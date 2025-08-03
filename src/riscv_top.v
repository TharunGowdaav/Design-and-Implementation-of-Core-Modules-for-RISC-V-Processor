module riscv_top (
    input wire clk,
    input wire reset,
    input wire [31:0] instruction,
    output wire [31:0] alu_result,
    // Additional outputs for testbench verification
    output wire reg_write,
    output wire reg_read
);

    // Internal wires for connecting modules
    wire [4:0] alu_op;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [31:0] imm;
    wire alu_src;
    
    // Enable signals for operations
    wire add_en, addi_en, sub_en, xor_en, xori_en;
    wire or_en, ori_en, and_en, andi_en;
    wire sll_en, slli_en, srl_en, srli_en;
    wire sra_en, srai_en, sltu_en;
    wire slt_en, slti_en, sltiu_en;
    
    // Wires for register file data
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] alu_input2;

    // Instantiate Decoder
    Decoder decoder (
        .instruction(instruction),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .reg_read(reg_read),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm),
        .alu_src(alu_src),
        .add_en(add_en),
        .addi_en(addi_en),
        .sub_en(sub_en),
        .xor_en(xor_en),
        .xori_en(xori_en),
        .or_en(or_en),
        .ori_en(ori_en),
        .and_en(and_en),
        .andi_en(andi_en),
        .sll_en(sll_en),
        .slli_en(slli_en),
        .srl_en(srl_en),
        .srli_en(srli_en),
        .sra_en(sra_en),
        .srai_en(srai_en),
        .sltu_en(sltu_en),
        .slt_en(slt_en),
        .slti_en(slti_en),
        .sltiu_en(sltiu_en)
    );

    // Instantiate GPR
    GPR gpr (
        .clock(clk),
        .reset(reset),
        .reg_write(reg_write),
        .reg_read(reg_read),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(alu_result),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // MUX for ALU input2 selection
    assign alu_input2 = alu_src ? imm : read_data2;

    // Instantiate ALU
    ALU alu (
        .input1(read_data1),
        .input2(alu_input2),
        .alu_op(alu_op),
        .add_en(add_en),
        .addi_en(addi_en),
        .sub_en(sub_en),
        .xor_en(xor_en),
        .xori_en(xori_en),
        .or_en(or_en),
        .ori_en(ori_en),
        .and_en(and_en),
        .andi_en(andi_en),
        .sll_en(sll_en),
        .slli_en(slli_en),
        .srl_en(srl_en),
        .srli_en(srli_en),
        .sra_en(sra_en),
        .srai_en(srai_en),
        .slt_en(slt_en),
        .slti_en(slti_en),
        .sltu_en(sltu_en),
        .sltiu_en(sltiu_en),
        .alu_result(alu_result)
    );

endmodule
