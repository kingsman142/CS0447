.data
	enterN: .asciiz "Enter a nonnegative integer: "
	invalidInput: .asciiz "Invalid integer; try again.\n"
	febParen: .asciiz "Feb("
	rightParen: .asciiz ") = "

.text
	j _main

# Argument
# 	$a0 = index of fibonacci sequence to find
# Return value
# 	$v0 = fibonacci sequence value at index $a0	
_fibonacciRecurs:
	slti $t0, $a0, 2
	beq  $t0, 1, returnN
	
	# n-1
	subi $a0, $a0, 1
	
	addi $sp, $sp, -12
	sw   $ra, 0($sp) #Store return address
	sw   $a0, 4($sp) #Store $a0 so we can decrement it later
	sw   $t0, 8($sp)
	
	addi $t0, $0, 0
	
	# Call recursive function on (n-1)
	jal  _fibonacciRecurs
	
	lw   $t0, 8($sp) #Current sum
	lw   $a0, 4($sp)
	lw   $ra, 0($sp) 
	#addi $sp, $sp, 12
	
	add  $t0, $t0, $v0
	
	# n-2
	subi $a0, $a0, 1
	
	addi $sp, $sp, -12
	sw   $ra, 0($sp)
	sw   $a0, 4($sp)
	sw   $t0, 8($sp)
	
	# Call recursive function on (n-2)
	jal  _fibonacciRecurs
	
	lw   $t0, 8($sp) #Current sum
	lw   $a0, 4($sp)
	lw   $ra, 0($sp)
	addi $sp, $sp, 24
	
	add  $t0, $t0, $v0
	
	addi $v0, $t0, 0
	jr   $ra

	returnN:
		addi $v0, $a0, 0
		jr   $ra
		
	

_main:
	askUserForInput:
		addi $v0, $0, 4
		la   $a0, enterN
		syscall
		
		addi $v0, $0, 5
		syscall
		addi $t2, $v0, 0
		
		slti $t0, $t2, 0
		beq  $t0, 0, fibonacciRecursCall
		
		addi $v0, $0, 4
		la   $a0, invalidInput
		syscall
		
		beq  $t0, 1, askUserForInput
		
	fibonacciRecursCall:					
		#Set the initial values for fibonacci's sequence
		addi $t0, $0, 0
		addi $t1, $0, 1
		
		addi $sp, $sp, -8
		sw   $t2, 0($sp) #Store user input
		sw   $0 , 4($sp) #Total sum
		
		#Set the index and call _fibonacciRecus
		addi $a0, $t2, 0
		jal  _fibonacciRecurs
		
		#Store the fibonacci value
		addi $t0, $v0, 0
		
		addi $v0, $0, 4
		la   $a0, febParen
		syscall
		
		addi $v0, $0, 1
		
		lw   $t1, 4($sp) #Load sum after call to fibonacciRecurs
		lw   $t2, 0($sp) #Load original user input
		addi $sp, $sp, 8
		
		addi $a0, $t2, 0
		syscall
		
		addi $v0, $0, 4
		la   $a0, rightParen
		syscall
		
		addi $v0, $0, 1
		addi $a0, $t0, 0
		syscall
		
		j    terminate
		
terminate:
	addi $v0, $0, 10
	syscall