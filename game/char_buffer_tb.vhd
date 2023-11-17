library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- ghdl -a --workdir=work -g -fsynopsys de2lcd.vhd char_buffer.vhd char_buffer_tb.vhd
-- ghdl --elab-run -g --workdir=work -fsynopsys char_buffer_tb

entity char_buffer_tb is
end entity char_buffer_tb ;

architecture behavioral of char_buffer_tb is
	-- component declaration for the unit under test
	component char_buffer is
		port (
			p1_score, p2_score : in std_logic_vector(1 downto 0);
			p1_win, p2_win, reset, game_tick : in std_logic;
			char_buffer_80_chars : out std_logic_vector(0 to 80 - 1)
		);
	end component char_buffer ; 
	

	-- signals go here
	signal p1_win, p2_win, reset, game_tick: std_logic := '0';
	signal p1_score, p2_score : std_logic_vector(1 downto 0) := (others => '0');
	signal char_buffer_80_chars : std_logic_vector(0 to 80 - 1) := (others => '0');

    signal finished : std_logic := '0';
	signal tmp: std_logic_vector(0 to 80 - 1);

	-- Set the game_tick to 100 ps
	constant game_tick_period : time := 100 ps;

begin
    dut: char_buffer
		port map(
			p1_score => p1_score, 
			p2_score => p2_score,
			p1_win => p1_win, 
			p2_win => p2_win,
			reset => reset, 
			game_tick => game_tick,
			char_buffer_80_chars => char_buffer_80_chars
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
		p1_score <= "00"; 
		p2_score <= "00"; 
		p1_win <= '0';
		p2_win <= '0';
		wait for game_tick_period;

		assert char_buffer_80_chars = X"303a3020202020202020" report "Test 0 failed" severity error;
		-- report "Eq: " & integer'image(to_integer(unsigned(p2_score))) severity error;
		-- for i in 0 to 9 loop
		-- 	tmp <= char_buffer_80_chars(i*8 to (i+1)*8 - 1);
		-- 	report integer'image(to_integer(unsigned(tmp)));
		-- end loop;
		

		-- test 1: "0:1       " 
		p1_score <= "00"; 
		p2_score <= "01"; 
		p1_win <= '0';
		p2_win <= '0';
		wait for game_tick_period;
		
		assert char_buffer_80_chars = X"303a3120202020202020" report "Test 1 failed" severity error;

		-- test 2: "1:2       " 
		p1_score <= "01"; 
		p2_score <= "10"; 
		p1_win <= '0';
		p2_win <= '0';
		wait for game_tick_period;
		
		assert char_buffer_80_chars = X"313a3220202020202020" report "Test 2 failed" severity error;

		-- test 3: "3:1 P1 won"
		p1_score <= "11"; 
		p2_score <= "01"; 
		p1_win <= '1';
		p2_win <= '0';
		wait for game_tick_period;
		tmp <= X"333a3120503120776f6e";
		assert char_buffer_80_chars = tmp report "Test 3 failed" severity error;

		-- test 4: "3:1 P1 won"
		-- inputs change, but it should stay in reset state
		p1_score <= "10"; 
		p2_score <= "11"; 
		p1_win <= '0';
		p2_win <= '1';
		wait for game_tick_period;
		
		tmp <= X"323a3320503220776f6e";
		assert char_buffer_80_chars = tmp report "Test 4 failed" severity error;
		-- test 5: "2:3 P1 won"
		-- first, reset
		reset <= '1';
		wait until (game_tick = '0');
		wait until (game_tick = '1');
		reset <= '0'; 
		wait until (game_tick = '0');
		wait for game_tick_period;
		tmp <= X"323a3320503220776f6e";
		assert char_buffer_80_chars = tmp report "Test 5 failed" severity error;

        -- Display a message when simulation finished
        assert false report "end of test" severity note;

        -- Finish the simulation
        finished <= '1';
		wait; -- very important line don't delete this one
	end process test_process;

end architecture behavioral;