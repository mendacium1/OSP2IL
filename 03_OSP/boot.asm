;03_OSP2
;Folgender Programmcode soll so modifiziert werden, dass vom Real-Mode in
;den Protected-Mode gewechselt wird. Die einzelnen Aufgaben sind dabei
;sinnvollerweise nicht in der Reihenfolgen ihres Auftretens sondern in der
;Reihenfolge 1,2,3,4,5,6,7 zu lösen.

[BITS 16]
org 0x7C00

start:

    mov ax,0
    mov ds,ax
    cli                       ;Interrupts deaktivieren
    lgdt [gdtr]               ;Global Descriptor Table laden

;<AUFGABE2>
;Verändere das Prozesskontrollregister CR0 so, dass der Protected-Mode aktiviert
;wird. Hilfreich ist hier "Intel 64 and IA-32 Architectures Software Developers
;Manual Volume 3A.pdf". Wie vom Real-Mode in den Protected-Mode ge- wechselt
;werden kann, zeigt Abbildung 2-3. Eine Beschreibung des Vorgangs ist in
;Abschnitt 9.9.1 zu finden. Wir verzichten zum aktuellen Zeitpunkt darauf, die
;Interrupt Descriptor Table (IDT) zu laden. Paging soll ebenfalls noch nicht
;verwendet werden.

    mov eax, cr0
    or eax, 1                 ;Setzen des PE (Protected Enable) bit in CR0
    mov cr0, eax

;</AUFGABE2>

    jmp code:protectedmode    ;Sprung in den Protected-Mode

[BITS 32]
protectedmode:

;<AUFGABE3>
;Der erste Schritt nach dem Wechsel in den Protected-Mode ist das Initialisieren
;der benötigten Segmentregistern. Ein Segmentregister enthält dabei den Offset
;des Segmentdeskriptors innerhalb der GDT. Es werden in unserem Fall zumindest
;das DS-Register (Datensegment), das SS-Register (Stacksegment) und das
;ES-Register (Videosegment) benötigt. Der Stackpointer (ESP) wird sinnvoller-
;weise auf das Ende des Datensegments gesetzt.

    mov ax, data
    mov ds, ax                    ; Setzen des DS-Registers auf data


    ;mov ax, code                 ; Dachte zuerst data = code, schmeißt aber fault fehler
    mov ss, ax                    ; Setzen des SS-Registers auf data (da code nicht funktioniert)

    mov ax, video
    mov es, ax

    mov esp, 0xBFF                ; Set the stack pointer to the end of the data segment

;</AUFGABE3>

    mov eax, protectedmsg         ;Erfolgsmeldung ausgeben
    call write32

;<AUFGABE5>
;Testen Interrupt 1. Zuvor muss die IDT analog zur GDT mit lidt geladen werden.

    lidt [idtr]
    int 0x1

;</AUFGABE5>

;<AUFGABE7>
;Aktiviere Paging indem du das Kommentar vor der nachfolgenden Call-Anweisung
;entfernen. Der Interrupthandler für Interrupt 2 ist auch auf einer Adresse
;oberhalb von 4MiB zu erreichen. Modifiziere den Interrupt-Gate-Deskriptor für
;Interrupt 2 so dass der Interrupthandler von dieser Adresse gestartet wird.
;Rufe anschließend Interrupt 2 auf.

    call startpaging
    ;Da der IDT an dieser Stelle nicht beschrieben werden kann, habe ich dies bereits im
    ;vorhinein unter Aufgabe 4 geändert. Meine Überlegung wäre folgende gewesen:
    ;mov dword [idt+0xb0], 0x80 ;write offset 31-16
    int 0x2

;</AUFGABE 7>

endloop:                      ;Endlosschleife
    jmp endloop

;<AUFGABE 6>
;Analysiere folgenden Code. Was passiert hier? Nutzen die Erkenntnisse in
; AUFGABE 7

;Folgender Code aktiviert paging. Paging wird für das memory management verwendet und übersetzt
;virutelle adressen in physikalische Adressen
startpaging:
pagedir equ 0x80000           ;Setzen der Konstanten pagedir als Startadresse für das page-
                              ;Directory
pagetab equ 0x81000           ;Setzen der Konstanten pagetab als Startadresse für den page-
                              ;Table
tabsize equ 0x400             ;Setzen der Konstante tabsize als Größe für Page-Directory und Page-
                              ;Table. (1024Bit = 0x400)

    mov ebx,tabsize           ;Zero PageDirectory
                              ;Initialisieren eines loop-counters über das ebx-Register

