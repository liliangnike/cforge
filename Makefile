# C11, warnings as errors. GNU make is optional — see build.ps1 on Windows.
CC      ?= gcc
CFLAGS  ?= -std=c11 -Wall -Wextra -Wpedantic -Werror -O2 -g
CFLAGS  += -Iinclude -Iinclude/cforge
LDFLAGS ?= -pthread

ifeq ($(OS),Windows_NT)
  LDFLAGS += -lws2_32
  EXE := .exe
else
  EXE :=
endif

SRC := $(wildcard src/*.c)
OBJ := $(patsubst src/%.c,build/%.o,$(SRC))

.PHONY: all lib test demo app clean

all: lib test demo app

build:
	mkdir -p build

build/%.o: src/%.c | build
	$(CC) $(CFLAGS) -c $< -o $@

lib: build/libcforge.a

build/libcforge.a: $(OBJ)
	ar rcs $@ $(OBJ)

test: build/cforge_test$(EXE)
	./build/cforge_test$(EXE)

build/cforge_test$(EXE): tests/test_all.c build/libcforge.a
	$(CC) $(CFLAGS) tests/test_all.c -o $@ -Lbuild -lcforge $(LDFLAGS)

demo: build/cforge_demo$(EXE)

build/cforge_demo$(EXE): apps/demo.c build/libcforge.a
	$(CC) $(CFLAGS) apps/demo.c -o $@ -Lbuild -lcforge $(LDFLAGS)

app: build/cforge$(EXE)

build/cforge$(EXE): apps/cforge.c build/libcforge.a
	$(CC) $(CFLAGS) apps/cforge.c -o $@ -Lbuild -lcforge $(LDFLAGS)

clean:
	rm -rf build

