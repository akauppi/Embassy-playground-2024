#
# Usage:
#
#	<<
#	  $ [CHIP=esp32c3] make
#	<<
#
# # Why makefile?
#
# Haven't found a way to declare, using just 'cargo', that certain targets match certain chips. This means
# both '--feature=esp32c3' and '--target' need to be given. The Makefile is *just* a wrapper around the cargo
# commands; which can be used as such, if wanted.
#
# THIS MAKEFILE IS ONLY FOR DEVELOPMENT - not needed for making production builds
#
CHIP?=esp32c6
#CHIP:=esp32c3

ifneq (,$(findstring $(CHIP),esp32c3 ..))
  TARGET:=riscv32imc-unknown-none-elf
else ifneq (,$(findstring $(CHIP),esp32c6 ..))
  TARGET:=riscv32imac-unknown-none-elf
else
  $(error Unknown (or undefined) 'CHIP': "$(CHIP)")
endif

_BIN:=app

_DEBUG_TARGET:=target/$(TARGET)/debug/$(_BIN)
_RELEASE_TARGET:=target/$(TARGET)/release/$(_BIN)

all:
	@false

build-with-stable:
	cargo build --release --features=$(CHIP) --target=$(TARGET)

build-with-nightly:
	cargo +nightly-2024-06-01 build --features nightly,$(CHIP) --release --target=$(TARGET)

# Note: We deliberately don't use 'cargo run' because (a) had a problem with it, (b) it's rather slow in re-checking
#		all the code, (c) this direct approach gives more explicit feel of what's taking place.

$(_RELEASE_TARGET): src/lib.rs src/bin/*.rs Makefile Cargo.toml .cargo/config.toml
	@$(MAKE) build-with-stable
	@test -f $@

run: $(_RELEASE_TARGET)
	probe-rs run --chip $(CHIP) $(_RELEASE_TARGET)

#run!:
#	probe-rs run --chip $(CHIP) $(_RELEASE_TARGET)

clean:
	cargo clean
		@# cleans *all* targets

echo:
	@echo $(CHIP) $(TARGET)

#---
.PHONY: all build-with-stable build-with-nightly run run! echo
