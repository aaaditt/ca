# Week 3 — Code Explanations

Week 3 introduces division-based logic (`div`, `mfhi`, `mflo`): odd/even
check, a general "operation" (multiply) program, a prime checker, and sum of
digits. This file explains the logic; it does not modify any code.

---

## 1. `odd_even.asm` — check if a number is odd or even

```asm
.data
input:  .asciiz "Enter a number to check for odd or even: "
odd_res: .asciiz "Thn Number you entered is odd"
even_res: .asciiz "The Number you entered in Even"

.text
main:   li $v0,4
        la $a0,input
        syscall            # print prompt

        li $v0,5
        syscall            # read integer -> $v0
        move $t0,$v0       # $t0 = the number

        li $t1,2
        div $t0,$t1        # $t0 / $t1: quotient -> LO, remainder -> HI
        mfhi $t2           # $t2 = remainder of (number / 2)
        beq $t2,$zero,even # remainder == 0 -> even
        j odd

even:
        li $v0,4
        la $a0,even_res
        syscall            # print "even" message
        j end

odd:
        li $v0,4
        la $a0,odd_res
        syscall            # print "odd" message

end:
        li $v0,10
        syscall            # exit
```

**Flow:** the core trick is `div $t0, $t1` followed by `mfhi $t2`. On MIPS,
`div a, b` doesn't return a value directly — it computes both quotient and
remainder and stashes them in the special `LO`/`HI` registers; you then use
`mflo` to retrieve the quotient or `mfhi` to retrieve the remainder. Checking
`number % 2 == 0` is exactly "is the number even," which is why `mfhi` (the
remainder) is what's tested here, not `mflo`.

**Note (not fixed, out of scope):** the output strings have typos —
`"Thn Number you entered is odd"` (should be "The") and `"...entered in
Even"` (should be "is Even"). Purely cosmetic; doesn't affect the logic.

---

## 2. `oper1.asm` — multiply two numbers

```asm
.data
operation: .asciiz "this is the operation that were going to follow: X * Y\n"
num1:   .asciiz "Enter the first number: "
num2:   .asciiz "Enter the 2nd number: "
result: .asciiz "the answer is: "

.text
main:   li $v0,4
        la $a0, operation
        syscall            # print the "X * Y" description line

        li $v0,4
        la $a0,num1
        syscall
        li $v0,5
        syscall
        move $t0,$v0       # $t0 = X

        li $v0,4
        la $a0,num2
        syscall
        li $v0,5
        syscall
        move $t1,$v0       # $t1 = Y

        mul $t2,$t1,$t0    # $t2 = X * Y

        li $v0,4
        la $a0,result
        syscall            # print "the answer is: "

        li $v0,1
        move $a0,$t2
        syscall            # print $t2

        li $v0,10
        syscall            # exit

        li $v0,10          # (unreachable — program already exited above)
        syscall
```

**Flow:** straightforward prompt/read twice, `mul`, print. Since `mul` in
MIPS/MARS is a pseudo-instruction that produces a normal 32-bit result
register directly (unlike `div`, it doesn't require `mflo`), this is simpler
than the division-based programs in this same week.

**Note (not fixed, out of scope):** lines 43–44 duplicate the exit syscall
(`li $v0,10` / `syscall` appears twice in a row). The first `syscall`
already terminates the program, so the second copy is dead code that never
executes — harmless, but redundant.

---

## 3. `prime.asm` — check if a number is prime

```asm
.data
int1: .asciiz "Enter the number: "
res1: .asciiz "it is a prime number"
res2: .asciiz "it is not a prime number"

.text
main:
    li $v0,4
    la $a0,int1
    syscall                # print prompt

    li $v0,5
    syscall                # read integer -> $v0
    move $t0,$v0           # $t0 = N (the number to test)

    li $t1,2               # $t1 = candidate divisor, starts at 2
    blt $t0,$t1,not_prime  # if N < 2, it's not prime (handles 0 and 1)

loop:
    mul $t3,$t1,$t1        # $t3 = divisor * divisor
    bgt $t3,$t0,prime      # if divisor^2 > N, no factor was found -> N is prime

    div $t0,$t1            # N / divisor
    mfhi $t2               # $t2 = N mod divisor
    beq $t2,$zero,not_prime # remainder 0 -> divisor divides N evenly -> not prime

    addi $t1,$t1,1         # try the next divisor
    j loop

prime:
    li $v0,4
    la $a0,res1
    syscall                # print "it is a prime number"
    j exit

not_prime:
    li $v0,4
    la $a0,res2
    syscall                # print "it is not a prime number"

exit:
    li $v0,10
    syscall                # exit
```

**Flow:** this uses the classic **trial division up to √N** optimisation
instead of testing every divisor up to `N-1`. Instead of computing an actual
square root, it avoids the expensive operation entirely by comparing
`divisor * divisor > N`, which is mathematically equivalent to `divisor >
√N` but only needs a multiply. As soon as no divisor up to `√N` has been
found, no larger divisor could work either (its "co-factor" would have had
to be smaller than `√N` and already been tried), so `N` must be prime.

**Correctness detail:** `blt $t0,$t1,not_prime` before the loop correctly
rejects `0` and `1` (neither is prime) without ever entering the loop. For
`N = 2`: `divisor=2`, `2*2=4 > 2` is true immediately, so it jumps straight
to `prime` — correctly identifying 2 as prime without ever dividing by
itself.

---

## 4. `sum_of_digits.asm` — sum of the digits of a number

```asm
.data
input:  .asciiz "Enter a number: "
result: .asciiz "The sum of digits: "

.text
main:   li $v0,4
        la $a0,input
        syscall            # print prompt

        li $v0,5
        syscall            # read integer -> $v0
        move $t0,$v0       # $t0 = the number (this will be consumed/shrunk in the loop)

        li $t1,10          # $t1 = 10 (divisor, to peel off one digit at a time)
        li $t2,0           # $t2 = running digit sum

sum:    beq $t0,$zero,end  # if number has been reduced to 0, all digits consumed -> done
        j loop

loop:   div $t0,$t1        # number / 10
        mfhi $t3           # $t3 = number mod 10 = last digit
        add $t2,$t2,$t3    # digit_sum += last digit
        mflo $t0           # $t0 = number / 10 (drop the last digit)
        j sum

end:    li $v0, 4
        la $a0, result
        syscall            # print "The sum of digits: "

        li $v0,1
        move $a0,$t2
        syscall            # print the digit sum

        li $v0,10
        syscall            # exit
```

**Flow:** this uses `div` twice per digit — once via `mfhi` to peel off the
*last* digit (`number mod 10`), and once via `mflo` to *shrink* the number
by removing that digit (`number / 10`, integer division). Repeating
"mod 10, then divide by 10" is the standard technique for processing a
number digit-by-digit from the ones place upward, since MIPS has no
built-in way to index "the 3rd digit" — the number itself is the only thing
you can query.

**Edge case:** if the user enters `0`, `sum:` immediately sees `$t0 ==
$zero` and jumps straight to `end`, correctly reporting a digit sum of `0`
without ever running the loop.
