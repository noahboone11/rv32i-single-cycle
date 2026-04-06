library ieee;
use ieee.std_logic_1164.all;

entity datapath is
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
end datapath;

architecture structural of datapath is

  component dff_r is
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

  component adder is
    port (
      a : in  std_logic_vector(31 downto 0);
      b : in  std_logic_vector(31 downto 0);
      y : out std_logic_vector(31 downto 0)
    );
  end component;

  component mux2 is
    generic (
      WIDTH : integer := 32
    );
    port (
      sel : in  std_logic;
      a   : in  std_logic_vector(WIDTH-1 downto 0);
      b   : in  std_logic_vector(WIDTH-1 downto 0);
      y   : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component mux3 is
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

  component regfile is
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

  component extend_unit is
    port (
      instr   : in  std_logic_vector(31 downto 7);
      imm_src : in  std_logic_vector(1 downto 0);
      imm_ext : out std_logic_vector(31 downto 0)
    );
  end component;

  component alu is
    port (
      a           : in  std_logic_vector(31 downto 0);
      b           : in  std_logic_vector(31 downto 0);
      alu_control : in  std_logic_vector(2 downto 0);
      alu_result  : buffer std_logic_vector(31 downto 0);
      zero        : out std_logic
    );
  end component;

  signal pc_next        : std_logic_vector(31 downto 0);
  signal pc_next_gated  : std_logic_vector(31 downto 0);
  signal pc_plus4       : std_logic_vector(31 downto 0);
  signal pc_target      : std_logic_vector(31 downto 0);
  signal imm_ext        : std_logic_vector(31 downto 0);
  signal src1           : std_logic_vector(31 downto 0);
  signal src2           : std_logic_vector(31 downto 0);
  signal result         : std_logic_vector(31 downto 0);
  signal reg_write_en   : std_logic;

begin

  -- Hold PC and suppress register writes when clock is not enabled (step mode)
  pc_next_gated <= pc_next when clk_en = '1' else pc;
  reg_write_en  <= reg_write and clk_en;

  pc_reg : dff_r
    generic map (
      WIDTH => 32
    )
    port map (
      clk => clk,
      rst => rst,
      d   => pc_next_gated,
      q   => pc
    );

  pc_plus4_adder : adder
    port map (
      a => pc,
      b => x"00000004",
      y => pc_plus4
    );

  pc_target_adder : adder
    port map (
      a => pc,
      b => imm_ext,
      y => pc_target
    );

  pc_mux : mux2
    generic map (
      WIDTH => 32
    )
    port map (
      sel => pc_src,
      a   => pc_plus4,
      b   => pc_target,
      y   => pc_next
    );

  reg_file_instance : regfile
    port map (
      clk        => clk,
      reg_write  => reg_write_en,
      rs1        => instr(19 downto 15),
      rs2        => instr(24 downto 20),
      rd         => instr(11 downto 7),
      write_data => result,
      read_data1 => src1,
      read_data2 => store_data,
      dbg_addr   => dbg_addr,
      dbg_data   => dbg_data
    );

  extend_instance : extend_unit
    port map (
      instr   => instr(31 downto 7),
      imm_src => imm_src,
      imm_ext => imm_ext
    );

  alu_src_mux : mux2
    generic map (
      WIDTH => 32
    )
    port map (
      sel => alu_src,
      a   => store_data,
      b   => imm_ext,
      y   => src2
    );

  alu_instance : alu
    port map (
      a           => src1,
      b           => src2,
      alu_control => alu_control,
      alu_result  => alu_result,
      zero        => zero
    );

  result_mux : mux3
    generic map (
      WIDTH => 32
    )
    port map (
      sel => result_src,
      a   => alu_result,
      b   => read_data,
      c   => pc_plus4,
      y   => result
    );

end structural;
