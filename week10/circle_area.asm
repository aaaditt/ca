    .data
pi:             .float 3.14159265
msg:            .asciiz "Enter the radius: "
result:         .asciiz "The area of the circle is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall

                li $v0, 6
                syscall

                l.s $f1, pi
                mul.s $f2, $f0, $f0
                mul.s $f12, $f1, $f2

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 2
                syscall

                li $v0, 10
                syscall
