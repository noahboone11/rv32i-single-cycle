-- =============================================================================
-- Self-Checking Testbench for RV32I Single-Cycle Processor
-- File: riscv_single_top_tb.vhd
-- =============================================================================
--
-- OVERVIEW
-- --------
-- This testbench drives the riscv_single_top entity through a 18-instruction
-- test program and verifies correctness without requiring manual waveform
-- inspection. It prints PASS/FAIL messages to the simulation console.
--
-- OBSERVABILITY
-- -------------
-- The DUT exposes three debug ports used for self-checking:
--   WriteData  (31:0)  - data being written to data memory
--   DataAdr    (31:0)  - byte address of that write
--   MemWrite          - high for one cycle on every store
--
-- TEST PROGRAM (loaded via memfile.dat in the simulation working directory)
-- -------------------------------------------------------------------------
-- Addr  Hex         Assembly                   Expected result
-- 0x00  00500193    addi x3,  x0, 5            x3  = 5
-- 0x04  00C00213    addi x4,  x0, 12           x4  = 12
-- 0x08  004182B3    add  x5,  x3, x4           x5  = 17
-- 0x0C  40320333    sub  x6,  x4, x3           x6  = 7
-- 0x10  00C2F3B3    and  x7,  x5, x6           x7  = 17 & 7  = 1
-- 0x14  00C2E433    or   x8,  x5, x6           x8  = 17 | 7  = 23
-- 0x18  0041A4B3    slt  x9,  x3, x4           x9  = 1  (5 < 12)
-- 0x1C  04502A23    sw   x5,  84(x0)           mem[84]  = 17  <STORE 1>
-- 0x20  05402503    lw   x10, 84(x0)           x10 = 17
-- 0x24  00418463    beq  x3,  x4, +8           5!=12 -> NOT taken, PC=0x28
-- 0x28  00100593    addi x11, x0, 1            x11 = 1  (reached: beq not taken)
-- 0x2C  06A02223    sw   x10, 100(x0)          mem[100] = 17  <STORE 2>
-- 0x30  00500613    addi x12, x0, 5            x12 = 5
-- 0x34  00C18463    beq  x3,  x12, +8          5==5  -> TAKEN, PC=0x3C
-- 0x38  06002A23    sw   x0,  116(x0)          [MUST NOT EXECUTE - branch taken]
-- 0x3C  00700713    addi x14, x0, 7            x14 = 7  (branch target)
-- 0x40  06E02623    sw   x14, 108(x0)          mem[108] = 7   <STORE 3>
-- 0x44  00000063    beq  x0,  x0, 0            halt (infinite loop)
--
-- CHECKED EVENTS
-- --------------
--   STORE 1 : DataAdr=84,  WriteData=17  (tests sw)
--   STORE 2 : DataAdr=100, WriteData=17  (tests lw/sw round-trip + beq not-taken)
--   STORE 3 : DataAdr=108, WriteData=7   (tests beq taken)
--   GUARD   : Write to DataAdr=116 must NEVER appear (would mean taken branch
--             fell through instead of jumping)
--
-- PASS condition : all three expected stores seen with correct data, guard
--                  address never written, no unexpected addresses written.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_single_top_tb is
end entity riscv_single_top_tb;

architecture sim of riscv_single_top_tb is

    -- -------------------------------------------------------------------------
    -- DUT signals
    -- -------------------------------------------------------------------------
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal WriteData : std_logic_vector(31 downto 0);
    signal DataAdr   : std_logic_vector(31 downto 0);
    signal MemWrite  : std_logic;

    -- -------------------------------------------------------------------------
    -- Timing
    -- -------------------------------------------------------------------------
    constant CLK_PERIOD : time := 10 ns;

    -- -------------------------------------------------------------------------
    -- Test-result tracking (driven from the monitor process)
    -- -------------------------------------------------------------------------
    signal store1_ok  : boolean := false;   -- sw x5,  84(x0)
    signal store2_ok  : boolean := false;   -- sw x10, 100(x0)
    signal store3_ok  : boolean := false;   -- sw x14, 108(x0)
    signal any_fail   : boolean := false;

    -- -------------------------------------------------------------------------
    -- DUT component declaration
    -- Assumes the top level exposes three debug outputs so that tests can
    -- observe data-memory activity without probing internal hierarchy.
    -- -------------------------------------------------------------------------
    component riscv_single_top
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            WriteData : out std_logic_vector(31 downto 0);
            DataAdr   : out std_logic_vector(31 downto 0);
            MemWrite  : out std_logic
        );
    end component;

