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
  _DEFMT_OR_PRINTLN:=defmt
else ifneq (,$(findstring $(CHIP),esp32c6 ..))
  TARGET:=riscv32imac-unknown-none-elf
  _DEFMT_OR_PRINTLN:=defmt
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

null  :=
space := $(null) #
comma := ,

_FEATURES_CSL := $(subst $(space),$(comma),$(strip $(CHIP) $(_DEFMT_OR_PRINTLN)))
	# comma separated

all:
	@false

build-with-stable:
	cargo build $(--RELEASE) --bin $(_APP) --features=$(_FEATURES_CSL) --target=$(TARGET)

# Works.
# Provides some benefits, e.g. 'embassy-executor':
#	<<
#		If tasks don't fit in RAM, this is detected at compile time by the linker. Runtime panics due to running out
#		of memory are not possible.
#	<<
#
build-with-nightly:
	cargo +nightly-2024-06-01 build $(--RELEASE) --bin $(_APP) --features nightly,$(_FEATURES_CSL) --target=$(TARGET)

# Note: We deliberately don't use 'cargo run' because (a) had a problem with it, (b) it's rather slow in re-checking
#		all the code, (c) this direct approach gives more explicit feel of what's taking place.

$(_APP_BIN): src/lib.rs src/bin/*.rs Makefile Cargo.toml .cargo/config.toml
	@$(MAKE) CHIP=$(CHIP) build-with-stable
	@test -f $@

run: $(_APP_BIN)
ifeq ($(CHIP),esp32c3)
	$(warn 'probe-rs run' isn't compatible with $(CHIP))
endif
	probe-rs run --chip $(CHIP) $<

#run-with-espflash: $(_APP_BIN)
#	espflash flash --monitor $<

echo:
	@echo $(CHIP) $(TARGET) $(--RELEASE) $(_FEATURES_CSL)

#---
.PHONY: all build-with-stable build-with-nightly run run! echo
