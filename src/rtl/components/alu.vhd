library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity alu is
    port(a, b      : in  STD_LOGIC_VECTOR(31 downto 0);
         ALUControl : in  STD_LOGIC_VECTOR(2 downto 0);
         ALUResult  : buffer STD_LOGIC_VECTOR(31 downto 0);
         Zero       : out STD_LOGIC);
end;

architecture behave of alu is
begin
    process(all) begin
        case ALUControl is
            when "000" => ALUResult <= std_logic_vector(signed(a) + signed(b));   -- add
            when "001" => ALUResult <= std_logic_vector(signed(a) - signed(b));   -- sub
            when "010" => ALUResult <= a and b;                                    -- and
            when "011" => ALUResult <= a or b;                                     -- or
            when "101" =>                                                           -- slt
                if signed(a) < signed(b) then ALUResult <= (31 downto 1 => '0') & '1';
                else                          ALUResult <= (others => '0');
                end if;
            when others => ALUResult <= (others => '-');
        end case;
    end process;
    Zero <= '1' when ALUResult = X"00000000" else '0';
end;
