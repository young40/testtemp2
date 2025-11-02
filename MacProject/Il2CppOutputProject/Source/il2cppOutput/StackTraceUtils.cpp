#include "StackTraceUtils.h"
#include <execinfo.h>
#include <dlfcn.h>
#include <cxxabi.h>
#include <cstdlib>
#include <iostream>
#include <cstdio>
#include <cstring>
#include <memory>

void PrintCurrentStackTrace() {
    PrintCurrentStackTraceWithMessage("=== Call Stack ===");
}

void PrintCurrentStackTraceWithMessage(const char* message) {
    printf("%s\n", message);
    
    // 使用标准C++的execinfo.h来获取调用堆栈
    const int MAX_STACK_FRAMES = 64;
    void* callstack[MAX_STACK_FRAMES];
    int frameCount = backtrace(callstack, MAX_STACK_FRAMES);

    // 将堆栈符号转换为可读字符串
    char** symbols = backtrace_symbols(callstack, frameCount);

    if (symbols != NULL) {
        for (int i = 0; i < frameCount; i++) {
            printf("Frame #%d: %p\n", i+1, callstack[i]);

            // 解析符号信息
            char* symbol = symbols[i];

            // 尝试从符号字符串中提取函数名
            if (symbol != NULL) {
                // 查找函数名在符号字符串中的位置
                char* start = strchr(symbol, '(');
                if (start) {
                    start++; // 跳过 '('
                    char* end = strchr(start, '+');
                    if (end) {
                        *end = '\0'; // 截断函数名
                        // 尝试 demangle C++ 符号
                        int status = 0;
                        size_t bufferLen = 1024;
                        char* demangled = abi::__cxa_demangle(start, nullptr, &bufferLen, &status);
                        if (status == 0 && demangled != nullptr) {
                            printf("  [C++] Function: %s\n", demangled);
                            free(demangled);
                        } else {
                            printf("  [C++] Function: %s\n", start);
                        }
                    } else {
                        // 如果没有找到+号，尝试找到)号
                        end = strchr(start, ')');
                        if (end) {
                            *end = '\0';
                            // 尝试 demangle C++ 符号
                            int status = 0;
                            size_t bufferLen = 1024;
                            char* demangled = abi::__cxa_demangle(start, nullptr, &bufferLen, &status);
                            if (status == 0 && demangled != nullptr) {
                                printf("  [C++] Function: %s\n", demangled);
                                free(demangled);
                            } else {
                                printf("  [C++] Function: %s\n", start);
                            }
                        } else {
                            printf("  [C++]: %s\n", symbol);
                        }
                    }
                } else {
                    // 尝试查找最后一个空格后的内容（函数名通常在最后）
                    char* last_space = strrchr(symbol, ' ');
                    if (last_space) {
                        printf("  [C++] Symbol: %s\n", last_space+1);
                    } else {
                        printf("  [C++] Symbol: %s\n", symbol);
                    }
                }
            }

            // 使用dladdr获取更详细的符号信息
            Dl_info dlInfo;
            if (dladdr(callstack[i], &dlInfo)) {
                if (dlInfo.dli_sname) {
                    // 尝试 demangle 符号名
                    int status = 0;
                    size_t bufferLen = 1024;
                    char* demangled = abi::__cxa_demangle(dlInfo.dli_sname, nullptr, &bufferLen, &status);
                    if (status == 0 && demangled != nullptr) {
                        printf("  [dladdr] Demangled: %s\n", demangled);
                        free(demangled);
                    } else {
                        printf("  [dladdr] Symbol: %s\n", dlInfo.dli_sname);
                    }
                }
                if (dlInfo.dli_fname) {
                    printf("  [dladdr] File: %s\n", dlInfo.dli_fname);
                }
                if (dlInfo.dli_fbase) {
                    printf("  [dladdr] Base: %p\n", dlInfo.dli_fbase);
                }
            }

            printf("\n");
        }

        free(symbols);
    } else {
        printf("Failed to get backtrace symbols\n");
        // 至少输出内存地址
        for (int i = 0; i < frameCount; i++) {
            printf("Frame #%d: %p\n", i+1, callstack[i]);
        }
    }

    printf("=== End of call stack (total frames: %d) ===\n\n", frameCount);
}