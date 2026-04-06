library ieee;
use ieee.std_logic_1164.all;

entity alu_decoder is
  port (
    alu_op      : in  std_logic_vector(1 downto 0);
    funct3      : in  std_logic_vector(2 downto 0);
    opcode_b5   : in  std_logic;
    funct7_b5   : in  std_logic;
    alu_control : out std_logic_vector(2 downto 0)
  );
end alu_decoder;

architecture rtl of alu_decoder is
    signal r_type_sub : std_logic;
begin
    r_type_sub <= funct7_b5 and opcode_b5; -- R-type sub instruction has funct7[5] = 1 and opcode[5] = 1
    process(alu_op, funct3, opcode_b5, funct7_b5, r_type_sub) begin
        case alu_op is
            when "00" => alu_control <= "000"; -- addition
            when "01" => alu_control <= "001"; -- subtraction
            when others => case funct3 is
                when "000" => if r_type_sub = '1' then
                                alu_control <= "001"; -- sub
                             else 
                                alu_control <= "000"; --add, addi
                             end if;
                when "010" => alu_control <= "101"; -- slt, slti
                when "110" => alu_control <= "011"; -- or, ori
                when "111" => alu_control <= "010"; -- and, andi
                when others => alu_control <= "---"; -- NOT VALID
            end case;
        end case;   
    end process;
end architecture;