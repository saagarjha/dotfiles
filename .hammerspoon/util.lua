-- Shared utility functions

-- A "clamping" that keeps a number in a certain range
function clamp(n, min, max)
	return math.max(math.min(n, max), min)
end

-- Perform basic "fuzzy" matching
-- Return true if base contains the characters in query in the same order
function fuzzyMatch(base, query)
	base = base:lower():gsub("%s+", "")
	query = query:lower(): gsub("%s+", "")
	local patternQuery = ""
	for c in query:gmatch(".") do
		patternQuery = patternQuery .. "[^" .. c .. "]*" .. c
	end
	return string.match(base, patternQuery) ~= nil
end
