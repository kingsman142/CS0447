.data
	makeAMove: .asciiz "Make a move (R, P, S, Q): "
	youMadeMsg: .asciiz "\nYou made "
	computerMadeMsg: .asciiz ", Computer made "
	period: .asciiz "."
	youWonMsg: .asciiz "\nYou Won Congratulations"
	youLostMsg: .asciiz "\nYou lost, Good luck next time"
	rock: .asciiz "Rock"
	paper: .asciiz "Paper"
	scissors: .asciiz "Scissors"
	
.text
	addi $s0, $0, 80
	addi $s1, $0, 81
	addi $s2, $0, 82
	addi $s3, $0, 83

	#Generate random int with 3 as upper-bound and seed 5
	addi $v0, $0, 42
	addi $a0, $0, 5
	addi $a1, $0, 3
	syscall
	add  $t0, $0, $a0
	
	inputPrompt:
		#Print makeAMove
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000000
		syscall
	
		#Take user input to make a move
		addi $v0, $0, 8
		addi $a1, $0, 2
		lui  $at, 0x00001010
		ori  $a0, $at, 0x00000000
		syscall
		
	loop:		
		#Print youMadeMsg
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x0000001B
		syscall
		
		#Print user's move
		addi $v0, $0, 4
		lui $at, 0x00001010
		ori $a0, $at, 0x00000000
		beq  $s2, $a0, printRock
		beq  $s0, $a0, printPaper
		beq  $s3, $a0, printScissors
		beq  $s1, $a0, terminate
		
		loopAfterUserMoveOutput:
		
		#Print computerMadeMsg
		addi $v0, $0, 4
		lui $at, 0x00001001
		ori $a0, $at, 0x00000026
		syscall
		
		#Print computer's move
		addi $v0, $0, 1
		add  $a0, $0, $t0
		syscall
		#	also, print a period
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000031
		syscall
		
	printRock:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000071
		syscall
		j loopAfterUserMoveOutput
		
	printPaper:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000075
		j loopAfterUserMoveOutput
		
	printScissors:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x0000007A
		j loopAfterUserMoveOutput
	
	terminate:
		addi $v0, $0, 10
		syscall
