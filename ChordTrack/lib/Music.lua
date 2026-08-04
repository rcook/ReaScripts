-- @noindex
-- @description ChordTrack: Music Theory
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

local Music = {}

local CHORD_FORMULAS = {
  [""]        = {0, 4, 7},         -- Major Triad (default)
  ["maj"]     = {0, 4, 7},         -- Major Triad (default)
  ["m"]       = {0, 3, 7},         -- Minor Triad
  ["min"]     = {0, 3, 7},
  ["dim"]     = {0, 3, 6},         -- Diminished
  ["aug"]     = {0, 4, 8},         -- Augmented
  ["sus2"]    = {0, 2, 7},         -- Suspended 2nd
  ["sus4"]    = {0, 5, 7},         -- Suspended 4th

  ["7"]       = {0, 4, 7, 10},     -- Dominant 7th
  ["m7"]      = {0, 3, 7, 10},     -- Minor 7th
  ["maj7"]    = {0, 4, 7, 11},     -- Major 7th (pop)
  ["M7"]      = {0, 4, 7, 11},     -- Major 7th (jazz)
  ["dim7"]    = {0, 3, 6, 9},      -- Diminished 7th
  ["m7b5"]    = {0, 3, 6, 10},     -- Half-Diminished 7th
  ["7sus2"]   = {0, 2, 7, 10},     -- Dominant 7th sus2
  ["7sus4"]   = {0, 5, 7, 10},     -- Dominant 7th sus4

  ["9"]       = {0, 4, 7, 10, 14}, -- Dominant 9th (default assumed as b7 present)
  ["maj9"]    = {0, 4, 7, 11, 14}, -- Major 9th
  ["m9"]      = {0, 3, 7, 10, 14}, -- Minor 9th
  ["9sus4"]   = {0, 5, 7, 10, 14}, -- Dominant 9th sus4

  ["13sus4"]  = {0, 5, 7, 10, 14, 21}, -- Dominant 13th sus4
}

-- Base semitone values (pitch classes)
local NOTE_VALUES = {
  ["C"]  = 0,  ["B#"] = 0,
  ["C#"] = 1,  ["Db"] = 1,
  ["D"]  = 2,
  ["D#"] = 3,  ["Eb"] = 3,
  ["E"]  = 4,  ["Fb"] = 4,
  ["F"]  = 5,  ["E#"] = 5,
  ["F#"] = 6,  ["Gb"] = 6,
  ["G"]  = 7,
  ["G#"] = 8,  ["Ab"] = 8,
  ["A"]  = 9,
  ["A#"] = 10, ["Bb"] = 10,
  ["B"]  = 11, ["Cb"] = 11
}

-- Extensions (intervals from root in semitones)
-- Supports common numeric add-ons, including altered 9/11/13 variants.
local EXT_OFFSETS = {
  ["add2"]  = {2},
  ["add4"]  = {5},
  ["add6"]  = {9},
  ["add9"]  = {14},
  ["add11"] = {17},
  ["add13"] = {21},

  ["2"]    = {2},
  ["9"]    = {14},
  ["b9"]   = {13},
  ["#9"]   = {15},

  ["11"]   = {17},
  ["b11"]  = {16},
  ["#11"]  = {18},

  ["13"]   = {21},
  ["b13"]  = {20},
  ["#13"]  = {22},

  ["6"]    = {9},
  ["b6"]   = {8},
}

-- Longest-first so that e.g. "add11" wins over shorter prefixes.
local EXT_TOKENS = {
  "add11","add13","add2","add4","add6","add9",
  "b11","#11","11",
  "b13","#13","13",
  "b9","#9","9",
  "b6","6",
}

-- Helper: trim
local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Core-suffix keys sorted longest-first so the greedy prefix match below is
-- deterministic across Lua versions (pairs() ordering is unspecified).
local CORE_KEYS = {}
for k in pairs(CHORD_FORMULAS) do
  if k ~= "" then table.insert(CORE_KEYS, k) end
