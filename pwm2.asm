	bits 16
	org 100h
	
start:
	mov ax, 0
	mov es, ax

	mov bl, 4ah ; 16000 Hz sampling rate
	call change_timer_0
	
	; speaker on
	in al, 61h
	or al, 3
	out 61h, al

next_sample:
	
	mov dx, [es:046ch]
delay:
	cmp dx, [es:046ch]
	jz delay

	; play 1 byte sample
	mov al, 090h
	out 43h, al
	mov si, [sound_index]
	mov al, [sound_data + si]
	shr al, 1
	out 42h, al

	; if keypress exit
	mov ah, 1
	int 16h
	jnz exit
	
	; increment index
	inc si
	cmp si, [sound_size]
	mov [sound_index], si
	jb next_sample

restart_sound:
	mov word [sound_index], 0
	jmp next_sample
	
exit:
	; speaker off
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	; restore original 18.2Hz timer
	mov bl, 0
	call change_timer_0
	
	; exit to DOS
	mov ah, 4ch
	int 21h
	
; bl = timer divider
change_timer_0:
	cli
	mov al, 16h
	out 43h, al
	mov al, bl
	out 40h, al
	sti
	ret
	
sound_index dw 0
sound_size dw 35480	
sound_data:
	incbin "rock.raw"
