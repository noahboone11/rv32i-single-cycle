library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture sim_init of imem is
  type mem_array is array (0 to 63) of std_logic_vector(31 downto 0);
  signal memory : mem_array := (
    0 => x"00500093",  -- addi x1, x0, 5
    1 => x"00C00113",  -- addi x2, x0, 12
    2 => x"002081B3",  -- add  x3, x1, x2
    3 => x"00302423",  -- sw   x3, 8(x0)
    4 => x"00802203",  -- lw   x4, 8(x0)
    5 => x"000202B3",  -- add  x5, x4, x0
    6 => x"0080006F",  -- jal  x0, 8
    7 => x"00100313",  -- addi x6, x0, 1
    8 => x"00900393",  -- addi x7, x0, 9
    9 => x"FF9FF06F",  -- jal  x0, -8
    others => x"00000013"
  );
begin
  rd <= memory(to_integer(unsigned(addr(7 downto 2))));
end sim_init;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is
end top_tb;

architecture sim of top_tb is

  component top
    port (
      CLOCK_50 : in  std_logic;
      KEY      : in  std_logic_vector(3 downto 0);
      SW       : in  std_logic_vector(9 downto 0);
      LEDR     : out std_logic_vector(9 downto 0);
      HEX0     : out std_logic_vector(6 downto 0);
      HEX1     : out std_logic_vector(6 downto 0);
      HEX2     : out std_logic_vector(6 downto 0);
      HEX3     : out std_logic_vector(6 downto 0);
      HEX4     : out std_logic_vector(6 downto 0);
      HEX5     : out std_logic_vector(6 downto 0)
    );
  end component;

  signal clock_50 : std_logic := '0';
  signal key      : std_logic_vector(3 downto 0) := (others => '1');
  signal sw       : std_logic_vector(9 downto 0) := (others => '0');
  signal ledr     : std_logic_vector(9 downto 0);
  signal hex0     : std_logic_vector(6 downto 0);
  signal hex1     : std_logic_vector(6 downto 0);
  signal hex2     : std_logic_vector(6 downto 0);
  signal hex3     : std_logic_vector(6 downto 0);
  signal hex4     : std_logic_vector(6 downto 0);
  signal hex5     : std_logic_vector(6 downto 0);

  function seg_encode(hex_i : std_logic_vector(3 downto 0)) return std_logic_vector is
  begin
    case hex_i is
      when "0000" => return "1000000";
      when "0001" => return "1111001";
      when "0010" => return "0100100";
      when "0011" => return "0110000";
      when "0100" => return "0011001";
      when "0101" => return "0010010";
      when "0110" => return "0000010";
      when "0111" => return "1111000";
      when "1000" => return "0000000";
      when "1001" => return "0011000";
      when "1010" => return "0001000";
      when "1011" => return "0000011";
      when "1100" => return "1000110";
      when "1101" => return "0100001";
      when "1110" => return "0000110";
      when others => return "0001110";
    end case;
  end function;

  procedure assert_display(
    constant expected : in std_logic_vector(31 downto 0)
  ) is
  begin
    assert ledr(7 downto 0) = expected(31 downto 24)
      report "LEDR upper byte display incorrect" severity error;
    assert hex5 = seg_encode(expected(23 downto 20))
      report "HEX5 display incorrect" severity error;
    assert hex4 = seg_encode(expected(19 downto 16))
      report "HEX4 display incorrect" severity error;
    assert hex3 = seg_encode(expected(15 downto 12))
      report "HEX3 display incorrect" severity error;
    assert hex2 = seg_encode(expected(11 downto 8))
      report "HEX2 display incorrect" severity error;
    assert hex1 = seg_encode(expected(7 downto 4))
      report "HEX1 display incorrect" severity error;
    assert hex0 = seg_encode(expected(3 downto 0))
      report "HEX0 display incorrect" severity error;
  end procedure;

begin

  dut : top
    port map (
      CLOCK_50 => clock_50,
      KEY      => key,
      SW       => sw,
      LEDR     => ledr,
      HEX0     => hex0,
      HEX1     => hex1,
      HEX2     => hex2,
      HEX3     => hex3,
      HEX4     => hex4,
      HEX5     => hex5
    );

  clock_50 <= not clock_50 after 10 ns;

  stimulus : process
  begin
    -- Hold reset, PC display should show zero and reset LED should light.
    sw(9) <= '1';            -- single-step mode
    sw(6 downto 5) <= "01";  -- display PC
    key(0) <= '0';           -- assert reset
    wait for 25 ns;
    assert ledr(9) = '1' report "reset indicator LED should light during reset" severity error;
    assert ledr(8) = '1' report "step mode indicator LED should mirror SW9" severity error;
    assert_display(x"00000000");

    -- Release reset and confirm first fetched instruction is shown.
    key(0) <= '1';
    sw(6 downto 5) <= "10";  -- display instruction
    wait for 10 ns;
    assert_display(x"00500093");

    -- Step once and confirm PC advances to 4.
    sw(6 downto 5) <= "01";  -- display PC
    wait for 5 ns;
    key(1) <= '0';
    wait for 20 ns;
    key(1) <= '1';
    wait for 15 ns;
    assert_display(x"00000004");

    -- In register-display mode, x1 should now contain 5.
    sw(6 downto 5) <= "00";
    sw(4 downto 0) <= "00001";
    wait for 10 ns;
    assert_display(x"00000005");

    -- Instruction display should now show the second instruction.
    sw(6 downto 5) <= "10";
    wait for 10 ns;
    assert_display(x"00C00113");

    report "top_tb completed successfully" severity note;
    wait;
  end process;

end sim;

configuration top_tb_cfg of top_tb is
  for sim
    for dut : top
      use entity work.top(structural);
      for structural
        for instruction_mem : imem
          use entity work.imem(sim_init);
        end for;
      end for;
    end for;
  end for;
end top_tb_cfg;
