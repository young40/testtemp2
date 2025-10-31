# IL2CPP 初始化流程详解

本文档详细描述了 IL2CPP 运行时环境的初始化过程。

## 1. 入口点

IL2CPP 的初始化通常从 `libil2cpp/vm/Runtime.cpp` 文件中的 `Runtime::Init` 函数开始。这是整个 IL2CPP 运行时的核心初始化函数。

## 2. 核心初始化步骤

### 2.1 Runtime 初始化 (`Runtime::Init`)

`Runtime::Init` 是 IL2CPP 初始化的核心，主要完成以下工作：

1.  **基础环境初始化**:
    *   进行一些基本的健全性检查 (Sanity Checks)。
    *   初始化操作系统相关层 (`os::Initialize`, `os::Locale::Initialize`, `os::Image::Initialize`, `os::Thread::Init`)。
2.  **代码生成注册**:
    *   调用生成代码的注册函数 `g_CodegenRegistration()`，注册内部调用 (icalls) 和其他由 IL2CPP 生成器产生的代码。
3.  **元数据和程序集系统**:
    *   初始化元数据缓存 (`MetadataCache::Initialize`)。
    *   初始化程序集加载系统 (`Assembly::Initialize`)。
4.  **垃圾回收器 (GC) 初始化**:
    *   调用 `gc::GarbageCollector::Initialize()`。这是 GC 流程开始的关键点，它会启动终结器线程。
5.  **线程系统**:
    *   初始化线程管理器 (`Thread::Initialize`)。这一步需要在 GC 初始化之后进行。
6.  **核心类型设置**:
    *   设置 IL2CPP 默认类型的引用 (`il2cpp_defaults`)，如 `System.Object`, `System.String`, `System.Int32` 等基础类型。
7.  **类库和反射**:
    *   初始化类库 PAL (Platform Abstraction Layer) (`ClassLibraryPAL::Initialize`)。
    *   初始化反射系统 (`Reflection::Initialize`)。
8.  **网络和域**:
    *   初始化套接字系统 (`os::Socket::Startup`)。
    *   创建并附加主线程 (`Thread::Attach`, `Thread::SetMain`)。
    *   创建和设置应用程序域 (`Il2CppDomain`, `Il2CppAppDomain`) 及其上下文。
9.  **终结器线程**:
    *   初始化并启动终结器线程 (`gc::GarbageCollector::InitializeFinalizer`)。这个线程负责在后台执行对象的终结器。
10. **字符串和环境**:
    *   初始化字符串系统，包括创建空字符串。
    *   设置一些环境变量以影响 Mono 兼容层的行为。
11. **静态构造函数**:
    *   执行那些在类首次加载时就应该运行的静态构造函数和模块初始化器 (`vm::MetadataCache::ExecuteEagerStaticClassConstructors`, `vm::MetadataCache::ExecuteModuleInitializers`)。
12. **完成标志**:
    *   最后将全局标志 `g_il2cpp_is_fully_initialized` 设置为 `true`，表示运行时已完全初始化。

### 2.2 垃圾回收器初始化 (`gc::GarbageCollector::Initialize`)

这个函数在 `Runtime::Init` 中被调用，主要负责：

1.  调用 `InvokeFinalizers()` 处理任何在初始化阶段就已排队的终结器。
2.  如果平台支持线程，则启动一个专门的终结器线程 (`FinalizerThread`)。
    *   这个线程会进入一个循环，等待一个信号量。
    *   当被唤醒时（通常是 GC 发现需要终结的对象时），它会调用 `GarbageCollector::InvokeFinalizers()` 来执行这些对象的终结器方法。
    *   该线程在 `Runtime::Shutdown` 时被停止。

### 2.3 线程初始化 (`Thread::Initialize`)

*   初始化线程系统，包括分配用于跟踪所有附加到 IL2CPP 运行时的线程的内部数据结构。

### 2.4 终结器线程 (`FinalizerThread`)

*   这是一个独立运行的后台线程。
*   它通过 `vm::Thread::Attach` 附加到 IL2CPP 运行时。
*   在一个 `while` 循环中运行，循环内部首先等待信号量 (`m_FinalizerSemaphore.Wait()`)。
*   一旦被信号量唤醒，它就会调用 `GarbageCollector::InvokeFinalizers()` 来处理那些需要执行终结器的对象。
*   当 `Runtime::Shutdown` 被调用时，该线程会被通知停止运行。

## 3. 总结

IL2CPP 的初始化流程始于 `Runtime::Init`，它按特定顺序初始化了运行时所需的各个核心组件：OS抽象层、元数据、GC、线程、核心类型、反射等。其中，GC 的初始化会启动一个关键的终结器线程，用于异步处理对象的清理工作。整个初始化流程确保了 IL2CPP 运行时环境在执行任何用户托管代码之前是正确且完备的。