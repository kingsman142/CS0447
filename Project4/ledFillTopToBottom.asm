.text
	addi $s0, $zero, 0	# $s0: row counter
	addi $s1, $zero, 0	# $s1: column counter
	addi $s2, $zero, 8	# $s2: number of rows
	addi $s3, $zero, 32	# $s3: number of columns
outerLoop:
	beq  $s0, $s2, outerDone
innerLoop:
	beq  $s1, $s3, innerDone	
	add  $a0, $zero, $s0	# Set row
	add  $a1, $zero, $s1	# Set column
	addi $a2, $zero, 1	# Set led to on
	jal  _drawPixel		# Draw a pixel
	addi $s1, $s1, 1	# Increase column by 1
	j    innerLoop
innerDone:
	addi $s0, $s0, 1	# Increase row by 1
	add  $s1, $zero, $zero	# Reset column to 0
	j    outerLoop
outerDone:
	j    outerDone		# Infinite loop

# _drawPixel
#
# Draw a pixel at (row, column)
#
# Arguments:
#   - $a0: row
#   - $a1: column
#   - $a2: 1 on 0 off
_drawPixel:
	add  $t0, $zero, $a0	# $t0 row
	add  $t1, $zero, $a1	# $t1 column
	add  $t2, $zero, $a2	# $t2 on/off
	lui  $t9, 0xffff	# $t9 = 0xffff0000
	ori  $t9, $t9, 0x8000	# $t9 = 0xffff8000 (address of the led display)
	addi $t3, $zero, 7	# $t3 = 7
	srl  $t4, $t1, 2	# $t4 = column / 4
	sub  $t3, $t3, $t4	# $t3 = 7 - (column / 4)
	sll  $t3, $t3, 2	# Turn $t3 to byte addressing
	add  $t9, $t9, $t3	# Get the address associated with row/column
	lw   $t3, 0($t9)	# load data from display
	addi $t4, $zero, 3	# $t4 = 3
	and  $t5, $t1, 3	# $t5 = column % 4
	sub  $t4, $t4, $t5	# $t4 = 3 - (column % 4)
	sll  $t4, $t4, 3	# $t4 = (8 * (3 - (column % 4)))
	addi $t5, $zero, 7	# $t5 = 7
	and  $t6, $t0, 7	# $t6 = row % 8
	sub  $t5, $t5, $t6	# $t5 = 7 - (row % 8)
	add  $t4, $t4, $t5	# $t4 = (8 * (3 - (column % 4))) + (7 - (row % 8))
	addi $t5, $zero, 1	# $t5 = 1
	sllv $t5, $t5, $t4	# $t5 = $t5 << $t4
	nor  $t5, $t5, $zero	# $t5 = ~$t5 (1...101...1)
	and  $t3, $t3, $t5	# Turn the specific bit to 0
	sllv $t5, $a2, $t4	# Shift new value to the rigth bit (0...010...0)
	or   $t3, $t3, $t5	# Merge the data with the new bit
	sw   $t3, 0($t9)	# Store the data back
	jr   $ra		# Go back to caller
	
	
