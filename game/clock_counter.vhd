LIBRARY IEEE;
use IEEE.NUMERIC_STD.all;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uses the 50MHz clock
-- Generates a 30Hz clock, generating a pulse every 1/30th of a second
-- 50,000,000 / 30 = 1,666,666.66 ticks per pulse
-- Count to 1,666,667, pulse and reset

ENTITY clock_counter IS
    PORT (clock_100Mhz : IN STD_LOGIC;
          pulse : OUT STD_LOGIC);
END clock_counter;

ARCHITECTURE clock_counter_arch OF clock_counter IS
    SIGNAL counter : unsigned(20 DOWNTO 0) := (OTHERS => '0');

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
