![](../../workflows/gds/badge.svg)
![](../../workflows/docs/badge.svg)
![](../../workflows/test/badge.svg)
![](../../workflows/fpga/badge.svg)

# Workshop Simple CPU

An educational 8-bit accumulator CPU designed as part of an
OpenSilicon / Tiny Tapeout workshop.

The project demonstrates the basic structure of a processor:

- Program counter
- Program ROM
- Instruction decoder
- Accumulator register
- ALU
- Data memory
- Zero flag
- Conditional and unconditional jumps
- Input/output instructions
- Halt control

## Project overview

This project is an educational 8-bit accumulator CPU designed for a Tiny Tapeout workshop.
The CPU demonstrates the basic principles of processor design, including:
Program counter
Instruction fetch and decode
Accumulator register
Arithmetic and logic operations
Data memory
Conditional and unconditional jumps
Input/output instructions
Halt control
A simple custom instruction set
The design is written in Verilog and is intended to be easy for students to understand, simulate, modify, and eventually submit to Tiny Tapeout.
How it works
The CPU uses an 8-bit data path and a 4-bit program counter.
The program counter addresses a 16-word instruction ROM. Each instruction contains an opcode and, where required, a 4-bit operand.
The CPU contains:
An 8-bit accumulator
A 4-bit program counter
An 8-bit data RAM with 16 locations
An ALU
A zero flag
Input and output ports
A halt state
For each clock cycle, the CPU:
Fetches the instruction from the ROM.
Decodes the instruction.
Executes the operation.
Updates the accumulator, memory, or program counter as required.
Continues until the `HLT` instruction is executed.
Instruction Set
Opcode	Instruction	Description
`0`	`NOP`	No operation
`1`	`LDA`	Load accumulator from memory
`2`	`STA`	Store accumulator to memory
`3`	`ADD`	Add memory value to accumulator
`4`	`SUB`	Subtract memory value from accumulator
`5`	`AND`	Bitwise AND
`6`	`OR`	Bitwise OR
`7`	`LDI`	Load immediate value into accumulator
`8`	`JMP`	Unconditional jump
`9`	`JZ`	Jump if accumulator is zero
`A`	`IN`	Read external input
`B`	`OUT`	Write accumulator to output
`C`	`DEC`	Decrement accumulator
`D`	`HLT`	Halt the processor
Demonstration Program
The default ROM contains a simple program that calculates:
```text
5 + 4 + 3 + 2 + 1 = 15
```
The result is sent to the output port.
The expected output is:
```text
Decimal: 15
Hex:     0x0F
Binary:  00001111
```
After execution, the CPU enters the halted state.
Pinout
The Tiny Tapeout top-level module is:
```text
tt_um_workshop_cpu
```
User Input
The 8 `ui_in` pins are connected directly to the CPU input port.
Pin	Function
`ui_in[0]`	CPU input bit 0
`ui_in[1]`	CPU input bit 1
`ui_in[2]`	CPU input bit 2
`ui_in[3]`	CPU input bit 3
`ui_in[4]`	CPU input bit 4
`ui_in[5]`	CPU input bit 5
`ui_in[6]`	CPU input bit 6
`ui_in[7]`	CPU input bit 7
Therefore:
```text
ui_in[7:0] = CPU input value
```
User Output
The 8 `uo_out` pins are connected to the CPU output port.
Pin	Function
`uo_out[0]`	CPU output bit 0
`uo_out[1]`	CPU output bit 1
`uo_out[2]`	CPU output bit 2
`uo_out[3]`	CPU output bit 3
`uo_out[4]`	CPU output bit 4
`uo_out[5]`	CPU output bit 5
`uo_out[6]`	CPU output bit 6
`uo_out[7]`	CPU output bit 7
Therefore:
```text
uo_out[7:0] = CPU output value
```
For the default demonstration program:
```text
uo_out = 8'h0F
```
