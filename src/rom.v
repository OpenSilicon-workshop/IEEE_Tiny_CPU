// =====================================================================
// rom.v -- (Program ROM)
//
// Note :
// `initial` memory `initial` (non-synthesizable)
// ASIC. case .
//
// (8 ): [7:4] = | [3:0] = 
//
// : 5+4+3+2+1 = 15 .
// =====================================================================
`default_nettype none

module rom (
    input  wire [3:0] addr,
    output reg  [7:0] data
);

  always @(*) begin
    case (addr)
      4'd0:  data = 8'h70;  // LDI 0      A = 0
      4'd1:  data = 8'h28;  // STA 8      sum = 0
      4'd2:  data = 8'h75;  // LDI 5      A = 5
      4'd3:  data = 8'h29;  // STA 9      cnt = 5
      4'd4:  data = 8'h18;  // LDA 8      loop: A = sum
      4'd5:  data = 8'h39;  // ADD 9      A = sum + cnt
      4'd6:  data = 8'h28;  // STA 8      sum = A
      4'd7:  data = 8'h19;  // LDA 9      A = cnt
      4'd8:  data = 8'hC0;  // DEC        A = cnt - 1
      4'd9:  data = 8'h29;  // STA 9      cnt = A
      4'd10: data = 8'h9C;  // JZ 12      if cnt == 0 -> 12
      4'd11: data = 8'h84;  // JMP 4      else repeat loop
      4'd12: data = 8'h18;  // LDA 8      A = sum
      4'd13: data = 8'hB0;  // OUT        output = A
      4'd14: data = 8'hF0;  // HLT        halt
      4'd15: data = 8'h00;  // NOP        padding
      default: data = 8'h00;
    endcase
  end

endmodule

`default_nettype wire
