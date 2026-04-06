library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Data memory: 64 x 32-bit words (256 bytes), byte-addressed.
-- Write is synchronous (registered on rising edge when we = '1').
-- Read is asynchronous so the single-cycle datapath can use read_data
-- combinationally in the same cycle as the ALU result address.
-- ramstyle "logic" keeps reads asynchronous (LUT-based inference).

entity dmem is
  port (
    clk  : in  std_logic;
    we   : in  std_logic;                        -- write enable (mem_write)
    addr : in  std_logic_vector(31 downto 0);    -- byte address (alu_result)
    wd   : in  std_logic_vector(31 downto 0);    -- write data   (store_data)
    rd   : out std_logic_vector(31 downto 0)     -- read data
  );
end dmem;

architecture rtl of dmem is

  type mem_array is array(0 to 63) of std_logic_vector(31 downto 0);
  signal mem : mem_array := (others => (others => '0'));

  attribute ramstyle : string;
  attribute ramstyle of mem : signal is "logic";

begin

  -- Synchronous write
  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        mem(to_integer(unsigned(addr(7 downto 2)))) <= wd;
      end if;
    end if;
  end process;

  -- Asynchronous read
  rd <= mem(to_integer(unsigned(addr(7 downto 2))));

end rtl;
