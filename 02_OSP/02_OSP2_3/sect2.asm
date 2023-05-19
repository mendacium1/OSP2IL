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

ende:															; Label "ende"
	jmp ende													; Sprung zu Label "ende")
