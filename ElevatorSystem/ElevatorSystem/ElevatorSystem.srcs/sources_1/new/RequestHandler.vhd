library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RequestHandler is
    Port(clk : in std_logic;
         lift1_status, lift2_status, lift3_status: in std_logic_vector(1 downto 0);
         lift1_current_floor, lift2_current_floor, lift3_current_floor: in std_logic_vector(6 downto 1);
         floor1_up: in std_logic;
         floor2_up, floor2_down: in std_logic;
         floor3_up, floor3_down: in std_logic;
         floor4_up, floor4_down: in std_logic;
         floor5_up, floor5_down: in std_logic;
         floor6_down: in std_logic;
         floor1_up_led    : out std_logic;
         floor2_up_led    : out std_logic;
         floor2_down_led  : out std_logic;
         floor3_up_led    : out std_logic;
         floor3_down_led  : out std_logic;
         floor4_up_led    : out std_logic;
         floor4_down_led  : out std_logic;
         floor5_up_led    : out std_logic;
         floor5_down_led  : out std_logic;
         floor6_down_led  : out std_logic;
         lift1_up_request, lift1_down_request: out std_logic_vector(6 downto 1);
         lift2_up_request, lift2_down_request: out std_logic_vector(6 downto 1);
         lift3_up_request, lift3_down_request: out std_logic_vector(6 downto 1);
         lift1_up_response, lift1_down_reponse: in std_logic_vector(6 downto 1);
         lift2_up_response, lift2_down_reponse: in std_logic_vector(6 downto 1);
         lift3_up_response, lift3_down_reponse: in std_logic_vector(6 downto 1));
end RequestHandler;

architecture Behavioral of RequestHandler is

signal total_up_request, total_up_next   : std_logic_vector(6 downto 1);
signal total_down_request, total_down_next : std_logic_vector(6 downto 1);
signal lift1_up_next, lift2_up_next, lift3_up_next : std_logic_vector(6 downto 1);
signal lift1_down_next, lift2_down_next, lift3_down_next : std_logic_vector(6 downto 1);

function is_up_valid(status : std_logic_vector(1 downto 0); pos, target : integer) return boolean is
begin
    return (status = "01" and target > pos);
end function;

function is_down_valid(status : std_logic_vector(1 downto 0); pos, target : integer) return boolean is
begin
    return (status = "10" and target < pos);
end function;

function run_distance(lift_floor : std_logic_vector(6 downto 1); req_floor : integer; lift_status : std_logic_vector(1 downto 0)) return integer is
    variable lift_pos : integer := 0;
begin
    for i in 1 to 6 loop
        if lift_floor(i) = '1' then lift_pos := i; end if;
    end loop;
    if lift_status = "01" then
        if req_floor >= lift_pos then
            return req_floor - lift_pos;
        else
            return (6 - lift_pos) + (6 - req_floor);
        end if;
    elsif lift_status = "10" then
        if req_floor <= lift_pos then
            return lift_pos - req_floor;
        else
            return (lift_pos - 1) + (req_floor - 1);
        end if;
    else
        return abs(lift_pos - req_floor);
    end if;
end function;

begin

-- 时序逻辑
process(clk)
begin
    if rising_edge(clk) then
        total_up_request <= total_up_next;
        total_down_request <= total_down_next;
        lift1_up_request <= lift1_up_next;
        lift2_up_request <= lift2_up_next;
        lift3_up_request <= lift3_up_next;
        lift1_down_request <= lift1_down_next;
        lift2_down_request <= lift2_down_next;
        lift3_down_request <= lift3_down_next;

        floor1_up_led    <= total_up_next(1);
        floor2_up_led    <= total_up_next(2);
        floor2_down_led  <= total_down_next(2);
        floor3_up_led    <= total_up_next(3);
        floor3_down_led  <= total_down_next(3);
        floor4_up_led    <= total_up_next(4);
        floor4_down_led  <= total_down_next(4);
        floor5_up_led    <= total_up_next(5);
        floor5_down_led  <= total_down_next(5);
        floor6_down_led  <= total_down_next(6);
    end if;
end process;

-- 组合逻辑
process(floor1_up, floor2_up, floor3_up, floor4_up, floor5_up,
    floor2_down, floor3_down, floor4_down, floor5_down, floor6_down)
