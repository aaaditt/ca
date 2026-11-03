# Week 9 — Bugs, Corrections, and Code Explanations

Week 9 continues with procedures, now all **recursive**:

1. `power.asm` — `a` to the power `n` using recursion
2. `binary_search.asm` — recursive binary search on a sorted array
3. `sum_natural.asm` — sum of the first `n` natural numbers using recursion

The lab gave C-style code for each procedure (`Lab8.txt` on the board) and
asked for the MIPS assembly (MALP). That C code has several bugs. Part A lists
them and how the MIPS versions fix them. Part B explains each program.

All three programs were tested before being committed:

| Program | Inputs tried | Output |
|---------|--------------|--------|
| `power.asm` | `2^10`, `3^0`, `5^1`, `(-2)^3`, `7^3` | `1024`, `1`, `5`, `-8`, `343` |
| `sum_natural.asm` | `n = 10, 1, 0, 100` | `55`, `1`, `0`, `5050` |
| `binary_search.asm` | each of the 10 array values, plus `1`, `50`, `100` | right index for each value; "not found" for the 3 missing ones |

In every run `$sp` was back at its starting value when the program exited, so
every push had a matching pop.

---

# Part A — Bugs in the code given on the board

## 1. Power

```c
int power (int a, int n)
{
    if (n == 1)
        return a;
    return a * power(n - 1);      // BUG
}
main()
{
    pow = power(a, n);            // a, n, pow never declared / read
}
```

| # | Bug | What goes wrong | Fix in `power.asm` |
|---|-----|-----------------|--------------------|
| 1 | `power(n - 1)` passes **one** argument, but `power` takes two (`a`, `n`). | In C this is a compile error. In MIPS it means `$a1` gets `n - 1` but nobody makes sure `$a0` still holds `a`. | The recursive call is `power(a, n - 1)`: `$a0` is left as `a`, and only `$a1` is decremented. |
| 2 | The base case is `n == 1`. | `power(a, 0)` never hits `n == 1`. It goes 0, -1, -2, … forever until the stack runs out. Also, `a^0 = 1` is a valid answer the code can never give. | The base case is `n <= 0 → return 1` (`blez`). `a^1` is then worked out as `a * a^0 = a * 1`, which is correct, so nothing is lost. |
| 3 | `main` uses `a`, `n` and `pow` without declaring or reading them. | Compile error, and there is no input. | `main` reads `a` and `n` with syscall 5 and prints the result. |
| 4 | Title says "umber". | Typo only. | — |

`n <= 0` instead of `n == 0` also means a negative `n` stops straight away
and returns 1 instead of recursing forever. (A real negative power gives a
fraction, which an integer program cannot hold anyway.)

## 2. Recursive binary search

```c
int bin_search(int A[], int data, int lo, int hi)
{
    int mid;
    if (lo > hi) return -1                                   // missing ;
    mid = (lo + high)/2;                                     // BUG: high
    if ( data == A[mid]) return mid                          // missing ;
    if ( data < A[mid]) return bin_search(A, data, lo, mid-1)   // missing ;
    return bin_search(A, data, mid, high+1)                  // BUG: mid, high+1
}
```

| # | Bug | What goes wrong | Fix in `binary_search.asm` |
|---|-----|-----------------|----------------------------|
| 1 | `high` is used, but the parameter is called `hi`. | Compile error: `high` is undeclared. | `hi` is kept in `$a3` and used everywhere. |
| 2 | Four statements have no `;`. | Compile error. | — (not relevant in assembly) |
| 3 | **The right-half call is `bin_search(A, data, mid, high+1)`.** It should be `bin_search(A, data, mid + 1, hi)`. | This is the serious one — see below. | `lo = mid + 1`, `hi` unchanged: `addi $a2, $t0, 1`. |

**Why `mid, high+1` is wrong.** We only reach this line when
`data > A[mid]`, so `A[mid]` has already been checked and the answer is
strictly to the right of `mid`. The new range should be `mid+1 … hi`.

- **`lo = mid` instead of `mid + 1`:** `A[mid]` stays in the range, so the
  range may not get smaller. With 2 elements left (`lo = 6`, `hi = 7`),
  `mid = 6`, and the call is made with `lo = 6` again. The search goes round
  the same few ranges forever.
- **`hi + 1` instead of `hi`:** the range gets **bigger** every time it goes
  right. After a few steps `hi` is past the last element and the code reads
  memory after the array.

