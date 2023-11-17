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
    generic(
        y_pos: std_logic_vector(9 downto 0);
        color: std_logic_vector(2 downto 0);
        max_x: unsigned(9 downto 0);
        speed_magnitude: unsigned(9 downto 0)
    );
    port(
        speed: in std_logic_vector(1 downto 0);
        reset, game_tick, start: in std_logic;
        x_pos_out, y_pos_out: out std_logic_vector(9 downto 0)
    );
end tank;

architecture tank_arch of tank is
    type state_type is (idle, move_left, move_right);
    signal state: state_type;
    signal next_state: state_type;
    signal next_x_pos: unsigned(9 downto 0);
    signal x_pos_int: unsigned(9 downto 0);
begin
    -- Clocked process
    process(reset, game_tick)
    begin
        if reset = '1' then
            state <= idle;
            x_pos_int <= shift_left(max_x, 1);
        elsif rising_edge(game_tick) then
            state <= next_state;
            x_pos_int <= next_x_pos;
        end if;
    end process;

    -- Combinatorial process
    process(state, start)
    begin
        case state is
            when idle =>
                if start = '1' then
                    next_state <= move_right;
                    next_x_pos <= shift_right(max_x, 1);
                else
                    next_state <= idle;
                    next_x_pos <= x_pos_int;
                end if;
            when move_left =>
                if x_pos_int - speed_magnitude > 0 then
                    next_state <= move_left;
                    next_x_pos <= x_pos_int - speed_magnitude;
                else
                    next_state <= move_right;
                    next_x_pos <= (others => '0');
                end if;
            when move_right =>
                -- TODO: factor in the width of the tank
                if x_pos_int + speed_magnitude < max_x then
                    next_state <= move_right;
                    next_x_pos <= x_pos_int + speed_magnitude;
                else
                    next_state <= move_left;
                    next_x_pos <= max_x;
                end if;
            when others =>
                next_state <= idle;
                next_x_pos <= shift_left(max_x, 1);
        end case;
    end process;

    x_pos_out <= std_logic_vector(x_pos_int);
    y_pos_out <= y_pos;
end tank_arch;

-- ghdl -a --workdir=work -g -fsynopsys tank.vhd