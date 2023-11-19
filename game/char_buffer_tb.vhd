library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- ghdl -a --workdir=work -g -fsynopsys char_buffer.vhd char_buffer_tb.vhd; ghdl --elab-run -g --workdir=work -fsynopsys char_buffer_tb
-- ghdl -a --workdir=work -g -fsynopsys de2lcd.vhd char_buffer.vhd char_buffer_tb.vhd
-- ghdl --elab-run -g --workdir=work -fsynopsys char_buffer_tb

entity char_buffer_tb is
end entity char_buffer_tb ;

architecture behavioral of char_buffer_tb is
	-- component declaration for the unit under test
	component char_buffer is
		port (
			p1_win, p2_win, reset, game_tick : in std_logic;
			char_buffer_80_chars : out std_logic_vector(80 - 1 downto 0)
		);
	end component char_buffer ; 
	
	component leddcd is
		port(
			 data_in : in std_logic_vector(3 downto 0);
			 segments_out : out std_logic_vector(6 downto 0)
			);
	end component leddcd;	

	-- signals go here
	signal p1_win, p2_win, reset, game_tick: std_logic := '0';
	signal char_buffer_80_chars : std_logic_vector(80 - 1 downto 0) := (others => '0');

    signal finished : std_logic := '0';

	-- Set the game_tick to 100 ps
	constant game_tick_period : time := 100 ps;

begin
    dut: char_buffer
		port map(
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
		
		-- test 0: no win, all spaces
		p1_win <= '0';
		p2_win <= '0';
		wait for game_tick_period;

		assert char_buffer_80_chars = X"20202020202020202020" report "Test 0 failed" severity error;

		-- test 1: "P1 wins!"
		p1_win <= '1';
		p2_win <= '0';
		wait for game_tick_period;

		assert char_buffer_80_chars = X"50312077696e73212020" report "Test 1 failed" severity error;

		-- test 2: "P1 wins!"
		-- input winner change, but it should stay in win state
		p1_win <= '0';
		p2_win <= '1';
		wait for game_tick_period;

		assert char_buffer_80_chars = X"50312077696e73212020" report "Test 2 failed" severity error;
		
		-- test 3:  "P2 wins!"
		-- first, reset
		reset <= '1';
		wait until (game_tick = '0');
		wait until (game_tick = '1');
		-- test reset
		assert char_buffer_80_chars = X"20202020202020202020" report "Test 3A failed" severity error;
		reset <= '0'; 
		wait until (game_tick = '0');
		wait for game_tick_period;
		-- "P2 wins!"
		assert char_buffer_80_chars = X"50322077696e73212020" report "Test 3B failed" severity error;
		wait for game_tick_period;
		wait for game_tick_period;
		-- test that message is held in win state
		assert char_buffer_80_chars = X"50322077696e73212020" report "Test 3B failed" severity error;

        -- Display a message when simulation finished
        assert false report "end of test" severity note;

        -- Finish the simulation
        finished <= '1';
		wait; -- very important line don't delete this one
	end process test_process;

end architecture behavioral;