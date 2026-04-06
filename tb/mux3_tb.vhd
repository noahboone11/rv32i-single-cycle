library ieee;
use ieee.std_logic_1164.all;

entity mux3_tb is
end mux3_tb;

architecture sim of mux3_tb is

  component mux3
    generic (
      WIDTH : integer := 32
    );
    port (
      sel : in  std_logic_vector(1 downto 0);
      a   : in  std_logic_vector(WIDTH-1 downto 0);
      b   : in  std_logic_vector(WIDTH-1 downto 0);
      c   : in  std_logic_vector(WIDTH-1 downto 0);
      y   : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  signal sel : std_logic_vector(1 downto 0) := "00";
  signal a   : std_logic_vector(31 downto 0) := x"11111111";
  signal b   : std_logic_vector(31 downto 0) := x"22222222";
  signal c   : std_logic_vector(31 downto 0) := x"33333333";
  signal y   : std_logic_vector(31 downto 0);

begin

  dut : mux3 port map (sel => sel, a => a, b => b, c => c, y => y);

  stimulus : process
  begin
    sel <= "00"; wait for 10 ns;
    assert y = x"11111111" report "mux3 should select input a for sel = 00" severity error;

    sel <= "01"; wait for 10 ns;
    assert y = x"22222222" report "mux3 should select input b for sel = 01" severity error;

    sel <= "10"; wait for 10 ns;
    assert y = x"33333333" report "mux3 should select input c for sel = 10" severity error;

    report "mux3_tb completed successfully" severity note;
    wait;
  end process;

end sim;
