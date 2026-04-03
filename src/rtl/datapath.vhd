library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity datapath is
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
end;

architecture struct of datapath is
    component flopr generic(width : integer);
        port(clk, reset : in  STD_LOGIC;
             d          : in  STD_LOGIC_VECTOR(width-1 downto 0);
             q          : out STD_LOGIC_VECTOR(width-1 downto 0));
    end component;
    component adder
        port(a, b : in  STD_LOGIC_VECTOR(31 downto 0);
             y    : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    component mux2 generic(width : integer);
        port(d0, d1 : in  STD_LOGIC_VECTOR(width-1 downto 0);
             s      : in  STD_LOGIC;
             y      : out STD_LOGIC_VECTOR(width-1 downto 0));
    end component;
    component mux3 generic(width : integer);
        port(d0, d1, d2 : in  STD_LOGIC_VECTOR(width-1 downto 0);
             s          : in  STD_LOGIC_VECTOR(1 downto 0);
             y          : out STD_LOGIC_VECTOR(width-1 downto 0));
    end component;
    component regfile
        port(clk          : in  STD_LOGIC;
             we3          : in  STD_LOGIC;
             a1, a2, a3   : in  STD_LOGIC_VECTOR(4 downto 0);
             wd3          : in  STD_LOGIC_VECTOR(31 downto 0);
             rd1, rd2     : out STD_LOGIC_VECTOR(31 downto 0);
             a_disp       : in  STD_LOGIC_VECTOR(4 downto 0);
             rd_disp      : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    component extend
        port(instr  : in  STD_LOGIC_VECTOR(31 downto 7);
             immsrc : in  STD_LOGIC_VECTOR(1 downto 0);
             immext : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    component alu
        port(a, b      : in  STD_LOGIC_VECTOR(31 downto 0);
             ALUControl : in  STD_LOGIC_VECTOR(2 downto 0);
             ALUResult  : buffer STD_LOGIC_VECTOR(31 downto 0);
             Zero       : out STD_LOGIC);
    end component;

    signal PCNext, PCPlus4, PCTarget : STD_LOGIC_VECTOR(31 downto 0);
    signal ImmExt                    : STD_LOGIC_VECTOR(31 downto 0);
    signal SrcA, SrcB                : STD_LOGIC_VECTOR(31 downto 0);
    signal Result                    : STD_LOGIC_VECTOR(31 downto 0);
begin
    -- next PC logic
    pcreg:      flopr    generic map(32) port map(clk, reset, PCNext, PC);
    pcadd4:     adder                    port map(PC, X"00000004", PCPlus4);
    pcaddbranch:adder                    port map(PC, ImmExt, PCTarget);
    pcmux:      mux2     generic map(32) port map(PCPlus4, PCTarget, PCSrc, PCNext);

    -- register file logic
    rf:  regfile port map(clk, RegWrite, Instr(19 downto 15),
                          Instr(24 downto 20), Instr(11 downto 7),
                          Result, SrcA, WriteData, DispAddr, DispData);
    ext: extend  port map(Instr(31 downto 7), ImmSrc, ImmExt);

    -- ALU logic
    srcbmux:   mux2 generic map(32) port map(WriteData, ImmExt, ALUSrc, SrcB);
    mainalu:   alu                   port map(SrcA, SrcB, ALUControl, ALUResult, Zero);
    resultmux: mux3 generic map(32) port map(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
end;
