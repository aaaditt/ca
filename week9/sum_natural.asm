    .data
msg:            .asciiz "Enter n: "
result:         .asciiz "Sum of the first n natural numbers is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall

                li $v0, 5
                syscall
                move $a0, $v0          #a0 = n

                jal rsum
                move $t0, $v0          #save the sum, the print syscalls reuse v0 and a0

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                li $v0, 10
                syscall

rsum:           addi $sp, $sp, -8      #make space for 2 words on the stack
                sw $ra, 4($sp)
                sw $s0, 0($sp)

                move $s0, $a0          #s0 = n, needed after the recursive call
                li $t0, 1
                ble $s0, $t0, base     #n = 1 (or 0) -> sum is n itself

                addi $a0, $s0, -1      #argument = n - 1
                jal rsum               #v0 = RSum(n - 1)
                add $v0, $s0, $v0      #RSum(n) = n + RSum(n - 1)

                j rsum_end

base:           move $v0, $s0          #RSum(1) = 1, RSum(0) = 0

rsum_end:       lw $s0, 0($sp)
                lw $ra, 4($sp)
                addi $sp, $sp, 8
                jr $ra
