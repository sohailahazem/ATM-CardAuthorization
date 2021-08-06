include 'emu8086.inc'
ORG    100h
START:

    LEA    SI, cardMsg    ; ask for the card number
    CALL   print_string   
    CALL   scan_num       ; get number in CX
    MOV    DX, CX         ; copy the number to DX <for validity check> 

    PUTC 13
    PUTC 10
 
    LEA    SI, passMsg    ; ask for the password
    CALL   print_string   
    CALL   scan_num       ; get number in CX     
    MOV    BX, CX         ; copy the number to BX <for validity check> 
    
            
    LEA SI, passwords      ; loads effective address <starting address> of passwords into DS:SI
    CLD                    ; set forward direction
    MOV CX, 20             ; set counter to data size
    LEA DI, cardNumbers    ; loads effective address <starting address> of card numbers into ES:DI

;looks for the card number in the database:
    MOV AX, DX
    REPNE   SCASW 
    JZ  FOUND              ; if card number is found, check its corresponding password. else, deny access

DENIED:
      
    MOV AX, 0
    CALL   pthis
    DB  13, 10, 'DENIED. Validity = ', 0
    CALL   print_num      ; print number in AX, AX = 0 DENIED   
    CALL   pthis
    DB  13, 10, 'Make sure you entered the right credentials.', 0  
    PUTC 13
    PUTC 10 
    JMP START    

FOUND:

    MOV DX, 20      ; moves 20 in DX
    SUB DX, CX      ; DX = 20 - CX <gets the no. of card numbers scanned to reach the entered one>
    ADD SI, DX      ; SI = SI + DX <adds the index in DX to SI>
    SUB SI, 1       ; gets the password corresponding to the entered card number
    MOV DL, [SI]    
    CMP DX, BX      ; compares the entered password with the password of the entered card number
    JNE DENIED      ; if both are not equal, then deny access, else allow 



ALLOWED:
  
    MOV AX, 1  
    CALL   pthis
    DB  13, 10, 'ALLOWED. Validity = ', 0
    CALL   print_num      ; print number in AX, AX = 1 ALLOWED 
    INT 21H 
    RET                   ; return control to the operating system

; data
cardMsg   DB  'Enter the card number (0-65535): ', 0
passMsg   DB  'Enter the password (0-15): ', 0 
cardNumbers DW 1100H, 1101H, 1102H, 1103H, 1104H, 1105H, 1106H, 1107H, 1108H, 1109H, 110AH, 110BH, 110CH, 110DH, 110EH, 110FH, 1110H, 1111H, 1112H, 1113H   ;from 4352 to 4371    (random numbers from 0 to 65535 (16 bits))
;equ in decimal 4352, 4353,  4354,  4355,  4356,  4357,  4358,  4359,  4360,  4361,  4362,  4363,  4364,  4365,  4366,  4367,  4368,  4369,  4370,  4371

passwords DB 1H, 5H, 7H, 0CH, 0FH, 2H, 9H, 4H, 0DH, 3H, 0BH, 0AH, 8H, 0EH, 0H, 6H, 5H, 0FH, 7H, 0CH                          ;random numbers from 0 to 15 (4 bits)
;equivalent in decimal   12   15               13       11   10       14               15       12                                                                         

; macros to define procs
DEFINE_SCAN_NUM
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS  
DEFINE_PTHIS

END