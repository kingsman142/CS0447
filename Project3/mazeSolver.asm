.data
	path:	      .space 200 
	straightPath: .space 200
	endRow:	      .space 4
	endColumn:    .space 4

.text
	j main

# Used in backtracking; from the car's initial orientation, move it left
# Arguments
# 	a0 - Car's information stored in $t9
_moveCarLeft:
	andi $t0, $a0, 0x00000F00 # Get car's orientation initially at the location
	sll  $t0, $t0, 1 # Get the corrent direction after turning left
	andi $t1, $t9, 0x00000F00
	
	rotateCarLeft:
		beq  $t1, $t0, moveCarLeft
		sll  $t1, $t1, 1
		addi $t8, $0, 2 # Rotate car left once
		j rotateCarLeft
	moveCarLeft:
		addi $t8, $0, 1 # Move car forward once
		
	jr $ra
	
# Used in backtracking; from the car's initial orientation, move it right
# Arguments
# 	a0 - Car's information stored in $t9
_moveCarRight:
	andi $t0, $a0, 0x00000F00 # Get car's orientation initially at the location
	srl  $t0, $t0, 1 # Get the corrent direction after turning right
	andi $t1, $t9, 0x00000F00
	
	rotateCarRight:
		beq  $t1, $t0, moveCarRight
		srl  $t1, $t1, 1
		addi $t8, $0, 3 # Rotate car right once
		j rotateCarRight
	moveCarRight:
		addi $t8, $0, 1 # Move car forward once
		
	jr $ra
	
# Used in backtracking; from the car's initial orientation, move it forward
# Arguments
# 	a0 - Car's information stored in $t9
_moveCarForward:
	andi $t0, $a0, 0x00000F00 # Get car's orientation initially at the location
	andi $t1, $t9, 0x00000F00
	
	rotateCarForward:
		beq  $t1, $t0, moveCarForward
		sll  $t1, $t1, 1
		addi $t8, $0, 2 # Rotate car left once
		j rotateCarForward
	moveCarForward:
		addi $t8, $0, 1 # Move car forward once
		
	jr $ra
	

# Used in backtracking; from the car's initial orientation, move it backwards; used for dead-ends
# Arguments
# 	a0 - Car's information stored in $t9
_moveCarBackward:
	andi $t0, $t9, 0x00000F00 # Get car's orientation initially at the location
	sll  $t0, $t0, 2 # Get the current direction after turning left
	andi $t1, $t9, 0x00000F00
	andi $t2, $a0, 0x00000F00 # Car's initial orientation, used later to return to initial orientation
	
	rotateCarBackward:
		beq  $t1, $t0, moveCarBackward
		sll  $t1, $t1, 1
		addi $t8, $0, 2 # Rotate car left once
		j rotateCarBackward
	moveCarBackward:
		addi $t8, $0, 1 # Move car forward once
	rotateToInitialOrientation:
		andi $t3, $t9, 0x00000F00
		beq  $t3, $t2, doneRotatingOrientation
		addi $t8, $0, 3
		j    rotateToInitialOrientation
	doneRotatingOrientation:
		
	jr $ra

