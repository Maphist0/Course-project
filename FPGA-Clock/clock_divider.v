// Divide the 50(MHz) clock to 1(KHz), i.e. 1(ms)
//
// Input variable:
// @ clk: 		The orginal 50(MHz) clock.
// @ rst: 		The reset button signal. *** Negative Logic ***
// 
// Output variable:
// @ out_clk:	The 1(KHz) clock.
//

module clk_divider(clk, rst, out_clk);
	input clk;	// 50 MHz
	input rst;	// reset
	output reg out_clk;
 
    reg [31:0] count;
      
    always @ (posedge clk or negedge rst)  
    begin  
        if (~rst)	// Reset
        begin  
            count <= 0;  
            out_clk <= 0;  
        end  
        // 250000
        else if (count == 250000) 
		begin  
			count <= 0;  
			out_clk <= ~out_clk;  
		end
		else begin  
			count <= count+1;  
			out_clk <= out_clk;  
		end  
    end  
  
endmodule  