.data
	letters:	.word	0x8888887e, 0x0000007e, 0x929292fe, 0x0000006c, 0x8282827c, 0x00000044, 0x828282fe, 0x0000007c, 0x929292fe, 0x00000082, 0x909090fe, 0x00000080,
				#A			B			C			D			E			F
				0x8a8a827c, 0x0000004c, 0x101010fe, 0x000000fe, 0x82fe8200, 0x00000000, 0x0202020c, 0x000000fc, 0x442810fe, 0x00000082, 0x020202fe, 0x00000002,
				#G			H			I			J			K			L
				0x402040fe, 0x000000fe, 0x081020fe, 0x000000fe, 0x8282827c, 0x0000007c, 0x888888fe, 0x00000070, 0x868a827c, 0x0000007e, 0x888888fe, 0x00000076,
				#M			N			O			P			Q			R
				0x92929264, 0x0000004c, 0x80fe8080, 0x00000080, 0x020202fc, 0x000000fc, 0x040204f8, 0x000000f8, 0x040804fe, 0x000000fe, 0x281028c6, 0x000000c6,
				#S			T			U			V			W			X
				0x100e10e0, 0x000000e0, 0xa2928a86, 0x000000c2
				#Y			Z
	digits:		.word	0x828282fe, 0x000000fe, 0x0042fe02, 0x00000000, 0x9292929e, 0x000000f2, 0x92929292, 0x000000fe, 0x101010f0, 0x000000fe, 0x929292f2, 0x0000009e,
				#0			1			2			3			4			5
				0x929292fe, 0x0000009e, 0x908e8080, 0x000000e0, 0x929292fe, 0x000000fe, 0x929292f2, 0x000000fe
				#6			7			8			9
	msg:		.asciiz	"GOOD JOB YOU JUST GET 100 POINTS"

.text
	lui  $sp, 0x7fff		# $sp = 0x7fff0000
	ori  $sp, $sp, 0xeffc		# $sp = 0x7fffeffc
	#la   $s1, msg
	lui  $s1, 0x1001		# Replace la $s1, msg
	ori  $s1, $s1, 0x0120		# Replace la $s1, msg
loop:
	lbu  $s2, 0($s1)		# Load a character from msg
	beq  $s2, $zero, done		# If the character is null, done
	add  $a0, $zero, $s2		# Put the character as the argument of _displayCharacter
	jal  _displayCharacter		# Call _displayCharacter
	addi $s1, $s1, 1		# Increase the address of msg by 1
	j    loop			# Go back to loop
done:
	j    done			# Infinite loop

# _displayCharacter
#
# Shift in the new character
#
# Arguments:
#   - $a0: character to display
# Return Values:
#   - None
_displayCharacter:
	addi $sp, $sp, -12		# Create an activation frame
	sw   $s1, 8($sp)		# Backup $s1
	sw   $s0, 4($sp)		# Backup $s0
	sw   $ra, 0($sp)		# Backup $ra
	addi $s0, $zero, 32		# $s0 = 32 (space character)
	bne  $s0, $a0, dDigit		# If the character is not a space, continue
	add  $a0, $zero, $zero		# It is a space, shift 0 in 6 times
	jal  _shiftColumnsLeft		#
	add  $a0, $zero, $zero		#
	jal  _shiftColumnsLeft		#
	add  $a0, $zero, $zero		#
	jal  _shiftColumnsLeft		#
	add  $a0, $zero, $zero		#
	jal  _shiftColumnsLeft		#
	add  $a0, $zero, $zero		#
	jal  _shiftColumnsLeft		#
	add  $a0, $zero, $zero		#
	jal  _shiftColumnsLeft		#
	j    dDone			# Go to done
