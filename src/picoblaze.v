// Author: merlionfire 
// 
// Create Date:    04/12/2015 
// Design Name: 
// Module Name:    frac_calc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module picoblaze (
       
   // --- clock and reset 
   input  wire          clk,
   input  wire          reset,
   
   // --- I/O interface 
   output wire [7:0]    port_id,
   output wire          write_strobe,
   output wire          read_strobe,
   output wire [7:0]    out_port,
   input  wire [7:0]    in_port,
    
   // --- interrupt 
   input  wire          interrupt,
   output wire          interrupt_ack
);


wire [9:0] 	address;
wire [17:0] instruction;




  //******************************************************************//
  // Instantiate PicoBlaze and the Program ROM.                       // 
  //******************************************************************//
  kcpsm3 kcpsm3_inst (
    .address(address),
    .instruction(instruction),
    .port_id(port_id),
    .write_strobe(write_strobe),
    .out_port(out_port),
    .read_strobe(read_strobe),
    .in_port(in_port),
    .interrupt(interrupt),
    .interrupt_ack(interrupt_ack),
    .reset(reset),
    .clk(clk));

  picocode picocode_inst (
    .address(address),
    .instruction(instruction),
    .clk(clk));

endmodule


