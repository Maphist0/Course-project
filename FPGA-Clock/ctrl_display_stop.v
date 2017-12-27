// Control display or not

module displayControl(counter, display, is_display_stop);
	input is_display_stop;
	input [31:0] counter;
	output reg [31:0] display;
	
	reg display_state;
	
	initial
	begin
		display_state <= 1;
	end
	
	always @ (posedge is_display_stop)
	begin
		display_state <= ~display_state;
	end
	
	always @ (*)
	begin	
		if (display_state)
			display <= counter;
		else
			display <= display;
	end
endmodule
