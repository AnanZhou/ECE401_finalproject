module microprocessor_tb();
    reg clk;
    reg [31:0] instruction; // Note: This input seems unused in your read-only memory setup
    reg rst;

    // Instantiate the Unit Under Test (UUT)
    microprocessor u_microprocessor0 (
        .clk(clk),
        .instruction(instruction),
        .rst(rst)
    );

    // --- CLOCK GENERATION ---
    always #5 clk = ~clk;

    // --- DEBUGGING SIGNALS (Hierarchical Access) ---
    // These wires "peek" inside the core to show you internal states
    wire [31:0] debug_pc          = u_microprocessor0.u_core.pc_address;
    wire [31:0] debug_instr       = u_microprocessor0.u_core.instruction_fetch;
   
   
    wire        debug_instr_valid = u_microprocessor0.instruc_mem_valid; 
    wire        debug_req         = u_microprocessor0.instruction_mem_request;

    initial begin
        // 1. Initialize
        clk = 0;
        rst = 1; // Start high (assuming active low reset logic based on your files)
        instruction = 0;

        // 2. Formatting the Console Output
        $display("---------------------------------------------------------------------------------------------------------");
        $display("Time |    PC    |   Instr  | Req | Vld | PredTaken | PredTarget | Action Observed");
        $display("---------------------------------------------------------------------------------------------------------");

        // 3. Reset Sequence
        #10 rst = 0; // Assert Reset (Active Low)
        #10 rst = 1; // Release Reset
        
        // 4. Run Simulation
        #1000; 
        $display("---------------------------------------------------------------------------------------------------------");
        $finish;        
    end

    // --- AUTOMATIC MONITORING ---
    // Prints a log line every time the clock rises (start of a cycle)
    always @(posedge clk) begin
        if (rst) begin // Only print when not in reset
            #1; // Wait 1 unit for signals to settle after clock edge
            
          $display("%4t | %h | %h |  %b|", 
                $time, 
                debug_pc, 
                debug_instr,
                debug_req,
                debug_instr_valid
            );
        end
    end

    // --- WAVEFORM DUMP ---
    initial begin
       $dumpfile("microprocessor.vcd");
       $dumpvars(0, microprocessor_tb);
    end
endmodule