library ieee;
use ieee.std_logic_1164.all;

entity datapath_tb is
end datapath_tb;

architecture sim of datapath_tb is

  component datapath
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;
      reg_write   : in  std_logic;
      imm_src     : in  std_logic_vector(1 downto 0);
      alu_src     : in  std_logic;
      result_src  : in  std_logic_vector(1 downto 0);
      pc_src      : in  std_logic;
      alu_control : in  std_logic_vector(2 downto 0);
      instr       : in  std_logic_vector(31 downto 0);
      read_data   : in  std_logic_vector(31 downto 0);
      clk_en      : in  std_logic;
      dbg_addr    : in  std_logic_vector(4 downto 0);
      zero        : out std_logic;
      pc          : buffer std_logic_vector(31 downto 0);
      alu_result  : buffer std_logic_vector(31 downto 0);
      store_data  : buffer std_logic_vector(31 downto 0);
      dbg_data    : out std_logic_vector(31 downto 0)
    );
  end component;

  signal clk         : std_logic := '0';
  signal rst         : std_logic := '1';
  signal reg_write   : std_logic := '0';
  signal imm_src     : std_logic_vector(1 downto 0) := "00";
  signal alu_src     : std_logic := '0';
  signal result_src  : std_logic_vector(1 downto 0) := "00";
  signal pc_src      : std_logic := '0';
  signal alu_control : std_logic_vector(2 downto 0) := "000";
  signal instr       : std_logic_vector(31 downto 0) := (others => '0');
  signal read_data   : std_logic_vector(31 downto 0) := (others => '0');
  signal zero        : std_logic;
  signal pc          : std_logic_vector(31 downto 0);
  signal alu_result  : std_logic_vector(31 downto 0);
  signal store_data  : std_logic_vector(31 downto 0);

begin

  dut : datapath
    port map (
      clk         => clk,
      rst         => rst,
      reg_write   => reg_write,
      imm_src     => imm_src,
      alu_src     => alu_src,
      result_src  => result_src,
      pc_src      => pc_src,
      alu_control => alu_control,
      instr       => instr,
      read_data   => read_data,
      clk_en      => '1',
      dbg_addr    => (others => '0'),
      zero        => zero,
      pc          => pc,
      alu_result  => alu_result,
      store_data  => store_data,
      dbg_data    => open
    );

  clk <= not clk after 10 ns;

  stimulus : process
  begin
    wait until rising_edge(clk);
    wait for 1 ns;
    rst <= '0';
    wait until falling_edge(clk);

    -- addi x1, x0, 5
    reg_write   <= '1';
    imm_src     <= "00";
    alu_src     <= '1';
    result_src  <= "00";
    pc_src      <= '0';
    alu_control <= "000";
    instr       <= x"00500093";
    read_data   <= x"00000000";
    wait for 5 ns;
    assert alu_result = x"00000005" report "addi x1 ALU result incorrect" severity error;
    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000004" report "PC did not increment to 4 after addi x1" severity error;

    -- addi x2, x0, 12
    instr <= x"00C00113";
    wait for 5 ns;
    assert alu_result = x"0000000C" report "addi x2 ALU result incorrect" severity error;
    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000008" report "PC did not increment to 8 after addi x2" severity error;

    -- add x3, x1, x2
    alu_src     <= '0';
    instr       <= x"002081B3";
    wait for 5 ns;
    assert alu_result = x"00000011" report "add x3, x1, x2 result incorrect" severity error;
    assert zero = '0' report "zero flag incorrect for add x3, x1, x2" severity error;
    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"0000000C" report "PC did not increment to 12 after add" severity error;

    -- sw x3, 8(x0)
    reg_write   <= '0';
    imm_src     <= "01";
    alu_src     <= '1';
    instr       <= x"00302423";
    wait for 5 ns;
    assert alu_result = x"00000008" report "sw address calculation incorrect" severity error;
    assert store_data = x"00000011" report "sw store_data should be x3 = 17" severity error;
    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000010" report "PC did not increment to 16 after sw" severity error;

    -- lw x4, 0(x0)
    reg_write   <= '1';
    imm_src     <= "00";
    alu_src     <= '1';
    result_src  <= "01";
    instr       <= x"00002203";
    read_data   <= x"DEADBEEF";
    wait for 5 ns;
    assert alu_result = x"00000000" report "lw base+offset address incorrect" severity error;
    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000014" report "PC did not increment to 20 after lw" severity error;

    -- add x5, x4, x0
    result_src  <= "00";
    alu_src     <= '0';
    instr       <= x"000202B3";
    wait for 5 ns;
    assert alu_result = x"DEADBEEF" report "lw writeback into x4 failed" severity error;
    assert zero = '0' report "zero flag incorrect after x4 + x0" severity error;
    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000018" report "PC did not increment to 24 after add x5, x4, x0" severity error;

    -- jal x0, 8
    reg_write   <= '0';
    imm_src     <= "11";
    alu_src     <= '1';
    result_src  <= "10";
    pc_src      <= '1';
    instr       <= x"0080006F";
    read_data   <= x"00000000";
    wait until rising_edge(clk);
    wait for 1 ns;
    assert pc = x"00000020" report "jal target PC incorrect" severity error;

    report "datapath_tb completed successfully" severity note;
    wait;
  end process;

end sim;
