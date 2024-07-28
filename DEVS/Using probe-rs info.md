# Using `probe-rs info`

With both `esp32c3` and `esp32c6`, we get this:

```
$ probe-rs info --chip=esp32c6
Probing target via JTAG

No DAP interface was found on the connected probe. ARM-specific information cannot be printed.
RISC-V Chip:
  IDCODE: 0000000000
    Version:      0
    Part:         0
    Manufacturer: 0 (Unknown Manufacturer Code)
Xtensa Chip:
  IDCODE: 0000000000
    Version:      0
    Part:         0
    Manufacturer: 0 (Unknown Manufacturer Code)

Probing target via SWD

Error identifying target using protocol SWD: The probe does not support the SWD protocol.

```

It doesn't look like valid data. Keep trying every now and then - what is expected to be here?

