.data
	xyCalcMsg: .asciiz "x*y calculator"
	enterXMsg: .asciiz "Please enter x: "
	enterYMsg: .asciiz "Please enter y: "
	asterisk : .asciiz "*"
	equals   : .asciiz " = "
	nonnegMsg: .asciiz "Integer must be nonnegative."
	newLine  : .asciiz "\n"
	
.text
	addi $v0, $0, 4
	lui  $at, 0x00001001
	ori  $a0, $at, 0x00000000
	syscall 
	
	addi $v0, $0, 4
	lui  $at, 0x00001001
	ori  $a0, $at, 0x00000054
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
		
		addi $t1, $v0, 0
		
	promptForY:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x000000020
		syscall
		
		addi $v0, $0, 5
		syscall
		slt  $t0, $v0, $0
		beq  $t0, 1, integerNegativeErrorY
		
		addi $t2, $v0, 0
		addi $t4, $v0, 0
	
	multiply:
		beq  $t4, $0, end
		add  $t3, $t3, $t1
		sub  $t4, $t4, 1
		j multiply
	
	j end
	
	integerNegativeErrorX:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000037
		syscall
		
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000054
		syscall
		
		j promptForX
		
	integerNegativeErrorY:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000037
		syscall
		
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000054
		syscall
		
		j promptForY
		
	end:
		addi $v0, $0, 1
		addi $a0, $t1, 0
		syscall
		
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000031
		syscall
		
		addi $v0, $0, 1
		addi $a0, $t2, 0
		syscall
		
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000033
		syscall
		
		addi $v0, $0, 1
		addi $a0, $t3, 0
		syscall
		
		addi $v0, $0, 10
		syscall
