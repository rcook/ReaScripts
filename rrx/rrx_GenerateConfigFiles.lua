-- @noindex
-- @description Generate Config Files
-- @author Richard Cook
-- @version 0.0
-- @about
--  Generates .ReaperMenu and .ReaperKeyMap files for rrx

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")

local EXTRA_KEYS = {
  {key = "29 77", command_id = 40364, section = 0, desc = "Main : Ctrl+Alt+Shift+M : Options: Toggle metronome"},
  {key = "13 221", command_id = 41040, section = 0, desc = "Main : Ctrl+Shift+] : Move edit cursor to start of next measure"},
  {key = "13 219", command_id = 41041, section = 0, desc = "Main : Ctrl+Shift+[ : Move edit cursor to start of current measure"},
  {key = "13 190", command_id = 41044, section = 0, desc = "Main : Ctrl+Shift+. : Move edit cursor forward one beat"},
  {key = "13 188", command_id = 41045, section = 0, desc = "Main : Ctrl+Shift+, : Move edit cursor back one beat"}
}

local function normalize_path(p)
  return p:gsub("/", "\\"):gsub("\\+$", "")
end

local function join_paths(...)
  local p = ""
  for i, part in ipairs({...}) do
    if i > 1 then p = p .. "\\" end
    p = p .. part
  end
  return p
end

local function read_script_action_id(path, section)
  for line in io.lines(join_paths(reaper.GetResourcePath(), "reaper-kb.ini")) do
    if line:sub(1,3) == "SCR" then
      local s, action_id, desc, p = line:match("SCR .- (.-) (.-) (\".-\") (.*)")
      p = normalize_path(p:gsub("\"", ""))
      if p == path and tonumber(s) == section then
        return "_" .. action_id
      end
    end
  end
  abort("Could not find script " .. path .. " in section " .. section)
end

local function try_read_tag(path, tag)
  for line in io.lines(join_paths(path)) do
    local m, value = line:match("^%s*--%s*@(%S+)(.*)$")
    if m == nil then break end
    if m == tag then
      return value:match("%s*(.-)%s*$")
    end
  end
  return nil
end

local function make_menu_ini(actions)
  local function add_menu_item(menu_ini, item_idx, action_id, desc)
    local new_menu_ini = ""
    new_menu_ini = new_menu_ini .. menu_ini
      .. "item_" .. tostring(item_idx)
      .. "="
      .. action_id
      .. " "
    if desc ~= nil then new_menu_ini = new_menu_ini .. desc end
    new_menu_ini = new_menu_ini .. "\n"
    return new_menu_ini, item_idx + 1
  end

  local menu_ini = ""
  local item_idx = 0

  menu_ini = menu_ini .. "[Main actions]\n"
  menu_ini, item_idx = add_menu_item(menu_ini, item_idx, -2, "rrx")

  for _, action in ipairs(actions) do
    menu_ini, item_idx = add_menu_item(menu_ini, item_idx, action.action_id, action.desc)
  end

  menu_ini, item_idx = add_menu_item(menu_ini, item_idx, -3)
  menu_ini, item_idx = add_menu_item(menu_ini, item_idx, -1)
  menu_ini, item_idx = add_menu_item(menu_ini, item_idx, 40605, "Show action list...")
  menu_ini, item_idx = add_menu_item(menu_ini, item_idx, -1)
  menu_ini, item_idx = add_menu_item(menu_ini, item_idx, 2998, "Show recent actions")
  return menu_ini
end

local function make_key_map_ini(actions)
  local function add_key(key_map_ini, key, command_id, section, desc)
    local new_key_map_ini = ""
    new_key_map_ini = new_key_map_ini .. key_map_ini
      .. "KEY"
      .. " "
      .. key
      .. " "
      .. tostring(command_id)
      .. " "
      .. tostring(section)
      .. " "
      .. "# "
      .. desc
      .. "\n"
    return new_key_map_ini
  end

  local key_map_ini = ""
  for _, action in ipairs(actions) do
    if action.key ~= nil then
      key_map_ini = add_key(key_map_ini, action.key, action.command_id, action.section, action.desc)
    end
  end
  for _, k in ipairs(EXTRA_KEYS) do
    key_map_ini = add_key(key_map_ini, k.key, k.command_id, k.section, k.desc)
  end
  return key_map_ini
end

local function main(ctx)
  local this_path = normalize_path(debug.getinfo(1).source:match("@?(.*)"))
  local resource_dir = normalize_path(reaper.GetResourcePath())
  local scripts_dir = join_paths(resource_dir, "Scripts")
  local menu_sets_dir = join_paths(resource_dir, "MenuSets")
  local key_maps_dir = join_paths(resource_dir, "KeyMaps")

  local status, menu_path = reaper.JS_Dialog_BrowseForSaveFile(
    ctx.script_title,
    menu_sets_dir,
    "rrx_Actions.ReaperMenu",
    "ReaperMenu files (.ReaperMenu)\0*.*\0\0")
  if status == 0 then
    exit()
  end
  assert(status == 1)

  local status, key_map_path = reaper.JS_Dialog_BrowseForSaveFile(
    ctx.script_title,
    key_maps_dir,
    "rrx.ReaperKeyMap",
    "ReaperKeyMap files (.ReaperKeyMap)\0*.*\0\0")
  if status == 0 then
    exit()
  end
  assert(status == 1)

  local rrx_subdir = join_paths("rcook-reascripts", "rrx")
  local rrx_dir = join_paths(scripts_dir, rrx_subdir)
  local file_idx = 0

  local actions = {}
  while true do
    local f = reaper.EnumerateFiles(rrx_dir, file_idx)
    file_idx = file_idx + 1

    if f == nil then break end

    if f:find("^rrx_") == nil then goto continue end

    local p = join_paths(rrx_dir, f)
    if p == this_path then goto continue end

    local desc = try_read_tag(p, "description")
    if desc == nil then goto continue end

    local key = try_read_tag(p, "key")

    local rel_path = join_paths(rrx_subdir, f)
    local action_id = read_script_action_id(rel_path, 0)

    local command_id = reaper.NamedCommandLookup(action_id)

    actions[#actions + 1] = {
      action_id = action_id,
      command_id = command_id,
      desc = desc,
      key = key,
      section = 0
    }

    ::continue::
  end

  local menu_ini = make_menu_ini(actions)
  local key_map_ini = make_key_map_ini(actions)

  local f = assert(io.open(menu_path, "w"))
  f:write(menu_ini)
  assert(f:close())

  local f = assert(io.open(key_map_path, "w"))
  f:write(key_map_ini)
  assert(f:close())
end

run("Generate Config Files", main)
