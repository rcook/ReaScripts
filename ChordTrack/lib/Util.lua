-- @noindex
-- @description ChordTrack: Utility Functions
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

local Util = {}

function Util.log(s)
  reaper.ShowConsoleMsg(s .. "\n")
end

function Util.dump(obj)
  if type(obj) == "string" then
    return "\"" .. obj .. "\""
  elseif type(obj) == "table" then
    local s = "{ "
    local i = 0
    for k, v in pairs(obj) do
      local key
      if type(k) ~= "number" then
        key = "\"" .. k .. "\""
      else
        key = k
      end
      if i > 0 then
        s = s .. ", "
      end
      s = s .. "[" .. key .. "] = " .. Util.dump(v)
      i = i + 1
    end
    return s .. " }"
  else
    return tostring(obj)
  end
end

function Util.split(s, delim)
  delim = delim or " "
  local parts = {}
  local last_idx = 1
  while true do
    local start_idx, end_idx = s:find(delim, last_idx, true)
    if not start_idx then
      if last_idx <= #s then
        parts[#parts + 1] = s:sub(last_idx)
      end
      return parts
    end
    parts[#parts + 1] = s:sub(last_idx, end_idx - 1)
    last_idx = end_idx + #delim
  end
end

return Util
