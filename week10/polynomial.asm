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
                mov.s $f1, $f0         #f1 = a, the next read overwrites f0

                li $v0, 4
                la $a0, msg_b
                syscall

                li $v0, 6
                syscall
                mov.s $f2, $f0         #f2 = b

                li $v0, 4
                la $a0, msg_c
                syscall

                li $v0, 6
                syscall
                mov.s $f3, $f0         #f3 = c

                li $v0, 4
                la $a0, msg_x
                syscall

                li $v0, 6
                syscall
                mov.s $f4, $f0         #f4 = x

                mul.s $f5, $f4, $f4    #f5 = x * x
                mul.s $f5, $f1, $f5    #f5 = a * x^2
                mul.s $f6, $f2, $f4    #f6 = b * x
                add.s $f12, $f5, $f6   #f12 = ax^2 + bx
                add.s $f12, $f12, $f3  #f12 = ax^2 + bx + c, print float uses f12

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 2
                syscall                #print the float in f12

                li $v0, 10
                syscall
