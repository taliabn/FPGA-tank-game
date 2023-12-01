library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity collision_check is
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
end entity;

architecture behavioral of collision_check is
    signal obja_x1, obja_x2, obja_y1, obja_y2: unsigned(9 downto 0);
    signal objb_x1, objb_x2, objb_y1, objb_y2: unsigned(9 downto 0);

begin
    obja_x1 <= unsigned(obja_x);
    obja_x2 <= unsigned(obja_x) + obja_width;
    obja_y1 <= unsigned(obja_y);
    obja_y2 <= unsigned(obja_y) + obja_height;

    objb_x1 <= unsigned(objb_x);
    objb_x2 <= unsigned(objb_x) + objb_width;
    objb_y1 <= unsigned(objb_y);
    objb_y2 <= unsigned(objb_y) + objb_height;

    process(reset, clk)
    begin
        if reset = '1' then
            is_collision <= '0';
        elsif rising_edge(clk) then
            -- NOTE: This is a very naive implementation of collision detection
            -- NOTE: We probably could make this more optimized somehow
            if (obja_x1 <= objb_x2 and obja_x2 >= objb_x1) and
               (obja_y1 <= objb_y2 and obja_y2 >= objb_y1) then
                is_collision <= '1';
            -- NOTE: This reverse check is needed in case obja is inside objb
            -- can probably be optimized out depending on how we choose to use it
            -- I just wanted to minimize the chance of a mistake
            elsif (objb_x1 <= obja_x2 and objb_x2 >= obja_x1) and
                  (objb_y1 <= obja_y2 and objb_y2 >= obja_y1) then
                is_collision <= '1';
            else
                is_collision <= '0';
            end if;
        end if;
    end process;
end behavioral;

-- ghdl -a --workdir=work -g -fsynopsys collision_check.vhd
-- ghdl --elab-run -g --workdir=work -fsynopsys collision_check_tb
