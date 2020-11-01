format PE console
entry start
;вариант 19
include 'win32a.inc'
;--------------------------------------------------------------------------
section '.data' data readable writable
	strVecElemI  db '[%d]? ', 0
	strScanInt   db '%hu', 0
	strPrintPosSum db 'Sum of positive elements in array = %hu',10, 0
	strPrintNegSum db 'Sum of negative elements in array = %hu', 0

	vec_size     dd 15
	i	     dd ?
	tmp	     dd ?
	tmpStack     dd ?
	negSum	     dw ?
	posSum	     dw ?
	vec	     dw ?

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
	call VectorInput
; 2) find sum
	call VectorCount
; 3) выведем на экран значени€ сумм
	push [posSum]
	push strPrintPosSum
	call [printf]
	push [negSum]
	push strPrintNegSum
	call [printf]
finish:
	call [getch]

	push 0
	call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
	xor ecx, ecx		; ecx = 0
	mov ebx, vec		; ebx = &vec
getVecLoop:
	mov [tmp], ebx	     ;сохран€ем указатель на элемент массива
	cmp ecx, [vec_size]
	jge endInputVector	 ; to end of loop

	;выводим сообщение о вводе
	mov [i], ecx
	push ecx
	push strVecElemI
	call [printf]
	add esp, 8

	;запрашиваем ввод
	push ebx
	push strScanInt
	call [scanf]
	add esp, 8

	;увеличиваем счетчик элементов и восстанавливаем ссылку на элемент массива
	mov ecx, [i]
	inc ecx
	mov ebx, [tmp]
	add ebx, 2
	jmp getVecLoop
endInputVector:
	ret
;--------------------------------------------------------------------------
VectorCount:		       ;es,cs,ss,ds,fs
			       ;bp,si,cx
	mov ebx, vec;берЄм в ebx адрес первого элемента A
	xor eax,eax; счетчик массива
	xor si, si;posSum
	xor cx,cx; negSum

countLoop:
	cmp eax, [vec_size]
	jge endVectorCount
	cmp [ebx] , word 0 ;узнаем отрицательный ли это элемент
	js negElement ;если отрицательный
	cmp [ebx],word 0 ;узнаем ноль ли это
	je zero;если ноль
	add si,[ebx];если элемент положительный
	add ebx,2; переход к следующему элементу, т.к. размер элемента равен 2 байтам(машинное слово)
	inc eax
	jmp countLoop
negElement:   ;записываем в сумму отриц. элементов
	sub cx,[ebx]
	add ebx,2; переход к следующему элементу, т.к. размер элемента равен 2 байтам(машинное слово)
	inc eax
	jmp countLoop
zero:	;пропускаем элемент
	add ebx,2; переход к следующему элементу, т.к. размер элемента равен 2 байтам(машинное слово)
	inc eax
	jmp countLoop
endVectorCount:
	mov [negSum], cx ;запишем в €чейку пам€ти занчение суммы
	mov [posSum], si ;запишем в €чейку пам€ти значение суммы
	ret
;--------------------------------------------------------------------------
;-------------------------------third act - including HeapApi--------------------------

section '.idata' import data readable
    library kernel, 'kernel32.dll',\
	    msvcrt, 'msvcrt.dll',\
	    user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
	   ExitProcess, 'ExitProcess',\
	   HeapCreate,'HeapCreate',\
	   HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
	   printf, 'printf',\
	   scanf, 'scanf',\
	   getch, '_getch'