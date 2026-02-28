#ifndef _LOGGER_H_
#define _LOGGER_H_

#define COLOR_CODE_RED      "\033[1;31m"
#define COLOR_CODE_YELLOW   "\033[1;33m"
#define COLOR_CODE_CYAN     "\033[1;36m"
#define COLOR_CODE_WHITE    "\033[1;37m"

#define LOG_LEVEL_NONE      0u
#define LOG_LEVEL_DEBUG     1U
#define LOG_LEVEL_WARNING   2U
#define LOG_LEVEL_ERROR     3U

#define LOG_LEVEL_SHORT LOG_LEVEL_DEBUG

#define LOG_MESSAGE(format, ...)                log_write(COLOR_CODE_WHITE, __FUNCTION__, format, ##__VA_ARGS__)
#define LOG_DEBUG(format, ...)                  log_write(COLOR_CODE_CYAN, __FUNCTION__, format, ##__VA_ARGS__)
#define LOG_WARNING(format, ...)                log_write(COLOR_CODE_YELLOW, __FUNCTION__, format, ##__VA_ARGS__)
#define LOG_ERROR(format, ...)                  log_write(COLOR_CODE_RED, __FUNCTION__, format, ##__VA_ARGS__)

#if (LOG_LEVEL_SHORT == LOG_LEVEL_DEBUG)
#define LOG_DEBUG_SHORT(format, ...)            log_write_no_header(COLOR_CODE_CYAN, __FUNCTION__, format, ##__VA_ARGS__)
#define LOG_MESSAGE_SHORT(format, ...)          log_write_no_header(COLOR_CODE_WHITE, __FUNCTION__, format, ##__VA_ARGS__)
#else
#define LOG_DEBUG_SHORT(format, ...)            do { } while (0)
#define LOG_MESSAGE_SHORT(format, ...)          do { } while (0)
#endif
#if (LOG_LEVEL_SHORT == LOG_LEVEL_DEBUG) || (LOG_LEVEL_SHORT == LOG_LEVEL_WARNING)
#define LOG_WARNING_SHORT(format, ...)          log_write_no_header(COLOR_CODE_YELLOW, __FUNCTION__, format, ##__VA_ARGS__)
#else
#define LOG_WARNING_SHORT(format, ...)         do { } while (0)
#endif
#if (LOG_LEVEL_SHORT == LOG_LEVEL_DEBUG) || (LOG_LEVEL_SHORT == LOG_LEVEL_WARNING) || (LOG_LEVEL_SHORT == LOG_LEVEL_ERROR)
#define LOG_ERROR_SHORT(format, ...)            log_write_no_header(COLOR_CODE_RED, __FUNCTION__, format, ##__VA_ARGS__)
#else
#define LOG_ERROR_SHORT(format, ...)            do { } while (0)
#endif

void log_write(const char* colorCode, const char* func, const char* format, ...);
void log_write_no_header(const char* colorCode, const char* func, const char* format, ...);

#endif
