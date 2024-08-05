-

.MODEL SMALL
.STACK 64

.DATA                        ;DATA SEGMENT
    		
        COLOR DB  07         ;07 = HIGH INTENSIITY WHITE
 
        POSX DB 00
        POSY DB 00
        
        G_POSX DW ?
        G_POSY DW ?
    
        CLICK DB ?

;-------------------------------------------------

.CODE

MAIN PROC   FAR

            MOV AX,@DATA
            MOV DS,AX
            MOV AL,03        ;TEXT MODE 80*25 & 16 COLORS
            MOV AH,00
            INT 10H  
    
;--------------SHOW COLOR PALET-----------------
                               
            MOV DL,56
            MOV DH,00
            MOV BH,00         ;PAGE NUMBER
            MOV AH,02 
            int 10H           ;SET CURSOR POSITION
    
            MOV AH,09
            MOV AL,00
            MOV BH,00
            MOV BL,01110000B
            MOV CX,07
    
    BACK:
            PUSH CX
            MOV CX,08         ;LENGTH OF COLORS IN THE PALET
            INT 10H
        
            SUB BL,00010000B
     
            POP CX  
            PUSH AX
            PUSH BX
        
            MOV AX,CX 
            MOV BL,08
            MUL BL
            POP BX
        
            SUB AL,08
            MOV DL,AL
            MOV DH,00
            MOV BH,00
            MOV AH,02
            INT 10H            ;SET SURSOR POSITION
            
            POP AX 
            LOOP BACK
            
        
;-----------------INSTALL MOUSE------------------

            MOV AX,00
            INT 33H


;----------------CHECK FOR CLICK-----------------
   
    CLICK_CHECK:
    
            MOV AX,03
            INT 33H
            
            MOV CLICK,BL
            MOV G_POSX,CX
            MOV G_POSY,DX
            
            CALL CONVERT             ;CALCULATE POSITION
                  
            CMP CLICK,00            ;IS CLICKED
            JNE CLICKED             ;NOTHING IS CLICKED
            
            JMP CLICK_CHECK     
 
   
    CLICKED:                        ;WHEN SOMETHING IS CLICKED
                         
            CMP CLICK,00000010B     ;CHECK IF IT IS RIGHT CLICK
            JNE SELECT
            
            JMP CLICK_CHECK    
                              
                               
    SELECT:                      ;SELECT CLOLR OR READ CHARACTER 
    
            CMP POSY,00
            JE COLOR_SELECT
            
            CALL READ
            
            JMP CLICK_CHECK


    COLOR_SELECT:
    
            MOV AH,08               ;READ CHARECTAR FROM CURSOR POSITION
            INT 10H 
            
            MOV CL,04
            SHR AH,CL 
            MOV COLOR,AH            ;AH HOLD COLOR 
            JMP CLICK_CHECK
    
    
    CONVERT PROC                    ;CHANGE GRAPHIC POSITION TO CHARACTER POSITION
    
            MOV AX,G_POSX
            MOV BL,08
            DIV BL
            MOV POSX,AL
            MOV AX,G_POSY
            DIV BL
            MOV POSY,AL
            MOV DL,POSX
            MOV DH,POSY
            MOV BH,00
            MOV AH,02
            INT 10H 
               
            RET
            
    CONVERT ENDP


    READ    PROC                    ;READ CHARACTER FORM KEYBOARD
    
            MOV AH,00
            INT 16H
            
            CMP AL,13
            JZ BREAK
            
            CMP AL,08
            JZ DETELE
            
            MOV AH,09
            MOV BH,00
            MOV CX,01
            MOV BL,COLOR
            INT 10H
            
            MOV AH,02
            MOV BH,00
            ADD DL,01
            INT 10H
            
            JMP READ
            
    DETELE:
    
            MOV AH,02
            MOV BH,00
            SUB DL,01
            INT 10H
            
            MOV AH,09
            MOV BH,00
            MOV CX,01
            MOV BL,00
            INT 10H
            
            JMP READ
  
    BREAK:
            RET
            
    READ    ENDP

    MAIN    ENDP


        END MAIN    


