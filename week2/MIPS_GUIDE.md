# MIPS Assembly: Understanding Your Programs from Scratch

> **Goal**: By the end of this guide you should be able to re-write `sum.asm`, `first_n.asm`, and `factorial.asm` completely from memory — and understand *why* every line is there.

---

## 0. The Mental Model Before Anything Else

Think of a MIPS program as a very simple robot that can only do a handful of things:

| What the robot can do | MIPS concept |
|---|---|
| Remember numbers in little slots | **Registers** (`$t0`, `$v0`, …) |
| Store things on a bigger shelf | **Memory** (`.data` section) |
| Do math | `add`, `addi`, `mul`, … |
| Make decisions ("if i > N, stop") | **Branch instructions** (`bgt`, `beq`, …) |
| Jump to a different part of the code | `j label` |
| Ask the OS to do something (print, read) | **syscall** |

That's it. Every program you'll write is just a combination of those five things.

---

## 1. The Two Sections: `.data` and `.text`

Every MIPS program is split into exactly two parts.

```asm
.data          ; "Here I declare my variables and strings"
    msg: .asciiz "Hello"

.text          ; "Here is my actual code (instructions)"
main:
    ...
```

### `.data` — your variables

| Directive | What it stores | Example |
|---|---|---|
| `.asciiz "..."` | A null-terminated string | `msg: .asciiz "Enter N: "` |
| `.word 0` | A 32-bit integer, initialised to 0 | `sum: .word 0` |

Think of each label (`msg:`, `sum:`) as a **variable name**. The label is the address where that data lives in memory.

### `.text` — your code

The `.globl main` directive just tells the assembler "this is where execution starts". Always write:

```asm
.text
.globl main
main:
    ... your instructions ...
```

---

## 2. Registers — Your Only "Fast" Memory

MIPS has 32 registers. You only need to know a handful right now:

| Register | Nickname | Purpose |
|---|---|---|
| `$v0` | value | Return value from syscall; also holds syscall number |
| `$a0` | argument | Argument passed *to* a syscall |
| `$t0`–`$t9` | temp | Your scratch pad — use these freely |
| `$zero` | zero | Always contains 0 (read-only) |

**Key rule**: Registers are *fast* but not permanent — they live only while the program runs. Memory (`.data`) survives between stores.

---

## 3. Syscalls — Asking the OS to Do Things

A **syscall** is how your program talks to the OS (SPIM/MARS simulator). The pattern is always:

1. Load the syscall *code number* into `$v0`
2. Load any argument into `$a0`
3. Execute `syscall`

| `$v0` | What happens | Argument / Result |
|---|---|---|
| `1` | Print an integer | `$a0` = the integer to print |
| `4` | Print a string | `$a0` = address of the string |
| `5` | Read an integer from keyboard | Result comes back in `$v0` |
| `10` | Exit the program | — |

### Example: printing a string

```asm
li $v0, 4          # "I want to print a string"
la $a0, msg1       # "the string is at label msg1"
syscall            # do it!
```

`li` = **L**oad **I**mmediate (put a number directly into a register)  
`la` = **L**oad **A**ddress (put the memory address of a label into a register)

### Example: reading a number

```asm
li $v0, 5          # "I want to read an integer"
syscall            # do it — result is now in $v0
move $t0, $v0      # copy that result into $t0 so I can use $v0 for the next syscall
```

`move` just copies one register into another.

---

## 4. Basic Arithmetic

```asm
add  $t2, $t0, $t1     # $t2 = $t0 + $t1   (register + register)
addi $t2, $t1,  1      # $t2 = $t1 + 1     (register + constant)
mul  $t1, $t1, $t2     # $t1 = $t1 * $t2
sub  $t2, $t0, $t1     # $t2 = $t0 - $t1
```

The format is always: **destination, source1, source2**.

---

## 5. Memory: `lw` and `sw`

When you declare a `.word` variable in `.data`, it lives in memory — not in a register. To use it you must **load** it into a register first, and **store** it back when you're done.

```asm
lw $t2, no      # Load Word:  read the value at label 'no' into $t2
sw $t0, sum     # Store Word: write the value of $t0 into label 'sum'
```

`first_n.asm` uses this because the original code was written more "memory-style". `factorial.asm` skips it entirely — everything lives in registers, which is simpler and faster.

---

## 6. How Loops Work — The Key Concept

In high-level languages you write:

```c
for (i = 1; i <= N; i++) {
    sum = sum + i;
}
```

In MIPS there is no `for` or `while`. You build loops manually using two tools:

### Tool 1: Labels

A **label** is just a name for a position in the code. When you write:

```asm
loop:
    ... some instructions ...
```

`loop` is just a sticky note on that line. You can jump to it by name.

### Tool 2: Branch + Jump

