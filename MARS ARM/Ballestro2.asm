.data
prompt:         .asciiz "Please enter the maximum value to be tested for prime numbers (max 10000):\n"
result_msg:     .asciiz "The number of primes is: "
exit_msg:       .asciiz "\nProgram terminated.\n"

array:          .byte 15000    // buffer for flags

.text
start:
    // Print prompt
    lda x0, prompt
    addi x0, xzr, 4       // syscall: print string

    // Read integer
    addi x0, xzr, 5       // syscall: read int
    svc
    mov x20, x0           // store user input in x20

    // Compare input to max limit (15000)
    addi x1, xzr, 15000
    cmp x20, x1
    b.gt exit

    // Initialize array with 1s
    lda x1, array         // x1: base address
    addi x2, xzr, 2       // x2: current index (start from 2)

init_loop:
    cmp x2, x20
    b.ge exit   // prevent OOB accessb.ge sieve_start
    add x3, x1, x2
    addi x4, xzr, 1
    sturb x4, [x3, 0]
    addi x2, x2, 1
    cmp x2, x20
    b.ge sieve_start
    b init_loop

// Begin sieve
sieve_start:
    addi x2, xzr, 2       // x2 = p = 2

sieve_outer:
    mul x3, x2, x2        // x3 = p * p
    cmp x3, x20
    b.gt count_primes

    add x4, x1, x2
    ldurb x5, [x4, 0]     // check if p is marked
    cbz x5, sieve_next_p  // if not marked, skip

    // mark multiples of p
    add x6, x3, xzr       // i = p * p

mark_loop:
    cmp x6, x20
    b.ge sieve_next_p

    add x7, x1, x6
    addi x0, xzr, 0
    sturb x0, [x7, 0]     // mark as not prime

    add x6, x6, x2        // i += p
    cmp x6, x20
    b mark_loop

sieve_next_p:
    addi x2, x2, 1
    b sieve_outer

// Count remaining primes
count_primes:
    addi x2, xzr, 2       // start from 2
    addi x3, xzr, 0       // prime count = 0

count_loop:
    cmp x2, x20
    b.ge show_result

    add x4, x1, x2
    ldurb x5, [x4, 0]
    cmp x2, x20
    cbz x5, skip

    addi x3, x3, 1        // count++

skip:
    addi x2, x2, 1
    b count_loop

show_result:
    // Print message
    lda x2, result_msg
    addi x0, xzr, 4
    svc
    
    ldurb x3, [x3, 0] // move result (number of primes)
    addi x0, xzr, 1  // syscall: print int
    svc

    // Print exit message
    lda x2, exit_msg
    addi x0, xzr, 4
    svc

exit:
    addi x0, xzr, 10      // syscall: exit
    svc
