section .data
    ; Matrix A (3x3)
    matrixA: dq 1,2,3
             dq 1,1,1
             dq 1,0,1

    ; Matrix B (3x3)
    matrixB: dq 0,1,1
             dq 1,2,3
             dq 0,1,0

    space_str:  db " ", 0
    newline_str: db 10, 0        ; ASCII 10 = newline '\n'

section .bss
    ; Result Matrix C (3x3)
    matrixC: resq 9
    buffer:  resb 32            ; Buffer for integer-to-ASCII conversion

section .text
    global _start

_start:
    ; =========================================================
    ; 1. MATRIX MULTIPLICATION
    ; =========================================================
    xor r8, r8                  ; r8 = j (outer loop index: 0 to 2)

outer_loop_j:
    cmp r8, 3
    jge print_matrix_start      ; Go to print routine when j == 3

    xor r9, r9                  ; r9 = i (middle loop index: 0 to 2)

middle_loop_i:
    cmp r9, 3
    jge next_j                  ; Go to next j when i == 3

    xor r10, r10                ; r10 = k (inner loop index: 0 to 2)
    xor r11, r11                ; r11 = accumulator for C[i][j]

inner_loop_k:
    cmp r10, 3
    jge save_element            ; Save C[i][j] when k == 3

    ; 1. Load A[j][k]
    mov rax, r8
    imul rax, 3
    add rax, r10
    mov rbx, [matrixA + rax * 8] ;matrix A+these many bits

    ; 2. Load B[k][i]
    mov rcx, r10
    imul rcx, 3
    add rcx, r9
    mov rdx, [matrixB + rcx * 8]

    ; 3. c[i][j] += A[j][k] * B[k][i]
    imul rbx, rdx
    add r11, rbx

    inc r10                     ; k++
    jmp inner_loop_k

save_element:
    mov rax, r8                ; rax = i
    imul rax, 3                 ; rax = i * 3
    add rax, r9                 ; rax = i * 3 + j
    mov [matrixC + rax * 8], r11 ; C[i][j] = r11

    inc r9                      ; i++
    jmp middle_loop_i

next_j:
    inc r8                      ; j++
    jmp outer_loop_j

; =========================================================
; 2. PRINT MATRIX C TO STDOUT
; =========================================================
print_matrix_start:
    xor r8, r8                  ; r8 = row index (0 to 2)

print_row_loop:
    cmp r8, 3
    jge done

    xor r9, r9                  ; r9 = col index (0 to 2)

print_col_loop:
    cmp r9, 3
    jge print_newline

    ; Compute index = r8 * 3 + r9
    mov rax, r8
    imul rax, 3
    add rax, r9

    ; Get number from matrixC
    mov rdi, [matrixC + rax * 8]
    call print_number           ; Print integer in rdi

    ; Print space separator
    mov rsi, space_str
    mov rdx, 1
    call print_string

    inc r9
    jmp print_col_loop

print_newline:
    mov rsi, newline_str
    mov rdx, 1
    call print_string

    inc r8
    jmp print_row_loop

done:
    ; Exit System Call
    mov rax, 60                 ; sys_exit
    xor rdi, rdi                ; return status 0
    syscall

; =========================================================
; HELPER ROUTINES
; =========================================================

; Converts non-negative integer in RDI to ASCII and prints it
print_number:
    mov rax, rdi
    mov rcx, buffer + 30        ; Start filling buffer from the back
    mov byte [rcx], 0           ; Null terminator
    mov rbx, 10                 ; Base 10 divisor

.convert_loop:
    xor rdx, rdx
    div rbx                     ; rax = quotient, rdx = remainder
    add dl, '0'                 ; Convert remainder digit to ASCII
    dec rcx                     ; Move back 1 byte
    mov [rcx], dl               ; Store character
    test rax, rax
    jnz .convert_loop

    ; Calculate length
    mov rdx, buffer + 30
    sub rdx, rcx                ; rdx = string length

    ; Print string via sys_write
    mov rsi, rcx                ; pointer to converted string
    call print_string
    ret

; Writes string pointed to by RSI with length RDX to stdout
print_string:
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    syscall
    ret

