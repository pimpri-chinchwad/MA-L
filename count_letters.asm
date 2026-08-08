section .data
msg1 db "Enter digit (0-9)"
len1 equ $-msg1


section .bss
digit resb 2

%macro Display 2
	mov rax, 1
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

%macro Accept 2
	mov rax, 0
	mov rdi, 0
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
	Display msg1, len1
	Accept digit, 2
	
	mov al, [digit]
	sub al, 1h
	mov [digit], al
	
	Display digit, 1
	Exit
	
	
