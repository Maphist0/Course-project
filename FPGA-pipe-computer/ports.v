module portconnector (in0_0, in0_1, in1_0, in1_1, leds, ctrl_plus, resetn,
	in_port0, in_port1, out_port0, out_port1
);
	input			resetn, ctrl_plus;
	
	input	[ 3:0]	in0_0, in0_1, in1_0, in1_1;
	
	output	[55:0]	leds;
	
	output 	[31:0] 	in_port0, in_port1;
	
	input 	[31:0] 	out_port0, out_port1;
	
	wire 	[31:0] 	showing_result, neg_out;
	
	wire 			is_neg;
	
	assign 	in_port0 	= 	{24'd0, in0_0, in0_1};
	
	assign 	in_port1 	= 	{24'd0, in1_0, in1_1};
	
	detect_neg detectNeg(out_port1, is_neg, neg_out, resetn);
	
	mux2x32 show_ctrl(out_port0, neg_out, ctrl_plus, showing_result);
	
	sevenseg num0_0(.data(in0_0), .ledsegments(leds[55:49]));  					// HEX7
	sevenseg num0_1(.data(in0_1), .ledsegments(leds[48:42]));  					// HEX6
	sevenseg num1_0(.data(in1_0), .ledsegments(leds[41:35]));  					// HEX5
	sevenseg num1_1(.data(in1_1), .ledsegments(leds[34:28]));  					// HEX4
	// Assign the 'sign' digit here.		                      				// HEX3
	neg_sign ctrlsign(leds[27:21], is_neg, resetn, ctrl_plus);
	sevenseg out_num2(.data(showing_result[11:8]), .ledsegments(leds[20:14])); 	// HEX2
	sevenseg out_num1(.data(showing_result[7:4]), .ledsegments(leds[13:7]));   	// HEX1
	sevenseg out_num0(.data(showing_result[3:0]), .ledsegments(leds[6:0]));   	// HEX0
	

endmodule
 
module neg_sign(led, is_neg, resetn, ctrl);
	output reg [6:0] led;
	input is_neg, resetn, ctrl;
	
	always @ (*)
	begin
		if (resetn == 0)
			led <= 7'b111_1111;
		else
		begin
		if (is_neg == 1 && ctrl == 1)
			led <= 7'b011_1111;
		else
			led <= 7'b111_1111;
		end
	end
endmodule

module detect_neg(data, is_neg, neg_data, resetn);

	input  	[31:0] 	data;
	
	input 			resetn;
	
	output 	[31:0] 	neg_data;
	
	output 		 	is_neg;
	
	reg		[31:0]	neg_data;
	
	reg				is_neg;
	
	always @ (*)
	begin
		if (resetn == 0)
		begin
			is_neg <= 0;
			neg_data <= data;
		end
		else if (data[31:12] == 20'b1111_1111_1111_1111_1111)
		begin
			is_neg <= 1;
			neg_data <= (~data + 1'b1);
		end
		else
		begin
			is_neg <= 0;
			neg_data <= data;
		end
	end
endmodule
