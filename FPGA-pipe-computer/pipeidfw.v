module pipeidfw (
    clock, ewreg, ern, em2reg, mwreg, mrn, mm2reg, rs, rt,
    fwda, fwdb
);

    input           clock, ewreg, mwreg, em2reg, mm2reg;
    input   [ 4:0]  ern, mrn, rs, rt;

    output  [ 1:0]  fwda, fwdb;
    //assign 	fwda[1] = (mwreg & (mrn != 0) & (mrn == rs) & ~mm2reg)  | ~(ewreg & (ern != 0) & (ern == rs) & ~em2reg) | (mwreg & (mrn != 0) & (mrn == rs) & mm2reg);
    //assign	fwda[0] = ~(mwreg & (mrn != 0) & (mrn == rs) & ~mm2reg) | (ewreg & (ern != 0) & (ern == rs) & ~em2reg)  | (mwreg & (mrn != 0) & (mrn == rs) & mm2reg);
    //assign  fwdb[1] = (mwreg & (mrn != 0) & (mrn == rt) & ~mm2reg)  | ~(ewreg & (ern != 0) & (ern == rt) & ~em2reg) | (mwreg & (mrn != 0) & (mrn == rt) & mm2reg);
    //assign  fwdb[0] = ~(mwreg & (mrn != 0) & (mrn == rt) & ~mm2reg) | (ewreg & (ern != 0) & (ern == rt) & ~em2reg)  | (mwreg & (mrn != 0) & (mrn == rt) & mm2reg);
    reg     [ 1:0]  fwda, fwdb;

    always @ (*) begin

        //fwda = 2'b00;       // Default forward a: no hazrads
        if (ewreg & (ern != 0) & (ern == rs) & ~em2reg) begin
            fwda <= 2'b01;   // Select exe_alu
        end else if (mwreg & (mrn != 0) & (mrn == rs) & ~mm2reg) begin
            fwda <= 2'b10;   // Select mem_alu
        end else if (mwreg & (mrn != 0) & (mrn == rs) & mm2reg) begin
            fwda <= 2'b11;   // Select mem_lw
        end else begin
			fwda <= 2'b00;
        end

        //fwdb = 2'b00;       // Default forward b: no hazrads
        if (ewreg & (ern != 0) & (ern == rt) & ~em2reg) begin
            fwdb <= 2'b01;   // Select exe_alu
        end else if (mwreg & (mrn != 0) & (mrn == rt) & ~mm2reg) begin
            fwdb <= 2'b10;   // Select mem_alu
        end else if (mwreg & (mrn != 0) & (mrn == rt) & mm2reg) begin
            fwdb <= 2'b11;   // Select mem_lw
        end else begin
			fwdb <= 2'b00; 
        end
    end
endmodule
