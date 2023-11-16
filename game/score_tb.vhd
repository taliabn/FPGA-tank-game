library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ghdl -a --workdir=work -g -fsynopsys score.vhd score_tb.vhd
-- ghdl --elab-run -g --workdir=work -fsynopsys score_tb

entity score_tb is
end entity score_tb ;

architecture behavioral of score_tb is
	-- component declaration for the unit under test
	component score is
		port (
			p1_hit, p2_hit, reset, game_tick: in std_logic;
			p1_score, p2_score : out std_logic_vector(1 downto 0);
			p1_win, p2_win : out std_logic
		);
	end component score;

	-- signals go here
    signal p1_hit, p2_hit: std_logic := '0'; 
	signal reset, game_tick: std_logic := '0';
	signal p1_score, p2_score : std_logic_vector(1 downto 0) := (others => '0');
	signal p1_win, p2_win : std_logic := '0';

    signal finished : std_logic := '0';

	-- Set the game_tick to 100 ps
	constant game_tick_period : time := 100 ps;

begin
    dut: score
		port map(
			p1_hit => p1_hit, 
			p2_hit => p2_hit, 
			reset => reset, 
			game_tick => game_tick,
			p1_score => p1_score, 
			p2_score => p2_score,
			p1_win => p1_win, 
			p2_win => p2_win
		);

    game_tick_process: process  is
    begin
        game_tick <= '0';
        wait for game_tick_period / 2;
        game_tick <= '1';
        wait for game_tick_period / 2;

        if finished = '1' then
            wait;
        end if;
    end process;

	test_process: process is
    begin

		assert false report "start of test" severity note;

		-- simulate reset
		reset <= '1';
		wait until (game_tick = '0');
		wait until (game_tick = '1');
		reset <= '0'; 
		wait until (game_tick = '0');

		-- test 0: 0:0
		p1_hit <= '0'; 
		p2_hit <= '0'; 
		wait for game_tick_period;

		assert p1_score = std_logic_vector(to_unsigned(0, 2)) report "Test 0 failed from p1_score" severity error;
		assert p2_score = std_logic_vector(to_unsigned(0, 2)) report "Test 0 failed from p2_score" severity error;
		assert p1_win = '0' report "Test 0 failed from p1_win" severity error;
		assert p2_win = '0' report "Test 0 failed from p2_win" severity error;
		
		-- test 1: 1:0 (p2 hit)
		p1_hit <= '0'; 
		p2_hit <= '1'; 
		wait for game_tick_period;

		assert p1_score = std_logic_vector(to_unsigned(1, 2)) report "Test 1 failed from p1_score" severity error;
		assert p2_score = std_logic_vector(to_unsigned(0, 2)) report "Test 1 failed from p2_score" severity error;
		assert p1_win = '0' report "Test 1 failed from p1_win" severity error;
		assert p2_win = '0' report "Test 1 failed from p2_win" severity error;

		-- test 2: 1:1 (p1 hit)
		p1_hit <= '1'; 
		p2_hit <= '0'; 
		wait for game_tick_period;

		assert p1_score = std_logic_vector(to_unsigned(1, 2)) report "Test 2 failed from p1_score" severity error;
		assert p2_score = std_logic_vector(to_unsigned(1, 2)) report "Test 2 failed from p2_score" severity error;
		assert p1_win = '0' report "Test 2 failed from p1_win" severity error;
		assert p2_win = '0' report "Test 2 failed from p2_win" severity error;

		-- test 3: 2:1 (p2 hit)
		p1_hit <= '0'; 
		p2_hit <= '1'; 
		wait for game_tick_period;

		assert p1_score = std_logic_vector(to_unsigned(2, 2)) report "Test 3 failed from p1_score" severity error;
		assert p2_score = std_logic_vector(to_unsigned(1, 2)) report "Test 3 failed from p2_score" severity error;
		assert p1_win = '0' report "Test 3 failed from p1_win" severity error;
		assert p2_win = '0' report "Test 3 failed from p2_win" severity error;

		-- test 4: 2:1 (no change)
		p1_hit <= '0'; 
		p2_hit <= '0'; 
		wait for game_tick_period;

		assert p1_score = std_logic_vector(to_unsigned(2, 2)) report "Test 4 failed from p1_score" severity error;
		assert p2_score = std_logic_vector(to_unsigned(1, 2)) report "Test 4 failed from p2_score" severity error;
		assert p1_win = '0' report "Test 4 failed from p1_win" severity error;
		assert p2_win = '0' report "Test 4 failed from p2_win" severity error;

        -- test 5: 3:2 (p1 won, both hit)
		p1_hit <= '1'; 
		p2_hit <= '1'; 
		wait for game_tick_period;

		assert p1_score = std_logic_vector(to_unsigned(3, 2)) report "Test 5 failed from p1_score" severity error;
		assert p2_score = std_logic_vector(to_unsigned(2, 2)) report "Test 5 failed from p2_score" severity error;
		assert p1_win = '1' report "Test 5 failed from p1_win" severity error;
		assert p2_win = '0' report "Test 5 failed from p2_win" severity error;

		-- test 6: 3:2 (p1 hit erroneously, scores shouldn't change)
		p1_hit <= '1'; 
		p2_hit <= '0'; 
		wait for game_tick_period;

		assert p1_score = std_logic_vector(to_unsigned(3, 2)) report "Test 6 failed from p1_score" severity error;
		assert p2_score = std_logic_vector(to_unsigned(2, 2)) report "Test 6 failed from p2_score" severity error;
		assert p1_win = '1' report "Test 6 failed from 1_win" severity error;
		assert p2_win = '0' report "Test 6 failed from p2_win" severity error;


		-- test 7: 3:3 (tie)
		-- first, reset scores
		reset <= '1';
		wait until (game_tick = '0');
		wait until (game_tick = '1');
		reset <= '0'; 
		wait until (game_tick = '0');
		-- three rounds where both players hit eachother
		p1_hit <= '1'; 
		p2_hit <= '1'; 
		wait for game_tick_period;
		wait for game_tick_period;
		wait for game_tick_period;
		-- now the score should be 3:3
		assert p1_score = std_logic_vector(to_unsigned(3, 2)) report "Test 7 failed from p1_score" severity error;
		assert p2_score = std_logic_vector(to_unsigned(3, 2)) report "Test 7 failed from p2_score" severity error;
		assert p1_win = '1' report "Test 7 failed from 1_win" severity error;
		assert p2_win = '1' report "Test 7 failed from p2_win" severity error;

        -- Display a message when simulation finished
        assert false report "end of test" severity note;

        -- Finish the simulation
        finished <= '1';
		wait; -- very important line don't delete this one
	end process test_process;

end architecture behavioral;