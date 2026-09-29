    .data
msg:    .asciiz "Enter 5 elements: "
sum:    .asciiz "the sum of the array is: "
array:  .space 20   #or can write this as array:    .word   0,0,0,0,0 or .word 0:5
    .text

main:   li $v0,4
        la $a0,msg
        syscall

        la $t0,array

        li $v0,5
        syscall
        sw $v0,0($t0)

        li $v0,5
        syscall
        sw $v0,4($t0)

        li $v0,5
        syscall
        sw $v0,8($t0)

        li $v0,5
        syscall
        sw $v0,12($t0)

        li $v0,5
        syscall
        sw $v0,16($t0)

        li $t1,0
        li $t2,5
        li $t3,0

loop:   beq $t3,$t2,end
        lw $t4,0($t0)
        add $t1,$t1,$t4
        addi $t3,$t3,1
        addi $t0,$t0,4
        j loop

end:    li $v0,4
        la $a0,sum
        syscall

        li $v0,1
        move $a0,$t1
        syscall

        li $v0,10
        syscall
    