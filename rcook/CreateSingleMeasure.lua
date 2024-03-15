local function print(param)
  reaper.ShowConsoleMsg("[" .. tostring(reaper.time_precise()) .. "] " .. tostring(param) .. "\n")
end

local function error(param)
  local s = tostring(param)
  print("[ERROR] " .. s)
  reaper.ReaScriptError("!" .. s)
end

local function formatTime(pos)
  return reaper.format_timestr_pos(pos, "", -1)
end

local function getUserInputs(title, inputs)
  local captions_csv = ""
  local values_csv = ""
  local results_regex = ""
  for i, p in ipairs(inputs) do
    if i > 1 then
      captions_csv = captions_csv .. ","
      values_csv = values_csv .. ","
      results_regex = results_regex .. ","
    end
    captions_csv = captions_csv .. p[1]
    values_csv = values_csv .. p[2]
    results_regex = results_regex .. "([^,]+)"
  end
  local status, results_csv = reaper.GetUserInputs(title, #inputs, captions_csv, values_csv)
  if status then
    return true, results_csv:match(results_regex)
  else
    return false, nil
  end
end

local function createSingleMeasure(
  projectId,
  leadingMeasureQns,
  leadingMeasureBasis,
  newMeasureQns,
  newMeasureBasis,
  trailingMeasureQns,
  trailingMeasureBasis,
  dryRun)

  local newMeasureStartTime, newMeasureEndTime = reaper.GetSet_LoopTimeRange2(projectId, false, false, 0, 0, false)
  local newMeasureLength = newMeasureEndTime - newMeasureStartTime
  if newMeasureLength == 0 then
    error("Invalid selection (empty)")
  end

  local newMeasureStartQn = reaper.TimeMap2_timeToQN(projectId, newMeasureStartTime)
  local newMeasureEndQn = reaper.TimeMap2_timeToQN(projectId, newMeasureEndTime)

  -- Measure immediately before selection
  -- Measure starts at leadingMeasureStartTime and ends at newMeasureStartTime
  local measureNumber = reaper.TimeMap_QNToMeasures(projectId, newMeasureStartQn)
  local leadingMeasureStartTime, startQn, endQn, timeSigNum, timeSigDenom, tempo = reaper.TimeMap_GetMeasureInfo(projectId, measureNumber - 1)
  local leadingMeasureLength = newMeasureStartTime - leadingMeasureStartTime
  if leadingMeasureLength == 0 then
    error("Invalid selection (no leading)")
  end

  -- Measure immediately after selection
  -- Measure starts at newMeasureEndTime and ends at trailingMeasureEndTime
  local measureNumber = reaper.TimeMap_QNToMeasures(projectId, newMeasureEndQn)
  local trailingMeasureEndTime, startQn, endQn, timeSigNum, timeSigDenom, temp = reaper.TimeMap_GetMeasureInfo(projectId, measureNumber)
  local trailingMeasureLength = trailingMeasureEndTime - newMeasureEndTime
  if trailingMeasureLength == 0 then
    error("Invalid selection (no trailing)")
  end

  local leadingMeasureTempo = 240 / leadingMeasureLength / (leadingMeasureBasis / leadingMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, leadingMeasureStartTime, -1, -1, leadingMeasureTempo, leadingMeasureQns, leadingMeasureBasis, 0) then
      error("SetTempoTimeSigMarker failed")
    end
  end

  local newMeasureTempo = 240 / newMeasureLength / (newMeasureBasis / newMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, newMeasureStartTime, -1, -1, newMeasureTempo, newMeasureQns, newMeasureBasis, 0) then
      error("SetTempoTimeSigMarker failed")
    end
  end

  local trailingMeasureTempo = 240 / trailingMeasureLength / (trailingMeasureBasis / trailingMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, newMeasureEndTime, -1, -1, trailingMeasureTempo, trailingMeasureQns, trailingMeasureBasis, 0) then
      error("SetTempoTimeSigMarker failed")
    end
  end
end

local function main()
  local projectId = 0
  local leadingMeasureQns = 1
  local leadingMeasureBasis = 4
  local newMeasureQns = 4
  local newMeasureBasis = 4
  local trailingMeasureQns = 3
  local trailingMeasureBasis = 4
  local dryRun = true

  if reaper.SNM_GetIntConfigVarEx(projectId, "itemtimelock", -100) ~= 0 then
    error("Timebase for items/envelopes/markers must set to \"Time\"")
  end

  if reaper.SNM_GetIntConfigVarEx(projectId, "tempoenvtimelock", -100) ~=0 then
    error("Timebase for tempo/time signature envelope must be set to \"Time\"")
  end

  local status, a, b = getUserInputs("TITLE", {{"AAA", "one"}, {"BBB", "two"}})
  if not status then
    return
  end

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
end

main()

