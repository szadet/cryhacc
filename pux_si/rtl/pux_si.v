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
  parameter OPFIFOW  = 3    /* Size of the FIFO pointers */
)(
  input            axis_clk,            /*< Module clock */
  input            axis_rstn,           /*< Module reset */

  input [OPCW-1:0] axis_opcode_data,    /*< Opcode data input*/
  input            axis_opcode_valid,   /*< Opcode valid */
  output           axis_opcode_ready,   /*< Opcode ready */

  input [DATAW-1:0] axis_abuff_data,    /*< Buffer A data input*/
  input             axis_abuff_valid,   /*< Buffer A valid */
  output            axis_abuff_ready,   /*< Buffer A ready */

  input [DATAW-1:0] axis_bbuff_data,    /*< Buffer B data input*/
  input             axis_bbuff_valid,   /*< Buffer B valid */
  output            axis_bbuff_ready,   /*< Buffer B ready */
  
  input [DATAW-1:0] axis_mbuff_data,    /*< Buffer M data input*/
  input             axis_mbuff_valid,   /*< Buffer M valid */
  output            axis_mbuff_ready,   /*< Buffer M ready */  

  input              axis_status_ready, /*< Status ready */
  output [DATAW-1:0] axis_status_data,  /*< Status data input*/
  output             axis_status_valid, /*< Status valid */    

  output stream_reqest                  /*< Request stream fetch */ 
);

/**
 * Stream signals definition
 * @author Tomasz Szade
 */
 wire [OPFIFOW:0] wptr_r;
 wire [OPFIFOW:0] rptr_r;
 
/**
 * Signals
 */
endmodule


