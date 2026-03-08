# Elsewhere

A tiny macOS menu bar app that shows the time elsewhere in the world.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black) ![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## What it does

Elsewhere sits in your menu bar and passively displays the current time in a city of your choice. Built for remote workers, digital nomads, and anyone who works across timezones.

```
🇦🇪 7:42 PM
```

Click to see all your clocks, plan meetings across zones, switch cities, and more.

## Features

**Menu bar**
- Flag + time display (customizable: flag only, city + time, or time only)
- Respects your system's 12/24h setting automatically
- Updates every minute, aligned to minute boundaries

**World clock dropdown**
- See all your selected cities at a glance
- UTC offset and relative time difference (+3h, -5h) for each city
- Tomorrow/Yesterday indicator when a city is on a different date
- Click any city to make it the primary; click the primary to copy its time

**Meeting planner**
- Automatically shows overlapping working hours (9–5) between your primary city and each other selected city
- Helps you find the best time to schedule across zones

**Productivity**
- 28 curated cities across 4 regions
- Add/remove cities from grouped submenus
- Remembers everything between launches
- Launch at Login toggle
- No Dock icon — lives entirely in the menu bar
- Lightweight single binary, no dependencies

## Supported Cities

| Region | Cities |
|--------|--------|
| Americas | New York, Los Angeles, Chicago, Toronto, Sao Paulo, Mexico City, Buenos Aires |
| Europe | London, Paris, Berlin, Amsterdam, Istanbul, Moscow |
| Middle East & Africa | Dubai, Riyadh, Cairo, Lagos, Nairobi |
| Asia & Oceania | Mumbai, Singapore, Hong Kong, Shanghai, Tokyo, Seoul, Bangkok, Jakarta, Sydney, Auckland |

DST is handled automatically via IANA timezone identifiers.

## Install

```bash
git clone https://github.com/imaadmalikkk/Elsewhere.git
cd Elsewhere
bash build.sh
cp -r Elsewhere.app ~/Applications/
open ~/Applications/Elsewhere.app
```

Requires Xcode Command Line Tools (`xcode-select --install`).

## Build

```bash
bash build.sh
```

Produces `Elsewhere.app` in the project root.

## Test

```bash
swift test
```

37 tests covering timezone data integrity, UTC offset formatting, relative time differences, day boundary detection, meeting planner overlap calculations, and display format options.

## License

MIT
