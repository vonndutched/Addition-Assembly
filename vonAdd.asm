.model small
.stack 512

.data
buffData db 0
numPress db 0
isAdd1 db 0
numCtr dw 0
addStr1 db 3 dup (32), '$'
addStr2 db 3 dup (32), '$'
addArr1 db 3 dup (0), '$'
addArr2 db 3 dup (0), '$'
addend1 dw 0
addend2 dw 0
sum dw 0
sumStr db 4 dup (32), '$'
sumLine db "-----", '$'

sampleStr db "Hello World!", '$'
.386
.code

newline macro
	mov ah, 02h
	mov dl, 0ah
	int 21h	
	mov dl, 0dh
	int 21h			;displays newline\
endm

displayString macro OFFstr
	mov ah, 09h
	lea dx, OFFstr
	int 21h
endm

displayChar macro OFFchar	
	mov ah, 02h
	mov dl, OFFchar
	int 21h
endm

movCursor macro xPos, yPos
	mov ax, 0
	mov ah, 02h
	mov bh, 0
	mov dh, yPos
	mov dl, xPos
	int 10h
endm

checkPinKey proc
	pusha
		mov ah, 11h
		int 16h
		JNZ _pinKey
		JMP _noPinKey
		
		_pinKey:
			mov ah, 10h
			int 16h
			CMP al, 27
			JE _endPin
			CMP al, '0'
			JB _noPinKey
			CMP al, '9'
			JBE _numPin
			JMP _noPinKey
			
		_numPin:
			mov buffData, al
			sub al, 48
			mov numPress, al
			call numInput
			JMP _noPinKey
			
		_endPin:
			call endProgram
			JMP _noPinKey
		
		_noPinKey:
			xor ax, ax
			popa	
			ret
checkPinKey endp

;====================================================================

numInput proc
	pusha
	
	cld
	mov ax, numCtr
	CMP ax, 3
	JB _add1
	CMP ax, 6
	JB _add2
	JMP _endNumInput
	
	_add1:
		lea di, addStr1
		add di, numCtr
		mov al, buffData
		STOSB
		
		lea di, addArr1
		add di, numCtr
		mov al, numPress
		STOSB
		
		inc numCtr	
		
		movCursor 4, 2
		displayString addStr1
		mov bx, 4
		add bx, numCtr
		movCursor bl, 2
		
		mov ax, numCtr
		CMP ax, 3
		JNE _endNumInput
		movCursor 2, 3
		displayChar "+"
		movCursor 4, 3
		JMP _endNumInput
		
	_add2:
		lea di, addStr2
		add di, numCtr
		sub di, 3
		mov al, buffData
		STOSB
		
		lea di, addArr2
		add di, numCtr
		sub di, 3
		mov al, numPress
		STOSB
		
		inc numCtr	
		
		movCursor 4, 3
		displayString addStr2
		mov bx, 4
		add bx, numCtr
		sub bx, 3
		movCursor bl, 3
		
		mov ax, numCtr
		CMP ax, 6
		JNE _endNumInput
		
		movCursor 2, 4
		displayString sumLine
		
		popa
		call addNum
		call toStr
		call endProgram
	
	_endNumInput:
	popa
	ret
numInput endp

;====================================================================

addNum proc
	pusha
	std
	lea si, addArr1
	add si, 2
	mov bx, 1
	mov cx, 3
	
	_addLoop1:
		LODSB
		mov ah, 0
		mul bl
		add ax, addend1
		mov addend1, ax
		
		mov ax, 0
		mov al, 10
		mul bl
		mov bx, ax
		loop _addLoop1
	
	std
	lea si, addArr2
	add si, 2
	mov bx, 1
	mov cx, 3
	
	_addLoop2:
		LODSB
		mov ah, 0
		mul bl
		add ax, addend2
		mov addend2, ax
		
		mov ax, 0
		mov al, 10
		mul bl
		mov bx, ax
		loop _addLoop2
		
	mov ax, addend1
	mov bx, addend2
	add ax, bx
	mov sum, ax
	
	popa
	ret
addNum endp

;====================================================================

toStr proc
	pusha
	
	std
	lea di, sumStr
	add di, 3
	mov cx, 4

	_toStrLoop1:
		mov ax, sum
		mov bl, 10
		div bl
		push ax
		mov ah, 0
		mov sum, ax
		pop ax
		
		CMP ax, 0
		JE _blankNum
		
		add ah, 48
		mov al, ah
		STOSB
		JMP _endStrLoop1
		
	_blankNum:
		mov al, 32
		STOSB
		
	_endStrLoop1:
		loop _toStrLoop1
		
	movCursor 3, 5
	displayString sumStr
		
	popa
	ret
toStr endp

;====================================================================

begin proc far
	mov ax, @data
	mov ds, ax
	mov es, ax
	
	mov ah, 0
    mov al, 2
  	int 10h
	
	movCursor 4, 2
	
	loopMain1:
		call checkPinKey
		JE loopMain1
		
begin endp

;====================================================================

endProgram proc
	pusha
	movCursor 0, 7

	mov ax, 4c00h
	int 21h
	
	popa
	ret
endProgram endp

end begin