
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
--��Ƶģ�飬100M��Ƶ��1KHz
ENTITY fenping IS
   PORT (
      clk_in  : IN STD_LOGIC;--100MHz����
      clk_1KHz  : OUT STD_LOGIC--1KHz���
   );
END fenping;

ARCHITECTURE behave OF fenping IS
   
   SIGNAL time_count : integer := 0;
BEGIN
   PROCESS (clk_in)--100M
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (time_count = 5) THEN--100M����100000�εõ�1KHz�ź�,--���潫��ֵ��СΪ5--�����øþ�
         --IF (time_count = 100000) THEN--100M����100000�εõ�1KHz�ź�,--�ϰ��øþ�
            time_count <= 0;
            clk_1KHz <= '1';
         ELSE
            time_count <= time_count + 1;
            clk_1KHz <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   
END behave;


