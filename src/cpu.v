// =====================================================================
//  cpu.v  --  نواة المعالج البسيط
//
//  معالج ذو مركم (accumulator) بعرض 8 بت، ينفّذ تعليمة واحدة في كل دورة
//  ساعة (single-cycle): الجلب وفك الترميز والتنفيذ كلها في نفس الدورة.
//
//  مجموعة التعليمات (ISA):
//    0x0 NOP        لا شيء
//    0x1 LDA addr   A  <- RAM[addr]
//    0x2 STA addr   RAM[addr] <- A
//    0x3 ADD addr   A  <- A + RAM[addr]
//    0x4 SUB addr   A  <- A - RAM[addr]
//    0x5 AND addr   A  <- A & RAM[addr]
//    0x6 OR  addr   A  <- A | RAM[addr]
//    0x7 LDI imm    A  <- imm (قيمة مباشرة 0..15)
//    0x8 JMP addr   PC <- addr
//    0x9 JZ  addr   إذا كان علم الصفر مرفوعًا: PC <- addr
//    0xA IN         A  <- in_port  (المداخل الخارجية)
//    0xB OUT        out_port <- A
//    0xC DEC        A  <- A - 1
//    0xF HLT        إيقاف المعالج
//
//  ملاحظة عن علم الصفر (Z): يُحدَّث فقط عند التعليمات التي تكتب في المركم.
//  لذلك STA بعد DEC لا تُفسد العلم، وهو ما يسمح لـ JZ بالعمل بشكل صحيح.
// =====================================================================
`default_nettype none

module cpu (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] in_port,
    output reg  [7:0] out_port,
    output reg        halted,
    output wire [3:0] pc_out
);

  // ---------------- رموز العمليات ----------------
  localparam OP_NOP = 4'h0, OP_LDA = 4'h1, OP_STA = 4'h2, OP_ADD = 4'h3;
  localparam OP_SUB = 4'h4, OP_AND = 4'h5, OP_OR  = 4'h6, OP_LDI = 4'h7;
  localparam OP_JMP = 4'h8, OP_JZ  = 4'h9, OP_IN  = 4'hA, OP_OUT = 4'hB;
  localparam OP_DEC = 4'hC, OP_HLT = 4'hF;

  localparam ALU_ADD = 3'd0, ALU_SUB = 3'd1, ALU_AND = 3'd2;
  localparam ALU_OR  = 3'd3, ALU_PASSB = 3'd4, ALU_DEC = 3'd5;

  // ---------------- السجلات الداخلية ----------------
  reg [3:0] pc;        // عدّاد البرنامج
  reg [7:0] acc;       // المركم
  reg       zflag;     // علم الصفر
  reg [7:0] ram [0:15];// ذاكرة البيانات: 16 كلمة × 8 بت

  integer i;

  assign pc_out = pc;

  // ---------------- جلب التعليمة وفك ترميزها ----------------
  wire [7:0] instr;
  rom u_rom (.addr(pc), .data(instr));

  wire [3:0] opcode  = instr[7:4];
  wire [3:0] operand = instr[3:0];

  // قراءة الذاكرة قراءةً تجميعية (distributed RAM)
  wire [7:0] mem_data = ram[operand];

  // ---------------- وحدة الحساب والمنطق ----------------
  reg  [2:0] alu_op;
  wire [7:0] alu_y;
  wire       alu_zero;

  alu u_alu (
      .a   (acc),
      .b   (mem_data),
      .op  (alu_op),
      .y   (alu_y),
      .zero(alu_zero)
  );

  // ---------------- وحدة التحكم: اختيار عملية ALU ----------------
  always @(*) begin
    case (opcode)
      OP_ADD:  alu_op = ALU_ADD;
      OP_SUB:  alu_op = ALU_SUB;
      OP_AND:  alu_op = ALU_AND;
      OP_OR:   alu_op = ALU_OR;
      OP_DEC:  alu_op = ALU_DEC;
      default: alu_op = ALU_PASSB;  // LDA وغيرها: تمرير قيمة الذاكرة
    endcase
  end

  // ---------------- وحدة التحكم: القيمة التالية للمركم ----------------
  reg [7:0] acc_next;
  reg       acc_we;    // هل تُكتب قيمة جديدة في المركم؟

  always @(*) begin
    acc_next = alu_y;
    acc_we   = 1'b0;
    case (opcode)
      OP_LDA, OP_ADD, OP_SUB, OP_AND, OP_OR, OP_DEC: begin
        acc_next = alu_y;
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

  // علم الصفر يُحسب من القيمة التي ستُكتب فعليًا في المركم
  wire next_zero = (acc_next == 8'd0);

  // ---------------- المنطق التسلسلي ----------------
  always @(posedge clk) begin
    if (!rst_n) begin
      pc       <= 4'd0;
      acc      <= 8'd0;
      zflag    <= 1'b1;      // 0 يساوي صفرًا، فالعلم مرفوع بعد التصفير
      out_port <= 8'd0;
      halted   <= 1'b0;
      for (i = 0; i < 16; i = i + 1) ram[i] <= 8'd0;
    end else if (!halted) begin
      // الافتراضي: الانتقال إلى التعليمة التالية
      pc <= pc + 4'd1;

      if (acc_we) begin
        acc   <= acc_next;
        zflag <= next_zero;
      end

      case (opcode)
        OP_STA:  ram[operand] <= acc;
        OP_JMP:  pc <= operand;
        OP_JZ:   if (zflag) pc <= operand;
        OP_OUT:  out_port <= acc;
        OP_HLT:  halted <= 1'b1;
        default: ; // لا شيء إضافي
      endcase
    end
  end

endmodule

`default_nettype wire
