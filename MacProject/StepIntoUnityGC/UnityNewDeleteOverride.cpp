// We want to override global new/delete to use Unity's internal memory management
// The only proper place to do so is inside the main app executable (whole Unity is living inside a dylib)

#include <new>

// This is the actual implementation

extern "C" void* unity_operator_new_alloc(size_t size) noexcept;
extern "C" void* unity_operator_new_alloc_align(size_t size, size_t alignment) noexcept;
extern "C" void  unity_operator_delete_dealloc(void* p) noexcept;

// These are global new/delete we are currently overriding
// NOTE: sized delete (c++14) needs special compiler flags to be enabled, and will still go through normal operator delete if not overridden
// NOTE: new/delete with alignment specification (c++17) are currently not overridden

[[nodiscard]] __attribute__((used)) void* operator new(std::size_t size) {
    return unity_operator_new_alloc(size);
}
[[nodiscard]] __attribute__((used)) void* operator new[](std::size_t size) {
    return unity_operator_new_alloc(size);
}
__attribute__((used)) void operator delete(void* p) noexcept {
    unity_operator_delete_dealloc(p);
}
__attribute__((used)) void operator delete[](void* p) noexcept {
    unity_operator_delete_dealloc(p);
}

[[nodiscard]] __attribute__((used)) void* operator new(std::size_t size, const std::nothrow_t&) noexcept {
    return unity_operator_new_alloc(size);
}
[[nodiscard]] __attribute__((used)) void* operator new[](std::size_t size, const std::nothrow_t&) noexcept {
    return unity_operator_new_alloc(size);
}
__attribute__((used)) void operator delete(void* p, const std::nothrow_t&) noexcept {
    unity_operator_delete_dealloc(p);
}
__attribute__((used)) void operator delete[](void* p, const std::nothrow_t&) noexcept {
    unity_operator_delete_dealloc(p);
}

