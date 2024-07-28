# Embassy Playground 2024

Using [Embassy](https://embassy.dev) on ESP32-C3 and -C6 targets, in 2024.

## Background

Based on [`jessebraham/esp-hal-template`](https://github.com/jessebraham/esp-hal-template), but:

- supports `stable` in addition to `nightly` toolchain
- not a template repo, but a normal one

The idea is to support two kinds of targets:

- [`ESP32-C3-DevkitC-02`](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkitc-02/user_guide.html) with [JTAG/USB cable soldered on](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-guides/jtag-debugging/configure-builtin-jtag.html)
- [`ESP32-C6-DevKitM-1`](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c6/esp32-c6-devkitm-1/user_guide.html) (with a dedicated JTAG/USB connector)


## Requirements

Follow [ESP32-Mac](https://github.com/lure23/ESP32-Mac) to set up:

- Multipass
- `rust-emb` VM
- USB/IP setup 

- one or more of:

   - [`ESP32-C3-DevKitC-02`](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkitc-02/user_guide.html) with a [USB cable soldered for JTAG access](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-guides/jtag-debugging/configure-builtin-jtag.html)
   - [`ESP32-C6-DevKitM-01`](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c6/esp32-c6-devkitm-1/user_guide.html)

		This one has two USB ports (and they are USB-C :)). You can use one of them for JTAG.

<!--
developed on:
- macOS 14.5
- Multipass 1.14.0
-->

## Build and run (`stable`)

```
$ cargo build --release --features=esp32c6 --target=riscv32imac-unknown-none-elf
```

```
$ probe-rs run --chip esp32c6 target/riscv32imac-unknown-none-elf/release/app
```


### ..with `nightly` (optional)

```
$ cargo +nightly-2024-06-01 run --features nightly,esp32c6 --release --target=riscv32imac-unknown-none-elf
```

>Note: For the moment, one needs to have `nightly` < 2024-06-13 (or perhaps the patch for `embassy-executor-macros`). [source](https://github.com/ch32-rs/ch32-hal/issues/29)

Running as above.

