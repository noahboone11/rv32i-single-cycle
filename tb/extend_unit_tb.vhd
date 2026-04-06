library ieee;
use ieee.std_logic_1164.all;

entity extend_unit_tb is
end extend_unit_tb;

architecture sim of extend_unit_tb is

  component extend_unit
    port (
      instr   : in  std_logic_vector(31 downto 7);
      imm_src : in  std_logic_vector(1 downto 0);
      imm_ext : out std_logic_vector(31 downto 0)
    );
  end component;

  signal instr   : std_logic_vector(31 downto 7) := (others => '0');
  signal imm_src : std_logic_vector(1 downto 0) := (others => '0');
  signal imm_ext : std_logic_vector(31 downto 0);

begin

  dut : extend_unit port map (instr => instr, imm_src => imm_src, imm_ext => imm_ext);

  stimulus : process
  begin
    instr <= "000000000010" & "0000000000000"; imm_src <= "00"; wait for 10 ns;
    assert imm_ext = x"00000002" report "I-type positive immediate incorrect" severity error;

    instr <= "111111111111" & "0000000000000"; imm_src <= "00"; wait for 10 ns;
    assert imm_ext = x"FFFFFFFF" report "I-type negative immediate incorrect" severity error;

    instr <= "0000000" & "0000000000000" & "00100"; imm_src <= "01"; wait for 10 ns;
    assert imm_ext = x"00000004" report "S-type positive immediate incorrect" severity error;

    instr <= "1111111" & "0000000000000" & "11110"; imm_src <= "01"; wait for 10 ns;
    assert imm_ext = x"FFFFFFFE" report "S-type negative immediate incorrect" severity error;

    instr <= "0" & "000000" & "0000000000000" & "0010" & "0"; imm_src <= "10"; wait for 10 ns;
    assert imm_ext = x"00000004" report "B-type positive immediate incorrect" severity error;

    instr <= "1" & "111111" & "0000000000000" & "1110" & "1"; imm_src <= "10"; wait for 10 ns;
    assert imm_ext = x"FFFFFFFC" report "B-type negative immediate incorrect" severity error;

    instr <= "0" & "0000000010" & "0" & "00000000" & "00000"; imm_src <= "11"; wait for 10 ns;
    assert imm_ext = x"00000004" report "J-type positive immediate incorrect" severity error;

    instr <= "1" & "1111111110" & "1" & "11111111" & "00000"; imm_src <= "11"; wait for 10 ns;
    assert imm_ext = x"FFFFFFFC" report "J-type negative immediate incorrect" severity error;

    report "extend_unit_tb completed successfully" severity note;
    wait;
  end process;

end sim;
