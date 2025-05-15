.data
memaddress: .long 0
nmbrbytes: .word 4
highvalue: .word 15000
prompt: .asciiz "Welcome to the program\n"

.text
//Load prompt
lda x2, prompt
addi x0, xzr, 4
svc
//Calc String length
lda x2, prompt
add x1, xzr, xzr

lda x2, prompt
addi x1, xzr, -1
//increment x1 through length of word (null end = 0)
loop1:
addi x1,x1, 1
add x3, x1, x2
ldurb x0, [x3, 0]
cbnz x0,loop1
//xo contains num of bytes in string w/o null byte.
addi x0, x0, 1
lda x1, nmbrbytes
sturw x0, [x1, 0]
//allocate memoryn (syscall 9 to x2 bytes)
lda x1, nmbrbytes
ldursw x2, [x1,0]
addi x0, xzr, 9
svc //returns address in x0

lda x2,memaddress
stur x0, [x2, 0]
lda x1, nmbrbytes
ldursw x2, [x1,0]
sub sp, sp, x2 //Stack pointer = sp

//copy string 2 diff places, mem heap & stack.
//need single index value x4 w/ read byte to x0 & stack+ offset in x3
// mem + offset x2
// data str + offset & x1
lda x2, memaddress //heap addr x2
ldur x2, [x2, 0] //read value @ addr
add x3, sp, xzr
lda x1, prompt //str into x1
addi x4, xzr, -1 //put -1 into x4

loop2:
addi x4, x4, 1
add x5, x1, x4 // load prompt byte + offset to x5
ldurb x0, [x5,0]
add x5, x2, x4 //mem addr + offset
sturb x0, [x5, 0] //copy to mem + offset

add x5, x3, x4 //stack + offset
sturb x0, [x5,0]
cbnz x0, loop2 //if no copy 0

add x2, sp, xzr//stack ptr x2
addi x0, xzr, 4
svc

lda x2, memaddress
ldur x2, [x2, 0] //value @ label
addi x0, xzr, 4
svc


//end prog
addi x0,xzr, 10
svc