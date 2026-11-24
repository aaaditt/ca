# Week 12 — Code Explanations

Week 12 builds directly on the 1-bit primitives from Week 11, moving to **multi-bit modular datapath design** and **2's complement signed arithmetic** in Verilog:

1. `signed_add8.v` / `signed_add8_tb.v` — 8-bit signed ripple-carry adder with overflow detection
2. `signed_sub8.v` / `signed_sub8_tb.v` — 8-bit signed ripple-borrow subtractor with overflow detection

---

## Commands to Compile and Run on the System

Navigate to the `week12` folder in PowerShell, Command Prompt, or VS Code terminal:

```powershell
cd C:\Aadit\BITS\3yrsem1\ca\week12
```

### 1. Compile & Run 8-bit Signed Adder:
```powershell
iverilog -o signed_add8.vvp signed_add8.v signed_add8_tb.v
vvp signed_add8.vvp
```

### 2. Compile & Run 8-bit Signed Subtractor:
```powershell
iverilog -o signed_sub8.vvp signed_sub8.v signed_sub8_tb.v
vvp signed_sub8.vvp
```

### Run Both in One Shot (PowerShell):
```powershell
foreach ($n in "signed_add8","signed_sub8") { "=== $n ==="; iverilog -o "$n.vvp" "$n.v" "${n}_tb.v"; vvp "$n.vvp" }
```

> **Note on `$finish`:** At the end of every run, you will see a message like `signed_add8_tb.v:24: $finish called at 120 (1s)`. This is completely normal; it signals that the testbench completed all test vectors and exited cleanly.

---

# Part A — Bugs, Corrections, and Observations

All modules and testbenches were compiled and simulated with Icarus Verilog (`iverilog` + `vvp`) and verified:

1. **Self-Contained Building Blocks:** 
   `signed_add8.v` defines `full_adder` at the top of the file, and `signed_sub8.v` defines `full_sub` at the top of its file. This makes each file completely self-contained—you do **not** need to include `week11/full_adder.v` when compiling `signed_add8.v`.
   *(Crucial note: Do not compile `signed_add8.v` and `week11/full_adder.v` together in the same command, as `iverilog` will report a duplicate module error).*

2. **Hardware Transparency in Two's Complement:**
   A standard binary ripple-carry adder works identically for both unsigned and signed numbers at the gate level! The bit addition rules are unchanged. What distinguishes signed arithmetic is:
   - How the bit patterns are interpreted (signed decimal range `-128` to `+127`).
   - How **overflow** is detected (inspecting the carries into and out of the sign bit).

3. **Bit Indexing and Vector Slices:**
   `input [7:0] a` represents an 8-bit bus where `a[7]` is the Most Significant Bit (MSB / sign bit) and `a[0]` is the Least Significant Bit (LSB).

---

# Part B — What is New in Week 12

| Concept | Week 11 | Week 12 |
|---|---|---|
| **Width** | 1-bit scalar signals (`a`, `b`) | Multi-bit vectors/buses (`[7:0] a`, `[7:0] b`) |
| **Circuit Design** | Primitives / Equations (`assign sum = a ^ b ^ cin;`) | **Structural hierarchy**: Instantiating and chaining 8 lower-level modules (`full_adder`, `full_sub`) |
| **Number System** | Raw logic truth tables (0 and 1) | **Two's complement signed integers** (`-128` to `+127`) |
| **Error Flags** | Simple carry-out / borrow-out | **Arithmetic overflow** flag (`c7 ^ c8` / `br7 ^ br8`) |
| **Testbench Style** | Exhaustive `for` loops ($2^2=4$ or $2^3=8$ combinations) | Directed test cases targeting positive, negative, zero, and overflow edges |
| **Testbench Printing** | `%b` (binary bits) | `%4d` (formatted signed decimals) using `reg signed [7:0]` |

---

# 1. 8-Bit Signed Adder — `signed_add8.v`

### How it Works
The 8-bit adder is implemented as a **ripple-carry adder**. It chains 8 identical 1-bit `full_adder` modules:
- Bit 0 takes the external carry-in `1'b0` (constant 0) because there is no incoming carry.
- The carry-out of each bit (`c1, c2, ..., c7`) ripples into the carry-in of the next higher bit.
- The carry-out of bit 7 is `c8`.

