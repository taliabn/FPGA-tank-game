library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clock_counter_small_tb is
end clock_counter_small_tb;
	
architecture behavioral of clock_counter_small_tb is 
    COMPONENT clock_counter_small IS
    PORT (clock_100Mhz : IN STD_LOGIC;
          pulse : OUT STD_LOGIC);
    END COMPONENT clock_counter_small;


    signal clk : std_logic := '0';
    signal pulse : std_logic := '0';

    signal finished : std_logic := '0';

    constant clk_period : time := 10 ns;

BEGIN
    dut : clock_counter_small
    PORT MAP (
        clock_100Mhz => clk,
        pulse => pulse
    );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;

        if finished = '1' then
            wait;
        end if;
    end process;

    stim_proc: process
    begin
        
        wait for clk_period * 10000;

        finished <= '1';
        wait;
    end process;
    
end architecture behavioral;
