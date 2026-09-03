.data
msg1:   .asciiz "Enter a number: "
msg2:   .asciiz "The factorial is: "

    .text
    .globl main
main:
    # Print prompt message
    li $v0, 4
    la $a0, msg1
    syscall

    # Read integer N from user
    li $v0, 5
    syscall
    move $t0, $v0       # $t0 = N

    # Initialize factorial result = 1, counter i = 1
    li $t1, 1           # $t1 = factorial result
    li $t2, 1           # $t2 = counter i

loop:
    bgt $t2, $t0, over  # if i > N, exit loop
    mul $t1, $t1, $t2   # fact = fact * i
    addi $t2, $t2, 1    # i = i + 1
    j loop

over:
    # Print result message
    li $v0, 4
    la $a0, msg2
    syscall

    # Print factorial result integer
    li $v0, 1
    move $a0, $t1
    syscall

    # Exit program
    li $v0, 10
    syscall

.end main
