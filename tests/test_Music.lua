local p = arg and arg[0] and arg[0]:match("(.*/)") or "./"
package.path = p .. "?.lua;" .. package.path
local lu = require("luaunit")
local Music = require("../ChordTrack/lib/Music")

local function pc(str, octave, opts)
  return Music.parseChord(str, octave, opts)
end

TestParseChord_Roots = {}

function TestParseChord_Roots:test_C()  lu.assertEquals(pc("C"),  {60, 64, 67}) end
function TestParseChord_Roots:test_Cs() lu.assertEquals(pc("C#"), {61, 65, 68}) end
function TestParseChord_Roots:test_Db() lu.assertEquals(pc("Db"), {61, 65, 68}) end
function TestParseChord_Roots:test_D()  lu.assertEquals(pc("D"),  {62, 66, 69}) end
function TestParseChord_Roots:test_Ds() lu.assertEquals(pc("D#"), {63, 67, 70}) end
function TestParseChord_Roots:test_Eb() lu.assertEquals(pc("Eb"), {63, 67, 70}) end
function TestParseChord_Roots:test_E()  lu.assertEquals(pc("E"),  {64, 68, 71}) end
function TestParseChord_Roots:test_Fb() lu.assertEquals(pc("Fb"), {64, 68, 71}) end
function TestParseChord_Roots:test_F()  lu.assertEquals(pc("F"),  {65, 69, 72}) end
function TestParseChord_Roots:test_Es() lu.assertEquals(pc("E#"), {65, 69, 72}) end
function TestParseChord_Roots:test_Fs() lu.assertEquals(pc("F#"), {66, 70, 73}) end
function TestParseChord_Roots:test_Gb() lu.assertEquals(pc("Gb"), {66, 70, 73}) end
function TestParseChord_Roots:test_G()  lu.assertEquals(pc("G"),  {67, 71, 74}) end
function TestParseChord_Roots:test_Gs() lu.assertEquals(pc("G#"), {68, 72, 75}) end
function TestParseChord_Roots:test_Ab() lu.assertEquals(pc("Ab"), {68, 72, 75}) end
function TestParseChord_Roots:test_A()  lu.assertEquals(pc("A"),  {69, 73, 76}) end
function TestParseChord_Roots:test_As() lu.assertEquals(pc("A#"), {70, 74, 77}) end
function TestParseChord_Roots:test_Bb() lu.assertEquals(pc("Bb"), {70, 74, 77}) end
function TestParseChord_Roots:test_B()  lu.assertEquals(pc("B"),  {71, 75, 78}) end
function TestParseChord_Roots:test_Bs() lu.assertEquals(pc("B#"), {60, 64, 67}) end
function TestParseChord_Roots:test_Cb() lu.assertEquals(pc("Cb"), {71, 75, 78}) end

function TestParseChord_Roots:test_enharmonic_equivalence()
  lu.assertEquals(pc("C#"), pc("Db"))
  lu.assertEquals(pc("D#"), pc("Eb"))
  lu.assertEquals(pc("F#"), pc("Gb"))
  lu.assertEquals(pc("G#"), pc("Ab"))
  lu.assertEquals(pc("A#"), pc("Bb"))
  lu.assertEquals(pc("B#"), pc("C"))
  lu.assertEquals(pc("Cb"), pc("B"))
  lu.assertEquals(pc("E#"), pc("F"))
  lu.assertEquals(pc("Fb"), pc("E"))
end

TestParseChord_Octave = {}

function TestParseChord_Octave:test_default_is_4()
  lu.assertEquals(pc("C"), pc("C", 4))
  lu.assertEquals(pc("C", nil), {60, 64, 67})
end

function TestParseChord_Octave:test_octave_3() lu.assertEquals(pc("C", 3), {48, 52, 55}) end
function TestParseChord_Octave:test_octave_4() lu.assertEquals(pc("C", 4), {60, 64, 67}) end
function TestParseChord_Octave:test_octave_5() lu.assertEquals(pc("C", 5), {72, 76, 79}) end
function TestParseChord_Octave:test_octave_0() lu.assertEquals(pc("C", 0), {12, 16, 19}) end

function TestParseChord_Octave:test_octave_shifts_slash_bass()
  lu.assertEquals(pc("Cmaj7/G", 5), {67, 72, 76, 83})
end

TestParseChord_Qualities = {}