;Unter diesem label werden Page-Directory Einträge initialisiert
zeropagedir:                  ;Beginn der loop welche das Page-Directory leert/initialisiert
    dec ebx                   ;Dekrementieren des ebx-Rigisters um 1
    mov dword [ebx*4+pagedir],0;Jeden Eintrag des Page-Directory auf 0 setzen
    cmp ebx,0                 ;Checken ob ebx den Wert 0 hat
    jne zeropagedir           ;Ist die vorherige Bedingung falsch, so wird wieder zum zeropagedir
                              ;label gesprungen, dies wiederholt sich solange bis ebx den Wert 0
                              ;hat.
    mov eax,pagetab           ;Hier wird der Wert aus pagetab in das eax-Register geschrieben.
    or  eax,3                 ;Hier werden die 2 "niedrigsten" Bit auf 1 gesetzt (bitwise OR with
                              ;11)
    mov dword [pagedir],eax   ;Kopieren des Wertes im eax-Register an die Adressen von pagedir. 
                              ;Dies setzt den ersten Eintrag des Page-Directory auf den Wert von
                              ;pagetab und aktiviert das "present" und "read/write" flag.
    mov dword [pagedir+8],eax ;Ähnlich zu dem Befehl zuvor wird hier nun ein zweiter Eintrag
                              ;gemacht.

    mov ebx,tabsize           ;Map PDE1 (virt = phys)
                              ;Neu setzen des ebx-Registers mit tabsize, damit dieses Register
                              ;wieder als loop-Counter verwendet werden kann.

;Unter diesem label wird der page-Table beschrieben
fillpagetable:
    dec ebx                   ;Dekrementieren des ebx-Registers um 1
    mov eax, ebx              ;Derzeitigen Wert des ebx-Registers in das eax-Register schreiben.
    shl eax,12                ;Verschieben des Wertes im eax-Register um 12 bit nach links. Dies
                              ;ist equivalent zu einer multiplikation mit 4096 und konvertiert
                              ;die Adresse in eine physikale Adresse
    or  eax,3                 ;Gleich wie zuvor werden hier die 2 "niedrigsten" Bits auf 11 gesetzt
                              ;mit Hilfe einer Bit-weisen OR-Operation
    mov dword [ebx*4+pagetab],eax
                              ;Kopieren des eax-Registers in den Adressbereich durch multiplizieren
                              ;des ebx-Registers mit 4 und hinzufügen von pagetab. Dies setzt jeden
                              ;Eintrag mit einer physikalischen Adressen und aktiviert das wieder
                              ;das "present" und das "read/write" flag
    cmp ebx,0                 ;Gleich wie zuvor wird das ebx-Register mit 0 verglichen
    jne fillpagetable         ;Ist die vorherige Bedingung falsch wird zum label "fillpagetable"
                              ;gesprungen (loop bis ebx == 0)

    mov eax,pagedir           ;PDE -> CR3
                              ;Kopieren des Wertes aus pagedir in das eax-Register
    mov cr3,eax               ;Kopieren des Wertes aus dem eax-Register in das cr3-Register
                              ;(cr3 - Control Register 3). Dies setzt die physikalische Adresse des
                              ;Page-Directory
    pop ebx                   ;Wiederherstellen des ursprünglichen Wertes im ebx-Register über den
                              ;Stack.
    mov eax,cr0               ;Set PG-Bit
                              ;Kopieren des Wertes aus dem cr0-Register in das eax-Register
    or eax,0x80000000         ;Bit-weise OR-Operation mit dem eax-Register und dem Wert
                              ;0x80000000. Dies ist das Bit für "paging-enabled" im cr0-Register
    mov cr0,eax               ;Kopieren des Wertes aus dem eax-Register in das cr0-Register. Nun
                              ;ist das "paging-enabled"-Bit im cr0-Register gesetzt.
    push ebx                  ;Den Wert aus dem ebx-Register auf den Stack pushen
    retn                      ;Verlässt die Funktion
;</AUFGABE6>

;<AUFGABE1>
;Im Protected Mode wird Segmentierung zwingend benötigt. Dazu muss die Global
;Descriptor Table (GDT) mit gültigen Werten gefüllt werden. Eine Referenz zur
;GDT (Symbol gdtr) kann anschließend mit dem Kommando lgdt (Zeile 15) in das
;Global Descriptor Table Register (GDTR) geladen werden.
;Wir benötigen hier zumindest folgende drei Segmente:
; - Code-Segment "code": Basisadresse 0x00000000, Größe 12MiB
; - Daten-Segment "data": Basisadresse 0x00000000, Größe 12MiB
; - Video-Segment "video": Basisadresse und Größe sind selbst zu ermitteln
;Auch hier ist "Intel 64 and IA-32 Architectures Software Developers Manual
;Volume 3A.pdf" hilfreich. Der Aufbau eines Segmentdeskriptors wird in
;Abschnitt 3.4.5 sehr gut beschrieben.
;ACHTUNG: Der erste Deskriptor in der GDT muss immer leer sein.


; Global Descriptor Table
gdtr:
    dw gdt_end-gdt-1          ;16-Bit Limit
    dd gdt                    ;32-Bit Basisadresse
gdt:
    dd 0,0                    ;Leerer Descriptor an Position 0
