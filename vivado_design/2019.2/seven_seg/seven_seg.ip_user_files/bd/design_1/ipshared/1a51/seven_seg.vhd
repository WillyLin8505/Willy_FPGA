-- vhdl-linter-disable type-resolved
library ieee;                -- Reference the IEEE library
use ieee.std_logic_1164.all; -- Use the standard logic package
use ieee.numeric_std.all;
-- ===========================================================
-- ----------------------port define--------------------------
-- ===========================================================

entity seven_seg is
generic (
TOTAL_SEQ_NUM : integer := 2;
MODE_SEL      : integer := 0  --0: normal mode 
                              --1: debug mode 
);

port (
    clk          : in  std_logic;
    rst_n        : in  std_logic; -- vhdl-linter-disable-line type-resolved
    i_button_add : in  std_logic;
    i_button_mis : in  std_logic;
    i_button_clr : in  std_logic;
    o_seg        : out std_logic_vector(6 downto 0);
    o_seg_sel    : out std_logic
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
signal always_cnt            : std_logic_vector(2 downto 0);
signal always_cnt_nxt        : std_logic_vector(2 downto 0);
signal always_cnt_inc        : std_logic;
signal always_cnt_clr        : std_logic;
signal always_cnt_clr_ext    : std_logic_vector(always_cnt'length - 1 downto 0);

signal deb_cnt               : std_logic_vector(16 downto 0); --CLOCK_FREQ(10MHZ)*CLOCK_FREQ(10ms) = 100k
signal deb_cnt_nxt           : std_logic_vector(16 downto 0);
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
signal seq_1st_0_cnt_eq      : std_logic;
signal seq_1st_9_cnt_eq      : std_logic;
signal seq_2nd_0_cnt_eq      : std_logic;
signal seq_2nd_9_cnt_eq      : std_logic;
signal seq_1st_cnt_9_to_0_eq : std_logic;
signal seq_1st_cnt_0_to_9_eq : std_logic;

signal button_add_1_eq       : std_logic;
signal button_mis_1_eq       : std_logic;
signal button_clr_1_eq       : std_logic;

signal deb_cnt_max_eq        : std_logic;
signal deb_cnt_max_minus1_eq : std_logic;

--------------------------------------------------------------------------------------others 
signal deb_trg               : std_logic;
signal cnt_1st_add_minus_sgn : std_logic_vector(1 downto 0);
signal cnt_2nd_add_minus_sgn : std_logic_vector(1 downto 0);
signal cnt_com               : std_logic_vector(seq_1st_cnt'length + seq_2nd_cnt'length - 1 downto 0);
signal seg_com               : std_logic_vector(TOTAL_SEQ_NUM*7 - 1 downto 0);

signal deb_keep              : std_logic_vector(1 downto 0);
signal deb_keep_nxt          : std_logic_vector(1 downto 0);

signal deb_cnt_max           : std_logic_vector(deb_cnt'length - 1 downto 0);

signal seg_sel               : std_logic;

signal seg_1                 : std_logic_vector(6 downto 0);
signal seg_2                 : std_logic_vector(6 downto 0);
--------------------------------------------------------------------------------------output signal
signal o_seg_nxt             : std_logic_vector(6 downto 0);
signal o_seg_sel_nxt         : std_logic;

---------------------------------------------------------------------------------------------------start the design 
begin
--------------------------------------------------------------------------------------counter 
always_cnt_nxt        <= always_cnt_clr_ext when always_cnt_clr = '1' else --this counter for o_seg_sel , choose the seven_seg 
                         std_logic_vector(unsigned(always_cnt) + to_unsigned(1, always_cnt'length)) when (always_cnt_inc = '1') else 
                         always_cnt;
always_cnt_inc        <= '1';
always_cnt_clr        <= '0';
always_cnt_clr_ext    <= (others => not(always_cnt_clr));

deb_cnt_nxt           <= deb_cnt_clr_ext when deb_cnt_clr = '1' else  --debouncer counter 
                         std_logic_vector(unsigned(deb_cnt) + to_unsigned(1, deb_cnt'length)) when (deb_cnt_inc = '1') else 
                         deb_cnt;
deb_cnt_inc           <= deb_keep(0) and not(deb_cnt_max_eq);
deb_cnt_clr           <= deb_keep(1) xor deb_keep(0);
deb_cnt_clr_ext       <= (others => not(deb_cnt_clr));
      
seq_1st_cnt_nxt       <= seq_1st_cnt_clr_ext when seq_1st_cnt_clr = '1' else --for the first seven_seg
                         seq_1st_cnt_set_num when seq_1st_cnt_set = '1' else
                         std_logic_vector(signed(seq_1st_cnt) + resize(signed(cnt_1st_add_minus_sgn), seq_1st_cnt'length)) when seq_1st_cnt_inc = '1' else
                         seq_1st_cnt;
seq_1st_cnt_inc       <= (button_add_1_eq and not(seq_1st_9_cnt_eq and seq_2nd_9_cnt_eq)) or (button_mis_1_eq and not(seq_1st_0_cnt_eq and seq_2nd_0_cnt_eq));
seq_1st_cnt_clr       <= button_clr_1_eq or seq_1st_cnt_9_to_0_eq;
seq_1st_cnt_clr_ext   <= (others => not(seq_1st_cnt_clr));
seq_1st_cnt_set       <= seq_1st_cnt_0_to_9_eq;
seq_1st_cnt_set_num   <= std_logic_vector(to_unsigned(9, seq_1st_cnt'length));
  
seq_2nd_cnt_nxt       <= seq_2nd_cnt_clr_ext when seq_2nd_cnt_clr = '1' else --for the second seven_seg
                         std_logic_vector(signed(seq_2nd_cnt) + resize(signed(cnt_2nd_add_minus_sgn), seq_2nd_cnt'length)) when seq_2nd_cnt_inc = '1' else
                         seq_2nd_cnt;
seq_2nd_cnt_inc       <= seq_1st_cnt_9_to_0_eq or seq_1st_cnt_0_to_9_eq;
seq_2nd_cnt_clr       <= button_clr_1_eq;
seq_2nd_cnt_clr_ext   <= (others => not(seq_2nd_cnt_clr));

--------------------------------------------------------------------------------------equalizer
seq_1st_0_cnt_eq      <= '1' when unsigned(seq_1st_cnt) = to_unsigned(0, seq_1st_cnt'length) else '0';
seq_1st_9_cnt_eq      <= '1' when unsigned(seq_1st_cnt) = to_unsigned(9, seq_1st_cnt'length) else '0';
seq_2nd_0_cnt_eq      <= '1' when unsigned(seq_2nd_cnt) = to_unsigned(0, seq_2nd_cnt'length) else '0';
seq_2nd_9_cnt_eq      <= '1' when unsigned(seq_2nd_cnt) = to_unsigned(9, seq_2nd_cnt'length) else '0';

seq_1st_cnt_9_to_0_eq <= '1' when (seq_1st_9_cnt_eq = '1' and button_add_1_eq = '1' and not(seq_1st_9_cnt_eq = '1' and seq_2nd_9_cnt_eq = '1')) else '0';
seq_1st_cnt_0_to_9_eq <= '1' when (seq_1st_0_cnt_eq = '1' and button_mis_1_eq = '1' and not(seq_2nd_0_cnt_eq = '1'))else '0';

button_add_1_eq       <= i_button_add when deb_trg = '1' else '0';
button_mis_1_eq       <= i_button_mis when deb_trg = '1' else '0';
button_clr_1_eq       <= i_button_clr when deb_trg = '1' else '0';

deb_cnt_max_eq        <= '1' when unsigned(deb_cnt) = unsigned(deb_cnt_max) else '0';
deb_cnt_max_minus1_eq <= '1' when (MODE_SEL = 0) and (unsigned(deb_cnt) = unsigned(deb_cnt_max) - to_unsigned(1, deb_cnt'length)) else 
                         '1' when (MODE_SEL = 1) and (unsigned(deb_cnt) = to_unsigned(49, deb_cnt'length)) else '0';
--------------------------------------------------------------------------------------others 
deb_keep_nxt          <= deb_keep(0) & (i_button_add or i_button_mis or i_button_clr);
deb_cnt_max           <= std_logic_vector(to_unsigned(50, deb_cnt_max'length)) when MODE_SEL = 1 else (others => '1');

deb_trg               <= deb_cnt_max_minus1_eq;

cnt_1st_add_minus_sgn <= i_button_mis & '1';
cnt_2nd_add_minus_sgn <= seq_1st_cnt_0_to_9_eq & '1';

seg_sel               <= always_cnt(2);

--------------------------------------------------------------------------------------convert the number to 7 segment
cnt_com               <= seq_2nd_cnt & seq_1st_cnt;

process (cnt_com) begin

seg_com               <= (others => '0');

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

seg_1         <= seg_com(7-1 downto 0);
seg_2         <= seg_com(TOTAL_SEQ_NUM*7-1 downto (TOTAL_SEQ_NUM-1)*7);

--------------------------------------------------------------------------------------output signal 
o_seg_nxt     <= seg_1 when seg_sel = '0' else seg_2;
o_seg_sel_nxt <= seg_sel;

--------------------------------------------------------------------------------------sequencial logic

process (clk, rst_n) begin
if (rst_n = '0') then

    always_cnt  <= (others => '0');
    deb_cnt     <= (others => '0');
    seq_1st_cnt <= (others => '0');
    seq_2nd_cnt <= (others => '0');

    deb_keep    <= (others => '0');

    o_seg       <= seq_num(zero);
    o_seg_sel   <= '0';

elsif (rising_edge(clk)) then

    always_cnt  <= always_cnt_nxt;
    deb_cnt     <= deb_cnt_nxt;
    seq_1st_cnt <= seq_1st_cnt_nxt;
    seq_2nd_cnt <= seq_2nd_cnt_nxt;

    deb_keep    <= deb_keep_nxt;

    o_seg       <= o_seg_nxt;
    o_seg_sel   <= o_seg_sel_nxt;

end if;
end process;
end architecture behavior;
