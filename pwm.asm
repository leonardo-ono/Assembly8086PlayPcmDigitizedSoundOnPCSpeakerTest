	bits 16
	org 100h
	
start:
	; setup es to get the system
	; timer count correctly
	mov ax, 0
	mov es, ax

	; change timer 0 to 1193180Hz
	mov bl, 1
	call change_timer_0
	
	mov si, 0 ; sound index
	
next_sample:

	mov dl, [sound_data + si]
	
	shr dl, 2 ; convert to 6-bit sound
	          ; by dividing it by 4
	
	mov cx, 0
next_amplitude:

	cmp cl, dl
	jb on
	ja off

equal:
	mov al, 219 ; white filled square char
	call print
	
on:
	call speaker_on
	mov al, ' '
	call print
	jmp short continue

off:
	call speaker_off
	mov al, ' '
	call print

continue:

	; wait 0.8381us
	call delay

	inc cx
	cmp cx, 75
	jb next_amplitude

	; exit if keypress
	mov ah, 1
	int 16h
	jnz exit
	
	inc si
	cmp si, [sound_size]
	jae restart_sound
	
	; print cr & ln
	mov al, 0dh
	call print
	mov al, 0ah
	call print
	
	jmp next_sample
	
restart_sound:
	mov si, 0
	jmp next_sample
		
exit:

	; restore timer 0 to the original 18.2Hz
	mov bl, 0
	call change_timer_0

	; return to DOS
	mov ax, 4c00h
	int 21h



; al = ascii code
print:
	mov ah, 0eh
	int 10h
	ret
	
	
speaker_on:
	in al, 61h
	or al, 2
	out 61h, al
	ret
	
speaker_off:
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret
	
; with the timer 0 set at 1193180Hz, this will
; delay for 0.8381us
; for every timer 0 tick, the irq 0 (int 8)
; will update the system timer count at 
; memory location 0000:046ch	
delay:
	mov di, [es:046ch]
_wait:
	cmp di, [es:046ch]
	jz _wait
	ret
	
; bl = 0 -> restore original 18.2Hz timer 0
;      1 -> change timer 0 to 1193180Hz
change_timer_0:
	cli
	mov al, 16h
	out 43h, al
	mov al, bl
	out 40h, al
	sti
	ret
	

sound_size dw 35480	
	
sound_data:
	; db 0, 32, 64, 128, 192, 255 ; 8-bit sound (0-255)
	incbin "rock.raw"
	
	
	
	
	
	
	










