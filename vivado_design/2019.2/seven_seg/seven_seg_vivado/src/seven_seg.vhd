library ieee;                -- Reference the IEEE library
use ieee.std_logic_1164.all; -- Use the standard logic package
use ieee.numeric_std.all;
-- ===========================================================
-- ----------------------port define--------------------------
-- ===========================================================

entity seven_seg is
generic (
TOTAL_SEQ_NUM : integer := 2
);

port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    i_button_add : in  std_logic;
    i_button_mis : in  std_logic;
    i_button_clr : in  std_logic;
    o_seg_1      : out std_logic_vector(6 downto 0);
    o_seg_2      : out std_logic_vector(6 downto 0)
);
end seven_seg;

-- ===========================================================
-- ----------------------architecture-------------------------
-- ===========================================================
architecture behavior of seven_seg is
---------------------------------------------------------------------------------------------------define wire and reg 

type seq_name is (zero, one, two, three, four, five, six, seven, eight, nine);
type seq_array is array (seq_name) of std_logic_vector(6 downto 0);
constant seq_num : seq_array := (
    zero  => "0111111",
    one   => "0000110",
    two   => "1011011",
    three => "1001111",
    four  => "1100110",
    five  => "1101101",
    six   => "1111101",
    seven => "0000111",
    eight => "1111111",
    nine  => "1101111"
);

