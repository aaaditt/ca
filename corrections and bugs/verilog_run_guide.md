# Verilog Guide — How to Run Weeks 11 and 12

This guide covers three things:

1. The exact commands to run every Week 11 and Week 12 program
2. Why every program is split into a design file and a testbench
3. What the code means, line by line

---

# Part 1 — Setup (once)

Verilog is **simulated**, not run like C or Python. The free simulator used here
is **Icarus Verilog**.

Install it:

```
winget install --id Icarus.Verilog
```

The installer puts it in `C:\iverilog\bin` but does **not** add it to PATH.
Fix that once, then close and reopen the terminal:

```
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\iverilog\bin", "User")
```

Check that it worked:

```
iverilog -V
```

If you would rather not touch PATH, call it by full path each time. In
PowerShell the `&` is required:

```
& "C:\iverilog\bin\iverilog.exe" -o and_gate.vvp and_gate.v and_gate_tb.v
& "C:\iverilog\bin\vvp.exe" and_gate.vvp
```

---

# Part 2 — The two-step pattern

Every program is run with the same two commands:

```
iverilog -o <name>.vvp <design>.v <design>_tb.v
vvp <name>.vvp
```

| Part | Meaning |
|---|---|
| `iverilog` | the **compiler**. Reads the `.v` source files and checks the syntax |
| `-o <name>.vvp` | the name of the compiled file to create |
| `<design>.v` | the circuit |
| `<design>_tb.v` | the testbench that exercises the circuit |
| `vvp` | the **runner**. Executes the compiled file and prints the `$display` output |

This is the same split as C: `gcc -o prog prog.c`, then `./prog`.

**About the extension:** `.vvp` and `.out` make no difference. `-o` accepts any
name. `.vvp` is used here because it says what kind of file it is. The only rule
is that the name after `-o` must be the same name you give to `vvp`.

Compiled `.vvp` / `.out` files are build output. Do not commit them.

---

# Part 3 — Commands for every program

Go to the right folder first.

## Week 11

```
cd C:\Aadit\BITS\3yrsem1\ca\week11
```

| Program | Compile | Run |
|---|---|---|
| AND gate | `iverilog -o and_gate.vvp and_gate.v and_gate_tb.v` | `vvp and_gate.vvp` |
| OR gate | `iverilog -o or_gate.vvp or_gate.v or_gate_tb.v` | `vvp or_gate.vvp` |
| Half adder | `iverilog -o half_adder.vvp half_adder.v half_adder_tb.v` | `vvp half_adder.vvp` |
| Full adder | `iverilog -o full_adder.vvp full_adder.v full_adder_tb.v` | `vvp full_adder.vvp` |
| Half subtractor | `iverilog -o half_sub.vvp half_sub.v half_sub_tb.v` | `vvp half_sub.vvp` |
| Full subtractor | `iverilog -o full_sub.vvp full_sub.v full_sub_tb.v` | `vvp full_sub.vvp` |

Run all six at once (PowerShell):

```
foreach ($n in "and_gate","or_gate","half_adder","full_adder","half_sub","full_sub") { "=== $n ==="; iverilog -o "$n.vvp" "$n.v" "${n}_tb.v"; vvp "$n.vvp" }
```

## Week 12

```
cd C:\Aadit\BITS\3yrsem1\ca\week12
```

| Program | Compile | Run |
|---|---|---|
| 8-bit signed adder | `iverilog -o signed_add8.vvp signed_add8.v signed_add8_tb.v` | `vvp signed_add8.vvp` |
| 8-bit signed subtractor | `iverilog -o signed_sub8.vvp signed_sub8.v signed_sub8_tb.v` | `vvp signed_sub8.vvp` |

Run both at once:

```
foreach ($n in "signed_add8","signed_sub8") { "=== $n ==="; iverilog -o "$n.vvp" "$n.v" "${n}_tb.v"; vvp "$n.vvp" }
```

The `$finish called at ...` line at the end of every run is normal. It is the
simulator saying the simulation ended.

---

# Part 4 — Why separate files?

## Why a design file and a testbench

A real circuit has no "run" button. Its signals simply exist. To check one in
software you need something to play the part of the lab bench.

