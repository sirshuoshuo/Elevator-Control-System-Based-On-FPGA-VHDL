
LIBRARY ieee;
USE ieee.std_logic_1164.all; 

ENTITY lift IS 
	PORT
	(   clk_in  : IN STD_LOGIC;--100MHz����
	
		up1 :  IN  STD_LOGIC;--���ⰴ����S0
		up2 :  IN  STD_LOGIC;--���ⰴ����S1
		up3 :  IN  STD_LOGIC;
	    up4 :  IN  STD_LOGIC;
	    up5 :  IN  STD_LOGIC;
	    
	    down6:IN  STD_LOGIC;
	    down5:IN  STD_LOGIC;
	    down4:IN  STD_LOGIC;
	    down3:IN  STD_LOGIC;
		down2 :  IN  STD_LOGIC;--���ⰴ����S2
		
		floor1 :  IN  STD_LOGIC;--���ڰ�����SW1
		floor2 :  IN  STD_LOGIC;--���ڰ�����SW2
		floor3 :  IN  STD_LOGIC;--���ڰ�����SW3
		floor4:  IN  STD_LOGIC;
		floor5:  IN  STD_LOGIC;
		floor6:  IN  STD_LOGIC;
		led1 :  OUT  STD_LOGIC;--����Ŀ��¥�㣬�ߵ�ƽ��Ч
		led2 :  OUT  STD_LOGIC;--����Ŀ��¥�㣬�ߵ�ƽ��Ч
		led3 :  OUT  STD_LOGIC;--����Ŀ��¥�㣬�ߵ�ƽ��Ч��
	    led4:OUT  STD_LOGIC;
	    led5:OUT  STD_LOGIC;
	    led6:OUT  STD_LOGIC;
	    
		door :  OUT  STD_LOGIC;--���� LD10
        DEL  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);--�����λѡ
        LEDAG: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       floor_num : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END lift;

ARCHITECTURE RTL OF lift IS 
SIGNAL floor_num_sig : STD_LOGIC_VECTOR(2 DOWNTO 0);

COMPONENT lift_ctrl
	PORT(clk :  IN  STD_LOGIC;--1KHz
		 up1 :  IN  STD_LOGIC;--���ⰴ����S0
		up2 :  IN  STD_LOGIC;--���ⰴ����S1
		up3 :  IN  STD_LOGIC;
	    up4 :  IN  STD_LOGIC;
	    up5 :  IN  STD_LOGIC;
	    
	    down6:IN  STD_LOGIC;
	    down5:IN  STD_LOGIC;
	    down4:IN  STD_LOGIC;
	    down3:IN  STD_LOGIC;
		down2 :  IN  STD_LOGIC;--���ⰴ����S2
		
		floor1 :  IN  STD_LOGIC;--���ڰ�����SW1
		floor2 :  IN  STD_LOGIC;--���ڰ�����SW2
		floor3 :  IN  STD_LOGIC;--���ڰ�����SW3
		floor4:  IN  STD_LOGIC;
		floor5:  IN  STD_LOGIC;
		floor6:  IN  STD_LOGIC;
		led1 :  OUT  STD_LOGIC;--����Ŀ��¥�㣬�ߵ�ƽ��Ч
		led2 :  OUT  STD_LOGIC;--����Ŀ��¥�㣬�ߵ�ƽ��Ч
		led3 :  OUT  STD_LOGIC;--����Ŀ��¥�㣬�ߵ�ƽ��Ч��
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

--��Ƶģ�飬100M��Ƶ��1KHz
COMPONENT fenping IS
   PORT (
      clk_in  : IN STD_LOGIC;--100MHz����
      clk_1KHz  : OUT STD_LOGIC--1KHz���
   );
END COMPONENT;

--SIGNAL	floor_num :  STD_LOGIC_VECTOR(2 DOWNTO 0);--¥��
SIGNAL	clk :  STD_LOGIC;--1KHz

BEGIN 
--��Ƶģ�飬100M��Ƶ��1KHz
U_fenping : fenping
   PORT MAP(
      clk_in  => clk_in,--100MHz����
      clk_1KHz => clk--1KHz���
   );

-- ������ݿ���ģ�� 
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

  --�������ʾ����ģ��
U_segment : segment
PORT MAP(floor_num => floor_num_sig,
		 DEL => DEL,
		 LEDAG => LEDAG);
-- ���ڲ��ź����ӵ��ⲿ�˿�
--floor_num <= floor_num_sig;
--floor_num <= floor_num_sig;


END RTL;