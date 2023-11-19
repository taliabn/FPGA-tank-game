library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity char_buffer is
	port (
		p1_win, p2_win, reset, game_tick : in std_logic;
		char_buffer_80_chars : out std_logic_vector(80 - 1 downto 0)
	) ;
end char_buffer ; 

architecture behavior of char_buffer is

	type t_state is (gameplay, win);
	signal state, next_state: t_state;

	signal buffer_comb, buffer_o: std_logic_vector(80 - 1 downto 0) := (others => '0');

begin

    clocked_process : process(game_tick, reset)
    begin
        if ( reset = '1' ) then
			-- on reset, assign buffer to be all spaces
            buffer_o <= X"20202020202020202020";
			state <= gameplay;
        elsif ( rising_edge(game_tick) ) then
			state <= next_state;
			buffer_o <= buffer_comb;
		end if;
	end process clocked_process;

	combo_process : process(state, p1_win, p2_win, buffer_o)
	begin
		-- assign defaults
		buffer_comb <= buffer_o;
		next_state <= state;
		-- fsm
		case ( state ) is

			when gameplay =>
				if (p1_win = '1' or p2_win = '1') then
					-- display winner in format "PX wins!"
					-- use buffer(9:2)
					buffer_comb((8*10)-1 downto (8*9)) <= X"50"; -- "P"
					-- this does not handle ties, prioritizes p1
					if (p1_win = '1') then
						buffer_comb((8*9)-1 downto (8*8)) <= X"31"; -- "1"
					elsif (p2_win = '1') then
						buffer_comb((8*9)-1 downto (8*8)) <= X"32"; -- "2"
					else -- some timing got messed up (shouldn't happen)
						buffer_comb((8*9)-1 downto (8*8)) <= X"3F"; -- "?"
					end if;

					buffer_comb((8*8)-1 downto (8*7)) <= X"20"; -- " "
					buffer_comb((8*7)-1 downto (8*6)) <= X"77"; -- "w"
					buffer_comb((8*6)-1 downto (8*5)) <= X"69"; -- "i"
					buffer_comb((8*5)-1 downto (8*4)) <= X"6E"; -- "n"
					buffer_comb((8*4)-1 downto (8*3)) <= X"73"; -- "s"
					buffer_comb((8*3)-1 downto (8*2)) <= X"21"; -- "!"
					buffer_comb((8*2)-1 downto (8*1)) <= X"20"; -- " "
					buffer_comb((8*1)-1 downto (8*0)) <= X"20"; -- " "
					next_state <= win;
				else
					next_state <= gameplay;
					buffer_comb <= X"20202020202020202020";
				end if;

			when win =>
				-- don't change anything
				buffer_comb <= buffer_o;
				-- stay in win state until reset
				next_state <= win;

			when others =>
				buffer_comb <= (others => 'X');
				next_state <= gameplay;
		end case;
	end process combo_process;

	-- assign output ports from registered signals
	char_buffer_80_chars <= buffer_o;

end architecture behavior;