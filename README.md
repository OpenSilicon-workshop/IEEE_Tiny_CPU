![](../../workflows/gds/badge.svg)
![](../../workflows/docs/badge.svg)
![](../../workflows/test/badge.svg)
![](../../workflows/fpga/badge.svg)
# Workshop 8-bit Accumulator CPU SoC

An educational 8-bit accumulator-based microcontroller implemented in Verilog for Tiny Tapeout.
Overview
The project combines:
8-bit accumulator CPU
16-bit instruction / 32-word program ROM
32 bytes of data RAM
hardware stack
8-bit ALU
8-bit GPIO input/output
transmit-only UART
8-bit timer/counter
Tiny Tapeout integration
The RTL is organized into small modules so students can study and modify the processor and its peripherals.
Architecture
```text
                    +--------------------------+
                    |    tt_um_workshop_cpu    |
                    |    Tiny Tapeout wrapper  |
                    +------------+-------------+
                                 |
                    +------------v-------------+
                    |         soc_top          |
                    |                          |
                    |  +--------------------+  |
                    |  | CPU Control FSM    |  |
                    |  +---------+----------+  |
                    |            |             |
                    |       +----v----+        |
                    |       |   ALU   |        |
                    |       +---------+        |
                    |                            |
                    |  +------+ +------+         |
                    |  | ROM  | | RAM  |         |
                    |  +------+ +------+         |
                    |  +------+ +------+ +-----+ |
                    |  | GPIO | | UART | |Timer| |
                    |  +------+ +------+ +-----+ |
                    +------------------------------+
```
Programmer's Model
Register	Width	Description
`ACC`	8 bit	Main accumulator
`PC`	8 bit	Program counter
`SP`	5 bit	Hardware stack pointer
`ZF`	1 bit	Zero flag
`CF`	1 bit	Carry flag
The stack uses the upper half of the 32-byte data RAM, with `SP` starting at `0x1F`.
Instruction Format
Each instruction is 16 bits:
```text
15                 8 7                  0
+--------------------+--------------------+
|       OPCODE       |      OPERAND       |
+--------------------+--------------------+
```
The upper byte selects the instruction and the lower byte is an immediate value, address, or branch target.
Instruction Set
Opcode	Instruction	Operation
`00`	`NOP`	No operation
`01`	`LDA imm`	`ACC = imm`
`02`	`ADD imm`	Add immediate
`03`	`SUB imm`	Subtract immediate
`04`	`AND imm`	AND immediate
`05`	`OR imm`	OR immediate
`06`	`XOR imm`	XOR immediate
`07`	`NOT`	Invert accumulator
`08`	`STA addr`	Store ACC to RAM
`09`	`LDM addr`	Load RAM into ACC
`0A`	`JMP addr`	Unconditional jump
`0B`	`JZ addr`	Jump if zero
`0C`	`JNZ addr`	Jump if not zero
`0D`	`OUT`	Write ACC to GPIO
`0E`	`IN`	Read GPIO into ACC
`0F`	`HLT`	Halt CPU
`10`	`SHL`	Shift left
`11`	`SHR`	Shift right
`12`	`INC`	Increment
`13`	`DEC`	Decrement
`14`	`ADDA addr`	Add RAM value
`15`	`SUBA addr`	Subtract RAM value
`16`	`PUSH`	Push ACC
`17`	`POP`	Pop into ACC
`18`	`CALL addr`	Call subroutine
`19`	`RET`	Return from subroutine
`1A`	`JC addr`	Jump if carry
`1B`	`UTXD`	Transmit ACC over UART
`1C`	`UTXS`	Read UART busy status
`1D`	`UBRD imm`	Set UART divisor
`1E`	`TSET imm`	Set timer prescaler
`1F`	`TGET`	Read timer count
`20`	`TCLR`	Clear timer
CPU Execution
The control unit uses a multi-cycle FSM:
```text
FETCH -> DECODE -> EXECUTE -> FETCH
                 |
                 +-> MEM_READ -> EXECUTE
```
`MEM_READ` is used for memory-dependent instructions such as `ADDA`, `SUBA`, `POP`, and `RET`.
`HLT` enters a permanent HALT state until reset.
Memory
Program ROM
`src/program_rom.v` contains:
32 words
16 bits per word
student-modifiable initialization
The instruction format is:
```verilog
rom[address] = 16'hOP_OPERAND;
```
Data RAM
`src/regfile.v` provides:
```text
32 x 8-bit
```
memory.
The current convention is:
```text
0x00-0x0F  general-purpose data
0x10-0x1F  hardware stack
```
GPIO
```text
ui_in[7:0]  -> GPIO input -> CPU
CPU         -> GPIO output -> uo_out[7:0]
```
`IN` copies the input pins into `ACC`.
`OUT` copies `ACC` to the output pins.
UART
The UART is transmit-only and uses 8-N-1 framing.
Output:
```text
uio_out[1]
```
Baud rate:
```text
baud = clock_frequency / (16 * (baud_div + 1))
```
At a 5 MHz clock, useful divisor examples include:
Divisor	Approximate baud
`2`	104166
`25`	12019
`32`	9615
Timer
The timer is an 8-bit counter with an 8-bit prescaler.
```text
timer_frequency = clock_frequency / (prescaler + 1)
```
CPU instructions:
```text
TSET  - configure prescaler
TGET  - read counter
TCLR  - clear counter
```
Default Demonstration Program
The ROM currently demonstrates several SoC features.
1. Count 1 to 5
The CPU outputs:
```text
1 -> 2 -> 3 -> 4 -> 5
```
2. Subroutine
A `CALL` jumps to a subroutine that loads `5`, increments it to `6`, and returns. The result is then output.
3. UART
The program configures the UART and transmits the character:
```text
H
```
4. Timer
The timer is configured, cleared, allowed to run for a few cycles, then read and displayed.
5. Final result
The CPU outputs:
```text
42 = 0b00101010
```
and executes `HLT`.
Tiny Tapeout Pin Mapping
`ui_in`
Pin	Signal
`ui_in[7:0]`	GPIO input
`uo_out`
Pin	Signal
`uo_out[7:0]`	GPIO output
`uio`
Pin	Direction	Signal
`uio[0]`	Output	CPU `halted`
`uio[1]`	Output	UART TX
`uio[2:7]`	Unused	—
The wrapper uses:
```verilog
uio_oe = 8'h03;
```
so only `uio[0]` and `uio[1]` are driven.
Source Tree
```text
IEEE_Tiny_CPU/
├── src/
│   ├── tt_um_workshop_cpu.v
│   ├── soc_top.v
│   ├── control.v
│   ├── alu.v
│   ├── program_rom.v
│   ├── regfile.v
│   ├── gpio.v
│   ├── uart_tx.v
│   └── timer.v
├── test/
│   ├── tb.v
│   ├── test.py
│   └── Makefile
├── docs/
│   └── info.md
├── info.yaml
├── README.md
└── LICENSE
```
Important Student Files
`program_rom.v` — write and experiment with CPU programs
`control.v` — study instruction decoding and CPU control
`alu.v` — arithmetic and logic operations
`regfile.v` — data memory and stack
`gpio.v` — external digital I/O
`uart_tx.v` — serial transmission
`timer.v` — hardware timing
Simulation
Install the basic tools on Ubuntu/Debian:
```bash
sudo apt update
sudo apt install iverilog gtkwave
```
Then run the simulation from `test`:
```bash
cd test
make
```
For waveform viewing, if supported by the Makefile:
```bash
make wave
```
The complete RTL, testbench, and CI configuration should be verified together before treating the design as tapeout-ready.
Example: Custom Program
Output `0xAA` and halt:
```verilog
rom[0] = 16'h01_AA;  // LDA #0xAA
rom[1] = 16'h0D_00;  // OUT
rom[2] = 16'h0F_00;  // HLT
```
Read switches and continuously display them:
```verilog
rom[0] = 16'h0E_00;  // IN
rom[1] = 16'h0D_00;  // OUT
rom[2] = 16'h0A_00;  // JMP 0
```
Workshop Exercises
Beginner
Change the final output value.
Create an LED counter.
Read switches with `IN`.
Generate different LED patterns.
Intermediate
Use RAM with `STA` and `LDM`.
Build loops with conditional branches.
Use `ADDA` and `SUBA`.
Experiment with shifts.
Write subroutines with `CALL` and `RET`.
Advanced
Send messages over UART.
Use the timer for delays.
Add an ALU operation.
Add a new CPU instruction.
Extend the memory system.
Explore SRAM-based memory implementations.
Study synthesis, timing, and Tiny Tapeout integration.
Design Specifications
Parameter	Value
Architecture	8-bit accumulator
Instruction width	16 bits
Opcode width	8 bits
Operand width	8 bits
Instructions	33
Program ROM	32 x 16 bits
Data RAM	32 x 8 bits
GPIO input	8 bits
GPIO output	8 bits
UART	TX only, 8-N-1
Timer	8-bit counter + prescaler
CPU control	Multi-cycle FSM
Target clock	5 MHz
HDL	Verilog
Educational Goal
The project is designed to show the progression from basic digital logic to a complete small SoC:
```text
ALU
 ↓
Registers
 ↓
Instruction decoder
 ↓
CPU FSM
 ↓
Memory
 ↓
GPIO / UART / Timer
 ↓
Complete SoC
 ↓
Tiny Tapeout
```
The RTL is intentionally visible and modular so students can trace an instruction from ROM through the control unit and ALU to the external pins.
Project Status
This is an educational CPU/SoC development project. The RTL, testbench, Tiny Tapeout metadata, and CI flow should be kept synchronized as the design evolves.
License
See `LICENSE` for the project license.
