module pipe_computer (resetn, clock, in0_0, in0_1, in1_0, in1_1, leds, ctrl_plus, debug_led,
	pc, ins, ealu, malu, walu,
    inst, fwda, fwdb, da, db, dimm, esa,
    ewreg, ern, mrn, rs, rt, em2reg, mm2reg, dshift
	//da, db, dimm, dpc4, a, b, ins, mb, wdi,
	//drn, ern0, ern, wrn, pcsource
	); // debug

	//output	[31:0]	da, db, dimm, a, b, dpc4, mb, wdi; // debug
	
	//output  [ 4:0]  drn,ern0,ern,wrn;
	
	//output  [ 1:0]  pcsource;
	
	output	[ 1:0]	fwda, fwdb;
	output			ewreg, em2reg, mm2reg, dshift;
	output	[ 4:0]	ern, mrn, rs, rt;
	output	[31:0]	da, db, dimm, esa;
	
    input           resetn, clock, ctrl_plus;
    
    input	[ 3:0]	in0_0, in0_1, in1_0, in1_1;
    
    output 	[17:0] 	debug_led;
	
    output  [31:0]  pc, ealu, ins, malu, walu;
    
    output	[31:0]	inst;
    
    output	[55:0]	leds;

    wire    [31:0]  bpc, jpc, npc, pc4, ins, inst, malu;

    wire    [31:0]  dpc4, da, db, dimm, dsa;

    wire    [31:0]  epc4, ea, eb, eimm, esa;

    wire    [31:0]  mb, mmo;

    wire    [31:0]  wmo,wdi;
    
    wire 	[31:0] 	in_port0, in_port1;
    
	wire 	[31:0] 	out_port0, out_port1;

    wire    [ 4:0]  drn,ern0,ern,mrn,wrn;

    wire    [ 3:0]  daluc, ealuc;

    wire    [ 1:0]  pcsource;

    wire            wpcir, jwait;

    wire            dwreg, dm2reg, dwmem, daluimm, dshift, djal; // id stage

    wire            ewreg, em2reg, ewmem, ealuimm, eshift, ejal; // exe stage

    wire            mwreg, mm2reg, mwmem; // mem stage

    wire            wwreg, wm2reg; // wb stage
    
    wire 			mem_clock = ~clock;
    
    assign 	debug_led 	= {in0_0, in0_1, in1_0, in1_1, resetn, ctrl_plus};
    
    portconnector ctrlports ( in0_0, in0_1, in1_0, in1_1, leds, ctrl_plus, resetn,
		in_port0, in_port1, out_port0, out_port1 );

    pipepc prog_cnt ( npc, wpcir, clock, resetn, pc );

    pipeif if_stage ( pcsource, pc, bpc, da, jpc, npc, pc4, ins, mem_clock ); // IF stage

    pipeir inst_reg ( pc4, ins, wpcir, clock, resetn, jwait, dpc4, inst );// IF/ID

    pipeid id_stage ( mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
		wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
		bpc, jpc, pcsource,wpcir, dwreg, dm2reg, dwmem, daluc,
		daluimm, da, db, dimm, dsa, drn, dshift, djal, jwait,
		fwda, fwdb, rs, rt ); // ID stage

    pipedereg de_reg ( dwreg, dm2reg, dwmem, daluc, daluimm, da, db, dimm, drn, dshift, 
		djal, dpc4, dsa, clock, resetn, ewreg, em2reg,
		ewmem, ealuc, ealuimm,
		ea, eb, eimm, ern0, eshift, ejal, epc4, esa );
		
    pipeexe exe_stage ( ealuc, ealuimm, ea, eb, eimm, eshift, ern0, epc4, ejal, ern, ealu, esa ); // debug 
    
	pipeemreg em_reg ( ewreg, em2reg, ewmem, ealu, eb, ern, clock, resetn, mwreg,
		mm2reg, mwmem, malu, mb, mrn ); // EXE/MEM 
    
    pipemem mem_stage ( mwmem, malu, mb, clock, mem_clock, mmo, in_port0, in_port1, out_port0, out_port1, resetn);

    pipemwreg mw_reg ( mwreg, mm2reg, mmo, malu, mrn, clock, resetn,
        wwreg, wm2reg, wmo, walu, wrn); // MEM/WB 

    mux2x32 wb_stage ( walu, wmo, wm2reg, wdi ); // WB stage

endmodule
