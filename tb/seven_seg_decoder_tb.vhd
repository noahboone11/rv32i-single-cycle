library ieee;
use ieee.std_logic_1164.all;

entity seven_seg_decoder_tb is
end seven_seg_decoder_tb;

architecture sim of seven_seg_decoder_tb is

  component seven_seg_decoder
    port (
      hex_i : in  std_logic_vector(3 downto 0);
      seg_o : out std_logic_vector(6 downto 0)
    );
  end component;

  signal hex_i : std_logic_vector(3 downto 0) := (others => '0');
  signal seg_o : std_logic_vector(6 downto 0);

begin

  dut : seven_seg_decoder port map (hex_i => hex_i, seg_o => seg_o);

  stimulus : process
  begin
    hex_i <= "0000"; wait for 10 ns;
    assert seg_o = "1000000" report "7-seg decode for 0 incorrect" severity error;

    hex_i <= "0001"; wait for 10 ns;
    assert seg_o = "1111001" report "7-seg decode for 1 incorrect" severity error;

    hex_i <= "0010"; wait for 10 ns;
    assert seg_o = "0100100" report "7-seg decode for 2 incorrect" severity error;

    hex_i <= "1001"; wait for 10 ns;
    assert seg_o = "0011000" report "7-seg decode for 9 incorrect" severity error;

    hex_i <= "1010"; wait for 10 ns;
    assert seg_o = "0001000" report "7-seg decode for A incorrect" severity error;

    hex_i <= "1111"; wait for 10 ns;
    assert seg_o = "0001110" report "7-seg decode for F incorrect" severity error;

    report "seven_seg_decoder_tb completed successfully" severity note;
    wait;
  end process;

end sim;
