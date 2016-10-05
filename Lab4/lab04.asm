.data
	buffer:	.space 100
	enterString: .asciiz "Enter a string:\n"
	thisStringHas: .asciiz "This string has "
	characters: .asciiz " characters.\n"
	startIndex: .asciiz "Specify start index: "
	endIndex: .asciiz "Specify end index: "
	yourSubstring: .asciiz "Your substring is:\n"

.text
	j main

# 	Argument
# $a0 = address of a null-terminated string
# 	Return value
# $v0 = length of the specified string
_strLength:
	lbu  $t1, ($a0)
	slti $t2, $t1, 1
	beq  $t2, 1, returnStrLength
	add  $t3, $t3, 1
	add  $a0, $a0, 1
	j _strLength
	
	returnStrLength:
		addi $v0, $t3, 0
		jr   $ra

# 	Arguments
# $a0 = address of an input buffer
# $a1 = maximum number of characters to read into the buffer	
#	Return value
# None	
_readString:
	la   $a0, buffer   #Load the address of the buffer
	addi $v0, $0, 8    #Read string syscall
	addi $a1, $0, 100
	syscall
	
	#Find the length of the string and store the index of length-1 in $t2
	addi $s0, $ra, 0 #Keep $ra stored once we make a 2nd function call
	jal  _strLength
	addi $t2, $v0, 0
	subi $t2, $t2, 1
	
	#Replace the \n character with \0
	la   $a0, buffer
	add  $a0, $a0, $t2
	addi $t0, $0, 0
	sb   $t0, ($a0)
	
	#Make sure we turn back to main
	addi $ra, $s0, 0	
	jr $ra

# 	Arguments
# $a0 = address of an input string
# $a1 = address of an output buffer
# $a2 = start index for the input string (inclusive)
# $a3 = end index for the input string (exclusive)		
#	Return values
# $v0 = address of the output buffer (same as $a1)
_subString:
	slt  $t0, $t2, $a3
	beq  $t0, 1, setEndIndexToStringLength
	
	subStringAfterResettingEndIndex:
		#Check if either index is less than 0 or end < string
		slti $t0, $a2, 0
		beq  $t0, 1, returnEmptyString
		slti $t0, $a3, 0
		beq  $t0, 1, returnEmptyString
		slt  $t0, $a3, $a2
		beq  $t0, 1, returnEmptyString
		
		#
		# Store substring in $a1
		#
		addi $t0, $0, -1 #Index counter
		subi $a0, $a0, 1 #Match up input with index counter
		loop:
			addi $t0, $t0, 1
			addi $a0, $a0, 1
			
			#Make sure we can start reading the substring
			slt  $t1, $t0, $a2
			beq  $t1, 1, loop
			beq  $a3, $t0, return
			
			lbu  $t3, ($a0)
			sb   $t3, ($a1)
			addi $a1, $a1, 1
			
			j loop
		
		return:
			sb   $0, ($a1)
			sub  $a1, $a1, $a3
			add  $a1, $a1, $a2
			addi $v0, $a1, 0
			jr   $ra
		
	setEndIndexToStringLength:
		addi $a3, $t2, 0
		j subStringAfterResettingEndIndex
		
	returnEmptyString:
		sb   $0, ($a1)
		addi $v0, $a1, 0
		jr   $ra
	
main:
	# "Enter string: "
	addi $v0, $0, 4
	la   $a0, enterString
	syscall
	
	jal _readString
	
	# "This string has "
	addi $v0, $0, 4
	la   $a0, thisStringHas
	syscall
	
	#Print out number of characters
	addi $v0, $0, 1
	addi $a0, $t2, 0
	syscall
	
	# " characters."
	addi $v0, $0, 4
	la   $a0, characters
	syscall
	
	# "Specify start index: "
	addi $v0, $0, 4
	la   $a0, startIndex
	syscall
	
	#Store start index
	addi $v0, $0, 5
	syscall
	addi $t0, $v0, 0
	
	# "Specify end index: "
	addi $v0, $0, 4
	la   $a0, endIndex
	syscall
	
	#Store end index
	addi $v0, $0, 5
	syscall
	addi $t1, $v0, 0
	
	# "Your substring is: "
	addi $v0, $0, 4
	la   $a0, yourSubstring
	syscall
	
	#Print out substring
	la   $a0, buffer
	la   $a1, buffer
	addi $a2, $t0, 0
	addi $a3, $t1, 0
	jal  _subString
	
	addi $a0, $v0, 0
	addi $v0, $0, 4
	syscall