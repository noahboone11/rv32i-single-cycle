library ieee;
use ieee.std_logic_1164.all;

entity riscv_single_tb is
end riscv_single_tb;

architecture sim of riscv_single_tb is

  component riscv_single
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

  signal clk         : std_logic := '0';
  signal reset       : std_logic := '1';
  signal instruction : std_logic_vector(31 downto 0);
  signal read_data   : std_logic_vector(31 downto 0);
  signal pc          : std_logic_vector(31 downto 0);
  signal mem_write   : std_logic;
  signal alu_result  : std_logic_vector(31 downto 0);
  signal store_data  : std_logic_vector(31 downto 0);

  signal mem_word_8  : std_logic_vector(31 downto 0) := (others => '0');

begin

  dut : riscv_single
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

  clk <= not clk after 10 ns;

  process(pc)
  begin
    case pc is
      when x"00000000" => instruction <= x"00500093"; -- addi x1, x0, 5
      when x"00000004" => instruction <= x"00C00113"; -- addi x2, x0, 12
      when x"00000008" => instruction <= x"002081B3"; -- add x3, x1, x2
      when x"0000000C" => instruction <= x"00302423"; -- sw x3, 8(x0)
      when x"00000010" => instruction <= x"00802203"; -- lw x4, 8(x0)
      when x"00000014" => instruction <= x"000202B3"; -- add x5, x4, x0
      when x"00000018" => instruction <= x"0080006F"; -- jal x0, 8
      when x"0000001C" => instruction <= x"00100313"; -- addi x6, x0, 1 (should skip)
      when x"00000020" => instruction <= x"00900393"; -- addi x7, x0, 9
      when others      => instruction <= x"00000013"; -- nop (addi x0, x0, 0)
    end case;
  end process;

  read_data <= mem_word_8 when alu_result = x"00000008" else (others => '0');

  process(clk)
  begin
    if rising_edge(clk) then
      if mem_write = '1' and alu_result = x"00000008" then
        mem_word_8 <= store_data;
      end if;
    end if;
  end process;

  stimulus : process
  begin
    wait until rising_edge(clk);
    wait for 1 ns;
    reset <= '0';

    wait for 5 ns;
    assert pc = x"00000000" report "PC should start at 0" severity error;
    assert alu_result = x"00000005" report "addi x1 ALU result incorrect" severity error;
    assert mem_write = '0' report "mem_write should be 0 during addi x1" severity error;

    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000004" report "PC should advance to 4" severity error;
    assert alu_result = x"0000000C" report "addi x2 ALU result incorrect" severity error;
    assert mem_write = '0' report "mem_write should be 0 during addi x2" severity error;

    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000008" report "PC should advance to 8" severity error;
    assert alu_result = x"00000011" report "add x3 result incorrect" severity error;
    assert mem_write = '0' report "mem_write should be 0 during add x3" severity error;

    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"0000000C" report "PC should advance to 12" severity error;
    assert alu_result = x"00000008" report "sw address incorrect" severity error;
    assert store_data = x"00000011" report "sw data should be x3 = 17" severity error;
    assert mem_write = '1' report "mem_write should be 1 during sw" severity error;

    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000010" report "PC should advance to 16" severity error;
    assert alu_result = x"00000008" report "lw address incorrect" severity error;
    assert mem_write = '0' report "mem_write should be 0 during lw" severity error;
    assert mem_word_8 = x"00000011" report "data memory did not store 17 at address 8" severity error;

    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000014" report "PC should advance to 20" severity error;
    assert alu_result = x"00000011" report "lw writeback into x4 failed" severity error;
    assert mem_write = '0' report "mem_write should be 0 during add x5, x4, x0" severity error;

    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000018" report "PC should advance to 24" severity error;
    assert mem_write = '0' report "mem_write should be 0 during jal" severity error;

    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000020" report "jal should redirect PC to 32" severity error;
    assert alu_result = x"00000009" report "addi x7 after jal result incorrect" severity error;

    report "riscv_single_tb completed successfully" severity note;
    wait;
  end process;

end sim;
