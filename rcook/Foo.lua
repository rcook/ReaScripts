--[[
   * ReaScript Name: Foo
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
init_lib("Foo")

local function foo(project_id)
  local new_measure_start_time, new_measure_end_time = reaper.GetSet_LoopTimeRange2(PROJECT_ID, false, false, 0, 0, false)
  local new_measure_length = new_measure_end_time - new_measure_start_time
  if new_measure_length == 0 then
    exit("Selected time range is empty")
    return false
  end
end


local function main()
  run_action_command(0, "FOO")
end

run(main)
