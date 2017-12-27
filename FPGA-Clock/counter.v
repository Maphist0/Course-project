// reset is ** Negative Logic **
module counter(clk, rst, is_pause, count);
	input clk;
	input rst;
	input is_pause;
	output reg [31:0] count;
	
	reg [3:0] msecond_low;
	reg [3:0] msecond_high;
	reg [3:0] second_low;
	reg [3:0] second_high;
	reg [3:0] minute_low;
	reg [3:0] minute_high;
	reg [3:0] hour_low;
	reg [3:0] hour_high;
	
	reg state;
	
	initial
	begin
		state <= 1;
	end
	
	always @ (posedge is_pause)
	begin
		state <= ~state;
	end
	
	always @ (posedge clk or negedge rst)
	begin
		if (rst == 0)
			count <= 0;
		else if (state == 0)
			count <= count;
		else
		begin
			msecond_low = count[3:0];
			msecond_high = count[7:4];
			second_low = count[11:8];
			second_high = count[15:12];
			minute_low = count[19:16];
			minute_high = count[23:20];
			hour_low = count[27:24];
			hour_high = count[31:28];
			
			msecond_low = msecond_low + 1;
				if (msecond_low == 10)
				begin
					msecond_high = msecond_high + 1;
					if (msecond_high == 10)
					begin
						second_low = second_low + 1;
						if (second_low == 10)
						begin
							second_high = second_high + 1;
							if (second_high == 6)
							begin
								minute_low = minute_low + 1;
								if (minute_low == 10)
								begin
									minute_high = minute_high + 1;
									if (minute_high == 6)
									begin
										hour_low = hour_low + 1;
										if (hour_low == 10)
										begin
											hour_high = hour_high + 1;
											if (hour_high == 10)
											begin
												hour_high = 0;
											end
											hour_low = 0;
										end
										minute_high = 0;
									end
									minute_low = 0;
								end
								second_high = 0;
							end
							second_low = 0;
						end
						msecond_high = 0;
					end
					msecond_low = 0;
				end
			count = {hour_high, hour_low, minute_high, minute_low, second_high,
			second_low, msecond_high, msecond_low};
		end	
	end
endmodule
