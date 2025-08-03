module decoder(
    input wire [31:0] instruction,  // 32-bit instruction
    output reg [4:0] alu_op,        // ALU operation control signal
    output reg reg_write,           // Write control signal
    output reg reg_read,            // Read enable signal
    output reg [4:0] rs1,           // rs1 register address
    output reg [4:0] rs2,           // rs2 register address
    output reg [4:0] rd,            // rd register address
    output reg [31:0] imm,          // Immediate value
    output reg alu_src,             // ALU source selection (1 for immediate, 0 for rs2)
    
    // Enable signals for each operation
    output reg add_en,
    output reg addi_en,
    output reg sub_en,
    output reg xor_en,
    output reg xori_en,
    output reg or_en,
    output reg ori_en,
    output reg and_en,
    output reg andi_en,
    output reg sll_en,
    output reg slli_en,
    output reg srl_en,
    output reg srli_en,
    output reg sra_en,
    output reg srai_en,
    output reg sltu_en,
    output reg slt_en,
    output reg slti_en,
    output reg sltiu_en
);
    // Instruction fields
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    
    // Instruction type
    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011;

    always @(*) begin
        // Default assignments
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        rd = instruction[11:7];
        imm = 32'b0;
        reg_write = 1'b0;
        reg_read = 1'b0;  // Default to no read
        alu_src = 1'b0;
        alu_op = 5'b00000;

        // Reset all enable signals
        add_en = 1'b0;
        addi_en = 1'b0;
        sub_en = 1'b0;
        xor_en = 1'b0;
        xori_en = 1'b0;
        or_en = 1'b0;
        ori_en = 1'b0;
        and_en = 1'b0;
        andi_en = 1'b0;
        sll_en = 1'b0;
        slli_en = 1'b0;
        srl_en = 1'b0;
        srli_en = 1'b0;
        sra_en = 1'b0;
        srai_en = 1'b0;
        slt_en = 1'b0;
        slti_en = 1'b0;
        sltu_en = 1'b0;
        sltiu_en = 1'b0;

        case (opcode)
            R_TYPE: begin
                reg_write = 1'b1;
                reg_read = 1'b1;  // Enable read for R-type instruction
                alu_src = 1'b0;

                // R-type instruction decoding 
                if (funct7 == 7'b0000000 && funct3 == 3'b000) begin
                    add_en = 1'b1;
                    alu_op = 5'b00000;  // ADD
                end
                else if (funct7 == 7'b0100000 && funct3 == 3'b000) begin
                    sub_en = 1'b1;
                    alu_op = 5'b00010;  // SUB
                end
                else if (funct7 == 7'b0000000 && funct3 == 3'b100) begin
                    xor_en = 1'b1;
                    alu_op = 5'b00011;  // XOR
                end
                else if (funct7 == 7'b0000000 && funct3 == 3'b110) begin
                    or_en = 1'b1;
                    alu_op = 5'b00101;  // OR
                end
                else if (funct7 == 7'b0000000 && funct3 == 3'b111) begin
                    and_en = 1'b1;
                    alu_op = 5'b00111;  // AND
                end
                else if (funct7 == 7'b0000000 && funct3 == 3'b001) begin
                    sll_en = 1'b1;
                    alu_op = 5'b01001;  // SLL
                end
                else if (funct7 == 7'b0000000 && funct3 == 3'b101) begin
                    srl_en = 1'b1;
                    alu_op = 5'b01011;  // SRL
                end
                else if (funct7 == 7'b0100000 && funct3 == 3'b101) begin
                    sra_en = 1'b1;
                    alu_op = 5'b01101;  // SRA
                end
                else if (funct7 == 7'b0000000 && funct3 == 3'b011) begin
                    sltu_en = 1'b1;
                    alu_op = 5'b10001;  // SLTU
                end
                else if (funct7 == 7'b0000000 && funct3 == 3'b010) begin
                    slt_en = 1'b1;
                    alu_op = 5'b01111;  // SLT
                end
                else begin
                    reg_write = 1'b0;
                    alu_op = 5'b00000;
                end
            end
            
            I_TYPE: begin
                reg_write = 1'b1;
                reg_read = 1'b1;  // Enable read for I-type instruction
                alu_src = 1'b1;
                rs2 = 5'b0;  // I-type doesn't need rs2

                case (funct3)
                    3'b000: begin  // ADDI
                        addi_en = 1'b1;
                        alu_op = 5'b00001;  // ADDI
                        imm = {{20{instruction[31]}}, instruction[31:20]};
                    end
                    3'b010: begin  // SLTI
                        slti_en = 1'b1;
                        alu_op = 5'b10000;  // SLTI
                        imm = {{20{instruction[31]}}, instruction[31:20]};
                    end
                    3'b011: begin  // SLTIU
                        sltiu_en = 1'b1;
                        alu_op = 5'b10010;  // SLTIU
                        imm = {{20{instruction[31]}}, instruction[31:20]};
                    end
                    3'b100: begin  // XORI
                        xori_en = 1'b1;
                        alu_op = 5'b00100;  // XORI
                        imm = {{20{instruction[31]}}, instruction[31:20]};
                    end
                    3'b110: begin  // ORI
                        ori_en = 1'b1;
                        alu_op = 5'b00110;  // ORI
                        imm = {{20{instruction[31]}}, instruction[31:20]};
                    end
                    3'b111: begin  // ANDI
                        andi_en = 1'b1;
                        alu_op = 5'b01000;  // ANDI
                        imm = {{20{instruction[31]}}, instruction[31:20]};
                    end
                    3'b001: begin  // SLLI
                        slli_en = 1'b1;
                        alu_op = 5'b01010;  // SLLI
                        imm = {27'b0, instruction[24:20]};  // Shift amount
                    end
                    3'b101: begin  // SRLI/SRAI
                        imm = {27'b0, instruction[24:20]};  // Shift amount
                        if (funct7[5]) begin
                            srai_en = 1'b1;
                            alu_op = 5'b01110;  // SRAI
                        end else begin
                            srli_en = 1'b1;
                            alu_op = 5'b01100;  // SRLI
                        end
                    end
                    default: begin
                        alu_op = 5'b00000;
                        reg_write = 1'b0;
                        reg_read = 1'b0;  // No read for unknown instructions
                    end
                endcase
            end
            
            default: begin
                alu_op = 5'b00000;
                reg_write = 1'b0;
                reg_read = 1'b0;
                alu_src = 1'b0;
                rs1 = 5'b0;
                rs2 = 5'b0;
                rd = 5'b0;
                imm = 32'b0;
            end
        endcase
    end
endmodule
