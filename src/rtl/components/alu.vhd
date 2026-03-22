library ieee;
use ieee.std_logic_1164.all;

entity alu is
    port (
        alu_control: in  std_logic_vector(3 downto 0);
        src1       : in  std_logic_vector(31 downto 0);
        src2       : in  std_logic_vector(31 downto 0);
        alu_result : out std_logic_vector(31 downto 0);
        zero       : out std_logic
    );

end entity alu;

architecture rtl of alu is
begin
    process(all)
    begin
        case alu_control is
            when "0000" =>  -- ADD
                alu_result <= std_logic_vector(signed(src1) + signed(src2));
            when "0001" =>  -- SUB
                alu_result <= std_logic_vector(signed(src1) - signed(src2));
            when "0010" =>  -- AND
                alu_result <= src1 and src2;
            when "0011" =>  -- OR
                alu_result <= src1 or src2;
            when "0100" =>  -- SLT
                if signed(src1) < signed(src2) then
                    alu_result <= (31 downto 1 => '0') & '1';
                else
                    alu_result <= (others => '0');
                end if;
            when "0101" =>  -- SLTU
                if unsigned(src1) < unsigned(src2) then
                    alu_result <= (31 downto 1 => '0') & '1';
                else
                    alu_result <= (others => '0');
                end if;
            when "0110" =>  -- XOR
                alu_result <= src1 xor src2;
            when "0111" =>  -- LUI
                alu_result <= src2;
            when "1000" =>  -- SLL
                alu_result <= std_logic_vector(shift_left(unsigned(src1), to_integer(unsigned(src2(4 downto 0)))));
            when "1001" =>  -- SRA
                alu_result <= std_logic_vector(shift_right(signed(src1), to_integer(unsigned(src2(4 downto 0)))));
            when "1010" =>  -- SRL
                alu_result <= std_logic_vector(shift_right(unsigned(src1), to_integer(unsigned(src2(4 downto 0)))));
            when "1011" =>  -- AUIPC
                alu_result <= std_logic_vector(unsigned(src1) + unsigned(src2));
            when others =>
                alu_result <= (others => '0');

            zero <= '1' when alu_result = (others => '0') else '0';
        end case;
    end process;
end architecture rtl;