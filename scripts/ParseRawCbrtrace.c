#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void usageError() {
	fprintf(stderr, "Usage:\n<exec> <cbrtrace.log> <dest.log>\n");
	exit(EXIT_FAILURE);
}

void logError(char* path) {
	fprintf(stderr, "%s not found\n", path);
	exit(EXIT_FAILURE);
}

void trimNewline(char* line) {
	int index = strlen(line) - 1;
	if (line[index] == '\n') line[index] = '\0';
}

void parseLog(char* rawPath, char* destPath) {
	FILE* raw = fopen(rawPath, "r");
	if (raw == NULL) logError(rawPath);
	FILE* dest = fopen(destPath, "w");
	char buffer[256];
	unsigned long long branchAddr, takenAddr, actualAddr;
	while (fgets(buffer, sizeof(buffer), raw)) {
		sscanf(buffer, "%*llx [%llx, %*llx, %llx] => %llx", &branchAddr, &takenAddr, &actualAddr);
		fprintf(dest, "0x%.16lX %b\n", branchAddr, takenAddr == actualAddr ? 1 : 0);
	}
	fclose(raw);
	fclose(dest);
	printf("%s parsed to %s\n", rawPath, destPath);
}

void parseStdin() {
	char rawBuffer[256];
	char destBuffer[256];
	while (fgets(rawBuffer, sizeof(rawBuffer), stdin)) {
		// printf("%s\n", rawBuffer);
		trimNewline(rawBuffer);
		strcpy(destBuffer, rawBuffer);
		strcat(destBuffer, ".bp");
		parseLog(rawBuffer, destBuffer);
	}
}

int main(int argc, char** argv) {
	if (argc == 1) parseStdin();
	else if (argc == 2) {
		char buffer[256];
		strcpy(buffer, argv[1]);
		strcat(buffer, ".bp");
		parseLog(argv[1], buffer);
	}
	else if (argc == 3) parseLog(argv[1], argv[2]);
	else usageError();
	return 0;
}
