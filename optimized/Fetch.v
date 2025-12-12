module fetch (
    input wire clk, input wire rst, input wire load, input wire valid,
    input wire predict_taken_in, input wire [31:0] predict_target_in,
    input wire mispredict_in, input wire [31:0] correct_pc_in,
    input wire [31:0] instruction_fetch,
    output reg we_re, output reg request, output reg [3:0] mask,
    output wire [31:0] address_out, output reg [31:0] instruction, output wire [31:0] pre_address_pc 
);
    pc u_pc0 (
        .clk(clk), .rst(rst), .load(load),
        .predict_taken(predict_taken_in), .predict_target(predict_target_in),
        .mispredict(mispredict_in), .correct_pc(correct_pc_in),
        .address_out(address_out), .pre_address_pc(pre_address_pc)
    );
    always @ (*) begin
        if (load && !valid) begin mask = 4'b1111; we_re = 1'b0; request = 1'b0; end
        else begin mask = 4'b1111; we_re = 1'b0; request = 1'b1; end
    end
    always @ (*) instruction = instruction_fetch;
endmodule