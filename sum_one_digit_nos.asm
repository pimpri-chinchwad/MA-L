section .bss
digit1 resb 2
digit2 resb 2
digit3 resb 2
char_ans resb 2

%macro acceptNum 2
	mov rax, 0
	mov rdi, 0
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

%macro displayNum 2
	mov rax, 1
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro
	
%macro Exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro

section .text
global _start
_start:
	acceptNum digit1, 2
	acceptNum digit2, 2
	
	;------------------------convert ASCII_char to number
	mov al, [digit1]
	sub al, 30h
	mov [digit1], al
	
	mov al, [digit2]
	sub al, 30h
	mov [digit2], al
	
	
	;-------------------------------add digit1 and digit2
	mov al, [digit1]
	mov bl, [digit2]
	
	add al, bl
	mov [digit3], al
	
	
	movzx rax, byte [digit3]
	
	call display_haha
	Exit
	
	display_haha:
           mov rbx,10
           mov rcx,2
           mov rsi,char_ans+1
           
	cnt:
		  mov rdx,0
		  div rbx
		 cmp dl,09h
		 jbe add30
		 add dl,07h
		 
	add30:
		  add dl,30h
		  mov[rsi],dl
		  dec rsi
		  dec rcx
		  jnz cnt
		  displayNum char_ans,2
	 ret    
	
	
	
	
	
