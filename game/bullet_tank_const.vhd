library IEEE;
use IEEE.std_logic_1164.all;

package bullet_tank_const is
    constant BULLET_WIDTH : integer := 20;
    constant BULLET_HEIGHT : integer := 20;
    constant BULLET_SPEED : integer := 5;

    constant TANK_WIDTH : integer := 100;
    constant TANK_HEIGHT : integer := 50;
    constant TANK_SPEED_SHIFT : integer := 2;

    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant TANK1_Y : integer := 0;
    constant TANK2_Y : integer := SCREEN_HEIGHT - TANK_HEIGHT;
    

end package bullet_tank_const;
package body bullet_tank_const is
end package body bullet_tank_const;