| Real lab | Testbench |
|---|---|
| switches you flip | `reg a, b;` that you assign |
| LEDs you read | `wire y;` that you observe |
| the chip on the board | the instance, e.g. `and_gate uut(...)` |
| waiting for it to settle | `#10;` |
| writing down the result | `$display` |

So the two files do two different jobs:

- **Design file** (`and_gate.v`): describes the circuit. This is the thing you
  would build. It has inputs and outputs and nothing else. It cannot run on its
  own because nothing ever changes its inputs.
- **Testbench** (`and_gate_tb.v`): not a circuit. It is a test script that
  drives inputs and prints outputs. It has **no ports**, because nothing
  outside it connects to it.

Keeping them apart has practical benefits:

- The design stays clean. Test code like `$display` and `#10` cannot be built
  into hardware, so it must not be mixed into the circuit.
- You can reuse one design with many different tests.
- The Week 12 adders reuse the same `full_adder` as a building block.

## Why you list both files when compiling

The testbench contains the line `and_gate uut(...)`. That says "put an
`and_gate` here", but the testbench does not contain the definition of
`and_gate`. The compiler finds it only if you also pass the design file. Leave
one out and you get:

```
error: Unknown module type: and_gate
```

## Why `reg` and `wire`

- `reg` is a signal the testbench **assigns** (an input to the circuit).
- `wire` is a signal the circuit **drives** (an output from the circuit).

Rule: testbench inputs are `reg`, testbench outputs are `wire`.

---

# Part 5 — What the code means

## Anatomy of a design file

```verilog
module and_gate(input a, input b, output y);
    assign y = a & b;
endmodule
```

- `module ... endmodule` wraps one circuit.
- `(input a, input b, output y)` is the list of ports (the pins).
- `assign y = a & b;` is a **continuous assignment**. It is not a step that runs
  once. It describes a permanent connection, so whenever `a` or `b` changes,
  `y` updates by itself.

Operators used:

| Operator | Meaning |
|---|---|
| `&` | AND |
| `\|` | OR |
| `^` | XOR |
| `~` | NOT |

On single-bit signals these are the gates. They are different from `&&`, `||`
and `!`, which are logical operators for conditions.

## Anatomy of a testbench

```verilog
module and_gate_tb;
    reg a, b;
    wire y;

    and_gate uut(.a(a), .b(b), .y(y));

    integer i;
    initial begin
        $display("a b | y");
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i;
            #10;
            $display("%b %b | %b", a, b, y);
        end
        $finish;
    end
endmodule
```

| Line | Meaning |
|---|---|
| `module and_gate_tb;` | no port list, because a testbench has no pins |
| `reg a, b;` | the inputs the testbench drives |
| `wire y;` | the output it observes |
| `and_gate uut(.a(a), .b(b), .y(y));` | places the circuit. `uut` means Unit Under Test. `.a(a)` means "the circuit's port `a` connects to my signal `a`" |
| `initial begin ... end` | a block that runs once at time 0 |
| `for (...)` | counts `i` from 0 up to 2^(inputs) - 1 |
| `{a, b} = i;` | splits the bits of `i` across the inputs, so `i = 2` gives `a=1, b=0` |
| `#10;` | wait 10 time units so the circuit settles before reading the output |
| `$display(...)` | like `printf`. `%b` prints a bit |
| `$finish;` | ends the simulation |

The loop runs 4 times for 2 inputs and 8 times for 3 inputs. That is how a
testbench tries **every** input combination.

To write a new one, copy this skeleton and change three things: the module
name, the `reg`/`wire` lists, and the loop count.

---

## Week 11 designs

| File | Inputs | Outputs | Logic |
|---|---|---|---|
| `and_gate.v` | a, b | y | `a & b` |
| `or_gate.v` | a, b | y | `a \| b` |
| `half_adder.v` | a, b | sum, carry | `sum = a ^ b`, `carry = a & b` |
| `full_adder.v` | a, b, cin | sum, cout | `sum = a ^ b ^ cin`, `cout = (a&b) \| (a&cin) \| (b&cin)` |
| `half_sub.v` | a, b | difference, borrow | `difference = a ^ b`, `borrow = ~a & b` |
| `full_sub.v` | a, b, borrow_in | difference, borrow_out | `difference = a ^ b ^ borrow_in`, `borrow_out = (~a & b) \| (~(a^b) & borrow_in)` |

