# Track

## Embassy incompatibility with `nightly` >= `2024-06-13`

- [ ] ["Can not build on nightly rust [...]"](https://github.com/ch32-rs/ch32-hal/issues/29)

	Once solved, remove the mention of nightly version in `README`.
	
- [ ] ["macro expansion broken on latest nightly (2024-06-13)"](https://github.com/ch32-rs/ch32-hal/issues/29)

	"Next crates.io release will include the fix."
	
	= that would be anything > 0.4.1 [link](https://crates.io/crates/embassy-executor-macros)
	

## `C3` "difficulties"	

---
Root cause is likely: 

- [Support for targets without native atomics](https://github.com/knurling-rs/defmt/issues/597) (`defmt` GitHub Issues; opened 2021)

	>*Ideally Rust should expose load/store atomics on riscv32-imc* [source](https://github.com/probe-rs/rtt-target/pull/21#issuecomment-1453858641)
	
	- [ ] What is `+forced-atomics` Rust feature?

Related:

- ["How should we expose atomic load/store on targets that don't support full atomics"](https://github.com/rust-lang/rust/issues/99668) (`rust-lang` GitHub; open since Jul'22)	

	In... short:
	
	- `riscv32imc` doesn't have "CAS" (compare-and-swap) atomics, but any aligned loads/stores *are* atomic

---

Described in [Issue #1](https://github.com/akauppi/Embassy-playground-2024/issues/1).

- [ ] ["Strange RTT issues on ESP32C3 when using embassy"](https://github.com/probe-rs/probe-rs/issues/1939) (`probe-rs` Github Issue)

	>*After further investigation, it is the call to `core::arch::asm!("wfi")`.*

	<p />
	>*Another thing to note is that the USB device is dependent on both the PLL for the 48 MHz USB PHY clock, as well as APB_CLK. Specifically, an APB_CLK of 40 MHz or more is required for proper USB compliant operation, although the USB device will still function with most hosts with an APB_CLK as low as 10 MHz.*

	A dedicated JTAG device might work better; worth a try if C3 debugging really is needed!
	
	- [ ] ["Debugging and flashing are unstable if using wfi [...]"](https://github.com/probe-rs/probe-rs/issues/350)

		Sister / parallel issue, though mentions only STM32 in its title.
		
<!-- whisper
I don't want to directly link to that outside issue, from this repo (i.e. expose I'm working on this).
-->

