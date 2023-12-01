library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.bullet_tank_const.all;

entity pixelGenerator is
	port(
		clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
		pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
		red_out, green_out, blue_out					: out std_logic_vector(7 downto 0);
		test_address 									: out std_logic_vector(2 downto 0);
		tank1_x, tank1_y, tank2_x, tank2_y				: in std_logic_vector(9 downto 0);
		bullet1_x, bullet1_y, bullet2_x, bullet2_y 		: in std_logic_vector(9 downto 0)
	);
end entity pixelGenerator;

architecture behavioral of pixelGenerator is

	constant color_dk_red 	: std_logic_vector(2 downto 0) := "000";
	constant color_dk_blue 	: std_logic_vector(2 downto 0) := "001";
	constant color_lt_red	: std_logic_vector(2 downto 0) := "010";
	constant color_lt_blue 	: std_logic_vector(2 downto 0) := "011";
	constant color_black 	: std_logic_vector(2 downto 0) := "110";
	constant color_white	: std_logic_vector(2 downto 0) := "111";

	constant color_tank1 	: std_logic_vector(2 downto 0) := color_dk_red;
	constant color_tank2    : std_logic_vector(2 downto 0) := color_dk_blue;
	constant color_bullet1  : std_logic_vector(2 downto 0) := color_lt_red;
	constant color_bullet2  : std_logic_vector(2 downto 0) := color_lt_blue;
	constant color_bg 		: std_logic_vector(2 downto 0) := color_black;
	
	component colorROM is
		port(
			address		: in std_logic_vector (2 downto 0);
			clock		: in std_logic  := '1';
			q			: out std_logic_vector (23 downto 0)
		);
	end component colorROM;

	signal colorAddress : std_logic_vector (2 downto 0);
	signal color        : std_logic_vector (23 downto 0);
	signal pixel_row_int, pixel_col_int : natural;
	signal tank1_x_int, tank1_y_int, tank2_x_int, tank2_y_int : natural;
	signal bullet1_x_int, bullet1_y_int, bullet2_x_int,bullet2_y_int : natural;

begin

--------------------------------------------------------------------------------------------
	red_out <= color(23 downto 16);
	green_out <= color(15 downto 8);
	blue_out <= color(7 downto 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_col_int <= to_integer(unsigned(pixel_column));
	tank1_x_int <= to_integer(unsigned(tank1_x));
	tank2_x_int <= to_integer(unsigned(tank2_x));
	bullet1_x_int <= to_integer(unsigned(bullet1_x));
	bullet1_y_int <= to_integer(unsigned(bullet1_y));
	bullet2_x_int <= to_integer(unsigned(bullet2_x));
	bullet2_y_int <= to_integer(unsigned(bullet2_y));
	
--------------------------------------------------------------------------------------------	
	
	colors : colorROM
		port map(colorAddress, ROM_clk, color);

--------------------------------------------------------------------------------------------	

	pixelDraw : process(clk, rst_n) is
	
	begin
		
		-- if pixel is in bounding box of a game object, draw it the appropriate color, otherwise draw it background color
		if (rising_edge(clk)) then

			-- upper left corner is 0, 0
			-- if row above tank height and col in tank 1
			if ((pixel_row_int < TANK_HEIGHT) and 
				(pixel_col_int >= tank1_x_int) and 
				(pixel_col_int < tank1_x_int + TANK_WIDTH)
			) then
				colorAddress <= color_tank1;
			-- else if row below (screen height - tank height) and col in tank 2
			elsif ((pixel_row_int >= SCREEN_HEIGHT - TANK_HEIGHT) and
				  (pixel_col_int >= tank2_x_int) and 
				  (pixel_col_int < tank2_x_int + TANK_WIDTH)
			) then
				colorAddress <= color_tank2;
			-- else if in bullet 1
			elsif ((pixel_row_int >= bullet1_y_int) and 
				   (pixel_row_int < bullet1_y_int + BULLET_HEIGHT) and
				   (pixel_col_int >= bullet1_x_int) and 
				   (pixel_col_int < bullet1_x_int + BULLET_WIDTH)
			) then
				colorAddress <= color_bullet1;
			-- else if in bullet 2
			elsif ((pixel_row_int >= bullet2_y_int) and 
				   (pixel_row_int < bullet2_y_int + BULLET_HEIGHT) and
				   (pixel_col_int >= bullet2_x_int) and 
				   (pixel_col_int < bullet2_x_int + BULLET_WIDTH)
			) then
				colorAddress <= color_bullet2;
			-- else background color
			else
				colorAddress <= color_bg;			
			end if;
			
		end if;
		
	end process pixelDraw;	

	test_address <= colorAddress;

--------------------------------------------------------------------------------------------
	
end architecture behavioral;	
	