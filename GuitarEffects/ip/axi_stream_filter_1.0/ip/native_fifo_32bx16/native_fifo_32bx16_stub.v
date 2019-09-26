// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Thu Sep 26 16:16:48 2019
// Host        : zrhn2444 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/guitareffects/GuitarEffects/ip/axi_stream_filter_1.0/ip/native_fifo_32bx16/native_fifo_32bx16_stub.v
// Design      : native_fifo_32bx16
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_4,Vivado 2019.1" *)
module native_fifo_32bx16(clk, rst, din, wr_en, rd_en, dout, full, almost_full, 
  wr_ack, overflow, empty, almost_empty, valid, underflow, data_count, wr_rst_busy, rd_rst_busy)
/* synthesis syn_black_box black_box_pad_pin="clk,rst,din[31:0],wr_en,rd_en,dout[31:0],full,almost_full,wr_ack,overflow,empty,almost_empty,valid,underflow,data_count[3:0],wr_rst_busy,rd_rst_busy" */;
  input clk;
  input rst;
  input [31:0]din;
  input wr_en;
  input rd_en;
  output [31:0]dout;
  output full;
  output almost_full;
  output wr_ack;
  output overflow;
  output empty;
  output almost_empty;
  output valid;
  output underflow;
  output [3:0]data_count;
  output wr_rst_busy;
  output rd_rst_busy;
endmodule
