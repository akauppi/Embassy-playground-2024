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
  $(error Unknown 'CHIP': "$(CHIP)")
endif

_APP:=app
--RELEASE:=--release

ifeq (,$(--RELEASE))
_APP_BIN:=target/$(TARGET)/debug/$(_APP)
else
_APP_BIN:=target/$(TARGET)/release/$(_APP)
endif

all:
	@false

build-with-stable:
	cargo build $(--RELEASE) --bin $(_APP) --features=$(CHIP) --target=$(TARGET)

build-with-nightly:
	cargo +nightly-2024-06-01 build --features nightly,$(CHIP) $(--RELEASE) --target=$(TARGET)

# Note: We deliberately don't use 'cargo run' because (a) had a problem with it, (b) it's rather slow in re-checking
#		all the code, (c) this direct approach gives more explicit feel of what's taking place.

$(_APP_BIN): src/lib.rs src/bin/*.rs Makefile Cargo.toml .cargo/config.toml
	@$(MAKE) CHIP=$(CHIP) build-with-stable
	@test -f $@

run: $(_APP_BIN)
ifeq ($(CHIP),esp32c3)
	$(warn DEFMT logs are known NOT TO SHOW on ESP32-C3)
endif
	probe-rs run --chip $(CHIP) $<

run-with-espflash: $(_APP_BIN)
ifeq ($(CHIP),esp32c3)
	$(warn DEFMT logs are known NOT TO SHOW on ESP32-C3)
endif
	espflash flash --monitor $<

echo:
	@echo $(CHIP) $(TARGET) $(--RELEASE)

#---
.PHONY: all build-with-stable build-with-nightly run run! echo
