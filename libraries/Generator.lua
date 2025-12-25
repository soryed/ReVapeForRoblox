--creds to GoOnlineTools.com!

local Gen = {}
local Global = {
    LettersUPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    LettersLOWER = "abcdefghijklmnopqrstuvwxyz",
    Numbers = "0123456789",
    Symbols = "~`!@#$%^&*()-_=+{[]}|,<.>/?",
    Excludes = {"0","O","1","I","5","S","2","Z",'6',"G","9","g",'8',"B","M","W","@","a"}
}

local loadstring = function(...)
	local res, err = loadstring(...)
	if err then
		error('Onyx | Failed to load : '..err)
	end
	return res
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/qyroke2/ReVapeForRoblox/'..readfile('ReVape/profiles/commit.txt')..'/'..select(1, path:gsub('ReVape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local base = loadstring(downloadFile('ReVape/libraries/base64.lua'), 'base64')()

function Gen:APIToken(tbl)
	local Length = tonumber(tbl.Length) or 32
	if Length < 16 then Length = 32 end
	if Length > 128 then Length = 128 end

	local Sets = tbl.Sets or {}
	local UC = Sets.UC or false
	local LC = Sets.LC or false
	local N  = Sets.N  or false
	local S  = Sets.S  or false
	local E  = Sets.E  or false

	local pool = {}
	local function addChars(str)
		for i = 1, #str do
			local ch = str:sub(i,i)
			if not E or not table.find(Global.Excludes, ch) then
				table.insert(pool, ch)
			end
		end
	end

	if UC then addChars(Global.LettersUPPER) end
	if LC then addChars(Global.LettersLOWER) end
	if N  then addChars(Global.Numbers) end
	if S  then addChars(Global.Symbols) end

	if #pool == 0 then return "" end

	local token = {}
	for i = 1, Length do
		token[i] = pool[math.random(1, #pool)]
	end
	local concat = table.concat(token)
	local encoded = base:Encode(concat)
	return encoded
end

function Gen:Password(tbl)
	local Length = tonumber(tbl.Length) or 32
	if Length < 8 then Length = 32 end
	if Length > 128 then Length = 128 end

	local Sets = tbl.Sets or {}
	local UC = Sets.UC or false
	local LC = Sets.LC or false
	local N  = Sets.N  or false
	local S  = Sets.S  or false
	local E  = Sets.E  or false

	local pool = {}
	local function addChars(str)
		for i = 1, #str do
			local ch = str:sub(i,i)
			if not E or not table.find(Global.Excludes, ch) then
				table.insert(pool, ch)
			end
		end
	end

	if UC then addChars(Global.LettersUPPER) end
	if LC then addChars(Global.LettersLOWER) end
	if N  then addChars(Global.Numbers) end
	if S  then addChars(Global.Symbols) end

	if #pool == 0 then return "" end

	local token = {}
	for i = 1, Length do
		token[i] = pool[math.random(1, #pool)]
	end
	local concat = table.concat(token)
	return concat
end

function Gen:Username()
	local Length = 4
	local pool = Global.LettersUPPER .. Global.LettersLOWER .. Global.Numbers
	local username = {}

	for i = 1, Length do
		local index = math.random(1, #pool)
		username[i] = pool:sub(index, index)
	end

	return table.concat(username)
end

function Gen:Sessions(tbl)
	local Length = tonumber(tbl.Length) or 16
	if Length < 16 then Length = 16 end
	if Length > 128 then Length = 128 end

	local Sets = tbl.Sets or {}
	local UC = Sets.UC or false
	local LC = Sets.LC or false
	local N  = Sets.N  or false
	local S  = Sets.S  or false
	local E  = Sets.E  or false

	local pool = {}
	local function addChars(str)
		for i = 1, #str do
			local ch = str:sub(i,i)
			if not E or not table.find(Global.Excludes, ch) then
				table.insert(pool, ch)
			end
		end
	end

	if UC then addChars(Global.LettersUPPER) end
	if LC then addChars(Global.LettersLOWER) end
	if N  then addChars(Global.Numbers) end
	if S  then addChars(Global.Symbols) end

	if #pool == 0 then return "" end

	local token = {}
	for i = 1, Length do
		token[i] = pool[math.random(1, #pool)]
	end
	local concat = table.concat(token)
	local encoded = base:Encode(concat)
	local encodedv = base:Encode(encoded)
	return encodedv
end

function Gen:UUID()
	math.randomseed(os.clock() * 1e3)

	local hex = Global.LettersLOWER .. Global.Numbers

	local function randomHex(n)
		local t = {}
		for i = 1, n do
			local idx = math.random(1, #hex)
			t[i] = hex:sub(idx, idx)
		end
		return table.concat(t)
	end

	local uuid = string.format(
		"%s-%s-4%s-%x%s-%s",
		randomHex(8),
		randomHex(4),
		randomHex(3),
		math.random(8, 11),
		randomHex(3),
		randomHex(12)
	)

	return uuid
end

function Gen:GUID()
	math.randomseed(os.clock() * 1e6)
	local hex = Global.LettersUPPER .. Global.Numbers

	local function randomHex(n)
		local t = {}
		for i = 1, n do
			local idx = math.random(1, #hex)
			t[i] = hex:sub(idx, idx)
		end
		return table.concat(t)
	end

	local guid = string.format(
		"%s-%s-%s-%s-%s",
		randomHex(8),
		randomHex(4),
		randomHex(4),
		randomHex(4),
		randomHex(12)
	)

	return "{" .. guid .. "}"
end

function Gen:HexToken(tbl)
	local Length = tonumber(tbl.Length) or 32
	if Length < 16 then Length = 32 end
	if Length > 128 then Length = 128 end

	local hex = Global.Numbers..Global.LettersUPPER..Global.LettersLOWER
	local token = {}

	for i = 1, Length do
		token[i] = hex:sub(math.random(1, #hex), math.random(1, #hex))
	end

	local concat = table.concat(token)
	local encoded = base:Encode(concat)
	return encoded
end

function Gen:base(tbl)
	local Length = tonumber(tbl.Length) or 32
	if Length < 16 then Length = 32 end
	if Length > 128 then Length = 128 end

	local Sets = tbl.Sets or {}
	local UC = Sets.UC or false
	local LC = Sets.LC or false
	local N  = Sets.N  or false
	local S  = Sets.S  or false
	local E  = Sets.E  or false

	local pool = {}
	local function addChars(str)
		for i = 1, #str do
			local ch = str:sub(i,i)
			if not E or not table.find(Global.Excludes, ch) then
				table.insert(pool, ch)
			end
		end
	end

	if UC then addChars(Global.LettersUPPER) end
	if LC then addChars(Global.LettersLOWER) end
	if N  then addChars(Global.Numbers) end
	if S  then addChars(Global.Symbols) end

	if #pool == 0 then return "" end

	local token = {}
	for i = 1, Length do
		token[i] = pool[math.random(1, #pool)]
	end
	local concat = table.concat(token)
	local encoded = base:Encode(concat)
	local encoded2 = base:Encode(encoded)
	return encoded2
end

function Gen:NanoID(tbl)
	local Length = tonumber(tbl.Length) or 21
	if Length < 8 then Length = 8 end
	if Length > 64 then Length = 64 end

	local Sets = tbl.Sets or {}
	local UC = Sets.UC or false
	local LC = Sets.LC or false
	local N  = Sets.N  or false
	local S  = true
	local E  = Sets.E  or false

	local pool = {}
	local function addChars(str)
		for i = 1, #str do
			local ch = str:sub(i,i)
			if not E or not table.find(Global.Excludes, ch) then
				table.insert(pool, ch)
			end
		end
	end

	if UC then addChars(Global.LettersUPPER) end
	if LC then addChars(Global.LettersLOWER) end
	if N  then addChars(Global.Numbers) end
	if S  then addChars('_-') end

	if #pool == 0 then return "" end

	local token = {}
	for i = 1, Length do
		token[i] = pool[math.random(1, #pool)]
	end
	local concat = table.concat(token)
	return concat
end

return Gen