code equ $-gdt
    dw 0x0BFF                 ;Seg Limit 15:00 = 10111000
    dw 0x0000                 ;Base 15:00 = 0
    db 0x00                   ;Base 23:16 = 0
    db 0x9A                   ;P = Segment present = 1 (is present in memory)
                              ;DPL = Descriptor priviledge level = 00 (highest)
                              ;S = Descriptor Type = 1 (code/data)
                              ;TYPE = 1010 (Execute/Read)
    db 0xC0                   ;G = Granularity = 1 (in 4KB increments)
                              ;D/B = Default operation size = 1 (32-bit)
                              ;L = 64-bit code segment = 0
                              ;AVL = Available for use by system software = 0
                              ;(usable by system software)
                              ;Seg Limit 19:16 = 1011
    db 0x00                   ;Base 31:24 = 0
data equ $-gdt
    dw 0x0BFF                 ;Seg Limit 15:00 = 10111000
    dw 0x0000                 ;Base 15:00 = 0
    db 0x00                   ;Base 23:16 = 0
    db 0x92                   ;P = Segment present = 1 (is present in memory)
                              ;DPL = Descriptor priviledge level = 00 (highest)
                              ;S = Descriptor Type = 1 (code/data)
                              ;TYPE = 0010 (Read/Write)
    db 0xC0                   ;G = Granularity = 1 (in 4KB increments)
                              ;D/B = Default operation size = 1 (32-bit)
                              ;L = 64-bit code segment = 0
                              ;AVL = Available for use by system software = 0
                              ;(usable by system software)
                              ;Seg Limit 19:16 = 1011
    db 0x00                   ;Base 31:24 = 0
video equ $-gdt
    dw 0x7CFF                 ;Seg Limit 15:00 = 0000 0001
    dw 0x8000                 ;Base 15:00 = 80
    db 0x0B                   ;Base 23:16 = 0B
    db 0x92                   ;P = Segment present = 1 (is present in memory)
                              ;DPL = Descriptor priviledge level = 00 (highest)
                              ;S = Descriptor Type = 1 (code/data)
                              ;TYPE = 0010 (Read/Write)
    db 0x40                   ;G = Granularity = 0 (bytewise increments)
                              ;D/B = Default operation size = 1 (32-bit)
                              ;L = 64-bit code segment = 0
                              ;AVL = Available for use by system software = 0
                              ;(usable by system software)
                              ;Seg Limit 19:16 = 1011
    db 0x00                   ;Base 31:24 = 0
gdt_end:

;</AUFGABE1>

;<AUFGABE4>
;Das Betriebssystem soll um Interrupts erweitert werden. Wie auch in der GDT
;wird für jeden Interrupt ein Descriptor benötigt.
;Auch hier ist "Intel 64 and IA-32 Architectures Software Developers Manual
;Volume 3A.pdf" hilfreich. Der Aufbau eines Interruptdeskriptors wird in
;Abschnitt 6.11 sehr gut beschrieben. Wir legen Interrupt-Gate-Deskriptoren
;für die Interrupts 1 und 2 an.
;ACHTUNG: Der erste Deskriptor in der IDT muss immer leer sein.

; Global Interrupt Table
idtr:
    dw idt_end-idt-1          ;16-Bit Limit
    dd idt                    ;32-Bit Basisadresse
idt:
    dd 0,0                    ;Leerer Descriptor an Position 0

    dw interrupthandler1      ;Interrupthandler1 - Offset
    dw code                   ;code - Segment Selector = 0
    db 0x0
    db 10001111b              ;P = Segment Present flag = 1
                              ;DPL = Descriptor Privilege Level = 00 (highest)
                              ;D = Size of gate = 1 (32 bits)
    dw 0x0                    ;Offset 31:16 = 0

    dw interrupthandler2      ;Interrupthandler1 - Offset
    dw code                   ;code - Segment Selector = 0
    db 0x0                    ;Vorgegebene bits (reserved einfach 0)
    db 10001111b              ;P = Segment Present flag = 1
                              ;DPL = Descriptor Privilege Level = 00 (highest)
                              ;D = Size of gate = 1 (32 bits)
    ;An dieser Stelle wird Aufgabe 7 berücksicht und die Offset Addresse auf den Bereich
    ;im Paging gesetzt
    dw 0x80                    ;Offset 31:16 = 0
idt_end:

;</AUFGABE4>


;<WICHTIG>
;Ab dieser Position müssen keine Änderungen durchgeführt werden
;</WICHTIG>

; Interrupthandler

interrupthandler1:
    mov eax,interruptmsg1
    call write32
    iret

interrupthandler2:
    mov eax,interruptmsg2
    call write32
    iret

; Messages

protectedmsg     db     5,"Nachricht aus dem Protected Mode",0
interruptmsg1    db     6,"Nachricht von Interrupt 1",0
interruptmsg2    db     7,"Nachricht von Interrupt 2 (Paging)",0



; HILFSFUNKTIONEN

write32:
    push ebx
    push ecx
    push edx
    mov edx,eax
    mov byte al,[ds:edx]
    mov cl,160
    mul cl
    xor ecx,ecx
    inc edx
write32loop:
    mov byte bl,[ds:edx + ecx]
    cmp bl,0
    jz write32end
    mov byte [es:2*ecx+eax],bl
    mov byte [es:2*ecx+eax+1],0x1f
    inc ecx
    jmp write32loop
write32end:
    pop edx
    pop ecx
    pop ebx
    retn