What to check in the output:

- **AND:** `y` is 1 only for `1 1`.
- **OR:** `y` is 0 only for `0 0`.
- **Adders:** `sum` is 1 when an odd number of inputs are 1. The carry is 1
  when two or more inputs are 1.
- **Subtractors:** `difference` is the XOR of the inputs. A borrow is needed
  when you take a larger bit from a smaller one (`0 - 1`).

A **half** circuit handles two bits. A **full** circuit adds a third input
(`cin` or `borrow_in`) so that circuits can be chained.

---

## Week 12 designs

Week 12 asks for 8-bit signed add and subtract. The programs are long because
the chain is written out explicitly, one instance per bit.

### Signed numbers (2's complement)

8 bits hold values from -128 to 127. The leftmost bit (bit 7) is the **sign
bit**. The key fact is that the same bit-by-bit adder works for positive and
negative numbers. Nothing in the hardware changes. Only the way you *read* the
8 bits changes. For example, `11111011` is 251 unsigned but -5 signed. That is
why the testbench declares `reg signed [7:0]` and prints with `%d`.

### `signed_add8.v` — ripple-carry adder

```verilog
full_adder fa0(.a(a[0]), .b(b[0]), .cin(1'b0), .sum(sum[0]), .cout(c1));
full_adder fa1(.a(a[1]), .b(b[1]), .cin(c1),   .sum(sum[1]), .cout(c2));
...
full_adder fa7(.a(a[7]), .b(b[7]), .cin(c7),   .sum(sum[7]), .cout(c8));
assign overflow = c7 ^ c8;
```

- `[7:0]` means an 8-bit bus. `a[0]` is the lowest bit, `a[7]` the sign bit.
- Eight `full_adder` instances (`fa0` to `fa7`) are chained. The carry out of
  one (`c1`, `c2`, ...) becomes the carry in of the next, like adding on paper.
- `fa0` has `cin = 1'b0` because there is no carry into the lowest bit. `1'b0`
  means a 1-bit constant 0.
- `overflow = c7 ^ c8`: the result is wrong when the carry **into** the sign
  bit differs from the carry **out of** it.

### `signed_sub8.v` — ripple-borrow subtractor

The same idea with `full_sub` cells. The borrow out of each bit (`br1`,
`br2`, ...) feeds the next bit's `borrow_in`, and the first bit starts with
`1'b0`. `overflow = br7 ^ br8` follows the same rule as the adder.

### Overflow

8 signed bits cannot hold results outside -128 to 127. When the true answer is
out of range, the wrapped-around value is wrong and `overflow` is 1:

| Operation | Printed result | Overflow | Why |
|---|---|---|---|
| `127 + 1` | -128 | 1 | true answer 128 is too big |
| `-128 + -1` | 127 | 1 | true answer -129 is too small |
| `100 - -100` | -56 | 1 | true answer 200 is too big |
| `-128 - 1` | 127 | 1 | true answer -129 is too small |

### Week 12 testbenches

They use fixed test cases instead of a counting loop, because 16 input bits
would mean 65,536 combinations. Each case is one line:

```verilog
a = 8'd127; b = 8'd1; #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
```

- `8'd127` means "an 8-bit decimal 127". `-8'd5` is -5.
- `%4d` prints a signed decimal, padded to width 4 so the columns line up.
- The cases cover normal values, mixed signs, zero, and the overflow edges
  (127, -128).

Both designs were also checked against all 65,536 input pairs and matched
Verilog's own arithmetic with 0 errors.

---

# Part 6 — Common problems

| Message or symptom | Cause | Fix |
|---|---|---|
| `iverilog` is not recognized | not on PATH | do the PATH step in Part 1, or use the full path |
| `Unknown module type: xyz` | a file is missing from the compile command | list the design file and the testbench |
| `vvp` says it cannot open the file | the name after `-o` differs from the name given to `vvp` | use the same name in both commands |
| output prints stale or `x` values | missing `#10;` before `$display` | add a delay so the circuit settles |
| port connection error | `.a(a)` names do not match the design's port names | match the names exactly |
| nothing happens after compile | you only ran `iverilog` | also run `vvp <name>.vvp` |
