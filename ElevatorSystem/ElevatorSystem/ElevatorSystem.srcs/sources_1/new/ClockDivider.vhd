library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClockDivider is
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           en_3hz : out STD_LOGIC
          );
end ClockDivider;

architecture Behavioral of ClockDivider is
-- constant max_count_1hz : integer := 99_999_999;
 constant max_count_3hz : integer := 33_333_333;
-- signal count_1hz : unsigned(26 downto 0) := (others => '0'); 
 signal count_3hz : unsigned(26 downto 0) := (others => '0');
 signal count: unsigned(26 downto 0) := (others => '0'); 
 signal CLK_en : std_logic := '0';

 begin
     -- 分频
     process(clk, reset) is
     begin
        if reset = '1' then   -- 高电平复位
            en_3hz <= '0';
            count_3hz <= (others => '0');
    --        CLK_en_pulse <= '0';
        elsif rising_edge(clk) then
            if count_3hz = max_count_3hz then   -- 是否能直接除以2？
                en_3hz <= '1';
                count_3hz <= (others => '0');
            else
                en_3hz <= '0';
                count_3hz <= count_3hz + 1;            
            end if;
    --        CLK_en_pulse <= CLK_en;
        end if;
     end process;
end Behavioral;
