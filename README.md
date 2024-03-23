# rrx&mdash;Richard's REAPER Extensions

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

<table>
<thead>
<tr>
  <td>Shortcut</td>
  <td>Description</td>
  <td>Type</td>
</tr>
</thead>
<tbody>
<tr><td><pre>{</pre></td><td>Loop points: Set start point</td><td></td></tr>
<tr><td><pre>}</pre></td><td>Loop points: Set end point</td><td></td></tr>
<tr><td><pre>Tab</pre></td><td>Item navigation: Move cursor to next transient in items</td><td></td></tr>
<tr><td><pre>Shift+Tab</pre></td><td>Item navigation: Move cursor to previous transient in items</td><td></td></tr>
<tr><td><pre>[</pre></td><td>Markers: Go to previous marker/project start</td><td></td></tr>
<tr><td><pre>]</pre></td><td>Markers: Go to next marker/project end</td><td></td></tr>
<tr><td><pre>Ctrl+Shift+[</pre></td><td>Move edit cursor to start of current measure</td><td>Custom</td></tr>
<tr><td><pre>Ctrl+Shift+]</pre></td><td>Move edit cursor to start of next measure</td><td>Custom</td></tr>
<tr><td><pre>Ctrl+Shift+,</pre></td><td>Move edit cursor back one beat</td><td>Custom</td></tr>
<tr><td><pre>Ctrl+Shift+.</pre></td><td>Move edit cursor forward one beat</td><td>Custom</td></tr>
<tr><td><pre>Ctrl+Alt+Shift+M</pre></td><td>Options: Toggle metronome</td><td>Custom</td></tr>
<tr><td><pre>Alt+Shift+0</pre></td><td>Script: rrx_MarkMeasure.lua</td><td>Custom</td></tr>
<tr><td><pre>Alt+Shift+1</pre></td><td>Script: rrx_MarkMeasure_1_4.lua</td><td>Custom</td></tr>
<tr><td><pre>Alt+Shift+2</pre></td><td>Script: rrx_MarkMeasure_2_4.lua</td><td>Custom</td></tr>
<tr><td><pre>Alt+Shift+3</pre></td><td>Script: rrx_MarkMeasure_3_4.lua</td><td>Custom</td></tr>
<tr><td><pre>Alt+Shift+4</pre></td><td>Script: rrx_MarkMeasure_4_4.lua</td><td>Custom</td></tr>
<tr><td><pre>Alt+Shift+5</pre></td><td>Script: rrx_MarkMeasure_5_4.lua</td><td>Custom</td></tr>
<tr><td><pre>Alt+Shift+6</pre></td><td>Script: rrx_MarkMeasure_6_8.lua</td><td>Custom</td></tr>
</tbody>
</table>

## Developer information

See [ReaPack dev thread][reapack-dev-thread] for developer information

[reapack-dev-thread]: https://forum.cockos.com/showthread.php?t=258538
