module branch_predictor (
    input wire clk,
    input wire rst,
    
    // FETCH STAGE (Prediction Interface)
    input wire [31:0] fetch_pc,
    output reg predict_taken,
    output reg [31:0] predict_target,

    // EXECUTE STAGE (Update Interface)
    input wire update_en,             // Execute stage is processing a control instruction
    input wire [31:0] update_pc,      // PC of that instruction
    input wire [31:0] actual_target,  // Calculated Target
    input wire actual_taken           // Did it actually jump?
);
    // CONFIGURATION: 256 Entries -> 2^8
    parameter INDEX_BITS = 8; 
    parameter TAG_BITS   = 32 - INDEX_BITS - 2; // 22 bits

    integer i;

    // MEMORY ARRAYS
    reg [31:0]          btb_target [0:255];
    reg [TAG_BITS-1:0]  btb_tag    [0:255];
    reg                 btb_valid  [0:255];
    reg [1:0]           bht_state  [0:255]; // 2-bit Saturating Counter

    // SMART INDEXING: Use PC[9:2] (Discards byte offset)
    wire [INDEX_BITS-1:0] fetch_index  = fetch_pc[INDEX_BITS+1:2];
    wire [TAG_BITS-1:0]   fetch_tag    = fetch_pc[31:INDEX_BITS+2];

    wire [INDEX_BITS-1:0] update_index = update_pc[INDEX_BITS+1:2];
    wire [TAG_BITS-1:0]   update_tag   = update_pc[31:INDEX_BITS+2];

    // ============================================================
    // 1. PREDICTION LOGIC (Combinational)
    // ============================================================
    always @(*) begin
        // Predict TAKEN if: Valid + Tag Match + Counter >= 2'b10
        if (btb_valid[fetch_index] && (btb_tag[fetch_index] == fetch_tag) && bht_state[fetch_index][1]) begin
            predict_taken  = 1'b1;
            predict_target = btb_target[fetch_index];
        end else begin
            predict_taken  = 1'b0;
            predict_target = 32'b0;
        end
    end

    // ============================================================
    // 2. UPDATE LOGIC (Sequential)
    // ============================================================
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 256; i = i + 1) begin
                btb_valid[i] <= 0;
                bht_state[i] <= 2'b01; // Init Weakly Not Taken
                btb_tag[i]   <= 0;
                btb_target[i]<= 0;
            end
        end else if (update_en) begin
            
            // LOGIC: ALLOCATE ON TAKEN / EVICT ON NOT TAKEN
            if (actual_taken) begin
                // --- CASE: TAKEN ---
                btb_valid[update_index]  <= 1'b1;
                btb_tag[update_index]    <= update_tag;
                btb_target[update_index] <= actual_target;

                // Saturate Counter Upwards
                if (bht_state[update_index] != 2'b11)
                    bht_state[update_index] <= bht_state[update_index] + 1;
            end 
            else begin
                // --- CASE: NOT TAKEN ---
                // Aggressive Eviction: If confidence drops below "Taken" threshold, invalidate.
                
                reg [1:0] next_state;
                
                // Saturate Downwards
                if (bht_state[update_index] != 2'b00)
                    next_state = bht_state[update_index] - 1;
                else
                    next_state = 2'b00;

                // Update State
                bht_state[update_index] <= next_state;

                // EVICTION: If next state is Weakly Not Taken (01) or Strongly Not Taken (00)
                // Remove it from BTB to save space.
                if (next_state[1] == 1'b0) begin
                    btb_valid[update_index] <= 1'b0; 
                end
            end
        end
    end
endmodule