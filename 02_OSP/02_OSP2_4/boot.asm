[BITS 16]														; Code für 16-Bit-Mode generieren
org 0x7C00														; Start offset auf 0x7C00 setzen
start:															; Label "start" (hier keine Bedeutung )

	; color-textmode - "Hallo Welt"
	mov ax, 0xB800
	mov es, ax
	mov byte [es:0], 'H'
	mov byte [es:1], 00010111b
	mov byte [es:2], 'e'
	mov byte [es:3], 00010111b
	mov byte [es:4], 'l'
	mov byte [es:5], 00010111b
	mov byte [es:6], 'l'
	mov byte [es:7], 00010111b
	mov byte [es:8], 'o'
	mov byte [es:9], 00010111b
	mov byte [es:10], ' '
	mov byte [es:11], 00010111b
	mov byte [es:12], 'W'
	mov byte [es:13], 00010111b
	mov byte [es:14], 'e'
	mov byte [es:15], 00010111b
	mov byte [es:16], 'l'
	mov byte [es:17], 00010111b
	mov byte [es:18], 't'
	mov byte [es:19], 00010111b


    mov ah, 0x02            ; AH=02h für Lese-Operation von Sektor
    mov al, 1               ; Anzahl der Sektoren zu lesen
    mov ch, 0               ; CH=0 für Zylinder 0
    mov cl, 2               ; CL=2 für Sektor 2
    mov dh, 0               ; DH=0 für Head 0
    mov bx, sect2dest       ; Lade die Zieladresse in das Register bx
	mov es, bx				; Zieladresse in es
	xor bx, bx				; Initialisiere das Register bx mit 0
	mov dl, 0				; DL=0 für Drive 0
    int 0x13                ; Interrupt 0x13 ausführen

	jmp sect2dest:0												; Sprung zum nachgeladenem Programmcode

sect2dest equ 0x0500											; Zielsegmentadresse für Code in Sektor 2