This was checked by running a copy of `binary_search.asm` with the board's
`mid, hi+1` line put back in:

| Search for | Correct version | Board version |
|------------|-----------------|---------------|
| `91` (present, last element) | index 9 | index 9 (works by luck) |
| `50` (not present, between 38 and 56) | not found | **never stops** — the ranges repeat `(6,7) → (6,8) → (6,6) → (6,7) → …` |
| `100` (bigger than everything) | not found | **never stops** — `hi` grows to 10, 11, 12, … past the end of the array |

In MARS each of the endless runs pushes a new stack frame on every call, so
they would end with a stack overflow / memory error.

Trace of the `50` case with the board's code (array
`2, 5, 8, 12, 16, 23, 38, 56, 72, 91`):

| lo | hi | mid | A[mid] | 50 vs A[mid] | next call (board) |
|----|----|-----|--------|--------------|-------------------|
| 0  | 9  | 4   | 16     | greater      | `(4, 10)` |
| 4  | 10 | 7   | 56     | smaller      | `(4, 6)` |
| 4  | 6  | 5   | 23     | greater      | `(5, 7)` |
| 5  | 7  | 6   | 38     | greater      | `(6, 8)` |
| 6  | 8  | 7   | 56     | smaller      | `(6, 6)` |
| 6  | 6  | 6   | 38     | greater      | `(6, 7)` |
| 6  | 7  | 6   | 38     | greater      | `(6, 8)` ← same as 3 rows up, loops forever |

With the fix, the row `lo = 6, hi = 6` goes to `(7, 6)`, `lo > hi`, and it
returns `-1`.

## 3. Sum of N natural numbers

Only the start of this one was on the board:

```c
int RSum(int n)
{
    if (n == 1)
        return n;
    ...
```

It is completed in the usual way: `return n + RSum(n - 1);`.

| # | Issue | What goes wrong | Fix in `sum_natural.asm` |
|---|-------|-----------------|--------------------------|
| 1 | Base case `n == 1` only. | `RSum(0)` goes 0, -1, -2, … and never stops (same problem as `power`). | The check is `n <= 1 → return n` (`ble`). `RSum(1) = 1` as before, and `RSum(0) = 0`, which is the correct empty sum. |

---

# Part B — Code explanations

**Rules for recursive procedures (same as `fib` in Week 8):**

- A procedure that calls another procedure (here, itself) **overwrites
  `$ra`** with its own `jal`. So `$ra` must be saved on the stack at the
  start and loaded back before `jr $ra`.
- Any value the procedure still needs **after** the inner call must be in an
  `$s` register (saved on the stack too) or on the stack. `$a` and `$t`
  registers may be changed by the inner call.
- Every path out of the procedure must pop exactly what it pushed.

How much each of the three procedures has to save:

| Procedure | Saved on the stack | Why |
|-----------|--------------------|-----|
| `power` | `$ra`, `$s0` (= `a`) | after the inner call it still needs `a` to work out `a * a^(n-1)` |
| `rsum` | `$ra`, `$s0` (= `n`) | after the inner call it still needs `n` to work out `n + RSum(n-1)` |
| `bin_search` | `$ra` only | after the inner call it does nothing except return the answer, so no value has to survive the call |

`fib` (Week 8) had to save 3 registers because it makes **two** calls and has
to hold the first answer while the second call runs. These procedures make
only one call each time, so they need less.

---

## 1. `power.asm` — a to the power n using recursion

```asm
    .data
msg_a:          .asciiz "Enter the base (a): "
msg_n:          .asciiz "Enter the power (n): "
result:         .asciiz "a to the power n is: "

    .text
main:           li $v0, 4
                la $a0, msg_a
                syscall                # print "Enter the base (a): "

                li $v0, 5
                syscall                # read a -> $v0
                move $t0, $v0          # $t0 = a (can't go in $a0 yet, the next print uses $a0)

                li $v0, 4
                la $a0, msg_n
                syscall                # print "Enter the power (n): "

                li $v0, 5
                syscall                # read n -> $v0
                move $a1, $v0          # $a1 = n

                move $a0, $t0          # $a0 = a
                jal power              # $v0 = power(a, n)
                move $t0, $v0          # save the result before printing

                li $v0, 4
                la $a0, result
                syscall                # print "a to the power n is: "

                li $v0, 1
                move $a0, $t0
                syscall                # print a^n

                li $v0, 10
                syscall                # exit

power:          addi $sp, $sp, -8      # push: space for 2 words
                sw $ra, 4($sp)         # save the return address
                sw $s0, 0($sp)         # save the caller's $s0

                move $s0, $a0          # $s0 = a
                blez $a1, base         # n <= 0 -> base case

                addi $a1, $a1, -1      # argument n - 1 ($a0 still holds a)
                jal power              # $v0 = a^(n - 1)
                mul $v0, $s0, $v0      # $v0 = a * a^(n - 1)

                j power_end            # skip past base

base:           li $v0, 1              # a^0 = 1

power_end:      lw $s0, 0($sp)         # restore the caller's $s0
                lw $ra, 4($sp)         # restore the return address
                addi $sp, $sp, 8       # pop
                jr $ra
```

