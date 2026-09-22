# Week 5 — Code Explanations

Week 5 covers arrays: finding the largest element, linear search, and
element-wise sum of two arrays. This file explains the logic of the
**corrected** programs (see `week5.md` in this same folder for the full list
of bugs that were found and fixed before this explanation was written).

---

## 1. `largest_element_array.asm` — find the maximum value in an array

```asm
.data
result: .asciiz "The largest element is: "
array: .word 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
.text

main:   la $t0, array      # $t0 = pointer to the array, starts at array[0]
        li $t1, 10         # $t1 = array length (10 elements)
        li $t2, 1          # $t2 = loop index i, starts at 1
        lw $t3, 0($t0)     # $t3 = array[0], the initial "current max"
        addi $t0, $t0, 4   # advance pointer to array[1]

loop:   beq $t2, $t1, exit     # if i == length, every element checked -> done
        lw $t4, 0($t0)         # $t4 = array[i]
        bgt $t4, $t3, largest  # if array[i] > current max, update the max
        addi $t2, $t2, 1       # else: i++
        addi $t0, $t0, 4       # advance pointer
        j loop

largest: move $t3, $t4     # new max found
        addi $t2, $t2, 1
        addi $t0, $t0, 4
        j loop

exit:   li $v0, 4
        la $a0, result
        syscall             # print "The largest element is: "

        li $v0, 1
        move $a0, $t3
        syscall             # print the max value

        li $v0, 10
        syscall             # exit
```

**Pattern:** "running maximum." One register (`$t3`) always holds the best
value seen so far. The array is walked once, front to back, using `$t0` as a
moving pointer (`addi $t0, $t0, 4` each step, since each `.word` is 4 bytes).
`$t3` is seeded with `array[0]` *before* the loop so the loop body only has
to handle comparisons for the remaining elements — this avoids the awkward
"what's the max before we've seen anything" problem.

---

## 2. `linear_search.asm` — search for a user-given value

```asm
.data
num:        .asciiz "Enter number to be found: "
found:      .asciiz "The number is found at "
not_found:  .asciiz "The number is not found."
array:      .word 9, 10, 11, 12, 13, 14, 15, 16, 17, 18

.text
main:       li $v0,4
            la $a0,num
            syscall            # print prompt

            li $v0,5
            syscall            # read integer -> $v0
            move $t0,$v0       # $t0 = target value

            la $t1, array      # $t1 = pointer to array[0]
            li $t2, 10         # $t2 = array length
            li $t3, 0          # $t3 = index i

loop:   beq $t3, $t2, not_found1  # ran off the end of the array -> not found
        lw $t4, 0($t1)            # $t4 = array[i]
        beq $t4, $t0, found1      # match! -> found
        addi $t3, $t3, 1          # i++
        addi $t1, $t1, 4          # advance pointer
        j loop

found1: li $v0, 4
        la $a0, found
        syscall                # print "The number is found at "

        li $v0,1
        move $a0,$t3           # print the index (i doubles as the answer)
        syscall

        j exit                 # must skip past not_found1

not_found1: li $v0,4
            la $a0,not_found
            syscall            # print "The number is not found."

exit:   li $v0, 10
        syscall                # exit
```

**Pattern:** classic linear (sequential) search — check each element in
order, and stop as soon as a match is found or the array is exhausted. The
loop counter `$t3` conveniently *is* the index, so no separate bookkeeping is
needed to report where the match was found. The `j exit` after `found1` is
essential: without it, execution would fall through into `not_found1` and
print the "not found" message even after a successful match, since
`not_found1` sits immediately after `found1` in the file.

---

## 3. `sum_of_array.asm` — element-wise sum of two arrays

```asm
.data
array1: .word 11, 13, 15, 17, 19
array2: .word 1, 3, 5, 7, 9
array3: .word 0, 0, 0, 0, 0
result: .asciiz "The resultant array is: "
space: .asciiz " "
.text

main:   la $t1, array1     # pointer into array1
        la $t2, array2     # pointer into array2
        la $t3, array3     # pointer into array3 (destination)

        li $t4,0           # loop index i
        li $t5,5           # array length

loop:   beq $t4, $t5, end       # all 5 elements summed -> done
        lw $t6, 0($t1)          # $t6 = array1[i]
        lw $t7, 0($t2)          # $t7 = array2[i]
        add $t0, $t6, $t7       # $t0 = array1[i] + array2[i]
        sw $t0, 0($t3)          # array3[i] = $t0
        addi $t1, $t1, 4
        addi $t2, $t2, 4
        addi $t3, $t3, 4
        addi $t4, $t4, 1
        j loop

end:    li $v0, 4
        la $a0, result
        syscall                 # print "The resultant array is: "

        la $t3, array3          # reset pointer to start of array3
        li $t4, 0               # reset index

p_loop: beq $t4, $t5, exit      # done printing all 5 elements
        li $v0,4
        la $a0,space
        syscall                 # print a space separator

        li $v0,1
        lw $a0,0($t3)           # array3[i]
        syscall                 # print it

        addi $t3, $t3, 4
        addi $t4, $t4, 1
        j p_loop

exit:   li $v0, 10
        syscall                 # exit
```

Expected output for the given data: `12 16 20 24 28`.

**Pattern:** three pointers (`$t1`, `$t2`, `$t3`) walk three arrays in
lockstep to compute `array3[i] = array1[i] + array2[i]` for every `i`. After
the first loop finishes, `$t3` and `$t4` are sitting at the *end* of
`array3`/the loop bound — they have to be explicitly reset (`la $t3, array3`
/ `li $t4, 0`) before the second loop (`p_loop`) can reuse them to walk
`array3` again for printing. This is a common gotcha in MIPS: registers
don't "know" they were pointers/counters for a finished loop — they just
hold whatever value was last written to them, so reusing them for a new pass
always requires re-initializing them first.
