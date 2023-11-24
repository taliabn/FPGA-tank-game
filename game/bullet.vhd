library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
-- reset -> bullet is off screen
	--
-- when fired
	-- model tells bullet to go to an xy (model knows that xy is the tank position)
-- when collision
	-- model tells bullet to fuckoff screen to an xy
-- normal
	-- bullet proceeds on its velocity

entity bullet is
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
end bullet;

architecture bullet_arch of bullet is
    type state_type is (off_screen, normal, win_state);
    signal state: state_type;
    signal next_state: state_type;
    signal next_y_pos: unsigned(9 downto 0);
    signal y_pos_int: unsigned(9 downto 0);
    signal next_x_pos: unsigned(9 downto 0);
    signal x_pos_int: unsigned(9 downto 0);

begin
    process(reset, game_tick)
    begin
        if reset = '1' then
            state <= off_screen;
            x_pos_int <= shift_left(max_y_val, 1);
            y_pos_int <= shift_left(max_y_val, 1);
            -- report "bullet reset";
        elsif rising_edge(game_tick) then
            state <= next_state;
            x_pos_int <= next_x_pos;
            y_pos_int <= next_y_pos;
        end if;
    end process;

    process(state, fire, is_collision, game_over, x_pos_int, y_pos_int)
    begin
        next_state <= state;
        next_x_pos <= x_pos_int;
        next_y_pos <= y_pos_int;

        case state is
            when off_screen =>
                if game_over = '1' then
                    next_state <= win_state;
                    next_y_pos <= shift_left(max_y_val, 2);
                elsif fire = '1' then
                    next_state <= normal;
                    next_x_pos <= unsigned(initial_x_pos);
                    next_y_pos <= unsigned(initial_y_pos);
                else
                    next_state <= off_screen;
                    next_x_pos <= shift_left(max_y_val, 2);
                    next_y_pos <= shift_left(max_y_val, 2);
                end if;
            -- normal = bullet has been fired and is moving
            when normal =>
                if game_over = '1' then
                    next_state <= win_state;
                elsif is_collision = '1' then
                    next_state <= off_screen;
                else
                    -- If the bullet has exited the screen, set it to off_screen
                    -- Unsigned comparisom, so <0 is just really big
                    if (y_pos_int > max_y_val) then
                        next_state <= off_screen;
                        next_x_pos <= shift_left(max_y_val, 2);
                        next_y_pos <= shift_left(max_y_val, 2);
                    -- Direction = 1 means bullet is moving in the -y direction
                    -- Direction = 0 means bullet is moving in the +y direction
                    elsif direction = '1' then
                        next_y_pos <= y_pos_int - speed_magnitude;
                    else
                        next_y_pos <= y_pos_int + speed_magnitude;
                    end if;
                end if;
            when win_state =>
                if game_over = '1' then
                    next_state <= win_state;
                    next_x_pos <= shift_left(y_pos_int, 2);
                    next_y_pos <= shift_left(y_pos_int, 2);
                end if;
            when others =>
                next_state <= off_screen;
                next_x_pos <= shift_left(max_y_val, 2);
                next_y_pos <= shift_left(max_y_val, 2);
        end case;
        -- display x_pos_int and y_pos_int;
        -- report "bullet x_pos_int: " & integer'image(to_integer(x_pos_int));
        -- report "bullet y_pos_int: " & integer'image(to_integer(y_pos_int));

    end process;

    x_pos_out <= std_logic_vector(x_pos_int);
    y_pos_out <= std_logic_vector(y_pos_int);
end bullet_arch;

