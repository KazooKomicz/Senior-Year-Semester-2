.data
prompt:         .asciiz "Please enter a character string or press Enter to exit:\n"
pal_msg:        .asciiz "The string is a palindrome.\n"
not_pal_msg:    .asciiz "The string is NOT a palindrome.\n"
exit_msg:       .asciiz "Program terminated.\n"
newline:        .asciiz "\n"

input_buffer:   .word 100
clean_buffer:   .space 100

.text
start:
    // Print prompt
    lda x1, prompt
    addi x0, xzr, 4
    svc

    // Read input
    lda x1, input_buffer
    addi x2, xzr, 0       // index = 0

read_loop:
    addi x0, xzr, 12          // syscall: read char
    svc

    lda x3, newline
    addi x4, xzr, 0
    ldurb x5, [x3, 0]    // load newline char
    cmp x0, x5
    b.eq end_input        // if Enter, finish input

    add x20, x1, x2
    sturb x0, [x20, 0]    // store char
    addi x6, xzr, 1
    add x2, x2, x6        // index++

    addi x7, xzr, 100
    cmp x2, x7
    b.lt read_loop        // loop until limit

end_input:
    add x20, x1, x2
    addi x8, xzr, 0
    sturb x8, [x20, 0]    // null terminate

    // Check if input is empty
    lda x1, input_buffer
    addi x8, xzr, 0
    add x20, x1, x8
    ldurb x9, [x20, 0]
    cbz x9, exit_program

    // Clean input
    lda x1, input_buffer
    lda x2, clean_buffer
    addi x3, xzr, 0       // input index
    addi x4, xzr, 0       // clean index

clean_loop:
    add x20, x1, x3
    ldurb x5, [x20, 0]
    cbz x5, compare_loop  // end of string
    addi x3, x3, 1

    // Convert A-Z to a-z
    addi x6, xzr, 65      // 'A'
    cmp x5, x6
    b.lt check_digit
    addi x6, xzr, 90      // 'Z'
    cmp x5, x6
    b.gt check_digit
    addi x5, x5, 32       // to lowercase

check_digit:
    addi x6, xzr, 97      // 'a'
    cmp x5, x6
    b.ge store_char
    addi x6, xzr, 48      // '0'
    cmp x5, x6
    b.lt clean_loop
    addi x6, xzr, 57      // '9'
    cmp x5, x6
    b.gt clean_loop
    b store_char

store_char:
    add x20, x2, x4
    sturb x5, [x20, 0]    // store cleaned char
    addi x4, x4, 1
    b clean_loop

// Compare cleaned string for palindrome
compare_loop:
    addi x5, xzr, 0       // start
    subi x6, x4, 1         // end

cmp_loop:
    cmp x5, x6
    b.ge is_palindrome

    add x20, x2, x5
    ldurb x7, [x20, 0]
    add x20, x2, x6
    ldurb x8, [x20, 0]
    cmp x7, x8
    b.ne not_palindrome

    addi x9, xzr, 1
    add x5, x5, x9
    sub x6, x6, x9
    b cmp_loop

is_palindrome:
    lda x1, pal_msg
    mov x0, x10
    svc
    b start

not_palindrome:
    lda x1, not_pal_msg
    mov x10, x0
    svc
    b start

exit_program:
    lda x1, exit_msg
    mov x0, x10
    svc

    mov x0, x12           // syscall: exit
    svc
