-- MODEL modules

-- tank (two instances)
-- inputs: speed (signed), game_tick
-- generics: y position, color
-- outputs: x position, y position
-- notes: will have two instances

-- bullet (two instances)
-- inputs: intial x position, intial y position, write-enable, speed (signed), game_tick
-- generics: color
-- outputs: x position, y position
-- notes: will have two instances

-- VIEW modules



-- CONTROLLER modules



-- ideas:
-- make char buffer a (constant sized) input to the LCD
-- instead of signed speeds (aka velocity), do magnitudes + a direction bit 
	-- all module IO needs to be std_logic or std_logic_vector anyway

-- questions
	-- is dataflow as the final thing to combine all the modutles at the end the right approach?
	-- how to use PLL? (sys clock to our faster clock)
	-- VGA doesn't work
	