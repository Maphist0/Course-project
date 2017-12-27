module pipemem (mwmem, malu, mb, clock, mem_clock, mmo, in_port0, in_port1, out_port0, out_port1, resetn);

    input           mwmem, clock, mem_clock, resetn;
    input   [31:0]  malu, mb;
    input  	[31:0]  in_port0, in_port1;

    output  [31:0]  mmo;
    output 	[31:0]  out_port0, out_port1;

    // Unused
    wire            dmem_clk;
    wire    [31:0]  mem_dataout, io_read_data;


    datamem dmem (
    	malu, mb, mmo, mwmem, clock, mem_clock, dmem_clk,
    	resetn, out_port0, out_port1, in_port0, in_port1,
        mem_dataout, io_read_data
    );


endmodule
