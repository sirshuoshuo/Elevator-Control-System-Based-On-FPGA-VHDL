-- 三层电梯控制模块 
library ieee;
use ieee.std_logic_1164.all;
entity lift_ctrl is
port(
	 clk:in std_logic;--1KHz
	 up1,up2,up3,up4,up5,down2,down3,down4,down5,down6:in std_logic;--梯外按键，
	 floor1,floor2,floor3,floor4,floor5,floor6:in std_logic;--梯内按键，
     led1,led2,led3,led4,led5,led6:out std_logic;--梯内目的楼层，高电平有效
     door:out std_logic;--开门
	 floor_num: out std_logic_vector(2 downto 0)--楼层
	 );
end entity lift_ctrl;

architecture behave of lift_ctrl is

type stateTYPE is(c1,c2,c3,c4,c5,c6,open_door);

begin

--电梯控制进程
  process(clk)
  variable up,down,goal:std_logic_vector(6 downto 1):="000000";
  variable storey:std_logic_vector(2 downto 0):="000";
  variable mo:std_logic:='0';--mo控制方向，低电平表示上
  variable clk_cnt,time_cnt:integer:=0;
  variable state:stateTYPE:=c1;
  variable x,y,z:std_logic:='0';
  begin
    if clk'event and clk='1' then
      if up1='1' then up(1):='1';--按键低电平有效，信号存入up
      end if;
      if up2='1' then up(2):='1';--按键低电平有效，信号存入up
      end if;
      if up3='1' then up(3):='1';--按键低电平有效，信号存入up
      end if;
      if up4='1' then up(4):='1';--按键低电平有效，信号存入up
      end if;
      if up5='1' then up(5):='1';--按键低电平有效，信号存入up
      end if;
      
      if down6='1' then down(6):='1';--按键低电平有效，信号存入down
      end if;
      if down5='1' then down(5):='1';--按键低电平有效，信号存入down
      end if;
      if down4='1' then down(4):='1';--按键低电平有效，信号存入down
      end if;
      if down3='1' then down(3):='1';--按键低电平有效，信号存入down
      end if;
      if down2='1' then down(2):='1';--按键低电平有效，信号存入down
      end if;
      
      if floor1='1' then goal(1):='1';--按键低电平有效，信号存入goal
      end if;
      if floor2='1' then goal(2):='1';--按键低电平有效，信号存入goal
      end if;
      if floor3='1' then goal(3):='1';--按键低电平有效，信号存入goal
      end if;
      if floor4='1' then goal(4):='1';--按键低电平有效，信号存入goal
      end if;
      if floor5='1' then goal(5):='1';--按键低电平有效，信号存入goal
      end if;
      if floor6='1' then goal(6):='1';--按键低电平有效，信号存入goal
      end if;
      
      if clk_cnt<1000 then clk_cnt:=clk_cnt+1;--计数
      else
		case state is
        when c1 =>
          storey := "001";
          
          if goal(1)='1' or up(1)='1' then
            state := open_door; goal(1):='0'; up(1):='0';
          else
            mo := '0';
            if up(2)='1' or goal(2)='1' or up(3)='1' or goal(3)='1' or up(4)='1' or goal(4)='1' or up(5)='1' or goal(5)='1' or goal(6)='1' or down(6)='1' then
                state := c2; 
            elsif down(2)='1'or down(5)='1' or down(4)='1' or down(3)='1'or down(6)='1' then
                state := c2; 
            end if;
          end if;
          
		when c2=>
		  storey:="010";--2楼
		  if mo='0' then--目的是上
		  
			if goal(2)='1' or up(2)='1' then--目的地是2楼
				state:=open_door;goal(2):='0';up(2):='0';--开门，清数据
			elsif down(2)='1'then
			    mo:='1';--目的是下 
			elsif up(3)='1' or goal(3)='1'or down(3)='1' then--目的是3楼
				state:=c3;
		    elsif up(4)='1' or goal(4)='1' or down(4)='1' then--目的是4楼
				state:=c3;
			elsif up(5)='1' or goal(5)='1'or down(5)='1'  then--目的是5楼
				state:=c3;
		    elsif up(6)='1' or goal(6)='1'or down(6)='1' then--目的是6楼
				state:=c3;
			elsif up(1)='1' or goal(1)='1' then--目的是1楼
				mo:='1';--目的是下
			end if;
			
		  else--目的是下
			if goal(2)='1' or down(2)='1' then--目的地是2楼
				state:=open_door;goal(2):='0';down(2):='0';--开门，清数据
			elsif up(2)='1'then
			    mo:='0';
			elsif up(1)='1' or goal(1)='1'  then
				state:=c1;
			elsif up(3)='1' or down(3)='1' or goal(3)='1' then
				mo:='0';
			elsif up(4)='1' or down(4)='1' or goal(4)='1' then
				mo:='0';
			elsif up(5)='1' or down(5)='1' or goal(5)='1' then
				mo:='0';
			elsif down(6)='1' or goal(6)='1' then
				mo:='0';
			end if;
		  end if;
		  
		  
		 when c3 =>
            storey := "011";
            if mo = '0' then -- 目的是上
                if goal(3) = '1' or up(3) = '1' then
                    state := open_door; goal(3) := '0'; up(3) := '0';
                elsif down(3) = '1' then
                    mo := '1';
                elsif up(4) = '1' or goal(4) = '1' or down(4) = '1' then
                    state := c4;
                elsif up(5) = '1' or goal(5) = '1' or down(5) = '1' then
                    state := c4;
                elsif up(6) = '1' or goal(6) = '1' or down(6) = '1' then
                    state := c4;
                elsif up(2) = '1' or goal(2) = '1' or down(2) = '1' or up(1) = '1' or goal(1) = '1' then
                    mo := '1';
                end if;
            else
                if goal(3) = '1' or down(3) = '1' then
                    state := open_door; goal(3) := '0'; down(3) := '0';
                elsif up(3) = '1' then
                    mo := '0';
                elsif up(2) = '1' or goal(2) = '1' or down(2) = '1' then
                    state := c2;
                elsif up(1) = '1' or goal(1) = '1' then
                    state := c2;
                elsif up(4) = '1' or down(4) = '1' or goal(4) = '1' then
                    mo := '0';
                elsif up(5) = '1' or down(5) = '1' or goal(5) = '1' then
                    mo := '0';
                elsif goal(6) = '1' or down(6) = '1' then
                    mo := '0';
                end if;
            end if;
		  
        when c4 =>
            storey := "100";
            if mo = '0' then -- 目的是上
                if goal(4) = '1' or up(4) = '1' then
                    state := open_door; goal(4) := '0'; up(4) := '0';
                elsif down(4) = '1' then
                    mo := '1';
                elsif up(5) = '1' or goal(5) = '1' or down(5) = '1' then
                    state := c5;
                elsif up(6) = '1' or goal(6) = '1' or down(6) = '1' then
                    state := c5;
                elsif up(3) = '1' or goal(3) = '1' or down(3) = '1' or up(2) = '1' or goal(2) = '1' or down(2) = '1' or up(1) = '1' or goal(1) = '1' then
                    mo := '1';
                end if;
            else -- 目的是下
                if goal(4) = '1' or down(4) = '1' then
                    state := open_door; goal(4) := '0'; down(4) := '0';
                elsif up(4) = '1' then
                    mo := '0';
                elsif up(3) = '1' or goal(3) = '1' or down(3) = '1' then
                    state := c3;
                elsif up(2) = '1' or goal(2) = '1' or down(2) = '1' then
                    state := c3;
                elsif up(1) = '1' or goal(1) = '1' then
                    state := c3;
                elsif up(5) = '1' or down(5) = '1' or goal(5) = '1' then
                    mo := '0';
                elsif goal(6) = '1' or down(6) = '1' then
                    mo := '0';
                end if;
            end if;
          
          when c5 =>
            storey := "101";
            if mo = '0' then -- 目的是上
                if goal(5) = '1' or up(5) = '1' then
                    state := open_door; goal(5) := '0'; up(5) := '0';
                elsif down(5) = '1' then
                    mo := '1';
                elsif goal(6) = '1' or down(6) = '1' then
                    state := c6; -- 6楼逻辑将来补
                elsif up(4) = '1' or goal(4) = '1' or down(4) = '1' or up(3) = '1' or goal(3) = '1' or down(3) = '1' or up(2) = '1' or goal(2) = '1' or down(2) = '1' or up(1) = '1' or goal(1) = '1' then
                    mo := '1';
                end if;
            else -- 目的是下
                if goal(5) = '1' or down(5) = '1' then
                    state := open_door; goal(5) := '0'; down(5) := '0';
                elsif up(5) = '1' then
                    mo := '0';
                elsif up(4) = '1' or goal(4) = '1' or down(4) = '1' then
                    state := c4;
                elsif up(3) = '1' or goal(3) = '1' or down(3) = '1' then
                    state := c4;
                elsif up(2) = '1' or goal(2) = '1' or down(2) = '1' then
                    state := c4;
                elsif up(1) = '1' or goal(1) = '1' then
                    state := c4;
                elsif goal(6) = '1' or down(6) = '1' then
                    mo := '0';
                end if;
            end if;
          
        when c6 => -- 6楼
          storey := "110";
          if goal(6) = '1' or down(6) = '1' then
            state := open_door; goal(6) := '0'; down(6) := '0';
          else
            mo := '1'; -- 只能下行
            if goal(5) = '1' or down(5) = '1'or up(5)='1' then
              state := c5;
            elsif goal(4) = '1' or down(4) = '1'or up(4)='1' then
              state := c5;
            elsif goal(3) = '1' or down(3) = '1'or up(3)='1'then
              state := c5;
            elsif goal(2) = '1' or down(2) = '1'or up(2)='1' then
              state := c5;
            elsif goal(1) = '1' or up(1) = '1' then
              state := c5;
            end if;
          end if;
          
		when open_door=>--开电梯
			door<='1';--开门
		  if time_cnt<3 then 
			time_cnt:=time_cnt+1;--持续3秒
		  else 
			door<='0';--关门
			time_cnt:=0;--清计数
			if storey="001" then
				state:=c1;--1楼
			elsif storey="010" then
				state:=c2;--2楼
			elsif storey="011" then 
				state:=c3;--3楼
		    elsif storey="100" then
		        state:=c4;--4楼
		    elsif storey="101" then
		        state:=c5;--5楼
            elsif storey="110" then
		        state:=c6;--6楼
			end if;
		  end if;
		end case;
        clk_cnt:=0;--计数清零
        floor_num<=storey;--楼层
       end if;
--     floor_num<=storey;
    end if;	    

    led1<=goal(1);--梯内目的楼层，高电平有效
    led2<=goal(2);--梯内目的楼层，高电平有效
    led3<=goal(3);--梯内目的楼层，高电平有效
    led4<= goal(4);--梯内目的楼层，高电平有效
    led5<= goal(5);--梯内目的楼层，高电平有效
    led6<= goal(6);--梯内目的楼层，高电平有效
 end process;
 
 

  
end architecture behave;
