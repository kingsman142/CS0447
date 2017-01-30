.data
	letters:	.word	0x8888887e, 0x92fe007e, 0x006c9292, 0x8282827c, 0x82fe0044, 0x007c8282, 0x929292fe, 0x90fe0082, 0x00809090, 0x8a8a827c, 0x10fe004c, 0x00fe1010,
				0x0082fe82, 0x0202020c, 0x10fe00fc, 0x00824428, 0x020202fe, 0x40fe0002, 0x00fe4020, 0x081020fe, 0x827c00fe, 0x007c8282, 0x888888fe, 0x827c0070,
				0x007e868a, 0x888888fe, 0x92640076, 0x004c9292, 0x80fe8080, 0x02fc0080, 0x00fc0202, 0x040204f8, 0x04fe00f8, 0x00fe0408, 0x281028c6, 0x10e000c6,
				0x00e0100e, 0xa2928a86, 0x82fe00c2, 0x00fe8282, 0x9e00fe40, 0xf2929292, 0x92929200, 0xf000fe92, 0xfe101010, 0x9292f200, 0xfe009e92, 0x9e929292,
				0x8e808000, 0xfe00e090, 0xfe929292, 0x9292f200, 0x0000fe92
	numData:	.word	212
.text
	add  $s0, $zero, $zero	# $s0 = 0 (counter)
	#la   $s1, numData
	lui  $s1, 0x1001	# Replacing la $s1, numData
	ori  $s1, $s1, 0xd4	# Replacing la $s1, numData
	lw   $s1, 0($s1)	# $s1 = 212
	#la   $s2, letters
	lui  $s2, 0x1001	# Replacing la $s2, letters
loop:
	beq  $s0, $s1, done	# If $s0 == $s1 go to done
	add  $s3, $s0, $s2	# $s3 is the byte address to be loaded
	lbu  $a0, 0($s3)	# Load a byte from letters
	jal  _shiftColumnsLeft	# Call the function _shiftColumnsLeft
	addi $s0, $s0, 1	# Increase the counter by 1
	j    loop		# Go back to loop
done:
	j    done		# Infinite loop

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
	
	
