LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity cdce62005_tb is
end entity;
 
architecture RTL of cdce62005_tb is
 
	component cdce62005
		port(
			CLK	: in	std_logic;
			RST	: in	std_logic;
			RW		: in 	std_logic;
			ADDR	: in	std_logic_vector (3 downto 0);
			DATA	: out	std_logic_vector (31 downto 0); 
			nPD 	: out std_logic;
			nSYNC : out std_logic;
			MISO 	: in  std_logic;
			SCLK 	: out std_logic;
			LE 	: out std_logic;
			MOSI 	: out std_logic
		);
	end component;


	signal miso 	: std_logic;
	signal rw		: std_logic := '0';
	signal clk 		: std_logic := '0';
	signal rst 		: std_logic := '0';
	signal sclk 	: std_logic := '0';
	signal npd 		: std_logic := '0';
	signal nsync 	: std_logic := '0';
	signal le 		: std_logic := '0';
	signal mosi 	: std_logic := '0';
	signal addr		: std_logic_vector (3 downto 0);	
	signal data 	: std_logic_vector (31 downto 0); 

	constant clk_t : time := 80 ns;

 
begin

	UUT: cdce62005 
		port map(
			CLK 		=> clk,
			RST 		=> rst,
			RW			=> rw,
			MISO		=> miso,
			ADDR		=> addr,
			DATA		=> data,
			SCLK 		=> sclk,
			LE 		=> le,
			MOSI 		=> mosi,
			nPD 		=> npd,
			nSYNC 	=> nsync
		);

	
	MISO <= MOSI;
	
	process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;
	 
   process
   begin
		CLK <= '0';
		wait for clk_t/2;
		CLK <= '1';
		wait for clk_t/2;
   end process;

   process
   begin		
		wait until RST = '0';
		wait until rising_edge(CLK);
		rw <= '0';
		
      wait;
   end process;

end;