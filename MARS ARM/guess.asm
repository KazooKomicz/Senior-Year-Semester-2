.data
prompt:         .asciiz "Think of a number in 1-1000000. I'll guess it in ≤20 tries.\nRespond with:\n'H' if too high\n'L' if too low\n'E' if correct\n\n"
guess_msg:      .asciiz "Guess #"
guess_colon:    .asciiz ": "
input_prompt:   .asciiz "? "
success_msg:    .asciiz "I got it in "
success_msg2:   .asciiz " guesses!\n\n"
fail_msg:       .asciiz "I suspect foul play after 20 guesses!\n"

low:            .word 1              // Initial lower bound (1)
high:           .word 999999         // Initial upper bound (999999)
guess_count:    .word 1              // Starts at guess #1
guess:          .word 0              // Will store current guess
input:          .byte 0              // Stores user's H/L/E response

.text
.global main

main:
    // Print instructions
    addi x0, xzr, 4         // syscall 4 = print string
    lda x2, prompt          // Load address of prompt
    svc #0                  // Execute syscall

game_loop:
    // Check if exceeded 20 guesses
    lda x1, guess_count
    ldursw x1, [x1, 0]      // Load current guess count
    cmpi x1, 20             // Compare with 20
    b.gt fail               // If >20, jump to fail

    // Calculate midpoint guess: (low + high)/2
    lda x1, low
    ldursw x1, [x1, 0]      // Load low value
    lda x2, high
    ldursw x2, [x2, 0]      // Load high value
    add x3, x1, x2          // low + high
    lsr x3, x3, 1           // Divide by 2
    
    // Store the calculated guess
    lda x4, guess
    sturw x3, [x4, 0]       // Store in guess variable

    // Print guess number and value
    addi x0, xzr, 4         // print string
    lda x2, guess_msg       // "Guess #"
    svc #0
    
    addi x0, xzr, 1         // print integer
    lda x1, guess_count
    ldursw x2, [x1, 0]      // Guess number
    svc #0
    
    addi x0, xzr, 4         // print string
    lda x2, guess_colon     // ": "
    svc #0
    
    addi x0, xzr, 1         // print integer
    lda x1, guess
    ldursw x2, [x1, 0]      // Guess value
    svc #0
    
    addi x0, xzr, 4         // print newline
    lda x2, newline
    svc #0

    // Get user response
    addi x0, xzr, 4         // print prompt
    lda x2, input_prompt    // "? "
    svc #0

    addi x0, xzr, 8         // read character
    lda x2, input           // Store in input
    addi x3, xzr, 1         // Read 1 char
    svc #0
    
    addi x0, xzr, 4         // print newline
    lda x2, newline
    svc #0
    
    // Process input
    lda x1, input
    ldurb x4, [x1, 0]       // Load response char
    
    // Check responses
    cmpi x4, 'E'            // Correct guess?
    beq success             // Jump if equal
    
    cmpi x4, 'H'            // Too high?
    beq too_high
    
    cmpi x4, 'L'            // Too low?
    beq too_low
    
    // Invalid input - ignore and continue
    b next_guess

too_high:
    // Adjust high bound to guess-1
    lda x3, guess
    ldursw x3, [x3, 0]      // Current guess
    sub x3, x3, 1           // guess - 1
    lda x4, high
    sturw x3, [x4, 0]       // Update high
    b next_guess

too_low:
    // Adjust low bound to guess+1
    lda x3, guess
    ldursw x3, [x3, 0]      // Current guess
    add x3, x3, 1           // guess + 1
    lda x4, low
    sturw x3, [x4, 0]       // Update low
    b next_guess

next_guess:
    // Increment guess counter
    lda x0, guess_count
    ldursw x1, [x0, 0]      // Current count
    add x1, x1, 1           // Increment
    sturw x1, [x0, 0]       // Store back
    
    // Check if range is invalid (low > high)
    lda x1, low
    ldursw x1, [x1, 0]
    lda x2, high
    ldursw x2, [x2, 0]
    cmp x1, x2              // Compare low and high
    b.gt fail               // If low > high, jump to fail
    
    // Continue guessing
    b game_loop

success:
    // Print success message with guess count
    addi x0, xzr, 4         // print string
    lda x2, success_msg     // "I got it in "
    svc #0
    
    addi x0, xzr, 1         // print integer
    lda x1, guess_count
    ldursw x2, [x1, 0]      // Guess count
    svc #0
    
    addi x0, xzr, 4         // print string
    lda x2, success_msg2    // " guesses!\n\n"
    svc #0
    b exit

fail:
    // Print failure message
    addi x0, xzr, 4         // print string
    lda x2, fail_msg        // Foul play message
    svc #0

exit:
    // Exit program
    addi x0, xzr, 10        // exit syscall
    svc #0