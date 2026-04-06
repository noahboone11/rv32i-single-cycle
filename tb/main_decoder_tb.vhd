library ieee;
use ieee.std_logic_1164.all;

entity main_decoder_tb is
end main_decoder_tb;

architecture sim of main_decoder_tb is

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

  signal opcode     : std_logic_vector(6 downto 0) := (others => '0');
  signal reg_write  : std_logic;
  signal imm_src    : std_logic_vector(1 downto 0);
  signal alu_src    : std_logic;
  signal mem_write  : std_logic;
  signal result_src : std_logic_vector(1 downto 0);
  signal branch     : std_logic;
  signal alu_op     : std_logic_vector(1 downto 0);
  signal jump       : std_logic;

begin

  dut : main_decoder port map (
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

  stimulus : process
  begin
    opcode <= "0000011"; wait for 10 ns;
    assert reg_write = '1' and imm_src = "00" and alu_src = '1' and mem_write = '0'
           and result_src = "01" and branch = '0' and alu_op = "00" and jump = '0'
      report "lw decode incorrect" severity error;

    opcode <= "0100011"; wait for 10 ns;
    assert reg_write = '0' and imm_src = "01" and alu_src = '1' and mem_write = '1'
           and branch = '0' and alu_op = "00" and jump = '0'
      report "sw decode incorrect" severity error;

    opcode <= "0110011"; wait for 10 ns;
    assert reg_write = '1' and alu_src = '0' and mem_write = '0'
           and result_src = "00" and branch = '0' and alu_op = "10" and jump = '0'
      report "R-type decode incorrect" severity error;

    opcode <= "1100011"; wait for 10 ns;
    assert reg_write = '0' and imm_src = "10" and alu_src = '0' and mem_write = '0'
           and branch = '1' and alu_op = "01" and jump = '0'
      report "beq decode incorrect" severity error;

    opcode <= "0010011"; wait for 10 ns;
    assert reg_write = '1' and imm_src = "00" and alu_src = '1' and mem_write = '0'
           and result_src = "00" and branch = '0' and alu_op = "10" and jump = '0'
      report "I-type ALU decode incorrect" severity error;

    opcode <= "1101111"; wait for 10 ns;
    assert reg_write = '1' and imm_src = "11" and mem_write = '0'
           and result_src = "10" and branch = '0' and jump = '1'
      report "jal decode incorrect" severity error;

    report "main_decoder_tb completed successfully" severity note;
    wait;
  end process;

end sim;
