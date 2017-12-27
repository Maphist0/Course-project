module sevensegDisplay(display, hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7);
	input [31:0] display;
	output [6:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
	
	sevenseg msecond_low 	(display[3:0], hex0);
	sevenseg msecond_high 	(display[7:4], hex1);
	sevenseg second_low		(display[11:8], hex2);
	sevenseg second_high	(display[15:12], hex3);
	sevenseg minute_low		(display[19:16], hex4);
	sevenseg minute_high	(display[23:20], hex5);
	sevenseg hour_low		(display[27:24], hex6);
	sevenseg hour_high		(display[31:28], hex7);

endmodule
