library ieee;
use ieee.std_logic_1164.all;

entity dff_r_tb is
end dff_r_tb;

architecture sim of dff_r_tb is

  component dff_r
    generic (
      WIDTH : integer := 32
    );
    port (
      clk : in std_logic;
      rst : in std_logic;
      d   : in std_logic_vector(WIDTH-1 downto 0);
      q   : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal d   : std_logic_vector(31 downto 0) := (others => '0');
  signal q   : std_logic_vector(31 downto 0);

begin

  dut : dff_r port map (clk => clk, rst => rst, d => d, q => q);

  clk <= not clk after 10 ns;

  stimulus : process
  begin
    rst <= '1';
    d   <= x"AAAAAAAA";
    wait for 5 ns;
    assert q = x"00000000" report "q should reset to 0 immediately when rst = 1" severity error;

    wait until rising_edge(clk);
    wait for 1 ns;
    assert q = x"00000000" report "q should stay 0 during reset" severity error;

    rst <= '0';
    d   <= x"00000005";
    wait until rising_edge(clk);
    wait for 1 ns;
    assert q = x"00000005" report "q should capture d on rising edge after reset release" severity error;

    d <= x"FFFFFFFF";
    wait until rising_edge(clk);
    wait for 1 ns;
    assert q = x"FFFFFFFF" report "q should capture updated d on next rising edge" severity error;

    report "dff_r_tb completed successfully" severity note;
    wait;
  end process;

end sim;
