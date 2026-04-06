library ieee;
use ieee.std_logic_1164.all;

entity mux2_tb is
end mux2_tb;

architecture sim of mux2_tb is

  component mux2
    generic (
      WIDTH : integer := 32
    );
    port (
      sel : in std_logic;
      a   : in std_logic_vector(WIDTH-1 downto 0);
      b   : in std_logic_vector(WIDTH-1 downto 0);
      y   : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  signal sel : std_logic := '0';
  signal a   : std_logic_vector(31 downto 0) := (others => '0');
  signal b   : std_logic_vector(31 downto 0) := (others => '0');
  signal y   : std_logic_vector(31 downto 0);

begin

  dut : mux2 port map (sel => sel, a => a, b => b, y => y);

  stimulus : process
  begin
    a <= x"AAAAAAAA";
    b <= x"55555555";

    sel <= '0'; wait for 10 ns;
    assert y = x"AAAAAAAA" report "mux2 should select input a when sel = 0" severity error;

    sel <= '1'; wait for 10 ns;
    assert y = x"55555555" report "mux2 should select input b when sel = 1" severity error;

    a <= x"0000000F";
    b <= x"000000F0";
    sel <= '0'; wait for 10 ns;
    assert y = x"0000000F" report "mux2 failed after input change with sel = 0" severity error;

    sel <= '1'; wait for 10 ns;
    assert y = x"000000F0" report "mux2 failed after input change with sel = 1" severity error;

    report "mux2_tb completed successfully" severity note;
    wait;
  end process;

end sim;
