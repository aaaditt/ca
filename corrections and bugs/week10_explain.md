# Week 10 — Bugs, Corrections, and Code Explanations

Week 10 covers **floating point arithmetic**:

1. `circle_area.asm` — area of a circle, `pi * r^2`
2. `fahrenheit_to_celsius.asm` — `C = 5/9 * (F - 32)`
3. `polynomial.asm` — value of `ax^2 + bx + c` for a user-entered `x`

Part A lists the problems in the question as it was given, and one
floating point problem found while testing. Part B explains each program.

All three programs were tested before being committed:

| Program | Inputs tried | Output |
|---------|--------------|--------|
| `circle_area.asm` | `r = 1, 5, 2.5, 10` | `3.1415927`, `78.53982`, `19.634954`, `314.15927` |
| `fahrenheit_to_celsius.asm` | `F = 32, 212, 98.6, -40, 0, 100, 50` | `0.0`, `100.0`, `37.0`, `-40.0`, `-17.777779`, `37.77778`, `10.0` |
| `polynomial.asm` | `(a, b, c, x) = (1,2,3,2)`, `(2,-3,1,1)`, `(1,0,-4,2)`, `(0.5,1.5,-2,3)`, `(1,2,3,-1)`, `(0,0,5,7)` | `11.0`, `0.0`, `0.0`, `7.0`, `2.0`, `5.0` |

The outputs are shown the way MARS prints floats (it always shows at least
one digit after the decimal point, so `11` is printed as `11.0`).

---

# Floating point in MIPS — what is new this week

| | Integers (weeks 2–9) | Single-precision floats (this week) |
|---|---|---|
| Registers | `$t0`, `$s0`, `$a0`, … | `$f0` – `$f31` (separate set, in **coprocessor 1**) |
| Constant in data | `.word 5` | `.float 5.0` |
| Load from memory | `lw $t0, label` | `l.s $f1, label` |
| Copy register | `move $t1, $t0` | `mov.s $f1, $f0` |
| Arithmetic | `add`, `sub`, `mul`, `div` | `add.s`, `sub.s`, `mul.s`, `div.s` |
| Read from keyboard | syscall **5**, result in `$v0` | syscall **6**, result in **`$f0`** |
| Print | syscall **1**, value in `$a0` | syscall **2**, value in **`$f12`** |

The `.s` ending means **single precision** (32-bit `float`, about 7
significant digits). The double-precision versions end in `.d` (`l.d`,
`add.d`, syscall 7 / 3, register pairs like `$f12`/`$f13`).

**Things that trip people up:**

- There is **no `li` for floats**. Constants such as π, 5, 9 and 32 are put
  in the `.data` section with `.float` and loaded with `l.s`. (Some
  simulators, such as SPIM, accept a `li.s` pseudo-instruction, but it is
  not part of the real instruction set, so the programs here do not use it.)
- Float and integer registers do not mix: `add.s $f1, $t0, $f2` is an
  error. To move a value between the two sets you need `mtc1` / `mfc1` and
  a conversion (`cvt.s.w` / `cvt.w.s`), which these programs do not need
  because everything is read in as a float from the start.
- `$v0` is still the syscall number and `$a0` is still used for printing
  strings. That is why the float answer can be put in `$f12` **before**
  printing the message string — printing a string only touches `$v0` and
  `$a0`, never `$f12`.
- A float typed in as `5` is fine: syscall 6 reads `5` and stores `5.0`.

---

# Part A — Bugs and corrections

## 1. Circle area — the value of π

The question wrote π as `3.14.15926535...`, which has two decimal points.
That is a typo, not a number, and the assembler would reject it. The value
used is:

```asm
pi:             .float 3.14159265
```

A single-precision float only holds about 7 significant digits, so typing
more digits than this does nothing — `3.14159265`, `3.1415926535` and
`3.14159265358979` are all stored as exactly the same bits, which is the
closest float to π: `3.1415927410…`. (Using `.double` and the `.d`
instructions would keep about 16 digits.)

## 2. Fahrenheit to Celsius — the formula

The question gave the formula as:

```
celsius = 5/9 * fahr - 32
```

There are **two** problems in this line.

