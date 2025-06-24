-- 原字体大小为12
-- 目前resp没有实时返回，参考lift1的rising_edge
-- 生成up list 和 down list的函数需要更改

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lift3 is
  Port ( 
  clk: in std_logic;    
  reset: in std_logic;
  -- 电梯外部输入
--  en_door: in std_logic;   -- 开关门，1s
--  en_door_led: in std_logic;   -- 开关门led闪烁，0.3s
--  en_op: in std_logic;   -- 电梯升降，4s
  up_req: in std_logic_vector(5 downto 0);
  down_req: in std_logic_vector(5 downto 0);
  en_3hz: in std_logic;
  -- 电梯内部输入
  internal_req: in std_logic_vector(5 downto 0);   -- 乘客输入
  floor_resp: out std_logic_vector(6 downto 1);   -- 需要三位表示当前楼层
  up_resp: out std_logic_vector(6 downto 1);   -- 上升回复列表
  down_resp: out std_logic_vector(6 downto 1);
  dir_resp:out std_logic_vector(1 downto 0);
  -- 外部显示
  floor_show3: out std_logic_vector(3 downto 0);
  state_show3: out std_logic_vector(3 downto 0);
  led1_3: out std_logic;   -- 内部请求led
  led2_3: out std_logic;
  led3_3: out std_logic;
  led4_3: out std_logic;
  led5_3: out std_logic;
  led6_3: out std_logic;
  state_led3: out std_logic
  );   
  -- 现在缺少外部显示输出
end lift3;

architecture Behavioral of lift3 is
 -- 检查更高楼层是否有请求
 function have_higher_req(
    current_floor : integer;      
    union         : std_logic_vector  
) return std_logic is
    variable result : std_logic := '0';
begin
    for i in union'range loop
        if i > current_floor and union(i) = '1' then
            result := '1';
            exit;
        end if;
    end loop;
    return result;
end function;

-- 检查更低楼层是否有请求
function have_lower_req(
    current_floor : integer;
    union         : std_logic_vector 
) return std_logic is
begin
    -- 边界检查（当前在1层时直接返回'0'）
    if current_floor = 0 then
        return '0';
    end if;
    -- 检查低位段
    for i in union'range loop   -- 没有处理溢出
        if i < current_floor and union(i) = '1' then
            return '1';
        end if;
    end loop;
    return '0';
end function;

-- 生成 up_stay_list
 function generate_up_stay_list(
        floor_num    : integer range 0 to 5;
        up_req       : std_logic_vector(5 downto 0);
        internal_req : std_logic_vector(5 downto 0)
    ) return std_logic_vector is
        variable result : std_logic_vector(5 downto 0);
    begin
        for i in 0 to 5 loop
            if i > floor_num then
                result(i) := up_req(i) or internal_req(i);   -- 上楼的人只能按高楼层
--            else
--                result(i) := internal_req(i);   -- 
            end if;
        end loop;
        return result;
 end function;
 
 -- 生成down_stay_list
 function generate_down_stay_list(
        floor_num    : integer range 0 to 5;
        down_req       : std_logic_vector(5 downto 0);
        internal_req : std_logic_vector(5 downto 0)
    ) return std_logic_vector is
        variable result : std_logic_vector(5 downto 0);
    begin
        for i in 0 to 5 loop
            if i < floor_num then
                result(i) := down_req(i) or internal_req(i);   -- 下楼的人只能按低楼层
            end if;
        end loop;
        return result;
 end function;
 
 -- 找到 std_logic_vector 中最高位 '1' 的位置
function find_highest_bit(vec : std_logic_vector) return integer is
    variable highest : integer := 0;  -- 初始化为无效值
begin
    for i in vec'range loop
        if vec(i) = '1' then
            highest := i;
        end if;
    end loop;
    return highest;
end function;

-- 找到 std_logic_vector 中最低位 '1' 的位置
function find_lowest_bit(vec : std_logic_vector) return integer is
    variable lowest : integer := -1;  -- 初始化为无效值
begin
    for i in 0 to vec'high loop  -- 从最低位(0)开始检查
        if vec(i) = '1' then
            lowest := i;
            exit;  -- 找到第一个'1'就退出
        end if;
    end loop;
    return lowest;
