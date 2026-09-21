# — TinyTapeout

accumulator-based CPU (accumulator) 8 
 TinyTapeout .

---

## 1. 

```
              ┌──────────────┐
   ui_in ────►│   IN port    │
              └──────┬───────┘
                     │
   ┌────────┐   ┌────▼────┐   ┌──────────────┐
   │   PC   ├──►│  ROM    ├──►│ Control Unit │
   └────▲───┘   │ 16 × 8  │   └──────┬───────┘
 │ └─────────┘ │ 
        │                            │
        │       ┌─────────┐   ┌──────▼──────┐
        └───────┤  JMP/JZ │   │     ALU     │◄──┐
                └─────────┘   └──────┬──────┘   │
                                     │          │
                              ┌──────▼──────┐   │
                              │  ACC (8b)   ├───┘
                              └──────┬──────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
             ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
             │ RAM 16 × 8  │  │  OUT port   │  │   Z flag    │
             └─────────────┘  └──────┬──────┘  └─────────────┘
                                     │
                                  uo_out
```

- **PC**: 4 (16 ).
- **ROM**: `case` .
- **RAM**: 16 × 8 .
- **ACC**: .
- **Z flag**: zero flag .

 **cycles ** (single-cycle).

---

## 2. 

```
 : 7 6 5 4 3 2 1 0
       └──────┬──────┘ └──────┬──────┘
          opcode            operand
 (4 ) (4 )
```

## 3. instruction set (ISA)

| Opcode | | | |
|:------:|:--------:|---------|------|
| `0x0` | `NOP`      | no operation | `0x00` |
| `0x1` | `LDA addr` | `A ← RAM[addr]` | `0x18` |
| `0x2` | `STA addr` | `RAM[addr] ← A` | `0x28` |
| `0x3` | `ADD addr` | `A ← A + RAM[addr]` | `0x39` |
| `0x4` | `SUB addr` | `A ← A - RAM[addr]` | `0x4A` |
| `0x5` | `AND addr` | `A ← A & RAM[addr]` | `0x5B` |
| `0x6` | `OR  addr` | `A ← A \| RAM[addr]` | `0x6C` |
| `0x7` | `LDI imm`  | `A ← imm` (0..15) | `0x75` |
| `0x8` | `JMP addr` | `PC ← addr` | `0x84` |
| `0x9` | `JZ addr` | `Z=1` `PC ← addr` | `0x9C` |
| `0xA` | `IN`       | `A ← ui_in` | `0xA0` |
| `0xB` | `OUT`      | `uo_out ← A` | `0xB0` |
| `0xC` | `DEC`      | `A ← A - 1` | `0xC0` |
| `0xF` | `HLT`      | halt the processor | `0xF0` |

> **Note zero flag:** `Z` 
> (`LDA, ADD, SUB, AND, OR, LDI, IN, DEC`). `STA` `DEC`
> `JZ` .

---

## 4. 

 `5 + 4 + 3 + 2 + 1 = 15` .

| address | | | |
|:---:|:---:|---|---|
| 0  | `70` | `LDI 0`  | `A = 0` |
| 1  | `28` | `STA 8`  | `sum = 0` |
| 2  | `75` | `LDI 5`  | `A = 5` |
| 3  | `29` | `STA 9`  | `cnt = 5` |
| 4  | `18` | `LDA 8`  | **loop:** `A = sum` |
| 5  | `39` | `ADD 9`  | `A = sum + cnt` |
| 6  | `28` | `STA 8`  | `sum = A` |
| 7  | `19` | `LDA 9`  | `A = cnt` |
| 8  | `C0` | `DEC`    | `A = cnt - 1` |
| 9  | `29` | `STA 9`  | `cnt = A` |
| 10 | `9C` | `JZ 12` | → 12 |
| 11 | `84` | `JMP 4` | solution |
| 12 | `18` | `LDA 8`  | `A = sum` |
| 13 | `B0` | `OUT` | (15) |
| 14 | `F0` | `HLT` | |
| 15 | `00` | `NOP` | |

 `uo_out` **15** **46 cycles **.

---

## 5. 

```bash
# Tool installation (Ubuntu/Debian)
sudo apt install iverilog gtkwave

# 
make

# 
make wave
```

 :

```
=== starting CPU test ===
 reset ...
=== execution ended after 46 cycles ===
  PASS  halted : 1
  PASS  OUT (sum 1..5) : 15
  PASS  uio_oe : 255
 PASS OUT : 15

*** all tests passed ***
```

 Python `cpu_model.py` 
 `rom.v`.

---

## 6. pin assignment TinyTapeout

| | |
|---|---|
| `ui_in[7:0]` | `IN` |
| `uo_out[7:0]` | output register ( `OUT`) |
| `uio_out[3:0]`| program counter `PC` () |
| `uio_out[4]`  | halt signal `halted` |
| `uio_oe` | `8'hFF` — |

---

## 7. 

1. **** — `LDI 5` address 2 `LDI 7` result 
 .
2. **** — `XOR addr` ( `opcode = 0xD`). 
 `alu.v` `cpu.v`.
3. **** — `ui_in` `IN` 
 (: `A + A` ).
4. **** — (Carry flag) `JC` .
5. **** — : 16 RAM
 8 check the synthesis report.

---

## 8. TinyTapeout

1. ** ** GitHub
 ( `ttihp-verilog-template`) *Use this template*.
2. `src/` `src/` .
3. `info.yaml`: `top_module` 
 GitHub ( `tt_um_yourname_cpu`) 
 Verilog .
4. `docs/info.md` .
5. (`git push`) **GitHub Actions**.
6. check the synthesis report (Synthesis/GDS) Action: 
 `tiles`.
7. TinyTapeout ** **.

> ⚠️ **:** `info.yaml` `yaml_version` .
> `info.yaml` 
> unchanged.

---

## 9. 

```
cpu_project/
├── src/
│ ├── alu.v arithmetic and logic unit ( 2)
│ ├── rom.v 
│ ├── cpu.v 
│ └── tt_um_workshop_cpu.v TinyTapeout
├── test/
│   └── tb_cpu.v                testbench self-checking
├── cpu_model.py Python
├── info.yaml TinyTapeout
├── Makefile 
└── README.md 
```
