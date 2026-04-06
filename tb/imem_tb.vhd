library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture sim_init of imem is
  type mem_array is array (0 to 63) of std_logic_vector(31 downto 0);
  signal memory : mem_array := (
    0 => x"00500093",
    1 => x"00C00113",
    2 => x"002081B3",
    3 => x"00302423",
    4 => x"00802203",
    5 => x"000202B3",
    6 => x"0080006F",
    7 => x"00100313",
    8 => x"00900393",
    9 => x"FF9FF06F",
    others => x"00000013"
  );
begin
  rd <= memory(to_integer(unsigned(addr(7 downto 2))));
end sim_init;

library ieee;
use ieee.std_logic_1164.all;

entity imem_tb is
end imem_tb;

architecture sim of imem_tb is

  component imem
    port (
      addr : in  std_logic_vector(31 downto 0);
      rd   : out std_logic_vector(31 downto 0)
    );
  end component;

  signal addr : std_logic_vector(31 downto 0) := (others => '0');
  signal rd   : std_logic_vector(31 downto 0);

begin

  dut : entity work.imem(sim_init) port map (addr => addr, rd => rd);

  stimulus : process
  begin
    addr <= x"00000000"; wait for 10 ns;
    assert rd = x"00500093" report "address 0x00 should fetch first instruction" severity error;

    addr <= x"00000001"; wait for 10 ns;
    assert rd = x"00500093" report "imem should ignore byte offset bit 0" severity error;

    addr <= x"00000002"; wait for 10 ns;
    assert rd = x"00500093" report "imem should ignore byte offset bit 1" severity error;

    addr <= x"00000003"; wait for 10 ns;
    assert rd = x"00500093" report "imem should ignore both low byte offset bits" severity error;

    addr <= x"00000004"; wait for 10 ns;
    assert rd = x"00C00113" report "address 0x04 should fetch second instruction" severity error;

    addr <= x"00000005"; wait for 10 ns;
    assert rd = x"00C00113" report "0x04 and 0x05 should map to the same instruction word" severity error;

    addr <= x"00000008"; wait for 10 ns;
    assert rd = x"002081B3" report "address 0x08 should fetch third instruction" severity error;

    addr <= x"00000009"; wait for 10 ns;
    assert rd = x"002081B3" report "0x08 and 0x09 should map to the same instruction word" severity error;

    report "imem_tb completed successfully" severity note;
    wait;
  end process;

end sim;
