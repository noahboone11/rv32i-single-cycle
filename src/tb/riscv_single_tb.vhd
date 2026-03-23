library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_single_tb is
end riscv_single_tb;

architecture tb of riscv_single_tb is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal WriteData : std_logic_vector(31 downto 0);
    signal DataAdr   : std_logic_vector(31 downto 0);
    signal MemWrite  : std_logic;

    constant CLK_PERIOD : time := 10 ns;

    signal store1_ok : boolean := false;
    signal store2_ok : boolean := false;
    signal store3_ok : boolean := false;
    signal store4_ok : boolean := false;
    signal any_fail  : boolean := false;

    component riscv_single
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            WriteData : out std_logic_vector(31 downto 0);
            DataAdr   : out std_logic_vector(31 downto 0);
            MemWrite  : out std_logic
        );
    end component;

begin

    uut : riscv_single
        port map (
            clk       => clk,
            reset     => reset,
            WriteData => WriteData,
            DataAdr   => DataAdr,
            MemWrite  => MemWrite
        );

    clk <= not clk after CLK_PERIOD / 2;

    stim_proc : process
    begin
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 80;

        if not store1_ok then
            report "FAIL: store1 - sw x5, 80(x0)" severity error;
        end if;
        if not store2_ok then
            report "FAIL: store2 - sw x10, 100(x0)" severity error;
        end if;
        if not store3_ok then
            report "FAIL: store3 - sw x14, 108(x0)" severity error;
        end if;
        if not store4_ok then
            report "FAIL: store4 - sw x10, 120(x0)" severity error;
        end if;

        wait for 1 ns;

        if store1_ok and store2_ok and store3_ok and store4_ok and not any_fail then
            report "PASS: all tests passed" severity note;
        else
            report "FAIL: one or more tests failed" severity failure;
        end if;

        wait;
    end process stim_proc;

    check_proc : process (clk)
    begin
        if rising_edge(clk) and reset = '0' then
            if MemWrite = '1' then
                case DataAdr is

                    when x"00000050" =>  -- mem[80] = 17, tests add/addi/sw
                        if WriteData = x"00000011" then
                            report "PASS: store1 mem[80]=17" severity note;
                            store1_ok <= true;
                        else
                            report "FAIL: store1 wrong data" severity error;
                            any_fail <= true;
                        end if;

                    when x"00000064" =>  -- mem[100] = 17, tests lw/sw + beq not-taken
                        if WriteData = x"00000011" then
                            report "PASS: store2 mem[100]=17" severity note;
                            store2_ok <= true;
                        else
                            report "FAIL: store2 wrong data" severity error;
                            any_fail <= true;
                        end if;

                    when x"0000006C" =>  -- mem[108] = 7, tests beq taken
                        if WriteData = x"00000007" then
                            report "PASS: store3 mem[108]=7" severity note;
                            store3_ok <= true;
                        else
                            report "FAIL: store3 wrong data" severity error;
                            any_fail <= true;
                        end if;

                    when x"00000078" =>  -- mem[120] = 9, tests always-taken beq
                        if WriteData = x"00000009" then
                            report "PASS: store4 mem[120]=9" severity note;
                            store4_ok <= true;
                        else
                            report "FAIL: store4 wrong data" severity error;
                            any_fail <= true;
                        end if;

                    when x"00000074" =>  -- guard: beq-taken should skip this
                        report "FAIL: guard1 - beq taken fell through" severity error;
                        any_fail <= true;

                    when x"00000070" =>  -- guard: always-taken beq should skip this
                        report "FAIL: guard2 - always-taken beq fell through" severity error;
                        any_fail <= true;

                    when others =>
                        report "FAIL: unexpected write to addr "
                               & integer'image(to_integer(unsigned(DataAdr)))
                            severity error;
                        any_fail <= true;

                end case;
            end if;
        end if;
    end process check_proc;

end architecture tb;
