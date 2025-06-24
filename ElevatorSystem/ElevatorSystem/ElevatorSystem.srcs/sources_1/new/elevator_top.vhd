library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity elevator_top is
  Port ( 
  clk: in std_logic;
  reset: in std_logic;
  -- outside up-down button
  raw_floor1_up: in std_logic;
  raw_floor2_up: in std_logic;
  raw_floor2_down: in std_logic;
  raw_floor3_up: in std_logic;
  raw_floor3_down: in std_logic;
  raw_floor4_up: in std_logic;
  raw_floor4_down: in std_logic;
  raw_floor5_up: in std_logic;
  raw_floor5_down: in std_logic;
  raw_floor6_down : in std_logic;
          
  -- 外部上下请求：LED 显示灯
  floor1_up_led: out std_logic;
  floor2_up_led: out std_logic;
  floor2_down_led: out std_logic;
  floor3_up_led: out std_logic;
  floor3_down_led: out std_logic;
  floor4_up_led: out std_logic;
  floor4_down_led: out std_logic;
  floor5_up_led: out std_logic;
  floor5_down_led: out std_logic;
  floor6_down_led : out std_logic;
  
  -- internal_req button
  btn1_1: in std_logic;   -- JA
  btn2_1: in std_logic;
  btn3_1: in std_logic;
  btn4_1: in std_logic;
  btn5_1: in std_logic;
  btn6_1: in std_logic;
  
  btn1_2: in std_logic;   
  btn2_2: in std_logic;
  btn3_2: in std_logic;
  btn4_2: in std_logic;
  btn5_2: in std_logic;
  btn6_2: in std_logic;
  
  btn1_3: in std_logic;   
  btn2_3: in std_logic;
  btn3_3: in std_logic;
  btn4_3: in std_logic;
  btn5_3: in std_logic;
  btn6_3: in std_logic;
  
  -- internal_req led
  led1_1: out std_logic;   
  led2_1: out std_logic;
  led3_1: out std_logic;
  led4_1: out std_logic;
  led5_1: out std_logic;
  led6_1: out std_logic;
  state_led1: out std_logic;
  
  led1_2: out std_logic;   
  led2_2: out std_logic;
  led3_2: out std_logic;
  led4_2: out std_logic;
  led5_2: out std_logic;
  led6_2: out std_logic;
  state_led2: out std_logic;
  
  led1_3: out std_logic;   
  led2_3: out std_logic;
  led3_3: out std_logic;
  led4_3: out std_logic;
  led5_3: out std_logic;
  led6_3: out std_logic;
  state_led3: out std_logic;
  
  -- 数码管
  an: out std_logic_vector(7 downto 0);
  seg : out std_logic_vector(7 downto 0)
  );
end elevator_top;

