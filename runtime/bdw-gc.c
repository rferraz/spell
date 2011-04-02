#include "gc.h"

void spell_gc_init() {
    GC_INIT();
}

void *spell_gc_malloc(size_t size) {
    return GC_MALLOC(size);
}

void *spell_gc_malloc_atomic(size_t size) {
    return GC_MALLOC_ATOMIC(size);
}

void *spell_gc_malloc_uncollectable(size_t size) {
    return GC_MALLOC_UNCOLLECTABLE(size);
}

size_t spell_gc_heap_size() {
    return GC_get_heap_size();
}

size_t spell_gc_free_bytes() {
    return GC_get_free_bytes();
}

size_t spell_gc_bytes_since_gc() {
    return GC_get_bytes_since_gc();
}

size_t spell_gc_get_total_bytes() {
    return GC_get_total_bytes();
}
