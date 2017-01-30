.text
	lui  $sp, 0x7fff
	ori  $sp, $sp, 0xeffc
	
	addi $t0, $0, 1
	addi $t1, $0, 2
	addi $t2, $0, 3
	addi $sp, $sp, -12
	sw   $t2, 8($sp)
	sw   $t1, 4($sp)
	sw   $t0, 0($sp)
	lw   $s2, 8($sp)
	lw   $s1, 4($sp)
	lw   $s0, 0($sp)
	addi $sp, $sp, 12