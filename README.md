#  RV32I RISC-V Pipelined Processor  
### *ECE 401 – Final Project*  
*A clean, modular, 5-stage pipeline CPU with Dynamic Branch Prediction*

---

##  Overview

This project implements a **fully functional RV32I RISC-V processor** using a classic **5-stage pipeline**. The design emphasizes a clear modular layout with separate files for top-level integration, pipeline stages, storage, components, and control logic — matching the structure used in the accompanying design specification.

The implementation includes:
- A working baseline pipeline CPU  
- Hazard detection + forwarding  
- Branch and jump support (JAL, JALR, BNE, etc.)  
- Synchronous instruction & data memories  
- **Dynamic Branch Predictor (BTB + 2-bit BHT)**  
- Internal register forwarding  
- Optimized PC arbitration for speculation  

This CPU was built as part of **ECE 401 – RISC-V Processor Design**.

---

##  Features

###  Complete RV32I Support
All integer instructions including:
- Arithmetic/logic (R/I type)  
- Branches and jumps  
- Loads / stores  
- Immediate construction (LUI, AUIPC)  
- System ops (ECALL, EBREAK)

###  5-Stage Pipeline
- IF: PC update, instruction fetch  
- ID: Decode, regfile read, ImmGen  
- EX: ALU ops, branch compare, target calc  
- MEM: Load/store  
- WB: Write result back to register file  

###  Hazard Handling
- Data hazards: Forwarding from EX/MEM and MEM/WB  
- Load-use hazard: 1-cycle stall  
- Control hazards: Flush on mispredict  

###  Dynamic Branch Prediction (Optimization)
- Branch Target Buffer (BTB)  
- 2-bit Saturating Counter (BHT) predictor  
- Corrects EX-stage results with feedback loop  
- Replaces baseline “always not taken” strategy  

---

#  Project Structure 

This section summarizes each major file/module and their responsibilities according to the provided PDF.

1. Top-level Structure
  - Microprocessor.v
    - Top-level encapsulation module that instantiates Core and storage-related modules (Instruction Memory, Data Memory, etc.).
    - Exposes interfaces for clock/reset and for interaction with the outside world (such as memory and I/O used in testing).
  - Core.v
    - CPU Core module.
    - Internally includes: 5-stage pipeline registers, Fetch/Decode/Execute/Memory Access/Write Back functionality, Control Unit, Forwarding/Hazard Logic, and related glue logic.

2. Pipeline Structure
  - 5_Pipeline_Stages.v
    - Defines pipeline registers between the five pipeline stages IF / ID / EX / MEM / WB (IF/ID, ID/EX, EX/MEM, MEM/WB).
    - Manages the signals passed between stages: PC, instruction bits, register addresses, immediate values, ALU results, memory addresses/data, control signals, etc.
  - Fetch.v
    - Responsible for updating the Program Counter (PC), fetching instructions, and reading instructions from instruction memory.
    - Contains basic redirect/flush logic to support branch/jump updates when results become known (from EX/ID).
  - Decode.v
    - Decodes instructions and extracts fields (opcode, funct3, funct7, rs1, rs2, rd, etc.).
    - Generates register file read addresses and triggers reads.
    - Performs immediate generation (ImmGen) as part of decode.
  - Execute.v
    - Contains the ALU, comparator, and branch condition logic.
    - Performs arithmetic and logical operations, branch condition evaluation (equality, less-than, etc.), and computes branch/jump target addresses.
  - Write Back (WB)
    - The write-back logic writes results from MEM/WB back into the register file. This logic is typically realized in Core.v or in a small common module used by Core.v.

3. Storage and Components
  - Memory_Modules.v
    - Defines interfaces and implementations of Instruction Memory and Data Memory.
    - For simulation these are modeled as synchronous RAM/ROM or behavioral memory constructs.
  - Components.v
    - Common submodules used across stages: RegisterFile, ALU, Adder, Comparator, Immediate Generator (ImmGen), MUXes, and other small utilities.

4. Control Logic
  - Control_decode.v
    - Classifies instruction types (R/I/S/B/U/J, etc.) from opcode/funct3/funct7.
    - Generates primary control signals like ALUOp, RegWrite, MemRead, MemWrite, MemToReg, Branch, Jump, ImmSrc, etc.
  - Control_unit.v
    - Integrates hazard detection, forwarding decisions, stall/flush control, and pipeline control policy.
    - Determines when to pause a stage (stall), insert a bubble, flush pipeline registers for misprediction, and selects forwarding paths (forwarding mux select signals).

---



#  Baseline Performance

| Metric | Value |
|--------|-------|
| Pipeline Depth | 5 stages |
| Clock Frequency | 100 MHz |
| CPI (measured) | 1.54 |
| IPC | 0.65 |
| Extra Cycles per Branch | 2 bubbles |

Main bottleneck: control hazards — motivating the dynamic branch predictor described below.

---

#  Optimization: Dynamic Branch Prediction

The branch predictor implemented in this design consists of:

- Branch Target Buffer (BTB)
  - Stores PC tag and target address.
  - Indexed by pc[9:2]; on BTB hit a candidate target is provided.

- 2-bit Saturating Counter (BHT)
  - States: 00 Strong Not Taken, 01 Weak Not Taken, 10 Weak Taken, 11 Strong Taken.
  - Prediction rule: MSB = 1 → predict taken.

Predictor outputs:
- pred_taken (true when BTB hit and BHT predicts taken)
- pred_target (BTB target)

Prediction is used to speculatively update PC; mispredictions are corrected when EX-stage confirms branch outcome and target.

- Timing Alignment Optimization
- Internal Forwarding
- PC Priority Arbitration (from high to low)
    - 1.Mispredict
    - 2.Load Stall
    - 3.Prediction
    -  PC + 4
- Feedback Loop
    - Learn
    - Punish 


---

#  Authors

- Anan Zhou
- Jiahao Huang
- Yuhan Lin

---

# Reference
- https://github.com/arhamhashmi01/rv32i-pipeline-processor

