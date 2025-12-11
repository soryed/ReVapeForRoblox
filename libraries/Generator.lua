local Gen = {}
local base = {}
base.Strings = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789`~!@#$%^&*()_-+=|>.<,/?[{}]"
local Global = {
    LettersUPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    LettersLOWER = "abcdefghijklmnopqrstuvwxyz",
    Numbers = "0123456789",
    Symbols = "~`!@#$%^&*()-_=+{[]}|,<.>/?",
    Excludes = {"0","O","1","I","5","S","2","Z",'6',"G","9","g",'8',"B","M","W","@","a"}
}


local encodeMap = {}
local decodeMap = {}

for i = 1, #base.Strings do
    local c = base.Strings:sub(i,i)
    encodeMap[i-1] = c  
    decodeMap[c]    = i-1 
end

function base:Encode(str)
    local result = {}
    local buffer = 0
    local bits = 0
    for i = 1, #str do
        buffer = bit32.lshift(buffer, 8) + string.byte(str, i)
        bits = bits + 8
        while bits >= 6 do
            bits = bits - 6
            local index = bit32.rshift(buffer, bits)
            buffer = buffer - bit32.lshift(index, bits)
            result[#result+1] = encodeMap[index]
        end
    end
    if bits > 0 then
        local index = bit32.lshift(buffer, 6 - bits)
        result[#result+1] = encodeMap[index]
        result[#result+1] = "="
    end
    return table.concat(result)
end

function base:Decode(str)
    local result = {}
    local buffer = 0
    local bits = 0
    for i = 1, #str do
        local c = str:sub(i,i)
        if c == "=" then break end
        local val = decodeMap[c]
        if val then
            buffer = bit32.lshift(buffer, 6) + val
            bits = bits + 6
            while bits >= 8 do
                bits = bits - 8
                local byte = bit32.rshift(buffer, bits)
                buffer = buffer - bit32.lshift(byte, bits)
                result[#result+1] = string.char(byte)
            end
        end
    end
    return table.concat(result)
end

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
    local pool = Global.LettersUPPER..Global.LettersLOWER..Global.Numbers
    local username = {}
    
    for i = 1, Length do
        username[i] = pool:sub(math.random(1, #pool), math.random(1, #pool))
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
    local hex = Global.LettersLOWER..Global.Numbers

    local function randomHex(n)
        local t = {}
        for i = 1, n do
            t[i] = hex:sub(math.random(1, #hex), math.random(1, #hex))
        end
        return table.concat(t)
    end

    local uuid = string.format("%s-%s-4%s-%x%s-%s",
        randomHex(8),
        randomHex(4),
        randomHex(3),
        math.random(8,11),
        randomHex(3),
        randomHex(12)
    )

    return uuid
end

function Gen:GUID()
    local hex = Global.LettersUPPER..Global.Numbers

    local function randomHex(n)
        local t = {}
        for i = 1, n do
            t[i] = hex:sub(math.random(1, #hex), math.random(1, #hex))
        end
        return table.concat(t)
    end

    local guid = string.format("%s-%s-4%s-%x%s-%s",
        randomHex(12),
        randomHex(8),
        randomHex(6),
        math.random(11,21),
        randomHex(6),
        randomHex(18)
    )

    return "{"..guid.."}"
end

function Gen:HexToken(tbl)
    local Length = tonumber(tbl.Length) or 32
    if Length < 16 then Length = 32 end
    if Length > 128 then Length = 128 end

    local hex = Global.Numbers..Global.LettersUPPER..global.LettersLOWER
    local token = {}

    for i = 1, Length do
        token[i] = hex:sub(math.random(1, #hex), math.random(1, #hex))
    end

    local concat = table.concat(token)
    local encoded = base:Encode(concat)
    return encoded
end

function Gen:base()
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

function Gen:NanoID()
    local Length = tonumber(tbl.Length) or 21
    if Length < 8 then Length = 8 end
    if Length > 64 then Length = 64 end

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
