all : boot writedisk disk
boot : boot.asm
	nasm -w+all -o boot boot.asm
disk : writedisk
	./writedisk -s 1 boot
writedisk : writedisk.c
	gcc -std=c99 -Wall -pedantic writedisk.c -o writedisk
clean :
	rm boot writedisk sect2
