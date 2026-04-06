library ieee;
use ieee.std_logic_1164.all;

entity extend_unit is
    port (
        instr  :  in std_logic_vector(31 downto 7);
        imm_src : in std_logic_vector(1 downto 0);
        imm_ext : out std_logic_vector(31 downto 0)
    );
end extend_unit;

architecture rtl of extend_unit is
begin
    process(instr, imm_src) begin
        case imm_src is
            when "00" => 
                imm_ext <= (31 downto 12 => instr(31)) & instr(31 downto 20); -- I-type
            when "01" =>
                imm_ext <= (31 downto 12 => instr(31)) & instr(31 downto 25) & instr(11 downto 7); -- S-type
            when "10" =>
                imm_ext <= (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'; -- B-type
            when "11" =>
                imm_ext <= (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'; -- J-type
            when others =>
                imm_ext <= (31 downto 0 => '-'); -- NOT VALID
        end case;
    end process;
end rtl;