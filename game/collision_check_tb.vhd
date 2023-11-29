library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- NOTE! DOES NOT USE ANY ACTUAL CONSTANTS! JUST TESTS THE MODULE collision_check
-- TODO: verify that both object A being fully inside object B and object B being fully inside object A work correctly

entity collision_check_tb is
end collision_check_tb;

architecture behavioral of collision_check_tb is
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

    signal obja_x, obja_y, objb_x, objb_y: std_logic_vector(9 downto 0);

    signal is_collision: std_logic;

    signal reset, clk: std_logic;

    -- Clock is 30 hZ
    -- Therefore period is 33.33333 ms or 33,333,333 ns
    constant clk_period: time := 33333333 ns;

    signal finished_1: std_logic := '0';

begin
    dut_collision_check: collision_check
        generic map(
            -- Set the width and height of the objects to be
            -- 10 for width and 20 for height for a
            -- 20 for width and 10 for height for b
            obja_width => to_unsigned(10, 10),
            obja_height => to_unsigned(20, 10),

            objb_width => to_unsigned(20, 10),
            objb_height => to_unsigned(10, 10)
        )
        port map(
            obja_x => obja_x,
            obja_y => obja_y,
            objb_x => objb_x,
            objb_y => objb_y,
            reset => reset,
            clk => clk,
            is_collision => is_collision
        );

    -- Clock process definitions
    clk_process: process is
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;

        if finished_1 = '1' then
            wait;
        end if;
    end process;

    -- Stimulus process
    stim_proc: process is
    begin
        report "beginning test...";

        -- First, set all inputs to 0
        reset <= '0';
        obja_x <= (others => '0');
        obja_y <= (others => '0');
        objb_x <= (others => '0');
        objb_y <= (others => '0');
        wait for clk_period;
        assert is_collision = '1' report "Error: No collision at (0, 0)" severity error;

        -- Create a non-collision by moving object a to (100, 100)
        obja_x <= std_logic_vector(to_unsigned(100, 10));
        obja_y <= std_logic_vector(to_unsigned(100, 10));
        objb_x <= std_logic_vector(to_unsigned(0, 10));
        objb_y <= std_logic_vector(to_unsigned(0, 10));
        wait for clk_period;
        assert is_collision = '0' report "Error: Collision at (100, 100) and (0, 0)" severity error;

        -- Place objects a to be overlapping a: (5, 5), b: (0, 0)
        obja_x <= std_logic_vector(to_unsigned(5, 10));
        obja_y <= std_logic_vector(to_unsigned(5, 10));
        objb_x <= std_logic_vector(to_unsigned(0, 10));
        objb_y <= std_logic_vector(to_unsigned(0, 10));
        wait for clk_period;
        assert is_collision = '1' report "Error: No collision at (5, 5) and (0, 0)" severity error;

        -- Create a non-collision by moving object b to (100, 100)
        obja_x <= std_logic_vector(to_unsigned(5, 10));
        obja_y <= std_logic_vector(to_unsigned(5, 10));
        objb_x <= std_logic_vector(to_unsigned(100, 10));
        objb_y <= std_logic_vector(to_unsigned(100, 10));
        wait for clk_period;
        assert is_collision = '0' report "Error: Collision at (5, 5) and (100, 100)" severity error;

        -- Place objects a to be overlapping a: (0, 0), b: (5, 5)
        obja_x <= std_logic_vector(to_unsigned(0, 10));
        obja_y <= std_logic_vector(to_unsigned(0, 10));
        objb_x <= std_logic_vector(to_unsigned(5, 10));
        objb_y <= std_logic_vector(to_unsigned(5, 10));
        wait for clk_period;
        assert is_collision = '1' report "Error: No collision at (0, 0) and (5, 5)" severity error;

        -- Create a collision with bottom of a touching top of a
        -- (dims of a: 10x20, b: 20x10)
        obja_x <= std_logic_vector(to_unsigned(0, 10));
        obja_y <= std_logic_vector(to_unsigned(0, 10));
        objb_x <= std_logic_vector(to_unsigned(10, 10));
        objb_y <= std_logic_vector(to_unsigned(20, 10));
        wait for clk_period;
        assert is_collision = '1' report "Error: No collision at (0, 0) and (10, 20)" severity error;

        -- Bottom of b touching top of a
        obja_x <= std_logic_vector(to_unsigned(20, 10));
        obja_y <= std_logic_vector(to_unsigned(10, 10));
        objb_x <= std_logic_vector(to_unsigned(0, 10));
        objb_y <= std_logic_vector(to_unsigned(0, 10));
        wait for clk_period;
        assert is_collision = '1' report "Error: No collision at (20, 10) and (0, 0)" severity error;

        -- Left of b touching right of a
        obja_x <= std_logic_vector(to_unsigned(0, 10));
        obja_y <= std_logic_vector(to_unsigned(0, 10));
        objb_x <= std_logic_vector(to_unsigned(10, 10));
        objb_y <= std_logic_vector(to_unsigned(0, 10));
        wait for clk_period;
        assert is_collision = '1' report "Error: No collision at (0, 0) and (10, 10)" severity error;

        -- Right of b touching left of a
        obja_x <= std_logic_vector(to_unsigned(20, 10));
        obja_y <= std_logic_vector(to_unsigned(0, 10));
        objb_x <= std_logic_vector(to_unsigned(0, 10));
        objb_y <= std_logic_vector(to_unsigned(0, 10));
        wait for clk_period;
        assert is_collision = '1' report "Error: No collision at (20, 0) and (0, 0)" severity error;

        report "end of test";
        finished_1 <= '1';
        wait;
    end process;
end behavioral;

-- ghdl -a --workdir=work -g -fsynopsys collision_check.vhd collision_check_tb.vhd
-- ghdl --elab-run --workdir=work -g -fsynopsys collision_check_tb

-- ghdl -a --workdir=work -g -fsynopsys collision_check.vhd collision_check_tb.vhd; ghdl --elab-run --workdir=work -g -fsynopsys collision_check_tb


