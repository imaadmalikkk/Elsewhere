# Elsewhere

A tiny macOS menu bar app that shows the time in another city.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black) ![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## What it does

Elsewhere sits in your menu bar and passively displays the current time in a city of your choice — no clicking required. Built for people who split their time between timezones and want a glanceable clock.

```
🇦🇪 7:42 PM
```

Click it to switch cities, toggle launch at login, or quit.

## Features

- **Flag + time** in the menu bar — no seconds, no clutter
- **Respects your system's 12/24h setting** automatically
- **Remembers your selection** between launches
- **Launch at Login** toggle built in
- **No Dock icon** — lives entirely in the menu bar
- **~80KB** binary, no dependencies

## Supported cities

| City | Timezone | Flag |
|------|----------|------|
| Dubai | Asia/Dubai | 🇦🇪 |
| London | Europe/London | 🇬🇧 |

DST is handled automatically via IANA timezone identifiers.

## Install

```bash
git clone https://github.com/imaadmalik/Elsewhere.git
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

## License

MIT
