#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>

#define RESET_COLOR "\033[1;0m"
#define ENABLE_FILE_LOG

void log_write(const char* colorCode, const char* func, const char* format, ...)
{
    va_list args;
    va_start(args, format);
    printf("%s[%s] ", colorCode, func);
    vprintf(format, args);
    printf(RESET_COLOR);
    va_end(args);
}

void log_write_no_header(const char* colorCode, const char* func, const char* format, ...)
{
    va_list args;
    va_start(args, format);

    printf("%s", colorCode);
    vprintf(format, args);
    printf(RESET_COLOR);

#ifdef ENABLE_FILE_LOG
    static FILE* pOutFile = NULL;
    if (!pOutFile)
    {
        pOutFile = fopen("log.txt", "w");
    }

    if (pOutFile)
    {
        vfprintf(pOutFile, format, args);
    }
#endif

    va_end(args);
}