Expected output for `a = 2, n = 10`: `a to the power n is: 1024`.

### The idea

```
a^0 = 1
a^n = a * a^(n - 1)        for n >= 1
```

So `2^3 = 2 * 2^2 = 2 * (2 * 2^1) = 2 * (2 * (2 * 2^0)) = 2 * 2 * 2 * 1 = 8`.

### The agreement between caller and `power`

| Register | Direction | Meaning |
|----------|-----------|---------|
| `$a0` | caller → `power` | `a` (the base) |
| `$a1` | caller → `power` | `n` (the power) |
| `$v0` | `power` → caller | `a^n` |

### Step by step

1. **`main` reading `a`.** `a` is first put in `$t0`, not `$a0`, because the
   next prompt is printed with `la $a0, msg_n`, which would overwrite it.
   Just before `jal`, `a` is moved into `$a0`.
2. **Push.** `power` saves `$ra` (its own `jal power` will overwrite it) and
   `$s0` (it is about to use `$s0`, and the caller's value must come back
   unchanged).
3. **`move $s0, $a0`.** `a` is needed again after the recursive call, for the
   `mul`. It is copied to `$s0` because `$a0` is an argument register and
   the inner call is allowed to change it.
4. **Base case.** `blez $a1, base` — if `n <= 0` the answer is 1.
5. **Recursive case.** Only `$a1` changes (`n - 1`); `$a0` already holds `a`,
   which is the same base for every call. After `jal power`, `$v0 = a^(n-1)`,
   and `mul $v0, $s0, $v0` gives `a^n`.
6. **Pop and return.** `$s0` and `$ra` are loaded back from the same offsets,
   `$sp` goes back up by 8, and `jr $ra` returns to the caller with the answer
   in `$v0`.

### Trace for `a = 2, n = 3`

| Call | `$a1` (n) on entry | What it does | Returns |
|------|--------------------|--------------|---------|
| `power(2, 3)` | 3 | push, `$s0 = 2`, calls `power(2, 2)` | `2 * 4 = 8` |
| `power(2, 2)` | 2 | push, `$s0 = 2`, calls `power(2, 1)` | `2 * 2 = 4` |
| `power(2, 1)` | 1 | push, `$s0 = 2`, calls `power(2, 0)` | `2 * 1 = 2` |
| `power(2, 0)` | 0 | push, base case | `1` |

The calls go down the table, and the answers come back up it: 1 → 2 → 4 → 8.
At the deepest point there are 4 frames (8 bytes each) on the stack.

### Common mistakes with this program

| Mistake | What goes wrong |
|---------|-----------------|
| Writing the board's `power(n - 1)` literally, e.g. putting `n - 1` in `$a0` | `$a0` (the base) is replaced by `n - 1`, so the next call multiplies by the wrong number. |
| Keeping `a` only in `$a0` and using `$a0` in the `mul` after the call | Works in this program only because no call happens to change `$a0`. By the register rules `$a0` is not saved across a call, so this is a hidden bug that shows up as soon as the procedure is changed. Keeping it in `$s0` is the safe way. |
| Base case `n == 1` (as on the board) | `n = 0` recurses forever. |
| Not saving `$ra` | After the innermost return, every `jr $ra` jumps back to the line after `jal power` inside `power`, never to `main`. |
| Using `mult` without `mflo` | `mult $s0, $v0` puts the result in `LO`, not in a register; either use `mul` (3 operands) or follow `mult` with `mflo $v0`. |

**Points to note:**

