library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ghdl -a --workdir=work -g -fsynopsys kb_mapper.vhd kb_mapper_tb.vhd
-- ghdl --elab-run -g --workdir=work -fsynopsys kb_mapper_tb
 
entity kb_mapper_tb is
end entity kb_mapper_tb ;

architecture behavioral of kb_mapper_tb is

	component keyboard_mapper is
		generic(
			SLOW_KEY: std_logic_vector(7 downto 0) := X"1E";
			MED_KEY: std_logic_vector(7 downto 0) := X"1F";
			FAST_KEY: std_logic_vector(7 downto 0) := X"20";
			FIRE_KEY: std_logic_vector(7 downto 0) := X"17";
			BREAK_CODE: std_logic_vector(7 downto 0) := X"F0";
			SLOW_SPEED: std_logic_vector(1 downto 0) := "01";
			MED_SPEED: std_logic_vector(1 downto 0) := "10";
			FAST_SPEED: std_logic_vector(1 downto 0) := "11"
	);
		port (
			reset, clk: in std_logic;
			scan_code, scan_code_prev: in std_logic_vector(7 downto 0);
			scan_ready: in std_logic;
			speed: out std_logic_vector(1 downto 0);
			fire: out std_logic
		);
	end component keyboard_mapper;

    signal scan_code, scan_code_prev: std_logic_vector(7 downto 0) := (others => '0'); 
	signal reset, clk, scan_ready: std_logic := '0';
	signal speed : std_logic_vector(1 downto 0) := (others => '0');
	signal fire : std_logic := '0';

    signal finished : std_logic := '0';

	constant clk_period : time := 200 ms;
	constant SLOW_KEY: std_logic_vector(7 downto 0) := X"1E";
	constant MED_KEY: std_logic_vector(7 downto 0) := X"1F";
	constant FAST_KEY: std_logic_vector(7 downto 0) := X"20";
	constant FIRE_KEY: std_logic_vector(7 downto 0) := X"17";
	constant BREAK_CODE: std_logic_vector(7 downto 0) := X"F0";
	constant SLOW_SPEED:  std_logic_vector(1 downto 0) := "01";
	constant MED_SPEED:  std_logic_vector(1 downto 0) := "10";
	constant FAST_SPEED:  std_logic_vector(1 downto 0) := "11";

