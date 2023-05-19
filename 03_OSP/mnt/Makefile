all : boot writedisk sect2 disk
boot : boot.asm
	nasm -w+all -o boot boot.asm
sect2 : sect2.asm
	nasm -w+all -o sect2 sect2.asm
disk : writedisk
	./writedisk -s 1 boot
	./writedisk -s 2 sect2
writedisk : writedisk.c
	gcc -std=c99 -Wall -pedantic writedisk.c -o writedisk
clean :
	rm boot writedisk sect2
