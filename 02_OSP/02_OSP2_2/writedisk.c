#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

void get_usage() {
    printf("Syntax: writedisk [-s <sectornumber>] <filename>\n");
    exit(-1);
}

int main(int argc, char* argv[]) {
    char bootsector[512];
    int floppy, bootcode;
    int sector_number = 1; // default value for sector number
    int opt;

    // use getopt to parse the command line options
    while ((opt = getopt(argc, argv, "s:")) != -1) {
        switch (opt) {
            case 's':
                sector_number = atoi(optarg);
                break;
            default:
                get_usage();
        }
    }

    // check if there is a file name provided
    if (argc < 1) {
        get_usage();
    }

    bootcode = open(argv[optind], O_RDONLY);
    if (bootcode != -1) {
        read(bootcode, bootsector, 510);
        close(bootcode);
        bootsector[510] = (char)0x55;
        bootsector[511] = (char)0xaa;
        floppy = open("/dev/fd0", O_RDWR);
        if (floppy != -1) {
            lseek(floppy, (sector_number - 1) * 512, SEEK_SET);
            write(floppy, bootsector, 512);
            printf("%s auf FDD Sektor %d geschrieben\n", argv[0], sector_number);
            close(floppy);
            return 0;
        } else {
            printf("Fehler beim Schreiben\n");
        }
    } else {
        printf("Fehler beim Lesen\n");
    }
    return -1;
}

