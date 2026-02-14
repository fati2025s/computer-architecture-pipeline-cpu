# RISC-V 5-Stage Pipelined Processor with Cache & Hazard Unit

## Overview

This repository contains a high-performance **5-stage pipelined RISC-V processor** implemented in **SystemVerilog**. The design focuses on resolving complex architectural challenges, including data and control hazards, and features an integrated cache system for optimized memory access.

## Key Features

### 5-Stage Pipeline:

Implements Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), and Write-back (WB) stages.

### Advanced Hazard Management:

- #### Forwarding Unit:

    Minimizes stalls by forwarding data from EX and MEM stages directly to the ALU      and Branch logic in the ID stage.

- #### Hazard Detection Unit:

    Intelligently handles Load-Use dependencies and branch penalties by inserting stalls (bubbles) when necessary.

- #### Branch Flush:

    Implements a flushing mechanism to clear the pipeline upon taken branches,       ensuring that incorrect instructions are discarded.

### Integrated Cache System:

- **Direct-Mapped Cache**: A 64-line cache (32-bit per line) providing fast data access.

- **Write-Through Policy**: Ensures data consistency by updating both the cache and main memory simultaneously during write operations.

- **Cache Controller**:Handles Cache Misses by stalling the entire pipeline until data is fetched from the Main Memory.

### Branch Optimization:

Branch target calculation and decision-making are moved to the **ID stage** to reduce the branch penalty to just 1 cycle.

## Architecture

The processor follows the standard RISC-V RV32I ISA, supporting:

- ***R-type:*** add, sub, and, or, slt, etc.

- ***I-type:*** addi, lw, jalr, etc.

- ***S-type:*** sw.

- ***B-type:*** beq, bne, etc.

- ***J-type:*** jal.

## Technical Specifications

***ISA**  RISC-V RV32I

***Pipeline Depth*** 5 Stages

***Cache Type*** Direct-Mapped (64 Lines)

***Write Policy*** Write-Through

***Forwarding*** MEM -> EX, WB -> EX, MEM -> ID

***Memory Size*** 1024 x 32-bit Words


# Simulation & Verification

The design has been rigorously tested using custom assembly programs. The waveform below demonstrates a **Taken Branch** scenario where the Hazard Unit successfully triggers a **Stall** for data dependency and a **Flush** to clear the incorrect speculative path.

# 🛠 How to Run

 Clone the repository:
```bash
git clone https://github.com/fati2025s/computer-architecture-pipeline-cpu.git

```bash
iverilog -g2012 -o processor.out *.sv

```bash
vvp processor.out

```bash
gtkwave Processor_waves.vcd




