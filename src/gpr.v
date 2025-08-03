module gpr(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    output reg [31:0] read_data1,
    output reg [31:0] read_data2,
    input reg_write,
    input reg_read,
    input clock,
    input reset
);
    reg [31:0] reg_memory [31:0];
    integer i;

    // Reset and Write Logic
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_memory[i] <= i; // Initialise with index value
            end
        end
        else if (reg_write && rd != 5'b0) begin
            reg_memory[rd] <= write_data;
        end
    end

    // Read Logic
    always @(*) begin
        if (reg_read) begin
            read_data1 = reg_memory[rs1];
            read_data2 = reg_memory[rs2];
        end else begin
            read_data1 = 32'h0;
            read_data2 = 32'h0;
        end
    end
endmodule

