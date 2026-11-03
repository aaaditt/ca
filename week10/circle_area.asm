    .data
pi:             .float 3.14159265
msg:            .asciiz "Enter the radius: "
result:         .asciiz "The area of the circle is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall

                li $v0, 6
                syscall                #f0 = radius (read float returns in f0)

                l.s $f1, pi            #f1 = pi
                mul.s $f2, $f0, $f0    #f2 = r * r
                mul.s $f12, $f1, $f2   #f12 = pi * r * r, print float uses f12

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 2
                syscall                #print the float in f12

                li $v0, 10
                syscall
