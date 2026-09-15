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
    div $t0,$t1
    mfhi $t2

    bne $t2,$zero,prime

    prime:
        li $v0,4
        la $a0,res1
        syscall

    not_prime:
        li $v0,4
        la $a0,res2
        syscall

    li $v0,10
    syscall