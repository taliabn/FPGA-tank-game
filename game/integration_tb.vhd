library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- use WORK.bullet.all;
-- use WORK.tank.all;

-- NOTE! DOES NOT USE THE ACTUAL CONSTANTS!

entity integration_tb is
end integration_tb;

architecture behavioral of integration_tb is
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
            -- If direction is 1, bullet will travel in the -y direction
            direction: std_logic;
            max_y_val : unsigned(9 downto 0)
        );
        port (
            initial_x_pos, initial_y_pos : in std_logic_vector(9 downto 0);
            reset, fire, game_pulse, is_collision : in std_logic;
            game_over : in std_logic;
            clk : in std_logic;
            x_pos_out, y_pos_out : out std_logic_vector(9 downto 0)
        );
    end component bullet;

    component collision_check is
        generic(
            -- width and height of the objects
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

	component score is
		port (
			p1_hit, p2_hit, reset, clk: in std_logic;
			p1_score, p2_score : out std_logic_vector(1 downto 0);
			p1_win, p2_win : out std_logic
		);
	end component score;

	component char_buffer is
		port (
			p1_win, p2_win, reset, clk : in std_logic;
			char_buffer_80_chars : out std_logic_vector(80 - 1 downto 0)
		);
	end component char_buffer; 

	signal TB_char_buffer_80_chars : std_logic_vector(80 - 1 downto 0) := (others => '0');

    constant bullet_height : unsigned(9 downto 0) := to_unsigned(10, 10);
    constant bullet_width : unsigned(9 downto 0) := to_unsigned(10, 10);

    signal TB_speed : std_logic_vector(1 downto 0) := "00";
    signal TB_reset, TB_game_pulse : std_logic := '0';
    -- signal TB_lost_game1 : std_logic := '0';
    -- signal TB_lost_game2 : std_logic := '0';

	signal TB_win1, TB_win2 : std_logic := '0';
	signal TB_score1, TB_score2 : std_logic_vector(1 downto 0) := "00";

    signal TB_tank1_x_pos_out, TB_tank1_y_pos_out : std_logic_vector(9 downto 0) := (others => '0');
    signal TB_tank2_x_pos_out, TB_tank2_y_pos_out : std_logic_vector(9 downto 0) := (others => '0');

    signal TB_fire1, TB_bullet1_collision : std_logic := '0';
    signal TB_fire2, TB_bullet2_collision : std_logic := '0';
    -- signal TB_game_over_bullet1 : std_logic := '0';
    -- signal TB_game_over_bullet2 : std_logic := '0';
    signal TB_bullet1_x_pos_out, TB_bullet1_y_pos_out : std_logic_vector(9 downto 0) := (others => '0');
    signal TB_bullet2_x_pos_out, TB_bullet2_y_pos_out : std_logic_vector(9 downto 0) := (others => '0');

    constant clk_period : time := 10 ns;

    signal clk : std_logic := '0';
    signal finished : std_logic := '0';

    begin
        dut_tank_a: tank
        generic map(
            -- Set y_pos to 1
            y_pos => std_logic_vector(to_unsigned(1, 10)),
            -- Set color to 1
            color => std_logic_vector(to_unsigned(1, 3)),
            -- Set tank_width to unsigned 40
            tank_width => to_unsigned(40, 10),
            -- Set max_x to unsigned 450 CHANGE THIS??
            max_x => to_unsigned(450, 10),
            -- Set speed_shift to unsigned 2
            speed_shift => to_unsigned(2, 4)
        )
        port map(
            speed => TB_speed,
            reset => TB_reset,
            game_pulse => TB_game_pulse,
            lost_game => TB_win2,
            clk => clk,
            x_pos_out => TB_tank1_x_pos_out,
            y_pos_out => TB_tank1_y_pos_out
        );

        dut_tank_b: tank
        generic map(
            -- Set y_pos to 1
            y_pos => std_logic_vector(to_unsigned(170, 10)),
            -- Set color to 1
            color => std_logic_vector(to_unsigned(1, 3)),
            -- Set tank_width to unsigned 40
            tank_width => to_unsigned(40, 10),
            -- Set max_x to unsigned 450 CHANGE THIS??
            max_x => to_unsigned(450, 10),
            -- Set speed_shift to unsigned 2
            speed_shift => to_unsigned(2, 4)
        )
        port map(
            speed => TB_speed,
            reset => TB_reset,
            game_pulse => TB_game_pulse,
            lost_game => TB_win1,
            clk => clk,
            x_pos_out => TB_tank2_x_pos_out,
            y_pos_out => TB_tank2_y_pos_out
        );

        dut_bullet_a: bullet
        generic map(
            color => std_logic_vector(to_unsigned(1, 3)),
            speed_magnitude => to_unsigned(10, 10),
            direction => '0',
            max_y_val => to_unsigned(200, 10)
        )
        port map(
            initial_x_pos => TB_tank1_x_pos_out,
            initial_y_pos => TB_tank1_y_pos_out,
            reset => TB_reset,
            fire => TB_fire1,
            game_pulse => TB_game_pulse,
            is_collision => TB_bullet1_collision,
            game_over => TB_win2,
            clk => clk,
            x_pos_out => TB_bullet1_x_pos_out,
            y_pos_out => TB_bullet1_y_pos_out
        );

        dut_bullet_b: bullet
        generic map(
            color => std_logic_vector(to_unsigned(1, 3)),
            speed_magnitude => to_unsigned(10, 10),
            direction => '1',
            max_y_val => to_unsigned(200, 10)
        )
        port map(
            initial_x_pos => TB_tank2_x_pos_out,
            initial_y_pos => TB_tank2_y_pos_out,
            reset => TB_reset,
            fire => TB_fire2,
            game_pulse => TB_game_pulse,
            is_collision => TB_bullet2_collision,
            game_over => TB_win1,
            clk => clk,
            x_pos_out => TB_bullet2_x_pos_out,
            y_pos_out => TB_bullet2_y_pos_out
        );

        dut_collision_check_tank_2_bullet1: collision_check
        generic map(
            obja_width => to_unsigned(40, 10),
            obja_height => to_unsigned(40, 10),
            objb_width  =>   bullet_width,
            objb_height =>  bullet_height
        )
        port map(
            obja_x => TB_tank2_x_pos_out,
            obja_y => TB_tank2_y_pos_out,
            objb_x => TB_bullet1_x_pos_out,
            objb_y => TB_bullet1_y_pos_out,
            reset => TB_reset,
            clk => clk,
            is_collision => TB_bullet1_collision
        );

        dut_collision_check_tank_1_bullet2: collision_check
        generic map(
            obja_width => to_unsigned(40, 10),
            obja_height => to_unsigned(40, 10),
            objb_width  =>   bullet_width,
            objb_height =>  bullet_height
        )
        port map(
            obja_x => TB_tank1_x_pos_out,
            obja_y => TB_tank1_y_pos_out,
            objb_x => TB_bullet2_x_pos_out,
            objb_y => TB_bullet2_y_pos_out,
            reset => TB_reset,
            clk => clk,
            is_collision => TB_bullet2_collision
        );

		dut_score: score
		port map(
			p1_hit => TB_bullet2_collision, 
			p2_hit => TB_bullet1_collision, 
			reset => TB_reset, 
			clk => clk,
			p1_score => TB_score1, 
			p2_score => TB_score2,
			p1_win => TB_win1, 
			p2_win => TB_win2
		);

		dut: char_buffer
		port map(
			p1_win => TB_win1, 
			p2_win => TB_win2,
			reset => TB_reset, 
			clk => clk,
			char_buffer_80_chars => TB_char_buffer_80_chars
		);

        process is
            begin
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;

            if finished = '1' then
                wait;
            end if;
        end process;

        -- Main TestBench process
        process is
        begin
            assert false report "Start of TestBench" severity note;
			-- TB_win1 <= '0';
			-- TB_win2 <= '0';
            -- Set every single input to 0
            TB_speed <= "00";
            TB_reset <= '0';
            TB_game_pulse <= '0';
            -- TB_lost_game1 <= '0';
            -- TB_lost_game2 <= '0';
            TB_fire1 <= '0';
            TB_fire2 <= '0';
            -- TB_game_over_bullet1 <= '0';
            -- TB_game_over_bullet2 <= '0';
            finished <= '0';

            -- Reset
            TB_reset <= '1';
            wait for clk_period;
            TB_reset <= '0';
            wait for clk_period;

            -- finished <= '1'; wait;
            -- print the game win signals
            -- report "p1_hit: " & std_logic'image(TB_bullet2_collision) & " p2_hit: " & std_logic'image(TB_bullet1_collision) severity note;
            -- report "Win1: " & std_logic'image(TB_win1) & " Win2: " & std_logic'image(TB_win2) severity note;
            -- report "TB_score1: " & integer'image(to_integer(unsigned(TB_score1))) & " TB_score2: " & integer'image(to_integer(unsigned(TB_score2))) severity note;
            -- Verify that the positions are as expected
            -- tank1 at (40, 1), tank2 at (40, 170), bullet1 at (1000, 1000), bullet2 at (1000, 1000)

            -- report "Tank1X: " & integer'image(to_integer(unsigned(TB_tank1_x_pos_out))) & " Tank1Y: " & integer'image(to_integer(unsigned(TB_tank1_y_pos_out))) severity note;
            -- report "Tank2X: " & integer'image(to_integer(unsigned(TB_tank2_x_pos_out))) & " Tank2Y: " & integer'image(to_integer(unsigned(TB_tank2_y_pos_out))) severity note;
            -- report "Bullet1X: " & integer'image(to_integer(unsigned(TB_bullet1_x_pos_out))) & " Bullet1Y: " & integer'image(to_integer(unsigned(TB_bullet1_y_pos_out))) severity note;
            -- report "Bullet2X: " & integer'image(to_integer(unsigned(TB_bullet2_x_pos_out))) & " Bullet2Y: " & integer'image(to_integer(unsigned(TB_bullet2_y_pos_out))) severity note;

            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 Y position error" severity error;
			-- verify that score module outputs are all 0
			assert TB_win1 = '0' report "Win1 error";
			assert TB_win2 = '0' report "Win2 error";
            assert TB_score1 = std_logic_vector(to_unsigned(0, 2)) report "Score1 error" severity error;
            assert TB_score2 = std_logic_vector(to_unsigned(0, 2)) report "Score2 error" severity error;
			-- verify that lcd screen would be blank
			assert TB_char_buffer_80_chars = X"20202020202020202020" report "char buffer error" severity error;


            -- Fire bullet 1
            TB_fire1 <= '1';
            TB_game_pulse <= '1';
            wait for clk_period;
            TB_game_pulse <= '0';
            wait for clk_period;

            TB_fire1 <= '0';
            TB_game_pulse <= '1';
            wait for clk_period;
            TB_game_pulse <= '0';
            wait for clk_period;



            -- Verify that the positions are as expected (bullet has moved 10 pixels)
            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(11, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 Y position error" severity error;

            -- Check no collision
            assert TB_bullet1_collision = '0' report "Bullet1 collision error" severity error;
            assert TB_bullet2_collision = '0' report "Bullet2 collision error" severity error;
			assert TB_score1 = std_logic_vector(to_unsigned(0, 2)) report "Score1 error" severity error;
            assert TB_score2 = std_logic_vector(to_unsigned(0, 2)) report "Score2 error" severity error;

            -- Perform 10 more clock periods, ST the bullet should have moved 100 pixels
            for i in 1 to 10 loop
                TB_game_pulse <= '1';
                wait for clk_period;
                TB_game_pulse <= '0';
                wait for clk_period;
            end loop;

            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(111, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 Y position error" severity error;

            -- Check no collision
            assert TB_bullet1_collision = '0' report "Bullet1 collision error" severity error;
            assert TB_bullet2_collision = '0' report "Bullet2 collision error" severity error;
			assert TB_score1 = std_logic_vector(to_unsigned(0, 2)) report "Score1 error" severity error;
            assert TB_score2 = std_logic_vector(to_unsigned(0, 2)) report "Score2 error" severity error;

            -- Collision will occur when the bullet is at 170-bullet_height = 160
            -- Bullet will be at 161 at time of collision, so simulate 5 more clock periods (50 pixels)
            for i in 1 to 5 loop
                TB_game_pulse <= '1';
                wait for clk_period;
                TB_game_pulse <= '0';
                wait for clk_period;
            end loop;

            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(161, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 Y position error" severity error;

            -- Check collision
            assert TB_bullet1_collision = '1' report "Bullet1 collision error" severity error;
            assert TB_bullet2_collision = '0' report "Bullet2 collision error" severity error;
			wait for clk_period;
			assert TB_score1 = std_logic_vector(to_unsigned(1, 2)) report "Score1 error" severity error;
            assert TB_score2 = std_logic_vector(to_unsigned(0, 2)) report "Score2 error" severity error;

            -- Tick 1 more clock period, the bullet should move off the screen
            TB_game_pulse <= '1';
            wait for clk_period;
            TB_game_pulse <= '0';
            wait for clk_period;

            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 Y position error" severity error;
			-- check that neither score increased and that no one won yet
			assert TB_score1 = std_logic_vector(to_unsigned(1, 2)) report "Score1 error" severity error;
			assert TB_score2 = std_logic_vector(to_unsigned(0, 2)) report "Score2 error" severity error;
			assert TB_win1 = '0' report "Win1 error";
			assert TB_win2 = '0' report "Win2 error";

            -- Fire a bullet from tank 2
            TB_fire2 <= '1';
            TB_game_pulse <= '1';
            wait for clk_period;
            TB_game_pulse <= '0';
            wait for clk_period;

            TB_fire2 <= '0';

            -- Bullet should be at (40, 170)
            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Bullet2 Y position error" severity error;

            -- Check no collision
            assert TB_bullet1_collision = '0' report "Bullet1 collision error" severity error;
            assert TB_bullet2_collision = '0' report "Bullet2 collision error" severity error;
			-- check that neither score increased
			assert TB_score1 = std_logic_vector(to_unsigned(1, 2)) report "Score1 error" severity error;
			assert TB_score2 = std_logic_vector(to_unsigned(0, 2)) report "Score2 error" severity error;

            -- Collision will occur at 40 (top of tank 1)
            -- Bullet will be at 40 at time of collision, so simulate 13 more clock periods (130 pixels)
            for i in 1 to 13 loop
                TB_game_pulse <= '1';
                wait for clk_period;
                TB_game_pulse <= '0';
                wait for clk_period;
            end loop;

            -- Bullet should be at (40, 40)
            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Bullet2 Y position error" severity error;

            -- Check collision
            assert TB_bullet1_collision = '0' report "Bullet1 collision error" severity error;
            assert TB_bullet2_collision = '1' report "Bullet2 collision error" severity error;
			-- player 2 should have scored a point
			wait for clk_period;
			assert TB_score1 = std_logic_vector(to_unsigned(1, 2)) report "Score1 error" severity error;
			assert TB_score2 = std_logic_vector(to_unsigned(1, 2)) report "Score2 error" severity error;

            -- Tick 1 more clock period, the bullet should move off the screen
            TB_game_pulse <= '1';
            wait for clk_period;
            TB_game_pulse <= '0';
            wait for clk_period;

			-- scores shouldn't change, no one has won yet
			assert TB_score1 = std_logic_vector(to_unsigned(1, 2)) report "Score1 error" severity error;
			assert TB_score2 = std_logic_vector(to_unsigned(1, 2)) report "Score2 error" severity error;
			assert TB_win1 = '0' report "Win1 error";
			assert TB_win2 = '0' report "Win2 error";

            -- Bullet should be at (1000, 1000)
            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 Y position error" severity error;

            -- report "Tank1X: " & integer'image(to_integer(unsigned(TB_tank1_x_pos_out))) & " Tank1Y: " & integer'image(to_integer(unsigned(TB_tank1_y_pos_out))) severity note;
            -- report "Tank2X: " & integer'image(to_integer(unsigned(TB_tank2_x_pos_out))) & " Tank2Y: " & integer'image(to_integer(unsigned(TB_tank2_y_pos_out))) severity note;
            -- report "Bullet1X: " & integer'image(to_integer(unsigned(TB_bullet1_x_pos_out))) & " Bullet1Y: " & integer'image(to_integer(unsigned(TB_bullet1_y_pos_out))) severity note;
            -- report "Bullet2X: " & integer'image(to_integer(unsigned(TB_bullet2_x_pos_out))) & " Bullet2Y: " & integer'image(to_integer(unsigned(TB_bullet2_y_pos_out))) severity note;

            -- Fire a bullet from tank 1
            TB_fire1 <= '1';
            TB_game_pulse <= '1';
            wait for clk_period;
            TB_game_pulse <= '0';
            wait for clk_period;

            TB_fire1 <= '0';

            -- Go through 20 clock periods
            for i in 1 to 20 loop
                TB_game_pulse <= '1';
                wait for clk_period;
                TB_game_pulse <= '0';
                wait for clk_period;
            end loop;

            -- Bullet should have hit tank2

            -- Verify score
            assert TB_score1 = std_logic_vector(to_unsigned(2, 2)) report "Score1 error" severity error;
            assert TB_score2 = std_logic_vector(to_unsigned(1, 2)) report "Score2 error" severity error;
			assert TB_win1 = '0' report "Win1 error";
			assert TB_win2 = '0' report "Win2 error";

            -- Fire another bullet from tank 1
            TB_fire1 <= '1';
            TB_game_pulse <= '1';
            wait for clk_period;
            TB_game_pulse <= '0';
            wait for clk_period;

            TB_fire1 <= '0';

            -- Go through 20 clock periods
            for i in 1 to 20 loop
                TB_game_pulse <= '1';
                wait for clk_period;
                TB_game_pulse <= '0';
                wait for clk_period;
            end loop;
            
             -- Verify score
            assert TB_score1 = std_logic_vector(to_unsigned(3, 2)) report "Score1 error" severity error;
            assert TB_score2 = std_logic_vector(to_unsigned(1, 2)) report "Score2 error" severity error;
			assert TB_win1 = '1' report "Win1 error";
			assert TB_win2 = '0' report "Win2 error";
			-- Verify that LCD message is "P1 wins!"
			assert TB_char_buffer_80_chars = X"50312077696e73212020" report "Char buffer error" severity error;
            -- Tank 2 should have left the screen
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            
            -- Try to fire a bullet from tank 2
            TB_fire2 <= '1';
            TB_game_pulse <= '1';
            wait for clk_period;
            TB_game_pulse <= '0';
            wait for clk_period;
            TB_fire2 <= '0';

            -- Loop through 1000 clock periods
            for i in 1 to 1000 loop
                TB_game_pulse <= '1';
                wait for clk_period;
                TB_game_pulse <= '0';
                wait for clk_period;
            end loop;

            -- Verify score
            assert TB_score1 = std_logic_vector(to_unsigned(3, 2)) report "Score1 error" severity error;
            assert TB_score2 = std_logic_vector(to_unsigned(1, 2)) report "Score2 error" severity error;
            assert TB_win1 = '1' report "Win1 error";
            assert TB_win2 = '0' report "Win2 error";
			-- Verify that LCD message is "P1 wins!"
			assert TB_char_buffer_80_chars = X"50312077696e73212020" report "Char buffer error" severity error;

            -- Reset reset reset
            TB_reset <= '1';
            wait for clk_period;
            TB_reset <= '0';
            wait for clk_period;
                
            -- Verify that the positions are as expected
            -- tank1 at (40, 1), tank2 at (40, 170), bullet1 at (1000, 1000), bullet2 at (1000, 1000)
            assert TB_tank1_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank1 X position error" severity error;
            assert TB_tank1_y_pos_out = std_logic_vector(to_unsigned(1, 10)) report "Tank1 Y position error" severity error;
            assert TB_tank2_x_pos_out = std_logic_vector(to_unsigned(40, 10)) report "Tank2 X position error" severity error;
            assert TB_tank2_y_pos_out = std_logic_vector(to_unsigned(170, 10)) report "Tank2 Y position error" severity error;
            assert TB_bullet1_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 X position error" severity error;
            assert TB_bullet1_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet1 Y position error" severity error;
            assert TB_bullet2_x_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 X position error" severity error;
            assert TB_bullet2_y_pos_out = std_logic_vector(to_unsigned(1000, 10)) report "Bullet2 Y position error" severity error;
                    
            -- report "Tank1X: " & integer'image(to_integer(unsigned(TB_tank1_x_pos_out))) & " Tank1Y: " & integer'image(to_integer(unsigned(TB_tank1_y_pos_out))) severity note;
            -- report "Tank2X: " & integer'image(to_integer(unsigned(TB_tank2_x_pos_out))) & " Tank2Y: " & integer'image(to_integer(unsigned(TB_tank2_y_pos_out))) severity note;
            -- report "Bullet1X: " & integer'image(to_integer(unsigned(TB_bullet1_x_pos_out))) & " Bullet1Y: " & integer'image(to_integer(unsigned(TB_bullet1_y_pos_out))) severity note;
            -- report "Bullet2X: " & integer'image(to_integer(unsigned(TB_bullet2_x_pos_out))) & " Bullet2Y: " & integer'image(to_integer(unsigned(TB_bullet2_y_pos_out))) severity note;

            -- Check score is 0
            assert TB_score1 = std_logic_vector(to_unsigned(0, 2)) report "Score1 error" severity error;
            assert TB_score2 = std_logic_vector(to_unsigned(0, 2)) report "Score2 error" severity error;
            assert TB_win1 = '0' report "Win1 error";
            assert TB_win2 = '0' report "Win2 error";

            -- Check no collision
            assert TB_bullet1_collision = '0' report "Bullet1 collision error" severity error;
            assert TB_bullet2_collision = '0' report "Bullet2 collision error" severity error;

			-- verify that lcd screen was cleared
			assert TB_char_buffer_80_chars = X"20202020202020202020" report "char buffer error" severity error;

            finished <= '1';
            assert false report "If no assertions failed, tests successful! Ending" severity note;
            report "End of TestBench: Modules passed are tank, bullet, collision_check, score, and char buffer" severity note;
            wait;
        end process;

end architecture behavioral;

-- ghdl -a --workdir=work -g -fsynopsys char_buffer.vhd score.vhd bullet.vhd tank.vhd collision_check.vhd integration_tb.vhd
-- ghdl --elab-run -g --workdir=work -fsynopsys integration_tb

-- ghdl -a --workdir=work -g -fsynopsys char_buffer.vhd score.vhd bullet.vhd tank.vhd collision_check.vhd integration_tb.vhd; ghdl --elab-run -g --workdir=work -fsynopsys integration_tb

