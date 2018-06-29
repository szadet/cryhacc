/****************************************************************************
 * pux_si.v
 ****************************************************************************/
/**
 * Module: szade_pux_si
 * 
 * TODO: Add module documentation
 */
module pux_si 
#(  
  parameter OPCW     = 8,
  parameter DATAW    = 16,
  parameter STATUSW  = 2,
  parameter OPFIFOW  = 3    /* Size of the FIFO pointers */
)(
  input            axis_clk,  /*< Module clock */
  input            axis_rstn, /*< Module reset */

  input [OPCW-1:0] axis_opcode_data, 
  input            axis_opcode_valid,
  output           axis_opcode_ready,

  input [DATAW-1:0] axis_abuff_data, 
  input             axis_abuff_valid,
  output            axis_abuff_ready,

  input [DATAW-1:0] axis_bbuff_data, 
  input             axis_bbuff_valid,
  output            axis_bbuff_ready,
  
  input [DATAW-1:0] axis_mbuff_data, 
  input             axis_mbuff_valid,
  output            axis_mbuff_ready,  

  input                axis_status_ready,
  output [STATUSW-1:0] axis_status_data, 
  output               axis_status_valid,    

  output stream_reqest /*< Request stream fetch */ 
);

/**
 * Stream signals definition
 */
 reg  [OPFIFOW:0] opcwptr_r;
 reg  [OPFIFOW:0] opcrptr_r;
 wire             opcempty_w;
 wire             opcfull_w;
 wire             opcrd_w;
 wire             opcwr_w;
 
/**
 * Architecture
 */
 /**
  * Opcode FIFO pointers registers
  */ 
always @(posedge axis_clk or negedge axis_rstn)
begin : OPCODE_FETCH_BLOCK
  if (!axis_rstn) begin
    opcwptr_r<= {OPFIFOW{1'b0}};
    opcrptr_r<= {OPFIFOW{1'b0}};
  end else begin /*clock gating*/
    if (opcwr_w) opcwptr_r<= opcwptr_r + 'd1;
    if (opcrd_w) opcrptr_r<= opcrptr_r + 'd1;
  end
end

/**
 * FIFO 
 */
assign opcempty_w = 
  (opcwptr_r == opcrptr_r);

assign opcfull_w  = 
  (opcwptr_r[OPFIFOW] != opcrptr_r[OPFIFOW] && opcwptr_r == opcrptr_r); 

/**
 * Writing to the FIFO
 */
assign opcwr_w = (!opcempty_w && axis_opcode_valid);

/**
 * FIFO output
 */
assign axis_opcode_ready = (!opcfull_w); 

endmodule


