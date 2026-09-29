    .data
string:         .asciiz "Computer Architecture"
revstr:         .space 100
output:         .asciiz "The reversed string is: "

    .text  
main:           la $t0, string
                li $t1, 0
  
str_length:     lbu $t2, 0($t0)
                beqz $t2, end_loop
                addi $t0, $t0, 1
                addi $t1, $t1, 1
                j str_length
 	
end_loop:       la $t3, revstr
                addi $t0, $t0, -1
 
rev_loop:       bge $zero, $t1, end_rev_loop
                lbu $t4, 0($t0)
                sb $t4, 0($t3)
                addi $t0, $t0, -1
                addi $t3, $t3, 1
                addi $t1, $t1, -1
                j rev_loop

end_rev_loop:   sb $zero, 0($t3)

                li $v0, 4
                la $a0, output
                syscall

                li $v0, 4
                la $a0, revstr
                syscall

                li $v0, 10
                syscall
