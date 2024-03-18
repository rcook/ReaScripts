# RRX&mdash;Richard's REAPER Extensions

Released under [MIT License](LICENSE)

## Install in REAPER using ReaPack

1. Start REAPER
2. Go to _Extensions_ | _ReaPack_ | _Manage repositories..._
3. Click on _Import/export..._
4. Click on _Import repositories..._
5. Enter [https://github.com/rcook/rrx/raw/main/index.xml](https://github.com/rcook/rrx/raw/main/index.xml)
6. Click _OK_

## Tempo mapping

### Keyboard shortcuts

| Shortcut         | Description                                  | Type   |
| ---              | ---                                          | ---    |
| {                | Loop points: Set start point                 |        |
| }                | Loop points: Set end point                   |        |
| Tab              | Item navigation: Move cursor to next transient in items     |   |
| Shift+Tab        | Item navigation: Move cursor to previous transient in items |   |
| [                | Markers: Go to previous marker/project start |        |
| ]                | Markers: Go to next marker/project end       |        |
| Ctrl+Shift+[     | Move edit cursor to start of current measure | Custom |
| Ctrl+Shift+]     | Move edit cursor to start of next measure    | Custom |
| Ctrl+Shift+,     | Move edit cursor back one beat               | Custom |
| Ctrl+Shift+.     | Move edit cursor forward one beat            | Custom |
| Ctrl+Alt+Shift+M | Options: Toggle metronome                    | Custom |
| Alt+Shift+0      | Script: rrx_MarkMeasure.lua                  | Custom |
| Alt+Shift+1      | Script: rrx_MarkMeasure_1_4.lua              | Custom |
| Alt+Shift+2      | Script: rrx_MarkMeasure_2_4.lua              | Custom |
| Alt+Shift+3      | Script: rrx_MarkMeasure_3_4.lua              | Custom |
| Alt+Shift+4      | Script: rrx_MarkMeasure_4_4.lua              | Custom |
| Alt+Shift+5      | Script: rrx_MarkMeasure_5_4.lua              | Custom |
| Alt+Shift+6      | Script: rrx_MarkMeasure_6_8.lua              | Custom |

## Developer information

See [ReaPack dev thread][reapack-dev-thread] for developer information

[reapack-dev-thread]: https://forum.cockos.com/showthread.php?t=258538
