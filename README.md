# `abc-c6`

## Developing with `stable`

```
$ cargo run --release
```

### ..with `nightly` (optional)

```
$ cargo +nightly-2024-06-01 run --features nightly --release
```

>Note: For the moment, one needs to have `nightly` < 2024-06-13 (or perhaps the patch for `embassy-executor-macros`). [source](https://github.com/ch32-rs/ch32-hal/issues/29)

