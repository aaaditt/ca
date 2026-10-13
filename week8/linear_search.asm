    .data
array:          .word 9, 10, 11, 12, 13, 14, 15, 16, 17, 18
num:            .asciiz "Enter number to be found: "
found:          .asciiz "The number is found at index "
not_found:      .asciiz "The number is not found."

    .text
main:           li $v0, 4
                la $a0, num
                syscall

                li $v0, 5
                syscall
                move $a2, $v0          #a2 = number to be found

                la $a0, array          #a0 = address of the array
                li $a1, 10             #a1 = total number of elements
                jal search

                beqz $v0, not_found1   #v0 = 0 means not found
                move $t0, $v1          #save the index, a0 is needed for printing

                li $v0, 4
                la $a0, found
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                j exit

not_found1:     li $v0, 4
                la $a0, not_found
                syscall

exit:           li $v0, 10
                syscall

search:         li $t0, 0              #i = 0

loop:           beq $t0, $a1, fail
                lw $t1, 0($a0)
                beq $t1, $a2, success
                addi $t0, $t0, 1
                addi $a0, $a0, 4
                j loop

success:        li $v0, 1              #1 = found
                move $v1, $t0          #v1 = index
                jr $ra

fail:           li $v0, 0              #0 = not found
                jr $ra
