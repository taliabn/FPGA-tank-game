library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ghdl -a --workdir=work -g -fsynopsys colorROM.vhd pixelGenerator.vhd pixelGenerator_tb.vhd 
-- ghdl --elab-run -g --workdir=work -fsynopsys pixelGenerator_tb

entity pixelGenerator_tb is
end entity pixelGenerator_tb ;

architecture behavioral of pixelGenerator_tb is
	-- component declaration for the unit under test
	component pixelGenerator is
		generic(
			SCREEN_WIDTH	: natural := 640;
			SCREEN_HEIGHT	: natural := 480;
			TANK_HEIGHT		: natural := 40;
			TANK_WIDTH		: natural := 60;
			BULLET_HEIGHT	: natural := 25;
			BULLET_WIDTH	: natural := 10
		);
		port(
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0);
			test_address : out std_logic_vector(2 downto 0);
			tank1_x, tank1_y, tank2_x, tank2_y				: in std_logic_vector(9 downto 0);
			bullet1_x, bullet1_y, bullet2_x, bullet2_y 		: in std_logic_vector(9 downto 0)
		);
	end component pixelGenerator;

	-- signals go here
	signal clk, ROM_clk, rst_n, eof 					: std_logic := '0';
	signal video_on										: std_logic := '1';
	signal pixel_row, pixel_col						    : std_logic_vector(9 downto 0) := (others => '0');
	signal red_out, green_out, blue_out					: std_logic_vector(7 downto 0) := (others => '0');
	signal tank1_x, tank1_y, tank2_x, tank2_y			: std_logic_vector(9 downto 0) := (others => '0');
	signal bullet1_x, bullet1_y, bullet2_x, bullet2_y 	: std_logic_vector(9 downto 0) := (others => '0');
	-- signal color									 	: std_logic_vector(23 downto 0) := (others => '0');
	signal colorAddress :  std_logic_vector(2 downto 0)  := (others => '0');
	signal tmp_natural 									: natural := 0;
    signal finished : std_logic := '0';

	-- Set the clock period to 100 ps
	constant clk_period : time := 100 ps;
	-- Set the ROM clock period to 50 ps (not sure what it is on the board)
	constant ROM_clk_period : time := 50 ps;

	constant color_tank1 	: std_logic_vector(2 downto 0) := "000"; -- red
	constant color_bullet2	: std_logic_vector(2 downto 0) := "001"; -- green
	constant color_tank2 	: std_logic_vector(2 downto 0) := "010"; -- blue
	constant color_bullet1	: std_logic_vector(2 downto 0) := "011"; -- yellow
	constant color_bg		: std_logic_vector(2 downto 0) := "111"; -- white
	
	constant SCREEN_WIDTH	: natural := 640;
	constant SCREEN_HEIGHT	: natural := 480;
	constant TANK_HEIGHT	: natural := 40;
	constant TANK_WIDTH		: natural := 60;
	constant BULLET_HEIGHT	: natural := 25;
	constant BULLET_WIDTH	: natural := 10;

begin
    dut: pixelGenerator
		generic map(
			SCREEN_WIDTH => SCREEN_WIDTH,
			SCREEN_HEIGHT => SCREEN_HEIGHT,
			TANK_HEIGHT => TANK_HEIGHT,
			TANK_WIDTH => TANK_WIDTH,
			BULLET_HEIGHT => BULLET_HEIGHT,
			BULLET_WIDTH => BULLET_WIDTH
		)
		port map(
			clk => clk, 
			ROM_clk => ROM_clk, 
			rst_n => rst_n, 
			video_on => video_on, 
			eof => eof, 				
			pixel_row => pixel_row, 
			pixel_column => pixel_col,
			red_out => red_out, 
			green_out => green_out, 
			blue_out => blue_out,	
			test_address => colorAddress,		 		
			tank1_x => tank1_x, 
			tank1_y => tank1_y, 
			tank2_x => tank2_x, 
			tank2_y => tank2_y,			 
			bullet1_x => bullet1_x, 
			bullet1_y => bullet1_y, 
			bullet2_x => bullet2_x, 
			bullet2_y => bullet2_y
		);

	-- color <= red_out & green_out & blue_out;

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

    ROM_clk_process: process  is
    begin
        ROM_clk <= '0';
        wait for ROM_clk_period / 2;
        ROM_clk <= '1';
        wait for ROM_clk_period / 2;

        if finished = '1' then
            wait;
        end if;
    end process;


	-- set tank y positions, these will never change
	tank1_y <= (others => '0');
	tmp_natural <= SCREEN_HEIGHT - TANK_HEIGHT;
	tank2_y <= std_logic_vector(to_unsigned(tmp_natural, 10));

	test_process: process is
    begin

		assert false report "start of test" severity note;

		-- simulate reset
		rst_n <= '1';
		wait until (clk = '0');
		wait until (clk = '1');
		rst_n <= '0'; 
		wait until (clk = '0');

		-- test 0: bullet2 off screen,
		bullet1_x <= std_logic_vector(to_unsigned(10, 10));
		bullet1_y <= std_logic_vector(to_unsigned(100, 10)); 
		bullet2_x <= (others => '1'); 
		bullet2_y <= (others => '1'); 

		tank1_x <= (others => '0');
		tank2_x <= std_logic_vector(to_unsigned(50, 10));
		
		-- (0,0)
		pixel_col <= std_logic_vector(to_unsigned(0, 10));
		pixel_row <= std_logic_vector(to_unsigned(0, 10));
		wait for clk_period;
		assert colorAddress = color_tank1 report "Test 0A failed" severity error;
		-- (0,tank width)
		pixel_col <= std_logic_vector(to_unsigned(0, 10));
		pixel_row <= std_logic_vector(to_unsigned(TANK_WIDTH, 10));
		wait for clk_period;
		assert colorAddress = color_bg report "Test 0B failed" severity error;
		-- (11, 101)
		pixel_col <= std_logic_vector(to_unsigned(11, 10));
		pixel_row <= std_logic_vector(to_unsigned(101, 10));
		wait for clk_period;
		assert colorAddress = color_bullet1 report "Test 0C failed" severity error;
		-- (10, 100)
		pixel_col <= std_logic_vector(to_unsigned(10, 10));
		pixel_row <= std_logic_vector(to_unsigned(100, 10));
		wait for clk_period;
		assert colorAddress = color_bullet1 report "Test 0D failed" severity error;
		-- (20, 125)
		pixel_col <= std_logic_vector(to_unsigned(20, 10));
		pixel_row <= std_logic_vector(to_unsigned(125, 10));
		wait for clk_period;
		assert colorAddress = color_bg report "Test 0E failed" severity error;
		-- tank2
		pixel_col <= tank2_x;
		pixel_row <= tank2_y;
		wait for clk_period;
		assert colorAddress = color_tank2 report "Test 0F failed" severity error;
		-- (109, 479)
		pixel_col <= std_logic_vector(to_unsigned(109, 10));
		pixel_row <= std_logic_vector(to_unsigned(479, 10));
		wait for clk_period;
		assert colorAddress = color_tank2 report "Test 0G failed" severity error;

        -- Display a message when simulation finished
        assert false report "end of test" severity note;

        -- Finish the simulation
        finished <= '1';
		wait; -- very important line don't delete this one
	end process test_process;

end architecture behavioral;