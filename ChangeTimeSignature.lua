function print(param)
  reaper.ShowConsoleMsg("[" .. tostring(reaper.time_precise()) .. "] " .. tostring(param) .. "\n")
end

function error(param)
  s = tostring(param)
  print("[ERROR] " .. s)
  reaper.ReaScriptError("!" .. s)
end

function formatTime(pos)
  return reaper.format_timestr_pos(pos, "", -1)
end


-- Given a time selection, create a new measure of given number of beats


-- TODO: Check project timebase settings and MIDI source properties
-- 2.3.76 to 3.4.18

projectId = 0
leadingMeasureQns = 1
leadingMeasureQuantum = 4
newMeasureQns = 4
newMeasureQuantum = 4
trailingMeasureQns = 3
trailingMeasureQuantum = 4
dryRun = true

reaper.Help_Set('Hello World!', true)

newMeasureStartTime, newMeasureEndTime = reaper.GetSet_LoopTimeRange2(projectId, false, false, 0, 0, false)
newMeasureLength = newMeasureEndTime - newMeasureStartTime
if newMeasureLength == 0 then
  error("Invalid selection (empty)")
end

newMeasureStartQn = reaper.TimeMap2_timeToQN(projectId, newMeasureStartTime)
newMeasureEndQn = reaper.TimeMap2_timeToQN(projectId, newMeasureEndTime)

-- Measure immediately before selection
-- Measure starts at leadingMeasureStartTime and ends at newMeasureStartTime
measureNumber = reaper.TimeMap_QNToMeasures(projectId, newMeasureStartQn)
leadingMeasureStartTime, startQn, endQn, timeSigNum, timeSigDenom, tempo = reaper.TimeMap_GetMeasureInfo(projectId, measureNumber - 1)
leadingMeasureLength = newMeasureStartTime - leadingMeasureStartTime
if leadingMeasureLength == 0 then
  error("Invalid selection (no leading)")
end


-- Measure immediately after selection
-- Measure starts at newMeasureEndTime and ends at trailingMeasureEndTime
measureNumber = reaper.TimeMap_QNToMeasures(projectId, newMeasureEndQn)
trailingMeasureEndTime, startQn, endQn, timeSigNum, timeSigDenom, temp = reaper.TimeMap_GetMeasureInfo(projectId, measureNumber)
trailingMeasureLength = trailingMeasureEndTime - newMeasureEndTime
if trailingMeasureLength == 0 then
  error("Invalid selection (no trailing)")
end


leadingMeasureTempo = 240 / leadingMeasureLength / (leadingMeasureQuantum / leadingMeasureQns)
if not dryRun then
  if not reaper.SetTempoTimeSigMarker(projectId, -1, leadingMeasureStartTime, -1, -1, leadingMeasureTempo, leadingMeasureQns, leadingMeasureQuantum, 0) then
    error("SetTempoTimeSigMarker failed")
  end
end

newMeasureTempo = 240 / newMeasureLength / (newMeasureQuantum / newMeasureQns)
if not dryRun then
  if not reaper.SetTempoTimeSigMarker(projectId, -1, newMeasureStartTime, -1, -1, newMeasureTempo, newMeasureQns, newMeasureQuantum, 0) then
    error("SetTempoTimeSigMarker failed")
  end
end

trailingMeasureTempo = 240 / trailingMeasureLength / (trailingMeasureQuantum / trailingMeasureQns)
if not dryRun then
  if not reaper.SetTempoTimeSigMarker(projectId, -1, newMeasureEndTime, -1, -1, trailingMeasureTempo, trailingMeasureQns, trailingMeasureQuantum, 0) then
    error("SetTempoTimeSigMarker failed")
  end
end


reaper.UpdateTimeline()

