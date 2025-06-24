-- ԭ�����СΪ12
-- Ŀǰrespû��ʵʱ���أ��ο�lift1��rising_edge
-- ����up list �� down list�ĺ�����Ҫ����

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
  -- �����ⲿ����
--  en_door: in std_logic;   -- �����ţ�1s
--  en_door_led: in std_logic;   -- ������led��˸��0.3s
--  en_op: in std_logic;   -- ����������4s
  up_req: in std_logic_vector(5 downto 0);
  down_req: in std_logic_vector(5 downto 0);
  en_3hz: in std_logic;
  -- �����ڲ�����
  internal_req: in std_logic_vector(5 downto 0);   -- �˿�����
  floor_resp: out std_logic_vector(6 downto 1);   -- ��Ҫ��λ��ʾ��ǰ¥��
  up_resp: out std_logic_vector(6 downto 1);   -- �����ظ��б�
  down_resp: out std_logic_vector(6 downto 1);
  dir_resp:out std_logic_vector(1 downto 0);
  -- �ⲿ��ʾ
  floor_show3: out std_logic_vector(3 downto 0);
  state_show3: out std_logic_vector(3 downto 0);
  led1_3: out std_logic;   -- �ڲ�����led
  led2_3: out std_logic;
  led3_3: out std_logic;
  led4_3: out std_logic;
  led5_3: out std_logic;
  led6_3: out std_logic;
  state_led3: out std_logic
  );   
  -- ����ȱ���ⲿ��ʾ���
end lift3;

architecture Behavioral of lift3 is
 -- ������¥���Ƿ�������
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

-- ������¥���Ƿ�������
function have_lower_req(
    current_floor : integer;
    union         : std_logic_vector 
) return std_logic is
begin
    -- �߽��飨��ǰ��1��ʱֱ�ӷ���'0'��
    if current_floor = 0 then
        return '0';
    end if;
    -- ����λ��
    for i in union'range loop   -- û�д������
        if i < current_floor and union(i) = '1' then
            return '1';
        end if;
    end loop;
    return '0';
end function;

-- ���� up_stay_list
 function generate_up_stay_list(
        floor_num    : integer range 0 to 5;
        up_req       : std_logic_vector(5 downto 0);
        internal_req : std_logic_vector(5 downto 0)
    ) return std_logic_vector is
        variable result : std_logic_vector(5 downto 0);
    begin
        for i in 0 to 5 loop
            if i > floor_num then
                result(i) := up_req(i) or internal_req(i);   -- ��¥����ֻ�ܰ���¥��
--            else
--                result(i) := internal_req(i);   -- 
            end if;
        end loop;
        return result;
 end function;
 
 -- ����down_stay_list
 function generate_down_stay_list(
        floor_num    : integer range 0 to 5;
        down_req       : std_logic_vector(5 downto 0);
        internal_req : std_logic_vector(5 downto 0)
    ) return std_logic_vector is
        variable result : std_logic_vector(5 downto 0);
    begin
        for i in 0 to 5 loop
            if i < floor_num then
                result(i) := down_req(i) or internal_req(i);   -- ��¥����ֻ�ܰ���¥��
            end if;
        end loop;
        return result;
 end function;
 
 -- �ҵ� std_logic_vector �����λ '1' ��λ��
function find_highest_bit(vec : std_logic_vector) return integer is
    variable highest : integer := 0;  -- ��ʼ��Ϊ��Чֵ
begin
    for i in vec'range loop
        if vec(i) = '1' then
            highest := i;
        end if;
    end loop;
    return highest;
end function;

-- �ҵ� std_logic_vector �����λ '1' ��λ��
function find_lowest_bit(vec : std_logic_vector) return integer is
    variable lowest : integer := -1;  -- ��ʼ��Ϊ��Чֵ
begin
    for i in 0 to vec'high loop  -- �����λ(0)��ʼ���
        if vec(i) = '1' then
            lowest := i;
            exit;  -- �ҵ���һ��'1'���˳�
        end if;
    end loop;
    return lowest;
end function;

 -- intrnal_req_list����
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

 -- ¥�㷵�غ���
 function floor_convert(floor: integer range 0 to 5) return std_logic_vector is
    variable floor_response: std_logic_vector(6 downto 1) := "000000";  -- ��ʼ��Ϊ��Чֵ
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
 signal up_req_list: std_logic_vector(5 downto 0):= "000000";   -- ��up_req�����ں���response
-- signal up_req_list_reg: std_logic_vector(5 downto 0);
 signal down_req_list: std_logic_vector(5 downto 0):= "000000";
-- signal down_req_list_reg: std_logic_vector(5 downto 0);
 signal up_stay_list: std_logic_vector(5 downto 0):= "000000";
 signal up_stay_list_reg: std_logic_vector(5 downto 0):= "000000";
 signal down_stay_list: std_logic_vector(5 downto 0):= "000000";
 signal down_stay_list_reg: std_logic_vector(5 downto 0):= "000000";
 signal internal_req_list: std_logic_vector(5 downto 0):= "000000";   -- ��������internal_req
 signal union: std_logic_vector(5 downto 0):= "000000";
 signal union_reg: std_logic_vector(5 downto 0):= "000000";
 signal floor_num: unsigned(2 downto 0):= "000";
 signal floor_num_reg: unsigned(2 downto 0):= "000";
 signal state_led_reg: std_logic:='1';
-- ��ʱ��
 signal count: unsigned(26 downto 0) := (others => '0');
 constant max_count_4s : integer := 400_000_000;
 signal en_4s: std_logic:='0';
 signal en_4s_reg: std_logic:='0';

