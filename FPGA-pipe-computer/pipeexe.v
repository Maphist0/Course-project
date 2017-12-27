module pipeexe (
    ealuc, ealuimm, ea, eb, eimm, eshift, ern0, epc4, ejal,
    ern, ealu, esa
);
    input           ealuimm, eshift, ejal;
    input   [ 3:0]  ealuc;
    input   [ 4:0]  ern0;
    input   [31:0]  ea, eb, eimm, epc4, esa;

    output  [ 4:0]  ern;
    output  [31:0]  ealu;

    wire    [31:0]  a, b, s;
    //wire	[31:0]	epc4_plus_4;

    //assign  epc4_plus_4 = epc4 + 4;
    assign  ern = ern0 | {5{ejal}};

    mux2x32 a_source (ea, esa, eshift, a);
    mux2x32 b_source (eb, eimm, ealuimm, b);
    mux2x32 ealu_source (s, epc4, ejal, ealu);
    alu     ALU (a, b, ealuc, s);
    
endmodule
