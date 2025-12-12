//Memory
module memory#(
    parameter INIT_MEM = 0
)(
    input wire clk,
    input wire we_re,
    input wire request,
    input wire [7:0]address,
    input wire [31:0]data_in,
    input wire [3:0]mask,

    output reg [31:0]data_out
);
    reg [31:0] mem [0:255];

    initial begin
        if (INIT_MEM) $readmemh("instr.mem",mem);
        else begin
            integer i;
            for(i=0; i<256; i=i+1) mem[i] = 32'b0;
        end
    end

    // === Asynchronous Read ===
    always @(*) begin
        if (request && !we_re) begin
            data_out = mem[address];
        end else begin
            data_out = 32'b0;
        end
    end

    // Synchronous Write
    always @(posedge clk) begin
        if (request && we_re) begin
            if(mask[0]) mem[address][7:0]   <= data_in[7:0];
            if(mask[1]) mem[address][15:8]  <= data_in[15:8];
            if(mask[2]) mem[address][23:16] <= data_in[23:16];
            if(mask[3]) mem[address][31:24] <= data_in[31:24];
        end
    end
endmodule

// data_mem_top
module data_mem_top #(parameter INIT_MEM = 0)(
    input wire clk, input wire rst, input wire we_re, input wire request, input wire load, input wire [3:0] mask, input wire [7:0] address, input wire [31:0] data_in,
    output reg valid, output wire [31:0] data_out
    );
    always @(posedge clk or negedge rst ) begin
        if(!rst) valid <= 0;
        else valid <= load;
    end
    memory #(.INIT_MEM(INIT_MEM)) u_memory (.clk(clk), .we_re(we_re), .request(request), .mask(mask), .address(address), .data_in(data_in), .data_out(data_out));
endmodule

// instruc_mem_top
module instruc_mem_top #(parameter INIT_MEM = 0)(
    input wire clk, input wire rst, input wire we_re, input wire request, input wire [3:0] mask, input wire [7:0] address, input wire [31:0] data_in,
    output reg valid, output wire [31:0] data_out
    );
    always @(posedge clk or negedge rst ) begin
        if(!rst) valid <= 0;
        else valid <= request;
    end
    memory #(.INIT_MEM(INIT_MEM)) u_memory (.clk(clk), .we_re(we_re), .request(request), .mask(mask), .address(address), .data_in(data_in), .data_out(data_out));
endmodule

// wrappermem 
module wrappermem (
    input wire [31:0] data_i, input wire [1:0] byteadd, input wire [2:0] fun3, input wire mem_en, input wire Load, input wire data_valid, input wire [31:0]wrap_load_in,
    output reg [3:0] masking, output reg [31:0] data_o, output reg [31:0] wrap_load_out
);
    always @(*) begin
        masking = 4'b0000; data_o = 0; wrap_load_out = 0;
        if (mem_en) begin
            if(fun3==3'b000) case (byteadd) 0:begin masking=1; data_o=data_i; end 1:begin masking=2; data_o={data_i[31:16],data_i[7:0],data_i[7:0]}; end 2:begin masking=4; data_o={data_i[31:24],data_i[7:0],data_i[15:0]}; end 3:begin masking=8; data_o={data_i[7:0],data_i[23:0]}; end endcase
            if(fun3==3'b001) case (byteadd) 0:begin masking=3; data_o=data_i; end 1:begin masking=6; data_o={data_i[31:24],data_i[15:0],data_i[7:0]}; end 2:begin masking=12; data_o={data_i[15:0],data_i[15:0]}; end endcase
            if(fun3==3'b010) begin masking=15; data_o=data_i; end
        end
        if (Load | data_valid) begin
            if(fun3==3'b000) case (byteadd) 0:wrap_load_out={{24{wrap_load_in[7]}},wrap_load_in[7:0]}; 1:wrap_load_out={{24{wrap_load_in[15]}},wrap_load_in[15:8]}; 2:wrap_load_out={{24{wrap_load_in[23]}},wrap_load_in[23:16]}; 3:wrap_load_out={{24{wrap_load_in[31]}},wrap_load_in[31:24]}; endcase
            if(fun3==3'b001) case (byteadd) 0:wrap_load_out={{16{wrap_load_in[15]}},wrap_load_in[15:0]}; 1:wrap_load_out={{16{wrap_load_in[23]}},wrap_load_in[23:8]}; 2:wrap_load_out={{16{wrap_load_in[31]}},wrap_load_in[31:16]}; endcase
            if(fun3==3'b010) wrap_load_out=wrap_load_in;
            if(fun3==3'b100) case (byteadd) 0:wrap_load_out={24'b0,wrap_load_in[7:0]}; 1:wrap_load_out={24'b0,wrap_load_in[15:8]}; 2:wrap_load_out={24'b0,wrap_load_in[23:16]}; 3:wrap_load_out={24'b0,wrap_load_in[31:24]}; endcase
            if(fun3==3'b101) case (byteadd) 0:wrap_load_out={16'b0,wrap_load_in[15:0]}; 1:wrap_load_out={16'b0,wrap_load_in[23:8]}; 2:wrap_load_out={16'b0,wrap_load_in[31:16]}; endcase
            if(fun3==3'b110) wrap_load_out=wrap_load_in;
        end     
    end

endmodule
