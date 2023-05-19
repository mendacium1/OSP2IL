[BITS 16]														; Code für 16-Bit-Mode generieren
org 0x5000														; Startoffset auf 0x5000 setzen

sect2:															; Label "sect2" (hier keine Bedeutung)

	; color-textmode - "Hallo OSP"
	mov ax, 0xB800
	mov es, ax
	mov byte [es:0], 'H'
	mov byte [es:1], 00010111b
	mov byte [es:2], 'a'
	mov byte [es:3], 00010111b
	mov byte [es:4], 'l'
	mov byte [es:5], 00010111b
	mov byte [es:6], 'l'
	mov byte [es:7], 00010111b
	mov byte [es:8], 'o'
	mov byte [es:9], 00010111b
	mov byte [es:10], '-'
	mov byte [es:11], 00010111b
	mov byte [es:12], 'O'
	mov byte [es:13], 00010111b
	mov byte [es:14], 'S'
	mov byte [es:15], 00010111b
	mov byte [es:16], 'P'
	mov byte [es:17], 00010111b

	; Ermitteln der aktuellen Cursorposition
	mov ah, 0x03			; AH auf 0x03 setzen für "Read Cursor Position and Shape"-Funktion
	mov bh, 0				; BH auf 0 für page 0
	int 0x10				; Aufrufen des INT 0x10
	; Die Reihe ist nun im DH und die Spalte im DL Register gespeichert

	; Schreiben der osp-Nachricht
	mov ax, osp2msg			; Pointer zu string in ax register speichern
	mov bp, ax				; Pointer in BP Register speichern
	xor ax, ax				; AX Register auf 0 setzen
	mov es, ax				; ES Register auch auf 0 setzen
	mov ah, 0x13			; AH auf 0x13 setzen für "Write string"-Funktion
	mov al, 1				; AL auf 1 setzen für "write mode"
	mov bl, 00000011b		; Farbe setzen
	mov cx, osp2len			; Länge des strings in CX Register speicher
	int 0x10				; Aufrufen des INT 0x10

ende:															; Label "ende"
	jmp ende													; Sprung zu Label "ende")
	
osp2msg db 13,10,"OSP2 via INT 0x10"
osp2len equ $ - osp2msg
