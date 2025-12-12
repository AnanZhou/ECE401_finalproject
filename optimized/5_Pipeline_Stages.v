module fetch_pipe(
  input wire clk, input wire rst, input wire [31:0] pre_address_pc, input wire [31:0] instruction_fetch,
  input wire flush_in, input wire load, input wire pred_taken_in, output wire pred_taken_out,
  output wire [31:0] pre_address_out, output wire [31:0] instruction
);
  reg [31:0] pre_address, instruc; reg pred_taken;
  always @ (posedge clk or negedge rst) begin
    if (!rst) begin pre_address <= 0; instruc <= 0; pred_taken <= 0; end
    else begin
      if (flush_in) begin pre_address <= 0; instruc <= 32'h00000013; pred_taken <= 0; end 
      else if (load) begin pre_address <= pre_address; instruc <= instruc; pred_taken <= pred_taken; end
      else begin pre_address <= pre_address_pc; instruc <= instruction_fetch; pred_taken <= pred_taken_in; end
    end
  end
  assign pre_address_out = pre_address; assign instruction = instruc; assign pred_taken_out = pred_taken;
endmodule

module decode_pipe(
  input wire clk, input wire rst, input wire load_in, input wire store_in, input wire jalr_in, input wire next_sel_in,
  input wire branch_result_in, input wire branch_en_in, input wire reg_write_in, input wire [4:0] rs1_in, rs2_in, 
  input wire [3:0] alu_control_in, input wire [1:0] mem_to_reg_in, input wire [31:0] opa_mux_in, opb_mux_in, opb_data_in,
  input wire [31:0] pre_address_in, instruction_in, input wire flush_in, input wire pred_taken_in, output wire pred_taken_out,
  output wire load, store, jalr_out, next_sel, branch_result, branch_en_out, reg_write_out,
  output wire [4:0] rs1_out, rs2_out, output wire [3:0] alu_control, output wire [1:0] mem_to_reg,
  output wire [31:0] opa_mux_out, opb_mux_out, opb_data_out, pre_address_out, instruction_out
 );
  reg l,s,nextsel,branch_res,jalr, branch_en, reg_write, pred_taken; reg [1:0] mem_reg; reg [3:0] alu_con;
  reg [4:0] rs1, rs2; reg [31:0] opa_mux,opb_mux,opb_data,pre_address,instruction;
  always @ (posedge clk or negedge rst) begin
    if (!rst) begin l<=0; s<=0; jalr<=0; nextsel<=0; branch_res<=0; branch_en<=0; mem_reg<=0; alu_con<=0; opa_mux<=0; opb_mux<=0; opb_data<=0; pre_address<=0; instruction<=0; reg_write<=0; rs1<=0; rs2<=0; pred_taken<=0; end
    else begin
      if (flush_in) begin l<=0; s<=0; jalr<=0; nextsel<=0; branch_res<=0; branch_en<=0; reg_write<=0; instruction<=32'h00000013; pred_taken<=0; end
      else begin l<=load_in; s<=store_in; jalr<=jalr_in; nextsel<=next_sel_in; branch_res<=branch_result_in; branch_en<=branch_en_in; mem_reg<=mem_to_reg_in; alu_con<=alu_control_in; opa_mux<=opa_mux_in; opb_mux<=opb_mux_in; opb_data<=opb_data_in; pre_address<=pre_address_in; instruction<=instruction_in; reg_write<=reg_write_in; rs1<=rs1_in; rs2<=rs2_in; pred_taken<=pred_taken_in; end
    end
  end
  assign load=l; assign store=s; assign rs1_out=rs1; assign rs2_out=rs2; assign jalr_out=jalr; assign next_sel=nextsel; assign reg_write_out=reg_write; assign branch_result=branch_res; assign branch_en_out=branch_en; assign mem_to_reg=mem_reg; assign alu_control=alu_con; assign opa_mux_out=opa_mux; assign opb_mux_out=opb_mux; assign opb_data_out=opb_data; assign instruction_out=instruction; assign pre_address_out=pre_address; assign pred_taken_out=pred_taken;
endmodule

