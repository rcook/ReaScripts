-- @noindex
-- @description Render chord names in given chord track as a MIDI media item in the given MIDI track
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

local dump = Util.dump
local log = Util.log
local getTrackByName = ReaperUtil.getTrackByName
local split = Util.split

local TITLE = "Render Chords to MIDI Track"

local function getOptions()
  local is_ok, s = reaper.GetUserInputs(
    TITLE,
    2,
    "Chord track,MIDI Track",
    string.format("%s,%s", Constants.DEFAULT_CHORD_TRACK_NAME, Constants.DEFAULT_MIDI_TRACK_NAME),
    0)
  if not is_ok then
    return
  end

  local values = split(s, ",")
  assert(#values == 2)
  return values[1], values[2]
end

local function getTrackExtent(track)
  local n = reaper.CountTrackMediaItems(track)
  local all_start_pos = nil
  local all_end_pos = nil
  for i = 0, n - 1 do
    local item = assert(reaper.GetTrackMediaItem(track, i))
    local start_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local end_pos = start_pos + len
    if not all_start_pos or start_pos < all_start_pos then
      all_start_pos = start_pos
    end
    if not all_end_pos or end_pos > all_end_pos then
      all_end_pos = end_pos
    end
  end
  return all_start_pos, all_end_pos
end

local function insertNote(take, start_pos, end_pos, midi_note)
  local start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, start_pos)
  local end_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, end_pos)
  reaper.MIDI_InsertNote(
    take,             -- take
    false,            -- selected
    false,            -- muted
    start_ppq,        -- startppqpos
    end_ppq,          -- endppqpos
    0,                -- chan
    midi_note,        -- pitch
    100,              -- vel
    true)             -- noSortInOptional
end

local function doRenderChords(track)
  local chord_track_name, midi_track_name = getOptions()
  if not chord_track_name then
    return
  end

  local chord_track = getTrackByName(chord_track_name)
  if not chord_track then
    reaper.ShowMessageBox(
      string.format("Chord track \"%s\" not found.", chord_track_name),
      TITLE,
      0)
    return
  end

  local midi_track = getTrackByName(midi_track_name)
  if not midi_track then
    reaper.InsertTrackAtIndex(1, true)
    midi_track = reaper.GetTrack(0, 1)
    reaper.GetSetMediaTrackInfo_String(midi_track, "P_NAME", midi_track_name, 1)
    reaper.SetMediaTrackInfo_Value(midi_track, "B_TCPPIN", 1)
  end

  local midi_start_pos, midi_end_pos = getTrackExtent(chord_track)
  if not midi_start_pos then
    reaper.ShowMessageBox(
      string.format("Chord track \"%s\" contains no chords.", chord_track_name),
      TITLE,
      0)
    return
  end

  local midi_len = midi_end_pos - midi_start_pos

  local midi_item_count = reaper.CountTrackMediaItems(midi_track) 
  if midi_item_count > 0 then
    if reaper.ShowMessageBox(
        string.format("Replace existing %d item(s) on track \"%s\"?", midi_item_count, midi_track_name),
        TITLE,
        1) ~= 1 then
      return
    end
  end

  reaper.Undo_BeginBlock()

  ReaperUtil.clearTrackItems(midi_track)
  local item = assert(reaper.CreateNewMIDIItemInProj(midi_track, midi_start_pos, midi_len, false))
  local take = assert(reaper.GetActiveTake(item)) 
  assert(reaper.TakeIsMIDI(take))

  local chord_item_count = reaper.CountTrackMediaItems(chord_track)
  for i = 0, chord_item_count - 1 do
    local item = assert(reaper.GetTrackMediaItem(chord_track, i))
    local start_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local is_ok, notes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", "", false)
    assert(is_ok and notes)
    local midi_notes = Music.parseChord(notes)
    if midi_notes then
      for _, midi_note in ipairs(midi_notes) do
        insertNote(take, start_pos, start_pos + len, midi_note)
      end
    else
      log(string.format("Invalid chord name %s", notes))
    end
  end

  reaper.MIDI_Sort(take)

  reaper.Undo_EndBlock("Render chords to MIDI track", -1)

  reaper.UpdateArrange()
  reaper.UpdateTimeline()
end

doRenderChords()
