.data
msg1:   .asciiz "Enter a number: "
msg2:   .asciiz "The factorial is: "

    .text
    .globl main
main:
    li $v0, 4           # print string
    la $a0, msg1
    syscall

    li $v0, 5           # read integer -> $v0
    syscall
    move $t0, $v0       # $t0 = N

    li $t1, 1           # $t1 = fact = 1
    li $t2, 1           # $t2 = i = 1

loop:
    bgt $t2, $t0, over  # if i > N, exit loop
    mul $t1, $t1, $t2   # fact = fact * i
    addi $t2, $t2, 1    # i = i + 1
    j loop              # repeat loop

over:
    li $v0, 4           # print string
    la $a0, msg2
    syscall

    li $v0, 1           # print integer
    move $a0, $t1
    syscall

    li $v0, 10          # exit
    syscall

.end main
