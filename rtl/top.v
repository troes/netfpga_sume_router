//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Company      :   Hangzhou Chenxiao Technologies Co, Ltd.
// Project      :   SOHM155x8
// File Name    :   audyctl.v
// Author       :   ASIC man
// E-Mail       :   asic@chenxiaotech.com
// Description  :   AU DELAY CONTROLER,only support 2*OC3
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// $Log: $
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Including files
//~~~~~~~~~~~~~~~~~~~~~~~~~~~

`include "defines.v"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Module list
//~~~~~~~~~~~~~~~~~~~~~~~~~~~
module GTP_GE_TOP #
(
    parameter EXAMPLE_SIM_GTRESET_SPEEDUP          =   "FALSE",    // simulation setting for GT SecureIP model
    parameter STABLE_CLOCK_PERIOD                  = 10
)
(
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Input Pins
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~
    input           clk100m,
    input           clk125m,
    input           gtp_refclk,
    input   [15:0]  soft_rst,
    input   [15:0]  loop,        //16bit,bit2-0 for GTP channel #0
    input   [3:0]   rxd_p,
    input   [3:0]   rxd_n,
    input   [9:0]   din_0,        //20bit from GE TMAC #0
    input   [9:0]   din_1,        //20bit from GE TMAC #1
    input   [9:0]   din_2,        //20bit from GE TMAC #2
    input   [9:0]   din_3,        //20bit from GE TMAC #3
    
    input           gt0_pll0outclk_i,
    input           gt0_pll0outrefclk_i,
    output          gt0_pll0reset_i,
    input           gt0_pll0lock_i,
    input           gt0_pll0refclklost_i,
    input           gt0_pll1outclk_i,
    input           gt0_pll1outrefclk_i,
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Output Pins
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~
    output          k_ind_0,
    output          k_ind_1,
    output          k_ind_2,
    output          k_ind_3,
    output  [7:0]   d2mac_0,       //8bit to GE RMAC #0
    output  [7:0]   d2mac_1,       //8bit to GE RMAC #1
    output  [7:0]   d2mac_2,       //8bit to GE RMAC #2
    output  [7:0]   d2mac_3,       //8bit to GE RMAC #3
    output  [3:0]   txd_p,
    output  [3:0]   txd_n,

    output  [1:0]   rx_rec_clk,
    output  [3:0]   gtp_lock,
    output  [15:0]  reset_done,
    output  [3:0]   rxbyteisaligned_out,
    output  [2:0]   gt0_rxbufstatus_out,
    output  [2:0]   gt1_rxbufstatus_out,
    output  [2:0]   gt2_rxbufstatus_out,
    output  [2:0]   gt3_rxbufstatus_out,
    output  [1:0]   gt0_txbufstatus_out,
    output  [1:0]   gt1_txbufstatus_out,
    output  [1:0]   gt2_txbufstatus_out,
    output  [1:0]   gt3_txbufstatus_out
);
//~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Parameters
//~~~~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Internal signals
//~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire            gt3_tx_fsm_reset_done_out;
wire            gt3_rx_fsm_reset_done_out;
wire            gt3_txresetdone_out;
wire            gt3_rxresetdone_out;
wire            gt2_tx_fsm_reset_done_out;
wire            gt2_rx_fsm_reset_done_out;
wire            gt2_txresetdone_out;
wire            gt2_rxresetdone_out;
wire            gt1_tx_fsm_reset_done_out;
wire            gt1_rx_fsm_reset_done_out;
wire            gt1_txresetdone_out;
wire            gt1_rxresetdone_out;
wire            gt0_tx_fsm_reset_done_out;
wire            gt0_rx_fsm_reset_done_out;
wire            gt0_txresetdone_out;
wire            gt0_rxresetdone_out;

wire            gt0_rxresetdone_i;
wire            gt1_rxresetdone_i;
wire            gt2_rxresetdone_i;
wire            gt3_rxresetdone_i;
wire            gt0_data_valid_in;
wire            gt1_data_valid_in;
wire            gt2_data_valid_in;
wire            gt3_data_valid_in;
wire            gt0_rxbyteisaligned_out;
wire            gt1_rxbyteisaligned_out;
wire            gt2_rxbyteisaligned_out;
wire            gt3_rxbyteisaligned_out;

reg             gt0_rxresetdone_r;
reg             gt0_rxresetdone_r2;
reg             gt0_rxresetdone_r3;
reg             gt1_rxresetdone_r;
reg             gt1_rxresetdone_r2;
reg             gt1_rxresetdone_r3;
reg             gt2_rxresetdone_r;
reg             gt2_rxresetdone_r2;
reg             gt2_rxresetdone_r3;
reg             gt3_rxresetdone_r;
reg             gt3_rxresetdone_r2;
reg             gt3_rxresetdone_r3;

reg             gt0_system_reset_r; 
reg             gt0_system_reset_r2;
reg             gt1_system_reset_r; 
reg             gt1_system_reset_r2;
reg             gt2_system_reset_r; 
reg             gt2_system_reset_r2;
reg             gt3_system_reset_r; 
reg             gt3_system_reset_r2;

reg     [3:0]   rxen_com_align;
wire            clk62m5;
wire    [19:0]  din_0_w;        //20bit from GE TMAC #0
wire    [19:0]  din_1_w;        //20bit from GE TMAC #1
wire    [19:0]  din_2_w;        //20bit from GE TMAC #2
wire    [19:0]  din_3_w;        //20bit from GE TMAC #3
wire    [1:0]   k_ind_0_w;
wire    [1:0]   k_ind_1_w;
wire    [1:0]   k_ind_2_w;
wire    [1:0]   k_ind_3_w;
wire    [15:0]  d2mac_0_w;       //8bit to GE RMAC #0
wire    [15:0]  d2mac_1_w;       //8bit to GE RMAC #1
wire    [15:0]  d2mac_2_w;       //8bit to GE RMAC #2
wire    [15:0]  d2mac_3_w;       //8bit to GE RMAC #3
//~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Coding text
//~~~~~~~~~~~~~~~~~~~~~~~~~~~

//wire gt0_pll0lock_i;
wire cpll_reset_pll0_q0_clk1_refclk_i;
wire commonreset_i;
wire cpll_pd_pll0_q0_clk1_refclk_i;
wire gt1_rxoutclk_out;
wire gt0_rxoutclk_out;
assign  gtp_lock[3:0]   =   {2'd0,1'b1,gt0_pll0lock_i};
assign  rx_rec_clk[1:0] =   {gt1_rxoutclk_out,gt0_rxoutclk_out};

assign  reset_done[15:0]=   {   
                                gt3_tx_fsm_reset_done_out,
                                gt3_rx_fsm_reset_done_out,
                                gt3_txresetdone_out,
                                gt3_rxresetdone_out,
                                gt2_tx_fsm_reset_done_out,
                                gt2_rx_fsm_reset_done_out,
                                gt2_txresetdone_out,
                                gt2_rxresetdone_out,
                                gt1_tx_fsm_reset_done_out,
                                gt1_rx_fsm_reset_done_out,
                                gt1_txresetdone_out,
                                gt1_rxresetdone_out,
                                gt0_tx_fsm_reset_done_out,
                                gt0_rx_fsm_reset_done_out,
                                gt0_txresetdone_out,
                                gt0_rxresetdone_out
                            };


assign  gt0_rxresetdone_i   =   gt0_rxresetdone_out;
assign  gt1_rxresetdone_i   =   gt1_rxresetdone_out;
assign  gt2_rxresetdone_i   =   gt2_rxresetdone_out;
assign  gt3_rxresetdone_i   =   gt3_rxresetdone_out;

assign  gt0_data_valid_in   =   1'b1;
assign  gt1_data_valid_in   =   1'b1;
assign  gt2_data_valid_in   =   1'b1;
assign  gt3_data_valid_in   =   1'b1;

assign  rxbyteisaligned_out[3:0]    =   {
                                            gt3_rxbyteisaligned_out,
                                            gt2_rxbyteisaligned_out,
                                            gt1_rxbyteisaligned_out,
                                            gt0_rxbyteisaligned_out
                                        };

//~~~~~~~~~~~~~~~~~~~~~~~~~~
// Module Instantiation
//~~~~~~~~~~~~~~~~~~~~~~~~~~

//  clock generation
BUFG            U_TXOUTCLK_BUFG0
(
    .I          (gt0_txoutclk_out),
    .O          (clk62m5)
);


//  enable COMMA Align, using rxresetdone;
always @(posedge  clk62m5 or negedge gt0_rxresetdone_i)
begin
    if (!gt0_rxresetdone_i)
    begin
        gt0_rxresetdone_r    <=   1'b0;
        gt0_rxresetdone_r2   <=   1'b0;
        gt0_rxresetdone_r3   <=   1'b0;
    end
    else
    begin
        gt0_rxresetdone_r    <=   gt0_rxresetdone_i;
        gt0_rxresetdone_r2   <=   gt0_rxresetdone_r;
        gt0_rxresetdone_r3   <=   gt0_rxresetdone_r2;
    end
end

always @(posedge  clk62m5 or negedge gt1_rxresetdone_i)
begin
    if (!gt1_rxresetdone_i)
    begin
        gt1_rxresetdone_r    <=   1'b0;
        gt1_rxresetdone_r2   <=   1'b0;
        gt1_rxresetdone_r3   <=   1'b0;
    end
    else
    begin
        gt1_rxresetdone_r    <=   gt1_rxresetdone_i;
        gt1_rxresetdone_r2   <=   gt1_rxresetdone_r;
        gt1_rxresetdone_r3   <=   gt1_rxresetdone_r2;
    end
end

always @(posedge  clk62m5 or negedge gt2_rxresetdone_i)
begin
    if (!gt2_rxresetdone_i)
    begin
        gt2_rxresetdone_r    <=   1'b0;
        gt2_rxresetdone_r2   <=   1'b0;
        gt2_rxresetdone_r3   <=   1'b0;
    end
    else
    begin
        gt2_rxresetdone_r    <=   gt2_rxresetdone_i;
        gt2_rxresetdone_r2   <=   gt2_rxresetdone_r;
        gt2_rxresetdone_r3   <=   gt2_rxresetdone_r2;
    end
end

always @(posedge  clk62m5 or negedge gt3_rxresetdone_i)
begin
    if (!gt3_rxresetdone_i)
    begin
        gt3_rxresetdone_r    <=   1'b0;
        gt3_rxresetdone_r2   <=   1'b0;
        gt3_rxresetdone_r3   <=   1'b0;
    end
    else
    begin
        gt3_rxresetdone_r    <=   gt3_rxresetdone_i;
        gt3_rxresetdone_r2   <=   gt3_rxresetdone_r;
        gt3_rxresetdone_r3   <=   gt3_rxresetdone_r2;
    end
end

always@(posedge clk62m5)
begin
    gt0_system_reset_r  <=  ~gt0_rxresetdone_r3;    
    gt0_system_reset_r2 <=  gt0_system_reset_r; 
    
    gt1_system_reset_r  <=  ~gt1_rxresetdone_r3;    
    gt1_system_reset_r2 <=  gt1_system_reset_r; 
    
    gt2_system_reset_r  <=  ~gt2_rxresetdone_r3;    
    gt2_system_reset_r2 <=  gt2_system_reset_r; 
    
    gt3_system_reset_r  <=  ~gt3_rxresetdone_r3;    
    gt3_system_reset_r2 <=  gt3_system_reset_r; 
end   

always @(posedge clk62m5)
begin
    if (gt0_system_reset_r2)    rxen_com_align[0]   <=  1'b0;
    else                        rxen_com_align[0]   <=  1'b1;
    
    if (gt1_system_reset_r2)    rxen_com_align[1]   <=  1'b0;
    else                        rxen_com_align[1]   <=  1'b1;
    
    if (gt2_system_reset_r2)    rxen_com_align[2]   <=  1'b0;
    else                        rxen_com_align[2]   <=  1'b1;
    
    if (gt3_system_reset_r2)    rxen_com_align[3]   <=  1'b0;
    else                        rxen_com_align[3]   <=  1'b1;
end


//  interface width transfer;
GTP_ADPT                U_GTP_ADPT
(   
    .rst                (soft_rst[15]),
    .clk125m            (clk125m),
    .clk62m5            (clk62m5),
    .data_in_8b_0       (d2mac_0_w[15:0]),
    .data_in_8b_1       (d2mac_1_w[15:0]),
    .data_in_8b_2       (d2mac_2_w[15:0]),
    .data_in_8b_3       (d2mac_3_w[15:0]),
    .k_in_0             (k_ind_0_w[1:0]),
    .k_in_1             (k_ind_1_w[1:0]),
    .k_in_2             (k_ind_2_w[1:0]),
    .k_in_3             (k_ind_3_w[1:0]),
    .data_in_10b_0      (din_0[9:0]),
    .data_in_10b_1      (din_1[9:0]),
    .data_in_10b_2      (din_2[9:0]),
    .data_in_10b_3      (din_3[9:0]),
    //  output
    .data_out_8b_0      (d2mac_0[7:0]),
    .data_out_8b_1      (d2mac_1[7:0]),
    .data_out_8b_2      (d2mac_2[7:0]),
    .data_out_8b_3      (d2mac_3[7:0]),
    .k_out_0            (k_ind_0),
    .k_out_1            (k_ind_1),
    .k_out_2            (k_ind_2),
    .k_out_3            (k_ind_3),
    .data_out_10b_0     (din_0_w[19:0]),
    .data_out_10b_1     (din_1_w[19:0]),
    .data_out_10b_2     (din_2_w[19:0]),
    .data_out_10b_3     (din_3_w[19:0])
);


//***********************************************************************//
    //                                                                       //
    //--------------------------- The GT Wrapper ----------------------------//
    //                                                                       //
    //***********************************************************************//
    
    // Use the instantiation template in the example directory to add the GT wrapper to your design.
    // In this example, the wrapper is wired up for basic operation with a frame generator and frame 
    // checker. The GTs will reset, then attempt to align and transmit data. If channel bonding is 
    // enabled, bonding should occur after alignment.


    GTP_GE                             U_GTP_GE
    (
        .sysclk_in                     (clk100m), // input wire sysclk_in
        .soft_reset_tx_in              (soft_rst[15]), // input wire soft_reset_tx_in
        .soft_reset_rx_in              (soft_rst[15]), // input wire soft_reset_rx_in
        .dont_reset_on_data_error_in   (1'b1), // input wire dont_reset_on_data_error_in
        .gt0_drp_busy_out              (), // output wire gt0_drp_busy_out
        .gt0_tx_fsm_reset_done_out     (gt0_tx_fsm_reset_done_out), // output wire gt0_tx_fsm_reset_done_out, SYSCLK
        .gt0_rx_fsm_reset_done_out     (gt0_rx_fsm_reset_done_out), // output wire gt0_rx_fsm_reset_done_out, SYSCLK
        .gt0_data_valid_in             (gt0_data_valid_in), // input wire gt0_data_valid_in,                  RXUSRCLK2
        .gt1_drp_busy_out              (), // output wire gt1_drp_busy_out
        .gt1_tx_fsm_reset_done_out     (gt1_tx_fsm_reset_done_out), // output wire gt1_tx_fsm_reset_done_out
        .gt1_rx_fsm_reset_done_out     (gt1_rx_fsm_reset_done_out), // output wire gt1_rx_fsm_reset_done_out
        .gt1_data_valid_in             (gt1_data_valid_in), // input wire gt1_data_valid_in
//      .gt2_drp_busy_out              (), // output wire gt2_drp_busy_out
//      .gt2_tx_fsm_reset_done_out     (gt2_tx_fsm_reset_done_out), // output wire gt2_tx_fsm_reset_done_out
//      .gt2_rx_fsm_reset_done_out     (gt2_rx_fsm_reset_done_out), // output wire gt2_rx_fsm_reset_done_out
//      .gt2_data_valid_in             (gt2_data_valid_in), // input wire gt2_data_valid_in
//      .gt3_drp_busy_out              (), // output wire gt3_drp_busy_out
//      .gt3_tx_fsm_reset_done_out     (gt3_tx_fsm_reset_done_out), // output wire gt3_tx_fsm_reset_done_out
//      .gt3_rx_fsm_reset_done_out     (gt3_rx_fsm_reset_done_out), // output wire gt3_rx_fsm_reset_done_out
//      .gt3_data_valid_in             (gt3_data_valid_in), // input wire gt3_data_valid_in

    //_________________________________________________________________________
    //GT0  (X0Y0)
    //____________________________CHANNEL PORTS________________________________
    //-------------------------- Channel - DRP Ports  --------------------------
        .gt0_drpaddr_in                 (9'd0), // input wire [8:0] gt0_drpaddr_in
        .gt0_drpclk_in                  (clk100m), // input wire gt0_drpclk_in
        .gt0_drpdi_in                   (16'd0), // input wire [15:0] gt0_drpdi_in
        .gt0_drpdo_out                  (), // output wire [15:0] gt0_drpdo_out
        .gt0_drpen_in                   (1'b0), // input wire gt0_drpen_in
        .gt0_drprdy_out                 (), // output wire gt0_drprdy_out
        .gt0_drpwe_in                   (1'b0), // input wire gt0_drpwe_in
    //----------------------------- Loopback Ports -----------------------------
        .gt0_loopback_in                (loop[2:0]), // input wire [2:0] gt0_loopback_in
    //---------------------------- Power-Down Ports ----------------------------
        .gt0_rxpd_in                    (2'd0), // input wire [1:0] gt0_rxpd_in
        .gt0_txpd_in                    (2'd0), // input wire [1:0] gt0_txpd_in
    //------------------- RX Initialization and Reset Ports --------------------
        .gt0_eyescanreset_in            (1'b0), // input wire gt0_eyescanreset_in
        .gt0_rxuserrdy_in               (1'b0), // input wire gt0_rxuserrdy_in
    //------------------------ RX Margin Analysis Ports ------------------------
        .gt0_eyescandataerror_out       (), // output wire gt0_eyescandataerror_out
        .gt0_eyescantrigger_in          (1'b0), // input wire gt0_eyescantrigger_in
    //----------------- Receive Ports - Clock Correction Ports -----------------
        .gt0_rxclkcorcnt_out            (), // output wire [1:0] gt0_rxclkcorcnt_out
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .gt0_rxdata_out                 (d2mac_0_w[15:0]), // output wire [15:0] gt0_rxdata_out
        .gt0_rxusrclk_in                (clk62m5), // input wire gt0_rxusrclk_in
        .gt0_rxusrclk2_in               (clk62m5), // input wire gt0_rxusrclk2_in
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .gt0_rxcharisk_out              (k_ind_0_w[1:0]), // output wire [1:0] gt0_rxcharisk_out
        .gt0_rxdisperr_out              (), // output wire [1:0] gt0_rxdisperr_out
        .gt0_rxnotintable_out           (), // output wire [1:0] gt0_rxnotintable_out
    //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt0_gtprxn_in                  (rxd_n[0]), // input wire gt0_gtprxn_in
        .gt0_gtprxp_in                  (rxd_p[0]), // input wire gt0_gtprxp_in
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
        .gt0_rxbufreset_in              (soft_rst[0]), // input wire gt0_rxbufreset_in
        .gt0_rxbufstatus_out            (gt0_rxbufstatus_out[2:0]), // output wire [2:0] gt0_rxbufstatus_out
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt0_rxbyteisaligned_out        (gt0_rxbyteisaligned_out), // output wire gt0_rxbyteisaligned_out
        .gt0_rxmcommaalignen_in         (rxen_com_align[0]), // input wire gt0_rxmcommaalignen_in, RXUSRCLK2
        .gt0_rxpcommaalignen_in         (rxen_com_align[0]), // input wire gt0_rxpcommaalignen_in
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt0_dmonitorout_out            (), // output wire [14:0] gt0_dmonitorout_out
    //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt0_rxlpmhfhold_in             (1'b0), // input wire gt0_rxlpmhfhold_in
        .gt0_rxlpmhfovrden_in           (1'b0), // input wire gt0_rxlpmhfovrden_in
        .gt0_rxlpmlfhold_in             (1'b0), // input wire gt0_rxlpmlfhold_in
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt0_rxoutclk_out               (gt0_rxoutclk_out), // output wire gt0_rxoutclk_out
        .gt0_rxoutclkfabric_out         (), // output wire gt0_rxoutclkfabric_out
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt0_gtrxreset_in               (soft_rst[1]), // input wire gt0_gtrxreset_in
        .gt0_rxlpmreset_in              (1'b0), // input wire gt0_rxlpmreset_in
        .gt0_rxpcsreset_in              (1'b0), // input wire gt0_rxpcsreset_in
        .gt0_rxpmareset_in              (1'b0), // input wire gt0_rxpmareset_in
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt0_rxresetdone_out            (gt0_rxresetdone_out), // output wire gt0_rxresetdone_out, RXUSRCLK2
    //---------------------- TX Configurable Driver Ports ----------------------
        .gt0_txpostcursor_in            (5'd0), // input wire [4:0] gt0_txpostcursor_in
        .gt0_txprecursor_in             (5'd0), // input wire [4:0] gt0_txprecursor_in
    //------------------- TX Initialization and Reset Ports --------------------
        .gt0_gttxreset_in               (soft_rst[2]), // input wire gt0_gttxreset_in
        .gt0_txuserrdy_in               (1'b0), // input wire gt0_txuserrdy_in
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt0_txdata_in                  (din_0_w[19:0]), // input wire [15:0] gt0_txdata_in
        .gt0_txusrclk_in                (clk62m5), // input wire gt0_txusrclk_in
        .gt0_txusrclk2_in               (clk62m5), // input wire gt0_txusrclk2_in
    //-------------------- Transmit Ports - TX Buffer Ports --------------------
        .gt0_txbufstatus_out            (gt0_txbufstatus_out[1:0]), // output wire [1:0] gt0_txbufstatus_out
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt0_gtptxn_out                 (txd_n[0]), // output wire gt0_gtptxn_out
        .gt0_gtptxp_out                 (txd_p[0]), // output wire gt0_gtptxp_out
        .gt0_txdiffctrl_in              (4'd0), // input wire [3:0] gt0_txdiffctrl_in
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt0_txoutclk_out               (gt0_txoutclk_out), // output wire gt0_txoutclk_out
        .gt0_txoutclkfabric_out         (), // output wire gt0_txoutclkfabric_out
        .gt0_txoutclkpcs_out            (), // output wire gt0_txoutclkpcs_out
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt0_txpcsreset_in              (1'b0), // input wire gt0_txpcsreset_in
        .gt0_txpmareset_in              (1'b0), // input wire gt0_txpmareset_in
        .gt0_txresetdone_out            (gt0_txresetdone_out), // output wire gt0_txresetdone_out

    //GT1  (X0Y1)
    //____________________________CHANNEL PORTS________________________________
    //-------------------------- Channel - DRP Ports  --------------------------
        .gt1_drpaddr_in                 (9'd0), // input wire [8:0] gt1_drpaddr_in
        .gt1_drpclk_in                  (clk100m), // input wire gt1_drpclk_in
        .gt1_drpdi_in                   (16'd0), // input wire [15:0] gt1_drpdi_in
        .gt1_drpdo_out                  (), // output wire [15:0] gt1_drpdo_out
        .gt1_drpen_in                   (1'b0), // input wire gt1_drpen_in
        .gt1_drprdy_out                 (), // output wire gt1_drprdy_out
        .gt1_drpwe_in                   (1'b0), // input wire gt1_drpwe_in
    //----------------------------- Loopback Ports -----------------------------
        .gt1_loopback_in                (loop[6:4]), // input wire [2:0] gt1_loopback_in
    //---------------------------- Power-Down Ports ----------------------------
        .gt1_rxpd_in                    (2'd0), // input wire [1:0] gt1_rxpd_in
        .gt1_txpd_in                    (2'd0), // input wire [1:0] gt1_txpd_in
    //------------------- RX Initialization and Reset Ports --------------------
        .gt1_eyescanreset_in            (1'b0), // input wire gt1_eyescanreset_in
        .gt1_rxuserrdy_in               (1'b0), // input wire gt1_rxuserrdy_in
    //------------------------ RX Margin Analysis Ports ------------------------
        .gt1_eyescandataerror_out       (), // output wire gt1_eyescandataerror_out
        .gt1_eyescantrigger_in          (1'b0), // input wire gt1_eyescantrigger_in
    //----------------- Receive Ports - Clock Correction Ports -----------------
        .gt1_rxclkcorcnt_out            (), // output wire [1:0] gt1_rxclkcorcnt_out
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .gt1_rxdata_out                 (d2mac_1_w[15:0]), // output wire [15:0] gt1_rxdata_out
        .gt1_rxusrclk_in                (clk62m5), // input wire gt1_rxusrclk_in
        .gt1_rxusrclk2_in               (clk62m5), // input wire gt1_rxusrclk2_in
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .gt1_rxcharisk_out              (k_ind_1_w[1:0]), // output wire [1:0] gt1_rxcharisk_out
        .gt1_rxdisperr_out              (), // output wire [1:0] gt1_rxdisperr_out
        .gt1_rxnotintable_out           (), // output wire [1:0] gt1_rxnotintable_out
    //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt1_gtprxn_in                  (rxd_n[1]), // input wire gt1_gtprxn_in
        .gt1_gtprxp_in                  (rxd_p[1]), // input wire gt1_gtprxp_in
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
        .gt1_rxbufreset_in              (soft_rst[4]), // input wire gt1_rxbufreset_in
        .gt1_rxbufstatus_out            (gt1_rxbufstatus_out[2:0]), // output wire [2:0] gt1_rxbufstatus_out
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt1_rxbyteisaligned_out        (gt1_rxbyteisaligned_out), // output wire gt1_rxbyteisaligned_out
        .gt1_rxmcommaalignen_in         (rxen_com_align[1]), // input wire gt1_rxmcommaalignen_in
        .gt1_rxpcommaalignen_in         (rxen_com_align[1]), // input wire gt1_rxpcommaalignen_in
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt1_dmonitorout_out            (), // output wire [14:0] gt1_dmonitorout_out
    //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt1_rxlpmhfhold_in             (1'b0), // input wire gt1_rxlpmhfhold_in
        .gt1_rxlpmhfovrden_in           (1'b0), // input wire gt1_rxlpmhfovrden_in
        .gt1_rxlpmlfhold_in             (1'b0), // input wire gt1_rxlpmlfhold_in
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt1_rxoutclk_out               (gt1_rxoutclk_out), // output wire gt1_rxoutclk_out
        .gt1_rxoutclkfabric_out         (), // output wire gt1_rxoutclkfabric_out
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt1_gtrxreset_in               (soft_rst[5]), // input wire gt1_gtrxreset_in
        .gt1_rxlpmreset_in              (1'b0), // input wire gt1_rxlpmreset_in
        .gt1_rxpcsreset_in              (1'b0), // input wire gt1_rxpcsreset_in
        .gt1_rxpmareset_in              (1'b0), // input wire gt1_rxpmareset_in
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt1_rxresetdone_out            (gt1_rxresetdone_out), // output wire gt1_rxresetdone_out
    //---------------------- TX Configurable Driver Ports ----------------------
        .gt1_txpostcursor_in            (5'd0), // input wire [4:0] gt1_txpostcursor_in
        .gt1_txprecursor_in             (5'd0), // input wire [4:0] gt1_txprecursor_in
    //------------------- TX Initialization and Reset Ports --------------------
        .gt1_gttxreset_in               (soft_rst[6]), // input wire gt1_gttxreset_in
        .gt1_txuserrdy_in               (1'b0), // input wire gt1_txuserrdy_in
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt1_txdata_in                  (din_1_w[19:0]), // input wire [15:0] gt1_txdata_in
        .gt1_txusrclk_in                (clk62m5), // input wire gt1_txusrclk_in
        .gt1_txusrclk2_in               (clk62m5), // input wire gt1_txusrclk2_in
    //-------------------- Transmit Ports - TX Buffer Ports --------------------
        .gt1_txbufstatus_out            (gt1_txbufstatus_out[1:0]), // output wire [1:0] gt1_txbufstatus_out
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt1_gtptxn_out                 (txd_n[1]), // output wire gt1_gtptxn_out
        .gt1_gtptxp_out                 (txd_p[1]), // output wire gt1_gtptxp_out
        .gt1_txdiffctrl_in              (4'd0), // input wire [3:0] gt1_txdiffctrl_in
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt1_txoutclk_out               (), // output wire gt1_txoutclk_out
        .gt1_txoutclkfabric_out         (), // output wire gt1_txoutclkfabric_out
        .gt1_txoutclkpcs_out            (), // output wire gt1_txoutclkpcs_out
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt1_txpcsreset_in              (1'b0), // input wire gt1_txpcsreset_in
        .gt1_txpmareset_in              (1'b0), // input wire gt1_txpmareset_in
        .gt1_txresetdone_out            (gt1_txresetdone_out), // output wire gt1_txresetdone_out
/*
    //GT2  (X0Y2)
    //____________________________CHANNEL PORTS________________________________
    //-------------------------- Channel - DRP Ports  --------------------------
        .gt2_drpaddr_in                 (9'd0), // input wire [8:0] gt2_drpaddr_in
        .gt2_drpclk_in                  (clk100m), // input wire gt2_drpclk_in
        .gt2_drpdi_in                   (16'd0), // input wire [15:0] gt2_drpdi_in
        .gt2_drpdo_out                  (), // output wire [15:0] gt2_drpdo_out
        .gt2_drpen_in                   (1'b0), // input wire gt2_drpen_in
        .gt2_drprdy_out                 (), // output wire gt2_drprdy_out
        .gt2_drpwe_in                   (1'b0), // input wire gt2_drpwe_in
    //----------------------------- Loopback Ports -----------------------------
        .gt2_loopback_in                (loop[10:8]), // input wire [2:0] gt2_loopback_in
    //---------------------------- Power-Down Ports ----------------------------
        .gt2_rxpd_in                    (2'd0), // input wire [1:0] gt2_rxpd_in
        .gt2_txpd_in                    (2'd0), // input wire [1:0] gt2_txpd_in
    //------------------- RX Initialization and Reset Ports --------------------
        .gt2_eyescanreset_in            (1'b0), // input wire gt2_eyescanreset_in
        .gt2_rxuserrdy_in               (1'b0), // input wire gt2_rxuserrdy_in
    //------------------------ RX Margin Analysis Ports ------------------------
        .gt2_eyescandataerror_out       (), // output wire gt2_eyescandataerror_out
        .gt2_eyescantrigger_in          (1'b0), // input wire gt2_eyescantrigger_in
    //----------------- Receive Ports - Clock Correction Ports -----------------
        .gt2_rxclkcorcnt_out            (), // output wire [1:0] gt2_rxclkcorcnt_out
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .gt2_rxdata_out                 (d2mac_2_w[15:0]), // output wire [15:0] gt2_rxdata_out
        .gt2_rxusrclk_in                (clk62m5), // input wire gt2_rxusrclk_in
        .gt2_rxusrclk2_in               (clk62m5), // input wire gt2_rxusrclk2_in
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .gt2_rxcharisk_out              (k_ind_2_w[1:0]), // output wire [1:0] gt2_rxcharisk_out
        .gt2_rxdisperr_out              (), // output wire [1:0] gt2_rxdisperr_out
        .gt2_rxnotintable_out           (), // output wire [1:0] gt2_rxnotintable_out
    //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt2_gtprxn_in                  (rxd_n[2]), // input wire gt2_gtprxn_in
        .gt2_gtprxp_in                  (rxd_p[2]), // input wire gt2_gtprxp_in
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
        .gt2_rxbufreset_in              (soft_rst[8]), // input wire gt2_rxbufreset_in
        .gt2_rxbufstatus_out            (gt2_rxbufstatus_out[2:0]), // output wire [2:0] gt2_rxbufstatus_out
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt2_rxbyteisaligned_out        (gt2_rxbyteisaligned_out), // output wire gt2_rxbyteisaligned_out
        .gt2_rxmcommaalignen_in         (rxen_com_align[2]), // input wire gt2_rxmcommaalignen_in
        .gt2_rxpcommaalignen_in         (rxen_com_align[2]), // input wire gt2_rxpcommaalignen_in
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt2_dmonitorout_out            (), // output wire [14:0] gt2_dmonitorout_out
    //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt2_rxlpmhfhold_in             (1'b0), // input wire gt2_rxlpmhfhold_in
        .gt2_rxlpmhfovrden_in           (1'b0), // input wire gt2_rxlpmhfovrden_in
        .gt2_rxlpmlfhold_in             (1'b0), // input wire gt2_rxlpmlfhold_in
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt2_rxoutclkfabric_out         (), // output wire gt2_rxoutclkfabric_out
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt2_gtrxreset_in               (soft_rst[9]), // input wire gt2_gtrxreset_in
        .gt2_rxlpmreset_in              (1'b0), // input wire gt2_rxlpmreset_in
        .gt2_rxpcsreset_in              (1'b0), // input wire gt2_rxpcsreset_in
        .gt2_rxpmareset_in              (1'b0), // input wire gt2_rxpmareset_in
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt2_rxresetdone_out            (gt2_rxresetdone_out), // output wire gt2_rxresetdone_out
    //---------------------- TX Configurable Driver Ports ----------------------
        .gt2_txpostcursor_in            (5'd0), // input wire [4:0] gt2_txpostcursor_in
        .gt2_txprecursor_in             (5'd0), // input wire [4:0] gt2_txprecursor_in
    //------------------- TX Initialization and Reset Ports --------------------
        .gt2_gttxreset_in               (soft_rst[10]), // input wire gt2_gttxreset_in
        .gt2_txuserrdy_in               (1'b0), // input wire gt2_txuserrdy_in
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt2_txdata_in                  (din_2_w[19:0), // input wire [15:0] gt2_txdata_in
        .gt2_txusrclk_in                (clk62m5), // input wire gt2_txusrclk_in
        .gt2_txusrclk2_in               (clk62m5), // input wire gt2_txusrclk2_in
    //-------------------- Transmit Ports - TX Buffer Ports --------------------
        .gt2_txbufstatus_out            (gt2_txbufstatus_out[1:0]), // output wire [1:0] gt2_txbufstatus_out
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt2_gtptxn_out                 (txd_n[2]), // output wire gt2_gtptxn_out
        .gt2_gtptxp_out                 (txd_p[2]), // output wire gt2_gtptxp_out
        .gt2_txdiffctrl_in              (4'd0), // input wire [3:0] gt2_txdiffctrl_in
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt2_txoutclk_out               (), // output wire gt2_txoutclk_out
        .gt2_txoutclkfabric_out         (), // output wire gt2_txoutclkfabric_out
        .gt2_txoutclkpcs_out            (), // output wire gt2_txoutclkpcs_out
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt2_txpcsreset_in              (1'b0), // input wire gt2_txpcsreset_in
        .gt2_txpmareset_in              (1'b0), // input wire gt2_txpmareset_in
        .gt2_txresetdone_out            (gt2_txresetdone_out), // output wire gt2_txresetdone_out

    //GT3  (X0Y3)
    //____________________________CHANNEL PORTS________________________________
    //-------------------------- Channel - DRP Ports  --------------------------
        .gt3_drpaddr_in                 (9'd0), // input wire [8:0] gt3_drpaddr_in
        .gt3_drpclk_in                  (clk100m), // input wire gt3_drpclk_in
        .gt3_drpdi_in                   (16'd0), // input wire [15:0] gt3_drpdi_in
        .gt3_drpdo_out                  (), // output wire [15:0] gt3_drpdo_out
        .gt3_drpen_in                   (1'b0), // input wire gt3_drpen_in
        .gt3_drprdy_out                 (), // output wire gt3_drprdy_out
        .gt3_drpwe_in                   (1'b0), // input wire gt3_drpwe_in
    //----------------------------- Loopback Ports -----------------------------
        .gt3_loopback_in                (loop[14:12]), // input wire [2:0] gt3_loopback_in
    //---------------------------- Power-Down Ports ----------------------------
        .gt3_rxpd_in                    (2'd0), // input wire [1:0] gt3_rxpd_in
        .gt3_txpd_in                    (2'd0), // input wire [1:0] gt3_txpd_in
    //------------------- RX Initialization and Reset Ports --------------------
        .gt3_eyescanreset_in            (1'b0), // input wire gt3_eyescanreset_in
        .gt3_rxuserrdy_in               (1'b0), // input wire gt3_rxuserrdy_in
    //------------------------ RX Margin Analysis Ports ------------------------
        .gt3_eyescandataerror_out       (), // output wire gt3_eyescandataerror_out
        .gt3_eyescantrigger_in          (1'b0), // input wire gt3_eyescantrigger_in
    //----------------- Receive Ports - Clock Correction Ports -----------------
        .gt3_rxclkcorcnt_out            (), // output wire [1:0] gt3_rxclkcorcnt_out
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .gt3_rxdata_out                 (d2mac_3_w[15:0]), // output wire [15:0] gt3_rxdata_out
        .gt3_rxusrclk_in                (clk62m5), // input wire gt3_rxusrclk_in
        .gt3_rxusrclk2_in               (clk62m5), // input wire gt3_rxusrclk2_in
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .gt3_rxcharisk_out              (k_ind_3_w[1:0]), // output wire [1:0] gt3_rxcharisk_out
        .gt3_rxdisperr_out              (), // output wire [1:0] gt3_rxdisperr_out
        .gt3_rxnotintable_out           (), // output wire [1:0] gt3_rxnotintable_out
    //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt3_gtprxn_in                  (rxd_n[3]), // input wire gt3_gtprxn_in
        .gt3_gtprxp_in                  (rxd_p[3]), // input wire gt3_gtprxp_in
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
        .gt3_rxbufreset_in              (soft_rst[12]), // input wire gt3_rxbufreset_in
        .gt3_rxbufstatus_out            (gt3_rxbufstatus_out[2:0]), // output wire [2:0] gt3_rxbufstatus_out
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt3_rxbyteisaligned_out        (gt3_rxbyteisaligned_out), // output wire gt3_rxbyteisaligned_out
        .gt3_rxmcommaalignen_in         (rxen_com_align[3]), // input wire gt3_rxmcommaalignen_in
        .gt3_rxpcommaalignen_in         (rxen_com_align[3]), // input wire gt3_rxpcommaalignen_in
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt3_dmonitorout_out            (), // output wire [14:0] gt3_dmonitorout_out
    //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt3_rxlpmhfhold_in             (1'b0), // input wire gt3_rxlpmhfhold_in
        .gt3_rxlpmhfovrden_in           (1'b0), // input wire gt3_rxlpmhfovrden_in
        .gt3_rxlpmlfhold_in             (1'b0), // input wire gt3_rxlpmlfhold_in
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt3_rxoutclkfabric_out         (), // output wire gt3_rxoutclkfabric_out
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt3_gtrxreset_in               (soft_rst[13]), // input wire gt3_gtrxreset_in
        .gt3_rxlpmreset_in              (1'b0), // input wire gt3_rxlpmreset_in
        .gt3_rxpcsreset_in              (1'b0), // input wire gt3_rxpcsreset_in
        .gt3_rxpmareset_in              (1'b0), // input wire gt3_rxpmareset_in
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt3_rxresetdone_out            (gt3_rxresetdone_out), // output wire gt3_rxresetdone_out
    //---------------------- TX Configurable Driver Ports ----------------------
        .gt3_txpostcursor_in            (5'd0), // input wire [4:0] gt3_txpostcursor_in
        .gt3_txprecursor_in             (5'd0), // input wire [4:0] gt3_txprecursor_in
    //------------------- TX Initialization and Reset Ports --------------------
        .gt3_gttxreset_in               (soft_rst[14]), // input wire gt3_gttxreset_in
        .gt3_txuserrdy_in               (1'b0), // input wire gt3_txuserrdy_in
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt3_txdata_in                  (din_3_w[19:0), // input wire [15:0] gt3_txdata_in
        .gt3_txusrclk_in                (clk62m5), // input wire gt3_txusrclk_in
        .gt3_txusrclk2_in               (clk62m5), // input wire gt3_txusrclk2_in
    //-------------------- Transmit Ports - TX Buffer Ports --------------------
        .gt3_txbufstatus_out            (gt3_txbufstatus_out[1:0]), // output wire [1:0] gt3_txbufstatus_out
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt3_gtptxn_out                 (txd_n[3]), // output wire gt3_gtptxn_out
        .gt3_gtptxp_out                 (txd_p[3]), // output wire gt3_gtptxp_out
        .gt3_txdiffctrl_in              (4'd0), // input wire [3:0] gt3_txdiffctrl_in
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt3_txoutclk_out               (), // output wire gt3_txoutclk_out
        .gt3_txoutclkfabric_out         (), // output wire gt3_txoutclkfabric_out
        .gt3_txoutclkpcs_out            (), // output wire gt3_txoutclkpcs_out
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt3_txpcsreset_in              (1'b0), // input wire gt3_txpcsreset_in
        .gt3_txpmareset_in              (1'b0), // input wire gt3_txpmareset_in
        .gt3_txresetdone_out            (gt3_txresetdone_out), // output wire gt3_txresetdone_out
*/

    //____________________________COMMON PORTS________________________________
    //  Using PLL0
//      .gt0_pll0outclk_in              (gt0_pll0outclk_i), // input wire gt0_pll0outclk_in
//      .gt0_pll0outrefclk_in           (gt0_pll0outrefclk_i), // input wire gt0_pll0outrefclk_in
//      .gt0_pll0reset_out              (gt0_pll0reset_i), // output wire gt0_pll0reset_out
//      .gt0_pll0lock_in                (gt0_pll0lock_i), // input wire gt0_pll0lock_in
//      .gt0_pll0refclklost_in          (gt0_pll0refclklost_i), // input wire gt0_pll0refclklost_in   
//      .gt0_pll1outclk_in              (gt0_pll1outclk_i), // input wire gt0_pll1outclk_in
//      .gt0_pll1outrefclk_in           (gt0_pll1outrefclk_i) // input wire gt0_pll1outrefclk_in
    
    //  Using PLL1    
        .gt0_pll1reset_out              (gt0_pll0reset_i),
        .gt0_pll0outclk_in              (gt0_pll1outclk_i),
        .gt0_pll0outrefclk_in           (gt0_pll1outrefclk_i),
        .gt0_pll1lock_in                (gt0_pll0lock_i),
        .gt0_pll1refclklost_in          (gt0_pll0refclklost_i),    
        .gt0_pll1outclk_in              (gt0_pll0outclk_i),
        .gt0_pll1outrefclk_in           (gt0_pll0outrefclk_i)
    );
/*
assign gt0_pll0reset_t  = commonreset_i | gt0_pll0reset_i | cpll_reset_pll0_q0_clk1_refclk_i;
assign gt0_pll0pd_t     = cpll_pd_pll0_q0_clk1_refclk_i;


GTP_GE_cpll_railing #
   (
        .USE_BUFG(0)
   )
U_CPLL_RAILING_PLL0_Q0_CLK1_REFCLK_I
(
    .cpll_reset_out     (cpll_reset_pll0_q0_clk1_refclk_i),
    .cpll_pd_out        (cpll_pd_pll0_q0_clk1_refclk_i),
    .refclk_out         (),
    .refclk_in          (gtp_refclk)
);


GTP_GE_common #
(
    .WRAPPER_SIM_GTRESET_SPEEDUP(EXAMPLE_SIM_GTRESET_SPEEDUP),
    .SIM_PLL0REFCLK_SEL (3'b010),
    .SIM_PLL1REFCLK_SEL (3'b001)
)
U_COMMON0_I
(
    .PLL0OUTCLK_OUT     (gt0_pll0outclk_i),
    .PLL0OUTREFCLK_OUT  (gt0_pll0outrefclk_i),
    .PLL0LOCK_OUT       (gt0_pll0lock_i),
    .PLL0LOCKDETCLK_IN  (clk100m),
    .PLL0REFCLKLOST_OUT (gt0_pll0refclklost_i), 
    .PLL0RESET_IN       (gt0_pll0reset_t ),
    .PLL0PD_IN          (gt0_pll0pd_t ),
    .PLL0REFCLKSEL_IN   (3'b010),
    .PLL1OUTCLK_OUT     (gt0_pll1outclk_i),
    .PLL1OUTREFCLK_OUT  (gt0_pll1outrefclk_i),
    .GTREFCLK0_IN       (1'b0),
    .GTREFCLK1_IN       (gtp_refclk)
);


GTP_GE_common_reset # 
(
   .STABLE_CLOCK_PERIOD (STABLE_CLOCK_PERIOD)        // Period of the stable clock driving this state-machine, unit is [ns]
)
U_COMMON_RESET_I
(    
   .STABLE_CLOCK        (clk100m),             //Stable Clock, either a stable clock from the PCB
   .SOFT_RESET          (soft_rst[15]),               //User Reset, can be pulled any time
   .COMMON_RESET        (commonreset_i)              //Reset QPLL
);
*/


endmodule

