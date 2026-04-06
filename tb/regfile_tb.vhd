library ieee;
use ieee.std_logic_1164.all;

entity regfile_tb is
end regfile_tb;

architecture sim of regfile_tb is

  component regfile
    port (
      clk        : in  std_logic;
      reg_write  : in  std_logic;
      rs1        : in  std_logic_vector(4 downto 0);
      rs2        : in  std_logic_vector(4 downto 0);
      rd         : in  std_logic_vector(4 downto 0);
      write_data : in  std_logic_vector(31 downto 0);
      read_data1 : out std_logic_vector(31 downto 0);
      read_data2 : out std_logic_vector(31 downto 0);
      dbg_addr   : in  std_logic_vector(4 downto 0);
      dbg_data   : out std_logic_vector(31 downto 0)
    );
  end component;

  signal clk        : std_logic := '0';
  signal reg_write  : std_logic := '0';
  signal rs1        : std_logic_vector(4 downto 0) := (others => '0');
  signal rs2        : std_logic_vector(4 downto 0) := (others => '0');
  signal rd         : std_logic_vector(4 downto 0) := (others => '0');
  signal write_data : std_logic_vector(31 downto 0) := (others => '0');
  signal read_data1 : std_logic_vector(31 downto 0);
  signal read_data2 : std_logic_vector(31 downto 0);
  signal dbg_addr   : std_logic_vector(4 downto 0) := (others => '0');
  signal dbg_data   : std_logic_vector(31 downto 0);

begin

  dut : regfile
    port map (
      clk        => clk,
      reg_write  => reg_write,
      rs1        => rs1,
      rs2        => rs2,
      rd         => rd,
      write_data => write_data,
      read_data1 => read_data1,
      read_data2 => read_data2,
      dbg_addr   => dbg_addr,
      dbg_data   => dbg_data
    );

  clk <= not clk after 10 ns;

  stimulus : process
  begin
    rd <= "00001";
    write_data <= x"0000000A";
    reg_write <= '0';
    wait until rising_edge(clk);
    wait for 1 ns;
    rs1 <= "00001";
    wait for 5 ns;
    assert read_data1 = x"00000000" report "x1 should not write when reg_write = 0" severity error;

    reg_write <= '1';
    wait until rising_edge(clk);
    wait for 1 ns;
    reg_write <= '0';
    wait for 5 ns;
    assert read_data1 = x"0000000A" report "x1 should contain 10 after write" severity error;

    rd <= "00010";
    write_data <= x"00000014";
    reg_write <= '1';
    wait until rising_edge(clk);
    wait for 1 ns;
    reg_write <= '0';

    rs1 <= "00001";
    rs2 <= "00010";
    dbg_addr <= "00010";
    wait for 5 ns;
    assert read_data1 = x"0000000A" report "x1 readback incorrect" severity error;
    assert read_data2 = x"00000014" report "x2 readback incorrect" severity error;
    assert dbg_data   = x"00000014" report "debug read of x2 incorrect" severity error;

    rd <= "00000";
    write_data <= x"FFFFFFFF";
    reg_write <= '1';
    wait until rising_edge(clk);
    wait for 1 ns;
    reg_write <= '0';
    rs1 <= "00000";
    dbg_addr <= "00000";
    wait for 5 ns;
    assert read_data1 = x"00000000" report "x0 must remain zero" severity error;
    assert dbg_data   = x"00000000" report "debug read of x0 must be zero" severity error;

    report "regfile_tb completed successfully" severity note;
    wait;
  end process;

end sim;
