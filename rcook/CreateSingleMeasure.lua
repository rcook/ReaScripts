local function print(param)
  reaper.ShowConsoleMsg("[" .. tostring(reaper.time_precise()) .. "] " .. tostring(param) .. "\n")
end

local function userError(param)
  local s = tostring(param)
  reaper.ShowMessageBox(s, "CreateSingleMeasure", 0)
end

local function fatalError(param)
  local s = tostring(param)
  reaper.ShowMessageBox("Error: " .. s, "CreateSingleMeasure", 0)
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
    fatalError("Invalid time range selection")
  end

  local newMeasureStartQn = reaper.TimeMap2_timeToQN(projectId, newMeasureStartTime)
  local newMeasureEndQn = reaper.TimeMap2_timeToQN(projectId, newMeasureEndTime)

  -- Measure immediately before selection
  -- Measure starts at leadingMeasureStartTime and ends at newMeasureStartTime
  local measureNumber = reaper.TimeMap_QNToMeasures(projectId, newMeasureStartQn)
  local leadingMeasureStartTime, _, _, originalTimeSigNum, originalTimeSigDenom, originalTempo = reaper.TimeMap_GetMeasureInfo(projectId, measureNumber - 1)
  local leadingMeasureLength = newMeasureStartTime - leadingMeasureStartTime
  if leadingMeasureLength == 0 then
    fatalError("Invalid time range selection")
  end

  -- Measure immediately after selection
  -- Measure starts at newMeasureEndTime and ends at trailingMeasureEndTime
  local measureNumber = reaper.TimeMap_QNToMeasures(projectId, newMeasureEndQn)
  local trailingMeasureEndTime, _, _, _, _, _= reaper.TimeMap_GetMeasureInfo(projectId, measureNumber)
  local trailingMeasureLength = trailingMeasureEndTime - newMeasureEndTime
  if trailingMeasureLength == 0 then
    fatalError("Invalid time range selection")
  end

  local leadingMeasureTempo = 240 / leadingMeasureLength / (leadingMeasureBasis / leadingMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, leadingMeasureStartTime, -1, -1, leadingMeasureTempo, leadingMeasureQns, leadingMeasureBasis, 0) then
      fatalError("SetTempoTimeSigMarker failed")
    end
  end

  local newMeasureTempo = 240 / newMeasureLength / (newMeasureBasis / newMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, newMeasureStartTime, -1, -1, newMeasureTempo, newMeasureQns, newMeasureBasis, 0) then
      fatalError("SetTempoTimeSigMarker failed")
    end
  end

  local trailingMeasureTempo = 240 / trailingMeasureLength / (trailingMeasureBasis / trailingMeasureQns)
  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, newMeasureEndTime, -1, -1, trailingMeasureTempo, trailingMeasureQns, trailingMeasureBasis, 0) then
      fatalError("SetTempoTimeSigMarker failed")
    end
  end

  if not dryRun then
    if not reaper.SetTempoTimeSigMarker(projectId, -1, trailingMeasureEndTime, -1, -1, originalTempo, originalTimeSigNum, originalTimeSigDenom, 0) then
      fatalError("SetTempoTimeSigMarker failed")
    end
  end
end

local function main()
  local projectId = 0
  local leadingMeasureBasis = 4
  local newMeasureBasis = 4
  local trailingMeasureBasis = 4
  local dryRun = true

  if reaper.SNM_GetIntConfigVarEx(projectId, "itemtimelock", -100) ~= 0 then
    userError("Timebase for items/envelopes/markers must be set to \"Time\"")
    return false
  end

  if reaper.SNM_GetIntConfigVarEx(projectId, "tempoenvtimelock", -100) ~=0 then
    userError("Timebase for tempo/time signature envelope must be set to \"Time\"")
    return false
  end

  local newMeasureStartTime, newMeasureEndTime = reaper.GetSet_LoopTimeRange2(projectId, false, false, 0, 0, false)
  local newMeasureLength = newMeasureEndTime - newMeasureStartTime
  if newMeasureLength == 0 then
    userError("Selected time range is empty")
    return false
  end

  local markerCount = reaper.CountTempoTimeSigMarkers(projectId)
  for i = 0, markerCount - 1 do
    local status, markerTime = reaper.GetTempoTimeSigMarker(projectId, i)
    if not status then
      fatalError("GetTempoTimeSigMarker failed")
    end

    if markerTime >= newMeasureStartTime and markerTime <= newMeasureEndTime then
      userError("Selected time range already contains one or more tempo/time signature markers")
      return false
    end
  end

  local status, leadingMeasureQnsStr, newMeasureQnsStr, trailingMeasureQnsStr = getUserInputs("CreateSingleMeasure", {{"Beats in leading measure", 4}, {"Beats in new measure", 4}, {"Beats in trailing measure", 4}})
  if not status then
    -- Operation cancelled
    return false
  end

  local leadingMeasureQns = tonumber(leadingMeasureQnsStr)
  local newMeasureQns = tonumber(newMeasureQnsStr)
  local trailingMeasureQns = tonumber(trailingMeasureQnsStr)

  if not createSingleMeasure(
    projectId,
    leadingMeasureQns,
    leadingMeasureBasis,
    newMeasureQns,
    newMeasureBasis,
    trailingMeasureQns,
    trailingMeasureBasis,
    dryRun) then
    return false
  end

  reaper.UpdateTimeline()
  return true
end

main()

