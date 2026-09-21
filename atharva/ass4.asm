section .data
	nline db 10,10
	nline_len equ $-nline
	
	ano db 10," Assignment 4:",
		db 10, "-----------------------------",
		db 10, "Convert decimal to HEX",
		db 10, "-----------------------------", 10,
	ano_len equ $-ano
	
	bmsg db 10, "Enter 5 digit BCD number::"
	bmsg_len equ $- bmsg
	
	ehmsg db 10, "The equivalent Hex number is ::"
	ehmsg_len equ $-ehmsg
	
	emsg db 10, "INVALID NUMBER", 10
	emsg_len equ $-emsg

section .bss
	buf resb 6
	char_ans resb 4
	ans resw 1

;----------------------------------

%macro Print 2
	MOV RAX, 1
	MOV RDI, 1
	MOV RSI, %1
	MOV RDX, %2
	syscall
%endmacro

%macro Read 2
	MOV RAX, 0
	MOV RDI, 0
	MOV RSI, %1
	MOV RDX, %2
	syscall
%endmacro

%macro Exit 0
	Print nline, nline_len
	MOV RAX, 60
	MOV RDI, 0
	syscall
%endmacro

;-----------------------------------------------
section .text
	global _start
	
_start:
	Print ano, ano_len
	
	call BCD_HEX

BCD_HEX:
	Print bmsg, bmsg_len
	Read buf,6
	
	mov rsi, buf
	xor ax, ax
	mov rbp, 5
	mov rbx, 10

next:	
	xor cx, cx 				;clears cx
	mul bx					;ax=ax*bx
	mov cl, [rsi]			;store current digit in cl
	sub cl, 30h				;convert the digit fron ASCII to decimal
	add ax, cx				;ax=ax+cx
	
	inc rsi					;rsi++
	dec rbp					;counter?
	jnz next				;if counter not 0, got to next
	
	mov[ans], ax			;store the number in ans temporarily
	Print ehmsg, ehmsg_len	;because this changes content of ax
			
	mov ax, [ans]			;get back contents of ax in ax
	call Disp_16			;display the number in HEX
	
	ret

Disp_16:
	MOV RSI, char_ans+3		
	MOV RCX, 4				;counter
	MOV RBX, 16				;16 because 16 bit->hex

next_digit:
	XOR RDX ,RDX			
	DIV RBX					;quotient->rax     remainder->rdx
	
	CMP DL, 9				;is remainder between 0 to 9?
	jbe add30				;if yes, got to add_30 label
	add dl, 07H				;if no, add 7 and got to add_30 label
add30:
	add dl, 30h
	mov [rsi], dl			;store the Hex digit in char_ans using rsi
	
	dec rsi					;point to where next digit should be stored
	dec rcx					;dec counter
	jnz next_digit			;while counter != continue
	
	Print char_ans, 4
	
ret
	