```verilog
// 1-bit full adder (building block)
module full_adder(input a, input b, input cin, output sum, output cout);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

// 8-bit signed adder: sum = a + b
module signed_add8(input [7:0] a, input [7:0] b, output [7:0] sum, output overflow);
    wire c1, c2, c3, c4, c5, c6, c7, c8;

    full_adder fa0(.a(a[0]), .b(b[0]), .cin(1'b0), .sum(sum[0]), .cout(c1));
    full_adder fa1(.a(a[1]), .b(b[1]), .cin(c1),   .sum(sum[1]), .cout(c2));
    full_adder fa2(.a(a[2]), .b(b[2]), .cin(c2),   .sum(sum[2]), .cout(c3));
    full_adder fa3(.a(a[3]), .b(b[3]), .cin(c3),   .sum(sum[3]), .cout(c4));
    full_adder fa4(.a(a[4]), .b(b[4]), .cin(c4),   .sum(sum[4]), .cout(c5));
    full_adder fa5(.a(a[5]), .b(b[5]), .cin(c5),   .sum(sum[5]), .cout(c6));
    full_adder fa6(.a(a[6]), .b(b[6]), .cin(c6),   .sum(sum[6]), .cout(c7));
    full_adder fa7(.a(a[7]), .b(b[7]), .cin(c7),   .sum(sum[7]), .cout(c8));

    // signed overflow: carry into sign bit (c7) differs from carry out of it (c8)
    assign overflow = c7 ^ c8;
endmodule
```

### The Overflow Rule for Addition: `overflow = c7 ^ c8`
In 8-bit two's complement, numbers range from $-128$ to $+127$.
- Adding two positive numbers can produce a result $> +127$ (positive overflow), which accidentally sets the sign bit to 1 (negative). Here `c7 = 1` and `c8 = 0` $\implies$ `1 ^ 0 = 1`.
- Adding two negative numbers can produce a result $< -128$ (negative overflow), which accidentally sets the sign bit to 0 (positive). Here `c7 = 0` and `c8 = 1` $\implies$ `0 ^ 1 = 1`.
- Adding a positive and a negative number **can never overflow** because the sum is always strictly between the two operands. In that case, `c7` and `c8` are always equal, giving `c7 ^ c8 = 0`.

### Simulation Output & Test Cases (`signed_add8_tb.v`)

| a | b | Sum | Overflow | Explanation |
|---|---|---|---|---|
| `5` | `3` | `8` | `0` | Normal positive addition |
| `-5` | `-3` | `-8` | `0` | Normal negative addition |
| `50` | `-70` | `-20` | `0` | Mixed signs (never overflows) |
| `-50` | `70` | `20` | `0` | Mixed signs |
| `0` | `0` | `0` | `0` | Zero inputs |
| `-1` | `1` | `0` | `0` | Negative and positive cancellation |
| `100` | `27` | `127` | `0` | Maximum positive value that fits in 8 bits |
| `127` | `1` | `-128` | **`1`** | **Positive overflow**: $127 + 1 = +128$, but wraps to $-128$ |
| `100` | `100` | `-56` | **`1`** | **Positive overflow**: $100 + 100 = +200$, wraps to $-56$ |
| `-128` | `-1` | `127` | **`1`** | **Negative overflow**: $-128 + (-1) = -129$, wraps to $+127$ |
| `-100` | `-100` | `56` | **`1`** | **Negative overflow**: $-200$, wraps to $+56$ |
| `-128` | `127` | `-1` | `0` | Extreme opposite values (fits in 8 bits) |

---

# 2. 8-Bit Signed Subtractor — `signed_sub8.v`

### How it Works
The 8-bit subtractor is built as a **ripple-borrow chain** of 8 `full_sub` modules:
- Bit 0 takes the initial `borrow_in = 1'b0`.
- Each bit's borrow-out (`br1, br2, ..., br7`) ripples into the borrow-in of the next bit.
- The borrow-out of bit 7 is `br8`.

