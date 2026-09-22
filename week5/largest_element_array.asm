	.data
result: .asciiz "The largest element is: "
array: .word 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
	.text

main: 	la $t0, array
	li $t1, 10
	li $t2, 1 
	lw $t3, 0($t0)
	addi $t0, $t0, 4

loop:	beq $t2, $t1, exit
	lw $t4, 0($t0)
	bgt $t4, $t3, largest
	addi $t2, $t2, 1
	addi $t0, $t0, 4
	j loop

largest:	move $t3, $t4
	addi $t2, $t2, 1
	addi $t0, $t0, 4
	j loop

exit:	li $v0, 4
	la $a0, result
	syscall

	li $v0,1
	move $a0, $t3
	syscall
	
	li $v0, 10
	syscall 
