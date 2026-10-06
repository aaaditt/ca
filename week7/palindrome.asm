    .data
string:         .asciiz "malayalam"
pal:            .asciiz "The string is a palindrome"
not_pal:        .asciiz "The string is not a palindrome"

    .text
main:           la $t0, string
                la $t1, string

str_length:     lbu $t2, 0($t1)
                beqz $t2, end_loop
                addi $t1, $t1, 1
                j str_length

end_loop:       addi $t1, $t1, -1      #t1 is now at the last character

check:          bge $t0, $t1, pal1
                lbu $t2, 0($t0)
                lbu $t3, 0($t1)
                bne $t2, $t3, not_pal1
                addi $t0, $t0, 1
                addi $t1, $t1, -1
                j check

pal1:           li $v0, 4
                la $a0, pal
                syscall

                j exit

not_pal1:       li $v0, 4
                la $a0, not_pal
                syscall

exit:           li $v0, 10
                syscall
