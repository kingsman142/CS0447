.data
	buffer:	.space 64

.text
_strLength:
	add  $a0, $a0, $t1
	lbu  $t1, ($a0)
	slti $t2, $t1, 1
	beq  $t2, returnStrLength
	addi $t3, $t3, $t2
	addi $t4, $t4, 1
	addi $t1, $t1, 1
	j _strLength
	
	returnStrLength:
		addi $v0, $t3, 0
		jr   $ra
		
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
		
_subString:
	addi $t1, $ra, 0
	
	jal  _strLength
	
	addi $v0, $a1, 0
	