.data
	makeAMove: .asciiz "Make a move (R, P, S, Q): "
	youMadeMsg: .asciiz "\nYou made "
	computerMadeMsg: .asciiz ", Computer made "
	period: .asciiz "."
	youWonMsg: .asciiz "\n\"You Won Congratulations\"\n\n"
	youLostMsg: .asciiz "\n\"You lost, Good luck next time\"\n\n"
	rock: .asciiz "Rock"
	paper: .asciiz "Paper"
	scissors: .asciiz "Scissors"
	tieMsg: .asciiz "\n\"Tie\"\n\n"
	
.text
	addi $s0, $0, 80
	addi $s1, $0, 81
	addi $s2, $0, 82
	addi $s3, $0, 83
	addi $s4, $0, 0
	addi $s5, $0, 1
	addi $s6, $0, 2
		
	loop:
		j generateComputerMove
		
		loopAfterComputerMove:
	
		j inputPrompt
		
		loopAfterUserInput:
		
		#Print youMadeMsg
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x0000001B
		syscall
		
		#Print user's move
		addi $v0, $0, 4
		lui  $at, 0x00001010
		ori  $a0, $at, 0x00000000
		lw   $t1, ($a0)
		beq  $s2, $t1, printUserRock
		beq  $s0, $t1, printUserPaper
		beq  $s3, $t1, printUserScissors
		beq  $s1, $t1, terminate
		
		loopAfterUserMoveOutput:
		
		#Print computerMadeMsg
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000026
		syscall
		
		#Print computer's move
		beq  $t0, $s4, printComputerRock
		beq  $t0, $s5, printComputerPaper
		beq  $t0, $s6, printComputerScissors
		
		loopAfterComputerMoveOutput:
		
		#	also, print a period
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000037
		syscall
		
		beq  $t1, 80, normalizeToPaper
		beq  $t1, 82, normalizeToRock
		beq  $t1, 83, normalizeToScissors
		
		loopAfterInputNormalize:
		
		beq  $t0, $t1, loopBack
		
		beq  $t1, 0, compareUserInputRockToComputer
		beq  $t1, 1, compareUserInputPaperToComputer
		beq  $t1, 2, compareUserInputScissorsToComputer
		
		loopAfterGameOutput:
		
		j loop
		
	generateComputerMove:
		#Get System time
		addi $v0, $0, 30
		syscall
		#Lower Order system time for RNG Seed
		addi $t3, $a0, 0
		
		#Set RNG Seed
		addi $v0, $0, 40
		addi $a1, $t3, 0
		addi $a0, $0, 0
		syscall
	
		#Generate random int with 3 as upper-bound and seed 5
		addi $v0, $0, 42
		addi $a0, $0, 0
		addi $a1, $0, 3
		syscall
		add  $t0, $0, $a0
		j loopAfterComputerMove
		
	loopBack:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x0000008D
		syscall
		j loop
		
	normalizeToRock:
		addi $t1, $0, 0
		j loopAfterInputNormalize
		
	normalizeToPaper:
		addi $t1, $0, 1
		j loopAfterInputNormalize
	
	normalizeToScissors:
		addi $t1, $0, 2
		j loopAfterInputNormalize
	
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
		
		#Terminate if user enters Q
		lw   $t1, ($a0)
		beq  $t1, $s1, terminate
		j loopAfterUserInput
		
	printUserRock:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000079
		syscall
		j loopAfterUserMoveOutput
		
	printUserPaper:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x0000007E
		syscall
		j loopAfterUserMoveOutput
		
	printUserScissors:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000084
		syscall
		j loopAfterUserMoveOutput
		
	printComputerRock:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000079
		syscall
		j loopAfterComputerMoveOutput
		
	printComputerPaper:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x0000007E
		syscall
		j loopAfterComputerMoveOutput
		
	printComputerScissors:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000084
		syscall
		j loopAfterComputerMoveOutput
		
	compareUserInputRockToComputer:
		beq  $t0, 1, printUserLost
		beq  $t0, 2, printUserWon
		
	compareUserInputPaperToComputer:
		beq  $t0, 0, printUserWon
		beq  $t0, 2, printUserLost
		
	compareUserInputScissorsToComputer:
		beq  $t0, 0, printUserLost
		beq  $t0, 1, printUserWon
		
	printUserWon:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000039
		syscall
		j loopAfterGameOutput
		
	printUserLost:
		addi $v0, $0, 4
		lui  $at, 0x00001001
		ori  $a0, $at, 0x00000056
		syscall
		j loopAfterGameOutput
	
	terminate:
		addi $v0, $0, 10
		syscall