# Recursively using backtracking to navigate the car from the top-left of the maze
# 	to the bottom-right.
# Arguments
# 	a0 - car information in previous state
# Return
# 	v0 - 1 if exit found
#	     0 otherwise
_backtracking:
	andi $t0, $t9, 0x0000000F # Get the status of the neighboring walls
	andi $t4, $t9, 0xFF000000 # Current row position
	andi $t5, $t9, 0x00FF0000 # Current column position
	addi $t7, $t9, 0 # Current car information
	
	lw   $t2, endRow
	lw   $t3, endColumn
	bne  $t4, $t2, backtrackingNotSolved # Check if we're in the end row
	bne  $t5, $t3, backtrackingNotSolved # Check if we're in the end column
	addi $v0, $0, 1 # Maze is solved so we can just return
	j    exitRecursiveMovements
	
	backtrackingNotSolved:
	addi $v0, $0, 0 # Maze is not solved yet so don't return yet
	
	andi $t6, $t9, 0x00000F00
	beq  $t6, 0x00000800, north
	beq  $t6, 0x00000400, east
	beq  $t6, 0x00000200, south
	beq  $t6, 0x00000100, west
	
	north:
		checkForwardWallNorth:
			and  $t1, $t0, 0x00000008 # Check front wall status
			beq  $t1, 8, checkLeftWallNorth
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarForward
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)	
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkLeftWallNorth:
			and  $t1, $t0, 0x00000004 # Check left wall status
			beq  $t1, 4, checkRightWallNorth
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarLeft
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkRightWallNorth:
			and  $t1, $t0, 0x00000002 # Check right wall status
			beq  $t1, 2, checkBehindWallNorth
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarRight
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkBehindWallNorth:
			and  $t1, $t0, 0x00000001
			beq  $t1, 1, exitRecursiveMovements
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $a0, 0
			jal  _moveCarBackward
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			j    exitRecursiveMovements
			beq  $v0, 1, exitRecursiveMovements
			j    exitRecursiveMovements
	west:
		checkRightWallWest:
			and  $t1, $t0, 0x00000002 # Check right wall status
			beq  $t1, 2, checkForwardWallWest
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarRight
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkForwardWallWest:
			and  $t1, $t0, 0x00000008 # Check front wall status
			beq  $t1, 8, checkLeftWallWest
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarForward
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)	
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkLeftWallWest:
			and  $t1, $t0, 0x00000004 # Check left wall status
			beq  $t1, 4, checkBehindWallWest
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarLeft
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkBehindWallWest:
			and  $t1, $t0, 0x00000001
			beq  $t1, 1, exitRecursiveMovements
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $a0, 0
			jal  _moveCarBackward
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			j    exitRecursiveMovements
			beq  $v0, 1, exitRecursiveMovements
			j    exitRecursiveMovements
	south:
		checkRightWallSouth:
			and  $t1, $t0, 0x00000002 # Check right wall status
			beq  $t1, 2, checkForwardWallSouth
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarRight
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkForwardWallSouth:
			and  $t1, $t0, 0x00000008 # Check front wall status
			beq  $t1, 8, checkLeftWallSouth
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarForward
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)	
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkLeftWallSouth:
			and  $t1, $t0, 0x00000004 # Check left wall status
			beq  $t1, 4, checkBehindWallSouth
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarLeft
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkBehindWallSouth:
			and  $t1, $t0, 0x00000001
			beq  $t1, 1, exitRecursiveMovements
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $a0, 0
			jal  _moveCarBackward
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			j    exitRecursiveMovements
			beq  $v0, 1, exitRecursiveMovements
			j    exitRecursiveMovements
	east:
		checkLeftWallEast:
			and  $t1, $t0, 0x00000004 # Check left wall status
			beq  $t1, 4, checkRightWallEast
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarLeft
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkRightWallEast:
			and  $t1, $t0, 0x00000002 # Check right wall status
			beq  $t1, 2, checkForwardWallEast
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarRight
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkForwardWallEast:
			and  $t1, $t0, 0x00000008 # Check front wall status
			beq  $t1, 8, checkBehindWallEast
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $t9, 0
			jal  _moveCarForward
			addi $a0, $t7, 0
			jal  _backtracking
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)	
			addi $sp, $sp, 16
			beq  $v0, 1, exitRecursiveMovements
		checkBehindWallEast:
			and  $t1, $t0, 0x00000001
			beq  $t1, 1, exitRecursiveMovements
			subi $sp, $sp, 16
			sw   $a0, 12($sp)
			sw   $t7, 8($sp)
			sw   $ra, 4($sp)
			sw   $t0, 0($sp)
			addi $a0, $a0, 0
			jal  _moveCarBackward
			lw   $t0, 0($sp)
			lw   $ra, 4($sp)
			lw   $t7, 8($sp)
			lw   $a0, 12($sp)		
			addi $sp, $sp, 16
			j    exitRecursiveMovements
			beq  $v0, 1, exitRecursiveMovements
			j    exitRecursiveMovements
	exitRecursiveMovements:
	
	jr $ra

# Following 4 functions are helper methods for the traceback of the car

_moveUp:
	rotateCarToFaceUp:
		andi $t0, $t9, 0x00000F00 # Get the direction the car is currently facing
		beq  $t0, 0x00000800, finishedRotatingUp 
		beq  $t0, 0x00000100, rotateUpRight # Facing west
		
		addi $t8, $0, 2 # Rotate left
		j    rotateCarToFaceUp
		
		rotateUpRight:
			addi $t8, $0, 3 # Rotate right
			j    rotateCarToFaceUp
			
	finishedRotatingUp:
		addi $t8, $0, 1 # Move car forward
		jr   $ra
	
