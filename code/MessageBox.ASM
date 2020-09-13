
; Beer - example of tiny (one section) Win32 program

format PE GUI 4.0

include '%fasminc%\win32a.inc'

; no section defined - fasm will automatically create .flat section for both
; code and data, and set entry point at the beginning of this section

	invoke	MessageBox,0,_message,_caption,MB_ICONQUESTION+MB_YESNO
	cmp	eax,IDYES
	jne	exit

exit:
	invoke	ExitProcess,0

_message db 'Question text',0
_caption db 'Header text',0


; import data in the same section

data import

 library kernel32,'KERNEL32.DLL',\
	 user32,'USER32.DLL',\
	 winmm,'WINMM.DLL'

 import kernel32,\
	ExitProcess,'ExitProcess'

 import user32,\
	MessageBox,'MessageBoxA'

 import winmm,\
	mciSendString,'mciSendStringA'

end data
