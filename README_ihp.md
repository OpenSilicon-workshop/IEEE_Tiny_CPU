# appendix: IHP SRAM memory variant 

 `README.md` . 
(`cpu_ihp.v`) data memory (register array) 
 SRAM IHP SG13G2 -- 
 TinyTapeout IHP.

## 

 (`cpu.v`) ** cycles** (single-cycle):
 memory **** cycles clock. 
 (register array) ().

 SRAM ** **. (clocked):
 address cycles cycles . 
 ** phase** :

1. **phase ADDR**: address (write data `STA`) .
2. **phase DATA**: memory 
 update the accumulator .

 cycles (92 cycles 
46 ) -- 
 SRAM: ** memory (memory latency) 
 .**

## 

 Verilog 
 IHP :

1. Python (`cpu_model_ihp.py`) 
 (ADDR/DATA) 
 (registered read). 
 cycles : `OUT = 15` 92 ( 46 ).
2. Verilog 
 Python .
3. ** Verilog .**
 `make ihp` ( Makefile) 
 .

## 

** ( TinyTapeout/IHP ):**
- IHP SRAM 
 TinyTapeout IHP .
- IHP `256x8` ( ) ~17547 µm²
 `1x2` -- 
 (8 ).
- (`A_CLK`, `A_MEN`, `A_REN`, `A_WEN`, `A_ADDR`,
 `A_DIN`, `A_BM`, `A_DLY`, `A_DOUT`, `A_BIST_*`) 
 (`ihp-sg13g2-ams-chip-template`) (1024×32)
 memory.

** :**
- 256×8 ( `c2` ).
 : `IHP-Open-PDK/ihp-sg13g2/libs.ref/sg13g2_sram/`
- BIST ( Note TODO 
 `ihp_sram_256x8.v` ).
- `A_BM` ( 1 " " ).
- TinyTapeout ** SRAM 
 ** **** .
 : <https://tinytapeout.com/specs/memory/>
- **:** (`ttihp-verilog-template`) 
 . 
 (hard macro) SRAM 
 LibreLane ( ) -- 
 `info.yaml` . TinyTapeout Discord 
 .

## 

- `cpu.v` ( ) ** ** 
 -- .
- `cpu_ihp.v` ** optional** : 
 memory 
 " " ( `rom.v`) " "
 (hard macro) SRAM.

## 

```
src/ihp_sram_256x8.v memory ( + )
src/cpu_ihp.v multi-cycle
src/tt_um_workshop_cpu_ihp.v 
test/tb_cpu_ihp.v testbench ( -DSIM )
cpu_model_ihp.py 
```

 :
```bash
make ihp
```
