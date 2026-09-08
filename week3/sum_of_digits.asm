        .data
input:  .asciiz "Enter a number: "
result: .asciiz "The sum of digits: "

        .text
main:   li $v0,4
        la $a0,input
        syscall

        li $v0,5
        syscall
        move $t0,$v0

        li $t1,10
        li $t2,0

sum:    beq $t0,$zero,end
        j loop

loop:   div $t0,$t1
        mfhi $t3
        add $t2,$t2,$t3
        mflo $t0
        j sum

end:    li $v0, 4
        la $a0, result
        syscall

        li $v0,1
        move $a0,$t2
        syscall

        li $v0,10
        syscall