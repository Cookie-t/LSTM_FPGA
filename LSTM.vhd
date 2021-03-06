library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
use IEEE.numeric_std.all;

library work;
use work.neurals_utils.all;

entity LSTM is
  port (
	  clk   : in  std_logic;
    rst   : in  std_logic;
	  x     : in  matrix_1_4;
    h_old : in  matrix_1_8;
    c_old : in  matrix_1_8;
    c_new : out matrix_1_8;
    h_new : out matrix_1_8;
    ready : out std_logic
  ) ;
end entity ; -- LSTM

architecture arch of LSTM is

	component tanh_matrix_1_8 is
	    Port (
           clk : in std_logic;
           enable : in std_logic;
           input : in matrix_1_8;
           output : out matrix_1_8
        );
	end component;

	component sigmoid_matrix_1_8 is
    	Port (
           clk : in std_logic;
           enable : in std_logic;
           input : in matrix_1_8;
           output : out matrix_1_8
        );
	end component;

	component mul_mat_1_8 is
    Port (
           inputx : in matrix_1_8;
           inputy : in matrix_1_8;
           output : out matrix_1_8
    );
	end component;

	component add_mat_1_8 is
    Port (
           inputx : in matrix_1_8;
           inputy : in matrix_1_8;
           output : out matrix_1_8
    );
	end component;

	component sop is
    Port (
          clk : in std_logic;
          rst : in std_logic;
          X : in  matrix_1_4;
          W : in  matrix_4_8;
          H : in  matrix_1_8;
          U : in  matrix_8_8;
          B : in  matrix_1_8;
          O : out matrix_1_8
         );
  end component;


signal W_o : matrix_4_8;
signal W_i : matrix_4_8; -- 8_4
signal W_f : matrix_4_8;

signal U_o : matrix_8_8;
signal U_i : matrix_8_8;
signal U_f : matrix_8_8;

signal B_o : matrix_1_8;
signal B_i : matrix_1_8; -- 8_1
signal B_f : matrix_1_8;

signal O_t : matrix_1_8;
signal F_t : matrix_1_8;
signal U_c : matrix_8_8;

signal C_t : matrix_1_8;
signal I_t : matrix_1_8;
signal B_c : matrix_1_8; -- 8_1

signal tanh_ct : matrix_1_8;
signal candidate_value : matrix_1_8;
signal final_c : matrix_1_8;
signal forget : matrix_1_8;
signal input_1 : matrix_1_8;
signal output_1 : matrix_1_8;
signal mul_c_ft : matrix_1_8;
signal mul_It_Ct_1 : matrix_1_8;

signal WI, WF, WC, WO : matrix_4_8;
signal UI, UF, UC, UO : matrix_8_8;
signal BI, BF, BC, BO : matrix_1_8;

begin
tanh_c_2_h : tanh_matrix_1_8 port map (clk, '1', final_c, tanh_ct);
tanh_c_2_c : tanh_matrix_1_8 port map (clk, '1', candidate_value, C_t);

sigmoid_forget_ft : sigmoid_matrix_1_8 port map (clk, '1', forget, F_t);
sigmoid_input_it  : sigmoid_matrix_1_8 port map (clk, '1', input_1, I_t);
sigmoid_output_ot : sigmoid_matrix_1_8 port map (clk, '1', output_1, O_t);

mul_c_old_ft : mul_mat_1_8 port map (c_old, F_t, mul_c_ft);
mul_it_ct    : mul_mat_1_8 port map (I_t, C_t, mul_It_Ct_1);
mul_tanhc_ot : mul_mat_1_8 port map (O_t, tanh_ct, h_new);

add_m : add_mat_1_8 port map (mul_c_ft, mul_It_Ct_1, c_new);

WI <= init_WI; WF <= init_WF; WC <= init_WC; WO <= init_WO;
UI <= init_UI; UF <= init_UF; UC <= init_UC; UO <= init_UO;
BI <= init_BI; BF <= init_BF; BC <= init_BC; BO <= init_BO;

input_sop           : sop port map (clk, rst, x, WI, h_old, UI, BI, input_1); -- weight should be filled here
forget_sop          : sop port map (clk, rst, x, WF, h_old, UF, BF, forget); -- weight should be filled here
candidate_value_sop : sop port map (clk, rst, x, WC, h_old, UC, BC, candidate_value); -- weight should be filled here
output_sop          : sop port map (clk, rst, x, WO, h_old, UO, BO, output_1); -- weight should be filled here

end architecture ; -- arch