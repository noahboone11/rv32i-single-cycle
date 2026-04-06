library ieee;
use ieee.std_logic_1164.all;

entity alu_tb is
end alu_tb;

architecture sim of alu_tb is

  component alu
    port (
      a           : in  std_logic_vector(31 downto 0);
      b           : in  std_logic_vector(31 downto 0);
      alu_control : in  std_logic_vector(2 downto 0);
      alu_result  : buffer std_logic_vector(31 downto 0);
      zero        : out std_logic
    );
  end component;

  signal a           : std_logic_vector(31 downto 0) := (others => '0');
  signal b           : std_logic_vector(31 downto 0) := (others => '0');
  signal alu_control : std_logic_vector(2 downto 0) := (others => '0');
  signal alu_result  : std_logic_vector(31 downto 0);
  signal zero        : std_logic;

begin

  dut : alu port map (a => a, b => b, alu_control => alu_control, alu_result => alu_result, zero => zero);

  stimulus : process
  begin
    a <= x"00000005"; b <= x"00000003"; alu_control <= "000"; wait for 10 ns;
    assert alu_result = x"00000008" and zero = '0' report "ALU add 5 + 3 failed" severity error;

    a <= x"FFFFFFFF"; b <= x"00000001"; alu_control <= "000"; wait for 10 ns;
    assert alu_result = x"00000000" and zero = '1' report "ALU add overflow wrap failed" severity error;

    a <= x"00000005"; b <= x"00000003"; alu_control <= "001"; wait for 10 ns;
    assert alu_result = x"00000002" and zero = '0' report "ALU sub 5 - 3 failed" severity error;

    a <= x"00000003"; b <= x"00000003"; alu_control <= "001"; wait for 10 ns;
    assert alu_result = x"00000000" and zero = '1' report "ALU sub equal operands failed" severity error;

    a <= x"FFFFFFFF"; b <= x"00000001"; alu_control <= "010"; wait for 10 ns;
    assert alu_result = x"00000001" report "ALU and failed" severity error;

    a <= x"F0F0F0F0"; b <= x"0F0F0F0F"; alu_control <= "011"; wait for 10 ns;
    assert alu_result = x"FFFFFFFF" report "ALU or failed" severity error;

    a <= x"00000003"; b <= x"00000005"; alu_control <= "101"; wait for 10 ns;
    assert alu_result = x"00000001" and zero = '0' report "ALU slt true case failed" severity error;

    a <= x"00000005"; b <= x"00000003"; alu_control <= "101"; wait for 10 ns;
    assert alu_result = x"00000000" and zero = '1' report "ALU slt false case failed" severity error;

    report "alu_tb completed successfully" severity note;
    wait;
  end process;

end sim;
