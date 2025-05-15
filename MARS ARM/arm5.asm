.data
prompt01: .asciiz "Please enter a number: "
crlf: .asciiz "\r\n"
prompt02: .asciiz "Please enter a second number: "
result_msg: .asciiz "The quotient is: "
remainder_msg: .asciiz "The remainder is: "

.text

//output prompt
addi x0, xzr, 4
lda x2, prompt01
svc
//Takes input
addi x0, xzr, 5
svc
mov x4, x0
//Output prompt
addi x0, xzr, 4
lda x2, prompt02
svc
//Takes input
addi x0, xzr, 5
svc
mov x5, x0
//MATH
udiv x6, x4, x5
mul x7, x5, x6
sub x8, x4, x7
//Print quotient msg
addi x0, xzr, 4
lda x2, result_msg
svc
//Print quotient
addi x0, xzr, 1
addi x2, x6, 0
mov x6, x2
svc
//Print remainder msg
addi x0, xzr, 4
lda x2, remainder_msg
svc
//Print Remainder
addi x0, xzr, 1
addi x2, x8, 0
mov x8, x2
svc

// exit gracefully
addi x0, xzr, 10
lda x2, result_msg
svc
