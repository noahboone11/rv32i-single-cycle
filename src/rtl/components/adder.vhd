library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    generic (
        WIDTH : natural := 32
    );
    port (
        a : in  std_logic_vector(WIDTH-1 downto 0);
        b : in  std_logic_vector(WIDTH-1 downto 0);
        f : out std_logic_vector(WIDTH-1 downto 0)
    );
end adder;

architecture rtl of adder is
begin
    f <= std_logic_vector(unsigned(a) + unsigned(b));
end rtl;
