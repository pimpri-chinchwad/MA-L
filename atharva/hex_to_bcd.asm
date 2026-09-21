section .data

hmsg db 10, "Enter 4 digit Hex Number::"
hmsg_len equ $-hmsg

ebmsg db 10, "The equivalent BCD number is::"
ebmsg_len equ $-ebmsg

ermsg db 10, "INVALID NUMBER INPUT",10
ermsg_len equ $-ermsg

section .bss
buf resb 5
char_ans resb 1

%macro Print 2
	mov rax,1
	mov rdi,1
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

%macro Read 2
	mov rax,0
	mov rdi,0
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

%macro Exit 0
	mov rax, 60
	mov rdi,0
	syscall
%endmacro

section .text
global _start

_start:
	call HEX_BCD
	Exit
	
HEX_BCD:
	Print hmsg,hmsg_len
	call Accept_16 		;calling procedure to accept hex number
						;
	mov ax,bx			;mov accepted number to ax
	
	mov bx,10			;bx=10
	xor bp,bp			;clear bp

back:
	xor dx,dx			;clear dx
	div bx   			;divide ax by bx   &  quotient->ax remainder->dx
	push dx 			;push remaindex(dx) on stack
	inc bp
	
	cmp ax,0
	jne back			;while ax!=0 -> back

back1:
	pop dx				;pop last digit stored on stack
	add dl, 30h			;add 30 to digit to make them decimal ???????????????
	mov [char_ans], dl	
	Print char_ans,1
	
	dec bp
	jnz back1		;while bp!=0 -> back1
	
ret 

Accept_16:
	Read buf, 5
	
	mov rcx,4			;rcx=4
	mov rsi,buf			;rsi=buf (pointing to digits of number)
	xor bx,bx			;clear bx
	
next_byte:	
	shl bx,4			;shift left by 4 bytes, because you want to convert 1234 to 0001 0010 0011 0100
						;one by one digits will be getting shifted 
						
	mov al, [rsi]		;move current char into ax
	
	cmp al,'0'			;if below 0-> error message
	jb error
	cmp al,'9'			;if between 0 to 9-> subtract 30
	jbe sub30
	
	cmp al, 'A'			;if between A to F->sub 37
	jb error
	cmp al,'f'
	jbe sub37
	
	cmp al,'a'
	jb error
	cmp al,'f'
	jbe sub57

error:
	Print ermsg,ermsg_len
	Exit

sub57: sub al,20h		;NOTE: total 57, because they will be executed in sequence
sub37: sub al,07h
sub30: sub al,30h

	add bx,ax
	;bx=0000 0000 0000 0000
	;ax=0000 0000 0000 0001
	;(add)
	;bx=0000 0000 0000 0001
	
	;clear ax and shift by 4bytes
	;ax=0000 0000 0000 0010
	
	
	inc rsi
	dec rcx
	jnz next_byte

ret
	
			
	