end function;

 -- intrnal_req_list更新
 function internal_req_list_upadte(
--    req_list: std_logic_vector(5 downto 0);
    req: std_logic_vector(5 downto 0) 
    ) return std_logic_vector is
    variable req_list: std_logic_vector(5 downto 0);
 begin
    for i in 0 to req' high loop
        if req(i) = '1' then
            req_list(i) := '1';
        end if;
    end loop;
    return req_list;
 end function;

 -- 楼层返回函数
 function floor_convert(floor: integer range 0 to 5) return std_logic_vector is
    variable floor_response: std_logic_vector(6 downto 1) := "000000";  -- 初始化为无效值
 begin
    floor_response(floor+1) := '1';
    return floor_response;
 end function;
 
 type state_type is (IDLE, UP, DOWN, DOOR_OP);
 type dir_type is (idle, up, down);
 signal state_reg: state_type:= idle;
 signal next_state: state_type:= idle;
 signal dir: dir_type;
 signal dir_reg: dir_type:= IDLE;
 signal up_req_list: std_logic_vector(5 downto 0):= "000000";   -- 接up_req，用于后面response
-- signal up_req_list_reg: std_logic_vector(5 downto 0);
 signal down_req_list: std_logic_vector(5 downto 0):= "000000";
-- signal down_req_list_reg: std_logic_vector(5 downto 0);
 signal up_stay_list: std_logic_vector(5 downto 0):= "000000";
 signal up_stay_list_reg: std_logic_vector(5 downto 0):= "000000";
 signal down_stay_list: std_logic_vector(5 downto 0):= "000000";
 signal down_stay_list_reg: std_logic_vector(5 downto 0):= "000000";
 signal internal_req_list: std_logic_vector(5 downto 0):= "000000";   -- 用于外显internal_req
 signal union: std_logic_vector(5 downto 0):= "000000";
 signal union_reg: std_logic_vector(5 downto 0):= "000000";
 signal floor_num: unsigned(2 downto 0):= "000";
 signal floor_num_reg: unsigned(2 downto 0):= "000";
 signal state_led_reg: std_logic:='1';
-- 计时用
 signal count: unsigned(26 downto 0) := (others => '0');
 constant max_count_4s : integer := 400_000_000;
 signal en_4s: std_logic:='0';
 signal en_4s_reg: std_logic:='0';

begin
    -- 时序逻辑更新
    process(clk, reset)
    begin
        if reset = '1' then
            floor_num_reg <= TO_UNSIGNED(0,3);   -- init as floor 0, in order to fit the bit size
            state_reg <= IDLE;
--            next_state <= IDLE;
            dir_reg <= idle;
            union_reg <= (others => '0');
--            floor_resp <= floor_convert(TO_INTEGER(floor_num));
            up_stay_list_reg <= (others => '0');
            down_stay_list_reg <= (others => '0');
--            up_req_list_reg <= (others => '0');
--            down_req_list_reg <= (others => '0');
            count <= (others => '0');
            en_4s_reg <= '0';
            state_led_reg <= '0';
        elsif rising_edge(clk) then
--            union <= up_req or down_req or internal_req;
            union_reg <= union;
