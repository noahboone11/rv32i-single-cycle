library ieee;
use ieee.std_logic_1164.all;

entity imm_extend is
	port (
		instruction : in  std_logic_vector(31 downto 7);
		ximm_sel    : in  std_logic_vector(2 downto 0);
		ximm        : out std_logic_vector(31 downto 0)
	);
end entity imm_extend;

architecture rtl of imm_extend is
begin
	process(all)
	begin
		case ximm_sel is
			-- I type: 12-bit signed immediate
			when "000" =>
				ximm <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);

			-- S type: 12-bit signed immediate
			when "001" =>
				ximm <= (31 downto 12 => instruction(31)) & instruction(31 downto 25) & instruction(11 downto 7);

			-- B type: signed branch offset
			when "010" =>
				ximm <= (31 downto 12 => instruction(31)) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';

			-- J type: signed jump offset
			when "011" =>
				ximm <= (31 downto 20 => instruction(31)) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';

			-- U type: upper 20 bits, low 12 forced to zero
			when "100" =>
				ximm <= instruction(31 downto 12) & (11 downto 0 => '0');

			when others =>
				ximm <= (others => '0');
		end case;
	end process;
end architecture rtl;