begin
    dut: keyboard_mapper
		generic map(
			SLOW_KEY => SLOW_KEY,
			MED_KEY => MED_KEY,
			FAST_KEY => FAST_KEY,
			FIRE_KEY => FIRE_KEY,
			BREAK_CODE => BREAK_CODE,
			SLOW_SPEED => SLOW_SPEED,
			MED_SPEED => MED_SPEED,
			FAST_SPEED => FAST_SPEED
		)
		port map(
			reset => reset, 
			clk => clk,
			scan_ready => scan_ready, 
			scan_code => scan_code, 
			scan_code_prev => scan_code_prev, 
			speed => speed,
			fire => fire
		);

    clk_process: process  is
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;

        if finished = '1' then
            wait;
        end if;
    end process;


	test_process: process is
    begin

		assert false report "start of test" severity note;

		-- test 0: simulate reset
		reset <= '1';
		wait for clk_period;
		assert speed = SLOW_SPEED report "Test 0 failed from speed" severity error;
		assert fire = '0' report "Test 0 failed from fire" severity error;
		reset <= '0'; 
		
		-- test 1: start by pressing and releasing fire key
		scan_code_prev <= X"00"; 
		scan_code <= FIRE_KEY; 
		scan_ready <= '1';
		wait for clk_period;
		assert speed = SLOW_SPEED report "Test 1A failed from speed" severity error;
		assert fire = '1' report "Test 1A failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= FIRE_KEY; -- release fire key
		scan_ready <= '1';
		wait for clk_period;
		assert speed = SLOW_SPEED report "Test 1B failed from speed" severity error;
		assert fire = '0' report "Test 1B failed from fire" severity error;

		-- test 2: press and release med_speed key to change speed
		scan_code_prev <= X"AB"; -- don't care 
		scan_code <= MED_KEY; 
		scan_ready <= '1';
		wait for clk_period;
		assert speed = MED_SPEED report "Test 2A failed from speed" severity error;
		assert fire = '0' report "Test 2A failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= MED_KEY; -- release med speed key
		scan_ready <= '1';
		wait for clk_period;
		assert speed = MED_SPEED report "Test 2B failed from speed" severity error;
		assert fire = '0' report "Test 2B failed from fire" severity error;

		-- test 3: press and hold fire, press slow_speed key, release slow_speed key, release fire key
		scan_code_prev <= X"AB"; -- don't care
		scan_code <= FIRE_KEY; -- press fire
		scan_ready <= '1';
		wait for clk_period;
		assert speed = MED_SPEED report "Test 3A failed from speed" severity error;
		assert fire = '1' report "Test 3A failed from fire" severity error;
		scan_code_prev <= FIRE_KEY; 
		scan_code <= SLOW_KEY; -- press slow_speed 
		scan_ready <= '1';
		wait for clk_period;
		assert speed = SLOW_SPEED report "Test 3B failed from speed" severity error;
		assert fire = '0' report "Test 3B failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= SLOW_KEY; -- release slow_speed
		scan_ready <= '1';
		wait for clk_period;
		assert speed = SLOW_SPEED report "Test 3C failed from speed" severity error;
		assert fire = '0' report "Test 3C failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= FIRE_KEY; -- release fire
		scan_ready <= '1';
		wait for clk_period;
		assert speed = SLOW_SPEED report "Test 3D failed from speed" severity error;
		assert fire = '0' report "Test 3D failed from fire" severity error;

		-- test 4: press and hold fire, press high_speed key, release fire key, release high_speed key, 
		scan_code_prev <= X"AB"; -- don't care
		scan_code <= FIRE_KEY; -- press fire
		scan_ready <= '1';
		wait for clk_period;
		assert speed = SLOW_SPEED report "Test 4A failed from speed" severity error;
		assert fire = '1' report "Test 4A failed from fire" severity error;
		scan_code_prev <= FIRE_KEY; 
		scan_code <= FAST_KEY; -- press fast 
		scan_ready <= '1';
		wait for clk_period;
		assert speed = FAST_SPEED report "Test 4B failed from speed" severity error;
		assert fire = '0' report "Test 4B failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= FIRE_KEY; -- release fire
		scan_ready <= '1';
		wait for clk_period;
		assert speed = FAST_SPEED report "Test 4C failed from speed" severity error;
		assert fire = '0' report "Test 4C failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= FAST_KEY; -- release fast
		scan_ready <= '1';
		wait for clk_period;
		assert speed = FAST_SPEED report "Test 4D failed from speed" severity error;
		assert fire = '0' report "Test 4D failed from fire" severity error;

		-- test 5: press and hold med_speed, press FAST_speed key, release med_speed
		scan_code_prev <= X"AB"; -- don't care
		scan_code <= MED_KEY; -- press med
		scan_ready <= '1';
		wait for clk_period;
		assert speed = MED_SPEED report "Test 5A failed from speed" severity error;
		assert fire = '0' report "Test 5A failed from fire" severity error;
		scan_code_prev <= FIRE_KEY; 
		scan_code <= FAST_KEY; -- press fast 
		scan_ready <= '1';
		wait for clk_period;
		assert speed = FAST_SPEED report "Test 5B failed from speed" severity error;
		assert fire = '0' report "Test 5B failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= MED_KEY; -- release med (speed should still be fast)
		scan_ready <= '1';
		wait for clk_period;
		assert speed = FAST_SPEED report "Test 5C failed from speed" severity error;
		assert fire = '0' report "Test 5C failed from fire" severity error;

        assert false report "end of test" severity note;
        finished <= '1';
		wait;
	end process test_process;

end architecture behavioral;
