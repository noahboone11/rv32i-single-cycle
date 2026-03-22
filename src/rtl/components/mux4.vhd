library ieee;
use ieee.std_logic_1164.all;

entity mux4 is
    generic (
        WIDTH : natural := 32
    );
    port (
        d0  : in  std_logic_vector(WIDTH-1 downto 0);
        d1  : in  std_logic_vector(WIDTH-1 downto 0);
        d2  : in  std_logic_vector(WIDTH-1 downto 0);
        d3  : in  std_logic_vector(WIDTH-1 downto 0);
        sel : in  std_logic_vector(1 downto 0);
        f   : out std_logic_vector(WIDTH-1 downto 0)
    );
end mux4;

architecture stuctural of mux4 is

    signal a, b : std_logic;

    component mux2 is
        port (
            d0  : in  std_logic_vector(WIDTH-1 downto 0);
            d1  : in  std_logic_vector(WIDTH-1 downto 0);
            sel : in  std_logic;
            f   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

begin

    mux2_0 : mux2 
        port map (
            d0  => d0,
            d1  => d1,
            sel => sel(0),
            f   => a
        );

    mux2_1 : mux2 
        port map (
            d0  => d1,
            d1  => d2,
            sel => sel(0),
            f   => b
        );

    mux2_2 : mux2 
        port map (
            a => d0,
            b => d1,
            sel => sel(1),
            f => f
        );

end structural;