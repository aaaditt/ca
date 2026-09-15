    .data
inp1: .asciiz "Enter the first integer: "
inp2: .asciiz "Enter the second integer: "
inp3: .asciiz "Enter the third integer: "
inp4: .asciiz "ENter the fourth integer: "
inp5: .asciiz "Enter the fifth integer: "
res: .asciiz "The ans is: "

    .text

main:   li $v0,4
        la $a0,inp1
        syscall

        li $v0,5
        syscall
        move $t0,$v0

        li $v0,4
        la $a0,inp2
        syscall

        li $v0,5
        syscall
        move $t1,$v0

        li $v0,4
        la $a0,inp3
        syscall

        li $v0,5
        syscall
        move $t2,$v0

        li $v0,4
        la $a0,inp4
        syscall

        li $v0,5
        syscall
        move $t3,$v0

        li $v0,4
        la $a0,inp5
        syscall

        li $v0,5
        syscall
        move $t4,$v0
        
        mult $t0,$t1
        mflo $t5
        div $t5,$t2
        mflo $t6
        div $t6,$t2
        mfhi $t7
        add $t8,$t7,$t4

        li $v0,4
        la $a0,res
        syscall

        li $v0,1
        move $a0,$t8
        syscall

        li $v0,10
        syscall

