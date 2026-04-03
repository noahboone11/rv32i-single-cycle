library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Converts a 4-bit nibble to a 7-segment pattern.
-- The DE1-SoC displays are common-anode: segment ON = '0', OFF = '1'.
-- Segment mapping: seg(0)=top, seg(1)=upper-right, seg(2)=lower-right,
--                  seg(3)=bottom, seg(4)=lower-left, seg(5)=upper-left, seg(6)=middle

entity hex_decoder is
    port(nibble : in  STD_LOGIC_VECTOR(3 downto 0);
         seg    : out STD_LOGIC_VECTOR(6 downto 0));  -- active low
end;

architecture behave of hex_decoder is
begin
    process(nibble) begin
        case nibble is
            when "0000" => seg <= "1000000"; -- 0
            when "0001" => seg <= "1111001"; -- 1
            when "0010" => seg <= "0100100"; -- 2
            when "0011" => seg <= "0110000"; -- 3
            when "0100" => seg <= "0011001"; -- 4
            when "0101" => seg <= "0010010"; -- 5
            when "0110" => seg <= "0000010"; -- 6
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
            when "1010" => seg <= "0001000"; -- A
            when "1011" => seg <= "0000011"; -- b
            when "1100" => seg <= "1000110"; -- C
            when "1101" => seg <= "0100001"; -- d
            when "1110" => seg <= "0000110"; -- E
            when "1111" => seg <= "0001110"; -- F
            when others => seg <= "1111111"; -- blank
        end case;
    end process;
end;
