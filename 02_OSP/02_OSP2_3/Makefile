all : boot writedisk disk
boot : boot.asm
	nasm -w+all -o boot boot.asm
sect2 : sect2.asm
	nasm -w+all -o sect2 sect2.asm
disk : writedisk
	./writedisk -s 0 boot
writedisk : writedisk.c
	gcc -std=c99 -Wall -pedantic writedisk.c -o writedisk
clean :
	rm boot writedisk
