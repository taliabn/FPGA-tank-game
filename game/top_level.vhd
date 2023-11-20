library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
  port (
	clk_50Mhz, reset, p1_hit, p2_hit: in std_logic;
	segments_out_p1, segments_out_p2 : out std_logic_vector(6 downto 0);
	LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED		: OUT	STD_LOGIC;
	LCD_RW						: BUFFER STD_LOGIC;
	DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end top_level ; 

architecture structural of top_level is

	-- MODEL 
	component score is
		port (
			p1_hit, p2_hit, reset, game_tick: in std_logic;
			p1_score, p2_score : out std_logic_vector(1 downto 0);
			p1_win, p2_win : out std_logic
		);
	end component score;

	-- VIEW
	component char_buffer is
		port (
			p1_win, p2_win, reset, game_tick : in std_logic;
			char_buffer_80_chars : out std_logic_vector(80 - 1 downto 0)
			);
			end component char_buffer ; 
				
	component leddcd is
		port(
			data_in : in std_logic_vector(3 downto 0);
			segments_out : out std_logic_vector(6 downto 0)
		   );
	end component leddcd;

	component de2lcd is 
		port (
			reset, clk_50Mhz				: IN	STD_LOGIC;
			CHAR_BUFFER : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
			LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED		: OUT	STD_LOGIC;
			LCD_RW						: BUFFER STD_LOGIC;
			DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
	end component de2lcd;

	-- system
	component clk30 is
    PORT (clock_50Mhz : IN STD_LOGIC;
          clock_30hz : OUT STD_LOGIC);
	end component clk30;

	-- signals
	signal game_tick, p1_win, p2_win, clock_30hz, lcd_reset: std_logic;
	signal p1_score, p2_score : std_logic_vector(1 downto 0);
	signal char_buffer_80_chars : std_logic_vector(80 - 1 downto 0);
	signal data_in_p1 : std_logic_vector(3 downto 0);
	signal data_in_p2 : std_logic_vector(3 downto 0);


begin

	data_in_p1 <= "00" & p1_score;
	data_in_p2 <= "00" & p2_score;
	-- de2lcd has active low reset, everything else is using active high
	lcd_reset <= not reset;

	score_unit: score 
		port map(
			p1_hit => p1_hit, 
			p2_hit => p2_hit, 
			reset => reset, 
			game_tick => clock_30hz,
			p1_score => p1_score, 
			p2_score => p2_score,
			p1_win => p1_win, 
			p2_win => p2_win
		);

	-- VIEW
	char_buffer_unit: char_buffer
		port map(
			p1_win => p1_win, 
			p2_win => p2_win,
			reset => reset, 
			game_tick => clock_30hz,
			char_buffer_80_chars => char_buffer_80_chars
		);
					
	leddcd_p1: leddcd
		port map(
			data_in => data_in_p1,
			segments_out => segments_out_p1
		   );
					
	leddcd_p2: leddcd
		port map(
			data_in => data_in_p2,
			segments_out => segments_out_p2
		   );

	de2lcd_unit: de2lcd 
		port map(
			reset => lcd_reset, 
			clk_50Mhz => clk_50Mhz,
			CHAR_BUFFER => char_buffer_80_chars,
			LCD_RS => LCD_RS,
			LCD_E => LCD_E, 
			LCD_ON => LCD_ON, 
			RESET_LED => RESET_LED, 
			SEC_LED => SEC_LED,
			LCD_RW => LCD_RW,
			DATA_BUS => DATA_BUS
		);

	clk30_unit: clk30
		port map(
			clock_50Mhz => clk_50Mhz,
			clock_30hz => clock_30hz 
		);

end architecture ;
--- objects have 0, 0 at top left
-- MODEL modules

-- tank (two instances)
-- inputs: 
	-- speed (unsigned, comes from keyboard): in std_logic_vector (1 downto 0), 
	-- reset, game_tick: in std_logic
-- generics: y_pos: std_logic_vector(9 downto 0), 
	-- color: std_logic_vector(2 downto 0)
	-- tank_width, tank_height: integer
-- outputs: x_pos, y_pos: out std_logic_vector(9 downto 0)
-- notes: will have two instances
	-- direction is implicitly tracked with FSM


-- bullet (two instances)
-- inputs: 
	-- intial_x_pos, intial_y_pos: in std_logic_vector(9 downto 0)
	-- reset, fire, game_tick, is_collision: in std_logic
-- generics: color: std_logic_vector(2 downto 0), 
			-- direction: std_logic;
			-- bullet_width, bullet_height: integer
-- outputs: x_pos, y_pos: out std_logic_vector(9 downto 0)
-- notes: will have two instances
	-- existence is implicitly tracked by setting positions to max vals (aka off screen)

-- bullet -> is vibing
-- reset (fuckoff screen)
	-- 
-- when fired
	-- model tells bullet to go to an xy (model knows that xy is the tank position)
-- when collision
	-- model tells bullet to fuckoff screen to an xy
-- normal
	-- bullet proceeds on its velocity


-- collision detection (two instances)
-- inputs:
	-- tank_x, tank_y, bullet_x, bullet_y: in std_logic_vector(9 downto 0)
	-- reset, game_tick: in std_logic
-- outputs: 
	-- is_collision: out std_logic
-- notes: 	
	-- only checks between one tank and one bullet	


-- score
-- inputs:
	-- pi_hit, p2_hit, reset, game_tick: in std_logic
-- outputs:
	-- p1_score, p2_score : out std_logic_vector(1 downto 0);
	-- p1_win, p2_win : out std_logic;


-- VIEW modules

-- rendering module (pixel generator/VGA ) (replacement for  pixelGenerator)
-- clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
-- pixel_row, pixel_column						    : in std_logic_vector(9 downto 0)
-- red_out, green_out, blue_out						: out std_logic_vector(7 downto 0)
-- tank1_x, tank1_y, tank2_x, tank2_y, bullet1_x, bullet1_y, bullet2_x, bullet2_y : in std_logic_vector(9 downto 0)
-- p1_win, p2_win : in std_logic;

-- companion vga_sync module (we don't need to write this)
-- companion colorROM module (can add more colors if needby but do not necessarily need to)

-- LCD module 
-- buffer_creation
-- inputs p1_win, p2_win				: in std_logic;
-- outputs : char_buffer_80_chars		: out std_logic_vector((80 * 8) - 1 downto 0);

-- LED module 
-- inputs
	-- data_in : in std_logic_vector(3 downto 0);
-- outputs
	-- segments_out : out std_logic_vector(6 downto 0);
-- notes:
	-- two instances, one for each player's score
	-- either resize score or modify leddcd to take 2-bit data_in

-- module for LCD display stuff
-- char_buffer_80_chars							: IN	STD_LOGIC_VECTOR((80 * 8) - 1 DOWNTO 0);
-- Transparent I/O
-- reset, clk_50Mhz								: IN	STD_LOGIC;
-- LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED		: OUT	STD_LOGIC;
-- LCD_RW										: BUFFER STD_LOGIC;
-- DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0)


-- CONTROLLER modules

-- reset: a push button

-- key board

-- actual key board

-- keyboard mapper
-- input: scan_code
-- outputs: p1_speed, p2_speed: std_logic_vector (1 downto 0)

-- CLOCK MODULES

-- PLL?

-- Clock counter
-- input: clk
-- output: game_tick


-- questions
	-- how to use PLL? (sys clock to our faster clock)
	-- is numerical score going to LCD or seven-segment LEDs?
	-- should we care about ties?