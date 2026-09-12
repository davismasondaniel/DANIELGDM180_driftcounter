# DANIELGDM180 Drift Counter

A lightweight, standalone live drift counter HUD for FiveM. Tracks drift score, combo multiplier, slip angle, and best chain in real time, with a clean red/black DANIELGDM180-style overlay.

![logo](html/logo.png)

## Features

- **Live drift detection** — calculates slip angle from vehicle velocity vs. heading, combined with a minimum speed threshold
- **Score & combo system** — score accumulates per tick while drifting, with a combo multiplier that grows the longer you chain a drift
- **Best chain tracking** — tracks your best single-drift chain per session
- **Auto show/hide HUD** — HUD appears automatically when you're in the driver's seat of a vehicle, and hides when you exit or are a passenger
- **Pause menu aware** — HUD hides cleanly while the pause menu / map is open
- **Toggleable** — enable/disable the whole system with a chat command or keybind

## Requirements

- FiveM server (`fxserver`)
- No external dependencies — fully standalone

## Installation

1. Copy the resource folder into your server's `resources` directory.
2. Add the following to your `server.cfg`:
   ```
   ensure DANIELGDM180_driftcounter
   ```
3. Restart your server or run `refresh` + `start DANIELGDM180_driftcounter` in the server console.

## Usage

| Action | Default |
|---|---|
| Toggle drift counter | `/driftcounter` chat command |
| Toggle via keybind | Unbound by default — set in **Settings > Key Bindings > FiveM** |

Once toggled on, the HUD will automatically appear whenever you're driving a vehicle and disappear when you're not.

## Configuration

All settings live in `client/Config.lua`:

| Setting | Description | Default |
|---|---|---|
| `command` | Chat command to toggle the HUD | `driftcounter` |
| `minAngle` | Minimum slip angle (degrees) to register as a drift | `12.0` |
| `minSpeed` | Minimum speed (mph) required to register as a drift | `15.0` |
| `scorePerTick` | Base score awarded per tick while drifting | `8` |
| `comboDecayTime` | Time (ms) with no drift before the combo resets | `1500` |
| `comboGainPerTick` | Combo multiplier gained per tick while drifting | `0.015` |
| `comboMax` | Maximum combo multiplier | `10.0` |
| `tickMs` | HUD/score update frequency (ms) | `100` |
| `toggleKey` | Default keybind for toggling the HUD | *(unbound)* |

## File Structure

```
DANIELGDM180_driftcounter/
├── client/
│   └── main.lua         # Drift detection, scoring, and NUI messaging
├── config.lua           # All tunable settings
├── html/
│   ├── index.html        # HUD markup
│   ├── style.css         # HUD styling
│   ├── script.js          # NUI message handling
│   └── logo.png            # Brand logo
└── fxmanifest.lua
```

## How It Works

Each tick, the script compares the vehicle's velocity direction to its heading to calculate a slip angle. If that angle exceeds `minAngle` and speed exceeds `minSpeed`, the player is considered to be drifting:

- Score increases by `scorePerTick × combo`, rounded down
- Combo increases by `comboGainPerTick` per tick, capped at `comboMax`
- The current chain's score is tracked and compared against the session's best chain

If the player stops drifting for longer than `comboDecayTime`, the combo resets to `1.0` and the current chain resets to `0`.

## Credits

Developed by **DANIELGDM180** for the **DANIELGDM180 Server** FiveM server.

## License

All rights reserved — internal use for DANIELGDM180 unless otherwise licensed.
