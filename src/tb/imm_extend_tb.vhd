library ieee;
use ieee.std_logic_1164.all;

entity imm_extend_tb is
end entity imm_extend_tb;

architecture tb of imm_extend_tb is
	signal instruction : std_logic_vector(31 downto 7) := (others => '0');
	signal ximm_sel    : std_logic_vector(2 downto 0)  := (others => '0');
	signal ximm        : std_logic_vector(31 downto 0);
begin
	dut: entity work.imm_extend
		port map (
			instruction => instruction,
			ximm_sel    => ximm_sel,
			ximm        => ximm
		);

	stim_proc: process
	begin
		-- I-type: +5
		instruction <= (others => '0');
		instruction(31 downto 20) <= "000000000101";
		ximm_sel <= "000";
		wait for 1 ns;
		assert ximm = x"00000005" report "I-type +5 failed" severity error;

		-- I-type: -4
		instruction <= (others => '0');
		instruction(31 downto 20) <= "111111111100";
		ximm_sel <= "000";
		wait for 1 ns;
		assert ximm = x"FFFFFFFC" report "I-type -4 failed" severity error;

		-- S-type: +20
		instruction <= (others => '0');
		instruction(31 downto 25) <= "0000000";
		instruction(11 downto 7)  <= "10100";
		ximm_sel <= "001";
		wait for 1 ns;
		assert ximm = x"00000014" report "S-type +20 failed" severity error;

		-- S-type: -8
		instruction <= (others => '0');
		instruction(31 downto 25) <= "1111111";
		instruction(11 downto 7)  <= "11000";
		ximm_sel <= "001";
		wait for 1 ns;
		assert ximm = x"FFFFFFF8" report "S-type -8 failed" severity error;

		-- B-type: +16
		instruction <= (others => '0');
		instruction(31)           <= '0';
		instruction(7)            <= '0';
		instruction(30 downto 25) <= "000000";
		instruction(11 downto 8)  <= "1000";
		ximm_sel <= "010";
		wait for 1 ns;
		assert ximm = x"00000010" report "B-type +16 failed" severity error;

		-- B-type: -4
		instruction <= (others => '0');
		instruction(31)           <= '1';
		instruction(7)            <= '1';
		instruction(30 downto 25) <= "111111";
		instruction(11 downto 8)  <= "1110";
		ximm_sel <= "010";
		wait for 1 ns;
		assert ximm = x"FFFFFFFC" report "B-type -4 failed" severity error;

		-- J-type: +2048
		instruction <= (others => '0');
		instruction(31)           <= '0';
		instruction(19 downto 12) <= "00000000";
		instruction(20)           <= '1';
		instruction(30 downto 21) <= "0000000000";
		ximm_sel <= "011";
		wait for 1 ns;
		assert ximm = x"00000800" report "J-type +2048 failed" severity error;

		-- J-type: -2
		instruction <= (others => '0');
		instruction(31)           <= '1';
		instruction(19 downto 12) <= "11111111";
		instruction(20)           <= '1';
		instruction(30 downto 21) <= "1111111111";
		ximm_sel <= "011";
		wait for 1 ns;
		assert ximm = x"FFFFFFFE" report "J-type -2 failed" severity error;

		-- U-type: 0x12345 << 12
		instruction <= (others => '0');
		instruction(31 downto 12) <= "00010010001101000101";
		ximm_sel <= "100";
		wait for 1 ns;
		assert ximm = x"12345000" report "U-type failed" severity error;

		-- Default selector case
		instruction <= (others => '1');
		ximm_sel <= "111";
		wait for 1 ns;
		assert ximm = x"00000000" report "Default case failed" severity error;

		report "imm_extend_tb completed successfully" severity note;
		wait;
	end process;
end architecture tb;
