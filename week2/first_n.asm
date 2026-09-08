.data                           # start of data section — declare variables/strings here
msg1:   .asciiz "Enter N: "    # msg1 is a string variable; .asciiz = null-terminated string
msg2:   .asciiz "Sum = "       # msg2 is another string variable for the output label
no:     .word 0                # 'no' is a memory slot (like int no = 0) to store N
sum:    .word 0                # 'sum' is a memory slot to store the running total

    .text                      # start of code section — instructions go here
    .globl main                # tell the assembler that 'main' is the entry point
main:
    li $v0, 4                  # load immediate: put 4 into $v0 (4 = syscall code for "print string")
    la $a0, msg1               # load address: put the address of msg1 into $a0 (the argument)
    syscall                    # execute the syscall — OS prints the string in $a0

    li $v0, 5                  # load 5 into $v0 (5 = syscall code for "read integer from keyboard")
    syscall                    # execute — user types a number; result lands in $v0
    sw $v0, no                 # store word: copy $v0's value into memory slot 'no' (saves N)

    li $t0, 0                  # load immediate: $t0 = 0  (this register will hold our running sum)
    li $t1, 1                  # load immediate: $t1 = 1  (this register is our counter i, starts at 1)
    lw $t2, no                 # load word: read N from memory slot 'no' into register $t2

next:                          # LABEL — marks the top of the loop; we jump back here each iteration
    bgt $t1, $t2, over         # branch if greater than: if i ($t1) > N ($t2), jump to 'over' (exit loop)
    add $t0, $t0, $t1          # add: sum = sum + i  (accumulate: $t0 = $t0 + $t1)
    addi $t1, $t1, 1           # add immediate: i = i + 1  (increment the counter by 1)
    j next                     # unconditional jump: go back to 'next' (top of loop) and repeat

over:                          # LABEL — we land here when the loop is done (i > N)
    sw $t0, sum                # store word: save the final sum from register $t0 into memory slot 'sum'

    li $v0, 4                  # load 4 into $v0 (syscall code for "print string")
    la $a0, msg2               # load address of msg2 ("Sum = ") into $a0
    syscall                    # OS prints "Sum = "

    li $v0, 1                  # load 1 into $v0 (1 = syscall code for "print integer")
    lw $a0, sum                # load word: read the sum from memory into $a0 (argument for print)
    syscall                    # OS prints the integer value of $a0

    li $v0, 10                 # load 10 into $v0 (10 = syscall code for "exit program")
    syscall                    # OS exits cleanly

.end main                      # marks the end of the main function (good practice)