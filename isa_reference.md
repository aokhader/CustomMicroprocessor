## Instruction Notes:
We are limited by 9-bit instruction width. We are using 8 operations with 8 registers, r0-r7. We are also using a 64-value lookup table to store branching/loop addresses and repeated constants. The assembler will get the label line numbers and store them into a file, which is then loaded into the Verilog code before the program runs.

## Opcode List

#### Store the result in the first register listed for the following instructions: 
- ``MOV: 000 RRR RRR``
- ``ADD: 001 RRR RRR`` (SUB can be replaced with negative values in the LUT)
- ``AND: 010 RRR RRR``
- ``XOR: 011 RRR RRR``
- ``LSR: 100 RRR III`` (We don't need ADDI since all the constants are in the LUT and we can load from LUT into register)

#### Rest of the instructions:
- ``LD: 101 C AAAAA``: We can load (implicitly into r0) either from LUT or from memory:
  - Memory (inputs; register-based):
  ``LDM: 101 0 RRRRR (load from MEM[RRRRR]; R is the register that holds the address)``
  - LUT (constants and branch addresses; immediate-based):    
  ``LDI: 101 1 AAAAA (load from LUT[AAAAA])``

- ``STR: 110 R AAAAA (stores value in either r0 or r1 into MEM[AAAAA])``

- ``BR: 111 C AAAAA``:
  - Unconditional Jump: ``BR:  111 0 AAAAA (jump to LUT[AAAAA])``
  - Jump only if r0!=0: ``BNZ: 111 1 AAAAA (jump to LUT[AAAAA] if r0 != 0)``   


## Example Usage:

### MOV
Copies the value in the first register into the second register: 
```mov r4, r5;     r4 = r5```

### ADD
Accumulates the value in the first register by adding the second register's value:
```add r4, r5;     r4 = r4 + r5```

### AND
Performs bitwise AND on the two registers and stores the result into the first register:
```and r4, r5;     r4 = r4 & r5```

### XOR 
Performs bitwise XOR on the two registers and stores the result into the first register:
```xor r4, r5;     r4 = r4 ^ r5```

### LSR 
Performs a logical right shift by the given immediate on the given register and stores it in the same register:
```lsr r4, 5;      r4 = r4 >> 5```

### LDM
Loads the value stored in the memory address that is in the given register into r0:
```ldm r2;      r0 = MEM[r2]```

### LDI
Loads the value stored in the given LUT index into r0:
```ldi 11;      r0 = LUT[11]```

### STR
Stores the value in the given register into the given memory address:
*Note: the only valid registers we can store values from are r0 and r1.*
```str r0, 30;      MEM[30] = r0```

### BR
Performs an unconditional jump to the address stored in the given LUT index:
*Note that the assembler stores the address (the line we want to jump to) in the LUT, where we assume the PC is incrementing by 1 i.e. we start at PC = 0, then the next instruction is at PC = 1.*
```
0:   mov r1, r2
1:   add r3, r4
...
14:  loop: 
15:    xor r2, r3
15:    add r5, r0
16:    br 1        ; Assume LUT[1] = 14, so this jumps to line 14 i.e. goes to loop
```

### BNZ
Performs a jump to the address stored in the given LUT index IF r0 = 0:
*Note that the assembler stores the address (the line we want to jump to) in the LUT, where we assume the PC is incrementing by 1 i.e. we start at PC = 0, then the next instruction is at PC = 1.*
```
0:   mov r4, r1
1:   add r3, r2
...
10:  loop: 
11:    xor r1, r3
12:    add r0, r2
13:    bnz 2        ; Assume LUT[2] = 10, so this jumps to line 10 i.e. goes to loop IF r0 != 0
```


