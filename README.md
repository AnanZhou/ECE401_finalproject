# 🚀 RV32I RISC-V Pipelined Processor  
### *ECE 401 – Final Project*  
*A clean, modular, 5-stage pipeline CPU with Dynamic Branch Prediction*

---

## 📌 Overview

This project implements a **fully functional RV32I RISC-V processor** using a classic **5-stage pipeline**:


The design includes:
- A working baseline pipeline CPU  
- Hazard detection + forwarding  
- Branch and jump support (JAL, JALR, BNE, etc.)  
- Synchronous instruction & data memory  
- **Dynamic Branch Predictor (BTB + 2-bit BHT)**  
- Internal register forwarding  
- Optimized PC arbitration for speculation  

This CPU was built as part of **ECE 401 – RISC-V Processor Design**.

---

## 🧩 Features

### ✔ Complete RV32I Support
All integer instructions including:
- Arithmetic/logic (R/I type)  
- Branches and jumps  
- Loads / stores  
- Immediate construction (LUI, AUIPC)  
- System ops (ECALL, EBREAK)

### ✔ 5-Stage Pipeline
- **IF:** PC update, instruction fetch  
- **ID:** Decode, regfile read, ImmGen  
- **EX:** ALU ops, branch compare, target calc  
- **MEM:** Load/store  
- **WB:** Write result back to register file  

### ✔ Hazard Handling
- **Data hazards:** Forwarding from EX/MEM and MEM/WB  
- **Load-use hazard:** 1-cycle stall  
- **Control hazards:** Flush on mispredict  

### ✔ Dynamic Branch Prediction (Optimization)
- **Branch Target Buffer (BTB)**  
- **2-bit Saturating Counter** predictor  
- Corrects EX-stage results with feedback loop  
- Replaces baseline “always not taken” strategy  

---



# ⚙️ Baseline Architecture Summary

### **Top-Level (Microprocessor.v)**
- Instantiates Core + memories  
- Exposes clock/reset and I/O interfaces  

### **Core.v**
- Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB)  
- Stage modules  
- Control logic  
- Hazard detection  
- Forwarding logic  

---

# 🔍 Baseline Performance

| Metric | Value |
|--------|-------|
| Pipeline Depth | 5 stages |
| Clock Frequency | 100 MHz |
| CPI (measured) | **1.54** |
| IPC | **0.65** |
| Branch Prediction Accuracy | ~30–40% |
| Extra Cycles per Branch | 2 bubbles |

Main bottleneck: **Control hazards**, motivating dynamic branch prediction.

---

# 🚀 Optimization: Dynamic Branch Prediction

The branch predictor consists of:

---

## 🔸 Branch Target Buffer (BTB)
Stores:
- PC tag  
- Target address  

Indexing: `pc[9:2]`  
BTB hit → candidate jump target.

---

## 🔸 2-bit Saturating Counter (BHT)
State machine: 00 Strong Not Taken
01 Weak Not Taken
10 Weak Taken
11 Strong Taken


Prediction rule:
- **MSB = 1 → predict taken**

---

## 🔸 Predictor Behavior
Predicts **taken** only when:
- BTB hits  
- 2-bit counter predicts taken  

Outputs:
- `pred_taken`
- `pred_target`

---

# 🧑‍💻 Authors

- *Anan Zhou ;Jiahao Huang; Yuhan Lin*

---



---





