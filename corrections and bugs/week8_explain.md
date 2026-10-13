# Week 8 — Code Explanations

Week 8 covers procedures: four arithmetic procedures called from `main`,
linear search written as a procedure, and the nth Fibonacci term using a
recursive procedure. All three programs use the same two new instructions,
`jal` (call) and `jr $ra` (return). This file explains the logic of the three
programs; they were written fresh this week and tested, so there were no bugs
to correct.

**The procedure rules used in all three programs:**

- `jal label` jumps to `label` **and** stores the address of the next
  instruction in `$ra`. `jr $ra` jumps back to that address. A plain `j`
  cannot be used for a call because it does not remember where to come back
  to.
- Arguments are passed in `$a0`–`$a3`, and results come back in `$v0` /
  `$v1`.
- `$t` registers may be overwritten by a procedure; `$s` registers must hold
  the same value after a call as before it.
- The procedures are written **after** the exit syscall of `main`. If `main`
  did not exit first, execution would fall through into the first procedure
  and run it without being called.

---

## 1. `arithmetic.asm` — sum, difference, product and quotient procedures

```asm
    .data
num1:           .asciiz "Enter the first number (x): "
num2:           .asciiz "Enter the second number (y): "
sum_msg:        .asciiz "Sum (x + y) = "
diff_msg:       .asciiz "\nDifference (x - y) = "
prod_msg:       .asciiz "\nProduct (x * y) = "
quot_msg:       .asciiz "\nQuotient (x / y) = "

    .text
main:           li $v0, 4
                la $a0, num1
                syscall                # print "Enter the first number (x): "

                li $v0, 5
                syscall                # read integer -> $v0
                move $s0, $v0          # $s0 = x

                li $v0, 4
                la $a0, num2
                syscall                # print "Enter the second number (y): "

                li $v0, 5
                syscall                # read integer -> $v0
                move $s1, $v0          # $s1 = y

                move $a0, $s0          # first argument  = x
                move $a1, $s1          # second argument = y
                jal sum                # call sum, result comes back in $v0
                move $t0, $v0          # save the result before printing

                li $v0, 4
                la $a0, sum_msg
                syscall                # print "Sum (x + y) = "

                li $v0, 1
                move $a0, $t0
                syscall                # print the sum

                move $a0, $s0          # arguments must be loaded again
                move $a1, $s1
                jal difference
                move $t0, $v0

                li $v0, 4
                la $a0, diff_msg
                syscall                # print "Difference (x - y) = "

                li $v0, 1
                move $a0, $t0
                syscall                # print the difference

                move $a0, $s0
                move $a1, $s1
                jal product
                move $t0, $v0

                li $v0, 4
                la $a0, prod_msg
                syscall                # print "Product (x * y) = "

                li $v0, 1
                move $a0, $t0
                syscall                # print the product

                move $a0, $s0
                move $a1, $s1
                jal quotient
                move $t0, $v0

                li $v0, 4
                la $a0, quot_msg
                syscall                # print "Quotient (x / y) = "

                li $v0, 1
                move $a0, $t0
                syscall                # print the quotient

                li $v0, 10
                syscall                # exit

sum:            add $v0, $a0, $a1      # $v0 = x + y
                jr $ra                 # return to main

difference:     sub $v0, $a0, $a1      # $v0 = x - y
                jr $ra

product:        mul $v0, $a0, $a1      # $v0 = x * y
                jr $ra

quotient:       div $a0, $a1           # LO = x / y, HI = x % y
                mflo $v0               # $v0 = quotient
                jr $ra
```

Expected output for `x = 20`, `y = 6`:

```
Sum (x + y) = 26
Difference (x - y) = 14
Product (x * y) = 120
Quotient (x / y) = 3
```

**Pattern:** "load arguments, call, save the result, print." The same four
steps are repeated once for each procedure. `main` does no arithmetic itself;
it only reads the inputs, passes them on, and displays what comes back.

**Points to note:**

- `x` and `y` are kept in `$s0` / `$s1`, not in `$a0` / `$a1`. Printing uses
  `$a0` (`la $a0, sum_msg`, `move $a0, $t0`), so the value of `x` in `$a0` is
  destroyed after the first result is printed. That is why `move $a0, $s0` /
  `move $a1, $s1` is repeated before every `jal`.
- `move $t0, $v0` straight after each `jal` is essential. The very next
  instruction is `li $v0, 4` for the print-string syscall, which overwrites
  the result. Without the `move`, the program would print `4` as every
  answer.
- These are **leaf procedures** (they do not call any other procedure), so
  `$ra` is never overwritten and nothing has to be saved on the stack.
