library ieee;
use ieee.std_logic_1164.all;

entity main_decoder is 
  port (
    opcode     : in std_logic_vector(6 downto 0);
    reg_write  : out std_logic;
    imm_src    : out std_logic_vector(1 downto 0);
    alu_src    : out std_logic;
    mem_write  : out std_logic;
    result_src : out std_logic_vector(1 downto 0);
    branch     : out std_logic;
    alu_op     : out std_logic_vector(1 downto 0);
    jump       : out std_logic
  );
end main_decoder;

architecture rtl of main_decoder is
  signal control_vector : std_logic_vector(10 downto 0);
begin
  process(opcode) begin
    case opcode is
      when "0000011" => control_vector <= "10010010000";   -- lw
      when "0100011" => control_vector <= "00111--0000";   --sw
      when "0110011" => control_vector <= "1--00000100";   -- R-type
      when "1100011" => control_vector <= "01000--1010";   -- beq
      when "0010011" => control_vector <= "10010000100";   -- I-type ALU
      when "1101111" => control_vector <= "111-0100--1";   -- jal
      when others    => control_vector <= (others => '-'); -- NOT VALID
    end case;
  end process;

  reg_write  <= control_vector(10);
  imm_src    <= control_vector(9 downto 8);
  alu_src    <= control_vector(7);
  mem_write  <= control_vector(6);
  result_src <= control_vector(5 downto 4);
  branch     <= control_vector(3);
  alu_op     <= control_vector(2 downto 1);
  jump       <= control_vector(0);

end rtl;