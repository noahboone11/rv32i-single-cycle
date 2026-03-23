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
    constant ADD_CTRL  : std_logic_vector(3 downto 0) := "0000";
    constant SUB_CTRL  : std_logic_vector(3 downto 0) := "0001";
    constant AND_CTRL  : std_logic_vector(3 downto 0) := "0010";
    constant OR_CTRL   : std_logic_vector(3 downto 0) := "0011";
    constant SLT_CTRL  : std_logic_vector(3 downto 0) := "0100";
    constant SLTU_CTRL : std_logic_vector(3 downto 0) := "0101";
    constant XOR_CTRL  : std_logic_vector(3 downto 0) := "0110";
    constant LUI_CTRL  : std_logic_vector(3 downto 0) := "0111";
    constant SLL_CTRL  : std_logic_vector(3 downto 0) := "1000";
    constant SRA_CTRL  : std_logic_vector(3 downto 0) := "1001";
    constant SRL_CTRL  : std_logic_vector(3 downto 0) := "1010";
    constant AUIPC_CTRL: std_logic_vector(3 downto 0) := "1011";
begin
    process(all)
    begin
        case alu_control is
            when ADD_CTRL =>
                alu_result <= std_logic_vector(signed(src1) + signed(src2));
            when SUB_CTRL =>
                alu_result <= std_logic_vector(signed(src1) - signed(src2));
            when AND_CTRL =>
                alu_result <= src1 and src2;
            when OR_CTRL =>
                alu_result <= src1 or src2;
            when SLT_CTRL =>
                if signed(src1) < signed(src2) then
                    alu_result <= (31 downto 1 => '0') & '1';
                else
                    alu_result <= (others => '0');
                end if;
            when SLTU_CTRL =>
                if unsigned(src1) < unsigned(src2) then
                    alu_result <= (31 downto 1 => '0') & '1';
                else
                    alu_result <= (others => '0');
                end if;
            when XOR_CTRL =>
                alu_result <= src1 xor src2;
            when LUI_CTRL =>
                alu_result <= src2;
            when SLL_CTRL =>
                alu_result <= std_logic_vector(shift_left(unsigned(src1), to_integer(unsigned(src2(4 downto 0)))));
            when SRA_CTRL =>
                alu_result <= std_logic_vector(shift_right(signed(src1), to_integer(unsigned(src2(4 downto 0)))));
            when SRL_CTRL =>
                alu_result <= std_logic_vector(shift_right(unsigned(src1), to_integer(unsigned(src2(4 downto 0)))));
            when AUIPC_CTRL =>
                alu_result <= std_logic_vector(unsigned(src1) + unsigned(src2));
            when others =>
                alu_result <= (others => '0');

            zero <= '1' when alu_result = (others => '0') else '0';
        end case;
    end process;
end architecture rtl;