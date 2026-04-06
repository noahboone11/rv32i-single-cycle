library ieee;
use ieee.std_logic_1164.all;

entity seven_seg_decoder is
    port (
        hex_i : in  std_logic_vector(3 downto 0);
        seg_o : out std_logic_vector(6 downto 0)
    );
end seven_seg_decoder;

architecture rtl of seven_seg_decoder is
    -- Bit aliases for readability
    signal h3, h2, h1, h0 : std_logic;

begin
    
    h3 <= hex_i(3);
    h2 <= hex_i(2);
    h1 <= hex_i(1);
    h0 <= hex_i(0);

    -- Segment 0
    seg_o(0) <= ((not h2) and h0 and (h3 xnor h1))
                or (h2 and (not h1) and (h3 xnor h0));

    -- Segment 1
    seg_o(1) <= (h2 and (not h0) and (h3 or h1))
                or (h0 and ((h3 and h1) or ((not h3) and h2 and (not h1))));

    -- Segment 2
    seg_o(2) <= (h3 and h2 and (h1 or (not h0)))
                or ((not h3) and (not h2) and h1 and (not h0));

    -- Segment 3
    seg_o(3) <= (h0 and (h2 xnor h1))
                or ((not h0) and (((not h3) and h2 and (not h1)) or (h3 and (not h2) and h1)));

    -- Segment 4
    seg_o(4) <= ((not h3) and h0)
                or ((not h1) and (((not h2) and h0) or ((not h3) and h2)));

    -- Segment 5
    seg_o(5) <= ((not h3) and ((h1 and h0) or ((not h2) and (h1 or h0)))) 
                or (h3 and h2 and (not h1) and h0);

    -- Segment 6
    seg_o(6) <= ((not h3) and (((not h2) and (not h1)) or (h2 and h1 and h0)))
                or (h3 and h2 and (not h1) and (not h0));

end rtl;