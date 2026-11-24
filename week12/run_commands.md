# How to Run the Week 12 Verilog Codes

To run the codes in Week 12, open your terminal (PowerShell, Command Prompt, or VS Code terminal), navigate to this directory, and use the commands below:

```powershell
cd C:\Aadit\BITS\3yrsem1\ca\week12
```

---

## 1. To run the 8-Bit Signed Adder:
Use this command to compile `signed_add8.v` and its testbench `signed_add8_tb.v`, and then run the simulation:

```powershell
iverilog -o signed_add8.vvp signed_add8.v signed_add8_tb.v
vvp signed_add8.vvp
```

---

## 2. To run the 8-Bit Signed Subtractor:
Use this command to compile `signed_sub8.v` and its testbench `signed_sub8_tb.v`, and then run the simulation:

```powershell
iverilog -o signed_sub8.vvp signed_sub8.v signed_sub8_tb.v
vvp signed_sub8.vvp
```

---

## 3. To run both codes together in one command:
Use this PowerShell one-liner to compile and run both the adder and subtractor sequentially:

```powershell
foreach ($n in "signed_add8","signed_sub8") { "=== $n ==="; iverilog -o "$n.vvp" "$n.v" "${n}_tb.v"; vvp "$n.vvp" }
```

---

### What each part of the command does:
- `iverilog`: The Icarus Verilog compiler that checks syntax and compiles the hardware module and testbench together.
- `-o <name>.vvp`: Specifies the name of the compiled simulation file.
- `<design>.v <design>_tb.v`: Compiles both the circuit design and the testbench together so the testbench can link to the module.
- `vvp <name>.vvp`: The Verilog Virtual Processor runtime engine that executes the simulation and displays the output table.
- **Note:** The line `$finish called at ...` at the end of each run is normal and indicates that the testbench completed all test cases and exited cleanly.
