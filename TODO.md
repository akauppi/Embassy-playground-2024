# Todo

## Can we get to `stable`?

```
use static_cell::make_static;
```

..requires `feature(type_alias_impl_trait)` - and that's only in nightly.

- Tried to replace it with `LazyCell` (from 1.80 stable), but not capable enough in Rust..

   - [ ] Can `LazyCell` (or something stable?) be used, instead of `make_static`?