- The order of the arguments matters for `difference` and `quotient`:
  `sub $v0, $a0, $a1` is `x - y`, not `y - x`.
- `quotient` returns only the integer quotient (`mflo`). The remainder is in
  `HI` and is ignored, so `20 / 6` gives `3`. This is the same `div` / `mflo`
  pair used in `sum_of_digits.asm` in Week 3.
- There is no check for `y = 0`. Division by zero does not stop the program;
  it just prints a meaningless quotient.
- The message labels are named `sum_msg`, `diff_msg` etc. because `sum`,
  `difference`, `product` and `quotient` are already used as the procedure
  names — a label name can only be defined once in a file (same reason as
  `pal` / `pal1` in Week 7).

---

## 2. `linear_search.asm` — linear search using a procedure

```asm
    .data
array:          .word 9, 10, 11, 12, 13, 14, 15, 16, 17, 18
num:            .asciiz "Enter number to be found: "
found:          .asciiz "The number is found at index "
not_found:      .asciiz "The number is not found."

    .text
main:           li $v0, 4
                la $a0, num
                syscall                # print "Enter number to be found: "

                li $v0, 5
                syscall                # read integer -> $v0
                move $a2, $v0          # $a2 = number to be found

                la $a0, array          # $a0 = address of the array
                li $a1, 10             # $a1 = total number of elements
                jal search             # returns $v0 = 0/1, $v1 = index

                beqz $v0, not_found1   # $v0 = 0 -> not found
                move $t0, $v1          # save the index before printing

                li $v0, 4
                la $a0, found
                syscall                # print "The number is found at index "

                li $v0, 1
                move $a0, $t0
                syscall                # print the index

                j exit                 # must skip past not_found1

not_found1:     li $v0, 4
                la $a0, not_found
                syscall                # print "The number is not found."

exit:           li $v0, 10
                syscall                # exit

search:         li $t0, 0              # $t0 = index i, starts at 0

loop:           beq $t0, $a1, fail     # i == number of elements -> not found
                lw $t1, 0($a0)         # $t1 = array[i]
                beq $t1, $a2, success  # match -> found
                addi $t0, $t0, 1       # i++
                addi $a0, $a0, 4       # advance pointer to the next element
                j loop

success:        li $v0, 1              # return value 1 = found
                move $v1, $t0          # second return value = index
                jr $ra

fail:           li $v0, 0              # return value 0 = not found
                jr $ra
```

Expected output for the given data: entering `13` prints
`The number is found at index 4`, and entering `99` prints
`The number is not found.`

**Pattern:** the search loop is exactly the one from Week 5's
`linear_search.asm`. The only change is *where the values live*: the array
address, the length and the key now arrive in `$a0`, `$a1` and `$a2` instead
of being loaded inside the loop's own code, and the answer goes back in
`$v0` / `$v1` instead of jumping straight to a print block.

| Register | Direction | Meaning                                  |
|----------|-----------|------------------------------------------|
| `$a0`    | in        | address of the array                     |
| `$a1`    | in        | total number of elements                 |
| `$a2`    | in        | number to be found                       |
| `$v0`    | out       | `0` = not found, `1` = found             |
| `$v1`    | out       | index of the element (only when `$v0 = 1`) |

**Points to note:**

- The question lists two arguments (array address and number of elements),
  but the procedure also needs the number being searched for, so it is passed
  as a third argument in `$a2`.
- Two values are returned because one is not enough: `$v0` only says
  *whether* the number was found, and `$v1` says *where*. Index `0` is a
  valid position, so the index alone could not be used to mean "not found".
- `$v1` is only set on the `success` path. When `$v0` is `0`, `$v1` holds
  whatever was in it before, so `main` checks `$v0` first and never reads
  `$v1` in the not-found case.
- The procedure does not print anything. It only searches and reports back;
  `main` decides what to display. This is what makes it reusable — the same
  `search` works for any array by changing `$a0` and `$a1`.
- `search` moves `$a0` forward as it walks the array, so after the call `$a0`
  no longer points to the start of the array. That is allowed (argument
  registers are not preserved), and `main` does not use it again.
- `loop`, `success` and `fail` are ordinary labels inside the procedure. A
  procedure is not a closed block in MIPS — it is just the code between its
  label and its `jr $ra`, and it may have more than one `jr $ra`.
- `j exit` after the found block is still needed, for the same reason as in
  Week 5.

---

## 3. `fibonacci.asm` — nth Fibonacci term using a recursive procedure

