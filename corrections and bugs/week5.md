# Week 5 — Bugs, Corrections, and Code Explanations

Week 5 covers three MIPS array programs:

1. `largest_element_array.asm` — find the largest element in an array
2. `linear_search.asm` — search an array for a value entered by the user
3. `sum_of_array.asm` — add two arrays element-wise into a third array

All three files have been fixed in place in `week5/`. This document lists exactly
what was wrong, why it mattered, and then walks through how each corrected
program works.

---

## 1. `largest_element_array.asm`

### Bug found: curly ("smart") quotes instead of straight quotes

```asm
result: .asciiz “The largest element is: ”
```

`“` and `”` (Unicode `U+201C`/`U+201D`, the curly quotes a word processor
auto-inserts) are **not** the ASCII `"` character MIPS/MARS string literals
require. The assembler's tokenizer only recognizes `"..."` as the start/end of
a string. When it hits `“`, it doesn't see a string delimiter at all — it sees
a stray, unrecognized character sitting where an operand should be, and the
line fails to assemble (`.data` directive error / illegal operand, depending
on the assembler). This is a **syntax error that prevents the program from
assembling at all**, not a logic bug — nothing in this file runs until it's
fixed.

**Fix applied:**

```asm
result: .asciiz "The largest element is: "
```

This is a classic "typed the code in a rich-text editor / Word / a chat
window that auto-formats quotes" mistake — worth remembering because it looks
identical to the correct code at a glance.

### Logic check

The find-max algorithm itself was already correct:

- `$t3` is seeded with `array[0]` *before* the loop starts, and `$t0` is
  advanced past it, so the loop only needs to compare the remaining 9
  elements (`$t2` counts from 1 to 9).
- Every element `array[i]` is compared against the current max (`bgt $t4,
  $t3, largest`), and the max is updated when a bigger value is found.
- The loop terminates correctly when the counter reaches the array length
  (`beq $t2, $t1, exit`).

No changes were needed to the algorithm — only the string literal.

### Explanation of the corrected program

```asm
.data
result: .asciiz "The largest element is: "
array: .word 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
.text

main:   la $t0, array      # $t0 = pointer to the array, starts at array[0]
        li $t1, 10         # $t1 = array length (10 elements)
        li $t2, 1          # $t2 = loop index i, starts at 1 (element 0 is already "seen")
        lw $t3, 0($t0)     # $t3 = array[0], our initial "current max"
        addi $t0, $t0, 4   # advance pointer to array[1] (each word = 4 bytes)

loop:   beq $t2, $t1, exit     # if i == length, we've checked every element -> done
        lw $t4, 0($t0)         # $t4 = array[i]
        bgt $t4, $t3, largest  # if array[i] > current max, go update the max
        addi $t2, $t2, 1       # otherwise: i++
        addi $t0, $t0, 4       # advance pointer to next element
        j loop                 # repeat

largest: move $t3, $t4     # new max found: current max = array[i]
        addi $t2, $t2, 1   # i++ (same bookkeeping as the non-branch path)
        addi $t0, $t0, 4   # advance pointer
        j loop

exit:   li $v0, 4          # syscall 4 = print string
        la $a0, result
        syscall             # prints "The largest element is: "

        li $v0, 1          # syscall 1 = print integer
        move $a0, $t3      # the argument is the final max value
        syscall

        li $v0, 10         # syscall 10 = exit program
        syscall
```

**Key idea:** this is the standard "running maximum" pattern — keep one
register holding the best value seen so far, walk the array once, and replace
it whenever you find something bigger. `$t0` acting as a moving pointer
(`la` once, then `addi $t0, $t0, 4` each step) instead of re-computing
`array[i]` from scratch each time is the idiomatic MIPS way to walk an array,
since MIPS has no `array[i]` syntax — only "load word from this address."

---

## 2. `linear_search.asm`

### Bug 1: curly quotes (same defect as above, three occurrences)

```asm
num:        .asciiz “Enter number to be found: ”
found:      .asciiz “The number is found at ”
not_found:  .asciiz “The number is not found.”
```

Same root cause as `largest_element_array.asm` — these are not valid MIPS
string literals and stop the file from assembling.

**Fix applied:** replaced all three with straight double quotes:

```asm
num:        .asciiz "Enter number to be found: "
found:      .asciiz "The number is found at "
not_found:  .asciiz "The number is not found."
```

### Bug 2: comments written without `#` (invalid syntax, not just style)

```asm
la $t1, array (loads address of the array) 
li $t2, 10 (loading the length of the array) 
li $t3, 0 (i = 0) 
```

In MIPS assembly, a comment **must** start with `#` — anything from `#` to
the end of the line is ignored. Text in plain parentheses is not a comment at
all as far as the assembler is concerned; it's parsed as if it were more
operands on the instruction. `la $t1, array (loads address of the array)`
assembles as `la` with a garbage second "operand" (`(loads`), which is a
**syntax error** — the instruction has too many/invalid operands and will
not assemble.

**Fix applied:**

```asm
la $t1, array   # loads address of the array
li $t2, 10      # loading the length of the array
li $t3, 0       # i = 0
```

### Logic check

The search logic was already correct: linear scan comparing each element to
the target, printing the index if found, printing "not found" and falling
through to `exit` otherwise. No algorithm changes were required.

### Explanation of the corrected program