dDigit:
	addi $s0, $zero, 58		# $s0 = 58 (57 is the character 9)
	slt  $s0, $a0, $s0		# Check whether the character is a digit
	beq  $s0, $zero, dChar		# If it is not a digit, go do dChar
	addi $s0, $a0, -48		# Subtract the character by 48 to get the digit 0 - 9
	#la   $s1, digits
	lui  $s1, 0x1001		# Replace la $s1, digits
	ori  $s1, $s1, 0x00d0		# Replace la $s1, digits
	j    dDisplay			# go to dDisplay
dChar:
	addi $s0, $a0, -65		# Subtract the character by 65 to get 0 - 25
	lui  $s1, 0x1001		# Replace la $s1, letters
dDisplay:
	sll  $s0, $s0, 3		# Multiply the value 0 - x by 8
	add  $s1, $s1, $s0		# $s1 is the address associated with the character
	lw   $s0, 0($s1)		# Load the first word of the address
	sll  $a0, $s0, 24		#
	srl  $a0, $a0, 24		# $a0 = 0x000000[b7]...[b0]
	jal  _shiftColumnsLeft		# Call _shiftColumnsLeft
	sll  $a0, $s0, 16		#
	srl  $a0, $a0, 24		# $a0 = 0x000000[b15]...[b8]
	jal  _shiftColumnsLeft		# Call _shiftColumnsLeft
	sll  $a0, $s0, 8		#
	srl  $a0, $a0, 24		# $a0 = 0x000000[b23]...[b16]
	jal  _shiftColumnsLeft		# Call _shiftColumnsLeft
	srl  $a0, $s0, 24		# $a0 = 0x000000[b31]...[b24]
	jal  _shiftColumnsLeft		# Call _shiftColumnsLeft
	lw   $s0, 4($s1)		# Load the second word of the address
	sll  $a0, $s0, 24		# 
	srl  $a0, $a0, 24		# $a0 = 0x000000[b7]...[b0]
	jal  _shiftColumnsLeft		# Call _shiftColumnsLeft
	add  $a0, $zero, $zero		# $a0 = 0
	jal  _shiftColumnsLeft		# Call _shiftColumnsLeft
dDone:
	lw   $s1, 8($sp)		# Restore $s1
	lw   $s0, 4($sp)		# Restore $s0
	lw   $ra, 0($sp)		# Restore $ra
	addi $sp, $sp, 12		# Deallocate the activation frame
	jr   $ra			# Go back to caller

# _shiftColumnsLeft
#
# This function shift all columns of the LED display
# to the left and insert a new data from $a0 to the
# right most column.
#
# Arguments:
#   - $a0: 8-bit data for the right most column
# Return Value:
#   - None
_shiftColumnsLeft:
	add  $t0, $zero, $a0		# $t0 new byte to be insert
	lui  $t1, 0xffff		# $t1 = 0xffff0000
	ori  $t1, $t1, 0x8000		# $t1 = 0xffff8000 (address of the display)
	addi $t2, $zero, 7		# $t2 = 7 (counter)
sclLoop:
	beq  $t2, $zero, sclDone	# If $t2 = 0, done
	sll  $t3, $t2, 2		# $t3 = $t2 * 4 (number of bytes)
	add  $t3, $t1, $t3		# $t3 is the address of the left word
	lw   $t4, 0($t3)		# $t4 is the data of the left word
	lw   $t5, -4($t3)		# $t5 is the data of the right word
	sll  $t4, $t4, 8		# Shift left left word by 8
	srl  $t5, $t5, 24		# Shift right right word by 24 (only need top 8 bit)
	or   $t4, $t4, $t5		# Merge top 8-bit of right word to botoom 8 bit of left word
	sw   $t4, 0($t3)		# Store new data back
	addi $t2, $t2, -1		# Decrease counter by 1
	j    sclLoop			# Go back to sclLoop
sclDone:
	lw   $t2, 0($t1)		# Load the last word
	sll  $t2, $t2, 8		# Shift the last word left by 8
	or   $t2, $t2, $t0		# Add new data
	sw   $t2, 0($t1)		# Store the last word back
	jr   $ra			# Go back to caller
	
	
