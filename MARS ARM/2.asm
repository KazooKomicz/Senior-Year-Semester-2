.data
prompt01: .asciiz "Think of a number in the range of 1 to 1000000. I will attempt to guess your number.\r\n"
prompt02: .asciiz "Respond with: 'H' if the guess is too high, 'L' if the guess is too low, 'E' if the guess is correct.\r\n"
guess_msg: .asciiz "Guess #"
guess: .asciiz ": "
high_msg: .asciiz "H\r\n"
low_msg: .asciiz "L\r\n"
correct_msg: .asciiz "E\r\n"
foul_play_msg: .asciiz "I suspect foul play. Too many guesses.\r\n"

.text
start:
    // Output welcome messages
    addi x0, xzr, 4         // Syscall to print
    lda x2, prompt01         // Load message
    svc                    // Print message
    
    addi x0, xzr, 4         // Syscall to print
    lda x2, prompt02         // Load message
    svc                    // Print message

    // Initialize the binary search range
    addi x6, x6, 1               // min value = 1
    stur x7, x7, 1000000         // max value = 1000000
    addi x8, x8, 1               // Guess count = 1

binary_search_loop:
    // Calculate the midpoint (guess)
    add x9, x6, x7          // x9 = min + max
    lsr x9, x9, 1           // x9 = (min + max) / 2 (midpoint)

    // Print the guess message
    addi x0, xzr, 4         // Syscall to print
    lda x2, guess_msg        // Load "Guess #"
    svc                    // Print "Guess #"

    addi x0, xzr, 1         // Syscall to print the number (guess)
    mov x9, x2              // Move the guess to x2
    svc                    // Print the guess

    addi x0, xzr, 4         // Syscall to print ": "
    lda x2, guess            // Load ": "
    svc                    // Print ": "

    // Take the user input (H, L, or E)
    addi x0, xzr, 5         // Syscall to read a character (user response)
    svc                    // Read character into x0

    // Check if the input is 'E' (correct guess)
    cmp x0, 'E'            // Compare input with 'E'
    b.eq correct_guess        // If equal, jump to correct_guess

    // Check if the input is 'H' (guess too high)
    cmp x0, x72             // Compare input with 'H'
    b.eq too_high             // If equal, jump to too_high

    // Check if the input is 'L' (guess too low)
    cmp x0, x76             // Compare input with 'L'
    b.eq too_low              // If equal, jump to too_low

correct_guess:
    // Print success message
    addi x0, xzr, 4         // Syscall to print
    lda x2, correct_msg      // Load "E\r\n"
    svc                    // Print "E\r\n"

    addi x0, xzr, 4         // Syscall to print
    lda x2, foul_play_msg    // Load message for foul play
    svc                    // Print foul play message

    // Exit gracefully
    addi x0, xzr, 10        // Syscall to exit
    svc                    // Exit the program

too_high:
    // Adjust the range (new max = guess - 1)
    subi x7, x9, 1           // max = guess - 1
    addi x8, x8, 1          // Increment guess count
    b binary_search_loop    // Repeat the loop

too_low:
    // Adjust the range (new min = guess + 1)
    addi x6, x9, 1           // min = guess + 1
    addi x8, x8, 1          // Increment guess count
    b binary_search_loop    // Repeat the loop
