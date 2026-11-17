# Week 11 — Code Explanations

Week 11 moves from MIPS assembly to **Verilog** (hardware description). The
questions are small combinational circuits, each written as a module plus a
testbench:

1. `half_adder.v` / `half_adder_tb.v` — Q2, half adder
2. `full_adder.v` / `full_adder_tb.v` — Q3, full adder
3. `half_sub.v` / `half_sub_tb.v` — Q4, half subtractor
4. `full_sub.v` / `full_sub_tb.v` — Q5, full subtractor

(Q1, the `and` / `all` gate programs seen in other students' folders, is not
included because that question was not available.)

**Testing note:** no Verilog simulator was installed on the machine used to
write these, so the files were **not run**. The formulas were copied from the
board and each truth table below was checked by hand against the expected
testbench output shown on the board. Run them in the lab to confirm.

To compile and run one program:

```
iverilog -o sim.vvp half_adder.v half_adder_tb.v
vvp sim.vvp
```

---

# Part A — Bugs and corrections

No bugs were found in the formulas given on the board. All four match their
expected truth tables for every input row. Two things are worth knowing:

- **Operator precedence in Verilog:** `~` binds tightest, then `&`, then `^`,
  then `|`. The full-subtractor formula
  `((~a) & b) | ((~(a ^ b)) & borrow_in)` is written with explicit brackets,
  so it reads the way it looks. The brackets were kept as given.
- **`~` on one bit:** `~a` is fine here because every signal is 1 bit wide. On
  a multi-bit signal `~` flips every bit, which is a different thing from the
  logical `!`.

---

# Part B — What is new this week

| | MIPS (weeks 2–10) | Verilog (this week) |
|---|---|---|
| What you write | A list of instructions run one after another | A description of hardware; everything exists at once |
| Unit | Program / label | `module ... endmodule` |
| Computing a value | `add`, `xor`, ... instructions | `assign out = expression;` |
| Running it | MARS | Simulator (`iverilog` + `vvp`) with a **testbench** |

`assign` is **continuous**: whenever an input changes, the output is
recomputed. There is no "step" at which it runs, like a wire connected to a
gate.

A module is the circuit. A **testbench** is a second module with no ports; it
creates the circuit, drives the inputs, and prints the outputs. It is only for
simulation, it is not hardware.

---

# 1. Half adder — `half_adder.v`

Adds two 1-bit numbers. The result can be 0, 1 or 2, which needs two output
bits: `sum` (low bit) and `carry` (high bit).

```verilog
module half_adder(input a, input b, output sum, output carry);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule
```

- `sum = a ^ b`: XOR is 1 when the inputs differ (0+1 or 1+0).
- `carry = a & b`: a carry only happens for 1+1.

| a b | sum carry |
|---|---|
| 0 0 | 0 0 |
| 0 1 | 1 0 |
| 1 0 | 1 0 |
| 1 1 | 0 1 |

# 2. Full adder — `full_adder.v`

Adds `a + b + cin` (carry-in from the previous bit). Needed so adders can be
chained to add multi-bit numbers.

```verilog
module full_adder(input a, input b, input cin, output sum, output cout);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule
```

- `sum` is 1 when an **odd** number of the three inputs are 1 (3-input XOR).
- `cout` is 1 when **at least two** inputs are 1, which is the OR of the
  three pairs.

| a b cin | sum cout |
|---|---|
| 0 0 0 | 0 0 |
| 0 0 1 | 1 0 |
| 0 1 0 | 1 0 |
| 0 1 1 | 0 1 |
| 1 0 0 | 1 0 |
| 1 0 1 | 0 1 |
| 1 1 0 | 0 1 |
| 1 1 1 | 1 1 |

# 3. Half subtractor — `half_sub.v`

Computes `a - b` for single bits. `borrow` says whether we had to borrow from
the next bit.

```verilog
module half_sub(input a, input b, output difference, output borrow);
    assign difference = a ^ b;
    assign borrow     = (~a) & b;
endmodule
```

- `difference = a ^ b`: same as the adder's sum bit.
- `borrow = (~a) & b`: borrowing is only needed for 0 - 1.

| a b | difference borrow |
|---|---|
| 0 0 | 0 0 |
| 0 1 | 1 1 |
| 1 0 | 1 0 |
| 1 1 | 0 0 |

# 4. Full subtractor — `full_sub.v`

Computes `a - b - borrow_in`, so subtractors can be chained.

```verilog
module full_sub(input a, input b, input borrow_in,
                output difference, output borrow_out);
    assign difference = a ^ b ^ borrow_in;
    assign borrow_out = ((~a) & b) | ((~(a ^ b)) & borrow_in);
endmodule
```

- `difference` is again a 3-input XOR.
- `borrow_out` has two cases: `(~a) & b` is the half-subtractor borrow
  (0 - 1). `(~(a ^ b)) & borrow_in` covers `a == b` with an incoming borrow,
  since then subtracting the borrow still needs one from the next bit.

| a b bin | difference bout |
|---|---|
| 0 0 0 | 0 0 |
| 0 0 1 | 1 1 |
| 0 1 0 | 1 1 |
| 0 1 1 | 0 1 |
| 1 0 0 | 1 0 |
| 1 0 1 | 0 0 |
| 1 1 0 | 0 0 |
| 1 1 1 | 1 1 |

---

# The testbenches

All four testbenches have the same shape (shown for the half adder):

```verilog
module half_adder_tb;
    reg a, b;            // inputs are reg: the testbench assigns them
    wire sum, carry;     // outputs are wire: driven by the module

    half_adder uut(.a(a), .b(b), .sum(sum), .carry(carry));

    integer i;
    initial begin
        $display("a b | sum carry");
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i;  // low 2 bits of i become a and b
            #10;         // wait 10 time units for the outputs to settle
            $display("%b %b |  %b    %b", a, b, sum, carry);
        end
        $finish;
    end
endmodule
```

- `uut` ("unit under test") is an instance of the module. `.a(a)` connects
  the module's port `a` to the testbench signal `a`.
- `reg` vs `wire`: a testbench signal that the `initial` block assigns must be
  a `reg`; a signal driven by a module output must be a `wire`.
- `{a, b} = i;` counts through every input combination: `i = 0..3` gives
  `00, 01, 10, 11`. The full adder and full subtractor loop to 8 with three
  inputs (`{a, b, cin} = i`), giving all 8 rows, in the same order as the
  expected output.
- `#10;` is needed because `assign` outputs update a moment after the inputs
  change. Printing without the delay would show the old output.
- `$display` prints one line, `$finish` ends the simulation.
