module clock(clk, key_reset, key_start_pause, key_display_stop,
    hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7,
    led0, led1, led2); 

    input clk, key_reset, key_start_pause, key_display_stop; 
    
    // For 7-segment
    output [6:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
    output led0, led1, led2;
	wire led0, led1, led2;
    
    // Divide the 50(MHz) clock to 1(KHz), i.e. 1(ms)
    //
    // Input
    // @ clk: 		The orginal 50(MHz) clock.
    // @ rst: 		The reset button signal.
    // 
    // Output
    // @ out_clk:	The 1(KHz) clock.
    //
    wire ms_clk;
    clk_divider ms_clock (
		.clk(clk),
		.rst(key_reset),
		.out_clk(ms_clk)
    );
    
    // Debounce key_display_stop button.
    wire is_display_stop;
	debounce debounce_display_stop (
		.sig_in(key_display_stop),
		.clk_1k(ms_clk),
		.sig_out(is_display_stop)
	);
	
	// Debounce key_start_pause button
	wire is_pause;
	debounce debounce_pause (
		.sig_in(key_start_pause),
		.clk_1k(ms_clk),
		.sig_out(is_pause)
	);
	
	assign led0 = key_reset;
	assign led1 = is_pause;
	assign led2 = is_display_stop;
	
    
    // Use "key_display_stop" to control the display.
    //
    // Input
    // @ counter:	32 bit (8 x (4 bit each)) reg to store the time.
    // @ is_display_stop:	Control signal, "1" to synchronize the display with count.
    //
    // Output
    // @ display:	32 bit (8 x (4 bit each)) reg to store the display signal.
    //
    wire [31:0] counter;
	wire [31:0] display;
    displayControl disCtrl (
		.counter(counter),
		.display(display),
		.is_display_stop(is_display_stop)
    );
    
    // Allocate the display control to actual 7-seg signal.
    sevensegDisplay dis (
		.display(display),
		.hex0(hex0), .hex1(hex1), .hex2(hex2), .hex3(hex3), 
		.hex4(hex4), .hex5(hex5), .hex6(hex6), .hex7(hex7) 
    );
    
    // Bind clock with counter.
    counter cnt (
		.clk(ms_clk),
		.rst(key_reset),
		.is_pause(is_pause),
		.count(counter)
    );
		
endmodule
