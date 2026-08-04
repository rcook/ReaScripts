-- @noindex
-- @description Dump chord names corresponding to media items in the default chord track (debugging)
-- @author Richard Cook
-- @version 0.0
-- @about
--  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam enim ante, condimentum in
--  maximus sed, pellentesque non est. Suspendisse sagittis justo eu tortor dignissim, non laoreet
--  lacus dictum. Aenean sodales ligula ante, id dapibus diam dapibus ac. Donec at dui consequat,
--  congue neque et, viverra ex. Integer eu massa quis sapien laoreet consequat ultrices quis
--  tortor. Fusce vel semper felis, at maximus mi. Nunc tellus elit, congue sed rhoncus vitae,
--  vestibulum vel sapien. Proin sapien est, commodo at commodo in, volutpat vitae leo. Maecenas
--  facilisis, quam sagittis pretium fringilla, mauris ex interdum dolor, sit amet ultrices dolor
--  odio vel tortor. Curabitur vestibulum lectus tincidunt felis fermentum malesuada. Aenean
--  commodo magna ac est fringilla, tempus ullamcorper eros mollis. Etiam sit amet mi arcu. Fusce
--  nec convallis metus. Nulla at tempus nisi, non varius mauris.

package.path = package.path .. ";" .. debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]] .. "?.lua"
local Constants = require("lib/Constants")
local Music = require("lib/Music")
local ReaperUtil = require("lib/ReaperUtil")
local Util = require("lib/Util")

local appendEmptyItems = ReaperUtil.appendEmptyItems
local dump = Util.dump
local getTrackByName = ReaperUtil.getTrackByName
local log = Util.log

local TITLE = "Dump Chords in Chord Track"

local function doDumpChords(track)
  local chord_track = getTrackByName(Constants.DEFAULT_CHORD_TRACK_NAME)
  if not chord_track then
    reaper.ShowMessageBox(
      string.format("No track found with default chord track name \"%s\".", Constants.DEFAULT_CHORD_TRACK_NAME),
      TITLE,
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