architecture Behavioral of elevator_top is
 -- 外部上下按键：按钮去抖动之后的输出
 signal floor1_up: std_logic;
 signal floor2_up: std_logic;
 signal floor2_down: std_logic;
 signal floor3_up: std_logic;
 signal floor3_down: std_logic;
 signal floor4_up: std_logic;
 signal floor4_down: std_logic;
 signal floor5_up: std_logic;
 signal floor5_down: std_logic;
 signal floor6_down : std_logic;
 
 -- button after debounce
 signal btn11: std_logic;
 signal btn21: std_logic;
 signal btn31: std_logic;
 signal btn41: std_logic;
 signal btn51: std_logic;
 signal btn61: std_logic;
 signal btn12: std_logic;
 signal btn22: std_logic;
 signal btn32: std_logic;
 signal btn42: std_logic;
 signal btn52: std_logic;
 signal btn62: std_logic;
 signal btn13: std_logic;
 signal btn23: std_logic;
 signal btn33: std_logic;
 signal btn43: std_logic;
 signal btn53: std_logic;
 signal btn63: std_logic;
 --
 signal en_3hz: std_logic;
 --
 signal number: std_logic_vector(31 downto 0);
 -- 数码管
 constant dp: std_logic_vector(7 downto 0):= "10101010";
 constant blink_mask: std_logic_vector(7 downto 0):= "00000011";
 -- 用于数码管显示的数字和状态
 signal floor_show1: std_logic_vector(3 downto 0):= "0000";
 signal state_show1: std_logic_vector(3 downto 0):= "0000";
 signal floor_show2: std_logic_vector(3 downto 0):= "0000";
 signal state_show2: std_logic_vector(3 downto 0):= "0000";
 signal floor_show3: std_logic_vector(3 downto 0):= "0000";
 signal state_show3: std_logic_vector(3 downto 0):= "0000";
 -- response to req_handler
 signal floor_response1: std_logic_vector(6 downto 1);   -- floor number response
 signal up_response1: std_logic_vector(6 downto 1);   ------------------------------------
 signal down_response1: std_logic_vector(6 downto 1);
 signal dir_response1: std_logic_vector(1 downto 0);
 signal floor_response2: std_logic_vector(6 downto 1);   -- floor number response
 signal up_response2: std_logic_vector(6 downto 1);   ------------------------------------
 signal down_response2: std_logic_vector(6 downto 1);
 signal dir_response2: std_logic_vector(1 downto 0);
 signal floor_response3: std_logic_vector(6 downto 1);   -- floor number response
 signal up_response3: std_logic_vector(6 downto 1);   -------------------------------------
 signal down_response3: std_logic_vector(6 downto 1);
 signal dir_response3: std_logic_vector(1 downto 0);
 -- input from req_handler
 signal up_request1: std_logic_vector(5 downto 0);
 signal down_request1: std_logic_vector(5 downto 0);
 signal up_request2: std_logic_vector(5 downto 0);
 signal down_request2: std_logic_vector(5 downto 0);
 signal up_request3: std_logic_vector(5 downto 0);
 signal down_request3: std_logic_vector(5 downto 0); 
