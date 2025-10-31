# IL2CPP学习笔记

## 1. IL2CPP源码结构

- **入口点**：位于`libil2cpp/vm/Runtime.cpp`中的`Runtime::Init`函数
- **核心库组织结构**：libil2cpp结构清晰，主要分为以下模块：
  - `vm`：虚拟机相关实现
  - `gc`：垃圾回收机制
  - `utils`：工具类和辅助函数
  - `os`：操作系统相关接口封装
- **垃圾回收实现**：位于`libil2cpp/gc`目录下，基于Boehm-Demers-Weiser GC

## 2. 初始化流程

IL2CPP的初始化流程是理解其运行机制的关键。详细内容请参见 [IL2CPP初始化流程详解](IL2CPP初始化流程.md)。

## 2. 垃圾回收机制

- **GC类型**：IL2CPP使用Boehm-Demers-Weiser保守垃圾回收器
- **接口封装**：在IL2CPP中对GC进行了封装，主要接口定义在`libil2cpp/gc/GarbageCollector.h`
- **实现细节**：具体实现在`BoehmGC.cpp`和`GarbageCollector.cpp`文件中，包含了与Unity集成的相关细节

## 3. IL2CPP基本原理和架构

IL2CPP是Unity的一个脚本后端，它将C#代码转换为C++代码，然后编译为原生机器码。这种方式可以提高游戏性能并减少内存占用。

## 4. IL2CPP核心库结构

**libil2cpp**：这是IL2CPP的核心库，包含了虚拟机、垃圾回收(GC)、元数据处理、运行时支持、代码生成、调试器等功能。主要目录结构包括：
- `vm`：虚拟机相关实现
- `gc`：垃圾回收机制
- `metadata`：元数据处理
- `codegen`：代码生成
- `debugger`：调试器
- `utils`：工具类和辅助函数
- `os`：操作系统相关接口封装

## 5. 垃圾回收(GC)机制

IL2CPP使用Boehm-Demers-Weiser保守垃圾回收器，相关代码在libil2cpp/gc目录下。主要文件包括：
- `GarbageCollector.h/cpp`：GC的主要接口和实现
- `BoehmGC.cpp`：基于Boehm GC的具体实现

## 6. C#到C++的转换

当你在Unity中编写C#脚本并使用IL2CPP后端构建时，Unity会将C#代码转换为C++代码。这个过程包括：
- 将C#类和方法转换为对应的C++类和函数
- 生成类型信息和元数据供运行时使用
- 处理C#特有的特性，如垃圾回收、泛型等

## 7. IL2CPP执行入口点

- 应用程序从Main.cpp开始，调用PlayerMain函数
- PlayerMain最终会调用IL2CPP的初始化函数il2cpp_init
- il2cpp_init在libil2cpp/il2cpp-api.cpp中实现，它会调用Runtime::Init进行初始化

## 8. 核心模块

- **Runtime** (`libil2cpp/vm/Runtime.cpp`)：负责整个运行时的初始化和管理
- **GC** (`libil2cpp/gc/`)：垃圾回收的实现，支持Boehm GC等不同GC实现
- **Domain** (`libil2cpp/vm/Domain.cpp`)：管理应用程序域
- **Thread** (`libil2cpp/vm/Thread.cpp`)：线程管理
- **Object Model** (`libil2cpp/vm/Object.cpp`, `libil2cpp/vm/Class.cpp`)：对象模型和类管理

## 9. GC集成

- IL2CPP使用Boehm GC作为默认垃圾回收器
- `libil2cpp/gc/BoehmGC.cpp`实现了与Boehm GC的集成
- `libil2cpp/gc/GarbageCollector.cpp`提供了GC的抽象接口