end
table.sort(CORE_KEYS, function(a, b) return #a > #b end)

local function parseRoot(note)
  if not note then return nil end
  note = trim(note)
  return NOTE_VALUES[note]
end

-- Parse a chord name into:
--   main_part (everything before slash)
--   bass_part (everything after slash)
-- Supports both "Cmaj7/G" and "Cmaj7 / G" (whitespace tolerant).
local function splitSlashChord(chord_str)
  -- split on a single slash, but allow whitespace around it
  local main, bass = chord_str:match("^(.+)%s*/%s*([A-G][#b]?)$")
  if main and bass then
    return trim(main), trim(bass)
  end
  return chord_str, nil
end

-- Extract the "core chord suffix" from the main part, plus any remaining extension tokens.
-- Example:
--   "Cmaj7b9"     -> root=C, core_suffix="maj7", remaining="b9"
--   "C7sus4add9"  -> core_suffix="7sus4"? (not in table) so we try longest core match
--
-- Strategy:
--   1) Determine root.
--   2) Try to find the longest matching suffix from CHORD_FORMULAS.
--   3) The remainder (if any) is treated as extension tokens and parsed additively.
local function parseCoreAndExtensions(root_name, suffix_str)
  suffix_str = suffix_str or ""
  suffix_str = trim(suffix_str)

  -- Find the longest key that matches at the start of suffix_str.
  -- CORE_KEYS is sorted longest-first, so the first hit wins.
  local core_suffix = ""
  local core_len = 0

  for _, k in ipairs(CORE_KEYS) do
    if suffix_str:sub(1, #k) == k then
      core_suffix = k
      core_len = #k
      break
    end
  end

  local extensions_part = suffix_str:sub(core_len + 1)
  extensions_part = trim(extensions_part)

  return core_suffix, extensions_part
end

-- Tokenize extension strings left-to-right, longest-match at each step
-- (e.g. "maj7b9add13" -> b9, add13). Returns nil if any residue is unknown.
local function parseExtensions(ext_str)
  if not ext_str or ext_str == "" then return {} end

  local offs = {}
  local s = ext_str

  while s ~= "" do
    s = trim(s)

    local matched = false
    for _, tok in ipairs(EXT_TOKENS) do
      if s:sub(1, #tok) == tok then
        for _, v in ipairs(EXT_OFFSETS[tok]) do table.insert(offs, v) end
        s = s:sub(#tok + 1)
        matched = true
        break
      end
    end

    if not matched then return nil end
  end

  return offs
end

-- Deduplicate intervals
local function uniq(list)
  local seen = {}
  local out = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      seen[v] = true
      table.insert(out, v)
    end
  end
  return out
end

function Music.parseChord(chord_str, default_octave, opts)
  opts = opts or {}
  default_octave = default_octave or 4

  chord_str = trim(chord_str or "")
  if chord_str == "" then return nil end

  local allowFallback = opts.allowFallback == true

  -- Handle slash chords
  local main_part, bass_note_name = splitSlashChord(chord_str)

  -- Parse root from main_part
  local root_name, suffix_str = main_part:match("^([A-G][#b]?)(.*)$")
  if not root_name then return nil end
  suffix_str = suffix_str or ""
  suffix_str = trim(suffix_str)

  local root_pc = parseRoot(root_name)
  if root_pc == nil then return nil end

  local root_midi = (default_octave + 1) * 12 + root_pc

  -- Core chord + remainder extensions
  local core_suffix, extensions_part = parseCoreAndExtensions(root_name, suffix_str)

  local formula = CHORD_FORMULAS[core_suffix]
  if not formula then
    if allowFallback then
      formula = CHORD_FORMULAS[""]
    else
      return nil
    end
  end

  local intervals = {}
  for i = 1, #formula do
    table.insert(intervals, formula[i])
  end

  if extensions_part and extensions_part ~= "" then
    local ext_intervals = parseExtensions(extensions_part)
    if ext_intervals == nil then
      return nil
    end
    for _, v in ipairs(ext_intervals) do
      table.insert(intervals, v)
    end
  end

  intervals = uniq(intervals)

  -- Compute MIDI notes from intervals
  -- Default behaviour: keep chord tones as-is (root + extensions).
  local notes = {}
  for i = 1, #intervals do
    notes[i] = root_midi + intervals[i]
  end

  -- Slash chord handling:
  -- "Cmaj7/G" means the chord tones are the same, but the bass note is forced to G
  -- by adding/replacing a low G in a musically typical way.
  --
  -- Approach:
  --   - Compute bass MIDI near the chord's octave: (default_octave)*12 + bass_pc
  --   - Remove any existing note with the same pitch class as the bass and below root? (simple replace)
  --   - Insert the bass note; ensure it's the lowest (common practice).
  if bass_note_name then
    local bass_pc = parseRoot(bass_note_name)
    if bass_pc == nil then return nil end

    -- bass in "root octave" (not +1), i.e. default_octave * 12 is MIDI for C in that octave region
    -- This makes bass likely lower than root_midi.
    local bass_midi = (default_octave) * 12 + bass_pc

    -- Remove one occurrence of same pitch class that is closest to bass_midi (so we don’t duplicate it).
    local bass_pc_mod12 = bass_pc % 12
    local remove_index = nil
    local best_dist = math.huge

    for i = 1, #notes do
      if notes[i] % 12 == bass_pc_mod12 then
        local d = math.abs(notes[i] - bass_midi)
        if d < best_dist then
          best_dist = d
          remove_index = i
        end
      end
    end

    if remove_index then
      table.remove(notes, remove_index)
    end

    table.insert(notes, bass_midi)
  end

  table.sort(notes)
  return notes
end

return Music