```asm
.data
num:        .asciiz "Enter number to be found: "
found:      .asciiz "The number is found at "
not_found:  .asciiz "The number is not found."
array:      .word 9, 10, 11, 12, 13, 14, 15, 16, 17, 18

.text
main:       li $v0,4
            la $a0,num
            syscall            # print "Enter number to be found: "

            li $v0,5
            syscall            # read an integer -> $v0
            move $t0,$v0       # $t0 = target value to search for

            la $t1, array      # $t1 = pointer to array[0]
            li $t2, 10         # $t2 = array length
            li $t3, 0          # $t3 = index i, starts at 0

loop:   beq $t3, $t2, not_found1  # if i == length, we've run out of elements -> not found
        lw $t4, 0($t1)            # $t4 = array[i]
        beq $t4, $t0, found1      # if array[i] == target, we found it
        addi $t3, $t3, 1          # i++
        addi $t1, $t1, 4          # advance pointer to next element
        j loop

found1: li $v0, 4
        la $a0, found
        syscall                # print "The number is found at "

        li $v0,1
        move $a0,$t3           # print the index where it was found
        syscall

        j exit                 # skip the "not found" branch

not_found1: li $v0,4
            la $a0,not_found
            syscall            # print "The number is not found."
                               # (falls through into exit — no jump needed)

exit:   li $v0, 10
        syscall                # exit program
```

**Key idea:** this is a textbook linear search — `$t3` doubles as both the
loop counter *and* the answer (the index), so when a match is found we can
print `$t3` directly without any extra bookkeeping. The `j exit` after
`found1` is necessary so that a successful search doesn't also fall through
and print the "not found" message; `not_found1` needs no such jump because
`exit:` is the very next label in program order.

---

## 3. `sum_of_array.asm`

### Issue found: redundant dead-code instruction (not a syntax error, but worth removing)

```asm
lw $t6, 0($t1)
lw $t7, 0($t2)
li $t0, 0            #sum counter 
add $t0, $t6, $t7
```

This file already used correct straight quotes and had no syntax errors — it
would assemble and run fine as-is. However, `li $t0, 0` resets `$t0` to zero
immediately before `add $t0, $t6, $t7` overwrites it anyway on the very next
line. The `li` has no effect on the program's behavior; it's leftover code
(possibly copied from a version that accumulated a running total, where
resetting a counter would have mattered). It doesn't break anything, but it's
dead code that makes a reader wonder if `$t0` is supposed to persist between
iterations when it isn't.

**Fix applied:** removed the redundant `li $t0, 0` line and merged the
comment onto the `add`:

```asm
lw $t6, 0($t1)
lw $t7, 0($t2)
add $t0, $t6, $t7    #sum = array1[i] + array2[i]
```

### Explanation of the corrected program

```asm
.data
array1: .word 11, 13, 15, 17, 19
array2: .word 1, 3, 5, 7, 9
array3: .word 0, 0, 0, 0, 0
result: .asciiz "The resultant array is: "
space: .asciiz " "
.text

main:   la $t1, array1     # $t1 = pointer into array1
        la $t2, array2     # $t2 = pointer into array2
        la $t3, array3     # $t3 = pointer into array3 (where results are written)

        li $t4,0           # $t4 = loop index i
        li $t5,5           # $t5 = array length (5 elements)

loop:   beq $t4, $t5, end       # if i == length, all elements summed -> done
        lw $t6, 0($t1)          # $t6 = array1[i]
        lw $t7, 0($t2)          # $t7 = array2[i]
        add $t0, $t6, $t7       # $t0 = array1[i] + array2[i]
        sw $t0, 0($t3)          # array3[i] = $t0
        addi $t1, $t1, 4        # advance pointer into array1
        addi $t2, $t2, 4        # advance pointer into array2
        addi $t3, $t3, 4        # advance pointer into array3
        addi $t4, $t4, 1        # i++
        j loop

end:    li $v0, 4
        la $a0, result
        syscall                 # print "The resultant array is: "

        la $t3, array3          # reset pointer back to the start of array3
        li $t4, 0               # reset index for the print loop

p_loop: beq $t4, $t5, exit      # if i == length, done printing
        li $v0,4
        la $a0,space
        syscall                 # print a separating space

        li $v0,1
        lw $a0,0($t3)           # load array3[i] as the value to print
        syscall                 # print it

        addi $t3, $t3, 4        # advance pointer
        addi $t4, $t4, 1        # i++
        j p_loop

exit:   li $v0, 10
        syscall                 # exit program
```

Expected output for the given data: `12 16 20 24 28` (11+1, 13+3, 15+5,
17+7, 19+9).

**Key idea:** this program uses **three independent pointers** (`$t1`,
`$t2`, `$t3`) walking three arrays in lockstep, which is the natural MIPS
translation of `array3[i] = array1[i] + array2[i]`. Note the second loop
(`p_loop`) has to re-`la` and re-zero its counter — pointers and counters are
just registers, so once `$t3`/`$t4` have been driven to the end of the array
by the first loop, they must be explicitly reset before being reused to walk
the array a second time for printing.

---

## Summary table

| File | Bug | Type | Fix |
|---|---|---|---|
| `largest_element_array.asm` | Curly quotes `“…”` in `.asciiz` | Fatal syntax error (won't assemble) | Replaced with straight quotes `"…"` |
| `linear_search.asm` | Curly quotes `“…”` in three `.asciiz` strings | Fatal syntax error (won't assemble) | Replaced with straight quotes `"…"` |
| `linear_search.asm` | Comments written as `(text)` instead of `# text` | Syntax error (invalid extra operands) | Converted to proper `#` comments |
| `sum_of_array.asm` | `li $t0, 0` immediately overwritten by `add` on next line | Dead code / redundant instruction (not a crash, just clutter) | Removed the redundant line |

All three programs now assemble and run correctly in MARS/SPIM.
