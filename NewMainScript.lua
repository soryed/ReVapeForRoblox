local ARGS = ... or {}

local cloneref = cloneref or function(ref: Instance): Instance
    return ref    
end

local StarterGui: StarterGui = cloneref(game:GetService('StarterGui'))
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local function TTD()
	if not ARGS.ReVapeDev then
	    if isfolder('ReVape') then
	        for _, v: string in listfiles('ReVape') do
	            if not v:find('profiles')  and not v:find('accounts') then
	                if isfolder(v) then
	                    delfolder(v)
	                elseif isfile(v) then
	                    delfile(v)
	                end
	            end
	        end
	
	        if isfolder('ReVape/profiles') and isfile('ReVape/profiles/commit.txt') then
	            delfile('ReVape/profiles/commit.txt')
			else
				StarterGui:SetCore('SendNotification', {
				    Title = 'Onyx',
				    Text = 'Issue reinstalling Onyx! dm "20mop" on discord!',
				    Duration = 20
				})
	        end
	    end
	end
end
local function RTTD()
	delfolder('ReVape/profiles')
	delfolder('ReVape/games')
	delfolder('ReVape/guis')
	delfolder('ReVape/libraries')
	delfolder('ReVape/assets')
	delfile('ReVape/main.lua')
	return nil
end

if ARGS.Refresh then
    TTD()
	task.wait(0.5)
    if not isfolder('ReVape/games') then
		StarterGui:SetCore('SendNotification', {
			Title = 'Onyx',
			Text = 'Successfully reinstalling Onyx!!',
			Duration = 12
		})
    else
		StarterGui:SetCore('SendNotification', {
			Title = 'Onyx',
			Text = 'Issue reinstalling Onyx! dm "20mop" on discord!',
			Duration = 20
		})
	end
	return nil
end

if ARGS.ForceRefresh then
    RTTD()
	task.wait(0.5)
   if not isfile('ReVape/main.lua') then
		StarterGui:SetCore('SendNotification', {
			Title = 'Onyx',
			Text = 'Successfully force deleted Onyx!!',
			Duration = 12
		})
    else
		StarterGui:SetCore('SendNotification', {
			Title = 'Onyx',
			Text = 'Issue force deleting Onyx! dm "20mop" on discord!',
			Duration = 20
		})
	end
	return nil
end


if getgenv().username  and next(ARGS) == nil then
	ARGS.username = getgenv().username
	ARGS.password = getgenv().password
end
if typeof(ARGS) ~= "table" then
	getgenv().username = 'GUEST' 
	getgenv().password = 'PASSWORD' 
end
getgenv().username = ARGS.username
getgenv().password = ARGS.password
getgenv().TestMode = ARGS.TestMode or false
getgenv().Closet = ARGS.Closet or false

local tweenService = cloneref(game:GetService('TweenService'))



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

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end


for _, folder in {'ReVape', 'ReVape/games', 'ReVape/profiles', 'ReVape/assets', 'ReVape/libraries', 'ReVape/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
	task.wait(0.05)
end


local folders = {'ReVape/accounts'}

for _, folder in ipairs(folders) do
    if not isfolder(folder) then
        makefolder(folder)
    end
    local files = {folder .. '/username.txt', folder .. '/password.txt'}
    for _, txt in ipairs(files) do
        if not isfile(txt) then
            writefile(txt, "")
        end
        task.wait(0.05)
    end
    task.wait(0.05)
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function() 
		return game:HttpGet('https://github.com/qyroke2/ReVapeForRoblox') 
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('ReVape/profiles/commit.txt') and readfile('ReVape/profiles/commit.txt') or '') ~= commit then
		wipeFolder('ReVape')
		wipeFolder('ReVape/games')
		wipeFolder('ReVape/guis')
		wipeFolder('ReVape/libraries')
	end
	writefile('ReVape/profiles/commit.txt', commit)
end

return loadstring(downloadFile('ReVape/main.lua'), 'main')()
