  --数码管显示控制模块
library ieee;
use ieee.std_logic_1164.all;
entity segment is
port(
	 floor_num: IN std_logic_vector(2 downto 0);--楼层
     DEL  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);--数码管位选
     LEDAG: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)--数码管段选
	 );
end entity segment;

architecture behave of segment is

begin

   DEL <= "0001";--数码管位选
   PROCESS (floor_num)
   BEGIN
        case floor_num is
            when "001" =>  -- 显示1
                LEDAG <= "00000110"; -- pgfedcba
            when "010" =>  -- 显示2
                LEDAG <= "01011011";
            when "011" =>  -- 显示3
                LEDAG <= "01001111";
            when "100" =>  -- 显示4
                LEDAG <= "01100110";
            when "101" =>  -- 显示5
                LEDAG <= "01101101";
            when "110" =>  -- 显示6
                LEDAG <= "01111101";
            when others =>
                LEDAG <= "00000000"; -- 默认熄灭或不显示
        end case;
   END PROCESS;
  
end architecture behave;