--            up_req_list_reg <= up_req_list;
--            down_req_list_reg <= down_req_list;
            state_reg <= next_state;
            dir_reg <= dir;
            up_stay_list_reg <= up_stay_list;
            down_stay_list_reg <= down_stay_list_reg;
            floor_num_reg <= floor_num;
            en_4s_reg <= en_4s;
            if state_reg = UP or state_reg = DOWN or state_reg = DOOR_OP then
   
                if count = max_count_4s then
                    en_4s_reg <= '1';
                    count <= (others => '0');
                else
                    count <= count + 1;
                    en_4s_reg <= '0';
                end if;   -- end max_count
            else   -- IDLE状态
                count <= (others => '0');
                en_4s_reg <= '0';
            end if;   -- end state_reg
            -- up_stay_list的更新要在door_op阶段
        end if;   -- reset
    end process;
    
    -- 计时四秒
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if state_reg = UP or state_reg = DOWN or state_reg = DOOR_OP then
--                if count = max_count_4s then
--                    en_4s <= '1';
--                    count <= (others => '0');
--                else
--                    count <= count + 1;
--                    en_4s <= '0';
--                end if;   -- end max_count
--            else   -- IDLE状态
--                count <= (others => '0');
--                en_4s <= '0';
--            end if;   -- end state_reg
--        end if;   
--    end process;   -- end 计时四秒

    -- 状态机
    process(internal_req, up_req, down_req, state_reg, floor_num_reg, 
            dir_reg, up_stay_list_reg, down_stay_list_reg)
    begin
        -- 实时更新internal_req
        internal_req_list <= internal_req_list_upadte(internal_req);
        union <= up_req or down_req or internal_req;
        up_req_list <= up_req;
        down_req_list <= down_req;
        -- state1: IDLE
        if state_reg = IDLE then
            if have_higher_req(TO_INTEGER(floor_num_reg), union) = '1' then
                dir <= up;
                dir_resp <= "01";
                next_state <= UP;
            elsif have_lower_req(TO_INTEGER(floor_num_reg), union) = '1' then
                next_state <= DOWN;
                dir <= down;
                dir_resp <= "10";
            else 
                dir <= idle;   
                dir_resp <= "00";
                next_state <= IDLE;
            end if;   -- have_higher_req
         
        -- state2: UP   
        elsif state_reg = UP then
            -- 优先看同方向的
            up_stay_list <= generate_up_stay_list(TO_INTEGER(floor_num_reg), up_req, internal_req);
            if up_stay_list_reg /= (up_stay_list_reg'range => '0') then
                
                -- 完成4s，电梯上了一层
                if en_4s_reg = '1' then
                    en_4s <= '0';
                    if up_stay_list_reg(TO_INTEGER(floor_num_reg + 1)) = '1' then   -- 下一层停靠
                        next_state <= DOOR_OP;
                    else
                        next_state <= UP;
                    end if;   -- end up_stay_list = '1'
                    floor_num <= floor_num + 1;
                    floor_resp <= floor_convert(TO_INTEGER(floor_num));
                end if;   --  end en_4s='1'
                
            else   -- up_stay_list为空
                         
                -- 电梯上了一层
                if en_4s_reg = '1' then
                    en_4s <= '0';
                    if TO_INTEGER(floor_num_reg+1) = find_highest_bit(down_req) then
                        next_state <= DOOR_OP;
                    else   -- 下一层不用停
                        next_state <= UP;
                    end if;   -- end floor_num+1=highest
                    
                end if;   -- end en_4s='1'
                floor_num <= floor_num + 1;
                floor_resp <= floor_convert(TO_INTEGER(floor_num));
            end if;   -- end up_stay_list判断
        
        -- state3: DOWN    
        elsif state_reg = DOWN then
            down_stay_list <= generate_down_stay_list(TO_INTEGER(floor_num_reg), down_req, internal_req);
            if down_stay_list_reg /= (down_stay_list_reg'range => '0') then
                -- 计时4s
--                if rising_edge(clk) then
--                    if count = max_count_4s then
--                        en_4s <= '1';
--                        count <= (others => '0');
--                    else
--                        count <= count + 1;
--                        en_4s <= '0';
--                    end if;   -- end max_count
--                end if;   -- end count 4s
                
                -- 完成4s，电梯下了一层
                if en_4s_reg = '1' then
                    en_4s <= '0';
                    if down_stay_list_reg(TO_INTEGER(floor_num_reg - 1)) = '1' then   -- 下一层停靠
                        next_state <= DOOR_OP;
                    else
                        next_state <= DOWN;
                    end if;   -- end down_stay_list = '1'
                    floor_num <= floor_num - 1;
                    floor_resp <= floor_convert(TO_INTEGER(floor_num));
                end if;   --  end en_4s='1'
                
            else   -- down_stay_list为空
                
                -- 电梯下了一层
                if en_4s_reg = '1' then
                    en_4s <= '0';
                    if TO_INTEGER(floor_num_reg-1) = find_lowest_bit(up_req) then
                        next_state <= DOOR_OP;
                    else   -- 下一层不用停
                        next_state <= DOWN;
                    end if;   -- end floor_num-1=lowest
                    
                end if;   -- end en_4s='1'
                floor_num <= floor_num - 1;
                floor_resp <= floor_convert(TO_INTEGER(floor_num));
            end if;   -- end down_stay_list判断
         
        -- state4: DOOR_OP      
        elsif state_reg = DOOR_OP then
            union(TO_INTEGER(floor_num_reg)) <= '0';
            internal_req_list(TO_INTEGER(floor_num_reg)) <= '0';   -- 清理该列表，用于后面显示
            if dir_reg = UP then
                if floor_num = "101" then
                    down_req_list(TO_INTEGER(floor_num_reg)) <= '0';
--                    down_resp <= down_req_list;
--                    down_resp(1) <= down_req_list(0);
--                    down_resp(2) <= down_req_list(1);
--                    down_resp(3) <= down_req_list(2);
--                    down_resp(4) <= down_req_list(3);
--                    down_resp(5) <= down_req_list(4);
--                    down_resp(6) <= down_req_list(5);
                else
--                    up_stay_list(TO_INTEGER(floor_num_reg)) <= '0';
                    up_req_list(TO_INTEGER(floor_num_reg)) <= '0';
--                    up_resp <= up_req_list;   -- 这样赋值可以吗（串行？）
--                    up_resp(6) <= up_req_list(5);
--                    up_resp(5) <= up_req_list(4);
--                    up_resp(4) <= up_req_list(3);
--                    up_resp(3) <= up_req_list(2);
--                    up_resp(2) <= up_req_list(1);
--                    up_resp(1) <= up_req_list(0);
                    up_stay_list <= generate_up_stay_list(TO_INTEGER(floor_num_reg), up_req, internal_req);
                end if;   -- end 6楼情况  
                
                
                if en_4s_reg = '1' then   -- internal_req over
                    en_4s <= '0';
                    if have_higher_req(TO_INTEGER(floor_num_reg), union) = '1' then
                        next_state <= UP;
                    elsif have_lower_req(TO_INTEGER(floor_num_reg), union) = '1' then
                        next_state <= DOWN;
                        dir <= down;   
                        dir_resp <= "10";
                    else
                        next_state <= IDLE;
                        dir <= idle;  
                        dir_resp <= "00";
                    end if;   -- end have_higher_req='1'
                    
                end if;   -- end en_4s='1'
            
            elsif dir_reg = DOWN then
                if floor_num_reg = "000" then
                    up_req_list(TO_INTEGER(floor_num_reg)) <= '0';
--                    up_resp <= up_req_list;
--                    up_resp(6) <= up_req_list(5);
--                    up_resp(5) <= up_req_list(4);
--                    up_resp(4) <= up_req_list(3);
--                    up_resp(3) <= up_req_list(2);
--                    up_resp(2) <= up_req_list(1);
--                    up_resp(1) <= up_req_list(0);
                else
--                    down_stay_list(TO_INTEGER(floor_num_reg)) <= '0';
                    down_req_list(TO_INTEGER(floor_num_reg)) <= '0';
--                    down_resp <= down_req_list;   -- 这样赋值可以吗（串行？）
--                    down_resp(1) <= down_req_list(0);
--                    down_resp(2) <= down_req_list(1);
--                    down_resp(3) <= down_req_list(2);
--                    down_resp(4) <= down_req_list(3);
--                    down_resp(5) <= down_req_list(4);
--                    down_resp(6) <= down_req_list(5);
                    down_stay_list <= generate_down_stay_list(TO_INTEGER(floor_num_reg), down_req, internal_req);
                end if;   -- end 一楼情况  
                
                
                if en_4s_reg = '1' then   -- internal_req over
                    en_4s <= '0';
                    if have_lower_req(TO_INTEGER(floor_num_reg), union) = '1' then
                        next_state <= DOWN;
                    elsif have_higher_req(TO_INTEGER(floor_num_reg), union) = '1' then
                        next_state <= UP;
                        dir <= up;
                        dir_resp <= "01";
                    else
                        next_state <= IDLE;
                        dir <= idle;
                        dir_resp <= "00";
                    end if;   -- end have_higher_req='1'
                    
                end if;   -- end en_4s='1'
                
            end if;   -- end dir=UP
     
        end if;   -- end 状态判断        
        
    end process;   -- end 状态机
    
    -- 外部显示（internal_req，数码管）
    process(reset, clk, floor_num_reg, state_reg, internal_req_list)   -- list变化时显示的led灯变化
    begin
        floor_show3 <= '0' & std_logic_vector(floor_num_reg + 1);   -- 高位补零
        led1_3 <= internal_req_list(0);
        led2_3 <= internal_req_list(1);
        led3_3 <= internal_req_list(2);
        led4_3 <= internal_req_list(3);
        led5_3 <= internal_req_list(4);
        led6_3 <= internal_req_list(5);        
        if state_reg = IDLE then
            state_show3 <= "1100";
            state_led3 <= '0';
        elsif state_reg = UP then
            state_show3 <= "1110";
            state_led3 <= '1';
        elsif state_reg = DOWN then
            state_show3 <= "1111";
            state_led3 <= '1';
        elsif state_reg = DOOR_OP then
            state_show3 <= "1101";
            if en_3hz = '1' then
                state_led3 <= not state_led_reg;
            end if;   -- end en_3hz
        end if;   -- end state_reg
    end process;   -- end外部显示
    
    
    
   
end Behavioral;
