    .data
int1: .asciiz "Enter the number: "
res1: .asciiz "it is a prime number"
res2: .asciiz "it is not a prime number"

    .text
main:
    li $v0,4
    la $a0,int1
    syscall

    li $v0,5
    syscall
    move $t0,$v0

    li $t1,2
    blt $t0,$t1,not_prime

loop:
    mul $t3,$t1,$t1
    bgt $t3,$t0,prime

    div $t0,$t1
    mfhi $t2
    beq $t2,$zero,not_prime

    addi $t1,$t1,1
    j loop

prime:
    li $v0,4
    la $a0,res1
    syscall
    j exit

not_prime:
    li $v0,4
    la $a0,res2
    syscall

exit:
    li $v0,10
    syscall
