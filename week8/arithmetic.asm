    .data
num1:           .asciiz "Enter the first number (x): "
num2:           .asciiz "Enter the second number (y): "
sum_msg:        .asciiz "Sum (x + y) = "
diff_msg:       .asciiz "\nDifference (x - y) = "
prod_msg:       .asciiz "\nProduct (x * y) = "
quot_msg:       .asciiz "\nQuotient (x / y) = "

    .text
main:           li $v0, 4
                la $a0, num1
                syscall

                li $v0, 5
                syscall
                move $s0, $v0          #s0 = x

                li $v0, 4
                la $a0, num2
                syscall

                li $v0, 5
                syscall
                move $s1, $v0          #s1 = y

                move $a0, $s0
                move $a1, $s1
                jal sum
                move $t0, $v0          #save the result

                li $v0, 4
                la $a0, sum_msg
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                move $a0, $s0
                move $a1, $s1
                jal difference
                move $t0, $v0

                li $v0, 4
                la $a0, diff_msg
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                move $a0, $s0
                move $a1, $s1
                jal product
                move $t0, $v0

                li $v0, 4
                la $a0, prod_msg
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                move $a0, $s0
                move $a1, $s1
                jal quotient
                move $t0, $v0

                li $v0, 4
                la $a0, quot_msg
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                li $v0, 10
                syscall

sum:            add $v0, $a0, $a1
                jr $ra

difference:     sub $v0, $a0, $a1
                jr $ra

product:        mul $v0, $a0, $a1
                jr $ra

quotient:       div $a0, $a1
                mflo $v0
                jr $ra
