local Constants = require("Scripts/rcook-reascripts/ChordTrack/lib/Constants")
local Music = require("Scripts/rcook-reascripts/ChordTrack/lib/Music")
local ReaperUtil = require("Scripts/rcook-reascripts/ChordTrack/lib/ReaperUtil")
local Util = require("Scripts/rcook-reascripts/ChordTrack/lib/Util")

local appendEmptyItems = ReaperUtil.appendEmptyItems
local dump = Util.dump
local getTrackByName = ReaperUtil.getTrackByName
local log = Util.log

local function doDumpChords(track)
  local chord_track = getTrackByName(Constants.DEFAULT_CHORD_TRACK_NAME)
  if not chord_track then
    reaper.ShowMessageBox(
      string.format("No track found with default chord track name \"%s\".", Constants.DEFAULT_CHORD_TRACK_NAME),
      "Dump Chords",
      0)
    return
  end

  local n = reaper.CountTrackMediaItems(chord_track)
  for i = 0, n - 1 do
    local item = assert(reaper.GetTrackMediaItem(chord_track, i))
    local start_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local is_ok, notes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", "", false)
    assert(is_ok and notes)
    local midi_notes = Music.parseChord(notes)
    log(string.format(
      "Item \"%s\" (%s, %s) [%s]",
      notes,
      tostring(start_pos),
      tostring(len),
      dump(midi_notes)))
  end
end

doDumpChords()
