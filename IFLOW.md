# 项目概述

这是一个Unity项目, 但包含了Unity导出的Xcode工程, 用于研究Unity的垃圾回收GC和IL2CPP的原理.

Unity的原内容在 `Assets` 目录. `MacProject/Il2CppOutputProject/Source/il2cppOutput` 是Unity工程中对应源码的导出cpp文件.
`MacProject/Il2CppOutputProject/IL2CPP` 目录包含了IL2CPP的源码.

`IL2CPP` 目录下有几个值得注意的目录. `external/bdwgc` 为垃圾回收GC的源码. `libil2cpp/gc` 是在IL2CPP下对GC的封装.
`libil2cpp` 是IC2CPP的核心源码.

## 学习规则

*   学习到的内容要记录到`docs`目录下的文件里面
*   查看新内容时，需要及时查看已经学习到的内容。这意味着在学习新知识点时，应该先回顾docs目录下已有的相关文档，以便建立知识之间的联系，避免重复学习，并在此基础上进行深入理解。
*   这个工程的重要目的还是帮助人完全掌握IL2CPP和bdwgc这两块重要内容

## 核心内容

1.  **自定义脚本 (MySIUGCScript.cs)**:
    *   位于 `Assets/Scripts/` 目录下。
    *   脚本中定义了一个简单的 `MyNode` 类。
    *   `MySIUGCScript` 类继承自 `MonoBehaviour`，在 `Start()` 方法中创建了一个 `MyNode` 实例并设置了其 `mMyNodeId` 属性。
    *   在 `OnGUI()` 方法中，使用 `GUI.Label` 在屏幕上显示文本 "Hello GC"，字体大小为 50，居中对齐，颜色为红色。
    *   这表明项目可能通过 GUI 显示信息，并可能通过 `MyNode` 的创建来触发或观察 GC 行为。

2.  **Unity 配置**:
    *   `ProjectSettings/ProjectSettings.asset` 文件包含了项目的各种设置，如产品名称、公司名称、目标平台 (Standalone)、默认屏幕分辨率等。
    *   项目似乎配置为使用 IL2CPP 脚本后端 (`scriptingBackend: Standalone: 1`)。
    *   启用了增量式 GC (`gcIncremental: 1`)。

4.  **构建输出**:
    *   `MacProject` 目录包含了针对 macOS 平台的构建输出，包括 Xcode 项目文件和编译后的 IL2CPP 输出。
    *   `Il2CppOutputProject` 目录包含了从 C# 代码生成的 C++ 代码，这是 IL2CPP 构建过程的一部分。

# 开发与构建

## 构建和运行

*   **编辑器**: 在 Unity 编辑器中直接打开项目文件夹即可进行开发和测试。
*   **构建**: 可以通过 Unity 编辑器的 Build Settings 构建项目。当前配置显示为 macOS Standalone 平台。
*   **IL2CPP 构建产物**: 构建后的 C++ 代码位于 `MacProject/Il2CppOutputProject/Source/il2cppOutput/`，其中 `MySIUGCScript.cpp` 对应了 `Assets/Scripts/MySIUGCScript.cs` 的 C++ 实现。
