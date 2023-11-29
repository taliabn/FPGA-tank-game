library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_mapper is
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
end entity keyboard_mapper;

architecture behavior of keyboard_mapper is
	signal fire_comb, fire_o : std_logic;
	signal speed_prev : std_logic_vector(1 downto 0) := (others => '0');
	signal speed_next: std_logic_vector(1 downto 0) := (others => '0'); 
	type t_state is (held, previously_released);
	signal state, next_state: t_state;

begin

	-- I think this should be fine timing wise because keys will probably not be pressed faster than 32 Hz
	registered_process : process(clk, scan_ready, reset)
    begin
        if ( reset = '1' ) then
			-- on reset, assign speed to slow
            speed_prev <= SLOW_SPEED;
			fire_o <= '0';
			state <= previously_released;
	-- triggered when a key is pressed (scan_ready)
		elsif ( rising_edge(clk) ) then
			speed_prev <= speed_next;
			state <= next_state;
			fire_o <= fire_comb;
		end if;
	end process registered_process;

	-- This is a mealy machine so that outputs are immediately visible
	-- Moore machine would have 3 states
	combo_process : process(state, scan_code, scan_code_prev, speed_prev, scan_ready) is
	begin
		-- happens regardless of state
		if (scan_ready = '1') then
			if ( (scan_code = SLOW_KEY) and (scan_code_prev /= BREAK_CODE) ) then
				speed_next <= SLOW_SPEED;
			elsif ( (scan_code = MED_KEY) and (scan_code_prev /= BREAK_CODE) ) then
				speed_next <= MED_SPEED;
			elsif ( (scan_code = FAST_KEY) and (scan_code_prev /= BREAK_CODE ) ) then
				speed_next <= FAST_SPEED;
			-- idk why including this else case breaks things
			-- quartus doesn't synthesize a latch with it commented out though
			else
				speed_next <= speed_prev; -- hold
			end if;
		else 
			speed_next <= speed_prev; -- hold
		end if;

		-- assigns fire='1' only when fire key is initially pressed (edge triggered)
		fire_comb <= '0';
		next_state <= state;
		case (state) is
			-- fire key is being held down
			when held =>
				if (scan_ready = '1') then
					if ((scan_code = FIRE_KEY ) and (scan_code_prev = break_code)) then
						-- encountered break code
						next_state <= previously_released;
					else
						next_state <= held;
					end if;
				else
					next_state <= held;
				end if;
				fire_comb <= '0';
			-- fire key has been released (or never pressed)
			-- able to fire again
			when previously_released => 
				if (scan_ready = '1') then
					if ((scan_code = FIRE_KEY) and (scan_code_prev /= break_code)) then
						-- encountered make code, this is the only time fire can be 1
						fire_comb <= '1';
						next_state <= held;
					else
						next_state <= previously_released;
					end if;
				else
					next_state <= previously_released;
					fire_comb <= '0';
				end if;
			when others =>
				next_state <= previously_released;
				fire_comb <= '0';
		end case;
	end process combo_process;

	-- assign output ports from registered signals	
	speed <= speed_prev;
	fire <= fire_o;

end architecture behavior;
