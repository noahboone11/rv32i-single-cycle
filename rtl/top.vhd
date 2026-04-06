library ieee;
use ieee.std_logic_1164.all;

entity top is
  port (
    CLOCK_50 : in  std_logic;
    KEY      : in  std_logic_vector(3  downto 0);  -- active-low
    SW       : in  std_logic_vector(9  downto 0);
    LEDR     : out std_logic_vector(9  downto 0);
    HEX0     : out std_logic_vector(6  downto 0);
    HEX1     : out std_logic_vector(6  downto 0);
    HEX2     : out std_logic_vector(6  downto 0);
    HEX3     : out std_logic_vector(6  downto 0);
    HEX4     : out std_logic_vector(6  downto 0);
    HEX5     : out std_logic_vector(6  downto 0)
  );
end top;

-- SW[4:0]  : debug register select (x0-x31)
-- SW[6:5]  : display mode
--            00 = register value
--            01 = PC
--            10 = current instruction
--            11 = ALU result
-- SW[9]    : clock mode    0 = 50 MHz free-run   1 = single-step
-- KEY[0]   : reset (hold to reset, active-low)
-- KEY[1]   : single clock step (pulse, only used when SW[9]=1)
--
-- LEDR[7:0]  : display_val[31:24]  (upper byte of 32-bit value)
-- HEX5-HEX0 : display_val[23:0]   (lower 6 hex digits)
-- LEDR[8]    : step-mode indicator (mirrors SW[9])
-- LEDR[9]    : reset indicator     (lit while KEY[0] held)

architecture structural of top is

  component riscv_single is
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      instruction : in  std_logic_vector(31 downto 0);
      read_data   : in  std_logic_vector(31 downto 0);
      clk_en      : in  std_logic;
      dbg_addr    : in  std_logic_vector(4 downto 0);
      pc          : out std_logic_vector(31 downto 0);
      mem_write   : out std_logic;
      alu_result  : out std_logic_vector(31 downto 0);
      store_data  : out std_logic_vector(31 downto 0);
      dbg_data    : out std_logic_vector(31 downto 0)
    );
  end component;

  component imem is
    port (
      addr : in  std_logic_vector(31 downto 0);
      rd   : out std_logic_vector(31 downto 0)
    );
  end component;

  component dmem is
    port (
      clk  : in  std_logic;
      we   : in  std_logic;
      addr : in  std_logic_vector(31 downto 0);
      wd   : in  std_logic_vector(31 downto 0);
      rd   : out std_logic_vector(31 downto 0)
    );
  end component;

  component seven_seg_decoder is
    port (
      hex_i : in  std_logic_vector(3 downto 0);
      seg_o : out std_logic_vector(6 downto 0)
    );
  end component;

  signal reset       : std_logic;
  signal clk_en      : std_logic;
  signal step_pulse  : std_logic;
  signal key1_d      : std_logic := '1';

  signal pc          : std_logic_vector(31 downto 0);
  signal instruction : std_logic_vector(31 downto 0);
  signal mem_write   : std_logic;
  signal alu_result  : std_logic_vector(31 downto 0);
  signal store_data  : std_logic_vector(31 downto 0);
  signal read_data   : std_logic_vector(31 downto 0);
  signal dbg_data    : std_logic_vector(31 downto 0);
  signal display_val : std_logic_vector(31 downto 0);

begin

  reset <= not KEY(0);

  -- Edge detector on KEY[1] (active-low): fires one cycle on button press
  process(CLOCK_50)
  begin
    if rising_edge(CLOCK_50) then
      key1_d <= KEY(1);
    end if;
  end process;
  step_pulse <= key1_d and (not KEY(1));  -- falling edge of KEY[1]

  -- Clock enable: always-on in free-run mode, single pulse in step mode
  clk_en <= '1' when SW(9) = '0' else step_pulse;

  cpu : riscv_single
    port map (
      clk         => CLOCK_50,
      reset       => reset,
      instruction => instruction,
      read_data   => read_data,
      clk_en      => clk_en,
      dbg_addr    => SW(4 downto 0),
      pc          => pc,
      mem_write   => mem_write,
      alu_result  => alu_result,
      store_data  => store_data,
      dbg_data    => dbg_data
    );

  instruction_mem : imem
    port map (
      addr => pc,
      rd   => instruction
    );

  data_mem : dmem
    port map (
      clk  => CLOCK_50,
      we   => mem_write,
      addr => alu_result,
      wd   => store_data,
      rd   => read_data
    );

  -- Display mux:
  --   00 = selected register
  --   01 = PC
  --   10 = fetched instruction
  --   11 = ALU result
  with SW(6 downto 5) select
    display_val <= dbg_data     when "00",
                   pc           when "01",
                   instruction  when "10",
                   alu_result   when others;

  -- Lower 24 bits across six HEX displays
  seg0 : seven_seg_decoder port map (hex_i => display_val( 3 downto  0), seg_o => HEX0);
  seg1 : seven_seg_decoder port map (hex_i => display_val( 7 downto  4), seg_o => HEX1);
  seg2 : seven_seg_decoder port map (hex_i => display_val(11 downto  8), seg_o => HEX2);
  seg3 : seven_seg_decoder port map (hex_i => display_val(15 downto 12), seg_o => HEX3);
  seg4 : seven_seg_decoder port map (hex_i => display_val(19 downto 16), seg_o => HEX4);
  seg5 : seven_seg_decoder port map (hex_i => display_val(23 downto 20), seg_o => HEX5);

  -- Upper 8 bits on LEDR[7:0], status on LEDR[9:8]
  LEDR(7 downto 0) <= display_val(31 downto 24);
  LEDR(8)          <= SW(9);        -- lit = step mode active
  LEDR(9)          <= not KEY(0);   -- lit = reset held

end structural;
