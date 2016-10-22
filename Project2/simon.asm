.data
	moves:	.space	100

.text
	j _main

_playSequence:
	addi $a0, $0, 1
	addi $a1, $0, 4
	addi $v0, $0, 42 #Generate random number
	syscall
	
	#a0 is where the random int from 0-4 is stored
	beq $a0, 0, addBlue
	beq $a0, 1, addYellow
	beq $a0, 2, addGreen
	beq $a0, 3, addRed	
	
	addRed:
		addi $t1, $0, 8
		sb $t1, ($s0)
		j play
	addGreen:
		addi $t1, $0, 4
		sb $t1, ($s0)
		j play
	addYellow:
		addi $t1, $0, 2
		sb $t1, ($s0)
		j play
	addBlue:
		addi $t1, $0, 1
		sb $t1, ($s0)
		j play
		
	play:
		addi $s0, $s0, 1 #Advance the pointer of the end of the moves sequence
				 #	so we know where to append the next move
		la   $t0, moves
		loop:
			lb   $t1, ($t0)
			beq  $t1, 0, return
			
			addi $t8, $t1, 0
			waitForColorToLightUp:
				bne  $t8, $0, waitForColorToLightUp
				
			addi $t0, $t0, 1 #Advance the sequence by 1
			j loop
			
	return:
		jr $ra
		
#Returns 1 to $v0 if correct sequence was entered or a 0 to $v0 if otherwise
_userPlay:
	addi $t9, $0, 0
	la   $t0, moves
	
	waitForUser:
		lb   $t1, ($t0)
		beq  $t1, $0, correctSequence #End of the sequence comes up and there hasn't been a wrong answer
		beq  $t9, $0, waitForUser #Wait for user input
		addi $t8, $t9, 0 #Show the user's color
		waitForUserColorToLightUp:
			bne  $t8, $0, waitForUserColorToLightUp
		addi $t0, $t0, 1 #Advance through the sequence
		bne  $t9, $t1, wrongAnswer #The sequence and user input don't match
		addi $t9, $0, 0
		j waitForUser
		
	wrongAnswer:
		addi $v0, $0, 0
		jr   $ra
		
	correctSequence:
		addi $v0, $0, 1
		jr   $ra
		
_clearMoves:
	la   $t0, moves
	clearLoop:
		lb   $t1, ($t0)
		beq  $t1, $0, doneClearing #We've reached the end of all the moves
		sb   $0, ($t0)   #Store a zero in the next position
		addi $t0, $t0, 1 #Advance the pointer
		j clearLoop
		
	doneClearing:
		jr   $ra

_main:
	waitToStartGame:
		beq  $t9, 16, initGame
		bne  $t9, $0, resetInputButton
		j    waitToStartGame
	
	resetInputButton:
		addi $t9, $0, 0
		j waitToStartGame
	
	initGame:
		addi $t8, $0, 16
		la   $s0, moves #Store the beginning of moves in $s0
		j gameLoop

	gameLoop:
		jal _playSequence
		jal _userPlay
		beq $v0, 0, userLost #If 0 is returned, the user didn't enter the correct sequence
		j gameLoop
		
	userLost:
		addi $t8, $0, 15 #Blink all 3 colors and play the lose tone
		addi $t9, $0, 0 #Reset the register for user input
		addi $t8, $0, 0 #Reset the register for displaying stuff
		addi $s0, $0, 0 #Reset the pointer for the moves
		jal  _clearMoves
		j _main

exit:
	addi $v0, $0, 10
	syscall
