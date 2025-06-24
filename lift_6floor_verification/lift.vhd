
LIBRARY ieee;
USE ieee.std_logic_1164.all; 

ENTITY lift IS 
	PORT
	(   clk_in  : IN STD_LOGIC;--100MHz输入
	
		up1 :  IN  STD_LOGIC;--梯外按键，S0
		up2 :  IN  STD_LOGIC;--梯外按键，S1
		up3 :  IN  STD_LOGIC;
	    up4 :  IN  STD_LOGIC;
	    up5 :  IN  STD_LOGIC;
	    
	    down6:IN  STD_LOGIC;
	    down5:IN  STD_LOGIC;
	    down4:IN  STD_LOGIC;
	    down3:IN  STD_LOGIC;
		down2 :  IN  STD_LOGIC;--梯外按键，S2
		
		floor1 :  IN  STD_LOGIC;--梯内按键，SW1
		floor2 :  IN  STD_LOGIC;--梯内按键，SW2
		floor3 :  IN  STD_LOGIC;--梯内按键，SW3
		floor4:  IN  STD_LOGIC;
		floor5:  IN  STD_LOGIC;
		floor6:  IN  STD_LOGIC;
		led1 :  OUT  STD_LOGIC;--梯内目的楼层，高电平有效
		led2 :  OUT  STD_LOGIC;--梯内目的楼层，高电平有效
		led3 :  OUT  STD_LOGIC;--梯内目的楼层，高电平有效、
	    led4:OUT  STD_LOGIC;
	    led5:OUT  STD_LOGIC;
	    led6:OUT  STD_LOGIC;
	    
		door :  OUT  STD_LOGIC;--开门 LD10
        DEL  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);--数码管位选
        LEDAG: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       floor_num : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END lift;

ARCHITECTURE RTL OF lift IS 
SIGNAL floor_num_sig : STD_LOGIC_VECTOR(2 DOWNTO 0);

COMPONENT lift_ctrl
	PORT(clk :  IN  STD_LOGIC;--1KHz
		 up1 :  IN  STD_LOGIC;--梯外按键，S0
		up2 :  IN  STD_LOGIC;--梯外按键，S1
		up3 :  IN  STD_LOGIC;
	    up4 :  IN  STD_LOGIC;
	    up5 :  IN  STD_LOGIC;
	    
	    down6:IN  STD_LOGIC;
	    down5:IN  STD_LOGIC;
	    down4:IN  STD_LOGIC;
	    down3:IN  STD_LOGIC;
		down2 :  IN  STD_LOGIC;--梯外按键，S2
		
		floor1 :  IN  STD_LOGIC;--梯内按键，SW1
		floor2 :  IN  STD_LOGIC;--梯内按键，SW2
		floor3 :  IN  STD_LOGIC;--梯内按键，SW3
		floor4:  IN  STD_LOGIC;
		floor5:  IN  STD_LOGIC;
		floor6:  IN  STD_LOGIC;
		led1 :  OUT  STD_LOGIC;--梯内目的楼层，高电平有效
		led2 :  OUT  STD_LOGIC;--梯内目的楼层，高电平有效
		led3 :  OUT  STD_LOGIC;--梯内目的楼层，高电平有效、
	    led4:OUT  STD_LOGIC;
	    led5:OUT  STD_LOGIC;
	    led6:OUT  STD_LOGIC;
		 door : OUT STD_LOGIC;
		 floor_num : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END COMPONENT;

COMPONENT segment
	PORT(floor_num : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 DEL : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 LEDAG : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

--分频模块，100M分频到1KHz
COMPONENT fenping IS
   PORT (
      clk_in  : IN STD_LOGIC;--100MHz输入
      clk_1KHz  : OUT STD_LOGIC--1KHz输出
   );
END COMPONENT;

--SIGNAL	floor_num :  STD_LOGIC_VECTOR(2 DOWNTO 0);--楼层
SIGNAL	clk :  STD_LOGIC;--1KHz

BEGIN 
--分频模块，100M分频到1KHz
U_fenping : fenping
   PORT MAP(
      clk_in  => clk_in,--100MHz输入
      clk_1KHz => clk--1KHz输出
   );

-- 三层电梯控制模块 
U_lift_ctrl : lift_ctrl
PORT MAP(clk => clk,
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
		 floor_num => floor_num);

  --数码管显示控制模块
U_segment : segment
PORT MAP(floor_num => floor_num_sig,
		 DEL => DEL,
		 LEDAG => LEDAG);
-- 把内部信号连接到外部端口
--floor_num <= floor_num_sig;
--floor_num <= floor_num_sig;


END RTL;