//adder
module adder (a,adder_out);
    input wire [31:0] a;
    output reg [31:0] adder_out;

    always @ (*) begin
        adder_out = a + 32'd4;
    end
endmodule

//alu
module alu (a_i,b_i,op_i,res_o);
    input wire [31:0]a_i;
    input wire [31:0]b_i;
    input wire [3:0]op_i;

    output reg [31:0]res_o;

    always @(*) begin

        if (op_i==4'b0000) begin
            res_o = a_i + b_i; //add
        end
        else if (op_i==4'b0001) begin
            res_o = a_i - b_i; //sub
        end
        else if (op_i==4'b0010) begin
            res_o = a_i << b_i; //shift left logical
        end
        else if (op_i==4'b0011) begin
            res_o = $signed (a_i) < $signed (b_i); //shift less then
        end 
        else if (op_i==4'b0100) begin
            res_o = a_i < b_i; //shift less then unsigned
        end          
        else if (op_i==4'b0101) begin
            res_o = a_i ^ b_i; //xor
        end
        else if (op_i==4'b0110) begin
            res_o = a_i >> b_i; //shift right logical
        end
        else if (op_i==4'b0111) begin
            res_o = a_i >>> b_i; //shift right arithematic
        end
        else if (op_i==4'b1000) begin
            res_o = a_i | b_i; //or
        end
        else if (op_i==4'b1001) begin
            res_o = a_i & b_i; //and
        end
        else if (op_i==4'b1111) begin
            res_o = b_i; //for lui 
        end
        else begin
            res_o = 0;
        end
    end
endmodule

//PC
module pc (
    input wire clk,
    input wire rst,
    input wire load,
    input wire jalr,
    input wire next_sel,
    input wire dmem_valid,
    input wire branch_reselt,
    input wire [31:0]next_address,
    input wire [31:0]address_in,

    output reg [31:0]address_out,
    output wire [31:0] pre_address_pc
);

    reg [31:0] pre_address;
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            address_out <= 0;
            pre_address  <= address_out;
        end

        else begin
            pre_address  <= address_out;
            if (next_sel | branch_reselt)begin
                address_out <= next_address;
            end
            else if (jalr)begin
                address_out <= next_address;
            end
            else if ((load && !dmem_valid))begin
                address_out <= address_out;
                pre_address <= pre_address_pc;
            end
            else begin
                address_out <= address_out + 32'd4;
            end
        end
        
    end

    assign pre_address_pc = pre_address;
endmodule

// registerfile
module registerfile (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [4:0]rs1,
    input wire [4:0]rs2,
    input wire [4:0]rd,
    input wire [31:0]data,

    output wire [31:0]op_a,
    output wire [31:0]op_b
);

    reg [31:0] register[31:1];
    integer i;

    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            for (i=0; i<32; i=i+1) begin
                register[i] <= 32'b0;
            end
        end
        else begin
            if (en) begin
                register[rd] <= data;
            end
        end
    end

    assign op_a = (rs1 != 0)? register[rs1] : 0;
    assign op_b = (rs2 != 0)? register[rs2] : 0;
endmodule

//mux

module mux (a,b,sel,out);
    input wire [31:0] a,b;
    input wire sel;

    output wire [31:0] out;

    assign out = (sel)?  b:a;
endmodule

module mux2_4 (a,b,c,d,sel,out);
    input wire [31:0] a,b,c,d;
    input wire [1:0] sel;

    output reg [31:0] out;

    always @ (*) begin
        case (sel)
            2'b00 : out = a;
            2'b01 : out = b;
            2'b10 : out = c;
            2'b11 : out = d;
        endcase
    end
endmodule

module mux3_8 (a,b,c,d,e,f,g,h,sel,out);
    input wire [31:0] a,b,c,d,e,f,g,h;
    input wire [2:0] sel;

    output reg [31:0] out;

    always @ (*) begin
        case (sel)
            3'b000 : out = a;
            3'b001 : out = b;
            3'b010 : out = c;
            3'b011 : out = d;
            3'b100 : out = e;
            3'b101 : out = f;
            3'b110 : out = g;
            3'b111 : out = h;
        endcase
    end
endmodule

// immediategen
module immediategen (
    input wire [31:0]instr,
    output reg [31:0] i_imme,
    output reg [31:0] s_imme,
    output reg [31:0] sb_imme,
    output reg [31:0] uj_imme,
    output reg [31:0] u_imme
);

    always @(*) begin
        i_imme  = {{20{instr[31]}}, instr[31:20]};
        s_imme  = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        sb_imme = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
        uj_imme = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
        u_imme  = {{instr[31:12]},12'b0};
    end
endmodule

