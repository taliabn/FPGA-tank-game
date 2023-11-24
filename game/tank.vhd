library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- tank (two instances)
-- inputs:
	-- speed (unsigned, comes from keyboard): in std_logic_vector (1 downto 0),
	-- reset, game_tick: in std_logic
-- generics: y_pos: std_logic_vector(9 downto 0),
	-- color: std_logic_vector(2 downto 0)
-- outputs: x_pos_out, y_pos: out std_logic_vector(9 downto 0)
-- notes: will have two instances
	-- direction is implicitly tracked with FSM


entity tank is
    -- Tank X,Y should be set to the upper left corner of the tank, assuming that 0,0 is in the upper left corner of the screen
    generic(
        -- Y position of tank
        y_pos: std_logic_vector(9 downto 0);
        -- Color isn't really used, but it's here for completeness
        color: std_logic_vector(2 downto 0);
        -- Width of tank
        tank_width: unsigned(9 downto 0);
        -- Max_X should be set to screen width
        max_x: unsigned(9 downto 0);
        -- Speed shift is used to multiply the speed input, performs a left shift by 2^speed_shift
        speed_shift: unsigned(3 downto 0)
    );
    port(
        speed: in std_logic_vector(1 downto 0);
        reset, game_tick: in std_logic;
        lost_game: in std_logic;
        x_pos_out, y_pos_out: out std_logic_vector(9 downto 0)
    );
end tank;

architecture tank_arch of tank is
    -- Off screen moves the tank off the screen
    -- Move right is the default state
    type state_type is (off_screen, move_left, move_right);
    signal state: state_type;
    signal next_state: state_type;
    signal next_x_pos: unsigned(9 downto 0);
    signal x_pos_int: unsigned(9 downto 0);

begin
    -- Clocked process
    process(reset, game_tick)
    begin
        if reset = '1' then
            -- Reset the tank to on screen, moving right
            state <= move_right;
            x_pos_int <= tank_width;
        elsif rising_edge(game_tick) then
            state <= next_state;
            x_pos_int <= next_x_pos;
        end if;
    end process;

    -- Combinatorial process
    process(state, speed, x_pos_int)
    variable speed_int : unsigned(9 downto 0);
    begin
        -- Convert speed to a 10 bit unsigned, and multiply by 4 (speeds = 0, 4, 8, 12)
        speed_int := shift_left(unsigned(resize(unsigned(speed), 10)), to_integer(speed_shift));
        case state is
            when off_screen =>
                next_state <= off_screen;
                next_x_pos <= shift_left(max_x, 1);
            when move_left =>
                if (x_pos_int - speed_int > 0) and (x_pos_int - speed_int < max_x) then
                    next_state <= move_left;
                    next_x_pos <= x_pos_int - speed_int;
                else
                    next_state <= move_right;
                    next_x_pos <= (others => '0');
                end if;
            when move_right =>
                if x_pos_int + speed_int < (max_x - tank_width) then
                    next_state <= move_right;
                    next_x_pos <= x_pos_int + speed_int;
                    -- report "Input speed is " & integer'image(to_integer(unsigned(speed)));
                    -- report "Moving right by "  & integer'image(to_integer(speed_int));
                else
                    next_state <= move_left;
                    -- NOTE! Optimization possible here;
                    -- Can eliminate the subtraction by making max_x - tank_width a constant
                    next_x_pos <= max_x - tank_width;
                end if;
            when others =>
                next_state <= off_screen;
                next_x_pos <= shift_left(max_x, 1);
        end case;
    end process;

    x_pos_out <= std_logic_vector(x_pos_int);
    y_pos_out <= y_pos;
end tank_arch;

-- ghdl -a --workdir=work -g -fsynopsys tank.vhd