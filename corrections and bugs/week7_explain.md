# Week 7 — Code Explanations

Week 7 covers strings: checking whether a string is a palindrome, and
concatenating two strings into a single string. Both programs build on the
"walk the string byte by byte until the null terminator" loop from Week 6
(`length_string.asm` / `reverse_array.asm`). This file explains the logic of
the two programs; there were no bugs to correct this week.

---

## 1. `palindrome.asm` — check if a string is a palindrome

```asm
    .data
string:         .asciiz "malayalam"
pal:            .asciiz "The string is a palindrome"
not_pal:        .asciiz "The string is not a palindrome"

    .text
main:           la $t0, string         # $t0 = front pointer, at string[0]
                la $t1, string         # $t1 = back pointer, also starts at string[0]

str_length:     lbu $t2, 0($t1)        # $t2 = current character
                beqz $t2, end_loop     # hit the null terminator -> end of string
                addi $t1, $t1, 1       # move back pointer forward
                j str_length

end_loop:       addi $t1, $t1, -1      # step back off the '\0' onto the last character

check:          bge $t0, $t1, pal1     # pointers met/crossed -> every pair matched
                lbu $t2, 0($t0)        # $t2 = character from the front
                lbu $t3, 0($t1)        # $t3 = character from the back
                bne $t2, $t3, not_pal1 # mismatch -> not a palindrome
                addi $t0, $t0, 1       # front pointer moves right
                addi $t1, $t1, -1      # back pointer moves left
                j check

pal1:           li $v0, 4
                la $a0, pal
                syscall                # print "The string is a palindrome"

                j exit                 # must skip past not_pal1

not_pal1:       li $v0, 4
                la $a0, not_pal
                syscall                # print "The string is not a palindrome"

exit:           li $v0, 10
                syscall                # exit
```

Expected output for the given data: `The string is a palindrome`.

**Pattern:** "two pointers moving inwards." The program has two phases:

1. **Find the end of the string.** `$t1` is walked forward until it reads the
   null byte (`beqz $t2, end_loop`). At that point it is sitting *on* the
   `\0`, so `addi $t1, $t1, -1` pulls it back by one to the last real
   character. This is the same trick used in `reverse_array.asm` in Week 6.
2. **Compare from both ends.** `$t0` points to the first character and `$t1`
   to the last. Each pass compares the two characters, then moves `$t0` right
   and `$t1` left. The first mismatch means the string is not a palindrome.
   If the pointers meet (odd length — the middle character has nothing to be
   compared with) or cross (even length) without a mismatch, the string is a
   palindrome. Both cases are covered by the single check `bge $t0, $t1`.

Trace for `"malayalam"` (9 characters, indices 0–8):

| Pass | `$t0` index | `$t1` index | Characters | Result        |
|------|-------------|-------------|------------|---------------|
| 1    | 0           | 8           | `m` / `m`  | match         |
| 2    | 1           | 7           | `a` / `a`  | match         |
| 3    | 2           | 6           | `l` / `l`  | match         |
| 4    | 3           | 5           | `a` / `a`  | match         |
| 5    | 4           | 4           | —          | pointers met → palindrome |

**Points to note:**

- No reversed copy of the string is needed, and no separate length counter
  either — comparing the two *addresses* (`bge $t0, $t1`) is enough to know
  when to stop.
- `j exit` after `pal1` is essential. Without it execution would fall through
  into `not_pal1` and print both messages (same situation as `found1` /
  `not_found1` in Week 5's linear search).
- The labels are named `pal1` / `not_pal1` because `pal` / `not_pal` are
  already used for the strings in `.data` — a label name can only be defined
  once in a file.
- The comparison is case-sensitive (`"Madam"` is reported as not a
  palindrome, because `M` and `m` have different ASCII codes), and spaces
  count as characters.
- To test another word, change the `string:` line and re-run.

---

## 2. `concatenate.asm` — join two strings into one

```asm
    .data
str1:           .asciiz "Computer "
str2:           .asciiz "Architecture"
result:         .space 100
output:         .asciiz "The concatenated string is: "

    .text
main:           la $t0, str1           # $t0 = pointer into str1
                la $t1, str2           # $t1 = pointer into str2
                la $t2, result         # $t2 = pointer into result (destination)

copy1:          lbu $t3, 0($t0)        # $t3 = str1[i]
                beqz $t3, copy2        # end of str1 -> start copying str2
                sb $t3, 0($t2)         # store the character in result
                addi $t0, $t0, 1       # next character of str1
                addi $t2, $t2, 1       # next free slot of result
                j copy1

copy2:          lbu $t3, 0($t1)        # $t3 = str2[j]
                beqz $t3, end_copy     # end of str2 -> done
                sb $t3, 0($t2)         # store it right after str1's characters
                addi $t1, $t1, 1       # next character of str2
                addi $t2, $t2, 1       # next free slot of result
                j copy2

end_copy:       sb $zero, 0($t2)       # null-terminate the result string

                li $v0, 4
                la $a0, output
                syscall                # print "The concatenated string is: "

                li $v0, 4
                la $a0, result
                syscall                # print the concatenated string

                li $v0, 10
                syscall                # exit
```

Expected output for the given data:
`The concatenated string is: Computer Architecture`.

**Pattern:** the same copy loop run twice into one destination buffer. The
key is that the destination pointer `$t2` is **never reset** between the two
loops. When `copy1` finishes, `$t2` is pointing at the first free byte after
the characters of `str1`, which is exactly where `str2` has to start. (This
is the opposite of Week 5's `sum_of_array.asm`, where the pointer *had* to be
reset before the second loop.)

**Points to note:**

- The null terminator of `str1` is **not** copied. `beqz $t3, copy2` jumps
  out *before* the `sb`, so the `\0` is skipped. If it were copied, the
  result would still contain both strings in memory, but printing would stop
  at that first `\0` and only `Computer ` would be shown.
- `sb $zero, 0($t2)` at `end_copy` adds the single terminator at the very
  end. Syscall 4 keeps printing bytes until it finds a `\0`, so a string
  built by hand must always be terminated by hand.
- `result: .space 100` reserves 100 bytes, so the two strings together can be
  at most 99 characters (one byte is needed for the `\0`). `Computer ` (9) +
  `Architecture` (12) = 21 characters, well within the limit.
- The space between the two words comes from the trailing space inside
  `str1` (`"Computer "`). The program itself does not insert any separator.
- `lbu` / `sb` are used instead of `lw` / `sw`, and the pointers move by 1
  instead of 4, because each character is one byte, not a 4-byte word.
