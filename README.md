# RRX&mdash;Richard's REAPER Extensions

Released under [MIT License](LICENSE)

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
# ReaPack Repository Template

A template for GitHub-hosted ReaPack repositories with automated
[reapack-index](https://github.com/cfillion/reapack-index)
running from GitHub Actions.

Replace the name of the repository in [index.xml](/index.xml) when using this template.
This will be the name shown in ReaPack.

```xml
<index version="1" name="Name of your repository here">
```

Replace the contents of this file ([README.md](/README.md)).
This will be the text shown when using ReaPack's "About this repository" feature.

reapack-index looks for package files in subfolders.
The folder tree represents the package categories shown in ReaPack.

Each package file is expected to begin with a metadata header.
See [Packaging Documentation](https://github.com/cfillion/reapack-index/wiki/Packaging-Documentation) on reapack-index's wiki.

The URL to import in ReaPack is [https://github.com/`<your username>`/`<repository name>`/raw/master/index.xml](https://github.com/cfillion/reapack-repository-template/raw/master/index.xml).
