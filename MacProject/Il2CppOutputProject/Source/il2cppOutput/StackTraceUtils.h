#pragma once

#include <execinfo.h>
#include <dlfcn.h>
#include <cxxabi.h>

// 打印当前调用堆栈的函数
void PrintCurrentStackTrace();

// 打印带有自定义消息的调用堆栈
void PrintCurrentStackTraceWithMessage(const char* message);