| Instruction | Meaning |
|---|---|
| `j label` | **Unconditional jump** — always go to `label` |
| `beq $a, $b, label` | Jump to `label` **if** `$a == $b` |
| `bne $a, $b, label` | Jump to `label` **if** `$a != $b` |
| `bgt $a, $b, label` | Jump to `label` **if** `$a > $b` |
| `blt $a, $b, label` | Jump to `label` **if** `$a < $b` |
| `bge $a, $b, label` | Jump to `label` **if** `$a >= $b` |
| `ble $a, $b, label` | Jump to `label` **if** `$a <= $b` |

### The loop pattern

Every loop you write will follow this skeleton:

```asm
    # --- setup before the loop ---
    li $t1, 1        # i = 1

loop:                          # top of loop (a label)
    bgt $t1, $t2, over         # EXIT condition: if i > N, jump out
    
    # --- loop body ---
    add $t0, $t0, $t1          # sum = sum + i
    addi $t1, $t1, 1           # i = i + 1
    
    j loop                     # go back to top

over:                          # code after the loop
    ...
```

**How it executes step by step:**
1. Check: `bgt $t1, $t2, over` — is `i > N`? If YES → jump to `over` (loop ends). If NO → continue.
2. Run the body (add, increment).
3. `j loop` — jump back to the top unconditionally.
4. Repeat from step 1.

This is the **exact same structure** used in both `first_n.asm` and `factorial.asm`.

---

## 7. Program Walkthrough: `sum.asm`

This one you already understand, but let's annotate it fully.

```asm
.data
msg1: .asciiz "Enter the first number: "
msg2: .asciiz "Enter the second number: "
res:  .asciiz "the result is: "

.text
main:
    # Print "Enter the first number:"
    li $v0, 4           # syscall 4 = print string
    la $a0, msg1        # point $a0 at msg1
    syscall

    # Read first number
    li $v0, 5           # syscall 5 = read integer
    syscall
    move $t0, $v0       # save it in $t0 (otherwise next syscall overwrites $v0)

    # Print "Enter the second number:"
    li $v0, 4
    la $a0, msg2
    syscall

    # Read second number
    li $v0, 5
    syscall
    move $t1, $v0       # save it in $t1

    # Add
    add $t2, $t0, $t1   # $t2 = $t0 + $t1

    # Print "the result is:"
    li $v0, 4
    la $a0, res
    syscall

    # Print the integer result
    li $v0, 1           # syscall 1 = print integer
    move $a0, $t2       # the integer to print goes in $a0
    syscall

    # Exit
    li $v0, 10
    syscall
```

**Why `move $t0, $v0` after reading?**  
Because `$v0` has two jobs: (1) it holds the syscall number before the call, (2) it holds the return value after. The next time you do `li $v0, 5`, it will overwrite whatever was there. So you save the number into a `$t` register immediately.

---

## 8. Program Walkthrough: `first_n.asm`

**Goal**: Read N, compute `1 + 2 + 3 + … + N`, print the sum.

**In pseudocode:**
```
sum = 0
i   = 1
N   = read from user

while (i <= N):
    sum = sum + i
    i   = i + 1

print sum
```

Now line by line:

```asm
.data
msg1:   .asciiz "Enter N: "
msg2:   .asciiz "Sum = "
no:     .word 0      # memory slot for N
sum:    .word 0      # memory slot for sum

.text
.globl main
main:
    # Print prompt
    li $v0, 4
    la $a0, msg1
    syscall

    # Read N
    li $v0, 5
    syscall
    sw $v0, no          # store the value from $v0 into memory label 'no'
                        # (alternatively: move $t2, $v0 -- same effect, fewer steps)

    # Setup loop variables
    li $t0, 0           # $t0 = sum = 0
    li $t1, 1           # $t1 = i   = 1
    lw $t2, no          # $t2 = N (load from memory into register)

next:                   # label = top of loop
    bgt $t1, $t2, over  # if i > N, exit
    add $t0, $t0, $t1   # sum = sum + i
    addi $t1, $t1, 1    # i = i + 1
    j next              # go back to top of loop

over:
    sw $t0, sum         # store final sum into memory

    # Print "Sum = "
    li $v0, 4
    la $a0, msg2
    syscall

    # Print the sum integer
    li $v0, 1
    lw $a0, sum         # load from memory into $a0
    syscall

    # Exit
    li $v0, 10
    syscall

.end main
```

### What's the difference between `sw`/`lw` and `move`?

| | `sw` / `lw` | `move` |
|---|---|---|
| Where | Reads/writes **memory** | Copies between **registers** |
| When needed | When you have a `.word` variable in `.data` | When you want to copy a register |
| Speed | Slower (memory access) | Faster (stays in CPU) |

In `factorial.asm`, the code is cleaner because it never uses `.word` — everything stays in registers.

---

## 9. Program Walkthrough: `factorial.asm`

