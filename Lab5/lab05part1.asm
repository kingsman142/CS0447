.data
	buffer: .space 100
	types: .asciiz "bit", "nybble", "byte", "half", "word"
	bits: .asciiz "one", "four", "eight", "sixteen", "thirty-two"
	pleaseEnterType: .asciiz "Please enter a datatype:\n"
	numberOfBits: .asciiz "Number of bits: "
	notFound: .asciiz "Not found!"

.text

	j _main

# Argument
# 	$a0 = address of a null-terminated string
# Return value
# 	$v0 = length of the specified string
_strLength:
	addi $t3, $0, 0
	
	counterLoop:
		lbu  $t1, ($a0)
		slti $t2, $t1, 1
		beq  $t2, 1, returnStrLength
		add  $t3, $t3, 1
		add  $a0, $a0, 1
		j    counterLoop
	
	returnStrLength:
		addi $v0, $t3, 0
		jr   $ra

# Arguments
# 	$a0 = address of an input buffer
# 	$a1 = maximum number of characters to read into the buffer	
# Return value
# 	None	
_readString:
	la   $a0, buffer   #Load the address of the buffer
	addi $v0, $0, 8    #Read string syscall
	addi $a1, $0, 100
	syscall
	
	#Find the length of the string and store the index of length-1 in $t2
	addi $t7, $ra, 0 #Keep $ra stored once we make a 2nd function call
	jal  _strLength
	addi $s0, $v0, 0
	subi $s0, $s0, 1
	
	#Replace the \n character with \0
	la   $a0, buffer
	add  $a0, $a0, $s0
	addi $t0, $0, 0
	sb   $t0, ($a0)
	
	#Make sure we turn back to main
	addi $ra, $t7, 0	
	jr   $ra
	
# Arguments
# 	$a0 = address of input 1
# 	$a1 = address of input 2
# Return value
# 	$v0 = 1 if the strings match, 0 otherwise
_checkType:
	loop:
		lbu  $t0, ($a0)
		lbu  $t1, ($a1)
		beq  $t0, 0, endOfStringReached
		beq  $t1, 0, endOfStringReached
		bne  $t0, $t1, returnFalse
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j    loop
		
	endOfStringReached:
		beq  $t0, $t1, returnTrue
		j    returnFalse
		
	returnFalse:
		addi $v0, $0, 0
		jr   $ra
	 
	returnTrue:
		addi $v0, $0, 1
		jr   $ra

# Arguments
# 	$a0 = address of a string array
# 	$a1 = index to look up
# Return value
# 	$v0 = address of string at index	
_lookUp:
	addi $t0, $0, 0
	addi $t7, $ra, 0 #Keep track of $ra
	
	loopElementsInArray:
		beq  $t0, $a1, return
		jal  _strLength
		addi $a0, $a0, 1
		addi $t0, $t0, 1
		j    loopElementsInArray
		
	return:
		addi $v0, $a0, 0
		addi $ra, $t7, 0
		jr   $ra
		
_main:
	addi $v0, $0, 4
	la   $a0, pleaseEnterType
	syscall
	
	la   $a0, buffer
	addi $a1, $0, 100
	jal _readString
	
	addi $s1, $0, 0 #Index of the type we're checking
	la   $a1, types
	checkTypes:
		#Check the two types
		la   $a0, buffer #User input
		jal  _checkType
		beq  $v0, 1, typeMatchFound #We found a match!
		addi $s1, $s1, 1 #Else, increment the index
		beq  $s1, 5, typeNotFound #If we reached the end of the array, we  haven't found a match
		
		#Look up index
		la   $a0, types
		addi $a1, $s1, 0
		jal  _lookUp
		
		#Store the next element in the array to $a1 for the next iteration
		addi $a1, $v0, 0
		
		j    checkTypes
	
	typeNotFound:
		addi $v0, $0, 4
		la   $a0, notFound
		syscall
	
		j terminate
	
	typeMatchFound:
		#Print out "Number of bits: "
		addi $v0, $0, 4
		la   $a0, numberOfBits
		syscall
		
		la   $a0, bits
		addi $a1, $s1, 0
		jal  _lookUp
		addi $a0, $v0, 0
		addi $v0, $0, 4
		syscall
		
	j terminate
	
terminate:
	addi $v0, $0, 10
	syscall