| # | Problem | What goes wrong | Fix |
|---|---------|-----------------|-----|
| 1 | **No brackets around `fahr - 32`.** `*` is done before `-`, so this is `(5/9 * fahr) - 32`. | Subtracts 32 *after* scaling, which is the wrong formula. For `F = 212` it gives `5/9 * 212 - 32 = 85.78` instead of `100`. | `C = 5/9 * (F - 32)`. In the program the subtraction is done first (`sub.s`), before any multiplying. |
| 2 | **`5/9` with integers is `0`.** Integer division throws away the fraction, so `5 / 9 = 0` (that is what `div` + `mflo` would give in MIPS, and what C gives for `5/9`). | Every temperature converts to `0 * F - 32 = -32`. | `5` and `9` are stored as `.float 5.0` and `.float 9.0`, and divided with `div.s`, which keeps the fraction. |

Results for a few inputs:

| F | Board formula with integers | Board formula with floats (no brackets) | Correct `5/9 * (F - 32)` |
|---|---|---|---|
| 32 | -32 | -14.22 | **0.0** |
| 212 | -32 | 85.78 | **100.0** |
| -40 | -32 | -54.22 | **-40.0** |

## 3. Fahrenheit to Celsius — order of operations in floating point (found while testing)

The first version of the program worked out `5/9` first and then multiplied:

```asm
                div.s $f5, $f3, $f4    # f5 = 5 / 9
                mul.s $f12, $f5, $f2   # f12 = 5/9 * (F - 32)
```

Mathematically this is correct, but for `F = 212` it printed
**`100.00001`**, not `100.0`.

**Why:** `5/9 = 0.5555…` goes on forever in binary, just like `1/3` goes on
forever in decimal. A float has to cut it off after 24 binary digits, so the
stored value is very slightly more than `5/9`. Multiplying by 180 also
multiplies that tiny error by 180, and it becomes big enough to show in the
last digit.

**Fix applied:** multiply first, divide last:

```asm
                mul.s $f2, $f2, $f3    # f2 = (F - 32) * 5
                div.s $f12, $f2, $f4   # f12 = (F - 32) * 5 / 9
```

For `F = 212`: `180 * 5 = 900` (exact), and `900 / 9 = 100` (exact). Only
one rounding happens, at the very end, so whole-number answers come out
exact. This is the same formula — it only changes **when** the rounding
happens.

| F | `5/9` first (old) | `* 5` first, `/ 9` last (current) |
|---|---|---|
| 212 | 100.00001 | **100.0** |
| 98.6 | 37.0 | 37.0 |
| 50 | 10.0 | 10.0 |

General rule: in floating point, `(x * 5) / 9` and `x * (5 / 9)` are **not**
always exactly equal. Rounding happens after every single instruction, so
the order of instructions can change the last digit.

## 4. Polynomial

No bugs in the question. It only says "for a user input x"; the program also
reads `a`, `b` and `c` from the user so it works for any quadratic, not one
fixed set of coefficients.

---

# Part B — Code explanations

## 1. `circle_area.asm` — area of a circle

```asm
    .data
pi:             .float 3.14159265
msg:            .asciiz "Enter the radius: "
result:         .asciiz "The area of the circle is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall                # print "Enter the radius: "

                li $v0, 6
                syscall                # read float -> $f0 = r

                l.s $f1, pi            # $f1 = pi
                mul.s $f2, $f0, $f0    # $f2 = r * r
                mul.s $f12, $f1, $f2   # $f12 = pi * r^2

                li $v0, 4
                la $a0, result
                syscall                # print "The area of the circle is: "

                li $v0, 2
                syscall                # print the float in $f12

                li $v0, 10
                syscall                # exit
```

Expected output for `r = 5`: `The area of the circle is: 78.53982`.

### Step by step

1. **Read the radius.** Syscall 6 reads a float and leaves it in `$f0` — not
   `$v0` like syscall 5.
2. **Load π.** `l.s $f1, pi` copies the 4 bytes at label `pi` into `$f1`.
   This is the float version of `lw`.
3. **`r * r`.** There is no "square" instruction, so `r^2` is `r * r`.
4. **`π * r^2` straight into `$f12`.** Syscall 2 prints whatever is in
   `$f12`, so the last instruction writes the answer there and no extra
   `mov.s` is needed.
5. **Print the message, then the number.** Printing the message uses `$v0`
   and `$a0` only, so `$f12` still holds the area when syscall 2 runs.

### Common mistakes with this program

