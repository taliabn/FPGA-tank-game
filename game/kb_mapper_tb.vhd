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
			BREAK_CODE: std_logic_vector(7 downto 0) := X"F0"
		);
		port (
			reset: in std_logic;
			scan_code, scan_code_prev: in std_logic_vector(7 downto 0);
			scan_ready: in std_logic;
			speed: out std_logic_vector(1 downto 0);
			fire: out std_logic
		);
	end component keyboard_mapper;

    signal scan_code, scan_code_prev: std_logic_vector(7 downto 0); 
	signal reset, game_tick, scan_ready: std_logic := '0';
	signal speed : std_logic_vector(1 downto 0) := (others => '0');
	signal fire : std_logic := '0';

    signal finished : std_logic := '0';

	-- Set the game_tick frequency to 30 Hz
	constant game_tick_period : time := 33 ms;
	-- Set the key pressing frequency to 60 char/sec
	constant key_press_period : time := 25 ms;
	constant SLOW_KEY: std_logic_vector(7 downto 0) := X"1E";
	constant MED_KEY: std_logic_vector(7 downto 0) := X"1F";
	constant FAST_KEY: std_logic_vector(7 downto 0) := X"20";
	constant FIRE_KEY: std_logic_vector(7 downto 0) := X"17";
	constant BREAK_CODE: std_logic_vector(7 downto 0) := X"F0";
	constant SLOW_SPEED:  std_logic_vector(1 downto 0) := "00";
	constant MED_SPEED:  std_logic_vector(1 downto 0) := "01";
	constant FAST_SPEED:  std_logic_vector(1 downto 0) := "10";

begin
    dut: keyboard_mapper
		port map(
			reset => reset, 
			scan_ready => scan_ready, 
			scan_code => scan_code, 
			scan_code_prev => scan_code_prev, 
			speed => speed,
			fire => fire
		);

    game_tick_process: process  is
    begin
        game_tick <= '0';
        wait for game_tick_period / 2;
        game_tick <= '1';
        wait for game_tick_period / 2;

        if finished = '1' then
            wait;
        end if;
    end process;


    scan_ready_process: process  is
    begin
        scan_ready <= '0';
        wait for key_press_period / 2;
        scan_ready <= '1';
        wait for key_press_period / 2;

        if finished = '1' then
            wait;
        end if;
    end process;

	test_process: process is
    begin

		assert false report "start of test" severity note;

		-- test 0: simulate reset
		reset <= '1';
		wait until (scan_ready = '0');
		wait until (scan_ready = '1');
		assert speed = SLOW_SPEED report "Test 0 failed from speed" severity error;
		assert fire = '0' report "Test 0 failed from fire" severity error;
		reset <= '0'; 
		wait until (scan_ready = '0');

		-- test 1: start by pressing and releasing fire key
		scan_code_prev <= X"00"; 
		scan_code <= FIRE_KEY; 
		wait for key_press_period;
		assert speed = SLOW_SPEED report "Test 1A failed from speed" severity error;
		assert fire = '1' report "Test 1A failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= FIRE_KEY; 
		wait for key_press_period;
		assert speed = SLOW_SPEED report "Test 1B failed from speed" severity error;
		assert fire = '0' report "Test 1B failed from fire" severity error;

		-- test 2: press and release med_speed key to change speed
		scan_code_prev <= X"AB"; -- don't care 
		scan_code <= MED_KEY; 
		wait for key_press_period;
		assert speed = MED_SPEED report "Test 2A failed from speed" severity error;
		assert fire = '0' report "Test 2A failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= MED_KEY; 
		wait for key_press_period;
		assert speed = MED_SPEED report "Test 2B failed from speed" severity error;
		assert fire = '0' report "Test 2B failed from fire" severity error;

		-- test 3: press and hold fire, press slow_speed key, release slow_speed key, release fire key
		scan_code_prev <= X"AB"; -- don't care
		scan_code <= FIRE_KEY; -- press fire
		wait for key_press_period;
		assert speed = MED_SPEED report "Test 3A failed from speed" severity error;
		assert fire = '1' report "Test 3A failed from fire" severity error;
		scan_code_prev <= FIRE_KEY; 
		scan_code <= SLOW_KEY; -- press slow_speed 
		wait for key_press_period;
		assert speed = SLOW_SPEED report "Test 3B failed from speed" severity error;
		assert fire = '0' report "Test 3B failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= SLOW_KEY; -- release slow_speed
		wait for key_press_period;
		assert speed = SLOW_SPEED report "Test 3C failed from speed" severity error;
		assert fire = '0' report "Test 3C failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= FIRE_KEY; -- release fire
		wait for key_press_period;
		assert speed = SLOW_SPEED report "Test 3D failed from speed" severity error;
		assert fire = '0' report "Test 3D failed from fire" severity error;

		-- test 4: press and hold fire, press high_speed key, release fire key, release high_speed key, 
		scan_code_prev <= X"AB"; -- don't care
		scan_code <= FIRE_KEY; -- press fire
		wait for key_press_period;
		assert speed = SLOW_SPEED report "Test 4A failed from speed" severity error;
		assert fire = '1' report "Test 4A failed from fire" severity error;
		scan_code_prev <= FIRE_KEY; 
		scan_code <= FAST_KEY; -- press fast 
		wait for key_press_period;
		assert speed = FAST_SPEED report "Test 4B failed from speed" severity error;
		assert fire = '0' report "Test 4B failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= FIRE_KEY; -- release fire
		wait for key_press_period;
		assert speed = FAST_SPEED report "Test 4C failed from speed" severity error;
		assert fire = '0' report "Test 4C failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= FAST_KEY; -- release fast
		wait for key_press_period;
		assert speed = FAST_SPEED report "Test 4D failed from speed" severity error;
		assert fire = '0' report "Test 4D failed from fire" severity error;

		-- test 5: press and hold med_speed, press FAST_speed key, release med_speed
		scan_code_prev <= X"AB"; -- don't care
		scan_code <= MED_KEY; -- press med
		wait for key_press_period;
		assert speed = MED_SPEED report "Test 5A failed from speed" severity error;
		assert fire = '0' report "Test 5A failed from fire" severity error;
		scan_code_prev <= FIRE_KEY; 
		scan_code <= FAST_KEY; -- press fast 
		wait for key_press_period;
		assert speed = FAST_SPEED report "Test 5B failed from speed" severity error;
		assert fire = '0' report "Test 5B failed from fire" severity error;
		scan_code_prev <= BREAK_CODE; 
		scan_code <= MED_KEY; -- release med (speed should still be fast)
		wait for key_press_period;
		assert speed = FAST_SPEED report "Test 5C failed from speed" severity error;
		assert fire = '0' report "Test 5C failed from fire" severity error;


        -- Display a message when simulation finished
        assert false report "end of test" severity note;

        -- Finish the simulation
        finished <= '1';
		wait; -- very important line don't delete this one
	end process test_process;

end architecture behavioral;