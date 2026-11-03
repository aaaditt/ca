    .data
five:           .float 5.0
nine:           .float 9.0
thirty_two:     .float 32.0
msg:            .asciiz "Enter the temperature in Fahrenheit: "
result:         .asciiz "The temperature in Celsius is: "

    .text
main:           li $v0, 4
                la $a0, msg
                syscall

                li $v0, 6
                syscall                #f0 = fahrenheit

                l.s $f1, thirty_two
                sub.s $f2, $f0, $f1    #f2 = F - 32 (brackets first)

                l.s $f3, five
                mul.s $f2, $f2, $f3    #f2 = (F - 32) * 5, multiply first so 5/9 is never rounded on its own

                l.s $f4, nine
                div.s $f12, $f2, $f4   #f12 = (F - 32) * 5 / 9, print float uses f12

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 2
                syscall                #print the float in f12

                li $v0, 10
                syscall
