-- @noindex
-- @description Generate Config Files
-- @author Richard Cook
-- @version 0.0
-- @about
--  Generates .ReaperMenu and .ReaperKeyMap files for rrx

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")

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

local function read_description(path)
  for line in io.lines(join_paths(path)) do
    local m, value = line:match("^%s*--%s*@(%S+)(.*)$")
    if m == nil then break end
    if m == "description" then
      return value:match("%s*(.-)%s*$")
    end
  end
  abort("No @description tag found in " .. path)
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

local function main(ctx)
  local this_path = normalize_path(debug.getinfo(1).source:match("@?(.*)"))
  local resource_dir = normalize_path(reaper.GetResourcePath())
  local scripts_dir = join_paths(resource_dir, "Scripts")
  local menu_sets_dir = join_paths(resource_dir, "MenuSets")

  local status, menu_path = reaper.JS_Dialog_BrowseForSaveFile(
    ctx.script_title,
    menu_sets_dir,
    "rrx_Actions.ReaperMenu",
    "ReaperMenu files (.ReaperMenu)\0*.*\0\0")
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

    local desc = read_description(p)
    local rel_path = join_paths(rrx_subdir, f)
    local action_id = read_script_action_id(rel_path, 0)
    actions[#actions + 1] = {
      action_id = action_id,
      desc = desc
    }

    ::continue::
  end

  local menu_ini = make_menu_ini(actions)

  local f = assert(io.open(menu_path, "w"))
  f:write(menu_ini)
  assert(f:close())
end

run("Generate Config Files", main)
