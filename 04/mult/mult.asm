// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// loop from 0 to R1. Do R2=R2+R0 on every iteration

// initialize variables
	@i
	M=1
	@R2
	M=0	// reset R2 to 0 just in case garbage is placed into this memory location
	@result
	M=0
(LOOP)
	@i
	D=M
	@R1
	D=D-M	// i - R1
	@END
	D,JGT	// jump if i-r1 > 0
	@R2
	D=M
	@R0
	D=D+M
	@R2
	M=D
	@i
	M=M+1
	@LOOP
	0,JMP

(END)
	@END
	0,JMP