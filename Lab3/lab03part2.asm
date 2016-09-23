.data
	xyCalcMsg: .asciiz "x*y calculator"
	enterXMsg: .asciiz "\nPlease enter x: "
	enterYMsg: .asciiz "\nPlease enter y: "
	asterisk : .asciiz "*"
	equals   : .asciiz " = "
	nonnegMsg: .asciiz "Integer must be nonnegative."
	
.text
	addi $v0, $0, 4
	lui  $at, 0x00001001
	ori  $a0, $at, 0x00000000
	syscall 
	
	promptForX:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x0000000F
		syscall
	
		addi $v0, $0, 5
		syscall
	
		slt  $t0, $v0, $0
		beq  $t0, 1, integerNegativeErrorX
		
	promptForY:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x000000021
		syscall
		
		addi $v0, $0, 5
		syscall
		slt  $t0, $v0, $0
		beq  $t0, 1, integerNegativeErrorY
	
	integerNegativeErrorX:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000039
		syscall
		j promptForX
		
	integerNegativeErrorY:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000039
		syscall
		j promptForY