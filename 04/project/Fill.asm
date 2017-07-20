// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.


	// Initialize variables
	@i
	M=0
	@8192	// 8k of screen memory
	D=A
	@screen_pixel_bytes	// store 8192 to variable
	M=D

// loop waiting for keyboard input
(KEYBOARDLOOP)
	@i 	//clear counter
	M=0
	
	@24576	// keyboard register memory location
	D=M
	@DARKLOOP
	D,JGT	// jump to dark loop if keyboard register is greater than 0 (key press)

	@24576	// keyboard register memory location
	D=M
	@WHITELOOP
	D,JEQ	// jump to white loop if keyboard register is 0 (no key press)

	@KEYBOARDLOOP
	0,JMP

(DARKLOOP)
	@i
	D=M
	@screen_pixel_bytes
	D=D-M
	@KEYBOARDLOOP
	D,JEQ

	@i
	D=M
	@SCREEN 	// screen memory location
	A=A+D
	M=-1	// set 1 byte (16 row pixels) to 0xFF (black)

	@i
	M=M+1
	@DARKLOOP
	0,JMP

(WHITELOOP)
	@i
	D=M
	@screen_pixel_bytes
	D=D-M
	@KEYBOARDLOOP
	D,JEQ

	@i
	D=M
	@SCREEN 	// screen memory location
	A=A+D
	M=0	// set 1 byte (16 row pixels) to 0x00 (white)

	@i
	M=M+1
	@WHITELOOP
	0,JMP