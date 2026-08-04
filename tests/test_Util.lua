local p = arg and arg[0] and arg[0]:match("(.*/)") or "./"
package.path = p .. "?.lua;" .. package.path
local lu = require("luaunit")
local Util = require("../ChordTrack/lib/Util")

Test_split = {}

function Test_split:testDefaultDelim()
  lu.assertEquals(Util.split("hello world"), {"hello", "world"})
end

function Test_split:testStringDelim()
  lu.assertEquals(Util.split("hello,world", ","), {"hello", "world"})
end

os.exit(lu.LuaUnit.run())
