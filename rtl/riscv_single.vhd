library ieee;
use ieee.std_logic_1164.all;

entity riscv_single is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    instruction: in  std_logic_vector(31 downto 0);
    read_data  : in  std_logic_vector(31 downto 0);
    clk_en     : in  std_logic;
    dbg_addr   : in  std_logic_vector(4 downto 0);
    pc         : out std_logic_vector(31 downto 0);
    mem_write  : out std_logic;
    alu_result : out std_logic_vector(31 downto 0);
    store_data : out std_logic_vector(31 downto 0);
    dbg_data   : out std_logic_vector(31 downto 0)
  );
end riscv_single;

architecture structural of riscv_single is

  component control_unit is
    port (
      opcode      : in  std_logic_vector(6 downto 0);
      funct3      : in  std_logic_vector(2 downto 0);
      funct7_b5   : in  std_logic;
      zero        : in  std_logic;
      reg_write   : out std_logic;
      imm_src     : out std_logic_vector(1 downto 0);
      alu_src     : out std_logic;
      mem_write   : out std_logic;
      result_src  : out std_logic_vector(1 downto 0);
      pc_src      : out std_logic;
      alu_control : out std_logic_vector(2 downto 0)
    );
  end component;

  component datapath is
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

  signal alu_src_sig     : std_logic;
  signal reg_write_sig   : std_logic;
  signal zero_sig        : std_logic;
  signal pc_src_sig      : std_logic;
  signal imm_src_sig     : std_logic_vector(1 downto 0);
  signal result_src_sig  : std_logic_vector(1 downto 0);
  signal alu_control_sig : std_logic_vector(2 downto 0);
  signal mem_write_int   : std_logic;

begin

  control_unit_inst : control_unit
    port map (
      opcode      => instruction(6 downto 0),
      funct3      => instruction(14 downto 12),
      funct7_b5   => instruction(30),
      zero        => zero_sig,
      reg_write   => reg_write_sig,
      imm_src     => imm_src_sig,
      alu_src     => alu_src_sig,
      mem_write   => mem_write_int,
      result_src  => result_src_sig,
      pc_src      => pc_src_sig,
      alu_control => alu_control_sig
    );

  mem_write <= mem_write_int and clk_en;

  datapath_inst : datapath
    port map (
      clk         => clk,
      rst         => reset,
      reg_write   => reg_write_sig,
      imm_src     => imm_src_sig,
      alu_src     => alu_src_sig,
      result_src  => result_src_sig,
      pc_src      => pc_src_sig,
      alu_control => alu_control_sig,
      instr       => instruction,
      read_data   => read_data,
      clk_en      => clk_en,
      dbg_addr    => dbg_addr,
      zero        => zero_sig,
      pc          => pc,
      alu_result  => alu_result,
      store_data  => store_data,
      dbg_data    => dbg_data
    );

end structural;
