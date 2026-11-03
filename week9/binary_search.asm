    .data
array:          .word 2, 5, 8, 12, 16, 23, 38, 56, 72, 91     #must be sorted
num:            .asciiz "Enter number to be found: "
found:          .asciiz "The number is found at index "
not_found:      .asciiz "The number is not found."

    .text
main:           li $v0, 4
                la $a0, num
                syscall

                li $v0, 5
                syscall
                move $a1, $v0          #a1 = data (number to be found)

                la $a0, array          #a0 = address of the array
                li $a2, 0              #a2 = lo = first index
                li $a3, 9              #a3 = hi = last index
                jal bin_search

                bltz $v0, not_found1   #v0 = -1 means not found
                move $t0, $v0          #save the index, a0 is needed for printing

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

bin_search:     addi $sp, $sp, -4      #make space for 1 word on the stack
                sw $ra, 0($sp)

                bgt $a2, $a3, fail     #lo > hi -> range is empty

                add $t0, $a2, $a3
                sra $t0, $t0, 1        #t0 = mid = (lo + hi) / 2

                sll $t1, $t0, 2        #t1 = mid * 4 (byte offset)
                add $t1, $a0, $t1      #t1 = address of A[mid]
                lw $t2, 0($t1)         #t2 = A[mid]

                beq $a1, $t2, success  #data == A[mid]
                blt $a1, $t2, left     #data < A[mid]

                addi $a2, $t0, 1       #data > A[mid]: lo = mid + 1, hi stays
                jal bin_search
                j bs_end

left:           addi $a3, $t0, -1      #hi = mid - 1, lo stays
                jal bin_search
                j bs_end

success:        move $v0, $t0          #return mid
                j bs_end

fail:           li $v0, -1             #return -1

bs_end:         lw $ra, 0($sp)
                addi $sp, $sp, 4
                jr $ra
