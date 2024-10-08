library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.bullet_tank_const.all;

entity top_level is
  port (
	clk_50Mhz, reset: in std_logic;
	keyboard_clk, keyboard_data: in std_logic;
	RESET_N									: in std_logic;
	LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED		: OUT	STD_LOGIC;
	LCD_RW						: BUFFER STD_LOGIC;
	DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
	segments_out_p1, segments_out_p2 : out std_logic_vector(6 downto 0);
	VGA_RED, VGA_GREEN, VGA_BLUE 					: out std_logic_vector(7 downto 0);
	HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK		: out std_logic
  );
end top_level ;

architecture structural of top_level is

	-- MODEL
	component score is
		generic(
			win_score : unsigned(2 downto 1)
		);
		port (
			p1_hit, p2_hit, reset, clk: in std_logic;
			p1_score, p2_score : out std_logic_vector(1 downto 0);
			p1_win, p2_win : out std_logic
		);
	end component score;

    component tank is
		generic(
			y_pos: std_logic_vector(9 downto 0);
			color: std_logic_vector(2 downto 0);
			tank_width: unsigned(9 downto 0);
			max_x: unsigned(9 downto 0);
			speed_shift: unsigned(3 downto 0)
		);
		port(
			speed: in std_logic_vector(1 downto 0);
			reset, game_pulse: in std_logic;
			lost_game: in std_logic;
			clk: in std_logic;
			x_pos_out, y_pos_out: out std_logic_vector(9 downto 0)
		);
	end component tank;

	component bullet is
		generic(
			color: std_logic_vector(2 downto 0);
			speed_magnitude: unsigned(9 downto 0);
			direction: std_logic;
			max_y_val : unsigned(9 downto 0)
		);
		port (
			initial_x_pos, initial_y_pos : in std_logic_vector(9 downto 0);
			reset, fire, game_pulse, is_collision, clk: in std_logic;
			game_over : in std_logic;
			x_pos_out, y_pos_out : out std_logic_vector(9 downto 0)
		);
	end component bullet;

	component collision_check is
        generic(
            obja_width: unsigned(9 downto 0);
            obja_height: unsigned(9 downto 0);
            objb_width: unsigned(9 downto 0);
            objb_height: unsigned(9 downto 0)
        );
        port(
            obja_x, obja_y, objb_x, objb_y: in std_logic_vector(9 downto 0);
            reset, clk: in std_logic;
            is_collision: out std_logic
        );
    end component collision_check;

	-- VIEW
	component char_buffer is
		port (
			p1_win, p2_win, reset, clk : in std_logic;
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

 	component vga_top_level is
		port(
			CLOCK_50 									: in std_logic;
			RESET_N										: in std_logic;
			VGA_RED, VGA_GREEN, VGA_BLUE 				: out std_logic_vector(7 downto 0);
			HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK	: out std_logic
			);
	end component vga_top_level;

	-- CONTROLLER
	component ps2 is
		port( 	keyboard_clk, keyboard_data, clock_50MHz ,
				reset : in std_logic;--,
				scan_code : out std_logic_vector( 7 downto 0 );
				scan_readyo : out std_logic;
				hist0 : out std_logic_vector(7 downto 0)
			);
	end component ps2;

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

	component pixelGenerator is
		port(
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0);
			test_address 									: out std_logic_vector(2 downto 0);
			tank1_x, tank1_y, tank2_x, tank2_y				: in std_logic_vector(9 downto 0);
			bullet1_x, bullet1_y, bullet2_x, bullet2_y 		: in std_logic_vector(9 downto 0)
		);
	end component pixelGenerator;

	component VGA_SYNC is
		port(
				clock_50Mhz						: in std_logic;
				horiz_sync_out, vert_sync_out,
				video_on, pixel_clock, eof		: out std_logic;
				pixel_row, pixel_column			: out std_logic_vector(9 downto 0)
			);
	end component VGA_SYNC;

	-- SYSTEM
	component clock_counter is
    	port (
			clock_100Mhz : IN STD_LOGIC;
          	pulse : OUT STD_LOGIC
		);
	end component clock_counter;

	component pll is
		port (
			areset		: IN STD_LOGIC  := '0';
			inclk0		: IN STD_LOGIC  := '0';
			c0			: OUT STD_LOGIC ;
			locked		: OUT STD_LOGIC 
		);
	end component pll;

	-- signals
	signal game_pulse, inv_reset, pll_100MHz_clk, locked				: std_logic;
	signal p1_win, p2_win												: std_logic;
	signal p1_score, p2_score 											: std_logic_vector(1 downto 0);
	signal char_buffer_80_chars 										: std_logic_vector(80 - 1 downto 0);
	signal data_in_p1 													: std_logic_vector(3 downto 0);
	signal data_in_p2 													: std_logic_vector(3 downto 0);
	signal p1_speed, p2_speed											: std_logic_vector(1 downto 0);
	signal x_pos_bullet1, y_pos_bullet1, x_pos_bullet2, y_pos_bullet2	: std_logic_vector(9 downto 0);
	signal initial_x_pos_bullet1, initial_x_pos_bullet2					: std_logic_vector(9 downto 0);
	signal x_pos_tank1, y_pos_tank1, x_pos_tank2, y_pos_tank2 			: std_logic_vector(9 downto 0);
	signal p1_fire, p2_fire 											: std_logic;
	signal is_collision_bullet1_tank2, is_collision_bullet2_tank1 		: std_logic;
    signal p1_scan_code, p1_scan_code_prev								: std_logic_vector(7 downto 0);
	signal scan_readyo													: std_logic;
	signal scan_code, hist0 											: std_logic_vector(7 downto 0);

	--Signals for VGA
	signal pixel_row_int 										: std_logic_vector(9 downto 0);
	signal pixel_column_int 									: std_logic_vector(9 downto 0);
	signal video_on_int											: std_logic;
	signal VGA_clk_int											: std_logic;
	signal eof													: std_logic;
	signal test_address											: std_logic_vector(2 downto 0);

