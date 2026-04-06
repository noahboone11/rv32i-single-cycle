library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
  port (
    opcode      : in  std_logic_vector(6 downto 0);
    funct3      : in  std_logic_vector(2 downto 0);
    funct7_b5   : in  std_logic;
    zero        : in  std_logic;
    reg_write   : out std_logic;
    imm_src     : out std_logic_vector(1 downto 0);
    alu_src     : out std_logic;
    mem_write   : out std_logic;
    result_src  : out std_logic_vector(1 downto 0);
    pc_src      : out std_logic;
    alu_control : out std_logic_vector(2 downto 0)
  );
end control_unit;

architecture structural of control_unit is

  component main_decoder
    port (
      opcode     : in  std_logic_vector(6 downto 0);
      reg_write  : out std_logic;
      imm_src    : out std_logic_vector(1 downto 0);
      alu_src    : out std_logic;
      mem_write  : out std_logic;
      result_src : out std_logic_vector(1 downto 0);
      branch     : out std_logic;
      alu_op     : out std_logic_vector(1 downto 0);
      jump       : out std_logic
    );
  end component;

  component alu_decoder
    port (
      alu_op      : in  std_logic_vector(1 downto 0);
      funct3      : in  std_logic_vector(2 downto 0);
      opcode_b5   : in  std_logic;
      funct7_b5   : in  std_logic;
      alu_control : out std_logic_vector(2 downto 0)
    );
  end component;

  -- internal signals to connect the two decoders
  signal alu_op  : std_logic_vector(1 downto 0);
  signal branch  : std_logic;
  signal jump    : std_logic;

begin

  md : main_decoder port map (
    opcode     => opcode,
    reg_write  => reg_write,
    imm_src    => imm_src,
    alu_src    => alu_src,
    mem_write  => mem_write,
    result_src => result_src,
    branch     => branch,
    alu_op     => alu_op,
    jump       => jump
  );

  ad : alu_decoder port map (
    alu_op      => alu_op,
    funct3      => funct3,
    opcode_b5   => opcode(5),
    funct7_b5   => funct7_b5,
    alu_control => alu_control
  );

  pc_src <= (branch and zero) or jump;

end structural;