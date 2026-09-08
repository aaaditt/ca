        .data
operation: .asciiz "this is the operation that were going to follow: X * Y\n"
num1:   .asciiz "Enter the first number: "
num2:   .asciiz "Enter the 2nd number: "

result: .asciiz "the answer is: "
        .text
main:   li $v0,4
        la $a0, operation
        syscall


        li $v0,4
        la $a0,num1
        syscall

        li $v0,5
        syscall

        move $t0,$v0


        li $v0,4
        la $a0,num2
        syscall

        li $v0,5
        syscall

        move $t1,$v0

        mul $t2,$t1,$t0


        li $v0,4
        la $a0,result
        syscall

        li $v0,1
        move $a0,$t2
        syscall

	li $v0,10
	syscall

        li $v0,10
        syscall