#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>

#define RESET_COLOR "\033[1;0m" // default color: white text, no background
#define ENABLE_FILE_LOG         // #define to enable logging to file


/// @brief function to write log messages with color and function name
/// @param colorCode log message color code
/// @param func function name
/// @param format format string
/// @param ... additional arguments (variadic)
void log_write(const char* colorCode, const char* func, const char* format, ...)
{
    va_list args;
    va_start(args, format); // initialize variadic arguments
    printf("%s[%s] ", colorCode, func); // !! terminal must support ANSI escape codes for colors !!
    vprintf(format, args);
    printf(RESET_COLOR); // reset color to default after printing the log message
    va_end(args);
}


/// @brief function to write log messages without header (only color and function name)
/// @param colorCode log message color code
/// @param func function name
/// @param format format string
/// @param ... additional arguments (variadic)
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
