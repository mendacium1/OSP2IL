[BITS 16]														; Code für 16-Bit-Mode generieren
org 0x7C00														; Start offset auf 0x7C00 setzen
start:															; Label "start" (hier keine Bedeutung )

	; Aufgabe 5 Interrupt-Service-Routine (ISR)
	; Hinzufügen zu Interrupt-Tabelle
	xor ax, ax
	mov ds, ax
	cli						; Während dem updaten der IVT sind interrupts unerwünscht
	mov word [0x20], aufgabe5_isr
	mov [0x20+2], ax
	sti

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




	; Aufruf von ISR (Aufgabe 5)
	int 0x20

	jmp sect2dest:0												; Sprung zum nachgeladenem Programmcode

sect2dest equ 0x0500											; Zielsegmentadresse für Code in Sektor 2

; Aufgabe 5 Interrupt-Service-Routine (ISR)

; isr
aufgabe5_isr:
	; Hier wieder mit INT 10h
	; Ermitteln der aktuellen Cursorposition
	mov ah, 0x03			; AH auf 0x03 setzen für "Read Cursor Position and Shape"-Funktion
	mov bh, 0				; BH auf 0 für page 0
	int 0x10				; Aufrufen des INT 0x10
	; Die Reihe ist nun im DH und die Spalte im DL Register gespeichert

	; Schreiben der osp-Nachricht
	mov ax, aufgabe5msg			; Pointer zu string in ax register speichern
	mov bp, ax				; Pointer in BP Register speichern
	xor ax, ax				; AX Register auf 0 setzen
	mov es, ax				; ES Register auch auf 0 setzen
	mov ah, 0x13			; AH auf 0x13 setzen für "Write string"-Funktion
	mov al, 1				; AL auf 1 setzen für "write mode"
	mov bl, 00000110b		; Farbe setzen (Font: orange, BG: black)
	mov cx, aufgabe5len			; Länge des strings in CX Register speicher
	int 0x10				; Aufrufen des INT 0x10



aufgabe5msg db 13,10,"ISR20h"
aufgabe5len equ $ - aufgabe5msg
