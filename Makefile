
CC := clang-16
LD := ld.lld-16
OBJCOPY := llvm-objcopy-16
CFLAGS := --target=riscv64 -march=rv64imc_zba_zbb_zbc_zbs \
	-fPIC -O2 -fno-builtin -nostdinc -nostdlib -fvisibility=hidden -fdata-sections -ffunction-sections \
	-I test-contracts/ckb-c-stdlib -I test-contracts/ckb-c-stdlib/libc -I test-contracts/ckb-c-stdlib/molecule \
	-Wall -Werror -Wno-nonnull -Wno-unused-function

LDFLAGS := -nostdlib -static -Wl,--gc-sections

BUILDER_DOCKER := xujiandong/ckb-riscv-llvm-toolchain@sha256:6409ab0d3e335c74088b54f4f73252f4b3367ae364d5c7ca7acee82135f5af4d

all-via-docker:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make -f Makefile all"

all: test_bin


test_bin: test-contracts/main.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

fmt:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd code && clang-format -i -style=Google test-contracts/main.c test-contracts/new_syscalls.h"

clean:
	rm -f test_bin

test:
	RUST_LOG=info cargo test test_single_dag -- --nocapture
