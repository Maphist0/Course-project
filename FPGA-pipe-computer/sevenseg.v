module sevenseg (data, ledsegments);
    input 	[3:0] 	data; 
    output 	[6:0] 	ledsegments; 
    reg 	[6:0] 	ledsegments;
    always @ (*) 
		case(data)
        0: ledsegments = 7'b100_0000; 
        1: ledsegments = 7'b111_1001;
        2: ledsegments = 7'b010_0100;
        3: ledsegments = 7'b011_0000;
        4: ledsegments = 7'b001_1001;
        5: ledsegments = 7'b001_0010;
        6: ledsegments = 7'b000_0010;
        7: ledsegments = 7'b111_1000;
        8: ledsegments = 7'b000_0000;
        9: ledsegments = 7'b001_0000; 
        10:ledsegments = 7'b000_1000;
        11:ledsegments = 7'b000_0011;
        12:ledsegments = 7'b100_0110;
        13:ledsegments = 7'b010_0001;
        14:ledsegments = 7'b000_0110;
        15:ledsegments = 7'b000_1110;
        default: ledsegments = 7'b111_1111;
    endcase
endmodule
