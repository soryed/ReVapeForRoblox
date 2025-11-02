local gethui = gethui or function() return game:GetService('Players').LocalPlayer.PlayerGui end
local tweenService = game:GetService('TweenService')

local gui : ScreenGui = Instance.new('ScreenGui', gethui())
gui.Enabled = true

local stages = {
	UDim2.new(0, 50, 1, 0),
	UDim2.new(0, 100, 1, 0),
	UDim2.new(0, 160, 1, 0),
	UDim2.new(0, 200, 1, 0),
	UDim2.new(0, 240, 1, 0)
}

local createinstance = function(class, properties)
	local res = Instance.new(class)
	
	for property, value in properties do
		res[property] = value
	end

	return res
end

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/soryed/ReVapeForRoblox/'..readfile('ReVape/profiles/commit.txt')..'/'..select(1, path:gsub('ReVape/', '')), true)
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
if gui.Enabled then
	createinstance('ImageLabel', {
		Name = 'Main',
		Parent = gui,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(685, 399),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ScaleType = Enum.ScaleType.Fit,
		Image = 'rbxassetid://93496634716737'
	})

	createinstance('ImageButton', {
		Name = 'Exit',
		Parent = gui.Main,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(624, 23),
		Size = UDim2.fromOffset(40, 30),
		AutoButtonColor = false,
		ImageColor3 = Color3.fromRGB(34, 33, 34),
		Image = 'rbxassetid://110629770884920',
		ScaleType = Enum.ScaleType.Fit
	})

	createinstance('ImageLabel', {
		Name = 'Icon',
		Parent = gui.Main.Exit,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageTransparency = 0.4,
		ImageColor3 = Color3.new(1, 1, 1),
		Image = 'rbxassetid://14657521312',
		ScaleType = Enum.ScaleType.Fit
	})

	createinstance('ImageButton', {
		Name = 'Minimize',
		Parent = gui.Main,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(582, 23),
		Size = UDim2.fromOffset(40, 30),
		AutoButtonColor = false,
		ImageColor3 = Color3.fromRGB(34, 33, 34),
		Image = 'rbxassetid://133363055871405',
		ScaleType = Enum.ScaleType.Fit
	})

	createinstance('ImageLabel', {
		Name = 'Icon',
		Parent = gui.Main.Minimize,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageTransparency = 0.4,
		ImageColor3 = Color3.new(1, 1, 1),
		Image = 'rbxassetid://14657521312',
		ScaleType = Enum.ScaleType.Fit
	})

	createinstance('ImageLabel', {
		Name = 'textvape',
		Parent = gui.Main,
		AnchorPoint = Vector2.new(0.48, 0.31),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.48, 0.31),
		Size = UDim2.fromOffset(70, 70),
		Image = 'rbxassetid://14657521312',
		ScaleType = Enum.ScaleType.Fit
	})

	createinstance('ImageLabel', {
		Name = 'version',
		Parent = gui.Main.textvape,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(1, 0.3),
		Size = UDim2.fromOffset(29, 29),
		Image = 'rbxassetid://138794287840926',
		ImageColor3 = Color3.fromRGB(98, 198, 158),
		ScaleType = Enum.ScaleType.Fit
	})

	createinstance('Frame', {
		Name = 'loadbar',
		Parent = gui.Main,
		AnchorPoint = Vector2.new(0.5, 0.53),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.53),
		Size = UDim2.fromOffset(240, 6)
	})

	createinstance('Frame', {
		Name = 'fullbar',
		Parent = gui.Main.loadbar,
		BackgroundColor3 = Color3.fromRGB(3, 102, 79),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 2
	})


	createinstance('TextLabel', {
		Name = 'action',
		Parent = gui.Main,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.353284657, 0.556391001),
		Size = UDim2.fromOffset(200, 15),
		Font = Enum.Font.Arial,
		Text = '',
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 12,
		TextTransparency = 0.3
	})

	Instance.new('UICorner', gui.Main.loadbar)
	Instance.new('UICorner', gui.Main.loadbar.fullbar)
	Instance.new('UIScale', gui.Main).Scale = math.max(gui.AbsoluteSize.X / 1920, 0.485)
end;

getgenv().makestage = function(stage, package)
	pcall(function()
		tweenService:Create(gui.Main.loadbar.fullbar, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Size = stages[stage]
		}):Play()
		gui.Main.action.Text = package or ''
	end)
end

makestage(1, 'downloading packages.')
for _, folder in {'ReVape', 'ReVape/games', 'ReVape/profiles', 'ReVape/assets', 'ReVape/libraries', 'ReVape/guis'} do
	if not isfolder(folder) then
		makestage(1, `downloading packages\n({folder:gsub('ReVape', '')})`)
		makefolder(folder)
	end
	task.wait(0.05)
end

makestage(2, 'downloading important files.')
local folders = {'Revape/accounts'}

for _, folder in ipairs(folders) do
    if not isfolder(folder) then
		makestage(2, "downloading important files\n(" .. folder:gsub('Revape', '') .. ")")
        makefolder(folder)
    end
    local files = {folder .. '/username.txt', folder .. '/password.txt'}
    for _, txt in ipairs(files) do
        if not isfile(txt) then
			makestage(2, "downloading important files\n(" .. folder:gsub('Revape', '') .. ")")
            writefile(txt, "")
        end
        task.wait(0.05)
    end
    task.wait(0.05)
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function() 
		return game:HttpGet('https://github.com/soryed/ReVapeForRoblox') 
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

for _, v in gui:GetDescendants() do
	for __, prop in {'BackgroundTransparency', 'ImageTransparency', 'TextTransparency'} do
		task.spawn(pcall, function()
			tweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad), {
				[prop] = 1
			}):Play()
		end)
	end
end

return loadstring(downloadFile('ReVape/main.lua'), 'main')()