module execute_pipe(input wire clk, input wire rst, input wire load_in, input wire store_in, input wire reg_write_in, input wire [31:0] opb_datain, input wire [31:0] alu_res, input wire [1:0] mem_reg_in, input wire [31:0] next_sel_addr, input wire [31:0] pre_address_in, input wire [31:0] instruction_in, output wire reg_write_out, output wire load_out, output wire store_out, output wire [31:0] opb_dataout, output wire [31:0] alu_res_out, output wire [1:0] mem_reg_out, output wire [31:0] next_sel_address, output wire [31:0] pre_address_out, output wire [31:0] instruction_out);
  reg load , store , reg_write; reg [1:0] mem_reg; reg [31:0] alu_result , nextsel_addr; reg [31:0] pre_address , instruction , opb_data;
  always @ (posedge clk or negedge rst) begin
    if (!rst) begin load<=0; store<=0; mem_reg<=0; opb_data<=0; pre_address<=0; instruction<=0; alu_result<=0; nextsel_addr<=0; reg_write<=0; end
    else begin load<=load_in; store<=store_in; mem_reg<=mem_reg_in; opb_data<=opb_datain; pre_address<=pre_address_in; instruction<=instruction_in; alu_result<=alu_res; nextsel_addr<=next_sel_addr; reg_write<=reg_write_in; end
  end
  assign reg_write_out=reg_write; assign load_out=load; assign store_out=store; assign mem_reg_out=mem_reg; assign opb_dataout=opb_data; assign alu_res_out=alu_result; assign pre_address_out=pre_address; assign instruction_out=instruction; assign next_sel_address=nextsel_addr;
endmodule

module memory_pipe(input wire clk, input wire rst, input wire reg_write_in, input wire [1:0] mem_reg_in, input wire [31:0] wrap_load_in, input wire [31:0] alu_res, input wire [31:0] next_sel_addr, input wire [31:0] instruction_in, input wire [31:0] pre_address_in, output wire reg_write_out, output wire [31:0] alu_res_out, output wire [1:0] mem_reg_out, output wire [31:0] next_sel_address, output wire [31:0] wrap_load_out, output wire [31:0] instruction_out, output wire [31:0] pre_address_out);
  reg reg_write; reg [1:0] mem_reg; reg [31:0] pre_address_pc; reg [31:0] alu_result , nextsel_addr , wrap_load , instruction;
  always @ (posedge clk) begin
    if (!rst) begin mem_reg<=0; alu_result<=0; nextsel_addr<=0; wrap_load<=0; instruction<=0; reg_write<=0; pre_address_pc<=0; end
    else begin mem_reg<=mem_reg_in; alu_result<=alu_res; nextsel_addr<=next_sel_addr; wrap_load<=wrap_load_in; instruction<=instruction_in; reg_write<=reg_write_in; pre_address_pc<=pre_address_in; end
  end
  assign reg_write_out=reg_write; assign mem_reg_out=mem_reg; assign alu_res_out=alu_result; assign next_sel_address=nextsel_addr; assign wrap_load_out=wrap_load; assign instruction_out=instruction; assign pre_address_out=pre_address_pc;
endmodule

module memory_stage(input wire rst, input wire load, input wire store, input wire [31:0] op_b, input wire [31:0] instruction, input wire [31:0] alu_out_address, input wire [31:0] wrap_load_in, output reg [3:0] mask, input wire data_valid, input wire valid, output wire we_re, output wire request, output wire [31:0] store_data_out, output wire [31:0] wrap_load_out);
    always @(*) mask = 4'b1111; assign we_re = store; assign request = load | store; assign store_data_out = op_b; assign wrap_load_out = wrap_load_in;
endmodule

module write_back(input wire [1:0] mem_to_reg, input wire [31:0] alu_out, input wire [31:0] data_mem_out, input wire [31:0] next_sel_address, output wire [31:0] rd_sel_mux_out);
    mux2_4 u_mux2 (.a(alu_out), .b(data_mem_out), .c(next_sel_address), .sel(mem_to_reg), .out(rd_sel_mux_out));
endmodule