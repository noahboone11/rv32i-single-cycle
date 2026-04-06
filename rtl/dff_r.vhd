library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity dff_r is
    generic (
        WIDTH : integer := 32
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        d   : in std_logic_vector(WIDTH-1 downto 0);
        q   : out std_logic_vector(WIDTH-1 downto 0)
    );
end dff_r;

architecture rtl of dff_r is
    begin
        process (clk, rst)
        begin
            if rst = '1' then
                q <= (others => '0');
            elsif rising_edge(clk) then
                q <= d;
            end if;
        end process;
end rtl;
