format PE console
entry start
;вариант 19
include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

	strVecSize   db 'size of vector? ', 0
	strIncorSize db 'Incorrect size of vector = %d', 10, 0
	strVecElemI  db '[%d]? ', 0
	strScanInt   db '%d', 0
	strArrayName  db 'Array B:', 10, 0
	strVecElemOut  db '[%d] = %d', 10, 0

	vec_size     dd 0
	i	     dd ?
	tmp	     dd ?
	tmpStack     dd ?
	vec	     rd 100
	vec2	     rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
	call VectorInput
; 2) replace elements
	call VectorReplace
	push strArrayName
	call [printf]
; 4) test vector out
	call VectorOut
finish:
	call [getch]

	push 0
	call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
	push strVecSize
	call [printf]
	add esp, 4

	push vec_size
	push strScanInt
	call [scanf]
	add esp, 8

	mov eax, [vec_size]
	cmp eax, 0
	jg  getVector
; fail size
	push vec_size
	push strIncorSize
	call [printf]
	push 0
	call [ExitProcess]
; else continue...
getVector:
	xor ecx, ecx		; ecx = 0
	mov ebx, vec		; ebx = &vec
getVecLoop:
	mov [tmp], ebx
	cmp ecx, [vec_size]
	jge endInputVector	 ; to end of loop

	; input element
	mov [i], ecx
	push ecx
	push strVecElemI
	call [printf]
	add esp, 8

	push ebx
	push strScanInt
	call [scanf]
	add esp, 8

	mov ecx, [i]
	inc ecx
	mov ebx, [tmp]
	add ebx, 4
	jmp getVecLoop
endInputVector:
	ret
;--------------------------------------------------------------------------
VectorReplace:
	mov ebx,vec;берём в ebx адрес первого элемента A
	mov edx, vec2; берем в edx адрес первого элемента в B
	xor eax,eax; содержит 0
	xor ecx,ecx
	xor edi,edi ;для копирования
replaceLoop: ; начало цикла
	cmp eax, [vec_size]
	je endVectorReplace
	cmp [ebx], ecx; ;узнаем отрицательный ли это элемент
	js copyLoop
	cmp [ebx], ecx; сравниваем элемент с нулем еще раз
	je zero; если ebx  равно 0
	mov edi, [ebx];копируем элемент
	mov [edx], edi
	add ebx, 4;  переход к следующему элементу (размер элемента = 4 байтам)
	add edx, 4
	inc eax
	cmp ecx,ecx
	je replaceLoop

zero:
	mov edi,[ebx]
	mov [edx],edi
	mov byte [edx],1; проведем замену 0 на 1
	inc eax
	add ebx, 4;  переход к следующему элементу (размер элемента = 4 байтам)
	add edx, 4
	cmp ecx,ecx
	je replaceLoop

copyLoop:
	cmp eax, [vec_size]
	je endVectorReplace
	mov edi,[ebx]
	mov [edx],edi;копируем элемент
	add ebx,4
	add edx,4
	inc eax
	cmp ecx,ecx
	je copyLoop
endVectorReplace:
	ret
;--------------------------------------------------------------------------
VectorOut:
	mov [tmpStack], esp
	xor ecx, ecx		; ecx = 0
	mov ebx, vec2		 ; ebx = &vec
putVecLoop:
	mov [tmp], ebx
	cmp ecx, [vec_size]
	je endOutputVector	; to end of loop
	mov [i], ecx

	; output element
	push dword [ebx]
	push ecx
	push strVecElemOut
	call [printf]

	mov ecx, [i]
	inc ecx
	mov ebx, [tmp]
	add ebx, 4
	jmp putVecLoop
endOutputVector:
	mov esp, [tmpStack]
	ret
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