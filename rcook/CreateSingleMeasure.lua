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

function createSingleMeasure(
  projectId,
  leadingMeasureQns,
  leadingMeasureBasis,
  newMeasureQns,
  newMeasureBasis,
  trailingMeasureQns,
  trailingMeasureBasis,
  dryRun)

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

  leadingMeasureTempo = 240 / leadingMeasureLength / (leadingMeasureBasis / leadingMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, leadingMeasureStartTime, -1, -1, leadingMeasureTempo, leadingMeasureQns, leadingMeasureBasis, 0) then
      error("SetTempoTimeSigMarker failed")
    end
  end

  newMeasureTempo = 240 / newMeasureLength / (newMeasureBasis / newMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, newMeasureStartTime, -1, -1, newMeasureTempo, newMeasureQns, newMeasureBasis, 0) then
      error("SetTempoTimeSigMarker failed")
    end
  end

  trailingMeasureTempo = 240 / trailingMeasureLength / (trailingMeasureBasis / trailingMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, newMeasureEndTime, -1, -1, trailingMeasureTempo, trailingMeasureQns, trailingMeasureBasis, 0) then
      error("SetTempoTimeSigMarker failed")
    end
  end
end

projectId = 0
leadingMeasureQns = 1
leadingMeasureBasis = 4
newMeasureQns = 4
newMeasureBasis = 4
trailingMeasureQns = 3
trailingMeasureBasis = 4
dryRun = true

createSingleMeasure(
  projectId,
  leadingMeasureQns,
  leadingMeasureBasis,
  newMeasureQns,
  newMeasureBasis,
  trailingMeasureQns,
  trailingMeasureBasis,
  dryRun)

reaper.UpdateTimeline()

