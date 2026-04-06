library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a           : in  std_logic_vector(31 downto 0);
        b           : in  std_logic_vector(31 downto 0);
        alu_control : in  std_logic_vector(2 downto 0);
        alu_result  : buffer std_logic_vector(31 downto 0);
        zero        : out std_logic
    );
end alu;

architecture rtl of alu is
begin
    process(a, b, alu_control) begin
        case alu_control is
            when "000" => alu_result <= std_logic_vector(unsigned(a) + unsigned(b));        -- add
            when "001" => alu_result <= std_logic_vector(signed(a)   - signed(b));          -- sub
            when "010" => alu_result <= a and b;                                            -- and
            when "011" => alu_result <= a or b;                                             -- or
            when "101" =>                                                                   -- slt
                if signed(a) < signed(b) then
                    alu_result <= x"00000001";
                else 
                    alu_result <= x"00000000";
                end if;
            when others => alu_result <= (others => '0');
        end case;
    end process;

    zero <= '1' when alu_result = x"00000000" else '0';

end rtl;