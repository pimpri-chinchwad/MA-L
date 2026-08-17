section .data
    nline db 10,10
    nline_len equ $-nline
    
    ano db 10,"Assignment no 3: ",10
        db "Positive/Negative elements from 64 bit array",10
    ano_len equ $-ano
    
    arr64 dq -21H, 5FH, -33H, 0A1H, 62H
    n equ 5  ; Count of 64-bit quadword elements (5 elements)
    
    pmsg db 10,10,"The no of positive elements from 64 bit array: "
    pmsg_len equ $-pmsg
    
    nmsg db 10,10,"The no of negative elements from 64 bit array: "
    nmsg_len equ $-nmsg

section .bss
    p_count resq 1
    n_count resq 1
    char_ans resb 16

%macro print 2
  mov rax, 1
  mov rdi, 1
  mov rsi, %1
  mov rdx, %2
  syscall
%endmacro

%macro exit 0
  mov rax, 60
  mov rdi, 0
  syscall
%endmacro

section .text
  global _start

_start:
  print ano, ano_len
  mov rsi, arr64
  mov rcx, n         ; Set loop counter to 5 (not 40 bytes)
  mov rbx, 0         ; Positive counter
  mov rdx, 0         ; Negative counter

next_num:
  mov rax, [rsi]
  rol rax, 1         ; Rotate Most Significant Bit (sign bit) into Carry Flag
  jc negative

positive:
  inc rbx
  jmp next

negative:
  inc rdx

next:
  add rsi, 8         ; Advance pointer by 8 bytes (64 bits)
  dec rcx
  jnz next_num

  mov [p_count], rbx
  mov [n_count], rdx

  print pmsg, pmsg_len
  mov rax, [p_count]
  call disp64_proc

  print nmsg, nmsg_len
  mov rax, [n_count]
  call disp64_proc

  print nline, nline_len
  exit

disp64_proc:
    mov rbx, 16
    mov rcx, 2
    mov rdi, char_ans + 1 ; Use RDI to avoid corrupting RSI

cnt:
    mov rdx, 0
    div rbx          ; Divides RAX by 16; quotient in RAX, remainder in RDX
    cmp dl, 09h
    jbe add30
    add dl, 07h

add30:
    add dl, 30h
    mov [rdi], dl
    dec rdi
    dec rcx
    jnz cnt

    print char_ans, 2 ; Print converted 2-digit ASCII string
    ret
