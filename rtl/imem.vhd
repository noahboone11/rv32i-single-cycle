library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Instruction memory implemented as inferred ROM.
-- Quartus should initialize this on-chip memory from ../mem/imem.mif
-- when the Quartus project lives in the quartus/ folder.
-- PC is byte addressed, so addr(7 downto 2) selects one of 64 words.

entity imem is
  port (
    addr : in  std_logic_vector(31 downto 0);
    rd   : out std_logic_vector(31 downto 0)
  );
end imem;

architecture rtl of imem is

  type mem_array is array (0 to 63) of std_logic_vector(31 downto 0);
  signal memory : mem_array;

  attribute ram_init_file : string;
  attribute ram_init_file of memory : signal is "../mem/imem.mif";

begin

  process(addr)
  begin
    rd <= memory(to_integer(unsigned(addr(7 downto 2))));
  end process;

end rtl;
