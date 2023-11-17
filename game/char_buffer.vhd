library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity char_buffer is
	port (
		p1_score, p2_score : in std_logic_vector(1 downto 0);
		p1_win, p2_win, reset, game_tick : in std_logic;
		char_buffer_80_chars : out std_logic_vector(0 to 80 - 1)
	) ;
end char_buffer ; 

architecture behavior of char_buffer is

	type t_state is (gameplay, win);
	signal state, next_state: t_state;

	signal buffer_comb, buffer_o: std_logic_vector(0 to 80 - 1) := (others => '0');
	constant ascii_num_offset: unsigned(7 downto 0) := X"30"; -- ascii value for number 0
begin

	-- "p1_score:p2_score p1 won"

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


	combo_process : process(state, p1_score, p2_score, p1_win, p2_win)
		variable tmp_p1: unsigned(7 downto 0);
		variable tmp_p2: unsigned(7 downto 0);
	begin
		-- assign defaults
		buffer_comb <= buffer_o;
		next_state <= state;
		-- fsm
		case ( state ) is

			when gameplay =>
				-- display scores in format "p1_score:p2_score"
				-- use buffer(0:2)
				tmp_p1 := ascii_num_offset + unsigned(p1_score);
				buffer_comb((8*0) to (8*1)-1) <= std_logic_vector(tmp_p1);
				buffer_comb((8*1) to (8*2)-1) <= X"3A"; -- ":"
				tmp_p2 := ascii_num_offset + unsigned(p2_score);
				buffer_comb((8*2) to (8*3)-1) <= std_logic_vector(tmp_p2);

				-- default to returning to gameplay
				if (p1_win = '1' or p2_win = '1') then
					-- display winner in format "PX won"
					-- use buffer(4:9)
					buffer_comb((8*4) to (8*5)-1) <= X"50"; -- "P"

					-- this does not handle ties, prioritizes p1
					if (p1_win = '1') then
						buffer_comb((8*5) to (8*6)-1) <= X"31"; -- "1"
					elsif (p2_win = '1') then
						buffer_comb((8*5) to (8*6)-1) <= X"32"; -- "2"
					else -- some timing got messed up (shouldn't happen)
						buffer_comb((8*5) to (8*6)-1) <= X"3F"; -- "?"
					end if;

					buffer_comb((8*7) to (8*8)-1) <= X"77"; -- "w"
					buffer_comb((8*8) to (8*9)-1) <= X"6F"; -- "o"
					buffer_comb((8*9) to (8*10)-1) <= X"6E"; -- "n"
					next_state <= win;
				else
					next_state <= gameplay;
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