library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity score is
	generic(
		win_score : unsigned(2 downto 1) := "11"
	);
	port (
		p1_hit, p2_hit, reset, clk: in std_logic;
		p1_score, p2_score : out std_logic_vector(1 downto 0);
		p1_win, p2_win : out std_logic
	);
end entity score;

architecture behavior of score is
	signal p1_score_comb, p2_score_comb, p1_score_o, p2_score_o : std_logic_vector(1 downto 0) := (others => '0'); 
	signal p1_win_comb, p2_win_comb, p1_win_o, p2_win_o : std_logic := '0'; 

	type t_state is (gameplay, win, scored);
	signal state, next_state: t_state;

begin

    clocked_process : process(clk, reset)
    begin
        if ( reset = '1' ) then
			-- on reset, assign all outputs zero
            p1_win_o <= '0';
            p2_win_o <= '0';
            p1_score_o <= (others => '0');
            p2_score_o <= (others => '0');
			state <= gameplay;
        elsif ( rising_edge(clk) ) then
			state <= next_state;
			p1_score_o <= p1_score_comb;
			p2_score_o <= p2_score_comb;
			p1_win_o <= p1_win_comb;
			p2_win_o <= p2_win_comb;
		end if;
	end process clocked_process;

	combo_process : process(state, p1_hit, p2_hit, p1_win_o, p2_win_o, p1_score_o, p2_score_o)
		variable tmp_p1: unsigned(1 downto 0);
		variable tmp_p2: unsigned(1 downto 0);
	begin
		-- assign defaults
		p1_score_comb <= p1_score_o;
		p2_score_comb <= p2_score_o;
		p1_win_comb <= p1_win_o;
		p2_win_comb <= p2_win_o;
		next_state <= state;

		case ( state ) is
			when scored =>
				-- wait for reset or neither player hit
				if ( reset = '1' or ( (p1_hit = '0') and (p2_hit = '0')) ) then
					next_state <= gameplay;
				else
					next_state <= scored;
				end if; 
				-- hold values
				p1_score_comb <= p1_score_o;
				p2_score_comb <= p2_score_o;
				p1_win_comb <= p1_win_o;
				p2_win_comb <= p2_win_o;
			when gameplay =>
				-- update scores
				tmp_p1 := unsigned(p1_score_o) + unsigned'('0' & p2_hit);
				tmp_p2 := unsigned(p2_score_o) + unsigned'('0' & p1_hit);

				p1_score_comb <= std_logic_vector(tmp_p1);
				p2_score_comb <= std_logic_vector(tmp_p2);

				if (p1_hit='1') or (p2_hit='1') then
					-- a point was scored
					next_state <= scored;
				else
					next_State <= gameplay;
				end if;

				-- update winners and conditionally move to win state (allowing for ties)
				if (tmp_p1 >= win_score) then
					p1_win_comb <= '1';
					next_state <= win;
				else
					p1_win_comb <= '0';
				end if;
				if (tmp_p2 >= win_score) then
					p2_win_comb <= '1';
					next_state <= win;
				else
					p2_win_comb <= '0';
				end if;
			when win =>
				-- don't change anything
				p1_score_comb <= p1_score_o;
				p2_score_comb <= p2_score_o;
				p1_win_comb <= p1_win_o;
				p2_win_comb <= p2_win_o;
				-- stay in win state until reset
				next_state <= win;
			when others =>
				p1_score_comb <= p1_score_o;
				p2_score_comb <= p2_score_o;
				p1_win_comb <= p1_win_o;
				p2_win_comb <= p2_win_o;
				next_state <= gameplay;
		end case;
	end process combo_process;

	-- assign output ports from registered signals
	p1_score <= p1_score_o;
	p2_score <= p2_score_o;
	p1_win <= p1_win_o;
	p2_win <= p2_win_o;

end architecture behavior;
