    .data
msg_a:          .asciiz "Enter a: "
msg_b:          .asciiz "Enter b: "
msg_c:          .asciiz "Enter c: "
msg_x:          .asciiz "Enter x: "
result:         .asciiz "The value of ax^2 + bx + c is: "

    .text
main:           li $v0, 4
                la $a0, msg_a
                syscall

                li $v0, 6
                syscall
                mov.s $f1, $f0

                li $v0, 4
                la $a0, msg_b
                syscall

                li $v0, 6
                syscall
                mov.s $f2, $f0

                li $v0, 4
                la $a0, msg_c
                syscall

                li $v0, 6
                syscall
                mov.s $f3, $f0

                li $v0, 4
                la $a0, msg_x
                syscall

                li $v0, 6
                syscall
                mov.s $f4, $f0

                mul.s $f5, $f4, $f4
                mul.s $f5, $f1, $f5
                mul.s $f6, $f2, $f4
                add.s $f12, $f5, $f6
                add.s $f12, $f12, $f3

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 2
                syscall

                li $v0, 10
                syscall
