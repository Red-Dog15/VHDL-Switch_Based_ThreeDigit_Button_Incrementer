-- Converts binary coded decimal to seven segment code for DE1-SoC 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ssegPackage.all;



entity ThreeDigitTallyCounter is port 
(
        button, reset, clk : in std_logic;   
        sseg0, sseg1, sseg2 : out std_logic_vector(7 downto 0);
        sw0, sw1, sw2 : in std_logic;
		  led0, led1, led2 : out std_logic -- output LEDs representing states
);
end ThreeDigitTallyCounter;





	
-- architecture
architecture behavior of ThreeDigitTallyCounter is

    -- Build an enumerated type for the state machine
    type state_type is (s0, s1, s2);

    -- Register to hold the current state
    signal state : state_type := s0;

    -- Timer
    signal timer : integer range 0 to 175000000 := 0;

    -- Counter
    signal counter : unsigned(11 downto 0) := (others => '0');

    -- BCD output
    signal bcd : std_logic_vector(15 downto 0);

    -- Clock alias
    signal clk_50 : std_logic;

    -- Counter multiplier
    signal counter_multiplier : integer range 0 to 111 := 0;

    -- Switch registers
    signal sw_reg0, sw_reg1, sw_reg2 : std_logic := '0';
	 
	 -- flip_flop signals
	 signal btn_sync1, btn_sync2 : std_logic := '1';
	 signal sw0_sync1, sw0_sync2 : std_logic := '1';
	 signal sw1_sync1, sw1_sync2 : std_logic := '1';
	 signal sw2_sync1, sw2_sync2 : std_logic := '1';

	 signal btn_timer : integer range 0 to 50000 := 0;
	 signal btn_stable : std_logic := '1';

begin
	-- flip flop syncronizer
	process(clk)
	begin
		if rising_edge(clk) then
		
			btn_sync1 <= button;
			btn_sync2 <= btn_sync1;
			
			sw0_sync1 <= sw0; 
			sw0_sync2 <= sw0_sync1;
			
			sw1_sync1 <= sw1;
			sw1_sync2 <= sw1_sync1;
			
			sw2_sync1 <= sw2;
			sw2_sync2 <= sw2_sync1;
			
		end if;
	end process;

	-- debouncer

	process (clk)
	begin
		if rising_edge(clk) then
			if btn_sync2 /= btn_stable then -- initiate timer for debounce
				btn_timer <= btn_timer + 1;
				if btn_timer > 50000 then -- 10ms
					btn_stable <= btn_sync2;
					btn_timer <= 0;
				end if;
			else
				btn_timer <= 0;
			end if;
		end if;
	end process;
				
	
    clk_50 <= clk;

    threeDigit : doubleDabble
        port map (
            clk => clk_50,
            binaryIn => counter,
            bcd => bcd
        );

    ssegOnes  : ssegDecoder port map (binaryIn => bcd(3 downto 0), ssegOut => sseg0);
    ssegTens  : ssegDecoder port map (binaryIn => bcd(7 downto 4), ssegOut => sseg1);
    ssegHunds : ssegDecoder port map (binaryIn => bcd(11 downto 8), ssegOut => sseg2);

    process (clk, reset)
    begin
		  if reset = '0' then -- check for reset button press
			  state <= s2;
			  timer <= 0;
			  
        elsif rising_edge(clk) then
            case state is
                when s0 =>
							  
                    if btn_stable = '0' then -- check for button press
                        if (sw0 = '0') and (sw_reg0 = '0') then
                            counter_multiplier <= counter_multiplier + 1;
                            sw_reg0 <= '1';
                        end if;

                        if (sw1 = '0') and (sw_reg1 = '0') then
                            counter_multiplier <= counter_multiplier + 10;
                            sw_reg1 <= '1';
                        end if;

                        if (sw2 = '0') and (sw_reg2 = '0') then
                            counter_multiplier <= counter_multiplier + 100;
									 sw_reg2 <= '1';
                        end if;
								
								if counter_multiplier > 0 then
									
									counter <= counter + to_unsigned(counter_multiplier, counter'length);  -- increment counter
									counter_multiplier <= 0;
									sw_reg0 <= '0';
									sw_reg1 <= '0';
									sw_reg2 <= '0';

								end if;
								
                        if to_integer(counter) >= 999 then
                            counter <= (others => '0');
                        end if;
								
								state <= s1; --switch to state 1
                    else
                        state <= s0;
                    end if;

                when s1 =>
                    if btn_stable = '1' then -- checks if button was released
                        state <= s0;
                    else
                        state <= s1;
                    end if;

                when s2 =>
                    if reset = '1' then
                        timer <= 0;
                        state <= s0;
                    elsif (timer < 15000000) then
                        timer <= timer + 1;
                    else
                        counter <= (others => '0');
                        timer <= 0;
                    end if;
            end case;
        end if;
    end process;
	 	-- Determine the output based only on the current state
	-- and the input (do not wait for a clock edge).
	process (state)
	begin
			case state is
				when s0=>
					led0 <= '1';
					led1 <= '0';
					led2 <= '0';
				when s1=>
					led0 <= '0';
					led1 <= '1';
					led2 <= '0';
					
				when s2=>
					led0 <= '0';
					led1 <= '0';
					led2 <= '1';
					
			end case;
	end process;
end behavior;
