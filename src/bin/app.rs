#![no_std]
#![no_main]
#![cfg_attr(feature = "nightly", feature(type_alias_impl_trait))]

use defmt::info;
use defmt_rtt as _;
use embassy_executor::Spawner;
use embassy_time::{Duration, Timer};
use esp_backtrace as _;
use esp_hal::{
    clock::ClockControl,
    peripherals::Peripherals,
    prelude::*,
    rtc_cntl::Rtc,
    system::SystemControl,
    timer::{timg::TimerGroup, OneShotTimer},
};
#[cfg(feature = "nightly")]
use static_cell::make_static;
#[cfg(not(feature = "nightly"))]
use {
    static_cell,
    esp_hal::timer::ErasedTimer
};

#[cfg(not(feature = "nightly"))]
// When you are okay with using a nightly compiler it's better to use https://docs.rs/static_cell/2.1.0/static_cell/macro.make_static.html
macro_rules! mk_static {
    ($t:ty,$val:expr) => {{
        static STATIC_CELL: static_cell::StaticCell<$t> = static_cell::StaticCell::new();
        #[deny(unused_attributes)]
        let x = STATIC_CELL.uninit().write(($val));
        x
    }};
}

#[main]
async fn main(spawner: Spawner) {
    let peripherals = Peripherals::take();
    let system = SystemControl::new(peripherals.SYSTEM);
    let clocks = ClockControl::boot_defaults(system.clock_control).freeze();

    // Enable the RWDT watchdog timer:
    let mut rtc = Rtc::new(peripherals.LPWR, None);
    rtc.rwdt.set_timeout(2.secs());
    rtc.rwdt.enable();
    info!("RWDT watchdog enabled!");

    // Initialize the SYSTIMER peripheral, and then Embassy:
    let timg0 = TimerGroup::new(peripherals.TIMG0, &clocks, None);
    let timers = [OneShotTimer::new(timg0.timer0.into())];

    #[cfg(feature = "nightly")]
    let timers = make_static!(timers);
    #[cfg(not(feature = "nightly"))]
    let timers = mk_static!([OneShotTimer<ErasedTimer>; 1], timers);

    esp_hal_embassy::init(&clocks, timers);
    info!("Embassy initialized!");

    // TODO: Spawn some tasks
    let _ = spawner;

    // Periodically feed the RWDT watchdog timer when our tasks are not running:
    loop {
        rtc.rwdt.feed();
        Timer::after(Duration::from_secs(1)).await;
    }
}