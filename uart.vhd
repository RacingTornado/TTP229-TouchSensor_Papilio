----------------------------------------------------------------------------------
-- Company: Gadget Factory
-- Engineer: Jack Gassett
-- 
-- Create Date:    22:31:30 11/27/2010 
-- Design Name: 
-- Module Name:    UARTExample - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Example code for implementing the Xilinx UART example on the Papilio One.
--               http://www.xilinx.com/support/documentation/application_notes/xapp223.pdf
-- Dependencies: 
--						Requires the latest Picoblaze source code. Xilinx EULA does not allow the redistribution of Source code so the source modules must be downloaded seperately.
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UARTExample is
    Port ( rx : in  STD_LOGIC;
	        scl_12 : out STD_LOGIC;
			  reset: in STD_LOGIC;
           tx : out  STD_LOGIC;
			  extclk : in STD_LOGIC;
			  sdo : in STD_LOGIC;
			  go12 : out STD_LOGIC;
			  sdo_prev12 : out STD_LOGIC;
			  go1234 : out STD_LOGIC;
			  scl_clk : out STD_LOGIC
			  );
end UARTExample;



architecture Behavioral of UARTExample is
--Transmitter
component uart_tx is
  port (            data_in : in std_logic_vector(7 downto 0);
                 write_buffer : in std_logic;
                 reset_buffer : in std_logic;
                 en_16_x_baud : in std_logic;
                   serial_out : out std_logic;
                  buffer_full : out std_logic;
             buffer_half_full : out std_logic;
                          clk : in std_logic);
  end component; 
--Receiver component declaration
component uart_rx is
  port (      serial_in : in  STD_LOGIC;
                   read_buffer : in  STD_LOGIC;
           reset_buffer : in  STD_LOGIC;
           en_16_x_baud : in  STD_LOGIC;
                    clk : in  STD_LOGIC;
                   data_out : out STD_LOGIC_VECTOR (7 downto 0);
           buffer_data_present : out STD_LOGIC;
			  buffer_half_full : out STD_LOGIC;
            buffer_full : out STD_LOGIC);
  end component; 
 --clock declaration 
	COMPONENT dcm32to96
	PORT(
		CLKIN_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic
		);
	END COMPONENT;	
	
	COMPONENT clk32mHz
	PORT(
		extclk : IN std_logic;
		reset : IN std_logic;          
		scl : OUT std_logic
		);
	END COMPONENT;
	
--some signals
signal dout : STD_LOGIC_VECTOR (7 downto 0);
signal my_custom_half : STD_LOGIC_VECTOR(7 downto 0);
signal write_data: STD_LOGIC;
signal data_present, en_16_x_baud, clk: STD_LOGIC;
signal baud_count : integer range 0 to 5 :=0;
signal counter : integer range 0 to 255:=0;
signal my_custom : STD_LOGIC_VECTOR (14 downto 0);
signal buf_clk :STD_LOGIC;
signal go : STD_LOGIC;
signal bit_data : integer range 0 to  15:=1;
signal scl_count : integer range 0 to 15:=1;
signal some_counter : integer range 0 to 5:=0;
signal counter15 : integer range 0 to 30:=0;
signal exscl_temp: STD_LOGIC ;
signal exscl:STD_LOGIC;
signal sdo_prev : STD_LOGIC;
signal go1 : STD_LOGIC;
signal go1_prev :STD_LOGIC;
begin
--start a process
exscl<= exscl_temp and go1;
scl_12 <= exscl;
go12 <= go1;
go1234 <= go;
sdo_prev12 <= sdo_prev;
scl_clk <= exscl_temp;

baud_timer: process(clk)
begin
--if rising edge of clk
	if clk'event and clk='1' then
		if baud_count=1 then
			baud_count <= 0;
			en_16_x_baud <= '1';
		else
			baud_count <= baud_count + 1;
			en_16_x_baud <= '0';
		end if;
	end if;
end process baud_timer;


my_generate: process(clk)
begin
	if rising_edge(clk) then 
	 counter <= counter +1;
	end if;
end process my_generate;






my_data : process(buf_clk)
begin
		if(reset='0') then
			go<='0';
		elsif(buf_clk'event and buf_clk='1') then
			if(sdo_prev='0' and sdo='1') then	
					go<='1';
			elsif( counter15 >= 15) then
					go<='0';
			end if;
		end if;
end process my_data;


latch_my_data : process(buf_clk)
begin
	if(reset ='0') then
		sdo_prev <= '1';
	else
		if(rising_edge(buf_clk)) then
			sdo_prev<=sdo;
		end if;
	end if;
end process latch_my_data;


my_data_temp : process(exscl_temp,reset)
begin
	if(reset='0') then
		go1<='0';
	else
		if rising_edge(exscl_temp) then
			if(go='1') then
				counter15 <= counter15+1;
				go1<='1';
			elsif(counter15 >= 15) then
				counter15<=0;
				go1<='0';
			end if;
		end if;
	end if;
end process my_data_temp;

my_uart_get_data: process(exscl)
begin
	if(reset= '0') then
		my_custom <= "000000000000000";
	else
		if(rising_edge(exscl)) then 
			my_custom <= my_custom(my_custom'left-1 downto 0) & sdo;
		end if;
	end if;
end process my_uart_get_data;


latch_go1 : process(clk)
begin
	if(reset='0') then
	 go1_prev<= '0';
	else
		 if(rising_edge(clk)) then
			go1_prev<=go1;
		 end if;
	end if;
end process latch_go1;



uart_send : process(clk)
begin
	if (reset	='0') then
		my_custom_half <= "00000000";
		write_data <= '0';
   else
			if(rising_edge(clk)) then
				if (go1='0' and go1_prev='1') then
				 some_counter<=1;
				end if;
				if(some_counter =1 ) then
					my_custom_half <= my_custom(my_custom'left downto 7);
					write_data <= '1';
					some_counter <= some_counter + 1;
				end if;
				if (some_counter =2) then
					my_custom_half<=my_custom(6 downto 0) & '0';
					some_counter <= some_counter + 1;
				end if;
				if (some_counter >= 3) then
					some_counter<=0;
					--some_counter<=0;
					write_data<='0';
				end if;
			end if;
	end if;

	
end process uart_send;




 

--call the clock
	Inst_dcm32to96: dcm32to96 PORT MAP(
		CLKIN_IN => extclk,
		CLKFX_OUT => clk,
		CLKIN_IBUFG_OUT => buf_clk,
		CLK0_OUT => open
	);		
-- instantiate uart
INST_UART_TX : uart_tx
port map (
   data_in => my_custom_half,
   write_buffer => write_data,
   reset_buffer => '0',
   en_16_x_baud => en_16_x_baud,
   clk => clk,
   serial_out => tx,
	buffer_half_full => open,
   buffer_full => open
);
-- instantiate receiver
INST_UART_RX : uart_rx
port map (
   serial_in => rx,
   read_buffer => '1',
   reset_buffer => '0',
   en_16_x_baud => en_16_x_baud,
   clk => clk,
   data_out => dout,
   buffer_data_present => data_present,
	buffer_half_full => open,
	buffer_full => open
);

Inst_clk32mHz: clk32mHz PORT MAP(
		extclk => buf_clk,
		reset => reset,
		scl => exscl_temp
	);

end Behavioral;

