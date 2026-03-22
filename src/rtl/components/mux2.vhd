library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
    generic (
        WIDTH : natural := 32
    );
    port (
        d0  : in  std_logic_vector(WIDTH-1 downto 0);
        d1  : in  std_logic_vector(WIDTH-1 downto 0);
        sel : in  std_logic;
        f   : out std_logic_vector(WIDTH-1 downto 0)
    );
end mux2;

architecture rtl of mux2 is
begin
    f <= d1 when (sel = '1') else d0;
end rtl;