library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
    generic (
        width : integer := 32
    );
    port (
        sel : in std_logic;
        a   : in std_logic_vector(width-1 downto 0);
        b   : in std_logic_vector(width-1 downto 0);
        y   : out std_logic_vector(width-1 downto 0)
    );
end mux2;

architecture rtl of mux2 is
begin
    y <= a when sel = '0' else b;
end rtl;