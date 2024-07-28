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
	cargo run --release --features=$(CHIP) --target=$(TARGET)

build-with-nightly:
	cargo +nightly-2024-06-01 run --features nightly,$(CHIP) --release --target=$(TARGET)

run-with-stable:
	cargo run --release --bin $(notdir $(_RELEASE_TARGET)) --features $(CHIP) --target $(TARGET)

run-with-nightly:
	cargo +nightly-2024-06-01 run --release --bin $(notdir $(_RELEASE_TARGET)) --features $(CHIP) --target $(TARGET)

clean:
	-rm -rf target/$(TARGET)

echo:
	@echo $(CHIP) $(TARGET)

#---
.PHONY: all build-with-stable build-with-nightly run-with-stable run-with-nightly echo
