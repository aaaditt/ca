.data
msg1:   .asciiz "Enter N: "
msg2:   .asciiz "Sum = "
no:     .word 0
sum:    .word 0

    .text
    .globl main
main:
    li $v0, 4           # print string
    la $a0, msg1
    syscall

    li $v0, 5           # read integer -> $v0
    syscall
    sw $v0, no          # store N in memory

    li $t0, 0           # $t0 = sum = 0
    li $t1, 1           # $t1 = i = 1
    lw $t2, no          # $t2 = N

next:
    bgt $t1, $t2, over  # if i > N, exit loop
    add $t0, $t0, $t1   # sum = sum + i
    addi $t1, $t1, 1    # i = i + 1
    j next              # repeat loop

over:
    sw $t0, sum         # save sum to memory

    li $v0, 4           # print string
    la $a0, msg2
    syscall

    li $v0, 1           # print integer
    lw $a0, sum
    syscall

    li $v0, 10          # exit
    syscall

.end main