**Goal**: Read N, compute `N! = 1 × 2 × 3 × … × N`, print it.

**In pseudocode:**
```
fact = 1
i    = 1
N    = read from user

while (i <= N):
    fact = fact * i
    i    = i + 1

print fact
```

**Notice**: The loop structure is *identical* to `first_n.asm`. Only the body changes (`mul` instead of `add`, accumulator starts at 1 not 0).

```asm
.data
msg1:   .asciiz "Enter a number: "
msg2:   .asciiz "The factorial is: "

.text
.globl main
main:
    # Print prompt
    li $v0, 4
    la $a0, msg1
    syscall

    # Read N
    li $v0, 5
    syscall
    move $t0, $v0       # $t0 = N  (cleaner than sw/lw)

    # Setup: fact = 1, i = 1
    li $t1, 1           # $t1 = fact = 1  (must start at 1, not 0!)
    li $t2, 1           # $t2 = i    = 1

loop:                   # top of loop
    bgt $t2, $t0, over  # if i > N, exit
    mul $t1, $t1, $t2   # fact = fact * i
    addi $t2, $t2, 1    # i = i + 1
    j loop              # go back

over:
    # Print "The factorial is: "
    li $v0, 4
    la $a0, msg2
    syscall

    # Print the result
    li $v0, 1
    move $a0, $t1       # fact is in $t1
    syscall

    # Exit
    li $v0, 10
    syscall

.end main
```

---

## 10. The Loop Side-by-Side

Both looping programs use *the same skeleton*. Look at them together:

| | `first_n.asm` | `factorial.asm` |
|---|---|---|
| Accumulator starts at | `0` (sum) | `1` (fact) — **never 0 for multiplication!** |
| Counter starts at | `1` | `1` |
| Loop body | `add $t0, $t0, $t1` | `mul $t1, $t1, $t2` |
| Exit condition | `bgt $t1, $t2, over` | `bgt $t2, $t0, over` |
| Labels used | `next`, `over` | `loop`, `over` |

---

## 11. How to Write a MIPS Program from Scratch (Your Checklist)

Follow this order every time:

```
1.  Write the pseudocode first (English / C-style)
2.  Identify your strings → put them in .data as .asciiz
3.  Identify persistent variables (optional) → .data as .word
    OR just use $t registers — usually simpler
4.  Write .text / .globl main / main:
5.  Print prompts and read inputs using syscalls
6.  After every read (syscall 5), immediately move $v0 to a $t register
7.  Initialize your loop variables (accumulator, counter)
8.  Write the loop:
        label_top:
            bgt / blt / beq ...  exit_label    (exit condition)
            ... body ...                        (do the work)
            addi counter, counter, 1            (increment)
            j label_top                         (go back)
        exit_label:
9.  Print the result (syscall 4 for string, then syscall 1 for integer)
10. li $v0, 10 / syscall to exit
```

---

## 12. Quick Reference Card

```
SYSCALLS
  li $v0, 1  ->  print integer  (arg in $a0)
  li $v0, 4  ->  print string   (arg in $a0 = address)
  li $v0, 5  ->  read integer   (result in $v0)
  li $v0, 10 ->  exit

DATA MOVES
  li   $t0, 5        # $t0 = 5  (immediate constant)
  la   $a0, label    # $a0 = address of label
  move $t0, $v0      # $t0 = $v0
  lw   $t0, label    # $t0 = memory[label]
  sw   $t0, label    # memory[label] = $t0

ARITHMETIC
  add  $t2, $t0, $t1   # $t2 = $t0 + $t1
  addi $t1, $t1, 1     # $t1 = $t1 + 1
  sub  $t2, $t0, $t1   # $t2 = $t0 - $t1
  mul  $t1, $t1, $t2   # $t1 = $t1 * $t2

BRANCHES & JUMPS
  j    label           # always jump
  beq  $a, $b, label   # jump if $a == $b
  bne  $a, $b, label   # jump if $a != $b
  bgt  $a, $b, label   # jump if $a >  $b
  blt  $a, $b, label   # jump if $a <  $b
  bge  $a, $b, label   # jump if $a >= $b
  ble  $a, $b, label   # jump if $a <= $b
```

---

## 13. Try It Yourself — Practice Exercises

Now try writing these from scratch *without looking at the files*:

1. **Warmup**: Write `sum.asm` from memory. Two inputs, add, print.
2. **Loop**: Write a program that reads N and prints the sum of the first N *even* numbers: `2 + 4 + 6 + … + 2N`.
3. **Challenge**: Write a program that reads N and prints all numbers from N down to 1.

For each one:
- Write the pseudocode first
- Fill in the checklist from §11
- Write the MIPS code

---

*You already understand `sum.asm`. The only new concept in the other two programs is the loop pattern from §6. Once that clicks, the rest is just filling in different arithmetic in the body.*
