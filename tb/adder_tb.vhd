library ieee;
use ieee.std_logic_1164.all;

entity adder_tb is
end adder_tb;

architecture sim of adder_tb is

  component adder
    port (
      a : in  std_logic_vector(31 downto 0);
      b : in  std_logic_vector(31 downto 0);
      y : out std_logic_vector(31 downto 0)
    );
  end component;

  signal a : std_logic_vector(31 downto 0) := (others => '0');
  signal b : std_logic_vector(31 downto 0) := (others => '0');
  signal y : std_logic_vector(31 downto 0);

begin

  dut : adder port map (a => a, b => b, y => y);

  stimulus : process
  begin
    a <= x"00000001"; b <= x"00000001"; wait for 10 ns;
    assert y = x"00000002" report "1 + 1 should equal 2" severity error;

    a <= x"00000005"; b <= x"00000003"; wait for 10 ns;
    assert y = x"00000008" report "5 + 3 should equal 8" severity error;

    a <= x"FFFFFFFF"; b <= x"00000001"; wait for 10 ns;
    assert y = x"00000000" report "FFFFFFFF + 1 should wrap to 0" severity error;

    a <= x"12345678"; b <= x"11111111"; wait for 10 ns;
    assert y = x"23456789" report "12345678 + 11111111 should equal 23456789" severity error;

    report "adder_tb completed successfully" severity note;
    wait;
  end process;

end sim;
