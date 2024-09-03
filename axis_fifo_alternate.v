`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2024 10:10:11
// Design Name: 
// Module Name: axis_fifo_alternate
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
/*
  The alternate case for axis fifo is that :  do not wait t_ready to high and write and read the 
  data when t_valid high in master master pins.
  The rd_ptr and wr_ptr pointer will decode the address and wr and rd the data .
*/

module axis_fifo_alternate #(
  parameter data_bits = 8, // 8 byte
  parameter mem_depth = 16,  // 
  parameter tkeep_width = ((data_bits)/8)
 )
 (
    input wire axis_clk,
    input wire axis_resetn,
    
    /*
    slave axis pins
    */
    input wire [data_bits - 1 :0] s_axis_tdata,
    input wire s_axis_tkeep,
    input wire s_axis_tlast,
    input wire s_axis_tvalid,
    
    /*
    master axis pins
    master and slave are interconnected
    */
    output wire [data_bits - 1:0]m_axis_tdata,
    output wire m_axis_tkeep,
    output wire m_axis_tlast,
    output wire m_axis_tvalid,
    input wire m_axis_tready
    

    );
    
    integer i;
    /* mem size decleartion
    */
    reg [data_bits - 1:0] mem_tcp [0:mem_depth - 1]; // array of memory
    reg mem_tkeep [0:mem_depth - 1]; //array of t_keep
    reg mem_tlast [0:mem_depth - 1]; // array of tlast
    
    /*
      fifo pointers
     
    */
    
    reg [4:0] wr_ptr;
    reg [4:0] rd_ptr;
    reg [4:0] count;
    
    /*fifo control  signal
    */
    wire fifo_full;
    wire fifo_empty;
    
   assign fifo_full = (count == mem_depth - 1) ? 1'b1 : 64'h00; 
   assign fifo_empty = (count == 0) ? 1'b1 : 64'h00; 
   
   /*
     resetn logic
   */
   
   always @ (posedge axis_clk)
   begin
     if (axis_resetn == 1'b0)
     begin
        wr_ptr <= 0;
        rd_ptr <= 0; 
        count <= 0;
        
        for ( i = 0 ; i<mem_depth - 1 ; i= i+1) 
        begin
           mem_tcp[i] <= 8'h00;
           mem_tkeep [i] <= 8'h00;
           mem_tlast [i] <= 8'h00;
        end
     end
     
     /*
     else condtion after reset 
      apply condition based upon slave  input
      data write on address indicated by write pointer
      after this t_keep is 1'b1 based upon byte by byte validity
     */
     else if ((s_axis_tvalid == 1'b1) && ( fifo_full == 1'b0) )
     begin
          mem_tcp[wr_ptr]  <= s_axis_tdata; // data write on address
          
          mem_tkeep[wr_ptr]  <= s_axis_tkeep;
          mem_tlast[wr_ptr]  <= s_axis_tlast;
          wr_ptr <=  wr_ptr + 1;
          count <=   count + 1;
     end
     
     /*
      master pins depend upon slave for reading the data based upon read pointer
     */
     
     else if ((m_axis_tready == 1'b1 )&& (fifo_empty == 1'b0))
     begin
         rd_ptr <= rd_ptr + 1;
         count <= count - 1;
     end
     
   end
   
   /*
     m_axis pins assigned based upon t_valid
     reading the data from memory without waiting the tready
   */
   
   assign m_axis_tdata =  (m_axis_tvalid == 1'b1) ? mem_tcp[rd_ptr] : 1'b0;
   assign m_axis_tkeep =  (m_axis_tvalid == 1'b1) ? mem_tkeep[rd_ptr] : 0;
   assign m_axis_tlast =  (m_axis_tvalid == 1'b1) ? mem_tlast[rd_ptr] : 1'b0;
   assign  m_axis_tvalid  = (count>0)? 1'b1 : 1'b0;  
endmodule