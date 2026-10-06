    .data
str1:           .asciiz "Computer "
str2:           .asciiz "Architecture"
result:         .space 100
output:         .asciiz "The concatenated string is: "

    .text
main:           la $t0, str1
                la $t1, str2
                la $t2, result

copy1:          lbu $t3, 0($t0)
                beqz $t3, copy2
                sb $t3, 0($t2)
                addi $t0, $t0, 1
                addi $t2, $t2, 1
                j copy1

copy2:          lbu $t3, 0($t1)
                beqz $t3, end_copy
                sb $t3, 0($t2)
                addi $t1, $t1, 1
                addi $t2, $t2, 1
                j copy2

end_copy:       sb $zero, 0($t2)

                li $v0, 4
                la $a0, output
                syscall

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 10
                syscall