_moveDown:
	rotateCarToFaceDown:
		andi $t0, $t9, 0x00000F00 # Get the direction the car is currently facing
		beq  $t0, 0x00000200, finishedRotatingDown
		beq  $t0, 0x00000400, rotateDownRight # Facing east
		
		addi $t8, $0, 2 # Rotate left
		j    rotateCarToFaceDown
		
		rotateDownRight:
			addi $t8, $0, 3 # Rotate right
			j    rotateCarToFaceDown
			
	finishedRotatingDown:
		addi $t8, $0, 1 # Move car forward
		jr   $ra

_moveLeft:
	rotateCarToFaceLeft:
		andi $t0, $t9, 0x00000F00 # Get the direction the car is currently facing
		beq  $t0, 0x00000100, finishedRotatingLeft 
		beq  $t0, 0x00000200, rotateLeftRight # Facing south
		
		addi $t8, $0, 2 # Rotate left
		j    rotateCarToFaceLeft
		
		rotateLeftRight:
			addi $t8, $0, 3 # Rotate right
			j    rotateCarToFaceLeft
			
	finishedRotatingLeft:
		addi $t8, $0, 1 # Move car forward
		jr   $ra

_moveRight:
	rotateCarToFaceRight:
		andi $t0, $t9, 0x00000F00 # Get the direction the car is currently facing
		beq  $t0, 0x00000400, finishedRotatingRight
		beq  $t0, 0x00000800, rotateRightRight # Facing north
		
		addi $t8, $0, 2 # Rotate left
		j    rotateCarToFaceRight
		
		rotateRightRight:
			addi $t8, $0, 3 # Rotate right
			j    rotateCarToFaceRight
			
	finishedRotatingRight:
		addi $t8, $0, 1 # Move car forward
		jr   $ra

# After using the left hand rule, use the path generated from that to go directly
# 	back to the top-left of the maze without having to backtrack in any way.
_traceBack:
	la $t0, straightPath
	
	traverseToEndOfPath:
		addi $t0, $t0, 2
		lh   $t1, ($t0)
		beq  $t1, 0, followPath
		j traverseToEndOfPath
	followPath:
		subi $t0, $t0, 2
		lb   $t2, 0($t0) # Old Y coordinate
		lb   $t3, 1($t0) # Old X coordinate
		lb   $t4, -2($t0) # New Y coordinate
		lb   $t5, -1($t0) # New X coordinate
		sub  $t6, $t4, $t2 # Difference between Y coordinates
		addi $t8, $0, 4
		beq  $t6, -1, traceCarUp
		beq  $t6, 1, traceCarDown
		sub  $t6, $t5, $t3 # Difference between X coordinates
		beq  $t6, -1, traceCarLeft
		beq  $t6, 1 traceCarRight
		j    backAtStartAfterTracing # There are no differences between the coordinates so the car is at (0, 0)
		
		traceCarDown:
			subi $sp, $sp, 8
			sw   $t0, 4($sp)
			sw   $ra, 0($sp)
			jal  _moveDown
			lw   $ra, 0($sp)
			lw   $t0, 4($sp)
			addi $sp, $sp, 8
			j    followPath
		traceCarUp:
			subi $sp, $sp, 8
			sw   $t0, 4($sp)
			sw   $ra, 0($sp)
			jal  _moveUp
			lw   $ra, 0($sp)
			lw   $t0, 4($sp)
			addi $sp, $sp, 8
			j    followPath
		traceCarLeft:
			subi $sp, $sp, 8
			sw   $t0, 4($sp)
			sw   $ra, 0($sp)
			jal  _moveLeft
			lw   $ra, 0($sp)
			lw   $t0, 4($sp)
			addi $sp, $sp, 8
			j    followPath
		traceCarRight:
			subi $sp, $sp, 8
			sw   $t0, 4($sp)
			sw   $ra, 0($sp)
			jal  _moveRight
			lw   $ra, 0($sp)
			lw   $t0, 4($sp)
			addi $sp, $sp, 8
			j    followPath

	backAtStartAfterTracing:
		jr $ra

