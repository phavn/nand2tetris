	@i
	M=0
	@10
	D=A
	@n
	M=D
(LOOP)
	@i
	D=M
	@n
	D=D-M
	@END
	D,JGT
	@i
	M=M+1
	@LOOP
	0,JMP
(END) // infinite loop
	@END
	0,JMP