| Mistake | What goes wrong |
|---------|-----------------|
| Using syscall 5 (read int) and `$v0` | Only whole-number radii can be entered, and the value is in an integer register, so `mul.s` cannot use it. |
| `li $f1, 3.14159265` | Assembler error — `li` is for integer registers and integer constants. Load the float from `.data` with `l.s`. |
| `.word 3.14159265` | `.word` stores an integer. The assembler rejects it or the bits are not a float — the value must be declared with `.float`. |
| `la $a0, pi` then `syscall 2` | Prints whatever is in `$f12` (here, garbage or 0), not π. Float printing ignores `$a0`. |
| Putting the answer in `$f0` and printing | Syscall 2 prints `$f12`, not `$f0`. |
| Using `mul` instead of `mul.s` | `mul` works on integer registers; `mul $f2, $f0, $f0` does not assemble. |

**Points to note:**

- A float prints about 7–8 significant digits, so `pi * 10^2` prints as
  `314.15927`, not `314.159265`.
- A negative radius still "works" (`(-5)^2 = 25`) and prints a positive area;
  a radius can't be negative, so that input has no real meaning.

---

## 2. `fahrenheit_to_celsius.asm` — Fahrenheit to Celsius

```asm
    .data
five:           .float 5.0
nine:           .float 9.0
thirty_two:     .float 32.0
msg:            .asciiz "Enter the temperature in Fahrenheit: "
result:         .asciiz "The temperature in Celsius is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall                # print the prompt

                li $v0, 6
                syscall                # read float -> $f0 = F

                l.s $f1, thirty_two
                sub.s $f2, $f0, $f1    # $f2 = F - 32       (brackets first)

                l.s $f3, five
                mul.s $f2, $f2, $f3    # $f2 = (F - 32) * 5

                l.s $f4, nine
                div.s $f12, $f2, $f4   # $f12 = (F - 32) * 5 / 9

                li $v0, 4
                la $a0, result
                syscall                # print "The temperature in Celsius is: "

                li $v0, 2
                syscall                # print the float in $f12

                li $v0, 10
                syscall                # exit
```

Expected output for `F = 98.6`: `The temperature in Celsius is: 37.0`.

### Step by step

1. **Read F** with syscall 6 → `$f0`.
2. **`F - 32` first.** This is the bracket in `5/9 * (F - 32)`. In assembly
   there are no brackets — the order is set by the order of the
   instructions, so the subtraction is simply written first.
3. **Times 5, then divide by 9.** `5/9 * (F - 32)` is the same as
   `(F - 32) * 5 / 9`. Doing the division last means only one rounding error
   (see Part A, section 3), so `212 → 100.0` exactly.
4. **`div.s` instead of `div`.** Float division keeps the fraction:
   `(0 - 32) * 5 / 9 = -17.777779`. Integer `div` would give `-17`.
5. **Answer goes straight into `$f12`** for syscall 2, same as `circle_area`.

### Trace for `F = 0`

| Instruction | Register | Value |
|-------------|----------|-------|
| `syscall 6` | `$f0` | `0.0` |
| `sub.s $f2, $f0, $f1` | `$f2` | `0 - 32 = -32.0` |
| `mul.s $f2, $f2, $f3` | `$f2` | `-32 * 5 = -160.0` |
| `div.s $f12, $f2, $f4` | `$f12` | `-160 / 9 = -17.777779` |

### Common mistakes with this program

| Mistake | What goes wrong |
|---------|-----------------|
| Following the board formula `5/9 * fahr - 32` in order | Subtracts 32 at the end — wrong answer for every input (`212 → 85.78`). |
| Integer `5 / 9` (`div` / `mflo`, or `li` constants) | `5 / 9 = 0`, so every answer is `-32` or `0`. |
| Dividing `5.0 / 9.0` first and multiplying after | Correct maths but `212 → 100.00001` because of rounding (Part A, section 3). |
| `div.s $f12, $f4, $f2` (operands swapped) | Works out `9 / (5(F - 32))` instead. The first source is divided **by** the second, same as integer `div`. |
| Writing `.float 32` and worrying it is an integer | Fine — `.float 32` and `.float 32.0` store the same value. The directive decides the type, not the decimal point. |

**Points to note:**

- `-40` is the one temperature that is the same in both scales, which makes
  it a quick check: the program prints `-40.0`.
- `98.6` is not exact in binary either, but the answer still rounds to
  `37.0`, because the error is far smaller than what a float prints.

---

## 3. `polynomial.asm` — value of ax^2 + bx + c

