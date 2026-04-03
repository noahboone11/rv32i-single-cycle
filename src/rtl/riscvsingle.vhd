library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity riscvsingle is
    port(clk, reset : in  STD_LOGIC;
         PC         : out STD_LOGIC_VECTOR(31 downto 0);
         Instr      : in  STD_LOGIC_VECTOR(31 downto 0);
         MemWrite   : out STD_LOGIC;
         ALUResult  : out STD_LOGIC_VECTOR(31 downto 0);
         WriteData  : out STD_LOGIC_VECTOR(31 downto 0);
         ReadData   : in  STD_LOGIC_VECTOR(31 downto 0);
         DispAddr   : in  STD_LOGIC_VECTOR(4 downto 0);
         DispData   : out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture struct of riscvsingle is
    component controller
        port(op         : in  STD_LOGIC_VECTOR(6 downto 0);
             funct3     : in  STD_LOGIC_VECTOR(2 downto 0);
             funct7b5   : in  STD_LOGIC;
             Zero       : in  STD_LOGIC;
             ResultSrc  : out STD_LOGIC_VECTOR(1 downto 0);
             MemWrite   : out STD_LOGIC;
             PCSrc      : out STD_LOGIC;
             ALUSrc     : out STD_LOGIC;
             RegWrite   : out STD_LOGIC;
             Jump       : out STD_LOGIC;
             ImmSrc     : out STD_LOGIC_VECTOR(1 downto 0);
             ALUControl : out STD_LOGIC_VECTOR(2 downto 0));
    end component;
    component datapath
        port(clk, reset : in  STD_LOGIC;
             ResultSrc  : in  STD_LOGIC_VECTOR(1 downto 0);
             PCSrc      : in  STD_LOGIC;
             ALUSrc     : in  STD_LOGIC;
             RegWrite   : in  STD_LOGIC;
             ImmSrc     : in  STD_LOGIC_VECTOR(1 downto 0);
             ALUControl : in  STD_LOGIC_VECTOR(2 downto 0);
             Zero       : out STD_LOGIC;
             PC         : buffer STD_LOGIC_VECTOR(31 downto 0);
             Instr      : in  STD_LOGIC_VECTOR(31 downto 0);
             ALUResult  : out STD_LOGIC_VECTOR(31 downto 0);
             WriteData  : out STD_LOGIC_VECTOR(31 downto 0);
             ReadData   : in  STD_LOGIC_VECTOR(31 downto 0);
             DispAddr   : in  STD_LOGIC_VECTOR(4 downto 0);
             DispData   : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    signal ALUSrc, RegWrite, Jump, Zero : STD_LOGIC;
    signal ImmSrc, ResultSrc            : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUControl                   : STD_LOGIC_VECTOR(2 downto 0);
    signal PCSrc                        : STD_LOGIC;
begin
    c: controller port map(Instr(6 downto 0), Instr(14 downto 12),
                           Instr(30), Zero, ResultSrc, MemWrite,
                           PCSrc, ALUSrc, RegWrite, Jump, ImmSrc, ALUControl);
    dp: datapath  port map(clk, reset, ResultSrc, PCSrc, ALUSrc,
                           RegWrite, ImmSrc, ALUControl, Zero, PC, Instr,
                           ALUResult, WriteData, ReadData, DispAddr, DispData);
end;
