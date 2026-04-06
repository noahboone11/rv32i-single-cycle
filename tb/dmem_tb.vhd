library ieee;
use ieee.std_logic_1164.all;

-- Tests for dmem:
--   1. Write followed by read at the same address returns the written value.
--   2. Write with we = '0' does NOT update memory.
--   3. Writes to different addresses are independent.
--   4. Read is asynchronous: rd reflects the current address immediately
--      without waiting for a clock edge.

entity dmem_tb is
end dmem_tb;

architecture sim of dmem_tb is

  component dmem is
    port (
      clk  : in  std_logic;
      we   : in  std_logic;
      addr : in  std_logic_vector(31 downto 0);
      wd   : in  std_logic_vector(31 downto 0);
      rd   : out std_logic_vector(31 downto 0)
    );
  end component;

  signal clk  : std_logic := '0';
  signal we   : std_logic := '0';
  signal addr : std_logic_vector(31 downto 0) := (others => '0');
  signal wd   : std_logic_vector(31 downto 0) := (others => '0');
  signal rd   : std_logic_vector(31 downto 0);

begin

  dut : dmem
    port map (
      clk  => clk,
      we   => we,
      addr => addr,
      wd   => wd,
      rd   => rd
    );

  clk <= not clk after 10 ns;   -- 50 MHz (20 ns period)

  stimulus : process
  begin

    -- ----------------------------------------------------------------
    -- 1. Initial state: memory is all zeros.
    -- ----------------------------------------------------------------
    addr <= x"00000008";
    wait for 5 ns;
    assert rd = x"00000000"
      report "initial read at 0x08 should be 0" severity error;

    -- ----------------------------------------------------------------
    -- 2. Write with we = '1' stores on rising edge.
    -- ----------------------------------------------------------------
    addr <= x"00000008";
    wd   <= x"DEADBEEF";
    we   <= '1';
    wait until rising_edge(clk);   -- write occurs here
    wait for 1 ns;
    we   <= '0';

    -- Read back immediately (async read)
    assert rd = x"DEADBEEF"
      report "read after write at 0x08 should be 0xDEADBEEF" severity error;

    -- ----------------------------------------------------------------
    -- 3. Write with we = '0' must NOT change memory.
    -- ----------------------------------------------------------------
    addr <= x"00000008";
    wd   <= x"CAFEBABE";
    we   <= '0';
    wait until rising_edge(clk);   -- no write should happen
    wait for 1 ns;

    assert rd = x"DEADBEEF"
      report "value at 0x08 must not change when we = 0" severity error;

    -- ----------------------------------------------------------------
    -- 4. Writes to different word addresses are independent.
    -- ----------------------------------------------------------------
    addr <= x"0000001C";   -- word index 7
    wd   <= x"12345678";
    we   <= '1';
    wait until rising_edge(clk);
    wait for 1 ns;
    we   <= '0';

    assert rd = x"12345678"
      report "read at 0x1C should return 0x12345678" severity error;

    -- Previous write at 0x08 must be unchanged
    addr <= x"00000008";
    wait for 5 ns;
    assert rd = x"DEADBEEF"
      report "value at 0x08 must be unchanged after write to 0x1C" severity error;

    -- ----------------------------------------------------------------
    -- 5. Async read: changing address alone updates rd without a clock.
    -- ----------------------------------------------------------------
    addr <= x"0000001C";
    wait for 5 ns;
    assert rd = x"12345678"
      report "async read: switching addr to 0x1C should show 0x12345678 immediately"
      severity error;

    addr <= x"00000008";
    wait for 5 ns;
    assert rd = x"DEADBEEF"
      report "async read: switching addr back to 0x08 should show 0xDEADBEEF immediately"
      severity error;

    -- ----------------------------------------------------------------
    -- 6. Byte-address alignment: bits [1:0] are dropped.
    -- ----------------------------------------------------------------
    addr <= x"00000009";   -- byte offset 1 inside word at 0x08
    wait for 5 ns;
    assert rd = x"DEADBEEF"
      report "addr 0x09 must return same word as 0x08 (bits[1:0] ignored)"
      severity error;

    report "dmem_tb completed successfully" severity note;
    wait;
  end process;

end sim;
