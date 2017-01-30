.text
	# ori, nor, sw, sh, sb
	ori  $s0, $zero, 0x7fff		# $s0 = 0x00007fff
	nor  $s0, $s0, $zero		# $s0 = 0xffff8000
	nor  $s1, $zero, $zero		# $s1 = 0xffffffff
	sw   $s1, 0($s0)		# Compare results
	sh   $s1, 4($s0)		# Compare results
	sb   $s1, 6($s0)		# Compare results
	# and, andi
	ori  $s2, $zero, 0x7f		# $s2 = 0x0000007f
	and  $s2, $s1, $s2		# $s2 = 0x0000007f
	sb   $s2, 7($s0)		# Compare results
	andi $s2, $s2, 0x3f		# $s2 = 0x0000003f
	sb   $s2, 8($s0)		# Compare results
	# or
	ori  $s3, $zero, 0x1f		# $s3 = 0x0000001f
	or   $s4, $s0, $s3		# $s4 = 0xffff801f
	sb   $s4, 9($s0)		# Compare results
	# add, addi
	addi $s4, $zero, 15		# $s4 = 0x0000000f
	sb   $s4, 10($s0)		# Compare results
	addi $s4, $s4, -11		# $s4 = 0x00000004
	addi $s5, $zero, 3		# $s5 = 0x00000003
	add  $s5, $s5, $s4		# $s5 = 0x00000007
	sb   $s5, 11($s0)		# Compare results
	# sub
	sub  $s5, $s5, $s4		# $s5 = 0x00000003
	sw   $s5, 12($s0)		# Compare results
	# slt, slti
	slt  $s5, $s5, $s4		# $s5 = 0x00000001
	sb   $s5, 13($s0)		# Compare results
	slti $s5, $s5, 0		# $s5 = 0x00000000
	sb   $s5, 14($s0)		# Compare results
	# sll, sllv
	addi $s5, $zero, 1		# $s5 = 0x00000001
	sll  $s6, $s5, 1		# $s6 = 0x00000002
	sb   $s6, 15($s0)		# Compare results
	sllv $s7, $s6, $s5		# $s7 = 0x00000004
	sb   $s7, 16($s0)		# Compare results
	# srl, srlv
	srl  $s7, $s1, 28		# $s7 = 0x0000000f
	sb   $s7, 17($s0)		# Compare results
	srlv $s5, $s2, $s5		# $s5 = 0x0000001f
	sb   $s5, 18($s0)		# Compare results
	# lbu
	lbu  $s5, 8($s0)		# $s5 = 0x0000003f
	sb   $s5, 19($s0)		# Compare results
	# lhu
	lhu  $s6, 6($s0)		# $s6 = 0x00007fff
	ori  $s6, $s6, 0x8000		# $s6 = 0x0000ffff
	addi $s6, $s6, -128		# $s6 = 0x0000ff7f
	sh   $s6, 20($s0)		# Compare results
	# j
	j    jump
	addi $s6, $zero, 0x80		# Your program should not be here (check j instruction)
	sb   $s6, 31($s0)		# Your program should not be here (check j instruction)
jump:
	addi $s6, $zero, 0x7f		# $s6 = 0x0000007f
	sb   $s6, 22($s0)		# Compare results
	# beq
	beq  $s2, $s5, beqEqual
	addi $s6, $zero, 0x40		# $s2 and $s5 are equal. Your program should not be here
	sb   $s6, 31($s0)		# Your program should not be here (check beq instruction)
beqEqual:
	addi $s6, $zero, 0x3f		# $s6 = 0x0000003f
	sb   $s6, 23($s0)		# Compare result
	beq  $s2, $s3, beqNotEqual
	addi $s6, $zero, 0x1f		# $s6 = 0x0000001f
	sb   $s6, 24($s0)		# Compare result
	j    beqDone
beqNotEqual:
	addi $s6, $zero, 0x20		# $s2 and $s3 are not equal. Your program should not be here
	sb   $s6, 31($s0)		# Your program should not be here (check beq instruction)
beqDone:
	# bne
	bne  $s2, $s3, bneNotEqual
	addi $s6, $zero, 0x10		# $s2 and $s3 are not equal. Your program should not be here
	sb   $s6, 31($s0)		# Your program should not be here (check bne instruction)
bneNotEqual:
	addi $s6, $zero, 0x0f		# $s6 = 0x0000000f
	sb   $s6, 25($s0)		# Compare result
	bne  $s2, $s5, bneEqual
	addi $s6, $zero, 0x7		# $s6 = 0x00000007
	sb   $s6, 26($s0)		# Compare result
	j    bneDone
bneEqual:	
	addi $s6, $zero, 0x8		# $s2 and $s5 are equal. Your program should not be here
	sb   $s6, 31($s0)		# Your program should not be here (check bne instruction)
bneDone:
	jal  foo			# Jump to function foo
	addi $s6, $zero, 1		# $s6 = 0x00000001
	sb   $s6, 28($s0)		# Compare result
	# lui
	lui  $s6, 0xff81		# $s6 = 0xff810000
	ori  $s6, $s6, 0xff01		# $s6 = 0xff81ff01
	sw   $s6, 28($s0)		# Compare result
done:	j    done
	
	
# Function	
foo:
	addi $s6, $zero, 3		# $s6 = 0x00000003
	sb   $s6, 27($s0)		# Compare result
	jr   $ra
sink:	j    sink			# Your program should not be here (check jal and jr)