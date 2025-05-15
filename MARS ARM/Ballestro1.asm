.data
prompt:         .asciiz "Please enter a character string or press Enter to exit:\n"
pal_msg:        .asciiz "The string is a palindrome.\n"
not_pal_msg:    .asciiz "The string is NOT a palindrome.\n"
exit_msg:       .asciiz "Program terminated.\n"
newline:        .asciiz "\n"

input_buffer:   .space 100
clean_buffer:   .space 100

.text
start:
    // Print prompt
    lda x2, prompt
    addi x0, xzr, 4
    svc

    // Read input (whole string at once)
    lda x1, input_buffer
    addi x2, xzr, 100     // maximum length
    addi x0, xzr, 8       // syscall: read string
    svc

    // Check if input is empty (just newline)
    ldurb x3, [x1, 0]
    addi x4, xzr, 10      // newline ASCII
    cmp x3, x4
    b.eq exit_program

    // Clean input (convert to lowercase and remove non-alphanumeric)
    lda x1, clean_buffer  // destination
    addi x5, xzr, 0       // clean index

clean_loop:
    ldurb x3, [x1, 0]     // load next char
    cbz x3, check_pal     // end of string

    // Check if uppercase letter (A-Z)
    addi x6, xzr, 'A'
    cmp x3, x6
    b.lt check_lower
    addi x6, xzr, 'Z'
    cmp x3, x6
    b.gt check_lower
    addi x3, x3, 32       // convert to lowercase
    b store_char

check_lower:
    // Check if lowercase letter (a-z)
    addi x6, xzr, 'a'
    cmp x3, x6
    b.lt check_digit
    addi x6, xzr, 'z'
    cmp x3, x6
    b.gt check_digit
    b store_char

check_digit:
    // Check if digit (0-9)
    addi x6, xzr, '0'
    cmp x3, x6
    b.lt skip_char
    addi x6, xzr, '9'
    cmp x3, x6
    b.gt skip_char

store_char:
    sturb x3, [x2, 0]     // store valid char
    addi x2, x2, 1        // increment dest pointer
    addi x5, x5, 1        // increment clean length

skip_char:
    addi x1, x1, 1        // increment source pointer
    b clean_loop

check_pal:
    mov x2, xzr   // null terminate cleaned string
    lda x1, clean_buffer
    subi x2, x5, 1        // end index (length-1)
    addi x3, xzr, 0       // start index

pal_loop:
    cmp x3, x2
    b.ge is_palindrome    // if start >= end, it's a palindrome

    // Load characters from both ends
    ldurb x4, [x1, 0]
    ldurb x4, [x3, 0]
    ldurb x5, [x1, 0]
    ldurb x5, [x2, 0]
    
    cmp x4, x5
    b.ne not_palindrome   // if chars don't match

    addi x3, x3, 1        // increment start
    subi x2, x2, 1        // decrement end
    b pal_loop

is_palindrome:
    lda x2, pal_msg
    addi x0, xzr, 4
    svc
    b exit_program

not_palindrome:
    lda x2, not_pal_msg
    addi x0, xzr, 4
    svc
    b exit_program

exit_program:
    lda x2, exit_msg
    addi x0, xzr, 4
    svc

    addi x0, xzr, 10      // syscall: exit
    svc