begin

	data_in_p1 <= "00" & p1_score;
	data_in_p2 <= "00" & p2_score;
	inv_reset <= not reset;

	score_unit: score
		generic map(
			-- Value that player wins at
			win_score => "11" 
		)
		port map(
			p1_hit => is_collision_bullet2_tank1,
			p2_hit => is_collision_bullet1_tank2,
			reset => inv_reset,
			clk => pll_100MHz_clk,
			p1_score => p1_score,
			p2_score => p2_score,
			p1_win => p1_win,
			p2_win => p2_win
		);

    tank1: tank
        generic map(
			y_pos => std_logic_vector(to_unsigned(TANK1_Y, 10)),
			tank_width => to_unsigned(TANK_WIDTH, 10),
			max_x => to_unsigned(SCREEN_WIDTH, 10),
			speed_shift => to_unsigned(TANK_SPEED_SHIFT, 4),
			color => std_logic_vector(to_unsigned(1, 3))
        )
        port map(
            speed => p1_speed,
            reset => inv_reset,
            game_pulse => game_pulse,
            lost_game => p2_win,
            x_pos_out => x_pos_tank1,
            y_pos_out => y_pos_tank1,
			clk => pll_100MHz_clk
        );

	tank2: tank
		generic map(
			y_pos => std_logic_vector(to_unsigned(TANK2_Y, 10)),
			tank_width => to_unsigned(TANK_WIDTH, 10),
			max_x => to_unsigned(SCREEN_WIDTH, 10),
			speed_shift => to_unsigned(TANK_SPEED_SHIFT, 4),
			color => std_logic_vector(to_unsigned(2, 3))
		)
		port map(
            speed => p2_speed,
            reset => inv_reset,
            game_pulse => game_pulse,
            lost_game => p1_win,
            x_pos_out => x_pos_tank2,
            y_pos_out => y_pos_tank2,
			clk => pll_100MHz_clk
        );

	initial_x_pos_bullet1 <= std_logic_vector(unsigned(x_pos_tank1) + shift_right(to_unsigned(TANK_WIDTH, 10), 1));
    bullet1: bullet
        generic map(
            color => std_logic_vector(to_unsigned(1, 3)),
            speed_magnitude => to_unsigned(BULLET_SPEED, 10),
            direction => '0',
            max_y_val => to_unsigned(SCREEN_HEIGHT, 10)
        )
        port map(
            initial_x_pos => initial_x_pos_bullet1,
            initial_y_pos => y_pos_tank1,
            reset => inv_reset,
            fire => p1_fire,
            game_pulse => game_pulse,
            is_collision => is_collision_bullet1_tank2,
            game_over => p2_win,
            x_pos_out => x_pos_bullet1,
            y_pos_out => y_pos_bullet1,
			clk => pll_100MHz_clk
        );

	initial_x_pos_bullet2 <= std_logic_vector(unsigned(x_pos_tank2) + shift_right(to_unsigned(TANK_WIDTH, 10), 1));
	bullet2: bullet
        generic map(
            color => std_logic_vector(to_unsigned(1, 3)),
            speed_magnitude => to_unsigned(BULLET_SPEED, 10),
            direction => '1',
            max_y_val => to_unsigned(SCREEN_HEIGHT, 10)
        )
        port map(
            initial_x_pos => initial_x_pos_bullet2,
            initial_y_pos => y_pos_tank2,
            reset => inv_reset,
            fire => p2_fire,
            game_pulse => game_pulse,
            is_collision => is_collision_bullet2_tank1,
            game_over => p1_win,
            x_pos_out => x_pos_bullet2,
            y_pos_out => y_pos_bullet2,
			clk => pll_100MHz_clk
        );

	collision_check_tank1_bullet2: collision_check
		generic map(
			obja_width => to_unsigned(TANK_WIDTH, 10),
			obja_height => to_unsigned(TANK_HEIGHT, 10),
			objb_width => to_unsigned(BULLET_WIDTH, 10),
			objb_height => to_unsigned(BULLET_HEIGHT, 10)
		)
		port map(
			obja_x => x_pos_tank1,
			obja_y => y_pos_tank1,
			objb_x => x_pos_bullet2,
			objb_y => y_pos_bullet2,
			reset => inv_reset,
			clk => pll_100MHz_clk,
			is_collision => is_collision_bullet2_tank1
		);

	collision_check_tank2_bullet1: collision_check
		generic map(
			obja_width => to_unsigned(TANK_WIDTH, 10),
			obja_height => to_unsigned(TANK_HEIGHT, 10),
			objb_width => to_unsigned(BULLET_WIDTH, 10),
			objb_height => to_unsigned(BULLET_HEIGHT, 10)
		)
		port map(
			obja_x => x_pos_tank2,
			obja_y => y_pos_tank2,
			objb_x => x_pos_bullet1,
			objb_y => y_pos_bullet1,
			reset => inv_reset,
			clk => pll_100MHz_clk,
			is_collision => is_collision_bullet1_tank2
		);


	-- VIEW
	char_buffer_unit: char_buffer
		port map(
			p1_win => p1_win,
			p2_win => p2_win,
			reset => inv_reset,
			clk => pll_100MHz_clk,
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
			reset => reset,
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
	-- VGA
	videoGen : pixelGenerator
		port map(
			clk => clk_50Mhz,
			ROM_clk => VGA_clk_int,
			rst_n => RESET_N,
			video_on => video_on_int,
			eof => eof,
			pixel_row => pixel_row_int,
			pixel_column => pixel_column_int,
			red_out => VGA_RED,
			green_out => VGA_GREEN,
			blue_out => VGA_BLUE,
			test_address => test_address,
			tank1_x => x_pos_tank1,
			tank1_y => y_pos_tank1,
			tank2_x => x_pos_tank2,
			tank2_y	=> y_pos_tank2,
			bullet1_x => x_pos_bullet1,
			bullet1_y => y_pos_bullet1,
			bullet2_x => x_pos_bullet2,
			bullet2_y => y_pos_bullet2
		);

	video_sync : VGA_SYNC
		port map(
			clock_50Mhz => clk_50Mhz,
			horiz_sync_out => HORIZ_SYNC,
			vert_sync_out => VERT_SYNC,
			video_on => video_on_int,
			pixel_clock => VGA_clk_int,
			eof => eof,
			pixel_row => pixel_row_int,
			pixel_column => pixel_column_int
		);
	VGA_BLANK <= video_on_int;
	VGA_CLK <= VGA_clk_int;

	-- SYSTEM
	clock_counter_unit: clock_counter
		port map(
			clock_100MHz => pll_100MHz_clk,
			pulse => game_pulse
		);

	pll_unit: pll
		port map(
				areset	=> inv_reset,
				inclk0	=> clk_50Mhz,
				c0 =>  pll_100MHz_clk,
				locked => locked
		);

	-- CONTROLLER

	ps2_unit: ps2
		port map(
			keyboard_clk => keyboard_clk,
			keyboard_data => keyboard_data,
			clock_50MHz => clk_50Mhz,
			reset => reset,
			scan_code => scan_code,
			scan_readyo => scan_readyo,
			hist0 => hist0
		);

    kb_p1: keyboard_mapper
		generic map(
			SLOW_KEY => X"1C", -- a
			MED_KEY => X"1B", -- s
			FAST_KEY => X"23", -- d
			FIRE_KEY => X"1D", -- w
			BREAK_CODE => X"F0"
		)
		port map(
			reset => inv_reset,
			clk => clk_50Mhz,
			scan_ready => scan_readyo,
			scan_code => scan_code,
			scan_code_prev => hist0,
			speed => p1_speed,
			fire => p1_fire
		);
    kb_p2: keyboard_mapper
		generic map(
			SLOW_KEY => X"3B", -- j
			MED_KEY => X"42", -- k
			FAST_KEY => X"4B", -- l
			FIRE_KEY => X"43", -- i
			BREAK_CODE => X"F0"
		)
		port map(
			reset => inv_reset,
			clk => clk_50Mhz,
			scan_ready => scan_readyo,
			scan_code => scan_code,
			scan_code_prev => hist0,
			speed => p2_speed,
			fire => p2_fire
		);
end architecture;

-- ghdl -a --workdir=work -g -fexplicit -fsynopsys bullet_tank_const.vhd bullet.vhd tank.vhd char_buffer.vhd clock_counter.vhd collision_check.vhd colorROM.vhd pixelGenerator.vhd vga_sync.vhd de2lcd.vhd oneshot.vhd keyboard.vhd kb_mapper.vhd ps2.vhd leddcd.vhd score.vhd top_level.vhd
-- ghdl -a --workdir=work -g -fexplicit -fsynopsys bullet_tank_const.vhd bullet.vhd tank.vhd char_buffer.vhd clock_counter.vhd collision_check.vhd colorROM.vhd pixelGenerator.vhd vga_sync.vhd de2lcd.vhd oneshot.vhd keyboard.vhd kb_mapper.vhd ps2.vhd leddcd.vhd score.vhd top_level.vhd
