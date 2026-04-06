library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  port (
    clk       : in  std_logic;
    reg_write : in  std_logic;
    rs1       : in  std_logic_vector(4 downto 0);
    rs2       : in  std_logic_vector(4 downto 0);
    rd        : in  std_logic_vector(4 downto 0);
    write_data: in  std_logic_vector(31 downto 0);
    read_data1: out std_logic_vector(31 downto 0);
    read_data2: out std_logic_vector(31 downto 0);
    dbg_addr  : in  std_logic_vector(4 downto 0);
    dbg_data  : out std_logic_vector(31 downto 0)
  );
end regfile;

architecture rtl of regfile is

  type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
  signal regs : reg_array := (others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reg_write = '1' and rd /= "00000" then
                regs(to_integer(unsigned(rd))) <= write_data;
            end if;
        end if;
    end process;

    read_data1 <= (others => '0') when rs1 = "00000" else regs(to_integer(unsigned(rs1)));
    read_data2 <= (others => '0') when rs2 = "00000" else regs(to_integer(unsigned(rs2)));
    dbg_data   <= (others => '0') when dbg_addr = "00000" else regs(to_integer(unsigned(dbg_addr)));

  end rtl;