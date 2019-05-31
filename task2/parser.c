#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

#define BUFFER_SIZE 1024

void process_buffer(char* buffer, int readed, int fdo) {
    int bytes_count = 0;
    int is_zeros = 1;

    for (int i = 0; i < readed; i++, bytes_count++) {
        if (is_zeros && !buffer[bytes_count]) {
            write(fdo, buffer, bytes_count);
            buffer = &buffer[bytes_count];
            bytes_count = 0;
            is_zeros = 0;
        }
        else if (!is_zeros && buffer[i])
        {
            lseek(fdo, bytes_count, SEEK_CUR);
            buffer = &buffer[bytes_count];
            is_zeros = 1;
            bytes_count = 0;
        }
    }

    if (is_zeros) {
        write(fdo, buffer, bytes_count);
    }
    else {
        lseek(fdo, bytes_count, SEEK_CUR);
    }
}

void sparse(char* outfile) {
    int fdi = STDIN_FILENO;
    int fdo = open(outfile, O_CREAT|O_WRONLY|O_TRUNC, 0644);
    if (fdo < 0) {
        perror("Error while opening output file\n");
        _exit(2);
    }

    char buffer[BUFFER_SIZE];
    int readed = 0;
    memset(buffer, 0, sizeof(buffer));

    while ((readed = read(fdi, buffer, sizeof(buffer))) > 0) {
        process_buffer(buffer, readed, fdo);
    }

    close(fdo);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        perror("Usage: gzip -cd <archive> | ./parser <output_file>\n");
        return 1;
    }

    sparse(argv[1]);

    return 0;
}