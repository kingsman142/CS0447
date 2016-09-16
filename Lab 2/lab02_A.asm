.data
	promptOne: .asciiz "What is the first value?\n"
	promptTwo: .asciiz "What is the second value?\n"
	sumOfMsg:  .asciiz "\nThe sum of "
	andMsg:	   .asciiz " and "
	isMsg:	   .asciiz " is "

.text
	#Print promptOne
	addi $v0, $zero, 4
	lui  $at, 0x00001001
	ori  $a0, $at, 0x00000000 
	syscall
	
	#Prompt first value
	addi $v0, $zero, 5
	syscall
	add  $t0, $zero, $v0
	
	#Print promptTwo
	addi $v0, $zero, 4
	lui $at, 0x00001001
	ori $a0, $at, 0x0000001a
	syscall
	
	#Prompt second value
	addi $v0, $zero, 5
	syscall
	add  $t1, $zero, $v0
	
	#Print sumOfMsg
	addi $v0, $zero, 4
	lui $at, 0x00001001
	ori $a0, $at, 0x00000035
	syscall
	#Print first value
	addi $v0, $zero, 1
	add $a0, $zero, $t0
	syscall
	#Print andMsg
	addi $v0, $zero, 4
	lui $at, 0x00001001
	ori $a0, $at, 0x00000042
	syscall
	#Print second value
	addi $v0, $zero, 1
	add $a0, $zero, $t1
	syscall
	#Print isMsg
	addi $v0, $zero, 4
	lui $at, 0x00001001
	ori $a0, $at, 0x00000048
	syscall
	#Print total of first and second values
	addi $v0, $zero, 1
	add $a0, $t0, $t1
	syscall
	
	#Terminate program
	addi $v0, $zero, 10
	syscall
	
	