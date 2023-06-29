#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <getopt.h>
#include <stdlib.h>

#define SECTOR_SIZE 512
#define HELP "Usage: writedisk [OPTION] [FILE]\n Optional arguments:\n -s \t number of sector to write to, starting with 1, default 1\n"

/**
 * Check if a string is a number
 * @param string: the string to check
 * @return 1 if it is 0 if it is not
 */
int is_string_number(char* string){
    while(*string != '\0'){
        if(*string < '0' || *string > '9')
            return 0;
        
        string++;
     }
    return 1;
}

int main ( int argc , char * argv []) {
	char sector_buffer[512];
	int floppy, sector_code;
    unsigned int chosen_sector = 1;

    /* Cli argument parsing */
	if ( argc < 2) {
		printf(HELP);
		return -1;
	}

    int opt;
    while((opt = getopt(argc, argv, ":s:")) != -1){
        switch(opt){
            case 's':
                if(!is_string_number(optarg)){
                    printf("Sector has to be number\n");
                    return -1;
                }
                chosen_sector = atoi(optarg);
                break;
            case '?':
                printf(HELP);
                return -1;
                break;
        }
    }

    /* invalid sector num */
    if(chosen_sector < 1){
        printf("Sectors start at 1");
        printf(HELP);
        return -1;
    }

    /* Name of bin file not specified */
    if(optind >= argc){
        printf(HELP);
    }

	sector_code = open(argv[optind], O_RDONLY);

	if (sector_code != -1) {
        if(chosen_sector == 1){
		    read(sector_code, sector_buffer, 510);
		    close(sector_code);
		    sector_buffer[510] = (char)0x55;
		    sector_buffer[511] = (char)0xaa;
        } else{
		    read(sector_code, sector_buffer, SECTOR_SIZE);
		    close(sector_code);
        }
        
		floppy = open("./MiniOS2.flp", O_RDWR);

		if (floppy != -1) {
			lseek(floppy, SECTOR_SIZE*(chosen_sector-1), SEEK_SET);
			write(floppy, sector_buffer, SECTOR_SIZE);
			printf("%s auf FDD geschrieben\n", argv[optind]);
			close(floppy);
			return 0;
        } else {
			printf ("Fehler beim Schreiben\n");
		}
	} else {
	    printf ("Fehler beim Lesen\n");
	}
	return -1;
}
