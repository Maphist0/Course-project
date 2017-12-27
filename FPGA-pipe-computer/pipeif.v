module pipeif (pcsource, pc, bpc, da, jpc, npc, pc4, ins, mem_clock);
    input   [ 1:0]  pcsource;
    input   [31:0]  pc, bpc, da, jpc;
    input           mem_clock;

    output  [31:0]  npc, pc4, ins;

    // <pcsource> controls the mux:
    // 00 ---> pc4
    // 01 ---> dpc
    // 10 ---> da
    // 11 ---> jpc
    mux4x32 mux_pc (pc4, bpc, da, jpc, pcsource, npc);

    assign pc4 = pc + 4;

    // Instruction memory.
    lpm_rom_irom irom (pc[7:2], mem_clock, ins);

endmodule
