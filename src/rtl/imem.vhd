library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;

entity imem is
    port(a  : in  STD_LOGIC_VECTOR(31 downto 0);
         rd : out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of imem is
    type ramtype is array(63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);

    impure function init_ram_hex return ramtype is
        file text_file     : text open read_mode is "riscvtest.txt";
        variable text_line : line;
        variable ram_content : ramtype;
        variable i : integer := 0;
    begin
        for i in 0 to 63 loop
            ram_content(i) := (others => '0');
        end loop;
        while not endfile(text_file) loop
            readline(text_file, text_line);
            hread(text_line, ram_content(i));
            i := i + 1;
        end loop;
        return ram_content;
    end function;

    signal mem : ramtype := init_ram_hex;
begin
    process(a) begin
        rd <= mem(to_integer(unsigned(a(31 downto 2))));
    end process;
end;