```asm
    .data
msg:            .asciiz "Enter n: "
result:         .asciiz "The nth Fibonacci term is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall                # print "Enter n: "

                li $v0, 5
                syscall                # read integer -> $v0
                move $a0, $v0          # $a0 = n

                jal fib                # $v0 = fib(n)
                move $t0, $v0          # save the result before printing

                li $v0, 4
                la $a0, result
                syscall                # print "The nth Fibonacci term is: "

                li $v0, 1
                move $a0, $t0
                syscall                # print fib(n)

                li $v0, 10
                syscall                # exit

fib:            addi $sp, $sp, -12     # push: make space for 3 words
                sw $ra, 8($sp)         # save the return address
                sw $s0, 4($sp)         # save the caller's $s0
                sw $s1, 0($sp)         # save the caller's $s1

                move $s0, $a0          # $s0 = n
                li $t0, 1
                ble $s0, $t0, base     # n <= 1 -> base case

                addi $a0, $s0, -1      # argument = n - 1
                jal fib                # $v0 = fib(n - 1)
                move $s1, $v0          # $s1 = fib(n - 1), kept across the next call

                addi $a0, $s0, -2      # argument = n - 2
                jal fib                # $v0 = fib(n - 2)
                add $v0, $s1, $v0      # $v0 = fib(n - 1) + fib(n - 2)

                j fib_end              # must skip past base

base:           move $v0, $s0          # fib(0) = 0, fib(1) = 1 -> return n itself

fib_end:        lw $s1, 0($sp)         # restore the caller's $s1
                lw $s0, 4($sp)         # restore the caller's $s0
                lw $ra, 8($sp)         # restore the return address
                addi $sp, $sp, 12      # pop: give the 3 words back
                jr $ra
```

Expected output for `n = 10`: `The nth Fibonacci term is: 55`.

**Pattern:** "save, recurse, restore." The procedure is a direct translation
of the definition `fib(0) = 0`, `fib(1) = 1`,
`fib(n) = fib(n - 1) + fib(n - 2)`, so it calls itself twice. Because of
that, three values must survive a call and are pushed on the stack at the
start of every call and popped at the end:

| Saved | Why it has to be saved                                              |
|-------|---------------------------------------------------------------------|
| `$ra` | the `jal fib` inside `fib` overwrites it with a new return address  |
| `$s0` | holds `n`, still needed after the first call to compute `n - 2`     |
| `$s1` | holds `fib(n - 1)`, still needed after the second call for the `add` |

Each call gets its own 12 bytes of stack (its "stack frame"), so every level
of the recursion has its own private copy of `n`, `fib(n - 1)` and its return
address.

Calls made for `n = 4` (each line returns the value on the right):

```
fib(4)                          = 3
├── fib(3)                      = 2
│   ├── fib(2)                  = 1
│   │   ├── fib(1)              = 1   (base case)
│   │   └── fib(0)              = 0   (base case)
│   └── fib(1)                  = 1   (base case)
└── fib(2)                      = 1
    ├── fib(1)                  = 1   (base case)
    └── fib(0)                  = 0   (base case)
```

**Points to note:**

- Saving `$ra` is the most important line. Without `sw $ra, 8($sp)`, the
  first inner `jal fib` replaces the address that leads back to `main`, and
  the procedure can never return there — the program loops forever.
- The stack grows **downwards**: `addi $sp, $sp, -12` reserves space and
  `addi $sp, $sp, 12` releases it. Every push must be matched by a pop of the
  same size, on every path out of the procedure. That is why both the base
  case and the recursive case go through the single `fib_end` block instead
  of having their own `jr $ra`.
- `n` and `fib(n - 1)` are kept in `$s` registers rather than `$t` registers
  because they are needed *after* a `jal`. The inner call uses `$t0` itself
  (`li $t0, 1`), so anything left in a `$t` register would be lost.
- `fib` restores `$s0` and `$s1` before returning because it is using
  registers that belong to its caller. This is the same rule `main` relies on
  in `arithmetic.asm`, seen from the other side.
- The base case returns `n` itself (`move $v0, $s0`), which covers both
  `fib(0) = 0` and `fib(1) = 1` with one instruction.
- `j fib_end` after the `add` is needed so that the result is not overwritten
  by `move $v0, $s0` in `base`.
- The terms are numbered from 0, so the series is `0, 1, 1, 2, 3, 5, 8, ...`
  and `n = 10` gives `55`.
- The recursion repeats work (in the tree above `fib(2)` is computed twice),
  so the number of calls grows very quickly — `n = 20` is instant, but values
  above about 30 are noticeably slow. `fib(46) = 1836311903` is the largest
  term that fits in a 32-bit register (`fib(47)` would overflow at the
  `add`), but the simulator would take far too long to get anywhere near
  that.
