library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity top is
    port(clk, reset : in  STD_LOGIC;
         WriteData  : buffer STD_LOGIC_VECTOR(31 downto 0);
         DataAdr    : buffer STD_LOGIC_VECTOR(31 downto 0);
         MemWrite   : buffer STD_LOGIC);
end;

architecture test of top is
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
    component imem
        port(a  : in  STD_LOGIC_VECTOR(31 downto 0);
             rd : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    component dmem
        port(clk, we : in  STD_LOGIC;
             a, wd   : in  STD_LOGIC_VECTOR(31 downto 0);
             rd      : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    signal PC, Instr, ReadData : STD_LOGIC_VECTOR(31 downto 0);
    signal DispData            : STD_LOGIC_VECTOR(31 downto 0);
begin
    rvsingle: riscvsingle port map(clk, reset, PC, Instr, MemWrite,
                                   DataAdr, WriteData, ReadData,
                                   "00000", DispData);
    imem1: imem port map(PC, Instr);
    dmem1: dmem port map(clk, MemWrite, DataAdr, WriteData, ReadData);
end;
