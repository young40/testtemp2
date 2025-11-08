# Makefile for building GameAssembly.dylib

# Variables
CC = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++
SDKROOT = /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.sdk
ARCH = arm64
MIN_MACOS_VERSION = 11.0
OUTPUT_DIR = Il2CppTempDirArtifacts/Debug/artifacts/arm64/9420
SOURCE_DIR = MacProject/Il2CppOutputProject/Source/il2cppOutput
IL2CPP_DIR = MacProject/Il2CppOutputProject/IL2CPP
LIB_DIR = MacProject/Libraries

# Common flags
CPPFLAGS = -std=c++17 -Wswitch -Wno-trigraphs -Wno-tautological-compare -Wno-invalid-offsetof \
         -Wno-implicitly-unsigned-literal -Wno-integer-overflow -Wno-shift-negative-value \
         -Wno-unknown-attributes -Wno-implicit-function-declaration -Wno-null-conversion \
         -Wno-missing-declarations -Wno-unused-value -Wno-pragma-once-outside-header \
         -Wno-unknown-warning-option -Wno-undef-prefix -fvisibility=hidden -isysroot "$(SDKROOT)" \
         -fexceptions -frtti -g -O0 -fno-strict-overflow -ffunction-sections -fdata-sections \
         -fmessage-length=0 -pipe -DBASELIB_INLINE_NAMESPACE=il2cpp_baselib \
         -DIL2CPP_MONO_DEBUGGER_DISABLED -DRUNTIME_IL2CPP -DTARGET_$(ARCH) \
         -DIL2CPP_ENABLE_WRITE_BARRIERS=1 -DIL2CPP_INCREMENTAL_TIME_SLICE=3 -DIL2CPP_DEBUG=1 \
         -DHAVE_BDWGC_GC -D_DEBUG

CFLAGS = -Wswitch -Wno-trigraphs -Wno-tautological-compare -Wno-invalid-offsetof \
         -Wno-implicitly-unsigned-literal -Wno-integer-overflow -Wno-shift-negative-value \
         -Wno-unknown-attributes -Wno-implicit-function-declaration -Wno-null-conversion \
         -Wno-missing-declarations -Wno-unused-value -Wno-pragma-once-outside-header \
         -Wno-unknown-warning-option -Wno-undef-prefix -fvisibility=hidden -isysroot "$(SDKROOT)" \
         -fexceptions -g -O0 -fno-strict-overflow -ffunction-sections -fdata-sections \
         -fmessage-length=0 -pipe -DBASELIB_INLINE_NAMESPACE=il2cpp_baselib \
         -DIL2CPP_MONO_DEBUGGER_DISABLED -DRUNTIME_IL2CPP -DTARGET_$(ARCH) \
         -DIL2CPP_ENABLE_WRITE_BARRIERS=1 -DIL2CPP_INCREMENTAL_TIME_SLICE=3 -DIL2CPP_DEBUG=1 \
         -DHAVE_BDWGC_GC -D_DEBUG

INCLUDES = -I"." -I"$(SOURCE_DIR)" -I"$(IL2CPP_DIR)/libil2cpp/pch" -I"$(IL2CPP_DIR)/libil2cpp" \
           -I"$(IL2CPP_DIR)/external/baselib/Include" \
           -I"$(IL2CPP_DIR)/libil2cpp/os/ClassLibraryPAL/brotli/include" \
           -I"$(IL2CPP_DIR)/external/baselib/Platforms/OSX/Include" \
					 -I"$(IL2CPP_DIR)/libil2cpp/pch"

LDFLAGS = -std=c++17 -Wswitch -Wno-trigraphs -Wno-tautological-compare -Wno-invalid-offsetof \
          -Wno-implicitly-unsigned-literal -Wno-integer-overflow -Wno-shift-negative-value \
          -Wno-unknown-attributes -Wno-implicit-function-declaration -Wno-null-conversion \
          -Wno-missing-declarations -Wno-unused-value -Wno-pragma-once-outside-header \
          -Wno-unknown-warning-option -Wno-undef-prefix -fvisibility=hidden -isysroot "$(SDKROOT)" \
          -fexceptions -frtti -g -O0 -fno-strict-overflow -ffunction-sections -fdata-sections \
          -fmessage-length=0 -pipe

# Automatically generate source file list
SOURCES := $(shell find $(SOURCE_DIR) -name "*.cpp" -o -name "*.c")

# Object files
OBJECTS = $(SOURCES:$(SOURCE_DIR)/%.cpp=$(OUTPUT_DIR)/%.o) $(SOURCES:$(SOURCE_DIR)/%.c=$(OUTPUT_DIR)/%.o)

# Default target
all: $(OUTPUT_DIR)/pch-c-764564960109082866.pch $(OUTPUT_DIR)/pch-cpp-8516765050462871105.pch $(OUTPUT_DIR)/GameAssembly.dylib

# Create output directory
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Precompiled headers
$(OUTPUT_DIR)/pch-c-764564960109082866.pch: $(IL2CPP_DIR)/libil2cpp/pch/pch-c.h | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -fcolor-diagnostics -arch $(ARCH) -mmacosx-version-min=$(MIN_MACOS_VERSION) -c -x c-header $<

$(OUTPUT_DIR)/pch-cpp-8516765050462871105.pch: $(IL2CPP_DIR)/libil2cpp/pch/pch-cpp.hpp | $(OUTPUT_DIR)
	$(CC) $(CPPFLAGS) $(INCLUDES) -o $@ -fcolor-diagnostics -stdlib=libc++ -arch $(ARCH) -mmacosx-version-min=$(MIN_MACOS_VERSION) -c -x c++-header $<

# Compile source files to object files
$(OUTPUT_DIR)/%.o: $(SOURCE_DIR)/%.cpp | $(OUTPUT_DIR)/pch-cpp-8516765050462871105.pch
	$(CC) $(CPPFLAGS) -I"$(IL2CPP_DIR)/libil2cpp/pch" $(INCLUDES) -o $@ -fcolor-diagnostics -stdlib=libc++ -arch $(ARCH) -mmacosx-version-min=$(MIN_MACOS_VERSION) -c -x c++ $<

$(OUTPUT_DIR)/%.o: $(SOURCE_DIR)/%.c | $(OUTPUT_DIR)/pch-c-764564960109082866.pch
	$(CC) $(CFLAGS) -I"$(IL2CPP_DIR)/libil2cpp/pch" $(INCLUDES) -o $@ -fcolor-diagnostics -arch $(ARCH) -mmacosx-version-min=$(MIN_MACOS_VERSION) -c -x c $<

# Link object files to create GameAssembly.dylib
$(OUTPUT_DIR)/GameAssembly.dylib: $(OBJECTS) | $(OUTPUT_DIR)
	$(CC) $(LDFLAGS) -o $@ -fcolor-diagnostics -stdlib=libc++ -arch $(ARCH) -mmacosx-version-min=$(MIN_MACOS_VERSION) $(OBJECTS) -L$(LIB_DIR) -lbaselib

clean:
	rm -rf $(OUTPUT_DIR)

.PHONY: all clean
