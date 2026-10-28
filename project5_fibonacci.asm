; Project 5 - Recursive Fibonacci (LC-3)
; Input: one digit n (0-9)
; Output: F(n) as a decimal number
; R0 = function input / return value
; R5 = frame pointer, R6 = stack pointer, R7 = return address

.ORIG x3000

MAIN
    ; Set up stack
    LD R6, STACK_START     ; Stack starts at x4000
    AND R5, R5, #0         ; No previous stack frame

    ; Read a single digit
    LEA R0, PROMPT         ; Load prompt address
    PUTS                   ; Print prompt
    GETC                   ; Read character into R0
    OUT                    ; Echo typed character
    LD R1, NEG_ASCII_ZERO  ; Load -48
    ADD R0, R0, R1         ; Convert ASCII digit to number
    ST R0, INPUT_N         ; Save original input

    ; Calculate Fibonacci
    JSR FIBONACCI          ; Call recursive function
    ST R0, FIB_RESULT      ; Save returned result

    ; Print F(n) =
    LD R0, NEWLINE         ; Load newline character
    OUT                    ; Move to next line
    LEA R0, PREFIX         ; Print "F("
    PUTS
    LD R0, INPUT_N         ; Load original n
    LD R1, ASCII_ZERO      ; Load 48
    ADD R0, R0, R1         ; Convert n to ASCII
    OUT                    ; Print n
    LEA R0, MIDDLE         ; Print ") = "
    PUTS

    ; Split result into tens and ones
    LD R0, FIB_RESULT      ; R0 = remaining number
    AND R1, R1, #0         ; R1 = tens counter
    ADD R3, R1, #-10       ; R3 = -10

DIV_LOOP
    ADD R2, R0, R3         ; Try subtracting 10
    BRn DIV_DONE           ; Stop if result would be negative
    ADD R0, R2, #0         ; Keep the subtraction
    ADD R1, R1, #1         ; Count one ten
    BRnzp DIV_LOOP         ; Repeat

DIV_DONE
    ST R0, ONES_DIGIT      ; Save remaining ones digit
    ADD R1, R1, #0         ; Set flags from tens counter
    BRz PRINT_ONES         ; Skip tens if zero
    ADD R0, R1, #0         ; Move tens digit into R0
    LD R2, ASCII_ZERO      ; Load ASCII '0'
    ADD R0, R0, R2         ; Convert tens to ASCII
    OUT                    ; Print tens digit

PRINT_ONES
    LD R0, ONES_DIGIT      ; Load ones digit
    LD R2, ASCII_ZERO      ; Load ASCII '0'
    ADD R0, R0, R2         ; Convert ones to ASCII
    OUT                    ; Print ones digit
    HALT                   ; End program

; Recursive Fibonacci: input R0 = n, output R0 = F(n)
FIBONACCI
    ; Prologue: create a four-word stack frame
    ADD R6, R6, #-1        ; Make space for input
    STR R0, R6, #0         ; Save original n
    ADD R6, R6, #-1        ; Make space for return address
    STR R7, R6, #0         ; Save R7
    ADD R6, R6, #-1        ; Make space for old frame pointer
    STR R5, R6, #0         ; Save old R5
    ADD R5, R6, #0         ; Set current frame pointer
    ADD R6, R6, #-1        ; Reserve first-result slot

    ; Base cases: F(0) = 0 and F(1) = 1
    ADD R1, R0, #-1        ; Compare n with 1
    BRnz FIB_DONE          ; Return n if n <= 1

    ; First recursive call: F(n-1)
    ADD R0, R0, #-1        ; Argument = n - 1
    JSR FIBONACCI          ; Calculate F(n-1)
    STR R0, R5, #-1        ; Save first result in this frame

    ; Second recursive call: F(n-2)
    LDR R0, R5, #2         ; Reload original n
    ADD R0, R0, #-2        ; Argument = n - 2
    JSR FIBONACCI          ; Calculate F(n-2)

    ; Add both results
    LDR R1, R5, #-1        ; Reload first result
    ADD R0, R0, R1         ; R0 = F(n-2) + F(n-1)

FIB_DONE
    ; Epilogue: remove frame and return
    ADD R6, R5, #0         ; Discard local result slot
    LDR R5, R6, #0         ; Restore caller's R5
    ADD R6, R6, #1         ; Pop saved frame pointer
    LDR R7, R6, #0         ; Restore caller's return address
    ADD R6, R6, #1         ; Pop saved return address
    ADD R6, R6, #1         ; Pop saved input n
    RET                    ; Return with result in R0

; Constants and storage
STACK_START     .FILL x4000
NEG_ASCII_ZERO  .FILL #-48
ASCII_ZERO      .FILL #48
NEWLINE .FILL x000A     ; ASCII line feed
PROMPT          .STRINGZ "Please enter a number n: "
PREFIX          .STRINGZ "F("
MIDDLE          .STRINGZ ") = "
INPUT_N         .BLKW 1
FIB_RESULT      .BLKW 1
ONES_DIGIT      .BLKW 1

.END
