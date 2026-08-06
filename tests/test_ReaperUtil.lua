local p = arg and arg[0] and arg[0]:match("(.*[/\\])") or "./"
package.path = p .. "/../ChordTrack/?.lua;" .. p .. "?.lua;" .. package.path
local lu = require("luaunit")
local ReaperUtil = require("../ChordTrack/lib/ReaperUtil")

Test_getTrackByName = {}

function Test_getTrackByName:setUp()
  mock_reaper = {}

  mock_reaper.CountTracks = function(project)
    lu.assertEquals(project, 0)
    return 10
  end

  mock_reaper.GetTrack = function(project, i)
    lu.assertEquals(project, 0)
    lu.assertIsTrue(i >= 0 and i <= 9)
    return {
      name = string.format("track%d", i)
    }
  end

  mock_reaper.GetTrackName = function(track)
    lu.assertNotIsNil(track)
    return true, track.name
  end

  _G.reaper = mock_reaper
end

function Test_getTrackByName:testFound()
  local track = ReaperUtil.getTrackByName("track3")
  lu.assertEquals(track.name, "track3")
end

function Test_getTrackByName:testNotFound()
  local track = ReaperUtil.getTrackByName("track11")
  lu.assertIsNil(track)
end

os.exit(lu.LuaUnit.run())
