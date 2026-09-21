// =====================================================================
//  cpu_ihp.v  --  redesigned CPU version using real IHP memory
//
// key difference from cpu.v: (single-cycle) 
// memory cycles clock. SRAM 
// : address cycles cycles .
//
// solution: each instruction is now executed in two phases ( ):
// phase ADDR: address ( write enable 
// STA) memory. program counter (PC) 
// rom[pc] remains stable .
// phase DATA: memory ( address 
// phase ). ALU update the accumulator
// then update the PC phase .
//
// Note: PC phase DATA rom[pc]
// ( ) 
// (latch) -- .
// =====================================================================
`default_nettype none

module cpu_ihp (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] in_port,
    output reg  [7:0] out_port,
    output reg        halted,
    output wire [3:0] pc_out,
 output wire phase_out // 0=ADDR 1=DATA -- useful for monitoring and learning
);

 // ---------------- opcode definitions ( cpu.v) ----------------
  localparam OP_NOP = 4'h0, OP_LDA = 4'h1, OP_STA = 4'h2, OP_ADD = 4'h3;
  localparam OP_SUB = 4'h4, OP_AND = 4'h5, OP_OR  = 4'h6, OP_LDI = 4'h7;
  localparam OP_JMP = 4'h8, OP_JZ  = 4'h9, OP_IN  = 4'hA, OP_OUT = 4'hB;
  localparam OP_DEC = 4'hC, OP_HLT = 4'hF;

  localparam ALU_ADD = 3'd0, ALU_SUB = 3'd1, ALU_AND = 3'd2;
  localparam ALU_OR  = 3'd3, ALU_PASSB = 3'd4, ALU_DEC = 3'd5;

  localparam PHASE_ADDR = 1'b0;
  localparam PHASE_DATA = 1'b1;

  // ---------------- internal registers ----------------
  reg [3:0] pc;
  reg [7:0] acc;
  reg       zflag;
  reg       phase;

  assign pc_out    = pc;
  assign phase_out = phase;

  // ---------------- instruction fetch and decode (fully combinational) --------
  wire [7:0] instr;
  rom u_rom (.addr(pc), .data(instr));

  wire [3:0] opcode  = instr[7:4];
  wire [3:0] operand = instr[3:0];

  wire is_write  = (opcode == OP_STA);

  // ---------------- real SRAM memory interface ----------------
  wire [7:0] sram_dout;
  wire       sram_we = (phase == PHASE_ADDR) && is_write;

  ihp_sram_256x8 u_ram (
      .clk (clk),
 .addr({4'b0000, operand}), // 4 8 (256 16 )
      .din (acc),
      .dout(sram_dout),
      .we  (sram_we)
  );

  // ---------------- arithmetic and logic unit ----------------
  reg  [2:0] alu_op;
  wire [7:0] alu_y;
  wire       alu_zero;

  alu u_alu (
      .a   (acc),
      .b   (sram_dout),
      .op  (alu_op),
      .y   (alu_y),
      .zero(alu_zero)
  );

  always @(*) begin
    case (opcode)
      OP_ADD:  alu_op = ALU_ADD;
      OP_SUB:  alu_op = ALU_SUB;
      OP_AND:  alu_op = ALU_AND;
      OP_OR:   alu_op = ALU_OR;
      OP_DEC:  alu_op = ALU_DEC;
      default: alu_op = ALU_PASSB;
    endcase
  end

 // ---------------- ( phase DATA ) ---
  reg [7:0] acc_next;
  reg       acc_we;

  always @(*) begin
    acc_next = alu_y;
    acc_we   = 1'b0;
    case (opcode)
      OP_LDA, OP_ADD, OP_SUB, OP_AND, OP_OR, OP_DEC: begin
 acc_next = alu_y; // alu_y sram_dout 
        acc_we   = 1'b1;
      end
      OP_LDI: begin
        acc_next = {4'b0000, operand};
        acc_we   = 1'b1;
      end
      OP_IN: begin
        acc_next = in_port;
        acc_we   = 1'b1;
      end
      default: acc_we = 1'b0;
    endcase
  end

  wire next_zero = (acc_next == 8'd0);

 // ---------------- : ----
  always @(posedge clk) begin
    if (!rst_n) begin
      pc       <= 4'd0;
      acc      <= 8'd0;
      zflag    <= 1'b1;
      out_port <= 8'd0;
      halted   <= 1'b0;
      phase    <= PHASE_ADDR;
    end else if (!halted) begin
      case (phase)

 // phase ADDR: address ( ) 
 // SRAM cycles (sram_we). no operation 
 // phase -- memory .
        PHASE_ADDR: begin
          phase <= PHASE_DATA;
        end

 // phase DATA: sram_dout address phase ADDR .
        PHASE_DATA: begin
          if (acc_we) begin
            acc   <= acc_next;
            zflag <= next_zero;
          end

          case (opcode)
            OP_OUT: out_port <= acc;
            OP_HLT: halted   <= 1'b1;
            default: ;
          endcase

 // program counter: zero flag ** 
 // (JZ zflag has not advanced yet )
          if (opcode == OP_JMP) begin
            pc <= operand;
          end else if (opcode == OP_JZ) begin
            pc <= zflag ? operand : (pc + 4'd1);
          end else begin
            pc <= pc + 4'd1;
          end

          phase <= PHASE_ADDR;
        end
      endcase
    end
  end

endmodule

`default_nettype wire
