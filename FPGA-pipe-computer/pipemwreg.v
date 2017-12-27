module pipemwreg (
    mwreg, mm2reg, mmo, malu, mrn, clock, resetn,
    wwreg, wm2reg, wmo, walu, wrn
);

    input           clock, resetn;

    input           mwreg, mm2reg;
    input   [ 4:0]  mrn;
    input   [31:0]  mmo, malu;

    output          wwreg, wm2reg;
    output  [ 4:0]  wrn;
    output  [31:0]  wmo, walu;

    reg             wwreg, wm2reg;
    reg     [ 4:0]  wrn;
    reg     [31:0]  wmo, walu;

    always @ (posedge clock or negedge resetn) begin
        if (resetn == 0) begin
            wwreg   <=  0;
            wm2reg  <=  0;
            wrn     <=  0;
            wmo     <=  0;
            walu    <=  0;
        end else begin
            wwreg   <=  mwreg;
            wm2reg  <=  mm2reg;
            wrn     <=  mrn;
            wmo     <=  mmo;
            walu    <=  malu;
        end
    end
endmodule
