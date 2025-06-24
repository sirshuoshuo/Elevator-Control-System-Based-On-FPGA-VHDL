  --�������ʾ����ģ��
library ieee;
use ieee.std_logic_1164.all;
entity segment is
port(
	 floor_num: IN std_logic_vector(2 downto 0);--¥��
     DEL  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);--�����λѡ
     LEDAG: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)--����ܶ�ѡ
	 );
end entity segment;

architecture behave of segment is

begin

   DEL <= "0001";--�����λѡ
   PROCESS (floor_num)
   BEGIN
        case floor_num is
            when "001" =>  -- ��ʾ1
                LEDAG <= "00000110"; -- pgfedcba
            when "010" =>  -- ��ʾ2
                LEDAG <= "01011011";
            when "011" =>  -- ��ʾ3
                LEDAG <= "01001111";
            when "100" =>  -- ��ʾ4
                LEDAG <= "01100110";
            when "101" =>  -- ��ʾ5
                LEDAG <= "01101101";
            when "110" =>  -- ��ʾ6
                LEDAG <= "01111101";
            when others =>
                LEDAG <= "00000000"; -- Ĭ��Ϩ�����ʾ
        end case;
   END PROCESS;
  
end architecture behave;
