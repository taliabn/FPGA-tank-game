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
			p1_win, p2_win, reset, clk : in std_logic;
			char_buffer_80_chars : out std_logic_vector(80 - 1 downto 0)
		);
	end component char_buffer ; 
	
	component leddcd is
		port(
			 data_in : in std_logic_vector(3 downto 0);
			 segments_out : out std_logic_vector(6 downto 0)
			);
	end component leddcd;	

	signal p1_win, p2_win, reset, clk: std_logic := '0';
	signal char_buffer_80_chars : std_logic_vector(80 - 1 downto 0) := (others => '0');
    signal finished : std_logic := '0';
	constant clk_period : time := 100 ps;

begin
    dut: char_buffer
		port map(
			p1_win => p1_win, 
			p2_win => p2_win,
			reset => reset, 
			clk => clk,
			char_buffer_80_chars => char_buffer_80_chars
		);

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

	test_process: process is
    begin

		assert false report "start of test" severity note;

		-- simulate reset
		reset <= '1';
		wait until (clk = '0');
		wait until (clk = '1');
		reset <= '0'; 
		wait until (clk = '0');
		
		-- test 0: no win, all spaces
		p1_win <= '0';
		p2_win <= '0';
		wait for clk_period;

		assert char_buffer_80_chars = X"20202020202020202020" report "Test 0 failed" severity error;

		-- test 1: "P1 wins!"
		p1_win <= '1';
		p2_win <= '0';
		wait for clk_period;

		assert char_buffer_80_chars = X"50312077696e73212020" report "Test 1 failed" severity error;

		-- test 2: "P1 wins!"
		-- input winner change, but it should stay in win state
		p1_win <= '0';
		p2_win <= '1';
		wait for clk_period;

		assert char_buffer_80_chars = X"50312077696e73212020" report "Test 2 failed" severity error;
		
		-- test 3:  "P2 wins!"
		-- first, reset
		reset <= '1';
		wait until (clk = '0');
		wait until (clk = '1');
		-- test reset
		assert char_buffer_80_chars = X"20202020202020202020" report "Test 3A failed" severity error;
		reset <= '0'; 
		wait until (clk = '0');
		wait for clk_period;
		-- "P2 wins!"
		assert char_buffer_80_chars = X"50322077696e73212020" report "Test 3B failed" severity error;
		wait for clk_period;
		wait for clk_period;
		-- test that message is held in win state
		assert char_buffer_80_chars = X"50322077696e73212020" report "Test 3B failed" severity error;

        assert false report "end of test" severity note;
        finished <= '1';
		wait; 
	end process test_process;

end architecture behavioral;
