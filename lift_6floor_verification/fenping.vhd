
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
--分频模块，100M分频到1KHz
ENTITY fenping IS
   PORT (
      clk_in  : IN STD_LOGIC;--100MHz输入
      clk_1KHz  : OUT STD_LOGIC--1KHz输出
   );
END fenping;

ARCHITECTURE behave OF fenping IS
   
   SIGNAL time_count : integer := 0;
BEGIN
   PROCESS (clk_in)--100M
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (time_count = 5) THEN--100M计数100000次得到1KHz信号,--仿真将该值减小为5--仿真用该句
         --IF (time_count = 100000) THEN--100M计数100000次得到1KHz信号,--上板用该句
            time_count <= 0;
            clk_1KHz <= '1';
         ELSE
            time_count <= time_count + 1;
            clk_1KHz <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   
END behave;


