// =====================================================================
//  alu.v  --  arithmetic and logic unit
//  Workshop: designing a simple CPU for TinyTapeout
//  This is the module built in the Day 2 hands-on exercise.
// =====================================================================
`default_nettype none

module alu (
 input wire [7:0] a, // input ( / accumulator)
 input wire [7:0] b, // input ( memory)
    input  wire [2:0] op,     // requested operation
    output reg  [7:0] y,      // result
 output wire zero // zero flag: equals 1 result = 0
);

  // opcode definitions
  localparam ALU_ADD   = 3'd0;
  localparam ALU_SUB   = 3'd1;
  localparam ALU_AND   = 3'd2;
  localparam ALU_OR    = 3'd3;
 localparam ALU_PASSB = 3'd4; // input b unchanged ( LDA)
 localparam ALU_DEC = 3'd5; // decrement a 1

  always @(*) begin
    case (op)
      ALU_ADD:   y = a + b;
      ALU_SUB:   y = a - b;
      ALU_AND:   y = a & b;
      ALU_OR:    y = a | b;
      ALU_PASSB: y = b;
      ALU_DEC:   y = a - 8'd1;
      default:   y = 8'd0;
    endcase
  end

  assign zero = (y == 8'd0);

endmodule

`default_nettype wire
