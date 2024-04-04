-- Author: Group 12, Balaji Leninrajan, Kayla Chang
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_machine is port(
   clk, sm_clken              : in  std_logic;
   blink			               : in  std_logic;                    -- will allow the "green" light to blink for states 0-1 (NS) and 8-9 (EW)
   reset                      : in  std_logic;                    -- input to reset the current state
   ns_req, ew_req             : in  std_logic;                    -- gets pedestrian requests for both North/South and East/West
   ns_clr, ew_clr             : out std_logic;                    -- will reset the pedestrian request for NS and EW
   ns_crossing, ew_crossing   : out std_logic;                    -- output to show when pedestrians can cross for NS and EW
   sevenseg_ns, sevenseg_ew   : out std_logic_vector(6 downto 0); -- gives the output for the NS and EW traffic lights (blink, green, amber, red)
   state                      : out std_logic_vector(3 downto 0)  -- shows the current state of the state machine
);
end state_machine;

architecture SM of state_machine is

   type STATE_NAMES is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15);  -- list all the STATES
   signal current_state, next_state    : STATE_NAMES;

begin

   Register_Section: process(clk)
   begin
      if(rising_edge(clk)) then              -- only changes current state if clk has a rising edge
            if(reset = '1') then
               current_state <= S0;          -- resets current state to default (0) if reset is activated
            elsif(reset = '0') then
               if(sm_clken = '1')  then
                  current_state <= next_state;  -- if it is not reset, then the current states moves to the next states
               end if ;
            end if;
      end if;
   end process;

   Transition_Section: process(current_state)
   begin
      case current_state is
         when S0 =>
            if ew_req = '1' and ns_req = '0' then  -- will skip past the NS crossing to state 6 if there is an EW request and no NS request
               next_state <= S6;
            else
               next_state <= S1;                   -- if not, it just moves on to the next state
            end if;

         when S1 =>
            if ew_req = '1' and ns_req = '0' then  -- similar to state 0, it will check to see if there is only an EW request
               next_state <= S6;
            else
               next_state <= S2;
            end if;

         when S2 =>
            next_state <= S3; -- just moves on to the next state since it is a green light

         when S3 =>
            next_state <= S4; -- same as state 2

         when S4 =>
            next_state <= S5;

         when S5 =>
            next_state <= S6;

         when S6 =>
            next_state <= S7;

         when S7 =>
            next_state <= S8;

         when S8 =>
            if ns_req = '1' and ew_req = '0' then  -- checks if someone wants to cross NS and that no one wants to cross EW
               next_state <= S14;                  -- if so, it skips to state 14 in order for pedestrians to walk sooner
            else
               next_state <= S9;                   -- if not, it just moves on to state 9
            end if;

         when S9 =>
            if ns_req = '1' and ew_req = '0' then  -- similar to S8, but the difference is that it will move on to state 10 instead of state 9 if this condition isn't met
               next_state <= S14;
            else
               next_state <= S10;
            end if;

         when S10 =>
            next_state <= S11;   -- green light for EW; just moves on to next state

         when S11 =>
            next_state <= S12;   -- similar to S10; just moves on to next state
            
         when S12 =>
            next_state <= S13;

         when S13 =>
            next_state <= S14;
            
         when S14 =>
            next_state <= S15;

         when S15 =>
            next_state <= S0;

         when others =>
            next_state <= S0; -- if something goes wrong with the states, it resets to state 0
      end case;
   end process;

   Decoder_Section: process(current_state, blink)
   begin
      case current_state is
         when S0 =>
            state <= "0000";              -- makes the state equal the number of the current state

            if blink = '1' then
               sevenseg_ns <= "0000000";  -- if the blink signal is on, then the light will turn off
            else
               sevenseg_ns <= "0001000";  -- the green light will turn on. This way, it creates a blinking effect
            end if;
            ns_crossing <= '0';

            sevenseg_ew <= "0000001";     -- EW will stay red until state 8
            ew_crossing <= '0';

            ns_clr <= '0';                -- will not reset the pedestrian input for NS until state 6
            ew_clr <= '0';                -- will not reset the pedestrian input for EW until state E (14)

         when S1 =>                       -- same as S0, since NS is still blinking and EW is still red
            state <= "0001";

            if blink = '1' then
               sevenseg_ns <= "0000000";
            else
               sevenseg_ns <= "0001000";
            end if;
            ns_crossing <= '0';

            sevenseg_ew <= "0000001";
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '0';

         when S2 =>
            state <= "0010";

            sevenseg_ns <= "0001000";  -- NS traffic light stays a solid green
            ns_crossing <= '1';        -- pedestrians are allowed to cross for NS

            sevenseg_ew <= "0000001";  -- EW is zero
            ew_crossing <= '0';        -- pedestrians aren't allowed to cross across EW

            ns_clr <= '0';
            ew_clr <= '0';

         when S3 =>                    -- like S2; NS stays green and EW is red
            state <= "0011";

            sevenseg_ns <= "0001000";
            ns_crossing <= '1';

            sevenseg_ew <= "0000001";
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '0';

         when S4 =>                    -- like S2; NS stays green and EW is red
            state <= "0100";

            sevenseg_ns <= "0001000";
            ns_crossing <= '1';

            sevenseg_ew <= "0000001";
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '0';

         when S5 =>                    -- like S2; NS stays green and EW is red
            state <= "0101";

            sevenseg_ns <= "0001000";
            ns_crossing <= '1';

            sevenseg_ew <= "0000001";
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '0';

         when S6 =>
            state <= "0110";

            sevenseg_ns <= "1000000";  -- NS light becomes amber
            ns_crossing <= '0';        -- pedestrians are no longer allowed to cross

            sevenseg_ew <= "0000001";  -- EW stays red for now
            ew_crossing <= '0';

            ns_clr <= '1';             -- clears the NS holding register since the NS green light is over
            ew_clr <= '0';

         when S7 =>
            state <= "0111";

            sevenseg_ns <= "1000000";  -- NS light stays amber
            ns_crossing <= '0';

            sevenseg_ew <= "0000001";  -- EW stays red
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '0';

         when S8 =>
            state <= "1000";

            sevenseg_ns <= "0000001";     -- NS light turns red
            ns_crossing <= '0';

            if blink = '1' then           -- similar to S0 and S1, except the EW is blinking
               sevenseg_ew <= "0000000";
            else
               sevenseg_ew <= "0001000";
            end if;
            ew_crossing <= '0';           -- EW pedestrians are not allowed to cross yet

            ns_clr <= '0';                -- will not clear NS or EW. EW will be cleared after the EW green light is over (S14)
            ew_clr <= '0';

         when S9 =>                       -- similar to S8; NS light is still red and EW light is still blinking
            state <= "1001";

            sevenseg_ns <= "0000001";
            ns_crossing <= '0';

            if blink = '1' then
               sevenseg_ew <= "0000000";
            else
               sevenseg_ew <= "0001000";
            end if;
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '0';

         when S10 =>
            state <= "1010";

            sevenseg_ns <= "0000001";  -- NS stays red
            ns_crossing <= '0';

            sevenseg_ew <= "0001000";  -- EW is now green
            ew_crossing <= '1';        -- pedestrians crossing EW are allowed to walk

            ns_clr <= '0';
            ew_clr <= '0';

         when S11 =>                   -- similar to S10; NS is red and EW is green
            state <= "1011";

            sevenseg_ns <= "0000001";
            ns_crossing <= '0';

            sevenseg_ew <= "0001000";
            ew_crossing <= '1';

            ns_clr <= '0';
            ew_clr <= '0';

         when S12 =>                   -- similar to S10; NS is red and EW is green
            state <= "1100";

            sevenseg_ns <= "0000001";
            ns_crossing <= '0';

            sevenseg_ew <= "0001000";
            ew_crossing <= '1';

            ns_clr <= '0';
            ew_clr <= '0';

         when S13 =>                   -- similar to S10; NS is red and EW is green
            state <= "1101";

            sevenseg_ns <= "0000001";
            ns_crossing <= '0';

            sevenseg_ew <= "0001000";
            ew_crossing <= '1';

            ns_clr <= '0';
            ew_clr <= '0';

         when S14 =>
            state <= "1110";

            sevenseg_ns <= "0000001";  -- NS is red
            ns_crossing <= '0';

            sevenseg_ew <= "1000000";  -- EW turns amber
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '1';             -- since EW is no longer green, EW holding register gets cleared
            
         when S15 =>                   -- similar to S14, where NS is red and EW is amber. However, EW is already cleared in S14
            state <= "1111";

            sevenseg_ns <= "0000001";
            ns_crossing <= '0';

            sevenseg_ew <= "1000000";
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '0';

         when others =>                -- should not be in this state. If something goes funky, no lights will turn on for the traffic lights and the pedetrian lights will be off
            sevenseg_ns <= "0000000";
            ns_crossing <= '0';

            sevenseg_ew <= "0000000";
            ew_crossing <= '0';

            ns_clr <= '0';
            ew_clr <= '0';

      end case;
   end process;

end architecture SM;
