        .data
input:  .asciiz "Enter a number to check for odd or even: "
odd_res: .asciiz "Thn Number you entered is odd"
even_res: .asciiz "The Number you entered in Even"

        .text
main:   li $v0,4
        la $a0,input
        syscall

        li $v0,5
        syscall
        move $t0,$v0

        li $t1,2
        div $t0,$t1
        mfhi $t2
        beq $t2,$zero,even
        j odd

        even:
        li $v0,4
        la $a0,even_res
        syscall
        j end

        odd:
        li $v0,4
        la $a0,odd_res
        syscall

        end:
        li $v0,10
        syscall

