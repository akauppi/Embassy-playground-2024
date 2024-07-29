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


## Troubleshooting

### USB errors

If you get USB errors:

```
Caused by:
    0: USB Communication Error
```    

- reset the devkit by:

	- **pushing both buttons**
	- **release the RESET button**
	- **then release the other button**

- reconnect the USB/IP connection:

	- RPi: `usbipd bind -b 1-1.2`
	- VM: `usbip attach -r 192.168.1.199 -b 1-1.2`

	>Obviously, you'll need to use the IP and bus-id that apply to your system.
	>
	>There are ways to make a board automatically rebind on the host side; this is not covered here. Windows `usbipd` seems to rebind automatically.

- and try again.


<details><summary>Sample error case</summary>

```
$ make run
probe-rs run --chip esp32c6 target/riscv32imac-unknown-none-elf/release/app
      Erasing ✔ [00:00:01] [###############################################################################################################] 128.00 KiB/128.00 KiB @ 71.85 KiB/s (eta 0s )
  Programming ✔ [00:00:12] [##################################################################################################################] 26.10 KiB/26.10 KiB @ 2.12 KiB/s (eta 0s )    Finished in 15.477s
INFO  RWDT watchdog enabled!
└─ app::____embassy_main_task::{async_fn#0} @ src/bin/app.rs:47  
ERROR !! A panic occured in '/home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/esp-hal-embassy-0.2.0/src/time_driver/mod.rs', at line 102, column 42:
└─ esp_backtrace::panic_handler @ /home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/esp-backtrace-0.13.0/src/lib.rs:29  
ERROR "panicked at /home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/esp-hal-embassy-0.2.0/src/time_driver/mod.rs:102:42:\ncalled `Option::unwrap()` on a `None` value"
└─ esp_backtrace::panic_handler @ /home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/esp-backtrace-0.13.0/src/lib.rs:29  
ERROR Backtrace:
└─ esp_backtrace::panic_handler @ /home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/esp-backtrace-0.13.0/src/lib.rs:29  
ERROR No backtrace available - make sure to force frame-pointers. (see https://crates.io/crates/esp-backtrace)
└─ esp_backtrace::panic_handler @ /home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/esp-backtrace-0.13.0/src/lib.rs:29  
 WARN probe_rs::session: Could not clear all hardware breakpoints: An error with the usage of the probe occurred

Caused by:
    0: USB Communication Error
    1: endpoint STALL condition
thread 'main' panicked at probe-rs/src/probe/espusbjtag/protocol.rs:375:37:
range end index 77 out of range for slice of length 64
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
make: *** [Makefile:53: run] Error 101
```
</details>

### Remote USB/IP not listed

```
$ usbip list -r 192.168.1.199
usbip: info: no exportable devices found on 192.168.1.199
```

- Reset the board as instructed above (both buttons; release RESET; release other).
- **RPi:**

	```
	$ sudo usbip bind -b 1-1.2
	```
- **VM:**

	```
	$ usbip list -r 192.168.1.199
	Exportable USB devices
	======================
	 - 192.168.1.199
	      1-1.2: unknown vendor : unknown product (303a:1001)
	           : /sys/devices/platform/soc/3f980000.usb/usb1/1-1/1-1.2
	           : Miscellaneous Device / ? / Interface Association (ef/02/01)
	```

That's it.