begin
    clock_divider: entity work.ClockDivider
    port map(
        clk => clk,
        reset => reset,
        en_3hz => en_3hz
    );
    
    -- 显示拼接
    number <= floor_show1 & state_show1 & floor_show2 & state_show2 & floor_show3 & state_show3 & "00000000";
    
    ShuMaGuan: entity work.SevenSegDisplay
    port map(
        clk => clk,
        dp => dp,
        en_n => blink_mask,
        number => number,
        an => an,
        seg => seg
    );
    
    -- 请求处理模块
    Request_Handler: entity work.RequestHandler port map(
        clk => clk,
        -- in状态返回
        lift1_status => dir_response1,
        lift2_status => dir_response2,
        lift3_status => dir_response3,
        -- in楼层返回
        lift1_current_floor => floor_response1,
        lift2_current_floor => floor_response2,
        lift3_current_floor => floor_response3,
        -- out电梯外部按钮，需定义btn信号
        floor1_up => floor1_up,
        floor2_up => floor2_up, floor2_down => floor2_down,
        floor3_up => floor3_up, floor3_down => floor3_down,
        floor4_up => floor4_up, floor4_down => floor4_down,
        floor5_up => floor5_up, floor5_down => floor5_down,
        floor6_down => floor6_down,
        -- out电梯外部按钮led显示，需定义led信号
        floor1_up_led => floor1_up_led,
        floor2_up_led => floor2_up_led,
        floor2_down_led => floor2_down_led,
        floor3_up_led => floor3_up_led,
        floor3_down_led => floor3_down_led,
        floor4_up_led => floor4_up_led,
        floor4_down_led => floor4_down_led,
        floor5_up_led => floor5_up_led,
        floor5_down_led => floor5_down_led,
        floor6_down_led => floor6_down_led,
        
        -- out上升下降请求列表
--        lift1_up_request => up_request1,
        lift1_up_request(6) => up_request1(5),
        lift1_up_request(5) => up_request1(4),
        lift1_up_request(4) => up_request1(3),
        lift1_up_request(3) => up_request1(2),
        lift1_up_request(2) => up_request1(1),
        lift1_up_request(1) => up_request1(0),
--        lift1_down_request => down_request1,
        lift1_down_request(6) => down_request1(5),
        lift1_down_request(5) => down_request1(4),
        lift1_down_request(4) => down_request1(3),
        lift1_down_request(3) => down_request1(2),
        lift1_down_request(2) => down_request1(1),
        lift1_down_request(1) => down_request1(0),
--        lift2_up_request => up_request2,
        lift2_up_request(6) => up_request2(5),
        lift2_up_request(5) => up_request2(4),
        lift2_up_request(4) => up_request2(3),
        lift2_up_request(3) => up_request2(2),
        lift2_up_request(2) => up_request2(1),
        lift2_up_request(1) => up_request2(0),
--        lift2_down_request => down_request2,
        lift2_down_request(6) => down_request2(5),
        lift2_down_request(5) => down_request2(4),
        lift2_down_request(4) => down_request2(3),
        lift2_down_request(3) => down_request2(2),
        lift2_down_request(2) => down_request2(1),
        lift2_down_request(1) => down_request2(0),
--        lift3_up_request => up_request3,
        lift3_up_request(6) => up_request3(5),
        lift3_up_request(5) => up_request3(4),
        lift3_up_request(4) => up_request3(3),
        lift3_up_request(3) => up_request3(2),
        lift3_up_request(2) => up_request3(1),
        lift3_up_request(1) => up_request3(0),
--        lift3_down_request => down_request3,
        lift3_down_request(6) => down_request3(5),
        lift3_down_request(5) => down_request3(4),
        lift3_down_request(4) => down_request3(3),
        lift3_down_request(3) => down_request3(2),
        lift3_down_request(2) => down_request3(1),
        lift3_down_request(1) => down_request3(0),
        -- in上升下降列表返回
        lift1_up_response => up_response1,
        lift1_down_reponse => down_response1,
        lift2_up_response => up_response2,
        lift2_down_reponse => down_response2,
        lift3_up_response => up_response3,
        lift3_down_reponse => down_response3
    );
    
    lift1_control: entity work.lift1
    port map(
        clk => clk,
        reset => reset,
        up_req => up_request1,
        down_req => down_request1,
        en_3hz => en_3hz,
        internal_req(5) => btn61,
        internal_req(4) => btn51,
        internal_req(3) => btn41,
        internal_req(2) => btn31,
        internal_req(1) => btn21,
        internal_req(0) => btn11,
        -- response(need modify)________________________
        floor_resp => floor_response1,
        up_resp => up_response1,
        down_resp => down_response1,
        dir_resp => dir_response1,
        -- 外部显示
        floor_show1 => floor_show1,
        state_show1 => state_show1,
        led1_1 => led1_1,
        led2_1 => led2_1,
        led3_1 => led3_1,
        led4_1 => led4_1,
        led5_1 => led5_1,
        led6_1 => led6_1,
        state_led1 => state_led1    
        -- led输出直接写在contrain文件中
    );
    
    lift2_control: entity work.lift2
    port map(
        clk => clk,
        reset => reset,
        up_req => up_request2,
        down_req => down_request2,
        en_3hz => en_3hz,
        internal_req(5) => btn62,
        internal_req(4) => btn52,
        internal_req(3) => btn42,
        internal_req(2) => btn32,
        internal_req(1) => btn22,
        internal_req(0) => btn12,
        -- response(need modify)________________________
        floor_resp => floor_response2,
        up_resp => up_response2,
        down_resp => down_response2,
        dir_resp => dir_response2,
        -- 外部显示
        floor_show2 => floor_show2,
        state_show2 => state_show2,
        led1_2 => led1_2,
        led2_2 => led2_2,
        led3_2 => led3_2,
        led4_2 => led4_2,
        led5_2 => led5_2,
        led6_2 => led6_2,
        state_led2 => state_led2
        -- led输出直接写在contrain文件中
    );
    
    lift3_control: entity work.lift3
    port map(
        clk => clk,
        reset => reset,
        up_req => up_request3,
        down_req => down_request3,
        en_3hz => en_3hz,
        internal_req(5) => btn63,
        internal_req(4) => btn53,
        internal_req(3) => btn43,
        internal_req(2) => btn33,
        internal_req(1) => btn23,
        internal_req(0) => btn13,
        -- response(need modify)________________________
        floor_resp => floor_response3,
        up_resp => up_response3,
        down_resp => down_response3,
        dir_resp => dir_response3,
        -- 外部显示
        floor_show3 => floor_show3,
        state_show3 => state_show3,
        led1_3 => led1_3,
        led2_3 => led2_3,
        led3_3 => led3_3,
        led4_3 => led4_3,
        led5_3 => led5_3,
        led6_3 => led6_3,
        state_led3 => state_led3
        -- led输出直接写在contrain文件中
    );
    
    XiaoDou1_1: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn1_1,   -- btn1_1直接在constrain文件中连
        btn_out => btn11
    );
    
    XiaoDou2_1: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn2_1,   -- btn1_1直接在constrain文件中连
        btn_out => btn21
    ); 
    
    XiaoDou3_1: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn3_1,   -- btn1_1直接在constrain文件中连
        btn_out => btn31
    ); 
    
    XiaoDou4_1: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn4_1,   -- btn1_1直接在constrain文件中连
        btn_out => btn41
    ); 
    
    XiaoDou5_1: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn5_1,   -- btn1_1直接在constrain文件中连
        btn_out => btn51
    ); 
    
    XiaoDou6_1: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn6_1,   -- btn1_1直接在constrain文件中连
        btn_out => btn61
    );
    
    XiaoDou1_2: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn1_2,   -- btn1_1直接在constrain文件中连
        btn_out => btn12
    );
    
    XiaoDou2_2: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn2_2,   -- btn1_1直接在constrain文件中连
        btn_out => btn22
    );    
    
    XiaoDou3_2: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn3_2,   -- btn1_1直接在constrain文件中连
        btn_out => btn32
    );  
    
    XiaoDou4_2: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn4_2,   -- btn1_1直接在constrain文件中连
        btn_out => btn42
    );  
    
    XiaoDou5_2: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn5_2,   -- btn1_1直接在constrain文件中连
        btn_out => btn52
    );  
    
    XiaoDou6_2: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn6_2,   -- btn1_1直接在constrain文件中连
        btn_out => btn62
    );  
    
    XiaoDou1_3: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn1_3,   -- btn1_1直接在constrain文件中连
        btn_out => btn13
    );
    
    XiaoDou2_3: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn2_3,   -- btn1_1直接在constrain文件中连
        btn_out => btn23
    );  
    
    XiaoDou3_3: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn3_3,   -- btn1_1直接在constrain文件中连
        btn_out => btn33
    );  
    
    XiaoDou4_3: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn4_3,   -- btn1_1直接在constrain文件中连
        btn_out => btn43
    );  
    
    XiaoDou5_3: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn5_3,   -- btn1_1直接在constrain文件中连
        btn_out => btn53
    );  
    
    XiaoDou6_3: entity work.ButtonDebounce
    port map(
        clk => clk,
        btn_in => btn6_3,   -- btn1_1直接在constrain文件中连
        btn_out => btn63
    );  
    
    -- 外部上下请求消抖：消抖模块（每个按钮一个实例）
    floor_1_up: entity work.ButtonDebounce 
        port map(clk     => clk,
                 btn_in  => raw_floor1_up,
                 btn_out => floor1_up);
    
    floor_2_up: entity work.ButtonDebounce 
        port map (clk     => clk,
                  btn_in  => raw_floor2_up,
                  btn_out => floor2_up);
    
    floor_2_down: entity work.ButtonDebounce 
        port map (clk     => clk,
                  btn_in  => raw_floor2_down,
                  btn_out => floor2_down);
    
    floor_3_up: entity work.ButtonDebounce 
        port map (clk     => clk,
                  btn_in  => raw_floor3_up,
                  btn_out => floor3_up);
    
    floor_3_down: entity work.ButtonDebounce 
        port map (
            clk     => clk,
            btn_in  => raw_floor3_down,
            btn_out => floor3_down
        );
    
    floor_4_up: entity work.ButtonDebounce 
        port map (
            clk     => clk,
            btn_in  => raw_floor4_up,
            btn_out => floor4_up
        );
    
    floor_4_down: entity work.ButtonDebounce 
        port map (
            clk     => clk,
            btn_in  => raw_floor4_down,
            btn_out => floor4_down
        );
    
    floor_5_up: entity work.ButtonDebounce 
        port map (
            clk     => clk,
            btn_in  => raw_floor5_up,
            btn_out => floor5_up
        );
    
    floor_5_down: entity work.ButtonDebounce 
        port map (
            clk     => clk,
            btn_in  => raw_floor5_down,
            btn_out => floor5_down
        );
    
    floor_6_down: entity work.ButtonDebounce port map (
        clk     => clk,
        btn_in  => raw_floor6_down,
        btn_out => floor6_down);

end Behavioral;
