# Address Sanitizer学习笔记

## 1. UNITY_ASAN宏和unity_asan_configure函数

在`MacProject/StepIntoUnityGC/Main.cpp`中发现了以下代码：

```cpp
#if UNITY_ASAN
extern "C"
{
    extern void unity_asan_configure();
}
#endif

int main(int argc, const char *argv[])
{
#if UNITY_ASAN
    unity_asan_configure();
#endif
    // ...
}
```

- `UNITY_ASAN`是一个预处理器宏，用于条件编译ASAN相关代码
- `unity_asan_configure()`函数是Unity引擎提供的专门用于配置ASAN的函数
- 该函数的具体实现在Unity引擎的内部库中，未在项目源码中找到定义

## 2. 项目中的其他ASAN相关内容

### MemoryPoolAddressSanitizer类

项目中包含专门用于ASAN的内存池实现：

1. **MemoryPoolAddressSanitizer.h** - 声明文件
   - 只在启用地址消毒器时使用（通过`IL2CPP_SANITIZE_ADDRESS`宏控制）
   - 使用系统分配器而不是自定义内存池，以便ASAN能够检测内存访问问题

2. **MemoryPoolAddressSanitizer.cpp** - 实现文件
   - 直接使用`malloc`和`calloc`进行内存分配
   - 维护分配记录以便正确释放内存
   - 在析构时释放所有分配的内存

### 条件编译

在`MetadataAlloc.cpp`中使用条件编译来选择内存池实现：

```cpp
#if IL2CPP_SANITIZE_ADDRESS
    typedef utils::MemoryPoolAddressSanitizer MemoryPoolType;
#else
    typedef utils::MemoryPool MemoryPoolType;
#endif
```

### ASAN默认选项

在`bdwgc/os_dep.c`中配置了ASAN默认选项：

```c
GC_API const char *__asan_default_options(void)
{
  return "allow_user_segv_handler=1";
}
```

这个配置允许GC使用自己的SIGBUS/SEGV处理器。

## 3. 总结

项目在设计时充分考虑了与Address Sanitizer的兼容性：
- 通过条件编译支持ASAN功能的启用/禁用
- 提供专门的内存管理策略以配合ASAN工作
- 配置ASAN选项以确保与垃圾回收器的兼容性