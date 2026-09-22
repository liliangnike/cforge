# CForge Interview Guide

Use this as a checklist. For every topic: **definition → example in this repo → common trap → follow-up question**.

## Week 1 — Language core

### 1. Memory model
- Stack vs heap vs static/data vs code.
- In this repo: `cf_arena` (heap region, bump pointer), `cf_pool` (fixed slots), `cf_vec` (`realloc`).
- Trap: returning a pointer to a local array.
- Ask yourself: what is the lifetime of this pointer? Who frees it?

### 2. Pointers and arrays
- `a[i]` is `*(a + i)`. Arrays decay to pointers except with `sizeof`, `&`, and string literals in some contexts.
- `cf_strview` is pointer + length (does **not** decay, does **not** need NUL).
- Trap: `sizeof` on a function parameter that looks like an array.

### 3. `const`, `restrict`, `volatile`
- `const char *` vs `char * const`.
- `volatile` is for memory-mapped I/O and signal flags — **not** for threading. Threading uses atomics / mutexes (`cf_ringbuf`, `cf_conc`).
- Trap: using `volatile` to “fix” data races.

### 4. Structs, unions, padding, alignment
- `cf_arena_alloc(..., align)` and `_Alignof(max_align_t)` in the pool.
- `CF_CONTAINER_OF` / `offsetof` for intrusive lists.
- Trap: assuming bit-field layout is portable (`cf_packed_flags` is a warning, not a protocol).

### 5. Preprocessor
- Include guards, `CF_STRINGIFY`, `CF_CONCAT`, X-macros in `cf_status.h`.
- Trap: unsafe function-like macros (`#define MAX(a,b) ((a)>(b)?(a):(b))` evaluates twice).

### 6. Undefined behavior you must be able to name
- Use after free, double free, buffer overflow, signed overflow, strict aliasing, data races, shifting past width, `NULL` deref.
- This code avoids aliasing punning by using `memcpy` (`cf_load_le32`).
- Midpoint `lo + (hi - lo) / 2` in `cf_bsearch_int` avoids `lo + hi` overflow.

## Week 2 — Data structures (whiteboard in C)

| Structure | File | What to recite |
| --- | --- | --- |
| Dynamic array | `cf_vec.c` | amortized O(1) push, doubling, `memmove` on insert |
| Intrusive list | `cf_list.c` | O(1) splice, no node malloc, `container_of` |
| Hash map | `cf_hashmap.c` | FNV-1a, open addressing, tombstones, 0.75 load, rehash |
| BST | `cf_tree.c` | insert/find, CLRS delete (0/1/2 children), inorder |
| Binary heap | `cf_heap.c` | array as complete tree, sift-up/down, comparator fn ptr |
| Ring buffer | `cf_ringbuf.c` | power-of-two mask, SPSC atomics acquire/release |

Whiteboard drills (implement on paper, then in `exercises/`):

1. Reverse a singly linked list (`cf_list_reverse`).
2. Detect a cycle (Floyd) (`cf_list_has_cycle`).
3. Merge two sorted lists.
4. Binary search (careful with midpoint).
5. Hash map `get`/`put`/`del` with linear probing.

## Week 3 — Systems C

### Allocators
- Arena: great for request/parse lifetimes; cannot free one object.
- Pool: great for same-size nodes (list/tree intern).
- Interview: “implement malloc” is usually “describe free lists, splitting, coalescing, alignment, fragmentation.”

### I/O and endianness
- `fopen` modes, `fread` short counts, always check return values.
- On-disk integers are little-endian via `cf_htole32` — never dump a struct.

### Concurrency
- Mutex + condvar recipe in `cf_threadpool.c`: wait while queue empty AND not stopping.
- Shutdown: set flag, broadcast, join.
- Atomics: `memory_order_release` on publish, `acquire` on observe (`cf_ringbuf`).
- Traps: forgotten unlock (use a consistent lock/unlock pairing), deadlock (lock order), lost wakeup (check predicate in a loop).

### Networking
- `socket → bind → listen → accept`.
- `send`/`recv` may transfer **partial** data — `cf_tcp_send_all` loops.
- Trap: assuming one `recv` equals one application message (we read lines).

### Parsing
- Lexer is a finite state machine walking a `const char *`.
- Never scan with `strtok` on a shared buffer in threads.

## Week 4 — Professional habits & interview talk track

### API design
- Opaque type + `create`/`destroy`.
- `cf_status` for recoverable errors; `NULL` only when returning a new object that failed to allocate.
- Out-parameters (`void **out`) when you need both status and a value.

### What to say in interviews
- “Keys are copied; values are owned by the map; `cf_kv_set` replaces and frees the old value.”
- “The hashmap stores tombstones so linear probing still finds keys after delete.”
- “The ring buffer is SPSC: one producer, one consumer. MPMC would need a mutex or a different algorithm.”
- “Bit-fields are implementation-defined; I would use masks for a wire format.”

### Questions you should be able to answer cold

1. Difference between `malloc(0)`, `free(NULL)`, and `realloc(NULL, n)`.
2. Why `strcpy` is unsafe; when `strncpy` is also wrong; why `memcpy` vs `memmove`.
3. How `qsort`’s comparator must behave (strict weak order).
4. What happens if two threads write a `size_t` without a mutex or atomic.
5. How you’d find a leak (ASan, Valgrind, owner graphs).
6. How you’d make the BST a red-black tree (what extra invariants).
7. How you’d shard `cf_kv` mutexes for less contention.
8. Alignment of `double` vs `char` on 64-bit; why the pool uses `max_align_t`.
9. Difference between a data race and a race condition.
10. How `container_of` is legal (and when pointer provenance bites).

### Compiler flags to know

```text
-Wall -Wextra -Wpedantic -Wshadow -Wconversion
-fsanitize=address,undefined
-O0 -g          # debug
-O2             # typical release
```

On this Windows MinGW setup, ASan/UBSan may be limited. On Linux, rebuild tests with sanitizers:

```sh
make clean
make CFLAGS="-std=c11 -Wall -Wextra -O1 -g -fsanitize=address,undefined" \
     LDFLAGS="-pthread -fsanitize=address,undefined" test
```

### A 45-minute mock interview using this repo

1. **5 min** — “Walk me through `cf_hmap_put`.”
2. **10 min** — “Implement `cf_list_reverse` on the whiteboard.”
3. **10 min** — “The KV store is slow under 32 threads. What do you change?”
4. **10 min** — “There’s a use-after-free in `cf_kv_del`. How do you find it?”
5. **10 min** — “Design a WAL instead of full-file snapshot.”

If you can do that without looking at notes, you are in professional range.

