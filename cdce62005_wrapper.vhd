----------------------------------------------------------------------------------
-- Company			: Research Institute of Precision Instruments
-- Engineer			: Kosinov Alexey
-- Create Date		: 08:55:00 12/03/2018
-- Target Devices	: Virtex-6 (XC6VSX315T-2FF1759)
-- Tool versions	: ISE Design 14.7
-- Description		: CDCE62005 SPI Interface 
--					: Fully Configurable Register Map - CDCE62005_Register_Map.xlsx
----------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity cdce62005 is
	port(
		CLK_IN		: in std_logic;
		RST_IN		: in std_logic;
		RW_IN		: in std_logic;
		ADDR_IN		: in std_logic_vector (3 downto 0);
		DATA_OUT	: out std_logic_vector (31 downto 0); 
		nPD_OUT 	: out std_logic;
		nSYNC_OUT 	: out std_logic;
		MISO_IN 	: in  std_logic;
		SCLK_OUT 	: out std_logic;
		LE_OUT 		: out std_logic;
		MOSI_OUT 	: out std_logic
	);
end entity;

architecture rtl of cdce62005 is

	type memory is array (0 to 11) of std_logic_vector (31 downto 0);                 
	constant ROM : memory := (
--		X"0000001F",	-- Unlock EEPROM
--		X"68860320", 	-- REG0
--		X"68860301", 	-- REG1
--		X"EB860302", 	-- REG2
--		X"EB860303", 	-- REG3
--		X"EB060314", 	-- REG4
--		X"34000A75", 	-- REG5
--		X"04BF04E6", 	-- REG6
--		X"95913DE7",	-- REG7
--		X"0000A03F",	-- Lock EEPROM
--		X"00000000",	-- Null
--		X"00000000"		-- Null
		
		X"68860320", 	-- REG0
		X"68860301", 	-- REG1
		X"EB860302", 	-- REG2
		X"EB860303", 	-- REG3
		X"EB060314", 	-- REG4
		X"34000A75", 	-- REG5
		X"04BF04E6", 	-- REG6
		X"95913DE7",	-- REG7
		X"0000007E",	-- Null
		X"0000008E",	-- Null
		X"00000000",	-- Null
		X"00000000"		-- Null
	);
	
	attribute rom_style : string;
	attribute rom_style of ROM : constant is "block";

	type fsm_rd is (idle, read_start, read_w0, read_w1, read_w2, read_w3, read_w4, read_back, read_stop);
	signal states : fsm_rd;

	signal sclk_i		: std_logic;
	signal sclk_run_i	: std_logic;
	signal sclk_run_t	: std_logic;
	
	signal le_i			: std_logic;
	signal le_t			: std_logic;
	
	signal mosi_i		: std_logic;
	signal mosi_t		: std_logic;
	
	signal mosi_r		: std_logic_vector(31 downto 0) := (others => '0');
	
	signal ct_startup : std_logic_vector(10 downto 0) := (others => '0');

	alias  ct_bit     : std_logic_vector(5 downto 0) is ct_startup(5 downto 0);
	alias  ct_word    : std_logic_vector(3 downto 0) is ct_startup(9 downto 6);
	
	signal ct_bit_t 	: integer range 0 to 31 := 0;
	
begin

	sclk_i 		<= CLK_IN;
	nPD_OUT		<= '1';
	nSYNC_OUT	<= '1';
	
	process (ADDR_IN)
	begin
		case ADDR_IN is 
			when "0000" =>
				mosi_r <= X"0000000E";
			when "0001" =>
				mosi_r <= X"0000001E";
			when "0010" =>
				mosi_r <= X"0000002E";
			when "0011" =>
				mosi_r <= X"0000003E";
			when "0100" =>
				mosi_r <= X"0000004E";
			when "0101" =>
				mosi_r <= X"0000005E";
			when "0110" =>
				mosi_r <= X"0000006E";
			when "0111" =>
				mosi_r <= X"0000007E"; -- R7.26 = EPLOCK: 0 for unlocked, else EEPROM locked
			when others => 
				mosi_r <= X"0000008E"; -- R8.6 = PLL locked when 1; R8.7 = Sleep mode when 0; R8.8 = Synchronization State
		end case;
	end process;
	
	
	-- READ
	process (sclk_i, RST_IN, RW_IN)
	begin
		if (RST_IN = '1' or RW_IN = '0') then
			mosi_i		<= '0';
			le_i		<= '1';
			sclk_run_i 	<= '0';
			ct_bit_t	<= 0;
			states 		<= idle;
		elsif (falling_edge(sclk_i)) then
				
				case states is
					when idle =>
						mosi_i		<= '0';
						sclk_run_i 	<= '0';
						le_i		<= '1';
						ct_bit_t	<= 0;
						states 		<= read_start;
					
					when read_start =>
						mosi_i 		<= mosi_r(ct_bit_t);
						sclk_run_i 	<= '1';
						le_i		<= '0';
						if (ct_bit_t = 31) then 
							states	<= read_w0;
						else 
							ct_bit_t	<= ct_bit_t + 1;
							states		<= read_start;
						end if;	
						
					when read_w0 =>			
						le_i		<= '1';
						mosi_i		<= '0';
						sclk_run_i 	<= '0';
						ct_bit_t	<= 0;
						states		<= read_w1;

					when read_w1 =>			
						le_i		<= '1';
						mosi_i		<= '0';
						sclk_run_i 	<= '0';
						states		<= read_w2;
						
					when read_w2 =>			
						le_i		<= '1';
						mosi_i		<= '0';
						sclk_run_i 	<= '0';
						states		<= read_w3;
						
					when read_w3 =>			
						le_i		<= '1';
						mosi_i		<= '0';
						sclk_run_i 	<= '0';
						states		<= read_w4;
						
					when read_w4 =>			
						le_i		<= '1';
						mosi_i		<= '0';
						sclk_run_i 	<= '0';
						states		<= read_back;

					when read_back =>
						DATA_OUT(ct_bit_t) <= MISO_IN;
						le_i 		<= '0';
						sclk_run_i 	<= '1';
						if (ct_bit_t = 31) then 
							states	<= read_stop;
						else 
							ct_bit_t 	<= ct_bit_t + 1;
							states		<= read_back;
						end if;	

					when read_stop => 
						mosi_i 		<= '0'; 
						sclk_run_i 	<= '0';
						le_i 		<= '1';						
				
				end case;			
		end if;
	end process;


	-- WRITE
	process(sclk_i, RST_IN, RW_IN)
	begin
		if (RST_IN = '1' or RW_IN = '1') then
			mosi_t			<= '0';
			le_t			<= '1';
			sclk_run_t		<= '0';
			ct_startup 		<= (others => '0');
		elsif falling_edge(sclk_i) then
			if (ct_startup(ct_startup'high) /= '1' and ct_word /= X"A") then
				ct_startup <= ct_startup + 1;
				case conv_integer(ct_bit) is
					when 0 to 31 =>
						le_t		<= '0';
						sclk_run_t	<= '1';
						mosi_t 		<= ROM(conv_integer(ct_word))(conv_integer(ct_bit));
					when others =>
						le_t		<= '1';
						sclk_run_t	<= '0';
						mosi_t 		<= '0';
				end case;
			end if;
		end if;
	end process;

	MOSI_OUT 	<= mosi_i 	when RW_IN = '1' else mosi_t;
	LE_OUT		<= le_i 	when RW_IN = '1' else le_t;
	SCLK_OUT 	<= sclk_i	when sclk_run_t = '1' or sclk_run_i = '1' else '0';

end architecture;
