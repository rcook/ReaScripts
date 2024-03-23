# Tempo mapping

## Recommended keyboard shortcuts

This is a good set of shortcuts for navigation and creating markers during
tempo mapping of a whole song:

| Shortcut           | Description                                                 | Type    |
| ---                | ---                                                         | ---     |
| _{_                | Loop points: Set start point                                | Default |
| _}_                | Loop points: Set end point                                  | Default |
| _Tab_              | Item navigation: Move cursor to next transient in items     | Default |
| _Shift+Tab_        | Item navigation: Move cursor to previous transient in items | Default |
| _[_                | Markers: Go to previous marker/project start                | Default |
| _]_                | Markers: Go to next marker/project end                      | Default |
| _Ctrl+Shift+[_     | Move edit cursor to start of current measure                | Custom  |
| _Ctrl+Shift+]_     | Move edit cursor to start of next measure                   | Custom  |
| _Ctrl+Shift+,_     | Move edit cursor back one beat                              | Custom  |
| _Ctrl+Shift+._     | Move edit cursor forward one beat                           | Custom  |
| _Ctrl+Alt+Shift+M_ | Options: Toggle metronome                                   | Custom  |
| _Alt+Shift+0_      | Script: rcook_Mark_Measure.lua                              | Custom  |
| _Alt+Shift+1_      | Script: rcook_Mark_Measure_1_4.lua                          | Custom  |
| _Alt+Shift+2_      | Script: rcook_Mark_Measure_2_4.lua                          | Custom  |
| _Alt+Shift+3_      | Script: rcook_Mark_Measure_3_4.lua                          | Custom  |
| _Alt+Shift+4_      | Script: rcook_Mark_Measure_4_4.lua                          | Custom  |
| _Alt+Shift+5_      | Script: rcook_Mark_Measure_5_4.lua                          | Custom  |
| _Alt+Shift+6_      | Script: rcook_Mark_Measure_6_8.lua                          | Custom  |

_Default_ shortcuts are factory-default REAPER keyboard bindings. You'll have to set up the _Custom_ using the _Actions_ window. The _Custom_ shortcuts listed here are just my personal preferences.

## Overview

* Enable _Editing Behavior_ \| _Transient detection_ \| _Tab through MIDI notes_
  * This is particularly useful if you have MIDI drums
  * _Tab_ and _Shift+Tab_ can then be used to easily move the edit cursor through the song's downbeats
* Run `rcook_Set_Project_Timebases.lua` to change project and MIDI item timebases to fix the position and duration of all media items in the project prior to marking up tempo and time signatures
* Navigate through song's measures, beats and transients using keyboard shortcuts
* Set the start of a measure using _{_ and the end using _}_
* Use `rcook_Mark_Measure.lua` et al to create tempo/time signature markers to turn this into a measure in the song's timeline
