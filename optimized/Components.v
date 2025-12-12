//adder
module adder (a,adder_out);
    input wire [31:0] a;
    output reg [31:0] adder_out;
    always @ (*) adder_out = a + 32'd4;
endmodule

//alu
module alu (a_i,b_i,op_i,res_o);
    input wire [31:0]a_i; input wire [31:0]b_i; input wire [3:0]op_i; output reg [31:0]res_o;
    always @(*) begin
        case(op_i)
            4'b0000: res_o = a_i + b_i;
            4'b0001: res_o = a_i - b_i;
            4'b0010: res_o = a_i << b_i;
            4'b0011: res_o = $signed (a_i) < $signed (b_i);
            4'b0100: res_o = a_i < b_i;
            4'b0101: res_o = a_i ^ b_i;
            4'b0110: res_o = a_i >> b_i;
            4'b0111: res_o = a_i >>> b_i;
            4'b1000: res_o = a_i | b_i;
            4'b1001: res_o = a_i & b_i;
            4'b1111: res_o = b_i;
            default: res_o = 0;
        endcase
    end
endmodule

// === PC Module (Fixed Latency) ===
module pc (
    input wire clk, input wire rst, input wire load,
    input wire predict_taken, input wire [31:0] predict_target,
    input wire mispredict, input wire [31:0] correct_pc,
    output reg [31:0] address_out, output wire [31:0] pre_address_pc
);
    always @(posedge clk or negedge rst) begin
        if(!rst) address_out <= 0;
        else begin
            if (mispredict) address_out <= correct_pc;
            else if (load) address_out <= address_out; 
            else if (predict_taken) address_out <= predict_target;
            else address_out <= address_out + 32'd4;
        end
    end
    assign pre_address_pc = address_out; // Direct assignment
endmodule

// === Register File (Internal Forwarding) ===
module registerfile (
    input wire clk, input wire rst, input wire en, input wire [4:0]rs1, input wire [4:0]rs2, input wire [4:0]rd, input wire [31:0]data,
    output wire [31:0]op_a, output wire [31:0]op_b
);
    reg [31:0] register[31:1]; integer i;
    always @(posedge clk or negedge rst) begin
        if(!rst) for (i=1; i<32; i=i+1) register[i] <= 32'b0;
        else if (en && rd != 0) register[rd] <= data;
    end
    assign op_a = (rs1 == 0) ? 32'b0 : (en && (rs1 == rd)) ? data : register[rs1];
    assign op_b = (rs2 == 0) ? 32'b0 : (en && (rs2 == rd)) ? data : register[rs2];
endmodule

//mux
module mux (a,b,sel,out);
    input wire [31:0] a,b; input wire sel; output wire [31:0] out;
    assign out = (sel)? b:a;
endmodule

module mux2_4 (a,b,c,d,sel,out);
    input wire [31:0] a,b,c,d; input wire [1:0] sel; output reg [31:0] out;
    always @ (*) case (sel) 2'b00:out=a; 2'b01:out=b; 2'b10:out=c; 2'b11:out=d; endcase
endmodule

module mux3_8 (a,b,c,d,e,f,g,h,sel,out);
    input wire [31:0] a,b,c,d,e,f,g,h; input wire [2:0] sel; output reg [31:0] out;
    always @ (*) case (sel) 3'b000:out=a; 3'b001:out=b; 3'b010:out=c; 3'b011:out=d; 3'b100:out=e; 3'b101:out=f; 3'b110:out=g; 3'b111:out=h; endcase
endmodule

// immediategen
module immediategen (
    input wire [31:0]instr, output reg [31:0] i_imme, output reg [31:0] s_imme, output reg [31:0] sb_imme, output reg [31:0] uj_imme, output reg [31:0] u_imme
);
    always @(*) begin
        i_imme  = {{20{instr[31]}}, instr[31:20]};
        s_imme  = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        sb_imme = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
        uj_imme = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
        u_imme  = {{instr[31:12]},12'b0};
    end
endmodule