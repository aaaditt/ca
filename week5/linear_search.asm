    .data
num:        .asciiz "Enter number to be found: "
found:      .asciiz "The number is found at "
not_found:  .asciiz "The number is not found."
array:      .word 9, 10, 11, 12, 13, 14, 15, 16, 17, 18

    .text
main:       li $v0,4
	        la $a0,num
	        syscall

	        li $v0,5
	syscall
	move $t0,$v0
 
	la $t1, array   # loads address of the array
	li $t2, 10      # loading the length of the array
	li $t3, 0       # i = 0

loop: 	beq $t3, $t2, not_found1
	lw $t4, 0($t1)
	beq $t4, $t0, found1
	addi $t3, $t3, 1
	addi $t1, $t1, 4
	j loop

found1: li $v0, 4
	la $a0, found
	syscall

	li $v0,1
	move $a0,$t3
	syscall

	j exit

not_found1: li $v0,4
	       la $a0,not_found
	       syscall

exit: 	li $v0, 10
	syscall
