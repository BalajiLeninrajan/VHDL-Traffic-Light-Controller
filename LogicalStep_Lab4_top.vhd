-- Author: Group 12, Balaji Leninrajan, Kayla Chang
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LogicalStep_Lab4_top is port (
   clkin_50    	: in     std_logic;							-- The 50 MHz FPGA Clockinput
   rst_n       	: in     std_logic;							-- The RESET input (ACTIVE LOW)
   pb_n        	: in     std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
   sw          	: in     std_logic_vector(7 downto 0); -- The switch inputs
   leds        	: out 	std_logic_vector(7 downto 0); -- for displaying the the lab4 project details
   -------------------------------------------------------------
   -- you can add temporary output ports here if you need to debug your design 
   -- or to add internal signals for your simulations
   -------------------------------------------------------------
   seg7_data   	: out    std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
   seg7_char1  	: out	   std_logic;							-- seg7 digi selectors
   seg7_char2  	: out	   std_logic;							-- seg7 digi selectors
	sm_clken_out	: out		std_logic;
	blink_sig_out	: out		std_logic;
	ns_seg_a			: out		std_logic;
	ns_seg_d			: out		std_logic;
	ns_seg_g			: out		std_logic;
	ew_seg_a			: out		std_logic;
	ew_seg_d			: out		std_logic;
	ew_seg_g			: out		std_logic
);
end LogicalStep_Lab4_top;

architecture SimpleCircuit of LogicalStep_Lab4_top is

   component segment7_mux port (
      clk     : in  	std_logic := '0';
      DIN2    : in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
      DIN1    : in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
      DOUT    : out	std_logic_vector(6 downto 0);
      DIG2    : out	std_logic;
      DIG1    : out	std_logic
   );
   end component;

   component clock_generator port (
      sim_mode    : in    boolean;
      reset       : in    std_logic;
      clkin       : in    std_logic;
      sm_clken    : out   std_logic;
      blink       : out   std_logic
   );
   end component;

   component pb_filters port (
      clkin			      : in     std_logic;
      rst_n			      : in     std_logic;
      rst_n_filtered    : out    std_logic;
      pb_n			      : in     std_logic_vector (3 downto 0);
      pb_n_filtered     : out	   std_logic_vector(3 downto 0)							 
   );
   end component;

   component pb_inverters port (
      rst_n			   : in     std_logic;
      rst				: out	   std_logic;							 
      pb_n_filtered  : in     std_logic_vector (3 downto 0);
      pb				   : out	   std_logic_vector(3 downto 0)							 
   );
   end component;

   component synchronizer port(
      clk      : in    std_logic;
      reset	   : in    std_logic;
      din		: in    std_logic; -- enable signal
      dout	   : out   std_logic  -- synchronized output
   );
   end component;

   component holding_register port (
      clk				: in    std_logic;
      reset			   : in    std_logic;
      register_clr   : in    std_logic; -- clears register
      din				: in    std_logic; -- sets register
      dout			   : out   std_logic  -- value stored in register
   );
   end component;

   component state_machine port(
      clk, sm_clken              : in     std_logic;
      blink			               : in		std_logic;
      reset		                  : in	   std_logic;
      ns_req, ew_req             : in     std_logic;                    -- cross request signals
      ns_clr, ew_clr             : out    std_logic;                    -- holding register clear signals
      ns_crossing, ew_crossing   : out		std_logic;                    -- crossing status
      sevenseg_ns, sevenseg_ew   : out    std_logic_vector(6 downto 0); -- ;ights (input to segment7_mux)
      state                      : out    std_logic_vector(3 downto 0)  -- current state
   );
   end component;

   constant sim_mode						         : boolean := TRUE; -- set to FALSE for LogicalStep board downloads -- set to TRUE for SIMULATIONS
   signal   rst, rst_n_filtered, synch_rst   : std_logic;
   signal   sm_clken, blink_sig				   : std_logic; 
   signal   pb_n_filtered, pb				      : std_logic_vector(3 downto 0);

   signal   synch_ew, synch_ns               : std_logic;
   signal   sevenseg_ns, sevenseg_ew         : std_logic_vector(6 downto 0);  -- Lights (input to segment7_mux)
	signal	ns_req, ew_req							: std_logic;                     -- Cross request signals
	signal	ns_clr, ew_clr							: std_logic;                     -- Holding register clear signals

begin

   INST0:   pb_filters			port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
   INST1:   pb_inverters	   port map (rst_n_filtered, rst, pb_n_filtered, pb);
   INST2:   synchronizer      port map (clkin_50, synch_rst, rst, synch_rst);	-- the synchronizer is also reset by synch_rst.
   INST3:   clock_generator   port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);
	
   INST4:   synchronizer      port map (clkin_50, synch_rst, pb(0), synch_ns);            -- synchronized input to NS cross request
   INST5:   synchronizer      port map (clkin_50, synch_rst, pb(1), synch_ew);            -- synchronized input to EW cross request
   INST6:   holding_register  port map (clkin_50, synch_rst, ns_clr, synch_ns, ns_req);   -- register to store NS cross request
   INST7:   holding_register  port map (clkin_50, synch_rst, ew_clr, synch_ew, ew_req);   -- register to store EW cross request
	
   INST8:   state_machine     port map (
                                          clkin_50, sm_clken,        -- state machine clock enable
                                          blink_sig,                 -- blink clock
                                          synch_rst,                 -- synchronized reset signal
                                          ns_req, ew_req,            -- synchronized cross requests
                                          ns_clr, ew_clr,            -- holding register clear signals
                                          leds(0), leds(2),          -- crossing status
                                          sevenseg_ns, sevenseg_ew,  -- lights (input to segment7_mux)
                                          leds(7 downto 4)           -- current state
                                       );

   INST9:   segment7_mux      port map (clkin_50, sevenseg_ew, sevenseg_ns, seg7_data, seg7_char2, seg7_char1);

   leds(1) <= ns_req; -- NS cross request
	leds(3) <= ew_req; -- EW cross request
	
   --*************************
   --*  FOR SIMULATION ONLY  *
   --*************************

	sm_clken_out <= sm_clken;     -- state machine clock enable
	blink_sig_out <= blink_sig;   -- blink clock
	
	ns_seg_a <= sevenseg_ns(6);   -- NS red light
	ns_seg_g <= sevenseg_ns(0);   -- NS amber light
	ns_seg_d <= sevenseg_ns(3);   -- NS green light
	ew_seg_a <= sevenseg_ew(6);   -- EW red light
	ew_seg_g <= sevenseg_ew(0);   -- EW amber light
	ew_seg_d <= sevenseg_ew(3);   -- EW green light

end SimpleCircuit;
