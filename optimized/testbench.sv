// Code your testbench here
// or browse Examples
module microprocessor_tb();
    reg clk;
    reg [31:0]instruction;
    reg rst;

    microprocessor u_microprocessor0
    (
        .clk(clk),
        .instruction(instruction),
        .rst(rst)
    );

    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst=0;
        #10;

        rst = 1;
        #140;
        #2000;

        $finish;       
    end
     initial begin
       $dumpfile("microprocessor.vcd");
       $dumpvars(0,microprocessor_tb);
    end

    always begin
        #5 clk= ~clk;
    end
endmodule