    .data
one:            .float 1.0
msg_a:          .asciiz "Enter the base (a): "
msg_n:          .asciiz "Enter the power (n): "
result:         .asciiz "a to the power n is: "
undefined:      .asciiz "0 to a negative power is undefined (1 / 0)."

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
                bltz $a1, negative     #n < 0 -> answer is 1 / a^(-n), a fraction

                jal power
                move $t0, $v0          #save a^n, the print syscalls reuse v0 and a0

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                j exit

negative:       beqz $a0, zero_base    #0^(-n) = 1 / 0, not defined

                sub $a1, $zero, $a1    #a1 = -n, which is positive
                jal power              #v0 = a^(-n)

                mtc1 $v0, $f1          #copy the integer bits into f1
                cvt.s.w $f1, $f1       #convert integer -> float
                l.s $f2, one
                div.s $f12, $f2, $f1   #f12 = 1 / a^(-n), print float uses f12

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 2
                syscall

                j exit

zero_base:      li $v0, 4
                la $a0, undefined
                syscall

exit:           li $v0, 10
                syscall

power:          addi $sp, $sp, -8      #make space for 2 words on the stack
                sw $ra, 4($sp)
                sw $s0, 0($sp)

                move $s0, $a0          #s0 = a, needed after the recursive call
                blez $a1, base         #n = 0 -> a^0 = 1 (main never passes a negative n)

                addi $a1, $a1, -1      #argument = n - 1 (a0 still holds a)
                jal power              #v0 = a^(n - 1)
                mul $v0, $s0, $v0      #a^n = a * a^(n - 1)

                j power_end

base:           li $v0, 1              #a^0 = 1

power_end:      lw $s0, 0($sp)
                lw $ra, 4($sp)
                addi $sp, $sp, 8
                jr $ra
