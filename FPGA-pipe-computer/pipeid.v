module pipeid (
    mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
    wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
    bpc, jpc, pcsource, wpcir, dwreg, dm2reg, dwmem, daluc,
    daluimm, da, db, dimm, sa, drn, dshift, djal, jwait,
    fwda, fwdb, rs, rt // debug
);
    input   [31:0]  dpc4, inst, wdi, ealu, malu, mmo;
    input   [ 4:0]  wrn;
    input           mwreg, ewreg, em2reg, mm2reg;
    input	[ 4:0]	ern, mrn;
    input           wwreg, clock, resetn;
    
    output  [ 1:0]  fwda, fwdb;
    output	[ 4:0]	rs, rt;

    output  [31:0]  bpc, jpc;
    output  [31:0]  da, db, dimm, sa;
    output	[ 4:0]	drn;
    output  [ 1:0]  pcsource;
    output	[ 3:0]	daluc;
    output          wpcir, dwreg, dm2reg, dwmem, daluimm;
    output          dshift, djal, jwait;

    wire            regclk, rsrtequ, sext, e, regrt;
    wire    [ 1:0]  fwda, fwdb;
    wire    [ 4:0]  rs, rt, rd;
    wire	[25:0]	addr;
    wire    [ 5:0]  op, func;
    wire	[15:0]	signext, imm;
    wire    [31:0]  q1, q2;

    // Separate the instruction.
    assign  op      = inst[31:26];
    assign  rs      = inst[25:21];
    assign  rt      = inst[20:16];
    assign  rd      = inst[15:11];
    assign  func    = inst[ 5:0 ];
    assign  imm     = inst[15:0 ];
    assign  addr    = inst[25:0 ];

    assign  regclk  = ~clock;
    assign  rsrtequ = (da == db) ? 1'b1 : 1'b0;
    assign  sa		= {27'b0, inst[10:6]};
    assign  e       = sext & imm[15];
    assign	signext	= {16{e}};
    assign  bpc     = dpc4 + {signext[13:0], imm, 1'b0, 1'b0};
    assign  dimm    = {signext, imm};
    assign  jpc     = {dpc4[31:28], addr, 1'b0, 1'b0};
    assign  wpcir   = em2reg & ((ern == rs) | (ern == rt));

    // Forward unit.
    pipeidfw id_forward (clock, ewreg, ern, em2reg, mwreg, mrn, mm2reg, rs, rt, fwda, fwdb);
    // Register file.
    regfile pipe_regfile (rs, rt, wdi, wrn, wwreg, regclk, resetn, q1, q2);
    // Mux to deal with forwarding.
    mux4x32 mux_da (q1, ealu, malu, mmo, fwda, da);
    mux4x32 mux_db (q2, ealu, malu, mmo, fwdb, db);
    // Mux to control write-back address.
    mux2x5  mux_n (rd, rt, regrt, drn);
    // Control unit.
    cu pipe_cu (op, func, rsrtequ, pcsource, dwreg, dm2reg, dwmem,
        djal, daluc, daluimm, dshift, regrt, sext, wpcir, jwait);


endmodule
