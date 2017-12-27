module pipeemreg (
    ewreg, em2reg, ewmem, ealu, eb, ern, clock, resetn,
    mwreg, mm2reg, mwmem, malu, mb, mrn
);

    input           clock, resetn;

    input           ewreg, em2reg, ewmem;
    input   [ 4:0]  ern;
    input   [31:0]  ealu, eb;

    output  reg     mwreg, mm2reg, mwmem;
    output  reg     [ 4:0]  mrn;
    output  reg     [31:0]  malu, mb;

    always @ (posedge clock or negedge resetn) begin
        if (resetn == 0) begin
            mwreg   <=  0;
            mm2reg  <=  0;
            mwmem   <=  0;
            mrn     <=  0;
            malu    <=  0;
            mb      <=  0;
        end else begin
            mwreg   <=  ewreg;
            mm2reg  <=  em2reg;
            mwmem   <=  ewmem;
            mrn     <=  ern;
            malu    <=  ealu;
            mb      <=  eb;
        end
    end
endmodule
