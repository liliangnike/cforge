# CForge — Professional C Interview Laboratory

A small systems library plus a thread-safe key-value store. You study **real C**, not toy snippets: memory, pointers, data structures, concurrency, I/O, sockets, and undefined-behavior hygiene.

The goal is to take your C from “I can write a program” to the level interviewers expect for systems, embedded, networking, and infrastructure roles.

## What you will practice

| Area | Where |
| --- | --- |
| Preprocessor, X-macros, `container_of` | `include/cforge/cf_macros.h`, `cf_status.h` |
| Opaque types, alignment, arenas, pools | `cf_arena`, `cf_pool` |
| Bit ops, endianness, bit-fields, bitsets | `cf_bits` |
| String views, buffers, overflow-safe parse | `cf_str` |
| Dynamic arrays, intrusive lists, hash maps, BST, heaps, ring buffers | `cf_vec` … `cf_ringbuf` |
| File I/O, binary serialization | `cf_io` |
| pthreads, mutex/cond, thread pool, C11 atomics | `cf_conc`, `cf_threadpool`, `cf_ringbuf` |
| TCP sockets | `cf_net` |
| Lexer / state machine | `cf_parse` |
| Classic pointer algorithms | `cf_algo` |
| Capstone: thread-safe KV + snapshot + CLI/TCP | `cf_kv`, `apps/cforge.c` |

## Build

You need a C11 compiler (**gcc** or **clang**) and **pthread**. GNU **make** is the Linux/macOS path; Windows can use `build.ps1` if `make` is missing.

### Linux / macOS

```sh
# Debian/Ubuntu if gcc/make are not installed yet:
sudo apt install build-essential

make all
```

Useful targets:

```sh
make test    # build and run unit tests
make demo    # build/cforge_demo
make app     # build/cforge
make clean
```

Sanitizer build (recommended while studying):

```sh
make clean
make CFLAGS="-std=c11 -Wall -Wextra -O1 -g -fsanitize=address,undefined" \
     LDFLAGS="-pthread -fsanitize=address,undefined" test
```

### Windows (MinGW-w64, posix threads)

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

If GNU make is installed:

```text
make all
```

## Run

Linux / macOS:

```sh
./build/cforge_demo          # guided tour of the library
./build/cforge_test          # unit tests
./build/cforge               # REPL
./build/cforge --serve 7379  # TCP server
```

Windows:

```powershell
.\build\cforge_demo.exe
.\build\cforge_test.exe
.\build\cforge.exe
.\build\cforge.exe --serve 7379
```

Binaries produced:

- `cforge_test` — unit tests
- `cforge_demo` — module walkthrough
- `cforge` — interactive KV CLI / TCP server

REPL example:

```text
> SET name "Ada Lovelace"
OK
> GET name
Ada Lovelace
> LIST
name=Ada Lovelace
> SAVE build\store.bin
OK
> QUIT
```

TCP (another terminal):

```text
./build/cforge --serve 7379          # Linux / macOS
.\build\cforge.exe --serve 7379      # Windows
```

Then connect with any TCP client and type the same commands.

## How to study (recommended order)

Do not skim the whole tree. Work **one module per sitting**:

1. Read the header comments (they name the interview topics).
2. Read the `.c` implementation. Trace every pointer.
3. Run the matching tests in `tests/test_all.c`.
4. Close the `.c` file and reimplement it from the header (see `exercises/EXERCISES.md`).
5. Compare your version with `src/`.
6. Recite the “why” out loud: complexity, ownership, failure modes, undefined behavior.

Suggested four-week plan is in [`INTERVIEW_GUIDE.md`](INTERVIEW_GUIDE.md).

## Layout

```text
include/cforge/   public headers (APIs + interview notes)
src/              implementations
tests/            unit tests
apps/             demo walkthrough + KV CLI/server
exercises/        reimplementation drills
```

## Coding standard used here (steal this for interviews)

- **C11**, `-Wall -Wextra -Wpedantic`
- Status codes instead of mixing `NULL`, `errno`, and magic `-1` without a rule
- Opaque structs for owned resources (`cf_arena`, `cf_hmap`, `cf_kv`)
- Explicit ownership: who `malloc`s must `free`, or the arena/pool owns it
- `memcpy` for type punning (strict aliasing); `memmove` when overlap is possible
- Overflow-aware growth (`SIZE_MAX` checks) and overflow-aware integer parse
- Power-of-two capacities + bit masks instead of `%` in hot paths

When you walk into an interview, you should be able to open any of these files and explain every line.

