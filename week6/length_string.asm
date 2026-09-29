    .data
user_string:    .asciiz "this is a random string"
output: .asciiz "the string length is: "

    .text
main:       la $t0,user_string
            li $t1,0
        
loop_start: lb $t2, 0($t0)
            beqz $t2, loop_end
            addi $t1, $t1, 1
            addi $t0, $t0, 1
            j loop_start

loop_end:   li $v0, 4
            la $a0, output
            syscall

            li $v0,1
            move $a0,$t1
            syscall

            li $v0,10
            syscall
