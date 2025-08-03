module alu (
    input wire [31:0] input1,    // Operand 1 (rs1 or immediate)
    input wire [31:0] input2,    // Operand 2 (rs2 or immediate)
    input wire [4:0] alu_op,     // ALU operation type (5-bit wide)
    
    // Enable signals to match the decoder
    input wire add_en,
    input wire addi_en,
    input wire sub_en,
    input wire xor_en,
    input wire xori_en,
    input wire or_en,
    input wire ori_en,
    input wire and_en,
    input wire andi_en,
    input wire sll_en,
    input wire slli_en,
    input wire srl_en,
    input wire srli_en,
    input wire sra_en,
    input wire srai_en,
    input wire slt_en,
    input wire slti_en,
    input wire sltu_en,
    input wire sltiu_en,
    
    output reg [31:0] alu_result // Result of ALU operation
);

    // ALU results for each operation
    wire [31:0]  add_result, sub_result, xor_result, or_result, and_result;
    wire [31:0] sll_result, srl_result, sra_result, slt_result, sltu_result;

    // I-type specific operations 
    wire [31:0] addi_result, xori_result, ori_result, andi_result;
    wire [31:0] slli_result, srli_result, srai_result, slti_result, sltiu_result;

    // I-type ALU submodules
    alu_addi addi_op (
        .rs1(input1),
        .imm(input2),
        .addi_result(addi_result)
    );

    alu_xori xori_op (
        .rs1(input1),
        .imm(input2),
        .xori_result(xori_result)
    );

    alu_ori ori_op (
        .rs1(input1),
        .imm(input2),
        .ori_result(ori_result)
    );

    alu_andi andi_op (
        .rs1(input1),
        .imm(input2),
        .andi_result(andi_result)
    );

    alu_slli slli_op (
        .rs1(input1),
        .imm(input2),
        .slli_result(slli_result)
    );

    alu_srli srli_op (
        .rs1(input1),
        .imm(input2),
        .srli_result(srli_result)
    );

    alu_srai srai_op (
        .rs1(input1),
        .imm(input2),
        .srai_result(srai_result)
    );

    alu_slti slti_op (
        .rs1(input1),
        .imm(input2),
        .slti_result(slti_result)
    );

    alu_sltiu sltiu_op (
        .rs1(input1),
        .imm(input2),
        .sltiu_result(sltiu_result)
    );

    // R-type ALU submodules
    alu_add add_op (
        .op1(input1),
        .op2(input2),
        .add_result(add_result)
    );

    alu_sub sub_op (
        .op1(input1),
        .op2(input2),
        .sub_result(sub_result)
    );

    alu_xor xor_op (
        .op1(input1),
        .op2(input2),
        .xor_result(xor_result)
    );

    alu_or or_op (
        .op1(input1),
        .op2(input2),
        .or_result(or_result)
    );

    alu_and and_op (
        .op1(input1),
        .op2(input2),
        .and_result(and_result)
    );

    alu_sll sll_op (
        .op1(input1),
        .op2(input2),
        .sll_result(sll_result)
    );

    alu_srl srl_op (
        .op1(input1),
        .op2(input2),
        .srl_result(srl_result)
    );

    alu_sra sra_op (
        .op1(input1),
        .op2(input2),
        .sra_result(sra_result)
    );

    alu_slt slt_op (
        .op1(input1),
        .op2(input2),
        .slt_result(slt_result)
    );

    alu_sltu sltu_op (
        .op1(input1),
        .op2(input2),
        .sltu_result(sltu_result)
    );

    // Select ALU result based on alu_op and enable signals
    always @(*) begin
        alu_result = 32'b0;

        case(alu_op)
            5'b00000: if (add_en)   alu_result = add_result;   // ADD 
            5'b00001: if (addi_en)  alu_result = addi_result;  // ADDI 
            5'b00010: if (sub_en)   alu_result = sub_result;   // SUB   
            5'b00011: if (xor_en)   alu_result = xor_result;   // XOR 
            5'b00100: if (xori_en)  alu_result = xori_result;  // XORI 
            5'b00101: if (or_en)    alu_result = or_result;    // OR 
            5'b00110: if (ori_en)   alu_result = ori_result;   // ORI 
            5'b00111: if (and_en)   alu_result = and_result;   // AND 
            5'b01000: if (andi_en)  alu_result = andi_result;  // ANDI 
            5'b01001: if (sll_en)   alu_result = sll_result;   // SLL 
            5'b01010: if (slli_en)  alu_result = slli_result;  // SLLI 
            5'b01011: if (srl_en)   alu_result = srl_result;   // SRL 
            5'b01100: if (srli_en)  alu_result = srli_result;  // SRLI 
            5'b01101: if (sra_en)   alu_result = sra_result;   // SRA 
            5'b01110: if (srai_en)  alu_result = srai_result;  // SRAI 
            5'b01111: if (slt_en)   alu_result = slt_result;   // SLT 
            5'b10000: if (slti_en)  alu_result = slti_result;  // SLTI 
            5'b10001: if (sltu_en)  alu_result = sltu_result;  // SLTU 
            5'b10010: if (sltiu_en) alu_result = sltiu_result; // SLTIU 
            default: alu_result = 32'b0;  // no operation
        endcase
    end