begin

    -- =========================================================================
    -- DUT instantiation
    -- =========================================================================
    uut : riscv_single_top
        port map (
            clk       => clk,
            reset     => reset,
            WriteData => WriteData,
            DataAdr   => DataAdr,
            MemWrite  => MemWrite
        );

    -- =========================================================================
    -- Clock generation
    -- =========================================================================
    clk <= not clk after CLK_PERIOD / 2;

    -- =========================================================================
    -- Stimulus + final verdict
    -- =========================================================================
    stim_proc : process
    begin
        -- Hold reset for two full clock cycles
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';

        -- Give the processor enough cycles to finish all 17 executed
        -- instructions (18 words, one skipped).  50 cycles is generous.
        wait for CLK_PERIOD * 50;

        -- ------------------------------------------------------------------
        -- Check that every expected store was actually seen
        -- ------------------------------------------------------------------
        if not store1_ok then
            report "FAIL: STORE 1 - sw x5, 84(x0) never executed"
                severity error;
            any_fail <= true;
        end if;

        if not store2_ok then
            report "FAIL: STORE 2 - sw x10, 100(x0) never executed (lw/sw round-trip or beq-not-taken broken)"
                severity error;
            any_fail <= true;
        end if;

        if not store3_ok then
            report "FAIL: STORE 3 - sw x14, 108(x0) never executed (beq-taken or addi broken)"
                severity error;
            any_fail <= true;
        end if;

        -- Short wait so the signals above propagate before the final check
        wait for 1 ns;

        -- ------------------------------------------------------------------
        -- Print overall result
        -- ------------------------------------------------------------------
        if store1_ok and store2_ok and store3_ok and not any_fail then
            report "======================================" severity note;
            report "=====      ALL TESTS PASSED      =====" severity note;
            report "======================================" severity note;
        else
            report "======================================" severity failure;
            report "=====   ONE OR MORE TESTS FAILED  =====" severity failure;
            report "======================================" severity failure;
        end if;

        wait;
    end process stim_proc;

    -- =========================================================================
    -- Self-checking monitor
    -- Fires on every rising clock edge while not in reset.
    -- Checks DataAdr and WriteData whenever MemWrite is asserted.
    -- =========================================================================
    check_proc : process (clk)
    begin
        if rising_edge(clk) and reset = '0' then
            if MemWrite = '1' then

                case DataAdr is

                    -- ---------------------------------------------------------
                    -- STORE 1: sw x5, 84(x0)  =>  mem[84] = 17
                    -- Tests: sw, add, addi
                    -- ---------------------------------------------------------
                    when x"00000054" =>
                        if WriteData = x"00000011" then
                            report "PASS: STORE 1 - mem[84] = 17  (add + sw correct)"
                                severity note;
                            store1_ok <= true;
                        else
                            report "FAIL: STORE 1 - mem[84]: expected 17, got "
                                   & integer'image(to_integer(unsigned(WriteData)))
                                   severity error;
                            any_fail <= true;
                        end if;

                    -- ---------------------------------------------------------
                    -- STORE 2: sw x10, 100(x0)  =>  mem[100] = 17
                    -- Tests: lw/sw round-trip, beq (not taken), addi x11 executed
                    -- ---------------------------------------------------------
                    when x"00000064" =>
                        if WriteData = x"00000011" then
                            report "PASS: STORE 2 - mem[100] = 17  (lw/sw round-trip + beq-not-taken correct)"
                                severity note;
                            store2_ok <= true;
                        else
                            report "FAIL: STORE 2 - mem[100]: expected 17, got "
                                   & integer'image(to_integer(unsigned(WriteData)))
                                   severity error;
                            any_fail <= true;
                        end if;

                    -- ---------------------------------------------------------
                    -- STORE 3: sw x14, 108(x0)  =>  mem[108] = 7
                    -- Tests: beq (taken), branch target executed correctly
                    -- ---------------------------------------------------------
                    when x"0000006C" =>
                        if WriteData = x"00000007" then
                            report "PASS: STORE 3 - mem[108] = 7   (beq-taken + addi correct)"
                                severity note;
                            store3_ok <= true;
                        else
                            report "FAIL: STORE 3 - mem[108]: expected 7, got "
                                   & integer'image(to_integer(unsigned(WriteData)))
                                   severity error;
                            any_fail <= true;
                        end if;

                    -- ---------------------------------------------------------
                    -- GUARD: address 116 must never be written.
                    -- Instruction at 0x38 is in the branch-delay slot of the
                    -- TAKEN beq at 0x34; if the processor falls through instead
                    -- of jumping, this store executes and fails the test.
                    -- ---------------------------------------------------------
                    when x"00000074" =>
                        report "FAIL: GUARD - write to mem[116]: taken branch fell through (beq-taken broken)"
                            severity error;
                        any_fail <= true;

                    -- ---------------------------------------------------------
                    -- Any other address is unexpected
                    -- ---------------------------------------------------------
                    when others =>
                        report "FAIL: Unexpected memory write to address "
                               & integer'image(to_integer(unsigned(DataAdr)))
                               & "  data = "
                               & integer'image(to_integer(unsigned(WriteData)))
                               severity error;
                        any_fail <= true;

                end case;
            end if;
        end if;
    end process check_proc;

end architecture sim;