- `mul` keeps only the lower 32 bits, so large answers overflow silently
  (e.g. `2^31` prints as a negative number, `2^32` prints `0`).
- A negative base works: `(-2)^3 = -8` was tested.

---

## 2. `binary_search.asm` — recursive binary search

```asm
    .data
array:          .word 2, 5, 8, 12, 16, 23, 38, 56, 72, 91     # must be sorted
num:            .asciiz "Enter number to be found: "
found:          .asciiz "The number is found at index "
not_found:      .asciiz "The number is not found."

    .text
main:           li $v0, 4
                la $a0, num
                syscall                # print "Enter number to be found: "

                li $v0, 5
                syscall                # read integer -> $v0
                move $a1, $v0          # $a1 = data

                la $a0, array          # $a0 = address of A
                li $a2, 0              # $a2 = lo = 0
                li $a3, 9              # $a3 = hi = 9 (last index)
                jal bin_search         # $v0 = index, or -1

                bltz $v0, not_found1   # -1 -> not found
                move $t0, $v0          # save the index before printing

                li $v0, 4
                la $a0, found
                syscall                # print "The number is found at index "

                li $v0, 1
                move $a0, $t0
                syscall                # print the index

                j exit

not_found1:     li $v0, 4
                la $a0, not_found
                syscall                # print "The number is not found."

exit:           li $v0, 10
                syscall

bin_search:     addi $sp, $sp, -4      # push: space for 1 word
                sw $ra, 0($sp)         # save the return address

                bgt $a2, $a3, fail     # lo > hi -> nothing left to search

                add $t0, $a2, $a3
                sra $t0, $t0, 1        # $t0 = mid = (lo + hi) / 2

                sll $t1, $t0, 2        # $t1 = mid * 4
                add $t1, $a0, $t1      # $t1 = address of A[mid]
                lw $t2, 0($t1)         # $t2 = A[mid]

                beq $a1, $t2, success  # data == A[mid] -> found
                blt $a1, $t2, left     # data <  A[mid] -> search left half

                addi $a2, $t0, 1       # data > A[mid]: lo = mid + 1
                jal bin_search         # search right half
                j bs_end

left:           addi $a3, $t0, -1      # hi = mid - 1
                jal bin_search         # search left half
                j bs_end

success:        move $v0, $t0          # return mid
                j bs_end

fail:           li $v0, -1             # return -1

bs_end:         lw $ra, 0($sp)         # restore the return address
                addi $sp, $sp, 4       # pop
                jr $ra
```

Expected output for `23`: `The number is found at index 5`.
For `50`: `The number is not found.`

### The idea

Binary search only works on a **sorted** array. Look at the middle element:

- if it is the number, done;
- if the number is smaller, it can only be in the left half;
- if the number is bigger, it can only be in the right half.

Each step throws away half of what is left, so 10 elements take at most 4
checks (linear search could take 10). If the range becomes empty
(`lo > hi`), the number is not there.

### The agreement between caller and `bin_search`

This is the first procedure in the course that uses **all four** argument
registers:

| Register | Direction | Meaning |
|----------|-----------|---------|
| `$a0` | caller → `bin_search` | address of the array `A` |
| `$a1` | caller → `bin_search` | `data`, the number to find |
| `$a2` | caller → `bin_search` | `lo`, first index still in range |
| `$a3` | caller → `bin_search` | `hi`, last index still in range |
| `$v0` | `bin_search` → caller | index of `data`, or `-1` |

`lo` and `hi` are **indices** (0 – 9), not addresses. The address is only
worked out when an element is read.

### Step by step

1. **Push `$ra`.** `bin_search` calls itself, so its `jal` would overwrite
   `$ra`. Nothing else needs saving (see below).
2. **Empty range.** `bgt $a2, $a3, fail` — if `lo > hi` there is nothing
   left, return `-1`. This check must come **before** reading `A[mid]`,
   otherwise it could read outside the array.
3. **`mid = (lo + hi) / 2`.** `sra` (shift right arithmetic by 1) divides by 2
   and rounds down, the same as C integer division for positive numbers. No
   `div` / `mflo` is needed.
4. **Address of `A[mid]`.** Each `.word` is 4 bytes, so the element at index
   `mid` is at `A + mid * 4`. `sll $t1, $t0, 2` is `mid * 4` (shift left by 2
   = multiply by 4).