endmodule

module alu_add #(parameter PRECISION = 32)
(
    input  wire [PRECISION-1:0] op1,
    input  wire [PRECISION-1:0] op2,
    output wire [PRECISION-1:0] add_result
);
    localparam num_steps = $clog2(PRECISION);
    wire [PRECISION-1:0] generates  [num_steps:0];
    wire [PRECISION-1:0] propagates [num_steps:0];
    
    genvar k, idx;
    generate
        // First step: Generate initial P and G values
        for (idx = 0; idx < PRECISION; idx = idx + 1) begin : init_step
            assign generates[0][idx]  = op1[idx] & op2[idx];
            assign propagates[0][idx] = op1[idx] ^ op2[idx];
        end
        
        // Intermediate steps: Compute group P and G
        for (k = 1; k <= num_steps; k = k + 1) begin : steps
            for (idx = 0; idx < PRECISION; idx = idx + 1) begin : stage
                if (idx < (1 << (k-1))) begin
                    assign generates[k][idx] = generates[k-1][idx];
                    assign propagates[k][idx] = propagates[k-1][idx];
                end else begin
                    assign generates[k][idx] = generates[k-1][idx] | 
                                             (propagates[k-1][idx] & generates[k-1][idx-(1<<(k-1))]);
                    assign propagates[k][idx] = propagates[k-1][idx] & 
                                              propagates[k-1][idx-(1<<(k-1))];
                end
            end
        end
        
        // Final sum computation
        assign add_result[0] = propagates[0][0];
        for (idx = 1; idx < PRECISION; idx = idx + 1) begin : sum
            assign add_result[idx] = propagates[0][idx] ^ generates[num_steps][idx-1];
        end
    endgenerate
endmodule

module alu_addi #(parameter PRECISION = 32)
(
    input  wire [PRECISION-1:0] rs1,
    input  wire [PRECISION-1:0] imm,
    output wire [PRECISION-1:0] addi_result
);
    localparam num_steps = $clog2(PRECISION);
    wire [PRECISION-1:0] generates  [num_steps:0];
    wire [PRECISION-1:0] propagates [num_steps:0];
    
    genvar k, idx;
    generate
        // First step: Generate initial P and G values
        for (idx = 0; idx < PRECISION; idx = idx + 1) begin : init_step
            assign generates[0][idx]  = rs1[idx] & imm[idx];
            assign propagates[0][idx] = rs1[idx] ^ imm[idx];
        end
        
        // Intermediate steps: Compute group P and G
        for (k = 1; k <= num_steps; k = k + 1) begin : steps
            for (idx = 0; idx < PRECISION; idx = idx + 1) begin : stage
                if (idx < (1 << (k-1))) begin
                    assign generates[k][idx] = generates[k-1][idx];
                    assign propagates[k][idx] = propagates[k-1][idx];
                end else begin
                    assign generates[k][idx] = generates[k-1][idx] | 
                                             (propagates[k-1][idx] & generates[k-1][idx-(1<<(k-1))]);
                    assign propagates[k][idx] = propagates[k-1][idx] & 
                                              propagates[k-1][idx-(1<<(k-1))];
                end
            end
        end
        
        // Final sum computation
        assign addi_result[0] = propagates[0][0];
        for (idx = 1; idx < PRECISION; idx = idx + 1) begin : sum
            assign addi_result[idx] = propagates[0][idx] ^ generates[num_steps][idx-1];
        end
    endgenerate
endmodule

module alu_and (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire [31:0] and_result
);
    assign and_result = op1 & op2;  // AND operation between op1 and op2
endmodule

module alu_andi (
    input wire [31:0] rs1,
    input wire [31:0] imm,
    output wire [31:0] andi_result
);
    assign andi_result = rs1 & imm;  // AND with immediate
endmodule

module alu_or (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire [31:0] or_result
);
    assign or_result = op1 | op2;  // OR operation between op1 and op2
endmodule

