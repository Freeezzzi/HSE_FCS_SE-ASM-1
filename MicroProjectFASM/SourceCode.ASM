format PE console
entry start
;������� 19
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
; 3) ������� �� ����� �������� ����
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
	mov [tmp], ebx	     ;��������� ��������� �� ������� �������
	cmp ecx, [vec_size]
	jge endInputVector	 ; to end of loop

	;������� ��������� � �����
	mov [i], ecx
	push ecx
	push strVecElemI
	call [printf]
	add esp, 8

	;����������� ����
	push ebx
	push strScanInt
	call [scanf]
	add esp, 8

	;����������� ������� ��������� � ��������������� ������ �� ������� �������
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
	mov ebx, vec;���� � ebx ����� ������� �������� A
	xor eax,eax; ������� �������
	xor si, si;posSum
	xor cx,cx; negSum

countLoop:
	cmp eax, [vec_size]
	jge endVectorCount
	cmp [ebx] , word 0 ;������ ������������� �� ��� �������
	js negElement ;���� �������������
	cmp [ebx],word 0 ;������ ���� �� ���
	je zero;���� ����
	add si,[ebx];���� ������� �������������
	add ebx,2; ������� � ���������� ��������, �.�. ������ �������� ����� 2 ������(�������� �����)
	inc eax
	jmp countLoop
negElement:   ;���������� � ����� �����. ���������
	sub cx,[ebx]
	add ebx,2; ������� � ���������� ��������, �.�. ������ �������� ����� 2 ������(�������� �����)
	inc eax
	jmp countLoop
zero:	;���������� �������
	add ebx,2; ������� � ���������� ��������, �.�. ������ �������� ����� 2 ������(�������� �����)
	inc eax
	jmp countLoop
endVectorCount:
	mov [negSum], cx ;������� � ������ ������ �������� �����
	mov [posSum], si ;������� � ������ ������ �������� �����
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