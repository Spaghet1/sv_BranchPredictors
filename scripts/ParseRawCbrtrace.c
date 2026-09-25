#include <stdio.h>
#include <stdlib.h>

void usageError() {
	fprintf(stderr, "Usage:\n<exec> <cbrtrace.log> <dest.log>\n");
	exit(EXIT_FAILURE);
}

void logError(char* path) {
	fprintf(stderr, "%s not found\n", path);
	exit(EXIT_FAILURE);
}

int main(int argc, char** argv) {
	if (argc != 3) usageError();
	unsigned long long branchAddr, takenAddr, actualAddr;
	char buffer[256];
	FILE* raw = fopen(argv[1], "r");
	if (raw == NULL) logError(argv[1]);
	FILE* dest = fopen(argv[2], "w");
	while (fgets(buffer, sizeof(buffer), raw)) {
		sscanf(buffer, "%*llx [%llx, %*llx, %llx] => %llx", &branchAddr, &takenAddr, &actualAddr);
		fprintf(dest, "0x%.16lX %b\n", branchAddr, takenAddr == actualAddr ? 1 : 0);
	}
	fclose(raw);
	fclose(dest);
	printf("%s parsed to %s\n", argv[1], argv[2]);
	return 0;
}
