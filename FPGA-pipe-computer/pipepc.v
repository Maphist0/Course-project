module pipepc (npc, wpcir, clock, resetn, pc);
    input   [31:0]  npc;
    input           clock, resetn, wpcir;

    output  [31:0]  pc;
    // reg     [31:0]  pc;
    reg     [31:0]  pcreg;
    
    assign pc = pcreg;

    always @ (posedge clock or negedge resetn) begin
		if (resetn == 0) begin
            pcreg <= -4;
        end else if (wpcir == 0) begin
			pcreg <= npc;
		end else begin
			pcreg <= pcreg;
		end
    end
endmodule