function TestParseChord_Qualities:test_major_default() lu.assertEquals(pc("C"),     {60, 64, 67}) end
function TestParseChord_Qualities:test_maj()           lu.assertEquals(pc("Cmaj"),  {60, 64, 67}) end
function TestParseChord_Qualities:test_m()             lu.assertEquals(pc("Cm"),    {60, 63, 67}) end
function TestParseChord_Qualities:test_min()           lu.assertEquals(pc("Cmin"),  {60, 63, 67}) end
function TestParseChord_Qualities:test_dim()           lu.assertEquals(pc("Cdim"),  {60, 63, 66}) end
function TestParseChord_Qualities:test_aug()           lu.assertEquals(pc("Caug"),  {60, 64, 68}) end
function TestParseChord_Qualities:test_sus2()          lu.assertEquals(pc("Csus2"), {60, 62, 67}) end
function TestParseChord_Qualities:test_sus4()          lu.assertEquals(pc("Csus4"), {60, 65, 67}) end
function TestParseChord_Qualities:test_dom7()          lu.assertEquals(pc("C7"),    {60, 64, 67, 70}) end
function TestParseChord_Qualities:test_m7()            lu.assertEquals(pc("Cm7"),   {60, 63, 67, 70}) end
function TestParseChord_Qualities:test_maj7()          lu.assertEquals(pc("Cmaj7"), {60, 64, 67, 71}) end
function TestParseChord_Qualities:test_M7()            lu.assertEquals(pc("CM7"),   {60, 64, 67, 71}) end
function TestParseChord_Qualities:test_dim7()          lu.assertEquals(pc("Cdim7"), {60, 63, 66, 69}) end
function TestParseChord_Qualities:test_m7b5()          lu.assertEquals(pc("Cm7b5"), {60, 63, 66, 70}) end
function TestParseChord_Qualities:test_9()             lu.assertEquals(pc("C9"),    {60, 64, 67, 70, 74}) end
function TestParseChord_Qualities:test_maj9()          lu.assertEquals(pc("Cmaj9"), {60, 64, 67, 71, 74}) end
function TestParseChord_Qualities:test_m9()            lu.assertEquals(pc("Cm9"),   {60, 63, 67, 70, 74}) end
function TestParseChord_Qualities:test_7sus4()         lu.assertEquals(pc("C7sus4"),  {60, 65, 67, 70}) end
function TestParseChord_Qualities:test_7sus2()         lu.assertEquals(pc("C7sus2"),  {60, 62, 67, 70}) end
function TestParseChord_Qualities:test_9sus4()         lu.assertEquals(pc("C9sus4"),  {60, 65, 67, 70, 74}) end
function TestParseChord_Qualities:test_13sus4()        lu.assertEquals(pc("C13sus4"), {60, 65, 67, 70, 74, 81}) end

function TestParseChord_Qualities:test_case_sensitivity_M7_vs_m7()
  lu.assertNotEquals(pc("CM7"), pc("Cm7"))
end

TestParseChord_Extensions = {}

function TestParseChord_Extensions:test_add9()      lu.assertEquals(pc("Cadd9"),   {60, 64, 67, 74}) end
function TestParseChord_Extensions:test_add2()      lu.assertEquals(pc("Cadd2"),   {60, 62, 64, 67}) end
function TestParseChord_Extensions:test_add4()      lu.assertEquals(pc("Cadd4"),   {60, 64, 65, 67}) end
function TestParseChord_Extensions:test_add6()      lu.assertEquals(pc("Cadd6"),   {60, 64, 67, 69}) end
function TestParseChord_Extensions:test_add11()     lu.assertEquals(pc("Cadd11"),  {60, 64, 67, 77}) end
function TestParseChord_Extensions:test_add13()     lu.assertEquals(pc("Cadd13"),  {60, 64, 67, 81}) end
function TestParseChord_Extensions:test_6()         lu.assertEquals(pc("C6"),      {60, 64, 67, 69}) end
function TestParseChord_Extensions:test_maj7b9()    lu.assertEquals(pc("Cmaj7b9"), {60, 64, 67, 71, 73}) end
function TestParseChord_Extensions:test_maj7sharp9()lu.assertEquals(pc("Cmaj7#9"), {60, 64, 67, 71, 75}) end
function TestParseChord_Extensions:test_13()        lu.assertEquals(pc("C13"),     {60, 64, 67, 81}) end

function TestParseChord_Extensions:test_Cb6_parses_as_C_plus_flat6()
  -- When "b" is followed by a digit, prefer the extension interpretation:
  -- "Cb6" is C major + b6 (Ab).
  lu.assertEquals(pc("Cb6"), {60, 64, 67, 68})
end

function TestParseChord_Extensions:test_Cb13_parses_as_C_plus_flat13()
  lu.assertEquals(pc("Cb13"), {60, 64, 67, 80})
end

function TestParseChord_Extensions:test_Cb_still_parses_as_Cb_major()
  -- Non-digit after the accidental keeps "Cb" as the root (a real note).
  lu.assertEquals(pc("Cb"),    {71, 75, 78})
  lu.assertEquals(pc("Cbmaj"), {71, 75, 78})
  lu.assertEquals(pc("Cbm7"),  {71, 74, 78, 81})
end

