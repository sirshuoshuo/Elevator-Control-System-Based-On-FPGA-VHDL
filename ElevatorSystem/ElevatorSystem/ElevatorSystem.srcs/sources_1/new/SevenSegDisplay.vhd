library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity SevenSegDisplay is
    Port(clk : in  std_logic;                         -- 100MHz系统时钟
         en_n : in std_logic_vector (7 downto 0);     -- 显示使能端，低电平使�?
         dp : in std_logic_vector (7 downto 0);       -- 小数点控制端
         number : in  std_logic_vector (31 downto 0); -- 8个数字的输入数据(每个数字4位，�?8*4=32�?)
         seg : out  std_logic_vector (7 downto 0);    -- 数据�?(�?高位为小数点)
         an : out  std_logic_vector (7 downto 0));    -- 阳极选择�?
end SevenSegDisplay;

architecture Behavioral of SevenSegDisplay is

    signal cnt: std_logic_vector (19 downto 0);
    signal anode_select: std_logic_vector (2 downto 0); -- 3位阳极扫描信号，也是状�?�机状�??
    signal digit_data: std_logic_vector (3 downto 0); -- 当前显示的数字数�?
    signal dp_bit: std_logic;                         -- 当前小数点状�?
    signal segment_data: std_logic_vector (6 downto 0); -- 七段数码管数据信�?(不含小数�?)
    signal an_tmp: std_logic_vector (7 downto 0);       -- 未与使能端组合前的阳极扫描信�?(8�?)

begin
    -- 计数�?
    process(clk)
    begin
        if rising_edge(clk) then
            cnt <= cnt + '1';
        end if;
    end process;
    
    -- �?高三位，作为扫描状�?? (每个数字刷新率：100MHz/2^20 �? 95.3Hz)
    anode_select <= cnt(19 downto 17);
    
    -- 阳极扫描 (3-8译码�?)
    with anode_select select
        an_tmp <=
            "11111110" when "000",
            "11111101" when "001",
            "11111011" when "010",
            "11110111" when "011",
            "11101111" when "100",
            "11011111" when "101",
            "10111111" when "110",
            "01111111" when "111",
            "11111111" when others;
    
    -- 应用低电平使能控�?
    an <= an_tmp or en_n;

    -- 数据选择多路复用
    with anode_select select
        digit_data <=
            number(3 downto 0)   when "000",
            number(7 downto 4)   when "001",
            number(11 downto 8)  when "010",
            number(15 downto 12) when "011",
            number(19 downto 16) when "100",
            number(23 downto 20) when "101",
            number(27 downto 24) when "110",
            number(31 downto 28) when "111",
            "0000"               when others;
    
    -- 小数点位
    with anode_select select
        dp_bit <=
            dp(0) when "000",
            dp(1) when "001",
            dp(2) when "010",
            dp(3) when "011",
            dp(4) when "100",
            dp(5) when "101",
            dp(6) when "110",
            dp(7) when "111",
            '1'   when others;
    
    -- 十六进制到七段数码管译码 (gfedcba)
    with digit_data select
        segment_data <=
            "1000000" when "0000", -- 0
            "1111001" when "0001", -- 1
            "0100100" when "0010", -- 2
            "0110000" when "0011", -- 3
            "0011001" when "0100", -- 4
            "0010010" when "0101", -- 5
            "0000010" when "0110", -- 6
            "1111000" when "0111", -- 7
            "0000000" when "1000", -- 8
            "0010000" when "1001", -- 9
            "0001000" when "1010", -- A
            "0000011" when "1011", -- b
            "1111111" when "1100", -- IDLE
            "0111111" when "1101", -- DOOR_OP
            "1011100" when "1110", -- UP
            "1100011" when "1111", -- DOWN 
--            "0100001" when "1101", -- d
--            "1101010" when "1110", -- M!
--            "0001100" when "1111", -- P!
--            "1011100" when ""
            "1111111" when others; -- 全灭
    
    -- 组合小数点和七段数据 (小数点在�?高位)
    seg <= dp_bit & segment_data;
    
end Behavioral;