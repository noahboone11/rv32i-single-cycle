library ieee;
use ieee.std_logic_1164.all;

-- Full-system integration testbench.
-- Uses the real dmem component so reads/writes go through actual memory
-- logic (address decode, byte-alignment, async read, sync write).
-- Instructions are driven by a combinational process (same approach as
-- riscv_single_tb) because imem.mif is not loaded by plain VHDL simulators.
-- This exercises every path the hardware will use except the FPGA ROM init.
--
-- Program under test (same sequence as riscv_single_tb):
--   0x00  addi x1, x0, 5       -- x1 = 5
--   0x04  addi x2, x0, 12      -- x2 = 12
--   0x08  add  x3, x1, x2      -- x3 = 17
--   0x0C  sw   x3, 8(x0)       -- mem[8] = 17   (real dmem write)
--   0x10  lw   x4, 8(x0)       -- x4 = mem[8]   (real dmem read)
--   0x14  add  x5, x4, x0      -- x5 = x4 = 17
--   0x18  jal  x0, 8           -- jump to 0x20
--   0x1C  addi x6, x0, 1       -- skipped
--   0x20  addi x7, x0, 9       -- x7 = 9

entity system_tb is
end system_tb;

architecture sim of system_tb is

  component riscv_single is
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      instruction : in  std_logic_vector(31 downto 0);
      read_data   : in  std_logic_vector(31 downto 0);
      clk_en      : in  std_logic;
      dbg_addr    : in  std_logic_vector(4 downto 0);
      pc          : out std_logic_vector(31 downto 0);
      mem_write   : out std_logic;
      alu_result  : out std_logic_vector(31 downto 0);
      store_data  : out std_logic_vector(31 downto 0);
      dbg_data    : out std_logic_vector(31 downto 0)
    );
  end component;

  component dmem is
    port (
      clk  : in  std_logic;
      we   : in  std_logic;
      addr : in  std_logic_vector(31 downto 0);
      wd   : in  std_logic_vector(31 downto 0);
      rd   : out std_logic_vector(31 downto 0)
    );
  end component;

  signal clk        : std_logic := '0';
  signal reset      : std_logic := '1';
  signal instruction: std_logic_vector(31 downto 0);
  signal read_data  : std_logic_vector(31 downto 0);
  signal pc         : std_logic_vector(31 downto 0);
  signal mem_write  : std_logic;
  signal alu_result : std_logic_vector(31 downto 0);
  signal store_data : std_logic_vector(31 downto 0);

begin

  clk <= not clk after 10 ns;

  cpu : riscv_single
    port map (
      clk         => clk,
      reset       => reset,
      instruction => instruction,
      read_data   => read_data,
      clk_en      => '1',
      dbg_addr    => (others => '0'),
      pc          => pc,
      mem_write   => mem_write,
      alu_result  => alu_result,
      store_data  => store_data,
      dbg_data    => open
    );

  data_mem : dmem
    port map (
      clk  => clk,
      we   => mem_write,
      addr => alu_result,
      wd   => store_data,
      rd   => read_data
    );

  -- Instruction ROM: combinational, addressed by PC
  process(pc)
  begin
    case pc is
      when x"00000000" => instruction <= x"00500093"; -- addi x1, x0, 5
      when x"00000004" => instruction <= x"00C00113"; -- addi x2, x0, 12
      when x"00000008" => instruction <= x"002081B3"; -- add  x3, x1, x2
      when x"0000000C" => instruction <= x"00302423"; -- sw   x3, 8(x0)
      when x"00000010" => instruction <= x"00802203"; -- lw   x4, 8(x0)
      when x"00000014" => instruction <= x"000202B3"; -- add  x5, x4, x0
      when x"00000018" => instruction <= x"0080006F"; -- jal  x0, 8
      when x"0000001C" => instruction <= x"00100313"; -- addi x6, x0, 1 (skipped)
      when x"00000020" => instruction <= x"00900393"; -- addi x7, x0, 9
      when others      => instruction <= x"00000013"; -- nop
    end case;
  end process;

  stimulus : process
  begin
    wait until rising_edge(clk);
    wait for 1 ns;
    reset <= '0';

    -- Cycle 0: addi x1, x0, 5
    wait for 5 ns;
    assert pc = x"00000000"
      report "PC should be 0x00" severity error;
    assert alu_result = x"00000005"
      report "addi x1: alu_result should be 5" severity error;
    assert mem_write = '0'
      report "addi x1: mem_write should be 0" severity error;

    -- Cycle 1: addi x2, x0, 12
    wait until rising_edge(clk); wait for 1 ns;
    assert pc = x"00000004"
      report "PC should be 0x04" severity error;
    assert alu_result = x"0000000C"
      report "addi x2: alu_result should be 12" severity error;
    assert mem_write = '0'
      report "addi x2: mem_write should be 0" severity error;

    -- Cycle 2: add x3, x1, x2
    wait until rising_edge(clk); wait for 1 ns;
    assert pc = x"00000008"
      report "PC should be 0x08" severity error;
    assert alu_result = x"00000011"
      report "add x3: alu_result should be 17" severity error;
    assert mem_write = '0'
      report "add x3: mem_write should be 0" severity error;

    -- Cycle 3: sw x3, 8(x0)  -- real dmem write
    wait until rising_edge(clk); wait for 1 ns;
    assert pc = x"0000000C"
      report "PC should be 0x0C" severity error;
    assert alu_result = x"00000008"
      report "sw: address should be 8" severity error;
    assert store_data = x"00000011"
      report "sw: store_data should be 17" severity error;
    assert mem_write = '1'
      report "sw: mem_write should be 1" severity error;

    -- Cycle 4: lw x4, 8(x0)  -- real dmem read (sw committed on prev rising edge)
    wait until rising_edge(clk); wait for 1 ns;
    assert pc = x"00000010"
      report "PC should be 0x10" severity error;
    assert alu_result = x"00000008"
      report "lw: address should be 8" severity error;
    assert mem_write = '0'
      report "lw: mem_write should be 0" severity error;
    -- read_data comes from real dmem: verify the async read returns what sw stored
    assert read_data = x"00000011"
      report "lw: dmem read_data should be 17 (written by sw)" severity error;

    -- Cycle 5: add x5, x4, x0  -- verifies lw writeback (x4 should now be 17)
    wait until rising_edge(clk); wait for 1 ns;
    assert pc = x"00000014"
      report "PC should be 0x14" severity error;
    assert alu_result = x"00000011"
      report "add x5: alu_result should be 17 (confirms lw loaded correctly)" severity error;
    assert mem_write = '0'
      report "add x5: mem_write should be 0" severity error;

    -- Cycle 6: jal x0, 8
    wait until rising_edge(clk); wait for 1 ns;
    assert pc = x"00000018"
      report "PC should be 0x18" severity error;
    assert mem_write = '0'
      report "jal: mem_write should be 0" severity error;

    -- Cycle 7: jal should have redirected PC to 0x20 (skipping 0x1C)
    wait until rising_edge(clk); wait for 1 ns;
    assert pc = x"00000020"
      report "jal: PC should jump to 0x20" severity error;
    assert alu_result = x"00000009"
      report "addi x7: alu_result should be 9" severity error;

    report "system_tb completed successfully" severity note;
    wait;
  end process;

end sim;
