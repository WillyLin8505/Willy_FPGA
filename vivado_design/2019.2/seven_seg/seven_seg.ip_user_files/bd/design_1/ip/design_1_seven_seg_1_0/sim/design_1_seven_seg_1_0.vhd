-- (c) Copyright 1995-2024 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:user:seven_seg:1.0
-- IP Revision: 9

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY design_1_seven_seg_1_0 IS
  PORT (
    clk : IN STD_LOGIC;
    rst_n : IN STD_LOGIC;
    i_button_add : IN STD_LOGIC;
    i_button_mis : IN STD_LOGIC;
    i_button_clr : IN STD_LOGIC;
    o_seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    o_seg_sel : OUT STD_LOGIC
  );
END design_1_seven_seg_1_0;

ARCHITECTURE design_1_seven_seg_1_0_arch OF design_1_seven_seg_1_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF design_1_seven_seg_1_0_arch: ARCHITECTURE IS "yes";
  COMPONENT seven_seg IS
    GENERIC (
      TOTAL_SEQ_NUM : INTEGER;
      MODE_SEL : INTEGER
    );
    PORT (
      clk : IN STD_LOGIC;
      rst_n : IN STD_LOGIC;
      i_button_add : IN STD_LOGIC;
      i_button_mis : IN STD_LOGIC;
      i_button_clr : IN STD_LOGIC;
      o_seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      o_seg_sel : OUT STD_LOGIC
    );
  END COMPONENT seven_seg;
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF design_1_seven_seg_1_0_arch: ARCHITECTURE IS "package_project";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF rst_n: SIGNAL IS "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF rst_n: SIGNAL IS "xilinx.com:signal:reset:1.0 rst_n RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF clk: SIGNAL IS "XIL_INTERFACENAME clk, FREQ_HZ 50000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF clk: SIGNAL IS "xilinx.com:signal:clock:1.0 clk CLK";
BEGIN
  U0 : seven_seg
    GENERIC MAP (
      TOTAL_SEQ_NUM => 2,
      MODE_SEL => 0
    )
    PORT MAP (
      clk => clk,
      rst_n => rst_n,
      i_button_add => i_button_add,
      i_button_mis => i_button_mis,
      i_button_clr => i_button_clr,
      o_seg => o_seg,
      o_seg_sel => o_seg_sel
    );
END design_1_seven_seg_1_0_arch;
