--[[
   * ReaScript Name: Empty
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

-- Standard preamble
SCRIPT_TITLE = "Empty"
dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
lib_init()

local function empty()
  trace("Hello World")
  message("Hello World")
end

local function main()
  empty()
end

main()
