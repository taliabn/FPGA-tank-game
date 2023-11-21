library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- use WORK.bullet.all;
-- use WORK.tank.all;

entity bullet_tank_tb is
end bullet_tank_tb;

architecture behavioral of bullet_tank_tb is
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
            reset, game_tick: in std_logic;
            lost_game: in std_logic;
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
            reset, fire, game_tick, is_collision : in std_logic;
            game_over : in std_logic;
            x_pos_out, y_pos_out : out std_logic_vector(9 downto 0)
        );
    end component bullet;

    signal TB_speed : std_logic_vector(1 downto 0) := "00";
    signal TB_reset, TB_game_tick : std_logic := '0';
    signal TB_lost_game : std_logic := '0';
    signal TB_tank_x_pos_out, TB_tank_y_pos_out : std_logic_vector(9 downto 0) := (others => '0');

    signal TB_fire_bullet, TB_is_collision_bullet : std_logic := '0';
    signal TB_game_over_bullet : std_logic := '0';
    signal TB_bullet_x_pos_out, TB_bullet_y_pos_out : std_logic_vector(9 downto 0) := (others => '0');

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
            game_tick => TB_game_tick,
            lost_game => TB_lost_game,
            x_pos_out => TB_tank_x_pos_out,
            y_pos_out => TB_tank_y_pos_out
        );

        dut_bullet_a: bullet
        generic map(
            color => std_logic_vector(to_unsigned(1, 3)),
            speed_magnitude => to_unsigned(10, 10),
            direction => '0',
            max_y_val => to_unsigned(200, 10)
        )
        port map(
            initial_x_pos => TB_tank_x_pos_out,
            initial_y_pos => TB_tank_y_pos_out,
            reset => TB_reset,
            fire => TB_fire_bullet,
            game_tick => TB_game_tick,
            is_collision => TB_is_collision_bullet,
            game_over => TB_game_over_bullet,
            x_pos_out => TB_bullet_x_pos_out,
            y_pos_out => TB_bullet_y_pos_out
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
            -- Set all inputs to 0
            TB_speed <= "00";
            TB_reset <= '0';
            TB_game_tick <= '0';
            TB_lost_game <= '0';

            TB_fire_bullet <= '0';
            TB_is_collision_bullet <= '0';
            TB_game_over_bullet <= '0';

            clk <= '0';
            wait for clk_period;

            -- Send reset signal to tank and bullet
            TB_reset <= '1';

            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';

            -- Bullet should be off screen
            -- report "BulletX: " & integer'image(to_integer(unsigned(TB_bullet_x_pos_out))) & " BulletY: " & integer'image(to_integer(unsigned(TB_bullet_y_pos_out))) severity note;
            assert (TB_bullet_y_pos_out > std_logic_vector(to_unsigned(200, 10))) report "Bullet y position is not off screen" severity error;

            -- Tank should be at y_pos = 1, x_pos = 0
            assert (TB_tank_y_pos_out = std_logic_vector(to_unsigned(1, 10))) report "Tank y position is not 1" severity error;
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(40, 10))) report "Tank x position is not expected" severity error;

            -- NEXT TEST -> Reset goes to zero, tick game
            TB_reset <= '0';
            TB_speed <= "01";

            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;
            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;

            -- Bullet should be off screen
            assert (TB_bullet_y_pos_out > std_logic_vector(to_unsigned(200, 10))) report "Bullet y position is not off screen" severity error;

            -- Tank should have moved 4 pixels to the right
            assert (TB_tank_y_pos_out = std_logic_vector(to_unsigned(1, 10))) report "Tank y position is not 1" severity error;
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(44, 10))) report "Tank x position is not expected" severity error;

            -- report "Tank x position is " & integer'image(to_integer(unsigned(TB_tank_x_pos_out))) severity note;

            -- Perform another game tick
            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;

            assert (TB_bullet_y_pos_out > std_logic_vector(to_unsigned(200, 10))) report "Bullet y position is not off screen" severity error;
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(48, 10))) report "Tank x position is not expected" severity error;

            assert (TB_tank_y_pos_out = std_logic_vector(to_unsigned(1, 10))) report "Tank y position is not 1" severity error;

            -- Fire bullet
            TB_fire_bullet <= '1';

            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;
            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;

            TB_fire_bullet <= '0';

            -- Bullet should be at the same x position as the tank in the previous step
            -- Print out bullet x position and y
            -- report "TankX: " & integer'image(to_integer(unsigned(TB_tank_x_pos_out))) & " TankY: " & integer'image(to_integer(unsigned(TB_tank_y_pos_out))) severity note;
            assert (TB_bullet_x_pos_out = std_logic_vector(to_unsigned(48, 10))) report "Bullet x position is not expected" severity error;
            assert (TB_bullet_y_pos_out = std_logic_vector(to_unsigned(1, 10))) report "Bullet y position is not expected" severity error;

            -- Tank should have moved 4*2 = 8 pixels to the right
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(56, 10))) report "Tank x position is not expected" severity error;

            -- Perform another game tick
            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;

            -- Bullet should have moved 10 pixels up
            assert (TB_bullet_x_pos_out = std_logic_vector(to_unsigned(48, 10))) report "Bullet x position is not expected" severity error;
            assert (TB_bullet_y_pos_out = std_logic_vector(to_unsigned(11, 10))) report "Bullet y position is not expected" severity error;

            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(60, 10))) report "Tank x position is not expected" severity error;

            -- Cycle through 10 game ticks
            for i in 1 to 10 loop
                TB_game_tick <= '1';
                wait for clk_period;
                TB_game_tick <= '0';
                wait for clk_period;
            end loop;

            -- Bullet should have moved 10*10 = 100 pixels up
            assert (TB_bullet_x_pos_out = std_logic_vector(to_unsigned(48, 10))) report "Bullet x position is not expected" severity error;
            assert (TB_bullet_y_pos_out = std_logic_vector(to_unsigned(111, 10))) report "Bullet y position is not expected" severity error;

            -- Tank should have moved 4*10 = 40 pixels to the right
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(100, 10))) report "Tank x position is not expected" severity error;

            -- Cycle through 10 game ticks
            for i in 1 to 10 loop
                TB_game_tick <= '1';
                wait for clk_period;
                TB_game_tick <= '0';
                wait for clk_period;
            end loop;

            -- Bullet should have moved 10*10 = 110 pixels up
            -- It now should be at y = 221, which is above the max_y_val of 200
            -- Therefore it should be off screen, at y = 800, x = 800
            assert (TB_bullet_x_pos_out = std_logic_vector(to_unsigned(800, 10))) report "Bullet x position is not expected" severity error;
            assert (TB_bullet_y_pos_out = std_logic_vector(to_unsigned(800, 10))) report "Bullet y position is not expected" severity error;

            -- Tank should have moved 4*10 = 40 pixels to the right
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(140, 10))) report "Tank x position is not expected" severity error;

            -- Set speed to 3, which is actually 12
            TB_speed <= "11";

            -- Cycle through 1 tick
            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;
            -- Tank should have moved 4 pixels to the right
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(144, 10))) report "Tank x position is not expected" severity error;

            -- Cycle through 1 tick
            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;
            -- Tank should have moved 12 pixels to the right
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(156, 10))) report "Tank x position is not expected" severity error;

            -- Cycle through 2 ticks
            for i in 1 to 2 loop
                TB_game_tick <= '1';
                wait for clk_period;
                TB_game_tick <= '0';
                wait for clk_period;
            end loop;

            -- Tank should have moved 12*2 = 24 pixels to the right
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(180, 10))) report "Tank x position is not expected" severity error;

            -- Cycle through 19 ticks
            for i in 1 to 19 loop
                TB_game_tick <= '1';
                wait for clk_period;
                TB_game_tick <= '0';
                wait for clk_period;
            end loop;

            -- Tank should have moved 12*19 = 228 pixels to the right
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(408, 10))) report "Tank x position is not expected" severity error;

            -- Max x is 450, width of tank is 40, so tank should be off screen at next tick, and bounce the other way
            -- This means that it should be at 410
            TB_game_tick <= '1';
            wait for clk_period;
            TB_game_tick <= '0';
            wait for clk_period;

            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(410, 10))) report "Tank x position is not expected" severity error;

            -- Tank should be going left now

            -- Cycle through 30 ticks
            for i in 1 to 30 loop
                TB_game_tick <= '1';
                wait for clk_period;
                TB_game_tick <= '0';
                wait for clk_period;
            end loop;

            -- Tank should have moved 12*30 = 360 pixels to the left
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(50, 10))) report "Tank x position is not expected" severity error;

            -- Loop 5 times, now it should be at the far left
            for i in 1 to 5 loop
                TB_game_tick <= '1';
                wait for clk_period;
                TB_game_tick <= '0';
                wait for clk_period;
            end loop;

            -- Tank should have moved 12*5 = 60 pixels to the left, but there's only 50 pixels, so snap to 0
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(0, 10))) report "Tank x position is not expected" severity error;

            -- Cycle through 30 ticks
            for i in 1 to 30 loop
                TB_game_tick <= '1';
                wait for clk_period;
                TB_game_tick <= '0';
                wait for clk_period;
            end loop;

            -- Tank should have moved 12*30 = 360 pixels to the right
            assert (TB_tank_x_pos_out = std_logic_vector(to_unsigned(360, 10))) report "Tank x position is not expected" severity error;

            -- report "BulletX: " & integer'image(to_integer(unsigned(TB_bullet_x_pos_out))) & " BulletY: " & integer'image(to_integer(unsigned(TB_bullet_y_pos_out))) severity note;
            report "TankX: " & integer'image(to_integer(unsigned(TB_tank_x_pos_out))) & " TankY: " & integer'image(to_integer(unsigned(TB_tank_y_pos_out))) severity note;


            finished <= '1';
            assert false report "Ending" severity note;
            wait;
        end process;

end architecture behavioral;

-- ghdl -a --workdir=work -g -fsynopsys bullet.vhd tank.vhd bullet_tank_tb.vhd
-- ghdl --elab-run -g --workdir=work -fsynopsys bullet_tank_tb

-- ghdl -a --workdir=work -g -fsynopsys bullet.vhd tank.vhd bullet_tank_tb.vhd; ghdl --elab-run -g --workdir=work -fsynopsys bullet_tank_tb