5. **Three-way compare.**
   - `beq` → equal → `success` returns `mid` in `$v0`.
   - `blt` → smaller → `left`: keep `lo`, set `hi = mid - 1`.
   - otherwise (bigger) → keep `hi`, set `lo = mid + 1`.
   In both recursive calls `$a0` (the array) and `$a1` (data) are not touched,
   so they are passed on as they are; only `$a2` or `$a3` changes.
6. **Return the inner answer.** After the inner `jal bin_search`, `$v0`
   already holds the answer of the smaller search, and that is also the
   answer of this search. So the procedure goes straight to `bs_end` without
   changing `$v0`.
7. **Pop and return.** Restore `$ra`, `$sp += 4`, `jr $ra`. Every path
   (`fail`, `success`, left call, right call) ends at `bs_end`, so every path
   pops.

### Why only `$ra` is saved

In `power` and `rsum`, the procedure does something **after** the inner call
(`a * …`, `n + …`), so it needs a value (`a` or `n`) to still be there. Here,
the recursive call is the very last thing the procedure does —
`return bin_search(...)` — so nothing has to survive the call. `$t0`, `$a2`
and `$a3` are changed by the inner calls, but they are never read again
afterwards. This is called a **tail call**. (It could even be written as a
plain loop with no stack at all. The recursive version is written here
because that is what the lab asks for.)

### Trace for `data = 23`

Array: `index 0..9 = 2, 5, 8, 12, 16, 23, 38, 56, 72, 91`.

| Call | lo | hi | mid | A[mid] | Compare | Next |
|------|----|----|-----|--------|---------|------|
| 1 | 0 | 9 | 4 | 16 | 23 > 16 | right: `lo = 5` |
| 2 | 5 | 9 | 7 | 56 | 23 < 56 | left: `hi = 6` |
| 3 | 5 | 6 | 5 | 23 | equal | return 5 |

Call 3 returns 5 → call 2 passes 5 back → call 1 passes 5 back → `main`
prints `The number is found at index 5`.

### Trace for `data = 50` (not found)

| Call | lo | hi | mid | A[mid] | Compare | Next |
|------|----|----|-----|--------|---------|------|
| 1 | 0 | 9 | 4 | 16 | 50 > 16 | `lo = 5` |
| 2 | 5 | 9 | 7 | 56 | 50 < 56 | `hi = 6` |
| 3 | 5 | 6 | 5 | 23 | 50 > 23 | `lo = 6` |
| 4 | 6 | 6 | 6 | 38 | 50 > 38 | `lo = 7` |
| 5 | 7 | 6 | – | – | `lo > hi` | return -1 |

Compare this with the board's version in Part A, which loops forever on the
same input.

### Common mistakes with this program

| Mistake | What goes wrong |
|---------|-----------------|
| Using the board's `mid, high+1` for the right half | Never-ending recursion for numbers that are not in the array (Part A). |
| Using `mid` instead of `mid + 1` / `mid - 1` | Same problem: the range may not shrink, so the search can repeat forever. |
| Using `mid` as an address (`add $t1, $a0, $t0` without `sll`) | Reads from `A + mid` bytes, i.e. the middle of some word — wrong value, and MARS stops with an alignment error. |
| Checking `lo > hi` after reading `A[mid]` | When the range is empty `mid` can be outside the array, so memory past the array is read first. |
| `li $a3, 10` for `hi` | `hi` is the **last index** (9), not the number of elements. With 10, a search for a number bigger than 91 reads `A[10]`, which is past the end of the array. |
| Array not sorted | The halving logic throws away the wrong half and misses numbers that are present. |
| Checking `beqz $v0` for not found (as in Week 8 linear search) | Here not found is `-1` and index `0` is a valid answer, so `bltz` must be used. With `beqz`, searching for `2` (index 0) would print "not found". |

**Points to note:**

- `(lo + hi) / 2` is fine here. With huge arrays `lo + hi` could overflow;
  `lo + (hi - lo) / 2` avoids that, but with indices 0–9 it cannot happen.
- If a number appears more than once, binary search returns **one** of its
  positions, not necessarily the first.

---

## 3. `sum_natural.asm` — sum of first n natural numbers using recursion

