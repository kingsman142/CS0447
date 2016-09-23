.data
	enterIntegerMsg: .asciiz "Please enter an integer: "
	outputMsg: .asciiz "Here is the output: "

.text
	addi $v0, $0, 4
	lui  $at, 0x00001001
	ori  $a0, $at, 0x00000000
	syscall
	
	addi $v0, $0, 5
	syscall
	addi $t0, $v0, 0
	
	sra  $t1, $t0, 15
	andi $t1, $t1, 0x0000007
	
	addi $v0, $0, 4
	lui  $at, 0x00001001
	ori  $a0, $at, 0x00001A
	syscall
	
	addi $v0, $0, 1
	addi $a0, $t1, 0
	syscall