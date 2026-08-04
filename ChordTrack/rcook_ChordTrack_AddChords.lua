local Constants = require("Scripts/rcook-reascripts/ChordTrack/lib/Constants")
local ReaperUtil = require("Scripts/rcook-reascripts/ChordTrack/lib/ReaperUtil")
local Util = require("Scripts/rcook-reascripts/ChordTrack/lib/Util")

local appendEmptyItems = ReaperUtil.appendEmptyItems
local getTrackByName = ReaperUtil.getTrackByName
local split = Util.split

local function getOptions()
  local is_ok, s = reaper.GetUserInputs(
    "Add Chords to Chord Track",
    2,
    "Chords,Chord track",
    string.format("C Am F G,%s", Constants.DEFAULT_CHORD_TRACK_NAME),
    0)
  if not is_ok then
    return
  end

  local values = split(s, ",")
  assert(#values == 2)
  return values[2], split(values[1])
end

local function doAddChords()
  local chord_track_name, chords = getOptions()
  if not chord_track_name then
    return
  end

  reaper.Undo_BeginBlock()

  local chord_track = getTrackByName(chord_track_name)
  if not chord_track then
    reaper.InsertTrackAtIndex(0, true)
    chord_track = reaper.GetTrack(0, 0)
    reaper.GetSetMediaTrackInfo_String(chord_track, "P_NAME", chord_track_name, 1)
    reaper.SetMediaTrackInfo_Value(chord_track, "B_TCPPIN", 1)
  end

  appendEmptyItems(chord_track, chords)

  reaper.Undo_EndBlock("Append empty items for chords", -1)
end

doAddChords()
