/****************************************************************************
 * pux_si_tb.v
 ****************************************************************************/

//`include "tasks_pix_si.v"
`timescale 1ns/1ns

/**
 * Module: pux_si_tb
 * 
 * TODO: Add module documentation
 */
module pux_si_tb;

/**
 * Parameters configuration 
 */
  localparam OPCW       = 8;
  localparam DATAW      = 16; 
  localparam CLK_PREIOD = 5;
  localparam STATUSW    = 2;
  
  
  `define TIMEOUT 200
  
/**
 * Signals
 */
  reg                 axis_clk;          /*< Main clock */
  reg                 axis_rstn;         /*< Reset */
  reg[OPCW-1:0]       axis_opcode_data;  /*< Opcode data input*/    
  reg                 axis_opcode_valid; /*< Opcode valid */        
  wire                axis_opcode_ready; /*< Opcode ready */          
  reg [DATAW-1:0]     axis_abuff_data;   /*< Buffer A data input*/  
  reg                 axis_abuff_valid;  /*< Buffer A valid */      
  wire                axis_abuff_ready;  /*< Buffer A ready */        
  reg [DATAW-1:0]     axis_bbuff_data;   /*< Buffer B data input*/  
  reg                 axis_bbuff_valid;  /*< Buffer B valid */      
  wire                axis_bbuff_ready;  /*< Buffer B ready */        
  reg [DATAW-1:0]     axis_mbuff_data;   /*< Buffer M data input*/  
  reg                 axis_mbuff_valid;  /*< Buffer M valid */      
  wire                axis_mbuff_ready;  /*< Buffer M ready */         
  reg                 axis_status_ready; /*< Status ready */        
  wire [STATUSW-1:0]  axis_status_data;  /*< Status data input*/    
  wire                axis_status_valid; /*< Status valid */                                                                      
  reg                 stream_reqest;     /*< Request stream fetch */
  
  integer timeoutcnt;
  
/**
 * Tasks
 */
/**
 * Terminate the simulation with the given exit code
 */
task FINISH;
  input integer EXIT_CODE;
begin
`ifdef __ICARUS__
    $finish_and_return(EXIT_CODE);
`else
    $finish(EXIT_CODE);
`endif
end
endtask

/**
 * Sending one opcode request
 */
task SEND_OPCODE;
  input [OPCW-1:0] OPCODE;
begin
  @(posedge axis_clk)
  $display("INFO: [time %0d ns] PUX_SI: SEND OPCODE %0h",$time,OPCODE);
  axis_opcode_valid = 1'b1;
  axis_opcode_data = OPCODE;
  #1 //switching delta

  wait (axis_opcode_ready === 1'b1);
  
  @(posedge axis_clk)
  axis_opcode_valid = 1'b0;  
end
endtask

/**
 * Waiting For Expected Status
 */
task WAIT_FOR_STATUS;
  input [STATUSW-1:0] EXPECETD_STATUS;
  
  @(posedge axis_status_valid)
  @(negedge axis_clk)
  
  if (EXPECETD_STATUS === axis_status_data) begin
    $display("INFO: [time %0d ns] Proper status received",$time);
  end else begin
    $display("ERROR: [time %0d ns] Expected status 0x%0h, received 0x%0h.",$time,EXPECETD_STATUS,axis_status_data);
    $display("ERROR: [time %0d ns] Test failed by reference comparison.",$time);
    FINISH(2);
  end
endtask
  

/**
 * Architecture
 */

/**       
 * Clock generation 
 */
initial
begin
  axis_clk = 1'b0;
  
  forever
  begin
    axis_clk = #(CLK_PREIOD/2) ~axis_clk;
  end
end


/**
 * Reset generation
 */
initial
begin
  axis_rstn = 1'b1;
  
  @(posedge axis_clk)
  axis_rstn = 1'b0;
  
  @(posedge axis_clk)
  axis_rstn = 1'b1;
end  

/**
 * DUT
 */       
pux_si #(
  .OPCW  (OPCW),
  .DATAW (DATAW)
) u_pux_si (
   .axis_clk          (axis_clk),
   .axis_rstn         (axis_rstn),
   .axis_opcode_data  (axis_opcode_data),  /*< Opcode data input*/
   .axis_opcode_valid (axis_opcode_valid), /*< Opcode valid */
   .axis_opcode_ready (axis_opcode_ready), /*< Opcode ready */
   .axis_abuff_data   (axis_abuff_data),   /*< Buffer A data input*/
   .axis_abuff_valid  (axis_abuff_valid),  /*< Buffer A valid */
   .axis_abuff_ready  (axis_abuff_ready),  /*< Buffer A ready */
   .axis_bbuff_data   (axis_bbuff_data ),  /*< Buffer B data input*/
   .axis_bbuff_valid  (axis_bbuff_valid),  /*< Buffer B valid */
   .axis_bbuff_ready  (axis_bbuff_ready),  /*< Buffer B ready */
   .axis_mbuff_data   (axis_mbuff_data ),  /*< Buffer M data input*/
   .axis_mbuff_valid  (axis_mbuff_valid),  /*< Buffer M valid */
   .axis_mbuff_ready  (axis_mbuff_ready),  /*< Buffer M ready */  
   .axis_status_ready (axis_status_ready), /*< Status ready */
   .axis_status_data  (axis_status_data),  /*< Status data input*/
   .axis_status_valid (axis_status_valid), /*< Status valid */    
   .stream_reqest     (stream_request)     /*< Request stream fetch */ 
 );
 
 initial
 begin
   axis_opcode_valid = 1'b0;
   axis_status_ready = 1'b0;
   
   $dumpfile("sim_bin/test.vcd");
   $dumpvars(0,pux_si_tb);   
   
   @(posedge axis_rstn)
   #20 
   SEND_OPCODE(23);
   SEND_OPCODE(02);
   SEND_OPCODE(31);
   SEND_OPCODE(17);
   SEND_OPCODE(12);
   SEND_OPCODE(01);
   
   $display("INFO: [time %0d ns] Test passed.",$time);
   FINISH(0);
end

initial
begin
  @(posedge axis_rstn)
  WAIT_FOR_STATUS(1);
  WAIT_FOR_STATUS(0);
  WAIT_FOR_STATUS(1);
  WAIT_FOR_STATUS(0);
  WAIT_FOR_STATUS(0);
  WAIT_FOR_STATUS(0);
end
 
 /**
  * Timeout
  */
initial
begin
  timeoutcnt = 0;
  
  while (timeoutcnt < `TIMEOUT)
  begin
    @(posedge axis_clk)
    timeoutcnt = timeoutcnt + 1;
  end

  $display("ERROR: [time %0d ns] Test failed by timeout.",$time);
  FINISH(3);
end

endmodule