```verilog
// 1-bit full subtractor (building block)
module full_sub(input a, input b, input borrow_in, output difference, output borrow_out);
    assign difference = a ^ b ^ borrow_in;
    assign borrow_out = ((~a) & b) | ((~(a ^ b)) & borrow_in);
endmodule

// 8-bit signed subtractor: diff = a - b
module signed_sub8(input [7:0] a, input [7:0] b, output [7:0] diff, output overflow);
    wire br1, br2, br3, br4, br5, br6, br7, br8;

    full_sub fs0(.a(a[0]), .b(b[0]), .borrow_in(1'b0), .difference(diff[0]), .borrow_out(br1));
    full_sub fs1(.a(a[1]), .b(b[1]), .borrow_in(br1),  .difference(diff[1]), .borrow_out(br2));
    full_sub fs2(.a(a[2]), .b(b[2]), .borrow_in(br2),  .difference(diff[2]), .borrow_out(br3));
    full_sub fs3(.a(a[3]), .b(b[3]), .borrow_in(br3),  .difference(diff[3]), .borrow_out(br4));
    full_sub fs4(.a(a[4]), .b(b[4]), .borrow_in(br4),  .difference(diff[4]), .borrow_out(br5));
    full_sub fs5(.a(a[5]), .b(b[5]), .borrow_in(br5),  .difference(diff[5]), .borrow_out(br6));
    full_sub fs6(.a(a[6]), .b(b[6]), .borrow_in(br6),  .difference(diff[6]), .borrow_out(br7));
    full_sub fs7(.a(a[7]), .b(b[7]), .borrow_in(br7),  .difference(diff[7]), .borrow_out(br8));

    // signed overflow: borrow into sign bit (br7) differs from borrow out of it (br8)
    assign overflow = br7 ^ br8;
endmodule
```

### The Overflow Rule for Subtraction: `overflow = br7 ^ br8`
For subtraction $A - B$:
- Subtracting a negative from a positive ($+A - (-B) = A + B$) can exceed $+127$.
- Subtracting a positive from a negative ($-A - (+B) = -(A + B)$) can go below $-128$.
- Subtracting two numbers of the same sign **can never overflow**.
- Just like the adder, signed subtraction overflow occurs if and only if the borrow into the sign bit differs from the borrow out of it: `assign overflow = br7 ^ br8;`.

### Simulation Output & Test Cases (`signed_sub8_tb.v`)

| a | b | Diff | Overflow | Explanation |
|---|---|---|---|---|
| `5` | `3` | `2` | `0` | Normal positive subtraction |
| `3` | `5` | `-2` | `0` | Smaller minus larger positive |
| `-5` | `-3` | `-2` | `0` | Both negative ($-5 - (-3) = -2$) |
| `-5` | `3` | `-8` | `0` | Negative minus positive |
| `50` | `-70` | `120` | `0` | Positive minus negative ($50 - (-70) = 120 \le 127$) |
| `0` | `0` | `0` | `0` | Zero inputs |
| `0` | `1` | `-1` | `0` | $0 - 1 = -1$ |
| `100` | `27` | `73` | `0` | Normal subtraction |
| `100` | `-100` | `-56` | **`1`** | **Positive overflow**: $100 - (-100) = +200 > 127$, wraps to $-56$ |
| `-128` | `1` | `127` | **`1`** | **Negative overflow**: $-128 - 1 = -129 < -128$, wraps to $+127$ |
| `-100` | `100` | `56` | **`1`** | **Negative overflow**: $-100 - 100 = -200$, wraps to $+56$ |
| `127` | `-1` | `-128` | **`1`** | **Positive overflow**: $127 - (-1) = +128$, wraps to $-128$ |
| `-128` | `-128` | `0` | `0` | Identical minimum values ($-128 - (-128) = 0$) |

---

# Part C — The Testbenches & Simulation Details

### Key Verilog Features Used in Week 12 Testbenches

```verilog
module signed_add8_tb;
    reg  signed [7:0] a, b;       // signed keyword enables signed arithmetic formatting
    wire signed [7:0] sum;
    wire overflow;

    signed_add8 uut(.a(a), .b(b), .sum(sum), .overflow(overflow));

    initial begin
        $display("   a +    b =  sum | overflow");
        a = 8'd5;    b = 8'd3;    #10; $display("%4d + %4d = %4d |    %b", a, b, sum, overflow);
        ...
        $finish;
    end
endmodule
```

1. **`signed` Keyword:**
   - Declaring `reg signed [7:0]` tells Verilog that values with bit 7 = 1 should be treated as negative numbers when evaluated or formatted.
   - Without `signed`, a bit pattern of `8'b11111011` would be printed as `251`. With `signed`, it is correctly printed as `-5`.

2. **Decimal Literals:**
   - `8'd100`: an 8-bit decimal literal for `+100`.
   - `-8'd50`: an 8-bit negative decimal literal for `-50`.

3. **Format Specifiers:**
   - `%4d`: prints a signed integer in decimal, padded to 4 character widths so all columns in the truth table stay aligned.
   - `%b`: prints a 1-bit binary flag (`0` or `1`) for `overflow`.

4. **Time Delays (`#10;`):**
   - Because ripple adders/subtractors propagate carries/borrows through 8 stages of gates, outputs do not update instantaneously in simulation time.
   - `#10;` delays execution by 10 simulation time units, giving the ripple chain sufficient time to settle before `$display` reads and prints the wires.
