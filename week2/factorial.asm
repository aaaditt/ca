.data                               # start of data section — declare strings/variables here
msg1:   .asciiz "Enter a number: "  # msg1 stores the prompt string (null-terminated)
msg2:   .asciiz "The factorial is: " # msg2 stores the output label string

    .text                           # start of code section — instructions go here
    .globl main                     # tell the assembler 'main' is the entry point
main:
    li $v0, 4                       # load 4 into $v0 (4 = syscall code for "print string")
    la $a0, msg1                    # load address of msg1 into $a0 (the string to print)
    syscall                         # OS prints "Enter a number: "

    li $v0, 5                       # load 5 into $v0 (5 = syscall code for "read integer")
    syscall                         # user types a number; result lands in $v0
    move $t0, $v0                   # copy $v0 → $t0 to save N (we need $v0 free for future syscalls)

    li $t1, 1                       # $t1 = 1  — this holds the factorial result (starts at 1, NOT 0!)
    li $t2, 1                       # $t2 = 1  — this is our counter i (starts at 1)

    # ── HOW THE LOOP WORKS ────────────────────────────────────────────────────
    # We want to compute: 1 * 2 * 3 * ... * N
    # Think of it as: keep multiplying fact by i, then i++, until i > N
    # In C it would be:   for (i = 1; i <= N; i++) { fact = fact * i; }
    # In MIPS there's no for/while — we fake it with a label + branch + jump
    # ─────────────────────────────────────────────────────────────────────────

loop:                               # LABEL — sticky note marking the TOP of our loop
    bgt $t2, $t0, over              # "branch if greater than": if i ($t2) > N ($t0), jump to 'over'
                                    #   → this is the EXIT CHECK. once i passes N, we leave the loop
    mul $t1, $t1, $t2               # multiply: fact = fact * i  ($t1 = $t1 * $t2)
                                    #   → this is the LOOP BODY — the actual work being done
    addi $t2, $t2, 1                # add immediate: i = i + 1  — move the counter forward
    j loop                          # unconditional jump: go back to 'loop' label (top of loop)
                                    #   → without this, the program would just fall through and stop

over:                               # LABEL — we land here when i > N (loop is finished)
    li $v0, 4                       # load 4 into $v0 (syscall code for "print string")
    la $a0, msg2                    # load address of msg2 ("The factorial is: ") into $a0
    syscall                         # OS prints the result label

    li $v0, 1                       # load 1 into $v0 (1 = syscall code for "print integer")
    move $a0, $t1                   # copy fact ($t1) into $a0 — $a0 is the argument for print
    syscall                         # OS prints the factorial result number

    li $v0, 10                      # load 10 into $v0 (10 = syscall code for "exit")
    syscall                         # OS exits the program cleanly

.end main                           # marks the end of the main function
