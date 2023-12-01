LIBRARY IEEE;
use IEEE.NUMERIC_STD.all;
USE IEEE.STD_LOGIC_1164.ALL;

-- Same as clock_counter.vhd, but with a 7 bit counter so that game pulse has a much faster frequency
-- allows for simulations to use a clock counter and finish running in a reasonable amount of time

ENTITY clock_counter_small IS
    PORT (clock_100Mhz : IN STD_LOGIC;
          pulse : OUT STD_LOGIC);
END clock_counter_small;

ARCHITECTURE clock_counter_arch OF clock_counter_small IS
    SIGNAL counter : unsigned(6 DOWNTO 0) := (OTHERS => '0');

BEGIN
    PROCESS (clock_100MHz)
        constant ZEROS : unsigned(counter'range) := (OTHERS => '0');
    BEGIN
        IF (rising_edge(clock_100MHz)) THEN
            counter <= unsigned(counter + to_unsigned(1, counter'length));
            if ( counter = ZEROS ) THEN
                pulse <= '1';
            else
                pulse <= '0';
            end if;
        END IF;
    END PROCESS;
END clock_counter_arch;