function TestParseChord_Extensions:test_Cb9_parses_as_C_plus_flat9()
  lu.assertEquals(pc("Cb9"), {60, 64, 67, 73})
end
function TestParseChord_Extensions:test_maj7sharp11() lu.assertEquals(pc("Cmaj7#11"), {60, 64, 67, 71, 78}) end
function TestParseChord_Extensions:test_sus4add9()  lu.assertEquals(pc("Csus4add9"), {60, 65, 67, 74}) end
function TestParseChord_Extensions:test_m7b5_is_core_not_ext()
  -- Longest-match core wins: "m7b5" is parsed whole; no extension leftover.
  lu.assertEquals(pc("Cm7b5"), {60, 63, 66, 70})
end

TestParseChord_SlashChords = {}

function TestParseChord_SlashChords:test_Cmaj7_over_G()
  lu.assertEquals(pc("Cmaj7/G"), {55, 60, 64, 71})
end

function TestParseChord_SlashChords:test_Cmaj7_over_G_with_spaces()
  lu.assertEquals(pc("Cmaj7 / G"), {55, 60, 64, 71})
end

function TestParseChord_SlashChords:test_C_over_E_removes_E4_and_inserts_E3()
  lu.assertEquals(pc("C/E"), {52, 60, 67})
end

function TestParseChord_SlashChords:test_C_over_G_removes_G_and_inserts_low_G()
  lu.assertEquals(pc("C/G"), {55, 60, 64})
end

function TestParseChord_SlashChords:test_C_over_Db_adds_bass_no_removal()
  lu.assertEquals(pc("C/Db"), {49, 60, 64, 67})
end

function TestParseChord_SlashChords:test_output_is_sorted_ascending()
  local out = pc("Cmaj7/G")
  for i = 2, #out do
    lu.assertTrue(out[i] >= out[i - 1], "output should be sorted ascending")
  end
end

function TestParseChord_SlashChords:test_non_slash_output_is_sorted_ascending()
  local out = pc("Cmaj7b9")
  for i = 2, #out do
    lu.assertTrue(out[i] >= out[i - 1], "non-slash output should be sorted ascending")
  end
end

function TestParseChord_SlashChords:test_invalid_bass_returns_nil()
  lu.assertNil(pc("C/H"))
end

TestParseChord_Fallback = {}

function TestParseChord_Fallback:test_unknown_returns_nil_by_default()
  lu.assertNil(pc("Cbogus"))
end

function TestParseChord_Fallback:test_fallback_rescues_unknown_extensions()
  -- allowFallback now covers unknown extension tokens too: unknown residue
  -- is dropped and the fallback triad returned.
  -- "Cxyz" -> C root, no accidental, unknown ext -> C major triad.
  lu.assertEquals(pc("Cxyz",   4, {allowFallback = true}), {60, 64, 67})
  -- "Cbogus" -> Cb root (b not followed by a digit, so no alt path), unknown
  -- suffix + unknown ext -> Cb major triad.
  lu.assertEquals(pc("Cbogus", 4, {allowFallback = true}), {71, 75, 78})
end

TestParseChord_Invalid = {}

function TestParseChord_Invalid:test_empty_string() lu.assertNil(pc("")) end
function TestParseChord_Invalid:test_nil()          lu.assertNil(pc(nil)) end
function TestParseChord_Invalid:test_whitespace()   lu.assertNil(pc("   ")) end
function TestParseChord_Invalid:test_bad_root_X()   lu.assertNil(pc("X")) end
function TestParseChord_Invalid:test_bad_root_H()   lu.assertNil(pc("H")) end
function TestParseChord_Invalid:test_lowercase_root_rejected() lu.assertNil(pc("c")) end

function TestParseChord_Invalid:test_unknown_suffix() lu.assertNil(pc("Cbogus")) end
function TestParseChord_Invalid:test_empty_bass()     lu.assertNil(pc("C/")) end
function TestParseChord_Invalid:test_empty_main()     lu.assertNil(pc("/G")) end

TestParseChord_Whitespace = {}

function TestParseChord_Whitespace:test_padded_root()
  lu.assertEquals(pc("  C  "), {60, 64, 67})
end

function TestParseChord_Whitespace:test_padded_slash_chord()
  lu.assertEquals(pc(" Cmaj7 / G "), {55, 60, 64, 71})
end

TestParseChord_Idempotence = {}

function TestParseChord_Idempotence:test_same_input_same_output()
  local a = pc("Cmaj7/G")
  local b = pc("Cmaj7/G")
  lu.assertEquals(a, b)
end

function TestParseChord_Idempotence:test_interleaved_calls_do_not_interfere()
  local a1 = pc("C")
  local _  = pc("Bbmaj9/F")
  local a2 = pc("C")
  lu.assertEquals(a1, a2)
end

os.exit(lu.LuaUnit.run())
