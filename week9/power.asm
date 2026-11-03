    .data
msg_a:          .asciiz "Enter the base (a): "
msg_n:          .asciiz "Enter the power (n): "
result:         .asciiz "a to the power n is: "

    .text
main:           li $v0, 4
                la $a0, msg_a
                syscall

                li $v0, 5
                syscall
                move $t0, $v0          #t0 = a

                li $v0, 4
                la $a0, msg_n
                syscall

                li $v0, 5
                syscall
                move $a1, $v0          #a1 = n

                move $a0, $t0          #a0 = a
                jal power
                move $t0, $v0          #save a^n, the print syscalls reuse v0 and a0

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                li $v0, 10
                syscall

power:          addi $sp, $sp, -8      #make space for 2 words on the stack
                sw $ra, 4($sp)
                sw $s0, 0($sp)

                move $s0, $a0          #s0 = a, needed after the recursive call
                blez $a1, base         #n = 0 -> a^0 = 1

                addi $a1, $a1, -1      #argument = n - 1 (a0 still holds a)
                jal power              #v0 = a^(n - 1)
                mul $v0, $s0, $v0      #a^n = a * a^(n - 1)

                j power_end

base:           li $v0, 1              #a^0 = 1

power_end:      lw $s0, 0($sp)
                lw $ra, 4($sp)
                addi $sp, $sp, 8
                jr $ra
