// *** Negative Logic ***
module debounce(sig_in, clk_1k, sig_out);
	input sig_in;
	input clk_1k;
	output reg sig_out;
		
	reg [7:0] cntTmp;
	always @ (posedge clk_1k)
	begin
		cntTmp <= {cntTmp[6:0], sig_in};
		if (cntTmp[7:0] == 8'b00000000)
			sig_out <= 1'b1;
		else if (cntTmp[7:0] == 8'b11111111)
			sig_out <= 1'b0;
		else
			sig_out <= sig_out;
	end
endmodule
