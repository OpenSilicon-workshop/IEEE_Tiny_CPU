// =====================================================================
//  tt_um_workshop_cpu.v  --  main wrapper submitted to TinyTapeout
//
//  The module name must start with tt_um_ as required by the official template.
//  Each TinyTapeout design has 8 inputs and8 outputs and8 bidirectional pins.
//
//  Pin assignment in this project:
//    ui_in  [7:0] : external data input read by the IN instruction
//    uo_out [7:0] : output register (written by the OUT instruction)
//    uio_out[3:0] : program counter PC (for observation during testing)
//    uio_out[4]   : halt signal halted
// uio_out[7:5] : unused ()
// =====================================================================
`default_nettype none

module tt_um_workshop_cpu (
    input  wire [7:0] ui_in,    // dedicated inputs
    output wire [7:0] uo_out,   // dedicated outputs
    input  wire [7:0] uio_in,   // bidirectional pins: input
    output wire [7:0] uio_out,  // bidirectional pins: output
 output wire [7:0] uio_oe, // bidirectional pins: output enable (1 = )
    input  wire       ena,      // always high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset (active low)
);

  wire [7:0] out_port;
  wire [3:0] pc_out;
  wire       halted;

  cpu u_cpu (
      .clk     (clk),
      .rst_n   (rst_n),
      .in_port (ui_in),
      .out_port(out_port),
      .halted  (halted),
      .pc_out  (pc_out)
  );

  assign uo_out  = out_port;
  assign uio_out = {3'b000, halted, pc_out};
  assign uio_oe  = 8'hFF;  // all bidirectional pins are outputs

  // prevent unused-signal warnings
  wire _unused = &{ena, uio_in, 1'b0};

endmodule

`default_nettype wire
