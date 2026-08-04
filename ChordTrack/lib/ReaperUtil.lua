-- @noindex
-- @description ChordTrack: REAPER Utility Functions
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

local PROJECT = Constants.DEFAULT_PROJECT

local ReaperUtil = {}

function ReaperUtil.getTrackByName(name)
  local n = reaper.CountTracks(PROJECT)
  for i = 0, n - 1 do
    local track = assert(reaper.GetTrack(PROJECT, i))
    local is_ok, temp_name = reaper.GetTrackName(track)
    assert(is_ok and temp_name)
    if temp_name == name then return track end
  end
  return nil
end

function ReaperUtil.insertEmptyItem(track, start_pos, len, notes)
  local item = assert(reaper.AddMediaItemToTrack(track))
  assert(reaper.SetMediaItemInfo_Value(item, "D_POSITION", start_pos))
  assert(reaper.SetMediaItemInfo_Value(item, "D_LENGTH", len))
  if notes then
    local is_ok, _ = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", notes, true)
    assert(is_ok)
  end
  return item
end

function ReaperUtil.getLastPosAndLen(track, default_len)
  local n = reaper.CountTrackMediaItems(track)
  local last_end_pos = 0
  local last_len = default_len or 0
  for i = 0, n - 1 do
    local item = assert(reaper.GetTrackMediaItem(track, i))
    local start_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local end_pos = start_pos + len
    if end_pos > last_end_pos then
      last_end_pos = end_pos
      last_len = len
    end
  end
  return last_end_pos, last_len
end

function ReaperUtil.appendEmptyItems(track, names)
  local last_pos, len = ReaperUtil.getLastPosAndLen(track, 2.0)
  for _, name in ipairs(names) do
    ReaperUtil.insertEmptyItem(track, last_pos, len, name)
    last_pos = last_pos + len
  end
end

function ReaperUtil.clearTrackItems(track)
  local n = reaper.CountTrackMediaItems(track)
  for i = n - 1, 0, -1 do
    local item = assert(reaper.GetTrackMediaItem(track, i))
    reaper.DeleteTrackMediaItem(track, item)
  end
end

return ReaperUtil
