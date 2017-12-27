// Program counter.
// Use <PCWrite> to control whether <pc> is the same as <nextpc>.

module pc (clock, nextpc, PCWrite, pc);
    input clock, PCWrite;
    input [31:0] nextpc;
    output reg [31:0] pc;

    always @ (posedge clock) begin
        if (PCWrite) begin
            pc <= nextpc;
            $display ("PC: %d", pc);
        end else begin
            $display ("Skipped writting to PC - nop");
        end
    end

endmodule
