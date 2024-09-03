`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2024 17:27:44
// Design Name: 
// Module Name: axis_fifo_alternate_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`define clk_period 10;
module axis_fifo_alternate_tb();
  /*
    parameter decleartion
   */
   parameter data_bits = 8;// 8 byte
   parameter mem_depth = 16 ; // 
   parameter tkeep_width = ((data_bits)/8);
  
    reg  axis_clk;
    reg axis_resetn;
    
    /*
    slave axis pins
    */
    reg [data_bits - 1 :0] s_axis_tdata;
    reg  s_axis_tkeep;
    reg s_axis_tlast;
    reg s_axis_tvalid;
    
    /*
    master axis pins
    */
    wire [data_bits - 1:0]m_axis_tdata;
    wire m_axis_tkeep;
    wire m_axis_tlast;
    wire m_axis_tvalid;
    reg m_axis_tready;
    
axis_fifo_alternate #(
      .data_bits(data_bits),
      .mem_depth(mem_depth),
     .tkeep_width (tkeep_width)
      )
      
dut (
    .axis_clk ( axis_clk ),
    .axis_resetn (axis_resetn),
    
    // slave axis pins
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tvalid(s_axis_tvalid),
    
    // master axis_pins
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready)
    
 );
 integer i;
 /*
   logic for clk
 */
 
 always  #10 axis_clk = ~axis_clk;
 
 /*
   initialize the stimuli
 */
 
 initial  begin
 axis_clk = 0;
 axis_resetn = 0;
 s_axis_tvalid = 1'b0;
 s_axis_tdata = 8'h00;
 s_axis_tkeep = 1'b0;
 s_axis_tkeep = 1'b0;
 s_axis_tlast = 1'b0;
 repeat(5) @(posedge axis_clk);
 
 /*
 writing the data
 */
 axis_resetn = 1'b1;
 
 for ( i= 0 ; i< 20 ; i= i+1) 
 begin
 @(posedge axis_clk);
 m_axis_tready = 1'b0;
 s_axis_tvalid = 1'b1;
 s_axis_tdata = $random();
 s_axis_tkeep = 1'b1;
 s_axis_tlast = 1'b0;
end
 
 /*
 reading the data
 */
 for ( i= 0 ; i< 20 ; i= i+1) 
begin
 @(posedge axis_clk);
 m_axis_tready = 1'b1;
  s_axis_tvalid = 1'b0;
  s_axis_tdata = 0;
  s_axis_tkeep = 1'b0;
  s_axis_tlast = 1'b0;
 end
 
 #10 $finish;
 end

    
endmodule
