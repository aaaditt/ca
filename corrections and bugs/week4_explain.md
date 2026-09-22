# Week 4 — Code Explanations

Week 4 contains `priority.asm` (operator precedence / order of operations)
and an empty placeholder `array.asm`. This file explains the logic; it does
not modify any code.

---

## 1. `array.asm`

This file is currently **empty (0 bytes)** — it's a placeholder that hasn't
been filled in yet, so there is nothing to explain here. (It shows up as an
untracked file in `git status` — worth committing once it has real content,
so it isn't lost.)

---

## 2. `priority.asm` — operator precedence: `a * b / c % d + e`

```asm
.data
inp1: .asciiz "Enter the first integer: "
inp2: .asciiz "Enter the second integer: "
inp3: .asciiz "Enter the third integer: "
inp4: .asciiz "ENter the fourth integer: "
inp5: .asciiz "Enter the fifth integer: "
res: .asciiz "The ans is: "

.text
main:   li $v0,4
        la $a0,inp1
        syscall
        li $v0,5
        syscall
        move $t0,$v0        # $t0 = a (1st number)

        li $v0,4
        la $a0,inp2
        syscall
        li $v0,5
        syscall
        move $t1,$v0        # $t1 = b (2nd number)

        li $v0,4
        la $a0,inp3
        syscall
        li $v0,5
        syscall
        move $t2,$v0        # $t2 = c (3rd number)

        li $v0,4
        la $a0,inp4
        syscall
        li $v0,5
        syscall
        move $t3,$v0        # $t3 = d (4th number)

        li $v0,4
        la $a0,inp5
        syscall
        li $v0,5
        syscall
        move $t4,$v0        # $t4 = e (5th number)

        mult $t0,$t1        # a * b -> result in HI/LO
        mflo $t5            # $t5 = a * b
        div $t5,$t2         # (a*b) / c -> quotient in LO, remainder in HI
        mflo $t6            # $t6 = (a*b) / c
        div $t6,$t2         # $t6 / c again -> quotient in LO, remainder in HI
        mfhi $t7            # $t7 = remainder of ($t6 / c)
        add $t8,$t7,$t4     # $t8 = $t7 + e

        li $v0,4
        la $a0,res
        syscall             # print "The ans is: "

        li $v0,1
        move $a0,$t8
        syscall             # print $t8

        li $v0,10
        syscall             # exit
```

**Intent:** the five prompts (`a, b, c, d, e`) and the `res` label ("The
ans is: ") strongly suggest this program is meant to evaluate an
operator-precedence expression like `a * b / c % d + e` — i.e. compute `(a *
b) / c`, then take that result **mod `d`**, then add `e`. This is a common
"BODMAS / order of operations" lab exercise: multiplication and division
happen left-to-right first, then modulo, then addition last, matching
standard precedence rules.

**Possible bug worth flagging (not fixed — Week 5 was the only week in
scope for corrections):** the second `div` — the one meant to compute the
`% d` (modulo by the *fourth* number) — divides by `$t2` again:

```asm
div $t6,$t2      # divides by c (the 3rd number) again
```

But `$t2` holds `c` (the third input), not `$t3` which holds `d` (the fourth
input, the one the modulo should presumably use). If the intended formula is
`(a*b/c) % d + e`, this line should read `div $t6,$t3` instead. As written,
the program actually computes `((a*b)/c) % c + e` — it takes the remainder
of dividing the quotient by `c` again rather than by `d`, meaning the fourth
input (`d`) is read from the user but never used in the calculation. Worth
double-checking against whatever expression the lab handout specifies.

**Key idea regardless of the exact formula:** this program is a good
demonstration of chaining `mult`/`div` results through the `HI`/`LO`
registers — `mflo` after `mult` retrieves a product, `mflo` after `div`
retrieves a quotient, and `mfhi` after `div` retrieves a remainder. Because
`HI`/`LO` are overwritten by *every* `mult`/`div`, each result has to be
copied out into a normal register (`$t5`, `$t6`, `$t7`) immediately, before
the next `mult`/`div` clobbers it.
