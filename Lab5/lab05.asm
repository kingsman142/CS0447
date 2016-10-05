.data
	types: .asciiz “bit”, “nybble”, “byte”, “half”, “word”
	bits: .asciiz “one”, “four”, “eight”, “sixteen”, “thirty-two”
	pleaseEnterType: .asciiz "Please enter a datatype:"

.text

	j _main

_readString:
	la   $a2, (buffer) #Load the address of the buffer
	addi $v0, $0, 8    #Read string syscall
	syscall
	
	jal  _strLength
	addi $t2, $v0, 0
	subi $t2, $t2, 1
	
	searchForEndOfString:
		add  $a0, $a0, $t1
		la   $t0, ($a0)
		beq  $t1, $t2, insertNUL
		addi $t1, $t1, 1
		j searchForEndOfString
		
	insertNUL:
		jr $ra
		
_main:
	addi $v0, $0, 4
	la   $a0, pleaseEnterType
	syscall
	
	jal _readString