--- objects have 0, 0 at top left

-- MODEL modules

-- tank (two instances)
-- inputs: 
	-- speed (unsigned, comes from keyboard): in std_logic_vector (1 downto 0), 
	-- reset, game_tick: in std_logic
-- generics: y_pos: std_logic_vector(9 downto 0), 
	-- color: std_logic_vector(2 downto 0)
-- outputs: x_pos, y_pos: out std_logic_vector(9 downto 0)
-- notes: will have two instances
	-- direction is implicitly tracked with FSM


-- bullet (two instances)
-- inputs: 
	-- intial_x_pos, intial_y_pos: in std_logic_vector(9 downto 0)
	-- reset, fire, game_tick, is_collision: in std_logic
-- generics: color: std_logic_vector(2 downto 0), 
			-- direction: std_logic;
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
-- inputs : p1_score, p2_score	 		: in std_logic_vector(1 downto 0);
-- inputs p1_win, p2_win				: in std_logic;
-- outputs : char_buffer_80_chars		: out std_logic_vector((80 * 8) - 1 downto 0);

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



-- CLOCK MODULES

-- PLL?

-- Clock counter
-- input: clk
-- output: game_tick


-- questions
	-- how to use PLL? (sys clock to our faster clock)
