library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity alu is
    port(a, b      : in  STD_LOGIC_VECTOR(31 downto 0);
         ALUControl : in  STD_LOGIC_VECTOR(2 downto 0);
         ALUResult  : out STD_LOGIC_VECTOR(31 downto 0);
         Zero       : out STD_LOGIC);
end;

architecture behave of alu is
    signal result_int : STD_LOGIC_VECTOR(31 downto 0);
begin
    process(a, b, ALUControl) begin
        case ALUControl is
            when "000" => result_int <= std_logic_vector(signed(a) + signed(b));
            when "001" => result_int <= std_logic_vector(signed(a) - signed(b));
            when "010" => result_int <= a and b;
            when "011" => result_int <= a or b;
            when "101" =>
                if signed(a) < signed(b) then result_int <= (31 downto 1 => '0') & '1';
                else                          result_int <= (others => '0');
                end if;
            when others => result_int <= (others => '0');
        end case;
    end process;

    ALUResult <= result_int;
    Zero      <= '1' when result_int = X"00000000" else '0';
end;
