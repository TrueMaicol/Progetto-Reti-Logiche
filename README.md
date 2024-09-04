# Progetto Reti Logiche

Final test of the _Reti Logiche_ course of the Bachelor degree program of _Ingegneria Informatica_ at Politecnico di Milano. Grade: 30/30

## Authors

- **Christian Biffi** - 10787158
- **Michele Cavicchioli** - 10706553


## Overview

This project implements a system designed to read data from memory and output it to one of four available outputs. The system sequentially receives the encoding corresponding to the output where the data should be displayed and the memory address from which the data should be read.

## Project Scope

The goal of this project is to create a digital system that performs memory reads and displays the retrieved data on a selected output. The system operates based on input signals, particularly `i_start`, which controls when data is read and processed.

## System Specifications

- The system reads the input via the `i_w` signal only when the `i_start` signal is high.
- There are four possible outputs (Z0, Z1, Z2, Z3), and 2 bits are sufficient to encode the output choice.
- The first two bits of the `i_w` signal determine the selected output, and the remaining bits compose the memory address.
- When computation is complete, the `o_done` signal goes high for one clock cycle, displaying the read data on the selected output.
- The system resets to its initial state when the `i_rst` signal is high, clearing any previously read data.

## Interface

The system is encapsulated in the `project_reti_logiche` entity, which has the following ports:

```vhdl
entity project_reti_logiche is
    port (
        i_clk       : in  std_logic;
        i_rst       : in  std_logic;
        i_start     : in  std_logic;
        i_w         : in  std_logic;
        o_z0        : out std_logic_vector(7 downto 0);
        o_z1        : out std_logic_vector(7 downto 0);
        o_z2        : out std_logic_vector(7 downto 0);
        o_z3        : out std_logic_vector(7 downto 0);
        o_done      : out std_logic;
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in  std_logic_vector(7 downto 0);
        o_mem_we    : out std_logic;
        o_mem_en    : out std_logic
    );
end project_reti_logiche;
```

## Architecture

The system is composed of three main components:

1. **Main Entity**
    - Handles essential inputs and outputs.
    - Manages the Finite State Machine (FSM) which controls the flow of operations.

2. **ShifterRegister**
    - Implements a left shift register to handle the memory address.
    - Shifts bits on each clock cycle while `i_start` is high, inserting the input bit into the Least Significant Bit (LSB).

3. **Datapath**
    - Manages the output data by retrieving it from RAM and storing it in the appropriate output register.
    - Controls the output based on the `done` signal, ensuring that the correct data is displayed on the selected output channel.

### Finite State Machine (FSM)

The FSM is divided into six states:

- **WAIT START**: The initial state, waiting for the `i_start` signal to go high, indicating the start of a valid input sequence.
- **ADD1**: Reads the first bit of the selected output channel.
- **ADD2**: Reads the second bit of the selected output channel.
- **LOAD DATA**: Manages the input of the memory address bit by bit, using the ShifterRegister to store the input.
- **SAVE DATA**: Fetches the data from memory and stores it in the selected output register.
- **OUTPUT**: Raises the `o_done` signal and displays the data on the outputs. The FSM then returns to the `WAIT START` state, ready for a new sequence.

## Results

### Synthesis

The synthesis of the component shows minimal resource utilization, ensuring efficient hardware implementation.

### Simulations

The system was tested using both the provided and custom testbenches, covering edge cases to ensure proper functionality. The system passed all tests in both Behavioral and Post-Synthesis Functional Simulations.

## Conclusion

The final system successfully meets the project specifications, passing all provided tests. The FSM was optimized from 8 to 6 states, and the code was kept modular and clean for maintainability.