```asm
    .data
msg_a:          .asciiz "Enter a: "
msg_b:          .asciiz "Enter b: "
msg_c:          .asciiz "Enter c: "
msg_x:          .asciiz "Enter x: "
result:         .asciiz "The value of ax^2 + bx + c is: "

    .text
main:           li $v0, 4
                la $a0, msg_a
                syscall                # print "Enter a: "

                li $v0, 6
                syscall                # read float -> $f0
                mov.s $f1, $f0         # $f1 = a  (next read overwrites $f0)

                li $v0, 4
                la $a0, msg_b
                syscall

                li $v0, 6
                syscall
                mov.s $f2, $f0         # $f2 = b

                li $v0, 4
                la $a0, msg_c
                syscall

                li $v0, 6
                syscall
                mov.s $f3, $f0         # $f3 = c

                li $v0, 4
                la $a0, msg_x
                syscall

                li $v0, 6
                syscall
                mov.s $f4, $f0         # $f4 = x

                mul.s $f5, $f4, $f4    # $f5 = x * x
                mul.s $f5, $f1, $f5    # $f5 = a * x^2
                mul.s $f6, $f2, $f4    # $f6 = b * x
                add.s $f12, $f5, $f6   # $f12 = ax^2 + bx
                add.s $f12, $f12, $f3  # $f12 = ax^2 + bx + c

                li $v0, 4
                la $a0, result
                syscall                # print "The value of ax^2 + bx + c is: "

                li $v0, 2
                syscall                # print the float in $f12

                li $v0, 10
                syscall                # exit
```

Expected output for `a = 1, b = 2, c = 3, x = 2`:
`The value of ax^2 + bx + c is: 11.0`  (`4 + 4 + 3`).

### Step by step

1. **Four reads, four `mov.s`.** Every syscall 6 puts its value in `$f0`,
   so each value is copied to its own register (`$f1`–`$f4`) straight after
   it is read. This is the float version of `move $s0, $v0` from earlier
   weeks. Without it, `a`, `b` and `c` would all be lost and only `x` would
   be left.
2. **`a * x^2`.** `x * x` first, then times `a`. `$f5` is reused for both
   steps — writing a register with something calculated from itself
   (`mul.s $f5, $f1, $f5`) is allowed.
3. **`b * x`** in `$f6`.
4. **Add up.** `ax^2 + bx` goes straight into `$f12`, then `+ c` is added to
   `$f12` itself, so the final answer is already where syscall 2 wants it.

### Trace for `a = 0.5, b = 1.5, c = -2, x = 3`

| Instruction | Register | Value |
|-------------|----------|-------|
| `mul.s $f5, $f4, $f4` | `$f5` | `3 * 3 = 9.0` |
| `mul.s $f5, $f1, $f5` | `$f5` | `0.5 * 9 = 4.5` |
| `mul.s $f6, $f2, $f4` | `$f6` | `1.5 * 3 = 4.5` |
| `add.s $f12, $f5, $f6` | `$f12` | `4.5 + 4.5 = 9.0` |
| `add.s $f12, $f12, $f3` | `$f12` | `9 + (-2) = 7.0` |

### Another way: Horner's method

`ax^2 + bx + c` can also be written as `(a * x + b) * x + c`:

```asm
                mul.s $f12, $f1, $f4   # a * x
                add.s $f12, $f12, $f2  # a * x + b
                mul.s $f12, $f12, $f4  # (a * x + b) * x
                add.s $f12, $f12, $f3  # (a * x + b) * x + c
```

This needs 2 multiplications instead of 3 and no extra registers. For a
quadratic the saving is small, but for a polynomial of degree `n` it uses
`n` multiplications instead of about `n^2 / 2`. The program uses the
straightforward version because it matches `ax^2 + bx + c` term by term and
is easier to check.

### Common mistakes with this program

| Mistake | What goes wrong |
|---------|-----------------|
| Not copying `$f0` after each read | Each read overwrites `$f0`, so `a`, `b`, `c` are lost; the answer uses `x` for everything. |
| `move $f1, $f0` | `move` is for integer registers; float registers use `mov.s`. |
| Calling `x^2` as `mul.s $f5, $f4, 2` | There are no immediate operands in float instructions — both sources must be `$f` registers. |
| Reading the inputs as integers (syscall 5) | `a = 0.5` or `x = 1.5` can't be entered, and integer registers can't be used with `.s` instructions. |

**Points to note:**

- `a = 0` is allowed and gives a straight line, `bx + c` (the
  `(0, 0, 5, 7)` test prints `5.0`).
- `(1, 0, -4, 2)` and `(2, -3, 1, 1)` both print `0.0` — `x` is a root of
  the quadratic in those cases (`x^2 - 4 = 0` at `x = 2`,
  `2x^2 - 3x + 1 = 0` at `x = 1`).
