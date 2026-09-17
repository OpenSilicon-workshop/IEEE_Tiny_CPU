// =====================================================================
//  tt_um_workshop_cpu.v  --  الوحدة الرئيسية المرسَلة إلى TinyTapeout
//
//  اسم الوحدة يجب أن يبدأ بـ tt_um_ حسب متطلبات القالب الرسمي.
//  كل تصميم في TinyTapeout له 8 مداخل و8 مخارج و8 أطراف ثنائية الاتجاه.
//
//  توزيع الأطراف في مشروعنا:
//    ui_in  [7:0] : مدخل بيانات خارجي تقرأه تعليمة IN
//    uo_out [7:0] : سجل الخرج (تكتب فيه تعليمة OUT)
//    uio_out[3:0] : عدّاد البرنامج PC (للمراقبة أثناء الاختبار)
//    uio_out[4]   : إشارة التوقف halted
//    uio_out[7:5] : غير مستخدمة (أصفار)
// =====================================================================
`default_nettype none

module tt_um_workshop_cpu (
    input  wire [7:0] ui_in,    // مداخل مخصصة
    output wire [7:0] uo_out,   // مخارج مخصصة
    input  wire [7:0] uio_in,   // أطراف ثنائية الاتجاه: المدخل
    output wire [7:0] uio_out,  // أطراف ثنائية الاتجاه: المخرج
    output wire [7:0] uio_oe,   // أطراف ثنائية الاتجاه: تفعيل الإخراج (1 = خرج)
    input  wire       ena,      // مرتفعة دائمًا عندما يكون التصميم مفعّلًا
    input  wire       clk,      // الساعة
    input  wire       rst_n     // التصفير (فعّال عند الصفر)
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
  assign uio_oe  = 8'hFF;  // كل الأطراف الثنائية تعمل كمخارج

  // منع تحذيرات الإشارات غير المستخدمة
  wire _unused = &{ena, uio_in, 1'b0};

endmodule

`default_nettype wire
