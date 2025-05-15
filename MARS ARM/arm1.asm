.data
welcome: .asciiz "Think of a number in the range 1-1000000. I will attempt to guess it."
guess_prompt: .asciiz "Guess #: "
input_prompt:.asciiz "? "
success_msg: .asciiz "I got it in "
foulplay_msg:.asciiz "I suspect foul play...\n"
end_msg:     .asciiz "Program terminated.\n"
newline:     .asciiz "\n"

highvalue: .word 100000
lowvalue: .word 0

.text
// Initialize lowvalue (x10)
lda x1, lowvalue
ldur x10, [x1, 0]

// Initialize highvalue (x11)
lda x1, highvalue
ldur x11, [x1, 0]

// Initialize guess count (x12 = 0)
mov x12, xzr

//Load prompt
lda x2, welcome
addi x0, xzr, 4
svc

guess_loop:
cmpi x12, 21
b.ge foul_play

addi x12, x12, 1 

add x13, x10, x11
mov x4, xzr
addi x4, x4, 2      // initialize divisor to 2
udiv x13, x13, x4

cmp x10, x11
b.eq correct_guess    // low == high → done

lda x2, guess_prompt
addi x0, xzr, 4
svc

addi x0, xzr, 1
mov x2, x13
svc

lda x2, input_prompt
addi x0, xzr, 4      // print prompt
svc

addi x0, xzr, 12     // syscall: read a character
svc

cmpi x0, 'E'
b.eq correct_guess
cmpi x0, 'H'
b.eq too_high
cmpi x0, 'L'
b.eq too_low

cmp x10, x11
b.eq correct_guess    // If low == high, you found it

b guess_loop

too_high:
subi x11, x13, 1

cmp x10, x11
b.gt foul_play    // If low > high, something went wrong
b guess_loop

too_low:
addi x10,x13, 1

cmp x10, x11
b.gt foul_play    // If low > high, something went wrong
b guess_loop

correct_guess:
lda x2, success_msg
addi x0, xzr, 4
svc

mov x2, x12
addi x0, xzr, 1   // syscall 1: print integer
svc

lda x2, newline
addi x0, xzr, 4
svc

// exit gracefully
addi x0, xzr, 10
lda x2, end_msg
svc

foul_play:
addi x0, xzr, 4
lda x2, foulplay_msg
svc

// Print message
addi x0, xzr, 4
lda x2, end_msg
svc
// Exit
addi x0, xzr, 10
svc
