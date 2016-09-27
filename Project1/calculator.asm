.text
	processFirstOperand:
		beq  $t9, $0, processFirstOperand #Wait for input
		
		#Normalize bits of input
		andi $t9, $t9, 0x0FFFFFFF
		slti $t3, $t9, 10
		beq  $t3, 0, operator #Break if it's not a number
		
		#Add a new digit to the already existing number
		addi $t5, $t0, 0
		sll  $t0, $t0, 3
		add  $t0, $t0, $t5
		add  $t0, $t0, $t5		
		
		#Store the number in the register $t0 and display it
		add  $t0, $t0, $t9		
		addi $t9, $0, 0
		addi $t8, $t0, 0
		
		j processFirstOperand
		
	processSecondOperand:
		beq  $t9, $0, processSecondOperand #Wait for input
		
		#Normalize bits of input
		andi $t9, $t9, 0x0FFFFFFF
		slti $t3, $t9, 10
		beq  $t3, 0, operator #Break if it's not a number
		
		#Add a new digit to the already existing number
		addi $t5, $t1, 0
		sll  $t1, $t1, 3
		add  $t1, $t1, $t5
		add  $t1, $t1, $t5		
		
		#Store the number in the register $t1 and display it
		add  $t1, $t1, $t9		
		addi $t9, $0, 0
		addi $t8, $t1, 0
		
		j processSecondOperand
		
	operator:
		beq  $t9, 14, calculate # Equals key
		beq  $t9, 15, clearData # C key
		addi $t2, $t9, 0 #Set the operator (+ - * /)
		addi $t9, $0, 0 #Reset input register
		j processSecondOperand
		
	calculate:
		beq  $t2, 10, add
		beq  $t2, 11, subtract
		
		addi $t4, $t0, 0 #If we're multiplying or dividing, we need another register
		addi $t0, $0, 0
		
		beq  $t2, 12, multiply
		
		addi $t0, $t4, 0
		beq  $t2, 13, divide
		j processSecondOperand
	
	clearData:
		addi $t0, $0, 0
		addi $t1, $0, 0
		addi $t2, $0, 0
		addi $t3, $0, 0
		addi $t4, $0, 0
		addi $t5, $0, 0
		addi $t6, $0, 0
		addi $t7, $0, 0
		addi $t8, $0, 0
		addi $t9, $0, 0
		j processFirstOperand
		
	add:
		add  $t0, $t0, $t1 #Add the two operands and store result in $t0
		addi $t9, $0, 0 #Make sure register $t9 is reset after calculating
		addi $t8, $t0, 0
		addi $t1, $0, 0
		j processSecondOperand
	
	subtract:
		sub  $t0, $t0, $t1 #Subtract the two operands and store result in $t0
		addi $t9, $0, 0 #Make sure register $t2 is reset after calculating
		addi $t8, $t0, 0
		addi $t1, $0, 0
		j processSecondOperand
	
	multiply:
		beq  $t1, 0, processSecondOperand
		add  $t0, $t0, $t4
		sub  $t1, $t1, 1
		bne  $t1, 0, multiply
		addi $t9, $0, 0
		addi $t8, $t0, 0
		j processSecondOperand
	
	divide:
		slt  $t7, $t0, $t1
		beq  $t7, 1, displayDivide
	
		sub  $t0, $t0, $t1
		addi $t6, $t6, 1
		slt  $t7, $t0, $t1
		beq  $t7, 1, displayDivide
		
		j divide
		
		displayDivide:
			addi $t9, $0, 0
			addi $t0, $t6, 0
			addi $t8, $t0, 0
			addi $t1, $0, 0
			addi $t6, $0, 0
			j processSecondOperand