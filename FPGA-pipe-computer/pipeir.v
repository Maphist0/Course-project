module pipeir (pc4, ins, wpcir, clock, resetn, jwait, dpc4, inst);
    input   [31:0]  pc4, ins;
    input           wpcir, clock, resetn, jwait;
    output  [31:0]  dpc4, inst;

    reg     [31:0]  dpc4, inst;

    always @ (posedge clock or negedge resetn) begin
        if (resetn == 0) begin
            dpc4 <= 0;
            inst <= 0;
        end else if (jwait == 1) begin
			dpc4 <= 0;
			inst <= 0;
        end else if (wpcir == 1) begin
            dpc4 <= dpc4;
            inst <= inst;
        end else begin
            dpc4 <= pc4;
            inst <= ins;
        end
    end

endmodule