begin
    -- ʱ���߼�����
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
            else   -- IDLE״̬
                count <= (others => '0');
                en_4s_reg <= '0';
            end if;   -- end state_reg
            -- up_stay_list�ĸ���Ҫ��door_op�׶�
        end if;   -- reset
    end process;
    
    -- ��ʱ����
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
--            else   -- IDLE״̬
--                count <= (others => '0');
--                en_4s <= '0';
--            end if;   -- end state_reg
--        end if;   
--    end process;   -- end ��ʱ����

    -- ״̬��
    process(internal_req, up_req, down_req, state_reg, floor_num_reg, 
            dir_reg, up_stay_list_reg, down_stay_list_reg)
    begin
        -- ʵʱ����internal_req
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
            -- ���ȿ�ͬ�����
            up_stay_list <= generate_up_stay_list(TO_INTEGER(floor_num_reg), up_req, internal_req);
            if up_stay_list_reg /= (up_stay_list_reg'range => '0') then
                
                -- ���4s����������һ��
                if en_4s_reg = '1' then
                    en_4s <= '0';
                    if up_stay_list_reg(TO_INTEGER(floor_num_reg + 1)) = '1' then   -- ��һ��ͣ��
                        next_state <= DOOR_OP;
                    else
                        next_state <= UP;
                    end if;   -- end up_stay_list = '1'
                    floor_num <= floor_num + 1;
                    floor_resp <= floor_convert(TO_INTEGER(floor_num));
                end if;   --  end en_4s='1'
                
            else   -- up_stay_listΪ��
                         
                -- ��������һ��
                if en_4s_reg = '1' then
                    en_4s <= '0';
                    if TO_INTEGER(floor_num_reg+1) = find_highest_bit(down_req) then
                        next_state <= DOOR_OP;
                    else   -- ��һ�㲻��ͣ
                        next_state <= UP;
                    end if;   -- end floor_num+1=highest
                    
                end if;   -- end en_4s='1'
                floor_num <= floor_num + 1;
                floor_resp <= floor_convert(TO_INTEGER(floor_num));
            end if;   -- end up_stay_list�ж�
        
        -- state3: DOWN    
        elsif state_reg = DOWN then
            down_stay_list <= generate_down_stay_list(TO_INTEGER(floor_num_reg), down_req, internal_req);
            if down_stay_list_reg /= (down_stay_list_reg'range => '0') then
                -- ��ʱ4s
--                if rising_edge(clk) then
--                    if count = max_count_4s then
--                        en_4s <= '1';
--                        count <= (others => '0');
--                    else
--                        count <= count + 1;
--                        en_4s <= '0';
--                    end if;   -- end max_count
--                end if;   -- end count 4s
                
                -- ���4s����������һ��
                if en_4s_reg = '1' then
                    en_4s <= '0';
                    if down_stay_list_reg(TO_INTEGER(floor_num_reg - 1)) = '1' then   -- ��һ��ͣ��
                        next_state <= DOOR_OP;
                    else
                        next_state <= DOWN;
                    end if;   -- end down_stay_list = '1'
                    floor_num <= floor_num - 1;
                    floor_resp <= floor_convert(TO_INTEGER(floor_num));
                end if;   --  end en_4s='1'
                
            else   -- down_stay_listΪ��
                
                -- ��������һ��
                if en_4s_reg = '1' then
                    en_4s <= '0';
                    if TO_INTEGER(floor_num_reg-1) = find_lowest_bit(up_req) then
                        next_state <= DOOR_OP;
                    else   -- ��һ�㲻��ͣ
                        next_state <= DOWN;
                    end if;   -- end floor_num-1=lowest
                    
                end if;   -- end en_4s='1'
                floor_num <= floor_num - 1;
                floor_resp <= floor_convert(TO_INTEGER(floor_num));
            end if;   -- end down_stay_list�ж�
         
        -- state4: DOOR_OP      
        elsif state_reg = DOOR_OP then
            union(TO_INTEGER(floor_num_reg)) <= '0';
            internal_req_list(TO_INTEGER(floor_num_reg)) <= '0';   -- ������б����ں�����ʾ
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
--                    up_resp <= up_req_list;   -- ������ֵ�����𣨴��У���
--                    up_resp(6) <= up_req_list(5);
--                    up_resp(5) <= up_req_list(4);
--                    up_resp(4) <= up_req_list(3);
--                    up_resp(3) <= up_req_list(2);
--                    up_resp(2) <= up_req_list(1);
--                    up_resp(1) <= up_req_list(0);
                    up_stay_list <= generate_up_stay_list(TO_INTEGER(floor_num_reg), up_req, internal_req);
                end if;   -- end 6¥���  
                
                
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
--                    down_resp <= down_req_list;   -- ������ֵ�����𣨴��У���
--                    down_resp(1) <= down_req_list(0);
--                    down_resp(2) <= down_req_list(1);
--                    down_resp(3) <= down_req_list(2);
--                    down_resp(4) <= down_req_list(3);
--                    down_resp(5) <= down_req_list(4);
--                    down_resp(6) <= down_req_list(5);
                    down_stay_list <= generate_down_stay_list(TO_INTEGER(floor_num_reg), down_req, internal_req);
                end if;   -- end һ¥���  
                
                
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
     
        end if;   -- end ״̬�ж�        
        
    end process;   -- end ״̬��
    
    -- �ⲿ��ʾ��internal_req������ܣ�
    process(reset, clk, floor_num_reg, state_reg, internal_req_list)   -- list�仯ʱ��ʾ��led�Ʊ仯
    begin
        floor_show3 <= '0' & std_logic_vector(floor_num_reg + 1);   -- ��λ����
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
    end process;   -- end�ⲿ��ʾ
    
    
    
   
end Behavioral;
