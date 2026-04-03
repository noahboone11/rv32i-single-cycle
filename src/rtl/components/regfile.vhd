library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity regfile is
    port(clk          : in  STD_LOGIC;
         we3          : in  STD_LOGIC;
         a1, a2, a3   : in  STD_LOGIC_VECTOR(4 downto 0);
         wd3          : in  STD_LOGIC_VECTOR(31 downto 0);
         rd1, rd2     : out STD_LOGIC_VECTOR(31 downto 0);
         -- display read port (third combinational read, for HEX display)
         a_disp       : in  STD_LOGIC_VECTOR(4 downto 0);
         rd_disp      : out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of regfile is
    type ramtype is array(31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
    signal mem : ramtype;
begin
    process(clk) begin
        if rising_edge(clk) then
            if we3 = '1' then mem(to_integer(unsigned(a3))) <= wd3;
            end if;
        end if;
    end process;
    rd1    <= X"00000000" when a1    = "00000" else mem(to_integer(unsigned(a1)));
    rd2    <= X"00000000" when a2    = "00000" else mem(to_integer(unsigned(a2)));
    rd_disp <= X"00000000" when a_disp = "00000" else mem(to_integer(unsigned(a_disp)));
end;
