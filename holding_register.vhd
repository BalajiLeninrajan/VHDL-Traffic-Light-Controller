-- Author: Group 12, Balaji Leninrajan, Kayla Chang

-- *****************************************************************
-- *  Register that holds value even when input signal is changed  *
-- *****************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity holding_register is port (
	clk            : in  std_logic;
	reset          : in  std_logic;
	register_clr   : in  std_logic;
	din				: in  std_logic;
	dout				: out std_logic
);
end holding_register;

architecture circuit of holding_register is

   signal sreg   : std_logic;

begin

   Register_logic: process(clk)
   begin
      if(rising_edge(clk)) then
            -- D flip-flop
            if((sreg='1' or din='1') and (reset='0' and register_clr='0')) then
               sreg <= '1'; -- set register to 1 when D flip-flop output is 1 or input is 1
            else
               sreg <= '0'; -- reset register
            end if;
      end if;

      dout <= sreg; -- output from D flip-flop
      
   end process;

end circuit;
