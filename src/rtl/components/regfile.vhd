library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
    port (
        clk         : in std_logic;
        write_en    : in std_logic;
        read_addr1  : in std_logic_vector(4 downto 0);
        read_addr2  : in std_logic_vector(4 downto 0);
        write_addr  : in std_logic_vector(4 downto 0);
        data_i      : in std_logic_vector(31 downto 0);
        data_o1     : out std_logic_vector(31 downto 0);
        data_o2     : out std_logic_vector(31 downto 0)
    );
end regfile;

architecture rtl of regfile is

    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);

    signal register_file : reg_array;

begin

    -- x0 hardwired to 0x00000000
    data_o1 <= x"00000000" when (read_addr1 = "00000") else register_file(read_addr1);
    data_o2 <= x"00000000" when (read_addr2 = "00000") else register_file(read_addr2);

    process(clk)
    begin
        if (rising_edge(clk)) then
            if (write_en and (write_addr /= "00000")) then
                register_file(write_addr) <= data_i;
            end if;
        end if;
    end process;

end rtl;