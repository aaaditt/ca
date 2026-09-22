# Week 2 — Code Explanations

Week 2 has three exercises, each with an original file and a tidied `_clean`
duplicate (same logic, fewer comments): `sum.asm`, `first_n.asm`,
`factorial.asm`. This file explains the logic; it does not modify any code.

---

## 1. `sum.asm` — add two user-entered numbers

```asm
.data
msg1: .asciiz "Enter the first number: "
msg2: .asciiz "Enter the second number: "
res: .asciiz "the result is: "

.text
main:   li $v0,4
        la $a0,msg1
        syscall            # print "Enter the first number: "

        li,$v0,5
        syscall            # read integer -> $v0
        move $t0,$v0       # $t0 = first number

        li $v0,4
        la $a0,msg2
        syscall            # print "Enter the second number: "

        li,$v0,5
        syscall            # read integer -> $v0
        move $t1,$v0       # $t1 = second number

        add $t2,$t0,$t1    # $t2 = first + second

        li,$v0,4
        la $a0,res
        syscall            # print "the result is: "

        li,$v0,1
        move $a0,$t2
        syscall            # print $t2 (the sum)

        li,$v0,10
        syscall            # exit
```

**Flow:** prompt → read int → save in `$t0`, prompt → read int → save in
`$t1`, `add` the two, print a label, print the sum, exit. This is the
simplest possible "read two numbers, combine them, print the result"
skeleton — every later program in the course (factorial, sum of N, arrays)
is a variation on this same prompt/read/compute/print shape.

**Note (not fixed, since only Week 5 was in scope for corrections):** several
lines write `li,$v0,5` with a comma directly after the mnemonic instead of
`li $v0, 5`. MARS's tokenizer treats commas as pure separators (like
whitespace), so this happens to still assemble correctly here — but it is
non-standard formatting and would be worth cleaning up for readability and to
avoid confusion in editors/linters that expect `mnemonic operand, operand`.

---

## 2. `first_n.asm` — sum of the first N natural numbers

```asm
.data
msg1:   .asciiz "Enter N: "
msg2:   .asciiz "Sum = "
no:     .word 0            # memory slot for N
sum:    .word 0             # memory slot for the running total

.text
.globl main
main:
    li $v0, 4
    la $a0, msg1
    syscall                # print "Enter N: "

    li $v0, 5
    syscall                # read integer -> $v0
    sw $v0, no             # store N in memory (no = N)

    li $t0, 0              # $t0 = sum = 0
    li $t1, 1              # $t1 = i = 1
    lw $t2, no             # $t2 = N (loaded back from memory)

next:
    bgt $t1, $t2, over     # if i > N, loop is done -> exit
    add $t0, $t0, $t1      # sum += i
    addi $t1, $t1, 1       # i++
    j next                 # repeat

over:
    sw $t0, sum            # save the final sum to memory

    li $v0, 4
    la $a0, msg2
    syscall                # print "Sum = "

    li $v0, 1
    lw $a0, sum            # load the sum back from memory to print it
    syscall                # print the sum

    li $v0, 10
    syscall                # exit
```

**Flow:** this is the "accumulator loop" pattern — `$t0` starts at 0 and
gets `i` added to it every iteration, while `$t1` (the counter `i`) climbs
from 1 up to `N`. `bgt $t1, $t2, over` is the loop's exit test, checked at
the *top* of the loop (a "while" shape, not a "do-while" shape) — this
matters because if `N` were 0, the loop body would never execute and the sum
would correctly stay 0.

**Why store `N` and `sum` in `.data` memory (`no`, `sum`) instead of just
keeping everything in registers?** It isn't strictly necessary here — the
whole computation could live in registers alone — but it demonstrates
`sw`/`lw` (store word / load word), which is the mechanism you need once a
program has more variables than there are spare registers, or needs values
to persist across function calls.

---

## 3. `factorial.asm` — N!

```asm
.data
msg1:   .asciiz "Enter a number: "
msg2:   .asciiz "The factorial is: "

.text
.globl main
main:
    li $v0, 4
    la $a0, msg1
    syscall                # print "Enter a number: "

    li $v0, 5
    syscall                # read integer -> $v0
    move $t0, $v0          # $t0 = N

    li $t1, 1              # $t1 = fact = 1  (NOT 0 — multiplying by 0 would zero everything out)
    li $t2, 1              # $t2 = i = 1

loop:
    bgt $t2, $t0, over     # if i > N, loop done -> exit
    mul $t1, $t1, $t2      # fact = fact * i
    addi $t2, $t2, 1       # i++
    j loop                 # repeat

over:
    li $v0, 4
    la $a0, msg2
    syscall                # print "The factorial is: "

    li $v0, 1
    move $a0, $t1          # $t1 holds the final factorial value
    syscall                # print it

    li $v0, 10
    syscall                # exit
```

**Flow:** identical skeleton to `first_n.asm`, but the accumulator (`$t1`)
starts at **1** and uses `mul` instead of `add` — this is the single most
important detail to notice when moving from "sum of 1..N" to "product of
1..N" (a factorial): an additive accumulator must start at the identity
element for addition (0), while a multiplicative accumulator must start at
the identity element for multiplication (1). Starting `fact` at 0 would make
every multiplication collapse to 0.

**Edge case worth knowing:** for `N = 0` or `N = 1`, `bgt $t2, $t0, over`
is checked with `$t2 = 1`. If `N = 0`, `1 > 0` is true immediately, so the
loop body never runs and `fact` stays `1` — which is the mathematically
correct answer, `0! = 1`.
