section .data 
	nline db 10,10 
	nline_len equ $-nline 
	ano db 10," Assignment 4:", 
		db 10, "-----------------------------", 
		db 10, "Convert decimal to HEX", 
		db 10, "-----------------------------", 10, 
	ano_len equ $-ano 

	menu db 10, "1.Hex to BCD"
		 db 10, "2.BCD to Hex"
		 db 10,"3.Exit"
		 db 10,"Enter your Choice::"
	menu_len equ $-menu
	
	hmsg db 10, "Enter 4 digit Hex Number::"
	hmsg_len equ $-hmsg

	ebmsg db 10, "The equivalent BCD number is::"
	ebmsg_len equ $-ebmsg

	ermsg db 10, "INVALID NUMBER INPUT",10
	ermsg_len equ $-ermsg
	
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
	Print ano, ano_len 

MENU:
	Print menu,menu_len
	Read buf,2
	
	mov al,[buf]

c1:	cmp al,'1'
	jne c2
	call HEX_BCD
	jmp MENU

c2:	cmp al,'2'
	jne c3
	call BCD_HEX
	jmp MENU

c3:
	cmp al,'3'
	jne invalid
	Exit

invalid:
	Print emsg,emsg_len
	jmp MENU

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
	