--------------------------------------------------------------------------------------counter 
signal deb_cnt               : std_logic_vector(4 downto 0);
signal deb_cnt_nxt           : std_logic_vector(4 downto 0);
signal deb_cnt_inc           : std_logic;
signal deb_cnt_clr           : std_logic;
signal deb_cnt_clr_ext       : std_logic_vector(deb_cnt'length - 1 downto 0);

signal seq_1st_cnt           : std_logic_vector(3 downto 0);
signal seq_1st_cnt_nxt       : std_logic_vector(3 downto 0);
signal seq_1st_cnt_inc       : std_logic;
signal seq_1st_cnt_clr       : std_logic;
signal seq_1st_cnt_clr_ext   : std_logic_vector(seq_1st_cnt'length - 1 downto 0);
signal seq_1st_cnt_set       : std_logic;
signal seq_1st_cnt_set_num   : std_logic_vector(3 downto 0);

signal seq_2nd_cnt           : std_logic_vector(3 downto 0);
signal seq_2nd_cnt_nxt       : std_logic_vector(3 downto 0);
signal seq_2nd_cnt_inc       : std_logic;
signal seq_2nd_cnt_clr       : std_logic;
signal seq_2nd_cnt_clr_ext   : std_logic_vector(seq_2nd_cnt'length - 1 downto 0);

--------------------------------------------------------------------------------------equalizer
signal deb_cnt_0_eq          : std_logic;
signal deb_cnt_30_eq         : std_logic;
signal deb_cnt_31_eq         : std_logic;
signal seq_1st_0_cnt_eq      : std_logic;
signal seq_1st_9_cnt_eq      : std_logic;
signal seq_2nd_0_cnt_eq      : std_logic;
signal seq_1st_cnt_9_to_0_eq : std_logic;
signal seq_1st_cnt_0_to_9_eq : std_logic;

signal button_add_1_eq       : std_logic;
signal button_mis_1_eq       : std_logic;
signal button_clr_1_eq       : std_logic;
signal button_add_0_eq       : std_logic;
signal button_mis_0_eq       : std_logic;
signal button_clr_0_eq       : std_logic;

constant full_1_8bits_con    : std_logic_vector(7 downto 0) := (others => '1');
constant full_0_8bits_con    : std_logic_vector(7 downto 0) := (others => '0');

--------------------------------------------------------------------------------------others 
signal deb_trg               : std_logic;
signal button_add_com      : std_logic_vector(7 downto 0);
signal button_mis_com      : std_logic_vector(7 downto 0);
signal button_clr_com      : std_logic_vector(7 downto 0);

signal deb_add               : std_logic;
signal deb_mis               : std_logic;
signal deb_clr               : std_logic;
signal cnt_1st_add_minus_sgn : std_logic_vector(1 downto 0);
signal cnt_2nd_add_minus_sgn : std_logic_vector(1 downto 0);
signal cnt_com               : std_logic_vector(seq_1st_cnt'length + seq_2nd_cnt'length - 1 downto 0);
signal seg_com               : std_logic_vector(TOTAL_SEQ_NUM*7 - 1 downto 0);

--------------------------------------------------------------------------------------output signal
signal o_seg_1_nxt           : std_logic_vector(6 downto 0);
signal o_seg_2_nxt           : std_logic_vector(6 downto 0);

---------------------------------------------------------------------------------------------------start the design 
begin
--------------------------------------------------------------------------------------counter 


deb_cnt_nxt           <= deb_cnt_clr_ext when deb_cnt_clr = '1' else
                         std_logic_vector(unsigned(deb_cnt) + to_unsigned(1, deb_cnt'length)) when (deb_cnt_inc = '1') else 
                         deb_cnt;
deb_cnt_inc           <= (button_add_1_eq or button_mis_1_eq or button_clr_1_eq) and not(deb_cnt_31_eq);
deb_cnt_clr           <= (button_add_0_eq and button_mis_0_eq and button_clr_0_eq);
deb_cnt_clr_ext       <= (others => not(deb_cnt_clr));
      
seq_1st_cnt_nxt       <= seq_1st_cnt_clr_ext when seq_1st_cnt_clr = '1' else
                         seq_1st_cnt_set_num when seq_1st_cnt_set = '1' else
                         std_logic_vector(signed(seq_1st_cnt) + resize(signed(cnt_1st_add_minus_sgn), seq_1st_cnt'length)) when seq_1st_cnt_inc = '1' else
                         seq_1st_cnt;
  
seq_1st_cnt_inc       <= deb_add or deb_mis;
seq_1st_cnt_clr       <= deb_clr or seq_1st_cnt_9_to_0_eq;
seq_1st_cnt_clr_ext   <= (others => not(seq_1st_cnt_clr));
seq_1st_cnt_set       <= seq_1st_cnt_0_to_9_eq;
seq_1st_cnt_set_num   <= std_logic_vector(to_unsigned(9, seq_1st_cnt'length));
  
seq_2nd_cnt_nxt       <= seq_2nd_cnt_clr_ext when seq_2nd_cnt_clr = '1' else
                         std_logic_vector(signed(seq_2nd_cnt) + resize(signed(cnt_2nd_add_minus_sgn), seq_2nd_cnt'length)) when seq_2nd_cnt_inc = '1' else
                         seq_2nd_cnt;
seq_2nd_cnt_inc       <= seq_1st_cnt_9_to_0_eq or seq_1st_cnt_0_to_9_eq;
seq_2nd_cnt_clr       <= deb_clr;
seq_2nd_cnt_clr_ext   <= (others => not(seq_2nd_cnt_clr));

--------------------------------------------------------------------------------------equalizer
deb_cnt_0_eq          <= '1' when unsigned(deb_cnt) = to_unsigned(0, deb_cnt'length)  else '0';
deb_cnt_31_eq         <= '1' when unsigned(deb_cnt) = to_unsigned(31, deb_cnt'length) else '0';
seq_1st_0_cnt_eq      <= '1' when unsigned(seq_1st_cnt) = to_unsigned(0, seq_1st_cnt'length) else '0';
seq_1st_9_cnt_eq      <= '1' when unsigned(seq_1st_cnt) = to_unsigned(9, seq_1st_cnt'length) else '0';
seq_2nd_0_cnt_eq      <= '1' when unsigned(seq_2nd_cnt) = to_unsigned(0, seq_2nd_cnt'length) else '0';
deb_cnt_30_eq         <= '1' when unsigned(deb_cnt) = to_unsigned(30, deb_cnt'length) else '0';

seq_1st_cnt_9_to_0_eq <= '1' when (seq_1st_9_cnt_eq = '1' and deb_add = '1') else '0';
seq_1st_cnt_0_to_9_eq <= '1' when (seq_1st_0_cnt_eq = '1' and deb_mis = '1' and not(seq_2nd_0_cnt_eq = '1'))else '0';

button_add_1_eq       <= '1' when unsigned(button_add_com) = unsigned(full_1_8bits_con) else '0';
button_mis_1_eq       <= '1' when unsigned(button_mis_com) = unsigned(full_1_8bits_con) else '0';
button_clr_1_eq       <= '1' when unsigned(button_clr_com) = unsigned(full_1_8bits_con) else '0';
button_add_0_eq       <= '1' when unsigned(button_add_com) = unsigned(full_0_8bits_con) else '0';
button_mis_0_eq       <= '1' when unsigned(button_mis_com) = unsigned(full_0_8bits_con) else '0';
button_clr_0_eq       <= '1' when unsigned(button_clr_com) = unsigned(full_0_8bits_con) else '0';

--------------------------------------------------------------------------------------others 
deb_trg               <= deb_cnt_30_eq;

button_add_com        <= button_add_com(button_add_com'length-2 downto 0) & i_button_add;
button_mis_com        <= button_mis_com(button_mis_com'length-2 downto 0) & i_button_mis;
button_clr_com        <= button_clr_com(button_clr_com'length-2 downto 0) & i_button_clr;

deb_add               <= (deb_trg) and i_button_add;
deb_mis               <= (deb_trg) and i_button_mis;
deb_clr               <= (deb_trg) and i_button_clr;

cnt_1st_add_minus_sgn <= i_button_mis & '1';
cnt_2nd_add_minus_sgn <= seq_1st_cnt_0_to_9_eq & '1';

---------------------------------------------------------------------------------------------------convert the number to 7 segment
cnt_com               <= seq_2nd_cnt & seq_1st_cnt;

process (cnt_com) begin

seg_com <= (others => '0');

for index in 0 to TOTAL_SEQ_NUM - 1 loop
case to_integer(unsigned(cnt_com((index + 1) * seq_1st_cnt'length - 1 downto index * seq_1st_cnt'length))) is
    when 0      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(zero);
    when 1      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(one);
    when 2      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(two);
    when 3      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(three);
    when 4      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(four);
    when 5      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(five);
    when 6      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(six);
    when 7      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(seven);
    when 8      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(eight);
    when 9      => seg_com((index + 1) * 7 - 1 downto index * 7)      <= seq_num(nine);
    when others => seg_com((index + 1) * 7 - 1 downto index * 7)      <= (others => '0');
end case;
end loop;
end process;

---------------------------------------------------------------------------------------------------output signal 

o_seg_1_nxt <= seg_com(7-1 downto 0);
o_seg_2_nxt <= seg_com(TOTAL_SEQ_NUM*7-1 downto (TOTAL_SEQ_NUM-1)*7);

---------------------------------------------------------------------------------------------------sequencial logic

process (clk, rst_n) begin
if (rst_n = '0') then
    deb_cnt     <= (others => '0');
    seq_1st_cnt <= (others => '0');
    seq_2nd_cnt <= (others => '0');
    o_seg_1     <= seq_num(zero);
    o_seg_2     <= seq_num(zero);
elsif (rising_edge(clk)) then
    deb_cnt     <= deb_cnt_nxt;
    seq_1st_cnt <= seq_1st_cnt_nxt;
    seq_2nd_cnt <= seq_2nd_cnt_nxt;
    o_seg_1     <= o_seg_1_nxt;
    o_seg_2     <= o_seg_2_nxt;
end if;
end process;

end architecture behavior;
