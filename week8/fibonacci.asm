    .data
msg:            .asciiz "Enter n: "
result:         .asciiz "The nth Fibonacci term is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall

                li $v0, 5
                syscall
                move $a0, $v0          #a0 = n

                jal fib
                move $t0, $v0          #save fib(n), the print syscalls reuse v0 and a0

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 1
                move $a0, $t0
                syscall

                li $v0, 10
                syscall

fib:            addi $sp, $sp, -12     #make space for 3 words on the stack
                sw $ra, 8($sp)
                sw $s0, 4($sp)
                sw $s1, 0($sp)

                move $s0, $a0          #s0 = n
                li $t0, 1
                ble $s0, $t0, base     #n = 0 or n = 1

                addi $a0, $s0, -1
                jal fib
                move $s1, $v0          #s1 = fib(n - 1)

                addi $a0, $s0, -2
                jal fib
                add $v0, $s1, $v0      #fib(n) = fib(n - 1) + fib(n - 2)

                j fib_end

base:           move $v0, $s0          #fib(0) = 0, fib(1) = 1

fib_end:        lw $s1, 0($sp)
                lw $s0, 4($sp)
                lw $ra, 8($sp)
                addi $sp, $sp, 12
                jr $ra
