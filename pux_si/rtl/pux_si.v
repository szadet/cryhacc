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
 
 wire [OPCW-1:0] opcode_w;
 wire            opcode_valid_w;

 localparam REGFILEW = OPCW*(1<<OPFIFOW)-1;
 integer             rwrd;
 integer             rbit; //register bit index
 reg  [REGFILEW-1:0] opcregs_r;
 reg  [OPCW-1:0]     opcrego_r;
 wire [OPCW-1:0]     opcrego_w;
 
 /**
  * Status channel
  */
 wire               status_valid_w;
 reg                status_valid_r;
 wire [STATUSW-1:0] status_w;
 reg  [STATUSW-1:0] status_r;
 
 
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
 * OPCODE REGISTER FILE
 */
always @(posedge axis_clk or negedge axis_rstn)
begin : OPCODE_REGISTER_FILE
  if (!axis_rstn) begin
    opcregs_r<= {OPFIFOW {1'b0}};
  end else if (opcwr_w) begin
    for (rwrd=0; rwrd<(1<<OPCW); rwrd= rwrd + 1)
      if (rwrd[OPFIFOW-1:0] == opcwptr_r[OPFIFOW-1:0])
        for (rbit=0; rbit<OPCW-1; rbit= rbit + 1)                
          opcregs_r[rbit+rwrd*OPCW]<= axis_opcode_data[rbit];  
  end
end

/**
 * OPCODE REGISTER OUTPUT
 */
always @(*)
begin : OPCODE_REGISTER_FILE_DEMUX
  for (rwrd=0; rwrd<(1<<OPFIFOW); rwrd=rwrd+1)
    if (rwrd == opcrptr_r[OPFIFOW-1:0])
      for (rbit=0; rbit<OPCW; rbit=rbit+1)
        opcrego_r[rbit]<= opcregs_r[rbit+rwrd*OPCW];  
end
assign c= opcrego_r;

/**
 * FIFO 
 */
assign opcempty_w = 
  (opcwptr_r == opcrptr_r);

assign opcfull_w  = 
  (opcwptr_r[OPFIFOW] != opcrptr_r[OPFIFOW] && opcwptr_r[OPFIFOW-1:0] == opcrptr_r[OPFIFOW-1:0]); 

/**
 * Writing to the FIFO
 */
assign opcwr_w = (!opcfull_w && axis_opcode_valid);
assign opcrd_w = (status_valid_r && axis_status_ready);

/**
 * FIFO output
 */
assign axis_opcode_ready = (!opcfull_w); 

/**
 * Temporary status logic
 */
always @(posedge axis_clk or negedge axis_rstn)
begin: STATUS_DONE
  if (!axis_rstn) begin
    status_r <= {STATUSW {1'b0}};
    status_valid_r <= 1'b0;
  end else begin /*clock gating*/
    if (!status_valid_r)
      status_r <= status_w; 
    
    if (axis_status_ready && status_valid_r)
      status_valid_r<= 1'b0;
    else if (status_valid_w)
      status_valid_r <= 1'b1; 
  end 
end

  assign status_valid_w = (!opcempty_w);
  assign status_w = 
    (opcrego_w == 'd2)  ? 'd2 :
    (opcrego_w == 'd17) ? 'd1 :
                          'd0;
  
  assign axis_status_data= status_valid_r;
  assign axis_status_valid = status_valid_r;

endmodule


