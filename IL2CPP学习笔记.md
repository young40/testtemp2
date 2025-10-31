# IL2CPP学习笔记

## 1. IL2CPP源码结构

- **入口点**：位于`libil2cpp/vm/Runtime.cpp`中的`Runtime::Init`函数
- **核心库组织结构**：libil2cpp结构清晰，主要分为以下模块：
  - `vm`：虚拟机相关实现
  - `gc`：垃圾回收机制
  - `utils`：工具类和辅助函数
  - `os`：操作系统相关接口封装
- **垃圾回收实现**：位于`libil2cpp/gc`目录下，基于Boehm-Demers-Weiser GC

## 2. 垃圾回收机制

- **GC类型**：IL2CPP使用Boehm-Demers-Weiser保守垃圾回收器
- **接口封装**：在IL2CPP中对GC进行了封装，主要接口定义在`libil2cpp/gc/GarbageCollector.h`
- **实现细节**：具体实现在`BoehmGC.cpp`和`GarbageCollector.cpp`文件中，包含了与Unity集成的相关细节