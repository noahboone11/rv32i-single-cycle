library ieee;
use ieee.std_logic_1164.all;

entity control_unit_tb is
end control_unit_tb;

architecture sim of control_unit_tb is

  component control_unit
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
  end component;

  signal opcode      : std_logic_vector(6 downto 0) := (others => '0');
  signal funct3      : std_logic_vector(2 downto 0) := (others => '0');
  signal funct7_b5   : std_logic := '0';
  signal zero        : std_logic := '0';
  signal reg_write   : std_logic;
  signal imm_src     : std_logic_vector(1 downto 0);
  signal alu_src     : std_logic;
  signal mem_write   : std_logic;
  signal result_src  : std_logic_vector(1 downto 0);
  signal pc_src      : std_logic;
  signal alu_control : std_logic_vector(2 downto 0);

begin

  dut : control_unit
    port map (
      opcode      => opcode,
      funct3      => funct3,
      funct7_b5   => funct7_b5,
      zero        => zero,
      reg_write   => reg_write,
      imm_src     => imm_src,
      alu_src     => alu_src,
      mem_write   => mem_write,
      result_src  => result_src,
      pc_src      => pc_src,
      alu_control => alu_control
    );

  stimulus : process
  begin
    opcode <= "0000011"; funct3 <= "010"; funct7_b5 <= '0'; zero <= '0'; wait for 10 ns;
    assert reg_write = '1' and imm_src = "00" and alu_src = '1' and mem_write = '0'
           and result_src = "01" and pc_src = '0' and alu_control = "000"
      report "lw control decode incorrect" severity error;

    opcode <= "0100011"; funct3 <= "010"; funct7_b5 <= '0'; zero <= '0'; wait for 10 ns;
    assert reg_write = '0' and imm_src = "01" and alu_src = '1' and mem_write = '1'
           and pc_src = '0' and alu_control = "000"
      report "sw control decode incorrect" severity error;

    opcode <= "0110011"; funct3 <= "000"; funct7_b5 <= '0'; zero <= '0'; wait for 10 ns;
    assert reg_write = '1' and alu_src = '0' and mem_write = '0'
           and result_src = "00" and pc_src = '0' and alu_control = "000"
      report "R-type add control decode incorrect" severity error;

    opcode <= "0110011"; funct3 <= "000"; funct7_b5 <= '1'; zero <= '0'; wait for 10 ns;
    assert alu_control = "001" and pc_src = '0'
      report "R-type sub control decode incorrect" severity error;

    opcode <= "1100011"; funct3 <= "000"; funct7_b5 <= '0'; zero <= '0'; wait for 10 ns;
    assert reg_write = '0' and imm_src = "10" and alu_src = '0' and mem_write = '0'
           and pc_src = '0' and alu_control = "001"
      report "beq not taken control decode incorrect" severity error;

    opcode <= "1100011"; funct3 <= "000"; funct7_b5 <= '0'; zero <= '1'; wait for 10 ns;
    assert pc_src = '1' report "beq taken should assert pc_src" severity error;

    opcode <= "1101111"; funct3 <= "000"; funct7_b5 <= '0'; zero <= '0'; wait for 10 ns;
    assert reg_write = '1' and imm_src = "11"
           and result_src = "10" and pc_src = '1'
      report "jal control decode incorrect" severity error;

    report "control_unit_tb completed successfully" severity note;
    wait;
  end process;

end sim;
