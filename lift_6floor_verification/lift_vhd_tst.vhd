LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY lift_vhd_tst IS
END lift_vhd_tst;

ARCHITECTURE lift_arch OF lift_vhd_tst IS
-- signals                                                    
SIGNAL clk: STD_LOGIC;
SIGNAL DEL : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL door : STD_LOGIC;
SIGNAL floor_num_tb : STD_LOGIC_VECTOR(2 DOWNTO 0);

SIGNAL LEDAG : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL down2, down3, down4, down5, down6 : STD_LOGIC;

SIGNAL up1, up2, up3, up4, up5 : STD_LOGIC;

SIGNAL floor1, floor2, floor3, floor4, floor5, floor6 : STD_LOGIC;

SIGNAL led1, led2, led3, led4, led5, led6 : STD_LOGIC;


COMPONENT lift
PORT (
    floor_num:out STD_LOGIC_VECTOR(2 DOWNTO 0);
	clk_in : IN  STD_LOGIC;
	DEL : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	LEDAG : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
 	up1, up2, up3, up4, up5         : IN  STD_LOGIC;
	down2, down3, down4, down5, down6 : IN  STD_LOGIC;
	floor1, floor2, floor3, floor4, floor5, floor6 : IN  STD_LOGIC;
	led1, led2, led3, led4, led5, led6 : OUT STD_LOGIC;
	door      : OUT STD_LOGIC
);
END COMPONENT;


BEGIN
    i1: lift port map
    (clk_in => clk,
    DEL => DEL,
		 up1 => up1,
		 up2 => up2,
		 up3 => up3,
		 up4 => up4,
		 up5 => up5,
		 down2 => down2,
		 down3 => down3,
		 down4 => down4,
		 down5 => down5,
		 down6 => down6,
		 floor1 => floor1,
		 floor2 => floor2,
		 floor3 => floor3,
		 floor4 => floor4,
		 floor5 => floor5,
		 floor6 => floor6,
		 led1 => led1,
		 led2 => led2,
		 led3 => led3,
		 led4 => led4,
		 led5 => led5,
		 led6 => led6,
		 door => door,
		 LEDAG => LEDAG,
		 floor_num =>floor_num_tb
		 );
    init: Process
    begin

	up1 <= '0'; up2 <= '0'; up3 <= '0'; up4 <= '0'; up5 <= '0';
	down2 <= '0'; down3 <= '0'; down4 <= '0'; down5 <= '0'; down6 <= '0';
	floor1 <= '0'; floor2 <= '0'; floor3 <= '0'; floor4 <= '0'; floor5 <= '0'; floor6 <= '0';
wait for 600000 ns;
	down6 <='1';--电梯外3楼按-下方向键
wait for 10000 ns;
    down6 <='0';

wait for 800000 ns;
	floor2 <='1';--电梯内按下2楼
wait for 10000 ns;
    floor2 <='0';	
	
wait for 2000000 ns;

wait for 200000 ns;
	up1 <='1';--电梯外1楼按-上方向键
wait for 10000 ns;
    up1 <='0';

wait for 200000 ns;
	floor3 <='1';--电梯内按下3楼
wait for 10000 ns;
    floor3 <='0';	
WAIT;                                                       
END PROCESS init;    


--产生100MHz时钟			   
always : PROCESS                                                                                  
BEGIN                                                         
clk<='1';
wait for 5 ns;
clk<='0';
wait for 5 ns;                                                       
END PROCESS always;                                          

END lift_arch;
