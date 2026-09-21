// =====================================================================
//  ihp_sram_256x8.v  --  wrapper around the real IHP SG13G2 memory macro
//
//  ⚠️ VERY IMPORTANT before actual fabrication:
// 
// ( ihp-sg13g2-ams-chip-template 
// RM_IHPSG13_1P_1024x32_c2_bm_bist). pin assignment 
// memory :
// - 256x8 ( "c2" )
// - BIST 
// - A_BM ( 1 " " " ")
// - A_DLY 
//
// Before submitting the design: review the files IHP-Open-PDK
// (ihp-sg13g2/libs.ref/sg13g2_sram) memory 
// TinyTapeout ( 
// -- discord ).
//
// clean interface (clean interface) cpu_ihp.v:
// addr : address 8 ( 4 : 16 256)
//    din  : write data
// dout : read data -- arrives one clock cycle after addr
// we : write enable (1 = 0 = )
// =====================================================================
`default_nettype none

module ihp_sram_256x8 (
    input  wire       clk,
    input  wire [7:0] addr,
    input  wire [7:0] din,
    output wire [7:0] dout,
    input  wire       we
);

`ifdef SIM
  // -------------------------------------------------------------------
 // behavioral model for local simulation only -- **** .
 // : cycles 
 // (registered read) .
  // -------------------------------------------------------------------
  reg [7:0] mem [0:255];
  reg [7:0] dout_r;

  always @(posedge clk) begin
 dout_r <= mem[addr]; // ( )
    if (we) mem[addr] <= din;
  end

  assign dout = dout_r;

`else
  // -------------------------------------------------------------------
 // IHP SG13G2 ( !)
 // ihp-sg13g2-ams-chip-template. 
 // Note .
  // -------------------------------------------------------------------
  RM_IHPSG13_1P_256x8_c2_bm_bist u_sram (
      .A_CLK  (clk),
 .A_MEN (1'b1), // memory 
 .A_REN (~we), // 
      .A_WEN  (we),         // write enable
      .A_ADDR (addr),
      .A_DIN  (din),
 .A_BM (8'hFF), // TODO: -- " "
 .A_DLY (1'b1), // TODO: 
      .A_DOUT (dout)
 // TODO: A_BIST_* 0 BIST.
 // memory -- .lef
 // IHP-Open-PDK .
  );
`endif

endmodule

`default_nettype wire