# Use the left hand rule to navigate form the top-left of the maze to the bottom-right
# Returns
# 	v0 - address at end of path
_leftHandRule:
	la $t4, path # Load the address of the path that must be written to
	
	addi $t8, $0, 1 # Move forward

	leftHandLoop:	
		andi $t3, $t9, 0xFF000000 # Current row position
		andi $t7, $t9, 0x00FF0000 # Current column position	
		
		andi $t1, $t9, 0xFF000000
		andi $t2, $t9, 0x00FF0000
		srl  $t1, $t1, 24
		srl  $t2, $t2, 16
		sb   $t1, 0($t4)	
		sb   $t2, 1($t4)
		addi $t4, $t4, 2
		
		lw   $t5, endRow
		lw   $t6, endColumn
		bne  $t3, $t5, tryToMoveLeft # Check if we're in the end row
		bne  $t7, $t6, tryToMoveLeft # Check if we're in the end column
		j    leftHandSolved # If we're in the end position and made it to this line, the maze has been solved
		
		tryToMoveLeft:
			andi $t0, $t9, 0x00000004 # Check the left wall status of the car
			beq  $t0, 0x00000004, tryToMoveForward # Left wall exists, so try to go forward
			addi $t8, $0, 2 # Turn left
			j    moveForward # No wall in front of the car
		tryToMoveForward:
			andi $t0, $t9, 0x00000008 # Check the front wall status of the car
			beq  $t0, 0x00000008, tryToMoveRight # Front wall exists, so try to turn right
			j    moveForward # No wall in front of the car
		tryToMoveRight:
			addi $t8, $0, 3
			andi $t0, $t9, 0x00000008
			beq  $t0, $0, moveForward
			j    tryToMoveRight
		j leftHandLoop
	
		moveForward:
			addi $t8, $0, 1
			j leftHandLoop
	
	leftHandSolved:
		addi $v0, $t4, 0
		jr   $ra
	
# After using the left hand rule, remove all duplicate points
# 	in the path so the car has a straightforward drive
# 	to the beginning of the maze.
# Arguments
# 	a0 - address of end of path
_removeDuplicatePaths:
	la $t0, path
	la $t1, straightPath
	
	loopThroughCoordinates:
		addi $t2, $0, 0 # Last occurance of the current coordinates in the path
		
		# Load the current coordinates of the path
		lh   $t3, 0($t0)
		addi $t0, $t0, 2
		
		# Store the current coordinates in the new path
		sh   $t3, 0($t1)
		addi $t1, $t1, 2
		
		beq  $t0, $a0, returnNewList # Reached the end of the list; no duplicates are possible
		
		addi $t4, $t0, 0
		searchForDuplicates:
			lh   $t5, 0($t4)
			addi $t4, $t4, 2
			beq  $t4, $a0, finishSearchingForDuplicates # Reached end of path
			beq  $t5, $t3, setNewDuplicate # Found a duplicate
			j    searchForDuplicates
			
			setNewDuplicate:
				addi $t2, $t4, 0 # Most recent duplicate is now stored in $t2
				j    searchForDuplicates
		
		finishSearchingForDuplicates:
			beq  $t2, $0, loopThroughCoordinates # No duplicates
			addi $t0, $t2, 0 # Set new location in the path
			j loopThroughCoordinates
			
	returnNewList:
		jr $ra

# After a traceback, make sure the car returns back to its original position outside of the maze	
_returnToOriginFromZeroZero:
	andi $t0, $t9, 0x00000F00 # Get the orientation of the car
	andi $t1, $t0, 0x00000800 # Facing north
	beq  $t1, 0x00000800, returnToOriginByTurningLeft
	andi $t1, $t0, 0x00000100 # Facing west
	beq  $t1, 0x00000100, returnToOriginByMovingForward
	jr   $ra
	
	returnToOriginByTurningLeft:
		addi $t8, $0, 2
		addi $t8, $0, 1
		jr   $ra
	returnToOriginByMovingForward:
		addi $t8, $0, 1
		jr   $ra	

main:
	addi $t0, $0, 0x07000000 # Set the row dimension of the maze
	addi $t1, $0, 0x00080000 # Set the column dimension of the maze - 1 more than the row dimension
	sw   $t0, endRow
	sw   $t1, endColumn
	
	jal _leftHandRule
	
	# Turn around
	addi $t8, $0, 2
	addi $t8, $0, 2
	
	addi $a0, $v0, 0 # Pass in the end of the path to _removeDuplicatePaths
	jal _removeDuplicatePaths
	jal _traceBack
	
	# Return to origin outside of maze
	jal  _moveLeft	
	# Turn around
	addi $t8, $0, 2
	addi $t8, $0, 2
	
	addi $a0, $t9, 0
	jal _backtracking