module alu_ori (
    input wire [31:0] rs1,
    input wire [31:0] imm,
    output wire [31:0] ori_result
);
    assign ori_result = rs1 | imm;  // OR with immediate
endmodule

module alu_sll (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire [31:0] sll_result
);
    assign sll_result = op1 << op2[4:0];  // Logical left shift by lower 5 bits of op2
endmodule

module alu_slli (
    input wire [31:0] rs1,
    input wire [31:0] imm,
    output wire [31:0] slli_result
);
    assign slli_result = rs1 << imm[4:0];  // Logical left shift with immediate
endmodule

module alu_slt (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire [31:0] slt_result
);
    // Use $signed for signed comparison
    assign slt_result = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;  // Set Less Than (signed)
endmodule

module alu_slti (
    input wire [31:0] rs1,
    input wire [31:0] imm,
    output wire [31:0] slti_result
);
    // Use $signed for signed comparison
    assign slti_result = ($signed(rs1) < $signed(imm)) ? 32'b1 : 32'b0;  // Set Less Than Immediate (signed)
endmodule

module alu_sltiu (
    input wire [31:0] rs1,
    input wire [31:0] imm,
    output wire [31:0] sltiu_result
);
    assign sltiu_result = (rs1 < imm) ? 32'b1 : 32'b0;  // Set Less Than Unsigned Immediate
endmodule

module alu_sltu (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire [31:0] sltu_result
);
    assign sltu_result = (op1 < op2) ? 32'b1 : 32'b0;  // Set Less Than Unsigned
endmodule

// ALU Shift Right Arithmetic Operation (R-type)
module alu_sra (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire [31:0] sra_result
);
    assign sra_result = $signed(op1) >>> op2[4:0];  // Arithmetic right shift
endmodule

module alu_srai (
    input wire [31:0] rs1,
    input wire [31:0] imm,
    output wire [31:0] srai_result
);
    assign srai_result = $signed(rs1) >>> imm[4:0];  // Arithmetic right shift with immediate
endmodule

// ALU Shift Right Logical Operation (R-type)
module alu_srl (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire [31:0] srl_result
);
    assign srl_result = op1 >> op2[4:0];  // Logical right shift by lower 5 bits of op2
endmodule

module alu_srli (
    input wire [31:0] rs1,
    input wire [31:0] imm,
    output wire [31:0] srli_result
);
    assign srli_result = rs1 >> imm[4:0];  // Logical right shift with immediate
endmodule

module alu_sub #(parameter PRECISION = 32)
(
    input  wire [PRECISION-1:0] op1,
    input  wire [PRECISION-1:0] op2,
    output wire [PRECISION-1:0] sub_result
);
    localparam num_steps = $clog2(PRECISION);
    wire [PRECISION-1:0] generates  [num_steps:0];
    wire [PRECISION-1:0] propagates [num_steps:0];
    
    // Invert op2 and add 1 for two's complement subtraction
    wire [PRECISION-1:0] op2_complement = ~op2 + 1;

    genvar k, idx;
    generate
        // First step: Generate initial P and G values
        for (idx = 0; idx < PRECISION; idx = idx + 1) begin : init_step
            assign generates[0][idx]  = op1[idx] & op2_complement[idx];
            assign propagates[0][idx] = op1[idx] ^ op2_complement[idx];
        end
        
        // Intermediate steps: Compute group P and G
        for (k = 1; k <= num_steps; k = k + 1) begin : steps
            for (idx = 0; idx < PRECISION; idx = idx + 1) begin : stage
                if (idx < (1 << (k-1))) begin
                    assign generates[k][idx] = generates[k-1][idx];
                    assign propagates[k][idx] = propagates[k-1][idx];
                end else begin
                    assign generates[k][idx] = generates[k-1][idx] | 
                                             (propagates[k-1][idx] & generates[k-1][idx-(1<<(k-1))]);
                    assign propagates[k][idx] = propagates[k-1][idx] & 
                                              propagates[k-1][idx-(1<<(k-1))];
                end
            end
        end
        
        // Final subtraction computation
        assign sub_result[0] = propagates[0][0];
        for (idx = 1; idx < PRECISION; idx = idx + 1) begin : subtract
            assign sub_result[idx] = propagates[0][idx] ^ generates[num_steps][idx-1];
        end
    endgenerate
endmodule

module alu_xor (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire [31:0] xor_result
);
    assign xor_result = op1 ^ op2;  // XOR operation between op1 and op2
endmodule

module alu_xori (
    input wire [31:0] rs1,
    input wire [31:0] imm,
    output wire [31:0] xori_result
);
    assign xori_result = rs1 ^ imm;  // XOR with immediate
endmodule
