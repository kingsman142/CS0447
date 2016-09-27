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
		
		addi $t1, $v0, 0 #Store X
		
	promptForY:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x000000020
		syscall
		
		addi $v0, $0, 5
		syscall
		slt  $t0, $v0, $0
		beq  $t0, 1, integerNegativeErrorY
		
		addi $t2, $v0, 0 #Store Y
		addi $t7, $t1, 0
		
		addi $t6, $t2, 0 #Placeholder for Y
		addi $t4, $t1, 0 #Placeholder for X
	
	multiply:
		slti $t5, $t6, 1 
		beq  $t5, 1, end #Exit if the multiplication factor is 0
		and  $t7, $t6, 1 #Find least significant bit of Y
		beq  $t7, 1, shiftAdd #If the least significant bit is 1, add the next number to the result
		multiplyAfterShift:
		srl  $t6, $t6, 1 #Shift the X placeholder to the left 1
		sll  $t4, $t4, 1 #Shift the Y placeholder to the right 1
		j multiply
	
	j end
	
	shiftAdd:
		add  $t3, $t3, $t4 #Store the X*Y result in $t3
		j multiplyAfterShift
	
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
