library ieee;
use ieee.std_logic_1164.all;

entity main_decoder is
  port (
    opcode        : in  std_logic_vector(6 downto 0);
    dmem_wren     : out std_logic;
    jump          : out std_logic;
    branch        : out std_logic;
    alu_bsel      : out std_logic;
    regfile_wren  : out std_logic;
    pc_target_sel : out std_logic;
    result_sel    : out std_logic_vector(1 downto 0);
    ximm_sel      : out std_logic_vector(2 downto 0);
    alu_op        : out std_logic_vector(1 downto 0)
  );
end entity main_decoder;

architecture rtl of main_decoder is
  -- Opcode constants
  constant LW_OP     : std_logic_vector(6 downto 0) := "0000011";
  constant SW_OP     : std_logic_vector(6 downto 0) := "0100011";
  constant JAL_OP    : std_logic_vector(6 downto 0) := "1101111";
  constant JALR_OP   : std_logic_vector(6 downto 0) := "1100111";
  constant R_TYPE_OP : std_logic_vector(6 downto 0) := "0110011";
  constant B_TYPE_OP : std_logic_vector(6 downto 0) := "1100011";
  constant I_TYPE_OP : std_logic_vector(6 downto 0) := "0010011";
  constant LUI_OP    : std_logic_vector(6 downto 0) := "0110111";
  constant AUIPC_OP  : std_logic_vector(6 downto 0) := "0010111";

  -- Control vectors: {regfile_wren, ximm_sel[2:0], alu_bsel, dmem_wren, result_sel[1:0], branch, alu_op[1:0], jump, pc_target_sel}
  constant LW_CTRL     : std_logic_vector(12 downto 0) := "1_000_1_0_01_0_00_0_0";
  constant SW_CTRL     : std_logic_vector(12 downto 0) := "0_001_1_1_00_0_00_0_0";
  constant JAL_CTRL    : std_logic_vector(12 downto 0) := "1_011_0_0_10_0_00_1_0";
  constant JALR_CTRL   : std_logic_vector(12 downto 0) := "1_000_0_0_10_0_00_1_1";
  constant R_TYPE_CTRL : std_logic_vector(12 downto 0) := "1_000_0_0_00_0_10_0_0";
  constant B_TYPE_CTRL : std_logic_vector(12 downto 0) := "0_010_0_0_00_1_01_0_0";
  constant I_TYPE_CTRL : std_logic_vector(12 downto 0) := "1_000_1_0_00_0_10_0_0";
  constant LUI_CTRL    : std_logic_vector(12 downto 0) := "1_100_1_0_00_0_11_0_0";
  constant AUIPC_CTRL  : std_logic_vector(12 downto 0) := "1_100_0_0_11_0_11_0_0";

  signal controls : std_logic_vector(12 downto 0);

begin
  -- Unpack control vector into individual signals
  regfile_wren  <= controls(12);
  ximm_sel      <= controls(11 downto 9);
  alu_bsel      <= controls(8);
  dmem_wren     <= controls(7);
  result_sel    <= controls(6 downto 5);
  branch        <= controls(4);
  alu_op        <= controls(3 downto 2);
  jump          <= controls(1);
  pc_target_sel <= controls(0);

  process(all)
  begin
    case opcode is
      when LW_OP     => controls <= LW_CTRL;
      when SW_OP     => controls <= SW_CTRL;
      when JAL_OP    => controls <= JAL_CTRL;
      when JALR_OP   => controls <= JALR_CTRL;
      when R_TYPE_OP => controls <= R_TYPE_CTRL;
      when B_TYPE_OP => controls <= B_TYPE_CTRL;
      when I_TYPE_OP => controls <= I_TYPE_CTRL;
      when LUI_OP    => controls <= LUI_CTRL;
      when AUIPC_OP  => controls <= AUIPC_CTRL;
      when others    => controls <= (others => '0');
    end case;
  end process;

end architecture rtl;
