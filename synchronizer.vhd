-- Author: Group 12, Balaji Leninrajan, Kayla Chang

-- ****************************************
-- *  Synchronizes inputs to gobal clock  *
-- ****************************************

library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is port (
   clk		: in    std_logic;
   reset	   : in    std_logic;
   din		: in    std_logic;
   dout     : out   std_logic
);
end synchronizer;

architecture circuit of synchronizer is

   signal sreg     : std_logic_vector(1 downto 0);

begin

   Synchronizer_Logic: process(clk)
   begin
      if(rising_edge(clk)) then
         if(reset = '1') then
            -- reset registers to 0 when reset signal is active
            sreg <= "00";

         else
            -- second D flip-flop
            if(sreg(0) = '1') then
               sreg(1) <= '1';
            else
               sreg(1) <= '0';
            end if;

            -- first D flip-flop
            if(din = '1') then
               sreg(0) <= '1';
            else
               sreg(0) <= '0';
            end if;

         end if;
      end if;

      dout <= sreg(1); -- output from second flip flop

   end process;

end circuit;
