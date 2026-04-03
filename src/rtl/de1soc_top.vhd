library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- DE1-SoC top-level for the RISC-V single-cycle processor.
--
-- Inputs:
--   CLOCK_50      50 MHz board clock
--   KEY(0)        Push-button reset (active low — hold to reset)
--   SW(4:0)       Selects which register (x0-x31) to display
--
-- Outputs:
--   HEX5-HEX0    Show the selected register value as 8 hex digits
--                HEX5:HEX4 = bits 31:16  (upper half)
--                HEX3:HEX2 = bits 23:16
--                HEX1:HEX0 = bits  7: 0
--                Full 32-bit value across all 6 displays (top 8 bits on HEX5:HEX4,
--                next 8 on HEX3:HEX2, bottom 8 on HEX1:HEX0, middle on HEX3:HEX2)
--                i.e. HEX5=bits[31:28], HEX4=bits[27:24], HEX3=bits[23:20],
--                     HEX2=bits[19:16], HEX1=bits[15:12]... wait, only 6 displays
--                     so we show the lower 24 bits on HEX5-HEX0 and upper byte on LEDR[7:0]
--   LEDR(7:0)    Upper byte of selected register (bits 31:24)
--   LEDR(9)      Done indicator: high when PC has not changed for one cycle
--                (processor is in an infinite loop — program finished)

entity de1soc_top is
    port(CLOCK_50 : in  STD_LOGIC;
         KEY      : in  STD_LOGIC_VECTOR(3 downto 0);
         SW       : in  STD_LOGIC_VECTOR(9 downto 0);
         HEX0     : out STD_LOGIC_VECTOR(6 downto 0);
         HEX1     : out STD_LOGIC_VECTOR(6 downto 0);
         HEX2     : out STD_LOGIC_VECTOR(6 downto 0);
         HEX3     : out STD_LOGIC_VECTOR(6 downto 0);
         HEX4     : out STD_LOGIC_VECTOR(6 downto 0);
         HEX5     : out STD_LOGIC_VECTOR(6 downto 0);
         LEDR     : out STD_LOGIC_VECTOR(9 downto 0));
end;

architecture rtl of de1soc_top is
    component riscvsingle
        port(clk, reset : in  STD_LOGIC;
             PC         : out STD_LOGIC_VECTOR(31 downto 0);
             Instr      : in  STD_LOGIC_VECTOR(31 downto 0);
             MemWrite   : out STD_LOGIC;
             ALUResult  : out STD_LOGIC_VECTOR(31 downto 0);
             WriteData  : out STD_LOGIC_VECTOR(31 downto 0);
             ReadData   : in  STD_LOGIC_VECTOR(31 downto 0);
             DispAddr   : in  STD_LOGIC_VECTOR(4 downto 0);
             DispData   : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    -- NOTE: For FPGA synthesis, replace imem with a Quartus IP ROM
    --       initialized from a .mif file via the IP Catalog (ROM: 1-PORT).
    --       The entity interface (a, rd) stays the same.
    component imem
        port(a  : in  STD_LOGIC_VECTOR(31 downto 0);
             rd : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    -- NOTE: For FPGA synthesis, replace dmem with a Quartus IP RAM
    --       (RAM: 1-PORT) so it maps to M10K block RAM.
    component dmem
        port(clk, we : in  STD_LOGIC;
             a, wd   : in  STD_LOGIC_VECTOR(31 downto 0);
             rd      : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component hex_decoder
        port(nibble : in  STD_LOGIC_VECTOR(3 downto 0);
             seg    : out STD_LOGIC_VECTOR(6 downto 0));
    end component;

    signal clk, reset              : STD_LOGIC;
    signal PC, PC_prev             : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr, ReadData         : STD_LOGIC_VECTOR(31 downto 0);
    signal MemWrite                : STD_LOGIC;
    signal ALUResult, WriteData    : STD_LOGIC_VECTOR(31 downto 0);
    signal DispData                : STD_LOGIC_VECTOR(31 downto 0);
    signal done                    : STD_LOGIC;

begin
    clk   <= CLOCK_50;
    reset <= not KEY(0);   -- KEY is active low; pressed = reset

    -- processor core
    cpu: riscvsingle port map(
        clk      => clk,
        reset    => reset,
        PC       => PC,
        Instr    => Instr,
        MemWrite => MemWrite,
        ALUResult => ALUResult,
        WriteData => WriteData,
        ReadData  => ReadData,
        DispAddr  => SW(4 downto 0),
        DispData  => DispData);

    imem1: imem port map(a => PC, rd => Instr);
    dmem1: dmem port map(clk => clk, we => MemWrite,
                         a => ALUResult, wd => WriteData, rd => ReadData);

    -- done detector: PC stable for one cycle = processor in infinite loop
    process(clk, reset) begin
        if reset = '1' then
            PC_prev <= (others => '0');
            done    <= '0';
        elsif rising_edge(clk) then
            PC_prev <= PC;
            if PC = PC_prev then done <= '1';
            else                 done <= '0';
            end if;
        end if;
    end process;

    -- HEX displays: show full 32-bit register value across 6 displays
    -- HEX5 = bits[31:28], HEX4 = bits[27:24]  (upper byte)
    -- HEX3 = bits[23:20], HEX2 = bits[19:16]
    -- HEX1 = bits[15:12], HEX0 = bits[11: 8]  (middle byte)
    -- Lower byte (bits[7:0]) shown on LEDR[7:0]
    h5: hex_decoder port map(nibble => DispData(31 downto 28), seg => HEX5);
    h4: hex_decoder port map(nibble => DispData(27 downto 24), seg => HEX4);
    h3: hex_decoder port map(nibble => DispData(23 downto 20), seg => HEX3);
    h2: hex_decoder port map(nibble => DispData(19 downto 16), seg => HEX2);
    h1: hex_decoder port map(nibble => DispData(15 downto 12), seg => HEX1);
    h0: hex_decoder port map(nibble => DispData(11 downto  8), seg => HEX0);

    LEDR(7 downto 0) <= DispData(7 downto 0);  -- lower byte on LEDs
    LEDR(8)          <= '0';
    LEDR(9)          <= done;
end;
