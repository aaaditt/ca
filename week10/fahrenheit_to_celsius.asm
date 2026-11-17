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
                syscall

                l.s $f1, thirty_two
                sub.s $f2, $f0, $f1

                l.s $f3, five
                mul.s $f2, $f2, $f3

                l.s $f4, nine
                div.s $f12, $f2, $f4

                li $v0, 4
                la $a0, result
                syscall

                li $v0, 2
                syscall

                li $v0, 10
                syscall
