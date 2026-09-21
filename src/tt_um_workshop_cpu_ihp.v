// =====================================================================
// tt_um_workshop_cpu_ihp.v -- (IHP memory variant)
//
// tt_um_workshop_cpu.v with an additional signal phase 
// uio_out[5] to monitor the memory phase (ADDR/DATA) .
// =====================================================================
`default_nettype none

module tt_um_workshop_cpu_ihp (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  wire [7:0] out_port;
  wire [3:0] pc_out;
  wire       halted;
  wire       phase_out;

  cpu_ihp u_cpu (
      .clk      (clk),
      .rst_n    (rst_n),
      .in_port  (ui_in),
      .out_port (out_port),
      .halted   (halted),
      .pc_out   (pc_out),
      .phase_out(phase_out)
  );

  assign uo_out  = out_port;
  assign uio_out = {2'b00, phase_out, halted, pc_out};
  assign uio_oe  = 8'hFF;

  wire _unused = &{ena, uio_in, 1'b0};

endmodule

`default_nettype wire
