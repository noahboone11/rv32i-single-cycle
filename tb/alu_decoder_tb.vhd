library ieee;
use ieee.std_logic_1164.all;

entity alu_decoder_tb is
end alu_decoder_tb;

architecture sim of alu_decoder_tb is

  component alu_decoder
    port (
      alu_op      : in  std_logic_vector(1 downto 0);
      funct3      : in  std_logic_vector(2 downto 0);
      opcode_b5   : in  std_logic;
      funct7_b5   : in  std_logic;
      alu_control : out std_logic_vector(2 downto 0)
    );
  end component;

  signal alu_op      : std_logic_vector(1 downto 0) := (others => '0');
  signal funct3      : std_logic_vector(2 downto 0) := (others => '0');
  signal opcode_b5   : std_logic := '0';
  signal funct7_b5   : std_logic := '0';
  signal alu_control : std_logic_vector(2 downto 0);

begin

  dut : alu_decoder port map (
    alu_op      => alu_op,
    funct3      => funct3,
    opcode_b5   => opcode_b5,
    funct7_b5   => funct7_b5,
    alu_control => alu_control
  );

  stimulus : process
  begin
    alu_op <= "00"; wait for 10 ns;
    assert alu_control = "000" report "lw/sw ALU op should decode to add" severity error;

    alu_op <= "01"; wait for 10 ns;
    assert alu_control = "001" report "branch ALU op should decode to subtract" severity error;

    alu_op <= "10"; funct3 <= "000"; opcode_b5 <= '0'; funct7_b5 <= '0'; wait for 10 ns;
    assert alu_control = "000" report "addi should decode to add" severity error;

    alu_op <= "10"; funct3 <= "000"; opcode_b5 <= '1'; funct7_b5 <= '1'; wait for 10 ns;
    assert alu_control = "001" report "sub should decode to subtract" severity error;

    alu_op <= "10"; funct3 <= "010"; opcode_b5 <= '0'; funct7_b5 <= '0'; wait for 10 ns;
    assert alu_control = "101" report "slt/slti should decode to slt" severity error;

    alu_op <= "10"; funct3 <= "110"; wait for 10 ns;
    assert alu_control = "011" report "or/ori should decode to or" severity error;

    alu_op <= "10"; funct3 <= "111"; wait for 10 ns;
    assert alu_control = "010" report "and/andi should decode to and" severity error;

    report "alu_decoder_tb completed successfully" severity note;
    wait;
  end process;

end sim;