variable dist1, dist2, dist3 : integer range 0 to 99;
variable chosen_lift : integer range 0 to 3;
variable lift1_pos, lift2_pos, lift3_pos : integer range 0 to 6 := 0;
begin
    lift1_pos := 0;
    lift2_pos := 0;
    lift3_pos := 0;
    -- 更新 total_*_next
    total_up_next <= total_up_request;
    total_down_next <= total_down_request;

    if floor1_up = '1' then total_up_next(1) <= '1'; end if;
    if floor2_up = '1' then total_up_next(2) <= '1'; end if;
    if floor3_up = '1' then total_up_next(3) <= '1'; end if;
    if floor4_up = '1' then total_up_next(4) <= '1'; end if;
    if floor5_up = '1' then total_up_next(5) <= '1'; end if;

    if floor2_down = '1' then total_down_next(2) <= '1'; end if;
    if floor3_down = '1' then total_down_next(3) <= '1'; end if;
    if floor4_down = '1' then total_down_next(4) <= '1'; end if;
    if floor5_down = '1' then total_down_next(5) <= '1'; end if;
    if floor6_down = '1' then total_down_next(6) <= '1'; end if;

    for i in 1 to 6 loop
        if lift1_up_response(i) = '0' and lift2_up_response(i) = '0' and lift3_up_response(i) = '0' then
            total_up_next(i) <='0';
        end if;
        if lift1_down_reponse(i) = '0' and lift2_down_reponse(i) = '0' and lift3_down_reponse(i) = '0' then
            total_down_next(i) <='0';
        end if;
    end loop;

    -- 获取电梯位置
    for j in 1 to 6 loop
        if lift1_current_floor(j) = '1' then lift1_pos := j; end if;
        if lift2_current_floor(j) = '1' then lift2_pos := j; end if;
        if lift3_current_floor(j) = '1' then lift3_pos := j; end if;
    end loop;

    lift1_up_next <= (others => '0');
    lift2_up_next <= (others => '0');
    lift3_up_next <= (others => '0');
    lift1_down_next <= (others => '0');
    lift2_down_next <= (others => '0');
    lift3_down_next <= (others => '0');

    for i in 1 to 6 loop
        if total_up_next(i) = '1' then
            dist1 := 99; dist2 := 99; dist3 := 99; chosen_lift := 0;
            if is_up_valid(lift1_status, lift1_pos, i) then dist1 := run_distance(lift1_current_floor, i, lift1_status); end if;
            if is_up_valid(lift2_status, lift2_pos, i) then dist2 := run_distance(lift2_current_floor, i, lift2_status); end if;
            if is_up_valid(lift3_status, lift3_pos, i) then dist3 := run_distance(lift3_current_floor, i, lift3_status); end if;
            if dist1 /= 99 or dist2 /= 99 or dist3 /= 99 then
                if dist1 <= dist2 and dist1 <= dist3 then chosen_lift := 1;
                elsif dist2 <= dist3 then chosen_lift := 2;
                else chosen_lift := 3; end if;
            else
                dist1 := run_distance(lift1_current_floor, i, lift1_status);
                dist2 := run_distance(lift2_current_floor, i, lift2_status);
                dist3 := run_distance(lift3_current_floor, i, lift3_status);
                if dist1 <= dist2 and dist1 <= dist3 then chosen_lift := 1;
                elsif dist2 <= dist3 then chosen_lift := 2;
                else chosen_lift := 3; end if;
            end if;
            case chosen_lift is
                when 1 => lift1_up_next(i) <= '1';
                when 2 => lift2_up_next(i) <= '1';
                when 3 => lift3_up_next(i) <= '1';
                when others => null;
            end case;
        end if;

        if total_down_next(i) = '1' then
            dist1 := 99; dist2 := 99; dist3 := 99; chosen_lift := 0;
            if is_down_valid(lift1_status, lift1_pos, i) then dist1 := run_distance(lift1_current_floor, i, lift1_status); end if;
            if is_down_valid(lift2_status, lift2_pos, i) then dist2 := run_distance(lift2_current_floor, i, lift2_status); end if;
            if is_down_valid(lift3_status, lift3_pos, i) then dist3 := run_distance(lift3_current_floor, i, lift3_status); end if;
            if dist1 /= 99 or dist2 /= 99 or dist3 /= 99 then
                if dist1 <= dist2 and dist1 <= dist3 then chosen_lift := 1;
                elsif dist2 <= dist3 then chosen_lift := 2;
                else chosen_lift := 3; end if;
            else
                dist1 := run_distance(lift1_current_floor, i, lift1_status);
                dist2 := run_distance(lift2_current_floor, i, lift2_status);
                dist3 := run_distance(lift3_current_floor, i, lift3_status);
                if dist1 <= dist2 and dist1 <= dist3 then chosen_lift := 1;
                elsif dist2 <= dist3 then chosen_lift := 2;
                else chosen_lift := 3; end if;
            end if;
            case chosen_lift is
                when 1 => lift1_down_next(i) <= '1';
                when 2 => lift2_down_next(i) <= '1';
                when 3 => lift3_down_next(i) <= '1';
                when others => null;
            end case;
        end if;
    end loop;
end process;

end Behavioral;
