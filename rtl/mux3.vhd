library ieee;
use ieee.std_logic_1164.all;

entity mux3 is 
    generic (
        WIDTH : integer := 32
    );
    port (
        sel : in  std_logic_vector(1 downto 0);
        a   : in  std_logic_vector(WIDTH-1 downto 0);
        b   : in  std_logic_vector(WIDTH-1 downto 0);
        c   : in  std_logic_vector(WIDTH-1 downto 0);
        y   : out std_logic_vector(WIDTH-1 downto 0)
    );
end mux3;

architecture rtl of mux3 is
begin
    process(sel, a, b, c) begin
        if (sel = "00") then y <= a;
        elsif (sel = "01") then y <= b;
        elsif (sel = "10") then y <= c;
        end if;
    end process;
end rtl;