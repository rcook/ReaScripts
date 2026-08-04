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
      if type(k) ~= "number" then
        k = "\"" .. k .. "\""
      end
      if i > 0 then
        s = s .. ", "
      end
      s = s .. "[" .. k .. "] = " .. Util.dump(v)
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
