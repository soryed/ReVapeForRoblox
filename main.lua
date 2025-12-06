repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

if identifyexecutor then
	if table.find({'Argon'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Onyx', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/qe40/ReVapeForRoblox/'..readfile('ReVape/profiles/commit.txt')..'/'..select(1, path:gsub('ReVape/', '')), true)
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
local function serializeValue(v)
    local t = type(v)
    if t == "string" then
        return ("%q"):format(v)
    elseif t == "number" or t == "boolean" or t == "nil" then
        return tostring(v)
    elseif t == "table" then
        local isArray = true
        local max = 0
        for k,_ in pairs(v) do
            if type(k) ~= "number" then isArray = false break end
            if k > max then max = k end
        end
        if isArray then
            local parts = {}
            for i = 1, max do
                table.insert(parts, serializeValue(v[i]))
            end
            return "{" .. table.concat(parts, ",") .. "}"
        else
            local parts = {}
            for k,val in pairs(v) do
                local key
                if type(k) == "string" and k:match("^[_%a][_%w]*$") then
                    key = k
                else
                    key = "[" .. serializeValue(k) .. "]"
                end
                table.insert(parts, key .. "=" .. serializeValue(val))
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    else
        return ("%q"):format(tostring(v))
    end
end

local function finishLoading()

	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)


	local teleportedServers
		vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
				
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then

					loadstring(readfile('ReVape/loader.lua'), 'loader')()
				else

					loadstring(game:HttpGet('https://raw.githubusercontent.com/soryed/OynxVAPEv4/'..readfile('ReVape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.VapeDeveloper then

				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
						
			end
			    if getgenv().username ~= nil then
        teleportScript = "getgenv().username = " .. serializeValue(getgenv().username) .. "\n" .. teleportScript
    end
    if getgenv().password ~= nil then
        teleportScript = "getgenv().password = " .. serializeValue(getgenv().password) .. "\n" .. teleportScript
    end
    if getgenv().SLS then
        teleportScript = "getgenv().SLS = true\n" .. teleportScript
    end
    if getgenv().SkipLoadingScreen then
        teleportScript = "getgenv().SkipLoadingScreen = true\n" .. teleportScript
    end
	if getgenv().TestMode then
        teleportScript = "getgenv().TestMode = true\n" .. teleportScript
    end
    if shared.VapeCustomProfile then
        teleportScript = "shared.VapeCustomProfile = " .. serializeValue(shared.VapeCustomProfile) .. "\n" .. teleportScript
    end

			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Onyx', "Initialized as " .. vape.user .. " with role " .. vape.role, 3)
			task.wait(2.75)
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end


if not isfile('ReVape/profiles/gui.txt') then
	writefile('ReVape/profiles/gui.txt', 'new')
end
local gui = readfile('ReVape/profiles/gui.txt')

if not isfolder('ReVape/assets/'..gui) then
	makefolder('ReVape/assets/'..gui)
end
vape = loadstring(downloadFile('ReVape/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape

if not shared.VapeIndependent then
	loadstring(downloadFile('ReVape/games/universal.lua'), 'universal')()
	if isfile('ReVape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('ReVape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/qe40/ReVapeForRoblox/'..readfile('ReVape/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('ReVape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