```asm
    .data
msg:            .asciiz "Enter n: "
result:         .asciiz "Sum of the first n natural numbers is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall                # print "Enter n: "

                li $v0, 5
                syscall                # read n -> $v0
                move $a0, $v0          # $a0 = n

                jal rsum               # $v0 = RSum(n)
                move $t0, $v0          # save the result before printing

                li $v0, 4
                la $a0, result
                syscall                # print "Sum of the first n natural numbers is: "

                li $v0, 1
                move $a0, $t0
                syscall                # print the sum

                li $v0, 10
                syscall                # exit

rsum:           addi $sp, $sp, -8      # push: space for 2 words
                sw $ra, 4($sp)         # save the return address
                sw $s0, 0($sp)         # save the caller's $s0

                move $s0, $a0          # $s0 = n
                li $t0, 1
                ble $s0, $t0, base     # n <= 1 -> base case

                addi $a0, $s0, -1      # argument = n - 1
                jal rsum               # $v0 = RSum(n - 1)
                add $v0, $s0, $v0      # $v0 = n + RSum(n - 1)

                j rsum_end             # skip past base

base:           move $v0, $s0          # RSum(1) = 1, RSum(0) = 0 -> return n

rsum_end:       lw $s0, 0($sp)         # restore the caller's $s0
                lw $ra, 4($sp)         # restore the return address
                addi $sp, $sp, 8       # pop
                jr $ra
```

Expected output for `n = 10`: `Sum of the first n natural numbers is: 55`.

### The idea

```
RSum(1) = 1
RSum(n) = n + RSum(n - 1)       for n >= 2
```

`RSum(4) = 4 + RSum(3) = 4 + (3 + RSum(2)) = 4 + (3 + (2 + RSum(1))) = 4 + 3 + 2 + 1 = 10`.

This has the same shape as `fib` from Week 8, but with only **one**
recursive call, so it is simpler: one value (`n`) to keep instead of two
(`n` and `fib(n - 1)`).

### Step by step

1. **Push** `$ra` and `$s0` — same reasons as in `power`.
2. **`move $s0, $a0`** — `n` is needed after the call for `n + RSum(n - 1)`,
   and `$a0` is about to be overwritten with `n - 1`.
3. **Base case** — `ble $s0, $t0, base` with `$t0 = 1`. For `n = 1` (and
   `n = 0`) the answer is `n` itself, so `base` is just `move $v0, $s0`, the
   same trick as `fib`'s base case.
4. **Recursive case** — call with `n - 1`; when it returns, `$v0 = RSum(n - 1)`
   and `$s0` is still `n` (the inner call saved and restored it), so
   `add $v0, $s0, $v0` gives `RSum(n)`.
5. **Pop and return** — same as `power`.

### Trace for `n = 4`

| Call | `$s0` (n) | Waits for | Returns |
|------|-----------|-----------|---------|
| `rsum(4)` | 4 | `rsum(3)` | `4 + 6 = 10` |
| `rsum(3)` | 3 | `rsum(2)` | `3 + 3 = 6` |
| `rsum(2)` | 2 | `rsum(1)` | `2 + 1 = 3` |
| `rsum(1)` | 1 | — (base case) | `1` |

When `rsum(1)` returns, it restores `$s0` to 2, so `rsum(2)` sees its own
`n` again; when `rsum(2)` returns it restores `$s0` to 3, and so on. That is
why `$s0` must be saved on the stack in every call.

### Common mistakes with this program

| Mistake | What goes wrong |
|---------|-----------------|
| `beq $s0, 1, base` only (as on the board) | `n = 0` recurses forever: 0, -1, -2, … until the stack runs out. |
| Using `$a0` after the call for `n + …` | `$a0` holds `n - 1` (and whatever the inner calls left there), not `n`, so the sum is wrong. |
| Saving `$s0` but not restoring it | Every caller sees `$s0 = 1` after its inner call, so the answer becomes `1 + 1 + … + 1 = n`. |
| Missing `j rsum_end` after the `add` | Falls into `base`, and `move $v0, $s0` replaces the sum with `n`. |

**Points to note:**

- The answer can be checked with the formula `n(n + 1) / 2`:
  `n = 10 → 55`, `n = 100 → 5050`. Both were tested.
- Each level of recursion uses 8 bytes of stack, so `n = 1000` uses 8000
  bytes — fine in MARS. The loop version from earlier weeks would use no
  stack at all; recursion is used here because the lab asks for it.
- For negative `n` the base case catches it straight away and prints `n`
  itself. Natural numbers start from 1, so a negative sum has no meaning.
