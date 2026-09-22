	.data
array1: .word 11, 13, 15, 17, 19
array2: .word 1, 3, 5, 7, 9
array3: .word 0, 0, 0, 0, 0
result: .asciiz "The resultant array is: "
space: .asciiz " "
	.text

main: 	la $t1, array1
	la $t2, array2
	la $t3, array3

	li $t4,0  #index counter
	li $t5,5  

loop:	beq $t4, $t5, end
	lw $t6, 0($t1)
	lw $t7, 0($t2)
	add $t0, $t6, $t7    #sum = array1[i] + array2[i]
	sw $t0, 0($t3)
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	addi $t4, $t4, 1
	j loop

end: 	li $v0, 4
	la $a0, result
	syscall

	la $t3, array3
	li $t4, 0

p_loop:	beq $t4, $t5, exit
	li $v0,4
	la $a0,space
	syscall

	li $v0,1
	lw $a0,0($t3)
	syscall
	addi $t3, $t3, 4
	addi $t4, $t4, 1
	j p_loop

exit:	li $v0, 10
	syscall
