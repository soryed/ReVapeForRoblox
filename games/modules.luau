if game.PlaceId == 6872265039 then
	local run = function(func) func() end
local cloneref = cloneref or function(obj) return obj end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local inputService = cloneref(game:GetService('UserInputService'))

local lplr = playersService.LocalPlayer
local vape = shared.vape
local entitylib = vape.Libraries.entity
local sessioninfo = vape.Libraries.sessioninfo
local bedwars = {}
local role = vape.role or "guest"
local user = vape.user or "GUEST"


local function notif(...)
	return vape:CreateNotification(...)
end

run(function()
	local function dumpRemote(tab)
		local ind = table.find(tab, 'Client')
		return ind and tab[ind + 1] or ''
	end

	local KnitInit, Knit
	repeat
		KnitInit, Knit = pcall(function() return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 9) end)
		if KnitInit then break end
		task.wait()
	until KnitInit
	if not debug.getupvalue(Knit.Start, 1) then
		repeat task.wait() until debug.getupvalue(Knit.Start, 1)
	end
	local Flamework = require(replicatedStorage['rbxts_include']['node_modules']['@flamework'].core.out).Flamework
	local Client = require(replicatedStorage.TS.remotes).default.Client

	bedwars = setmetatable({
		Client = Client,
		CrateItemMeta = debug.getupvalue(Flamework.resolveDependency('client/controllers/global/reward-crate/crate-controller@CrateController').onStart, 3),
		Store = require(lplr.PlayerScripts.TS.ui.store).ClientStore
	}, {
		__index = function(self, ind)
			rawset(self, ind, Knit.Controllers[ind])
			return rawget(self, ind)
		end
	})

	local kills = sessioninfo:AddItem('Kills')
	local beds = sessioninfo:AddItem('Beds')
	local wins = sessioninfo:AddItem('Wins')
	local games = sessioninfo:AddItem('Games')

	vape:Clean(function()
		table.clear(bedwars)
	end)
end)

for _, v in vape.Modules do
	if v.Category == 'Combat' or v.Category == 'Minigames' then
		vape:Remove(i)
	end
end
run(function()	
	NM = vape.Categories.Minigames:CreateModule({
		Name = 'Nightmare Emote',
		Tooltip = 'Client-Sided nightmare emote, animation is Server-Side visuals are Client-Sided',
		Function = function(callback)
			if callback then				
				local l__TweenService__9 = game:GetService("TweenService")
				local player = game:GetService("Players").LocalPlayer
				local p6 = player.Character
				
				if not p6 then return end
				
				local v10 = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("NightmareEmote"):Clone();
				asset = v10
				v10.Parent = game.Workspace
				lastPosition = p6.PrimaryPart and p6.PrimaryPart.Position or Vector3.new()
				
				task.spawn(function()
					while asset ~= nil do
						local currentPosition = p6.PrimaryPart and p6.PrimaryPart.Position
						if currentPosition and (currentPosition - lastPosition).Magnitude > 0.1 then
							asset:Destroy()
							asset = nil
							NM:Toggle()
							break
						end
						lastPosition = currentPosition
						v10:SetPrimaryPartCFrame(p6.LowerTorso.CFrame + Vector3.new(0, -2, 0));
						task.wait()
					end
				end)
				
				local v11 = v10:GetDescendants();
				local function v12(p8)
					if p8:IsA("BasePart") then
						p8.CanCollide = false;
						p8.Anchored = true;
					end;
				end;
				for v13, v14 in ipairs(v11) do
					v12(v14, v13 - 1, v11);
				end;
				local l__Outer__15 = v10:FindFirstChild("Outer");
				if l__Outer__15 then
					l__TweenService__9:Create(l__Outer__15, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = l__Outer__15.Orientation + Vector3.new(0, 360, 0)
					}):Play();
				end;
				local l__Middle__16 = v10:FindFirstChild("Middle");
				if l__Middle__16 then
					l__TweenService__9:Create(l__Middle__16, TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = l__Middle__16.Orientation + Vector3.new(0, -360, 0)
					}):Play();
				end;
                anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://9191822700"
				anim = p6.Humanoid:LoadAnimation(anim)
				anim:Play()
			else 
                if anim then 
					anim:Stop()
					anim = nil
				end
				if asset then
					asset:Destroy() 
					asset = nil
				end
			end
		end
	})
end)



run(function()
	GetExecutor = vape.Categories.Minigames:CreateModule({
		Name = "GetExecutor",
		Tooltip = "gets ur current exectuor(USED FOR DEBUGGING)",
		Function = function(callback)
			if callback then
				task.spawn(function()
				GetExecutor:Toggle(false)
				local timer = 4.5
					vape:CreateNotification('Onyx', "Currently searching for your executor", timer)
					if identifyexecutor then
					task.wait(timer + 0.5)
						vape:CreateNotification("Onyx", "Could find your executor '"..identifyexecutor().."'", 20)
					else
						vape:CreateNotification("Onyx", "Couldn't find your function 'identifyexecutor' for your executor", 5,"alert")
					end
				end)
			end
		end	
	})
end)

																																									
run(function()
    local Users = {
        KnownUsers = {
            Chase = {22808138, 4782733628, 7447190808, 3196162848},
            Orion = {547598710, 5728889572, 4652232128, 7043591647, 7209929547, 7043958628, 7418525152, 3774791573, 8606089749},
            LisNix = {162442297, 702354331, 9350301723},
            Nwr = {307212658, 5097000699, 4923561416},
            Gorilla = {514679433, 2431747703, 4531785383},
            Typhoon = {2428373515, 7659437319},
            Erin = {2465133159},
            Ghost = {7558211130, 1708400489,9554637663},
            Sponge = {376388734, 5157136850},
            Gora = {589533315, 567497793},
            Apple = {334013471, 145981200, 4721068661, 8006518573, 3547758846, 7155624750, 7468661659},
            Dom = {239431610, 2621170992},
            Kevin = {575474067, 4785639950, 8735055832},
            Vic = {839818760, 1524739259},
        },
        UnknownUsers = {
            7547477786, 7574577126, 5816563976, 240526951, 7587479685, 7876617827,
            2568824396, 7604102307, 7901878324, 5087196317, 7187604802, 7495829767,
            7718511355, 7928472983, 7922414080, 7758683476, 4079687909, 1160595313
        }
    }

    local ACMOD
    local Side
    local Specific
    local IncludeOffline
    local IncludeStudio

    ACMOD = vape.Categories.Exploits:CreateModule({
        Name = 'Anti-Cheat Mods',
        Tooltip = "Fetches all AC mod users (including unknowns)",
        Function = function()
            vape:CreateNotification('ReVape', "Currently fetching mods", 3)
            task.wait(4)

            local HttpService = game:GetService("HttpService")
            local Players = game:GetService("Players")

            local Offline, InGame, Online, Studio = 0, 0, 0, 0
            local url = "https://presence.roproxy.com/v1/presence/users"
            local data = {userIds = {}}

            if Side and Side.Value == "Known" then
                if Specific and Specific.Value == "All" then
                    for _, numbers in pairs(Users.KnownUsers) do
                        for _, num in ipairs(numbers) do
                            table.insert(data.userIds, num)
                        end
                    end
                elseif Specific and Users.KnownUsers[Specific.Value] then
                    for _, num in ipairs(Users.KnownUsers[Specific.Value]) do
                        table.insert(data.userIds, num)
                    end
                end
            elseif Side and Side.Value == "Unknown" then
                for _, num in ipairs(Users.UnknownUsers) do
                    table.insert(data.userIds, num)
                end
            end

            if #data.userIds == 0 then
                vape:CreateNotification('No Users Selected', "Pick a Side/Specific to fetch", 5, "alert")
                return
            end

            local jsonData = HttpService:JSONEncode(data)
            local response
            local success, err = pcall(function()
                response = HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
            end)

            if success and response then
                local okDecode, result = pcall(function()
                    return HttpService:JSONDecode(response)
                end)

                if not okDecode or not result then
                    vape:CreateNotification('Failed!', "Failed to decode presence JSON", 15, "alert")
                    return
                end

                if result.userPresences then
                    for _, user in pairs(result.userPresences) do
                        local username = tostring(user.userId)
                        local okName, nameOrErr = pcall(function()
                            return Players:GetNameFromUserIdAsync(user.userId)
                        end)
                        if okName and nameOrErr then
                            username = nameOrErr
                        end

                        if user.userPresenceType == 0 then
                            Offline = Offline + 1
                            if IncludeOffline and IncludeOffline.Value then
                                vape:CreateNotification('Offline Mod detected!', username, 5, "alert")
                            end
                        elseif user.userPresenceType == 1 then 
                            Online = Online + 1
                            vape:CreateNotification('Online Mod detected!', username, 15, "warning")
                        elseif user.userPresenceType == 2 then 
                            InGame = InGame + 1
                            vape:CreateNotification('InGame Mod detected!', username, 15, "warning")
                        elseif user.userPresenceType == 3 then 
                            Studio = Studio + 1
                            if IncludeStudio and IncludeStudio.Value then
                                vape:CreateNotification('Studio Mod detected!', username, 5, "warning")
                            end
                        end
                    end
                end

                task.wait(5)
                if InGame >= 2 then
                    vape:CreateNotification('Multiple Mods In-Game!', "There are [" .. InGame .. "] mods in game", 45)
                elseif InGame == 0 then
                    vape:CreateNotification('No Mods In-Game!', "There are none in-game", 45)
                end

                if Online >= 2 then
                    vape:CreateNotification('Multiple Mods Online!', "There are [" .. Online .. "] mods online", 45)
                elseif Online == 0 then
                    vape:CreateNotification('No Mods Online!', "There are none online", 45)
                end
            else
                vape:CreateNotification('ReVape', "Failed to get presence data: " .. tostring(err), 15, "alert")
            end
        end
    })

    Side = ACMOD:CreateDropdown({
        Name = "Version",
        List = {'Known', 'Unknown'},
    })

    Specific = ACMOD:CreateDropdown({
        Name = "Specific",
        Tooltip = 'Fetch a specific user (mains and alts)',
        List = {'All', 'Chase', 'Orion', 'LisNix', 'Nwr', 'Gorilla', 'Typhoon', 'Vic', 'Erin', 'Ghost', 'Sponge', 'Apple', 'Dom', 'Gora', 'Kevin'},
    })

    IncludeStudio = ACMOD:CreateToggle({
        Name = "Include Studio",
        Tooltip = "Include when a mod is in studio",
        Default = false
    })

    IncludeOffline = ACMOD:CreateToggle({
        Name = "Include Offline",
        Tooltip = "Include when a mod is offline",
        Default = false
    })
end)

run(function()
    local UsersList = {
        22808138, 4782733628, 7447190808, 3196162848,
        547598710, 5728889572, 4652232128, 7043591647, 7209929547, 7043958628, 7418525152, 3774791573, 8606089749,
        162442297, 702354331, 9350301723,
        307212658, 5097000699, 4923561416,
        514679433, 2431747703, 4531785383,
        2428373515, 7659437319,
        2465133159,
        7558211130, 1708400489,
        376388734, 5157136850,
        589533315, 567497793,
        334013471, 145981200, 4721068661, 8006518573, 3547758846, 7155624750, 7468661659,
        239431610, 2621170992,
        575474067, 4785639950, 8735055832,
        839818760, 1524739259,
        7547477786, 7574577126, 5816563976, 240526951, 7587479685, 7876617827,
        2568824396, 7604102307, 7901878324, 5087196317, 7187604802, 7495829767,
        7718511355, 7928472983, 7922414080, 7758683476, 4079687909, 1160595313
    }

    local UsersSet = {}
    for _, id in ipairs(UsersList) do
        UsersSet[id] = true
    end

    local playersService = game:GetService("Players")
    local lplr = playersService.LocalPlayer
    local joined = {} 

    local StaffDetector
    local Party
    local IncludeSpecs
    local CreateLogsOfMODS

    local function notif(title, body, duration, typ)
        if vape and vape.CreateNotification then
            vape:CreateNotification(title, body, duration or 5, typ)
        else
            print(("NOTIF [%s] %s"):format(title, body))
        end
    end

    local function checkFriends(list)
        for _, v in ipairs(list) do
            local id = v
            if type(v) == "table" and v.Id then id = v.Id end
            if joined[id] then
                return joined[id]
            end
        end
        return nil
    end

local function staffFunction(plr, checktype, checktypee)
    if not vape or not vape.Loaded then
        repeat task.wait() until vape and vape.Loaded
    end
if checktype == "spectator_join" then

else
notif('StaffDetector', 'Staff Detected ('..checktype..'): '..plr.Name..' ('..plr.UserId..')', 60, checktypee)
end
    

    if whitelist and whitelist.customtags then
        whitelist.customtags[plr.Name] = {{text = 'GAME STAFF', color = Color3.new(1, 0, 0)}}
    end


    if Party and Party.Enabled then
        if checktype == "impossible_join" or checktype == "detected_mod_join" then
            if bedwars and bedwars.PartyController and bedwars.PartyController.leaveParty then
                pcall(function()
                    bedwars.PartyController:leaveParty()
                end)
            end
        end
    end

    if CreateLogsOfMODS and CreateLogsOfMODS.Enabled then
        local Format
        local date = DateTime.now():ToLocalTime():ToTable()
        local dateString = string.format("%02d/%02d/%04d %02d:%02d:%02d", 
            date.month, date.day, date.year, date.hour, date.min, date.sec
        )

        if checktype == "impossible_join" then
            Format = "[USERNAME]:"..plr.Name.."|"..
                     "[USERID]:"..plr.UserId.."|"..
                     "[DATE]:"..dateString.."|"..
                     "[TYPE]:[IMPOSSIBLE JOIN]\n"

        elseif checktype == "detected_mod_join" then
            Format = "[USERNAME]:"..plr.Name.."|"..
                     "[USERID]:"..plr.UserId.."|"..
                     "[DATE]:"..dateString.."|"..
                     "[TYPE]:[KNOWN MOD JOIN]\n"

        elseif checktype == "spectator_join" then
            Format = "[USERNAME]:"..plr.Name.."|"..
                     "[USERID]:"..plr.UserId.."|"..
                     "[DATE]:"..dateString.."|"..
                     "[TYPE]:[SPECTATOR JOIN]\n"
        end
if Format then
    local path = "ReVape/profiles/logs.txt"

    if not isfolder("ReVape/profiles") then
        makefolder("ReVape/profiles")
    end

    if not isfile(path) then
        writefile(path, Format)
    else
        local prev = readfile(path)
        writefile(path, prev .. Format)
    end
end
     end
end
    local function checkJoin(plr, connection)
        if not plr or not plr.UserId then return false end

        local spectatorAttr = plr:GetAttribute('Spectator')
        local teamAttr = plr:GetAttribute('Team')
        local isCustomMatch = false
        if bedwars and bedwars.Store and bedwars.Store.getState then
            local ok, state = pcall(bedwars.Store.getState, bedwars.Store)
            if ok and state and state.Game and state.Game.customMatch then
                isCustomMatch = true
            end
        end

        if (not teamAttr) and spectatorAttr and not isCustomMatch then
            if connection then connection:Disconnect() end

            local tab = {}
            local success, pages = pcall(function()
                return playersService:GetFriendsAsync(plr.UserId)
            end)

            if not success or not pages then
                staffFunction(plr, 'impossible_join','warning')
                return true
            end

            for _ = 1, 4 do
                local currentPage = pages:GetCurrentPage()
                for _, v in ipairs(currentPage) do
                    table.insert(tab, v.Id or v.id or v.Id)
                end
                if pages.IsFinished then break end
                pages:AdvanceToNextPageAsync()
            end

            local friend = checkFriends(tab)
            if not friend then
                staffFunction(plr, 'impossible_join','warning')
                return true
            elseif UsersSet[plr.UserId] then
                staffFunction(plr, 'detected_mod_join','alert')
                return true
            else
                if IncludeSpecs and IncludeSpecs.Enabled then
                    notif('StaffDetector', string.format('Spectator %s joined from %s', plr.Name, tostring(friend)), 20, 'warning')
                    if CreateLogsOfMODS and CreateLogsOfMODS.Enabled then
                        staffFunction(plr, "spectator_join", 'info')
                    end
                end
            end
        end

        return false
    end

    local function playerAdded(plr)
        if not plr then return end
        joined[plr.UserId] = plr.Name
        if plr == lplr then return end

        local connection
        connection = plr:GetAttributeChangedSignal('Spectator'):Connect(function()
            checkJoin(plr, connection)
        end)
        if StaffDetector and StaffDetector.Clean then
            StaffDetector:Clean(connection)
        end

        if checkJoin(plr, connection) then
            return
        end
    end

    StaffDetector = vape.Categories.Utility:CreateModule({
        Name = 'StaffDetectorV2',
        Function = function(callback)
            if callback then
                if playersService and playersService.PlayerAdded then
                    StaffDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
                end
                for _, v in ipairs(playersService:GetPlayers()) do
                    task.spawn(playerAdded, v)
                end
            else
                table.clear(joined)
            end
        end,
        Tooltip = 'A Newer verison of Staff-Detector'
    })

    Party = StaffDetector:CreateToggle({
        Name = 'Leave party',
        Default = true,
    })
    IncludeSpecs = StaffDetector:CreateToggle({
        Name = 'Include Spectators',
        Tooltip = 'NOTE: Anti-Cheat mods could create new alts, ill say to keep this on to get the new username. BUT THIS CAN DO FALSE DETECTIONS!!',
        Default = true,
    })
    CreateLogsOfMODS = StaffDetector:CreateToggle({
        Name = 'Logs',
        Default = false,
        Tooltip = 'all this does is keep track of every mod/spectators has joined you with a date'
    })
end)


run(function()
  local Players = game:GetService("Players")
local player = Players.LocalPlayer
    local PlayerLevel
	local level 
  

PlayerLevel = vape.Categories.Exploits:CreateModule({
        Name = 'SetPlayerLevel',
	Tooltip = "Sets your player level to 100 (client sided)",
        Function = function(callback)
				notif("SetPlayerLevel", "This is client sided (only u will see the new level)", 3,"warning")
				game.Players.LocalPlayer:SetAttribute("PlayerLevel", level.Value)
	end
})

level = PlayerLevel:CreateSlider({
        Name = 'Player Level',
        Min = 1,
        Max = 1000,
        Default = 100,
	Function = function(val)
	    player:SetAttribute("PlayerLevel", val)
	end
    })
end)
run(function()
    local QueueDisplayConfig = {
        ActiveState = false,
        GradientControl = {Enabled = true},
        ColorSettings = {
            Gradient1 = {Hue = 0, Saturation = 0, Brightness = 1},
            Gradient2 = {Hue = 0, Saturation = 0, Brightness = 0.8}
        },
        Animation = {Speed = 0.5, Progress = 0}
    }

    local DisplayUtils = {
        createGradient = function(parent)
            local gradient = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
            gradient.Parent = parent
            return gradient
        end,
        updateColor = function(gradient, config)
            local time = tick() * config.Animation.Speed
            local interp = (math.sin(time) + 1) / 2
            local h = config.ColorSettings.Gradient1.Hue + (config.ColorSettings.Gradient2.Hue - config.ColorSettings.Gradient1.Hue) * interp
            local s = config.ColorSettings.Gradient1.Saturation + (config.ColorSettings.Gradient2.Saturation - config.ColorSettings.Gradient1.Saturation) * interp
            local b = config.ColorSettings.Gradient1.Brightness + (config.ColorSettings.Gradient2.Brightness - config.ColorSettings.Gradient1.Brightness) * interp
            gradient.Color = ColorSequence.new(Color3.fromHSV(h, s, b))
        end
    }

	local CoreConnection

    local function enhanceQueueDisplay()
		pcall(function() 
			CoreConnection:Disconnect()
		end)
        local success, err = pcall(function()
            if not lplr.PlayerGui:FindFirstChild('QueueApp') then return end
            
            for attempt = 1, 3 do
                if QueueDisplayConfig.GradientControl.Enabled then
                    local queueFrame = lplr.PlayerGui.QueueApp['1']
                    queueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    
                    local gradient = DisplayUtils.createGradient(queueFrame)
                    gradient.Rotation = 180
                    
                    local displayInterface = {
                        module = vape.watermark,
                        gradient = gradient,
                        GetEnabled = function()
                            return QueueDisplayConfig.ActiveState
                        end,
                        SetGradientEnabled = function(state)
                            QueueDisplayConfig.GradientControl.Enabled = state
                            gradient.Enabled = state
                        end
                    }
                    CoreConnection = game:GetService("RunService").RenderStepped:Connect(function()
                        if QueueDisplayConfig.ActiveState and QueueDisplayConfig.GradientControl.Enabled then
                            DisplayUtils.updateColor(gradient, QueueDisplayConfig)
                        end
                    end)
                end
                task.wait(0.1)
            end
        end)
        
        if not success then
            warn("Queue display enhancement failed: " .. tostring(err))
        end
    end

    local QueueDisplayEnhancer
    QueueDisplayEnhancer = vape.Categories.Utility:CreateModule({
        Name = 'QueueCardMods',
        Tooltip = 'Enhances the Queues display with dynamic gradients!!',
        Function = function(enabled)
            QueueDisplayConfig.ActiveState = enabled
            if enabled then
                enhanceQueueDisplay()
                QueueDisplayEnhancer:Clean(lplr.PlayerGui.ChildAdded:Connect(enhanceQueueDisplay))
			else
				pcall(function() 
					CoreConnection:Disconnect()
				end)
			end
        end
    })

   	QueueDisplayEnhancer:CreateSlider({
        Name = "Animation Speed",
        Function = function(speed)
            QueueDisplayConfig.Animation.Speed = math.clamp(speed, 0.1, 5)
        end,
        Min = 1,
        Max = 6,
        Default = 5
    })

    QueueDisplayEnhancer:CreateColorSlider({
        Name = "Color 1",
        Function = function(h, s, v)
            QueueDisplayConfig.ColorSettings.Gradient1 = {Hue = h, Saturation = s, Brightness = v}
        end
    })

    QueueDisplayEnhancer:CreateColorSlider({
        Name = "Color 2",
        Function = function(h, s, v)
            QueueDisplayConfig.ColorSettings.Gradient2 = {Hue = h, Saturation = s, Brightness = v}
        end
    })
end)
run(function()
	local TAG
	local CustomTAG
	local R, G, B
	local Org = ""
	local OrgText = ""
	local player = game:GetService('Players').LocalPlayer

	if not player:FindFirstChild("Tags") then
		notif("Onyx", "Couldn't find the folder 'Tags' to change your tag", 20, "alert")
		return
	end

	local tagObj = player.Tags:FindFirstChild("0")
	if not tagObj then
		notif("Onyx", "Couldn't find any tag inside 'Tags'", 20, "alert")
		return 	end

	local function Color3ToHex(r, g, b)
		return string.lower(string.format("#%02X%02X%02X", r, g, b))
	end

	Org = tagObj.Value
	OrgText = tagObj:GetAttribute("Text")

	CustomTAG = vape.Categories.Troll:CreateModule({
		Name = "CustomTag",
		Function = function(callback)
			if callback then
				tagObj.Value = string.format(
					"<font color='rgb(%s,%s,%s)'>[%s]</font>",
					R.Value, G.Value, B.Value, TAG.Value
				)
				tagObj:SetAttribute("Text", TAG.Value)
				player:SetAttribute("ClanTag", TAG.Value)

				local player = game.Players.LocalPlayer

				local function Color3ToHex(color)
					return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
				end

				player.PlayerGui.ChildAdded:Connect(function(child)
					if child.Name == "TabListScreenGui" and child:IsA("ScreenGui") then
						task.spawn(function()
							while CustomTAG.Enabled do
								for _, v in ipairs(child:GetDescendants()) do
									if v:IsA("TextLabel") then
										local nameToFind = (player.DisplayName == "" or player.DisplayName == player.Name)
											and player.Name
											or player.DisplayName

										if string.find(string.lower(v.Text), string.lower(nameToFind)) then
											v.Text = string.format(
												'<font transparency="0.3" color="%s">[%s]</font> %s',
												Color3ToHex(Color3.fromRGB(R.Value, G.Value, B.Value)),
												TAG.Value,
												nameToFind
											)
										end
									end
								end
								task.wait()
							end

							for _, v in ipairs(child:GetDescendants()) do
								if v:IsA("TextLabel") then
									local nameToFind = (player.DisplayName == "" or player.DisplayName == player.Name)
										and player.Name
										or player.DisplayName

									if string.find(string.lower(v.Text), string.lower(nameToFind)) then
										v.Text = string.format(
											'<font transparency="0.3" color="%s">[%s]</font> %s',
											Color3ToHex(Color3.fromRGB(255, 255, 255)),
											tagObj:GetAttribute("Text"),
											nameToFind
										)
									end
								end
							end
						end)
					end
				end)
			else
				tagObj.Value = Org
				tagObj:SetAttribute("Text", OrgText)
				player:SetAttribute("ClanTag", OrgText)
			end
		end,
		Tooltip = "Client-Sided visual custom clan tag on-chat",
	})

	TAG = CustomTAG:CreateTextBox({
		Name = "Tag Text",
		Placeholder = "",
		Function = function()
			CustomTAG:Toggle()
			task.wait()
			CustomTAG:Toggle()
		end,
	})

	R = CustomTAG:CreateSlider({
		Name = "R",
		Min = 0,
		Max = 255,
		Default = 255,
		Function = function()
			CustomTAG:Toggle()
			task.wait()
			CustomTAG:Toggle()
		end,
	})

	G = CustomTAG:CreateSlider({
		Name = "G",
		Min = 0,
		Max = 255,
		Default = 255,
		Function = function()
			CustomTAG:Toggle()
			task.wait()
			CustomTAG:Toggle()
		end,
	})

	B = CustomTAG:CreateSlider({
		Name = "B",
		Min = 0,
		Max = 255,
		Default = 255,
		Function = function()
			CustomTAG:Toggle()
			task.wait()
			CustomTAG:Toggle()
		end,
	})
end)
run(function()
	local ViewProfiles
	local lplr = game.Players.LocalPlayer
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local function create(name, props)
		local obj = Instance.new(name)
		for k, v in pairs(props) do
			if type(k) == "number" then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end

	local function CreateProfile()
		local Profile = create("ScreenGui", {
			Name = "Profile",
			DisplayOrder = 30,
			ResetOnSpawn = false,
			Parent = lplr:WaitForChild("PlayerGui"),
			IgnoreGuiInset = true
		})

		local BackgroundProfileUI = create("ImageButton", {
			Name = "Background",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.6,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(2, 2),
			Parent = Profile
		})

		local MainProfileFrame = create("Frame", {
			Name = "Main",
			Parent = Profile,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1)
		})

		local MainMainBG = create("ImageButton", {
			Name = "MainBG",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromOffset(800, 700),
			Parent = MainProfileFrame
		})

		create("UIAspectRatioConstraint", { Parent = MainMainBG, AspectRatio = 1.143 })
		create("UIScale", { Parent = MainMainBG, Scale = 1.297 })

		local IconButtonWrapper = create("ImageButton", {
			Name = "IconButtonWrapper",
			Parent = MainMainBG,
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -4, 0, 4),
			Size = UDim2.fromOffset(40, 40)
		})
		create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = IconButtonWrapper })
		create("UIPadding", {
			PaddingBottom = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
			PaddingTop = UDim.new(0.1, 0),
			Parent = IconButtonWrapper
		})
		create("ImageLabel", {
			Name = "Icon",
			Parent = IconButtonWrapper,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 100,
			Image = "rbxassetid://6693945013",
			ImageTransparency = 0.2
		})

		local FrameMainBG = create("Frame", {
			Parent = MainMainBG,
			BackgroundColor3 = Color3.fromRGB(100, 103, 167),
			Size = UDim2.fromScale(1, 1)
		})
		create("UICorner", { CornerRadius = UDim.new(0.05, 0), Parent = FrameMainBG })
		create("UIListLayout", {
			Parent = FrameMainBG,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local UserFrame = create("Frame", {
			Name = "UserFrame",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(78, 80, 130),
			Parent = FrameMainBG
		})
		create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = UserFrame })

		local BGImage = create("ImageLabel", {
			Name = "BGImage",
			Parent = UserFrame,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.05, 0.05),
			Size = UDim2.new(0.9, 0, 0.9, 0),
			Image = "rbxassetid://71356717298935",
			ScaleType = Enum.ScaleType.Crop,
			ImageTransparency = 0.38
		})
		create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = BGImage })

		create("TextLabel", {
			Name = "Title",
			Parent = UserFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.043, 0, 0, 0),
			Size = UDim2.new(0, 703, 0, 46),
			Text = "⚠️⚠️ PLEASE NOTE: USER MUST BE INGAME ⚠️⚠️",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.SemiBold),
			TextScaled = true
		})

		local err = create("TextLabel", {
			Name = "Error",
			Parent = UserFrame,
			Visible = false,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.066, 0, 0.3, 0),
			Size = UDim2.new(0, 703, 0, 46),
			TextColor3 = Color3.fromRGB(213, 48, 48),
			Text = "[ERROR]:",
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.SemiBold),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local RequestHistory = create("TextButton", {
			Name = "RequestHistory",
			Parent = UserFrame,
			BackgroundTransparency = 0.15,
			BackgroundColor3 = Color3.fromRGB(85, 170, 127),
			Position = UDim2.new(0.066, 0, 0.176, 0),
			Size = UDim2.new(0, 683, 0, 62),
			Text = "Request history",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Regular, Enum.FontStyle.Italic),
			TextSize = 24
		})
		create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = RequestHistory })

		local textbox = create("TextBox", {
			Name = "UserTextbox",
			Parent = UserFrame,
			BackgroundColor3 = Color3.fromRGB(95, 99, 159),
			Position = UDim2.new(0.066, 0, 0.066, 0),
			ShowNativeInput = false,
			Size = UDim2.new(0, 685, 0, 54),
			Text = "",
			PlaceholderText = "@Roblox",
			TextColor3 = Color3.fromRGB(155, 155, 155),
			TextSize = 32,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Italic)
		})


		local function HandleRequest()
			local plrrr = Players:FindFirstChild(textbox.Text)
			if not plrrr then
				notif('Onyx', "Player does not exist ingame", 10, "alert")
				return
			end

			local userid = plrrr.UserId
			local netFolder = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged

			bedwars.Client:Get("NametagDataRequest"):CallServerAsync(plrrr.UserId)
			bedwars.Client:Get("RequestMatchHistory"):CallServerAsync(userid)

			ViewProfiles:Toggle(false)
		end
																				
		ViewProfiles:Clean(textbox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				HandleRequest()
			end
		end))

		ViewProfiles:Clean(RequestHistory.MouseButton1Click:Connect(HandleRequest))

		ViewProfiles:Clean(IconButtonWrapper.MouseButton1Click:Connect(function()
			ViewProfiles:Toggle()
		end))
	end

	local function DestroyProfile()
		local p = lplr.PlayerGui:FindFirstChild("Profile")
		if p then p:Destroy() end
	end

	ViewProfiles = vape.Categories.Exploits:CreateModule({
		Name = "ViewProfile",
		Function = function(callback)
			   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			if callback then
				CreateProfile()
			else
				DestroyProfile()
			end
		end,
		Tooltip = "Allows you to see other players' profiles"
	})
end)

run(function()
	local SetFPS
	local FPS
	
	SetFPS = vape.Categories.Utility:CreateModule({
		Name = "SetFPS",
		Function = function(callback)
			

			if callback then
				setfpscap(FPS.Value)
			else
				setfpscap(240)
			end
		end,
		Tooltip = "Removes or customizes the Frame-Per-Second limit",
	})
	
	FPS = SetFPS:CreateSlider({
		Name = "Frames Per Second",
		Min = 0,
		Max = 420,
		Default = 240,
		Function = function(value)
			setfpscap(value)
		end
	})
end)

run(function()
    local TypeData
    local PlayerData
    local includeEmptyMatches
	local Clean
    PlayerData = vape.Categories.Minigames:CreateModule({
        Name = "PlayerData",
        Function = function(callback)
				   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
	    	if not callback then return end

            local http = game:GetService("HttpService")
            local store = bedwars.Store:getState()

            if TypeData.Value == "important" then
                local stats = {}
                local totals = {
                    TotalWins = 0,
                    TotalLosses = 0,
                    TotalMatches = 0,
                    TotalBedBreaks = 0,
                    TotalFinalKills = 0
                }

                local leaderboard = store and store.Leaderboard and store.Leaderboard.queues

                if leaderboard then
                    for mode, data in pairs(leaderboard) do
                        local wins = data.wins or 0																
                        local losses = data.losses or 0
						local ties = data.ties or 0
                        local matches = data.matches or (wins + losses)
                        local winrate = (wins + losses > 0) and ((wins / (wins + losses)) * 100) or 0
						local earlyleaves = data.earlyLeaves or 0
                        local bedBreaks = data.bedBreaks or 0
                        local finalKills = data.finalKills or 0

                        totals.TotalWins += wins
                        totals.TotalLosses += losses
                        totals.TotalMatches += matches
                        totals.TotalBedBreaks += bedBreaks
                        totals.TotalFinalKills += finalKills

                        if includeEmptyMatches.Value or (wins > 0 or losses > 0 or matches > 0) then
                            stats[mode] = {
                                Winrate = string.format("%.2f%%", winrate),
                                Wins = wins,
                                Losses = losses,
								Ties = ties,
                                Matches = matches,
								EarlyLeaves = earlyleaves,
                                BedBreaks = bedBreaks,
                                FinalKills = finalKills
                            }
                        end
                    end
                end

                local achievements = {}
                if store and store.Bedwars and store.Bedwars.achievements then
                    for _, ach in pairs(store.Bedwars.achievements) do
                        table.insert(achievements, ach)
                    end
                elseif leaderboard and leaderboard.bedwars_duels and leaderboard.bedwars_duels.obtainedAchievements then
                    achievements = leaderboard.bedwars_duels.obtainedAchievements
                end

                local dataOut = {
					GameModes = stats,
                    Totals = totals,
                    Achievements = achievements
                }
				if Clean then
					local json = http:JSONEncode(dataOut)
	                json = json:gsub(',"', ',\n    "')
	                json = json:gsub('{', '{\n    ')
	                json = json:gsub('}', '\n}')
	
	                writefile("ReVape/profiles/PlayerData.txt", json)
	                vape:CreateNotification("PlayerData", "Created PlayerData.txt file at profiles", 10)
					else
						local json = dataOut
						
                		writefile("ReVape/profiles/PlayerData.txt", json)
                		vape:CreateNotification("PlayerData", "Created PlayerData.txt file at profiles", 10)
					end
            elseif TypeData.Value == "full" then

				if Clean then
					local json = http:JSONEncode(bedwars.Store:getState())
	                json = json:gsub(',"', ',\n    "')
	                json = json:gsub('{', '{\n    ')
	                json = json:gsub('}', '\n}')
	
	                writefile("ReVape/profiles/PlayerDataJSON.txt", json)
	                vape:CreateNotification("PlayerData", "Created PlayerData.json file at profiles", 10)
					else
						local json = http:JSONEncode(bedwars.Store:getState())
						
                		writefile("ReVape/profiles/PlayerDataJSON.txt", json)
                		vape:CreateNotification("PlayerData", "Created PlayerData.json file at profiles", 10)
					end
            end
		PlayerData:Toggle()
        end,
        Tooltip = "Creates a file that has your data"
    })

    TypeData = PlayerData:CreateDropdown({
        Name = "Type",
        List = {"important", "full"}
    })

    includeEmptyMatches = PlayerData:CreateToggle({
        Name = "EmptyMatches",
        Default = false,
        Tooltip = "ONLY FOR IMPORTANT TYPE (adds 0-stats matches to your file)"
    })
	Clean = PlayerData:CreateToggle({
        Name = "Clean",
        Default = true,
        Tooltip = "Cleans up the JSON file"
    })
end)
elseif game.PlaceId == 8560631822 or game.PlaceId == 8444591321 or game.PlaceId == 6872274481 then
    local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end

local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
})

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local httpService = cloneref(game:GetService('HttpService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local collectionService = cloneref(game:GetService('CollectionService'))
local contextActionService = cloneref(game:GetService('ContextActionService'))
local guiService = cloneref(game:GetService('GuiService'))
local coreGui = cloneref(game:GetService('CoreGui'))
local starterGui = cloneref(game:GetService('StarterGui'))
local isnetworkowner = identifyexecutor and table.find({'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
	return true
end


local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset

local vape = shared.vape
local entitylib = vape.Libraries.entity
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local uipallet = vape.Libraries.uipallet
local tween = vape.Libraries.tween
local color = vape.Libraries.color
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset
local role = vape.role or "guest"
local user = vape.user or "GUEST"


local store = {
	attackReach = 0,
	attackReachUpdate = tick(),
	damageBlockFail = tick(),
	hand = {},
	inventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	inventories = {},
	matchState = 0,
	queueType = 'bedwars_test',
	tools = {}
}
local Reach = {}
local HitBoxes = {}
local InfiniteFly = {}
local TrapDisabler
local AntiFallPart
local Speed
local Fly
local bedwars, remotes, sides, oldinvrender, oldSwing = {}, {}, {}

local function addBlur(parent)
	local blur = Instance.new('ImageLabel')
	blur.Name = 'Blur'
	blur.Size = UDim2.new(1, 89, 1, 52)
	blur.Position = UDim2.fromOffset(-48, -31)
	blur.BackgroundTransparency = 1
	blur.Image = getcustomasset('ReVape/assets/new/blur.png')
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(52, 31, 261, 502)
	blur.Parent = parent
	return blur
end

local function collection(tags, module, customadd, customremove)
	tags = typeof(tags) ~= 'table' and {tags} or tags
	local objs, connections = {}, {}

	for _, tag in tags do
		table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			if customadd then
				customadd(objs, v, tag)
				return
			end
			table.insert(objs, v)
		end))
		table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if customremove then
				customremove(objs, v, tag)
				return
			end
			v = table.find(objs, v)
			if v then
				table.remove(objs, v)
			end
		end))

		for _, v in collectionService:GetTagged(tag) do
			if customadd then
				customadd(objs, v, tag)
				continue
			end
			table.insert(objs, v)
		end
	end

	local cleanFunc = function(self)
		for _, v in connections do
			v:Disconnect()
		end
		table.clear(connections)
		table.clear(objs)
		table.clear(self)
	end
	if module then
		module:Clean(cleanFunc)
	end
	return objs, cleanFunc
end

local function getBestArmor(slot)
	local closest, mag = nil, 0

	for _, item in store.inventory.inventory.items do
		local meta = item and bedwars.ItemMeta[item.itemType] or {}

		if meta.armor and meta.armor.slot == slot then
			local newmag = (meta.armor.damageReductionMultiplier or 0)

			if newmag > mag then
				closest, mag = item, newmag
			end
		end
	end

	return closest
end

local function getBow()
	local bestBow, bestBowSlot, bestBowDamage = nil, nil, 0
	for slot, item in store.inventory.inventory.items do
		local bowMeta = bedwars.ItemMeta[item.itemType].projectileSource
		if bowMeta and table.find(bowMeta.ammoItemTypes, 'arrow') then
			local bowDamage = bedwars.ProjectileMeta[bowMeta.projectileType('arrow')].combat.damage or 0
			if bowDamage > bestBowDamage then
				bestBow, bestBowSlot, bestBowDamage = item, slot, bowDamage
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getItem(itemName, inv)
	for slot, item in (inv or store.inventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getRoactRender(func)
	return debug.getupvalue(debug.getupvalue(debug.getupvalue(func, 3).render, 2).render, 1)
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in store.inventory.inventory.items do
		local swordMeta = bedwars.ItemMeta[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end

local function getTool(breakType)
	local bestTool, bestToolSlot, bestToolDamage = nil, nil, 0
	for slot, item in store.inventory.inventory.items do
		local toolMeta = bedwars.ItemMeta[item.itemType].breakBlock
		if toolMeta then
			local toolDamage = toolMeta[breakType] or 0
			if toolDamage > bestToolDamage then
				bestTool, bestToolSlot, bestToolDamage = item, slot, toolDamage
			end
		end
	end
	return bestTool, bestToolSlot
end

local function getWool()
	for _, wool in (inv or store.inventory.inventory.items) do
		if wool.itemType:find('wool') then
			return wool and wool.itemType, wool and wool.amount
		end
	end
end

local function getStrength(plr)
	if not plr.Player then
		return 0
	end

	local strength = 0
	for _, v in (store.inventories[plr.Player] or {items = {}}).items do
		local itemmeta = bedwars.ItemMeta[v.itemType]
		if itemmeta and itemmeta.sword and itemmeta.sword.damage > strength then
			strength = itemmeta.sword.damage
		end
	end

	return strength
end

local function getPlacedBlock(pos)
	if not pos then
		return
	end
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local function getBlocksInPoints(s, e)
	local blocks, list = bedwars.BlockController:getStore(), {}
	for x = s.X, e.X do
		for y = s.Y, e.Y do
			for z = s.Z, e.Z do
				local vec = Vector3.new(x, y, z)
				if blocks:getBlockAt(vec) then
					table.insert(list, vec * 3)
				end
			end
		end
	end
	return list
end

local function getNearGround(range)
	range = Vector3.new(3, 3, 3) * (range or 10)
	local localPosition, mag, closest = entitylib.character.RootPart.Position, 60
	local blocks = getBlocksInPoints(bedwars.BlockController:getBlockPosition(localPosition - range), bedwars.BlockController:getBlockPosition(localPosition + range))

	for _, v in blocks do
		if not getPlacedBlock(v + Vector3.new(0, 3, 0)) then
			local newmag = (localPosition - v).Magnitude
			if newmag < mag then
				mag, closest = newmag, v + Vector3.new(0, 3, 0)
			end
		end
	end

	table.clear(blocks)
	return closest
end

local function getShieldAttribute(char)
	local returned = 0
	for name, val in char:GetAttributes() do
		if name:find('Shield') and type(val) == 'number' and val > 0 then
			returned += val
		end
	end
	return returned
end

local function getSpeed()
	local multi, increase, modifiers = 0, true, bedwars.SprintController:getMovementStatusModifier():getModifiers()

	for v in modifiers do
		local val = v.constantSpeedMultiplier and v.constantSpeedMultiplier or 0
		if val and val > math.max(multi, 1) then
			increase = false
			multi = val - (0.06 * math.round(val))
		end
	end

	for v in modifiers do
		multi += math.max((v.moveSpeedMultiplier or 0) - 1, 0)
	end

	if multi > 0 and increase then
		multi += 0.16 + (0.02 * math.round(multi))
	end

	return 20 * (multi + 1)
end

local function getTableSize(tab)
	local ind = 0
	for _ in tab do
		ind += 1
	end
	return ind
end

local function hotbarSwitch(slot)
	if slot and store.inventory.hotbarSlot ~= slot then
		bedwars.Store:dispatch({
			type = 'InventorySelectHotbarSlot',
			slot = slot
		})
		vapeEvents.InventoryChanged.Event:Wait()
		return true
	end
	return false
end

local function isFriend(plr, recolor)
	if vape.Categories.Friends.Options['Use friends'].Enabled then
		local friend = table.find(vape.Categories.Friends.ListEnabled, plr.Name) and true
		if recolor then
			friend = friend and vape.Categories.Friends.Options['Recolor visuals'].Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	return table.find(vape.Categories.Targets.ListEnabled, plr.Name) and true
end

local function notif(...) return
	vape:CreateNotification(...)
end

local function removeTags(str)
	str = str:gsub('<br%s*/>', '\n')
	return (str:gsub('<[^<>]->', ''))
end

local function roundPos(vec)
	return Vector3.new(math.round(vec.X / 3) * 3, math.round(vec.Y / 3) * 3, math.round(vec.Z / 3) * 3)
end

local function switchItem(tool, delayTime)
	delayTime = delayTime or 0.05
	local check = lplr.Character and lplr.Character:FindFirstChild('HandInvItem') or nil
	if check and check.Value ~= tool and tool.Parent ~= nil then
		task.spawn(function()
			bedwars.Client:Get(remotes.EquipItem):CallServerAsync({hand = tool})
		end)
		check.Value = tool
		if delayTime > 0 then
			task.wait(delayTime)
		end
		return true
	end
end

local function waitForChildOfType(obj, name, timeout, prop)
	local check, returned = tick() + timeout
	repeat
		returned = prop and obj[name] or obj:FindFirstChildOfClass(name)
		if returned and returned.Name ~= 'UpperTorso' or check < tick() then
			break
		end
		task.wait(0.1)
	until false
	return returned
end

local frictionTable, oldfrict = {}, {}
local frictionConnection
local frictionState

local function modifyVelocity(v)
	if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' and not oldfrict[v] then
		oldfrict[v] = v.CustomPhysicalProperties or 'none'
		v.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.2, 0.5, 1, 1)
	end
end

local function updateVelocity(force)
	local newState = getTableSize(frictionTable) > 0
	if frictionState ~= newState or force then
		if frictionConnection then
			frictionConnection:Disconnect()
		end
		if newState then
			if entitylib.isAlive then
				for _, v in entitylib.character.Character:GetDescendants() do
					modifyVelocity(v)
				end
				frictionConnection = entitylib.character.Character.DescendantAdded:Connect(modifyVelocity)
			end
		else
			for i, v in oldfrict do
				i.CustomPhysicalProperties = v ~= 'none' and v or nil
			end
			table.clear(oldfrict)
		end
	end
	frictionState = newState
end

local function isEveryoneDead()
	return #bedwars.Store:getState().Party.members <= 0
end
	
local function joinQueue()
	if not bedwars.Store:getState().Game.customMatch and bedwars.Store:getState().Party.leader.userId == lplr.UserId and bedwars.Store:getState().Party.queueState == 0 then
		bedwars.QueueController:joinQueue(store.queueType)
	end
end

local kitorder = {
	hannah = 5,
	spirit_assassin = 4,
	dasher = 3,
	jade = 2,
	regent = 1
}

local sortmethods = {
	Damage = function(a, b)
		return a.Entity.Character:GetAttribute('LastDamageTakenTime') < b.Entity.Character:GetAttribute('LastDamageTakenTime')
	end,
	Threat = function(a, b)
		return getStrength(a.Entity) > getStrength(b.Entity)
	end,
	Kit = function(a, b)
		return (a.Entity.Player and kitorder[a.Entity.Player:GetAttribute('PlayingAsKit')] or 0) > (b.Entity.Player and kitorder[b.Entity.Player:GetAttribute('PlayingAsKit')] or 0)
	end,
	Health = function(a, b)
		return a.Entity.Health < b.Entity.Health
	end,
	Angle = function(a, b)
		local selfrootpos = entitylib.character.RootPart.Position
		local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
		local angle = math.acos(localfacing:Dot(((a.Entity.RootPart.Position - selfrootpos) * Vector3.new(1, 0, 1)).Unit))
		local angle2 = math.acos(localfacing:Dot(((b.Entity.RootPart.Position - selfrootpos) * Vector3.new(1, 0, 1)).Unit))
		return angle < angle2
	end
}


run(function()
	local oldstart = entitylib.start
	local function customEntity(ent)
		if ent:HasTag('inventory-entity') and not ent:HasTag('Monster') then
			return
		end

		entitylib.addEntity(ent, nil, ent:HasTag('Drone') and function(self)
			local droneplr = playersService:GetPlayerByUserId(self.Character:GetAttribute('PlayerUserId'))
			return not droneplr or lplr:GetAttribute('Team') ~= droneplr:GetAttribute('Team')
		end or function(self)
			return lplr:GetAttribute('Team') ~= self.Character:GetAttribute('Team')
		end)
	end

	entitylib.start = function()
		oldstart()
		if entitylib.Running then
			for _, ent in collectionService:GetTagged('entity') do
				customEntity(ent)
			end
			table.insert(entitylib.Connections, collectionService:GetInstanceAddedSignal('entity'):Connect(customEntity))
			table.insert(entitylib.Connections, collectionService:GetInstanceRemovedSignal('entity'):Connect(function(ent)
				entitylib.removeEntity(ent)
			end))
		end
	end

	entitylib.addPlayer = function(plr)
		if plr.Character then
			entitylib.refreshEntity(plr.Character, plr)
		end
		entitylib.PlayerConnections[plr] = {
			plr.CharacterAdded:Connect(function(char)
				entitylib.refreshEntity(char, plr)
			end),
			plr.CharacterRemoving:Connect(function(char)
				entitylib.removeEntity(char, plr == lplr)
			end),
			plr:GetAttributeChangedSignal('Team'):Connect(function()
				for _, v in entitylib.List do
					if v.Targetable ~= entitylib.targetCheck(v) then
						entitylib.refreshEntity(v.Character, v.Player)
					end
				end

				if plr == lplr then
					entitylib.start()
				else
					entitylib.refreshEntity(plr.Character, plr)
				end
			end)
		}
	end

	entitylib.addEntity = function(char, plr, teamfunc)
		if not char then return end
		entitylib.EntityThreads[char] = task.spawn(function()
			local hum, humrootpart, head
			if plr then
				hum = waitForChildOfType(char, 'Humanoid', 10)
				humrootpart = hum and waitForChildOfType(hum, 'RootPart', workspace.StreamingEnabled and 9e9 or 10, true)
				head = char:WaitForChild('Head', 10) or humrootpart
			else
				hum = {HipHeight = 0.5}
				humrootpart = waitForChildOfType(char, 'PrimaryPart', 10, true)
				head = humrootpart
			end
			local updateobjects = plr and plr ~= lplr and {
				char:WaitForChild('ArmorInvItem_0', 5),
				char:WaitForChild('ArmorInvItem_1', 5),
				char:WaitForChild('ArmorInvItem_2', 5),
				char:WaitForChild('HandInvItem', 5)
			} or {}

			if hum and humrootpart then
				local entity = {
					Connections = {},
					Character = char,
					Health = (char:GetAttribute('Health') or 100) + getShieldAttribute(char),
					Head = head,
					Humanoid = hum,
					HumanoidRootPart = humrootpart,
					HipHeight = hum.HipHeight + (humrootpart.Size.Y / 2) + (hum.RigType == Enum.HumanoidRigType.R6 and 2 or 0),
					Jumps = 0,
					JumpTick = tick(),
					Jumping = false,
					LandTick = tick(),
					MaxHealth = char:GetAttribute('MaxHealth') or 100,
					NPC = plr == nil,
					Player = plr,
					RootPart = humrootpart,
					TeamCheck = teamfunc
				}

				if plr == lplr then
					entity.AirTime = tick()
					entitylib.character = entity
					entitylib.isAlive = true
					entitylib.Events.LocalAdded:Fire(entity)
					table.insert(entitylib.Connections, char.AttributeChanged:Connect(function(attr)
						vapeEvents.AttributeChanged:Fire(attr)
					end))
				else
					entity.Targetable = entitylib.targetCheck(entity)

					for _, v in entitylib.getUpdateConnections(entity) do
						table.insert(entity.Connections, v:Connect(function()
							entity.Health = (char:GetAttribute('Health') or 100) + getShieldAttribute(char)
							entity.MaxHealth = char:GetAttribute('MaxHealth') or 100
							entitylib.Events.EntityUpdated:Fire(entity)
						end))
					end

					for _, v in updateobjects do
						table.insert(entity.Connections, v:GetPropertyChangedSignal('Value'):Connect(function()
							task.delay(0.1, function()
								if bedwars.getInventory then
									store.inventories[plr] = bedwars.getInventory(plr)
									entitylib.Events.EntityUpdated:Fire(entity)
								end
							end)
						end))
					end

					if plr then
						local anim = char:FindFirstChild('Animate')
						if anim then
							pcall(function()
								anim = anim.jump:FindFirstChildWhichIsA('Animation').AnimationId
								table.insert(entity.Connections, hum.Animator.AnimationPlayed:Connect(function(playedanim)
									if playedanim.Animation.AnimationId == anim then
										entity.JumpTick = tick()
										entity.Jumps += 1
										entity.LandTick = tick() + 1
										entity.Jumping = entity.Jumps > 1
									end
								end))
							end)
						end

						task.delay(0.1, function()
							if bedwars.getInventory then
								store.inventories[plr] = bedwars.getInventory(plr)
							end
						end)
					end
					table.insert(entitylib.List, entity)
					entitylib.Events.EntityAdded:Fire(entity)
				end

				table.insert(entity.Connections, char.ChildRemoved:Connect(function(part)
					if part == humrootpart or part == hum or part == head then
						if part == humrootpart and hum.RootPart then
							humrootpart = hum.RootPart
							entity.RootPart = hum.RootPart
							entity.HumanoidRootPart = hum.RootPart
							return
						end
						entitylib.removeEntity(char, plr == lplr)
					end
				end))
			end
			entitylib.EntityThreads[char] = nil
		end)
	end

	entitylib.getUpdateConnections = function(ent)
		local char = ent.Character
		local tab = {
			char:GetAttributeChangedSignal('Health'),
			char:GetAttributeChangedSignal('MaxHealth'),
			{
				Connect = function()
					ent.Friend = ent.Player and isFriend(ent.Player) or nil
					ent.Target = ent.Player and isTarget(ent.Player) or nil
					return {Disconnect = function() end}
				end
			}
		}

		if ent.Player then
			table.insert(tab, ent.Player:GetAttributeChangedSignal('PlayingAsKit'))
		end

		for name, val in char:GetAttributes() do
			if name:find('Shield') and type(val) == 'number' then
				table.insert(tab, char:GetAttributeChangedSignal(name))
			end
		end

		return tab
	end

	entitylib.targetCheck = function(ent)
		if ent.TeamCheck then
			return ent:TeamCheck()
		end
		if ent.NPC then return true end
		if isFriend(ent.Player) then return false end
		if not select(2, whitelist:get(ent.Player)) then return false end
		return lplr:GetAttribute('Team') ~= ent.Player:GetAttribute('Team')
	end
	vape:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity))
end)
entitylib.start()

run(function()
	local KnitInit, Knit
	repeat
		KnitInit, Knit = pcall(function()
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 9)
		end)
		if KnitInit then break end
		task.wait(0.1)
	until KnitInit

	if not debug.getupvalue(Knit.Start, 1) then
		repeat task.wait(0.1) until debug.getupvalue(Knit.Start, 1)
	end

	local Flamework = require(replicatedStorage['rbxts_include']['node_modules']['@flamework'].core.out).Flamework
	local InventoryUtil = require(replicatedStorage.TS.inventory['inventory-util']).InventoryUtil
	local Client = require(replicatedStorage.TS.remotes).default.Client
	local OldGet, OldBreak = Client.Get

	bedwars = setmetatable({
		AbilityController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController'),
		AnimationType = require(replicatedStorage.TS.animation['animation-type']).AnimationType,
		AnimationUtil = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].util['animation-util']).AnimationUtil,
		AppController = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.controllers['app-controller']).AppController,
		BedBreakEffectMeta = require(replicatedStorage.TS.locker['bed-break-effect']['bed-break-effect-meta']).BedBreakEffectMeta,
		BedwarsKitMeta = require(replicatedStorage.TS.games.bedwars.kit['bedwars-kit-meta']).BedwarsKitMeta,
		BlockBreaker = Knit.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out).BlockEngine,
		BlockEngine = require(lplr.PlayerScripts.TS.lib['block-engine']['client-block-engine']).ClientBlockEngine,
		BlockPlacer = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client.placement['block-placer']).BlockPlacer,
		BowConstantsTable = debug.getupvalue(Knit.Controllers.ProjectileController.enableBeam, 8),
		ClickHold = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.ui.lib.util['click-hold']).ClickHold,
		Client = Client,
		ClientConstructor = require(replicatedStorage['rbxts_include']['node_modules']['@rbxts'].net.out.client),
		ClientDamageBlock = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client,
		CombatConstant = require(replicatedStorage.TS.combat['combat-constant']).CombatConstant,
		DamageIndicator = Knit.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker['kill-effect'].effects['default-kill-effect']),
		EmoteType = require(replicatedStorage.TS.locker.emote['emote-type']).EmoteType,
		GameAnimationUtil = require(replicatedStorage.TS.animation['animation-util']).GameAnimationUtil,
		getIcon = function(item, showinv)
			local itemmeta = bedwars.ItemMeta[item.itemType]
			return itemmeta and showinv and itemmeta.image or ''
		end,
		getInventory = function(plr)
			local suc, res = pcall(function()
				return InventoryUtil.getInventory(plr)
			end)
			return suc and res or {
				items = {},
				armor = {}
			}
		end,
		HudAliveCount = require(lplr.PlayerScripts.TS.controllers.global['top-bar'].ui.game['hud-alive-player-counts']).HudAlivePlayerCounts,
		ItemMeta = debug.getupvalue(require(replicatedStorage.TS.item['item-meta']).getItemMeta, 1),
		KillEffectMeta = require(replicatedStorage.TS.locker['kill-effect']['kill-effect-meta']).KillEffectMeta,
		KillFeedController = Flamework.resolveDependency('client/controllers/game/kill-feed/kill-feed-controller@KillFeedController'),
		Knit = Knit,
		KnockbackUtil = require(replicatedStorage.TS.damage['knockback-util']).KnockbackUtil,
		MageKitUtil = require(replicatedStorage.TS.games.bedwars.kit.kits.mage['mage-kit-util']).MageKitUtil,
		NametagController = Knit.Controllers.NametagController,
		PartyController = Flamework.resolveDependency('@easy-games/lobby:client/controllers/party-controller@PartyController'),
		ProjectileMeta = require(replicatedStorage.TS.projectile['projectile-meta']).ProjectileMeta,
		QueryUtil = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil,
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui['queue-card']).QueueCard,
		QueueMeta = require(replicatedStorage.TS.game['queue-meta']).QueueMeta,
		Roact = require(replicatedStorage['rbxts_include']['node_modules']['@rbxts']['roact'].src),
		RuntimeLib = require(replicatedStorage['rbxts_include'].RuntimeLib),
		SoundList = require(replicatedStorage.TS.sound['game-sound']).GameSound,
		SoundManager = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).SoundManager,
		Store = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		TeamUpgradeMeta = debug.getupvalue(require(replicatedStorage.TS.games.bedwars['team-upgrade']['team-upgrade-meta']).getTeamUpgradeMetaForQueue, 6),
		UILayers = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).UILayers,
		VisualizerUtils = require(lplr.PlayerScripts.TS.lib.visualizer['visualizer-utils']).VisualizerUtils,
		WeldTable = require(replicatedStorage.TS.util['weld-util']).WeldUtil,
		WinEffectMeta = require(replicatedStorage.TS.locker['win-effect']['win-effect-meta']).WinEffectMeta,
		ZapNetworking = require(lplr.PlayerScripts.TS.lib.network),
	}, {
		__index = function(self, ind)
			rawset(self, ind, Knit.Controllers[ind])
			return rawget(self, ind)
		end
	})

	local remoteNames = {
		AfkStatus = debug.getproto(Knit.Controllers.AfkController.KnitStart, 1),
		AttackEntity = Knit.Controllers.SwordController.sendServerRequest,
		BeePickup = Knit.Controllers.BeeNetController.trigger,
		CannonAim = debug.getproto(Knit.Controllers.CannonController.startAiming, 5),
		CannonLaunch = Knit.Controllers.CannonHandController.launchSelf,
		ConsumeBattery = debug.getproto(Knit.Controllers.BatteryController.onKitLocalActivated, 1),
		ConsumeItem = debug.getproto(Knit.Controllers.ConsumeController.onEnable, 1),
		ConsumeSoul = Knit.Controllers.GrimReaperController.consumeSoul,
		ConsumeTreeOrb = debug.getproto(Knit.Controllers.EldertreeController.createTreeOrbInteraction, 1),
		DepositPinata = debug.getproto(debug.getproto(Knit.Controllers.PiggyBankController.KnitStart, 2), 5),
		DragonBreath = debug.getproto(Knit.Controllers.VoidDragonController.onKitLocalActivated, 5),
		DragonEndFly = debug.getproto(Knit.Controllers.VoidDragonController.flapWings, 1),
		DragonFly = Knit.Controllers.VoidDragonController.flapWings,
		DropItem = Knit.Controllers.ItemDropController.dropItemInHand,
		EquipItem = debug.getproto(require(replicatedStorage.TS.entity.entities['inventory-entity']).InventoryEntity.equipItem, 3),
		FireProjectile = debug.getupvalue(Knit.Controllers.ProjectileController.launchProjectileWithValues, 2),
		GroundHit = Knit.Controllers.FallDamageController.KnitStart,
		GuitarHeal = Knit.Controllers.GuitarController.performHeal,
		HannahKill = debug.getproto(Knit.Controllers.HannahController.registerExecuteInteractions, 1),
		HarvestCrop = debug.getproto(debug.getproto(Knit.Controllers.CropController.KnitStart, 4), 1),
		KaliyahPunch = debug.getproto(Knit.Controllers.DragonSlayerController.onKitLocalActivated, 1),
		MageSelect = debug.getproto(Knit.Controllers.MageController.registerTomeInteraction, 1),
		MinerDig = debug.getproto(Knit.Controllers.MinerController.setupMinerPrompts, 1),
		PickupItem = Knit.Controllers.ItemDropController.checkForPickup,
		PickupMetal = debug.getproto(Knit.Controllers.HiddenMetalController.onKitLocalActivated, 4),
		ReportPlayer = require(lplr.PlayerScripts.TS.controllers.global.report['report-controller']).default.reportPlayer,
		ResetCharacter = debug.getproto(Knit.Controllers.ResetController.createBindable, 1),
		SpawnRaven = debug.getproto(Knit.Controllers.RavenController.KnitStart, 1),
		SummonerClawAttack = Knit.Controllers.SummonerClawHandController.attack,
		WarlockTarget = debug.getproto(Knit.Controllers.WarlockStaffController.KnitStart, 2)
	}

	local function dumpRemote(tab)
		local ind
		for i, v in tab do
			if v == 'Client' then
				ind = i
				break
			end
		end
		return ind and tab[ind + 1] or ''
	end

	for i, v in remoteNames do
		local remote = dumpRemote(debug.getconstants(v))
		if remote == '' then
			--notif('Onyx', 'Failed to grab remote ('..i..')', 10, 'alert')
		end
		remotes[i] = remote
	end

	OldBreak = bedwars.BlockController.isBlockBreakable

	Client.Get = function(self, remoteName)
		local call = OldGet(self, remoteName)

		if remoteName == remotes.AttackEntity then
			return {
				instance = call.instance,
				SendToServer = function(_, attackTable, ...)
					local suc, plr = pcall(function()
						return playersService:GetPlayerFromCharacter(attackTable.entityInstance)
					end)

					local selfpos = attackTable.validate.selfPosition.value
					local targetpos = attackTable.validate.targetPosition.value
					store.attackReach = ((selfpos - targetpos).Magnitude * 100) // 1 / 100
					store.attackReachUpdate = tick() + 1

					if Reach.Enabled or HitBoxes.Enabled then
						attackTable.validate.raycast = attackTable.validate.raycast or {}
						attackTable.validate.selfPosition.value += CFrame.lookAt(selfpos, targetpos).LookVector * math.max((selfpos - targetpos).Magnitude - 14.399, 0)
					end

					if suc and plr then
						if not select(2, whitelist:get(plr)) then return end
					end

					return call:SendToServer(attackTable, ...)
				end
			}
		elseif remoteName == 'StepOnSnapTrap' and TrapDisabler.Enabled then
			return {SendToServer = function() end}
		end

		return call
	end

	bedwars.BlockController.isBlockBreakable = function(self, breakTable, plr)
		local obj = bedwars.BlockController:getStore():getBlockAt(breakTable.blockPosition)

		if obj and obj.Name == 'bed' then
			for _, plr in playersService:GetPlayers() do
				if obj:GetAttribute('Team'..(plr:GetAttribute('Team') or 0)..'NoBreak') and not select(2, whitelist:get(plr)) then
					return false
				end
			end
		end

		return OldBreak(self, breakTable, plr)
	end

	local cache, blockhealthbar = {}, {blockHealth = -1, breakingBlockPosition = Vector3.zero}
	store.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, 'wool_white')

	local function getBlockHealth(block, blockpos)
		local blockdata = bedwars.BlockController:getStore():getBlockData(blockpos)
		return (blockdata and (blockdata:GetAttribute('1') or blockdata:GetAttribute('Health')) or block:GetAttribute('Health'))
	end

	local function getBlockHits(block, blockpos)
		if not block then return 0 end
		local breaktype = bedwars.ItemMeta[block.Name].block.breakType
		local tool = store.tools[breaktype]
		tool = tool and bedwars.ItemMeta[tool.itemType].breakBlock[breaktype] or 2
		return getBlockHealth(block, bedwars.BlockController:getBlockPosition(blockpos)) / tool
	end

	local function calculatePath(target, blockpos)
		if cache[blockpos] then
			return unpack(cache[blockpos])
		end
		local visited, unvisited, distances, air, path = {}, {{0, blockpos}}, {[blockpos] = 0}, {}, {}

		for _ = 1, 10000 do
			local _, node = next(unvisited)
			if not node then break end
			table.remove(unvisited, 1)
			visited[node[2]] = true

			for _, side in sides do
				side = node[2] + side
				if visited[side] then continue end

				local block = getPlacedBlock(side)
				if not block or block:GetAttribute('NoBreak') or block == target then
					if not block then
						air[node[2]] = true
					end
					continue
				end

				local curdist = getBlockHits(block, side) + node[1]
				if curdist < (distances[side] or math.huge) then
					table.insert(unvisited, {curdist, side})
					distances[side] = curdist
					path[side] = node[2]
				end
			end
		end

		local pos, cost = nil, math.huge
		for node in air do
			if distances[node] < cost then
				pos, cost = node, distances[node]
			end
		end

		if pos then
			cache[blockpos] = {
				pos,
				cost,
				path
			}
			return pos, cost, path
		end
	end

	bedwars.placeBlock = function(pos, item)
		if getItem(item) then
			store.blockPlacer.blockType = item
			return store.blockPlacer:placeBlock(bedwars.BlockController:getBlockPosition(pos))
		end
	end

	bedwars.breakBlock = function(block, effects, anim, customHealthbar)
		if lplr:GetAttribute('DenyBlockBreak') or not entitylib.isAlive or InfiniteFly.Enabled then return end
		local handler = bedwars.BlockController:getHandlerRegistry():getHandler(block.Name)
		local cost, pos, target, path = math.huge

		for _, v in (handler and handler:getContainedPositions(block) or {block.Position / 3}) do
			local dpos, dcost, dpath = calculatePath(block, v * 3)
			if dpos and dcost < cost then
				cost, pos, target, path = dcost, dpos, v * 3, dpath
			end
		end

		if pos then
			if (entitylib.character.RootPart.Position - pos).Magnitude > 30 then return end
			local dblock, dpos = getPlacedBlock(pos)
			if not dblock then return end

			if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) > 0.4 then
				local breaktype = bedwars.ItemMeta[dblock.Name].block.breakType
				local tool = store.tools[breaktype]
				if tool then
					switchItem(tool.tool)
				end
			end

			if blockhealthbar.blockHealth == -1 or dpos ~= blockhealthbar.breakingBlockPosition then
				blockhealthbar.blockHealth = getBlockHealth(dblock, dpos)
				blockhealthbar.breakingBlockPosition = dpos
			end

			bedwars.ClientDamageBlock:Get('DamageBlock'):CallServerAsync({
				blockRef = {blockPosition = dpos},
				hitPosition = pos,
				hitNormal = Vector3.FromNormalId(Enum.NormalId.Top)
			}):andThen(function(result)
				if result then
					if result == 'cancelled' then
						store.damageBlockFail = tick() + 1
						return
					end

					if effects then
						local blockdmg = (blockhealthbar.blockHealth - (result == 'destroyed' and 0 or getBlockHealth(dblock, dpos)))
						customHealthbar = customHealthbar or bedwars.BlockBreaker.updateHealthbar
						customHealthbar(bedwars.BlockBreaker, {blockPosition = dpos}, blockhealthbar.blockHealth, dblock:GetAttribute('MaxHealth'), blockdmg, dblock)
						blockhealthbar.blockHealth = math.max(blockhealthbar.blockHealth - blockdmg, 0)

						if blockhealthbar.blockHealth <= 0 then
							bedwars.BlockBreaker.breakEffect:playBreak(dblock.Name, dpos, lplr)
							bedwars.BlockBreaker.healthbarMaid:DoCleaning()
							blockhealthbar.breakingBlockPosition = Vector3.zero
						else
							bedwars.BlockBreaker.breakEffect:playHit(dblock.Name, dpos, lplr)
						end
					end

					if anim then
						local animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
						bedwars.ViewmodelController:playAnimation(15)
						task.wait(0.3)
						animation:Stop()
						animation:Destroy()
					end
				end
			end)

			if effects then
				return pos, path, target
			end
		end
	end

	for _, v in Enum.NormalId:GetEnumItems() do
		table.insert(sides, Vector3.FromNormalId(v) * 3)
	end
	local function updateStore(new, old)
		if new.Bedwars ~= old.Bedwars then
			store.equippedKit = new.Bedwars.kit ~= 'none' and new.Bedwars.kit or ''
		end

		if new.Game ~= old.Game then
			store.matchState = new.Game.matchState
			store.queueType = new.Game.queueType or 'bedwars_test'
		end

		if new.Inventory ~= old.Inventory then
			local newinv = (new.Inventory and new.Inventory.observedInventory or {inventory = {}})
			local oldinv = (old.Inventory and old.Inventory.observedInventory or {inventory = {}})
			store.inventory = newinv

			if newinv ~= oldinv then
				vapeEvents.InventoryChanged:Fire()
			end

			if newinv.inventory.items ~= oldinv.inventory.items then
				vapeEvents.InventoryAmountChanged:Fire()
				store.tools.sword = getSword()
				for _, v in {'stone', 'wood', 'wool'} do
					store.tools[v] = getTool(v)
				end
			end

			if newinv.inventory.hand ~= oldinv.inventory.hand then
				local currentHand, toolType = new.Inventory.observedInventory.inventory.hand, ''
				if currentHand then
					local handData = bedwars.ItemMeta[currentHand.itemType]
					toolType = handData.sword and 'sword' or handData.block and 'block' or currentHand.itemType:find('bow') and 'bow'
				end

				store.hand = {
					tool = currentHand and currentHand.tool,
					amount = currentHand and currentHand.amount or 0,
					toolType = toolType
				}
			end
		end
	end


	local storeChanged = bedwars.Store.changed:connect(updateStore)
	updateStore(bedwars.Store:getState(), {})

	for _, event in {'MatchEndEvent', 'EntityDeathEvent', 'BedwarsBedBreak', 'BalloonPopped', 'AngelProgress', 'GrapplingHookFunctions'} do
		if not vape.Connections then return end
		bedwars.Client:WaitFor(event):andThen(function(connection)
			vape:Clean(connection:Connect(function(...)
				vapeEvents[event]:Fire(...)
			end))
		end)
	end

	vape:Clean(bedwars.ZapNetworking.EntityDamageEventZap.On(function(...)
		vapeEvents.EntityDamageEvent:Fire({
			entityInstance = ...,
			damage = select(2, ...),
			damageType = select(3, ...),
			fromPosition = select(4, ...),
			fromEntity = select(5, ...),
			knockbackMultiplier = select(6, ...),
			knockbackId = select(7, ...),
			disableDamageHighlight = select(13, ...)
		})
	end))

	for _, event in {'PlaceBlockEvent', 'BreakBlockEvent'} do
		vape:Clean(bedwars.ZapNetworking[event..'Zap'].On(function(...)
			local data = {
				blockRef = {
					blockPosition = ...,
				},
				player = select(5, ...)
			}
			for i, v in cache do
				if ((data.blockRef.blockPosition * 3) - v[1]).Magnitude <= 30 then
					table.clear(v[3])
					table.clear(v)
					cache[i] = nil
				end
			end
			vapeEvents[event]:Fire(data)
		end))
	end

	store.blocks = collection('block', gui)
	store.shop = collection({'BedwarsItemShop', 'TeamUpgradeShopkeeper'}, gui, function(tab, obj)
		table.insert(tab, {
			Id = obj.Name,
			RootPart = obj,
			Shop = obj:HasTag('BedwarsItemShop'),
			Upgrades = obj:HasTag('TeamUpgradeShopkeeper')
		})
	end)
	store.enchant = collection({'enchant-table', 'broken-enchant-table'}, gui, nil, function(tab, obj, tag)
		if obj:HasTag('enchant-table') and tag == 'broken-enchant-table' then return end
		obj = table.find(tab, obj)
		if obj then
			table.remove(tab, obj)
		end
	end)

	local kills = sessioninfo:AddItem('Kills')
	local beds = sessioninfo:AddItem('Beds')
	local wins = sessioninfo:AddItem('Wins')
	local games = sessioninfo:AddItem('Games')

	local mapname = 'Unknown'
	sessioninfo:AddItem('Map', 0, function()
		return mapname
	end, false)

	task.delay(1, function()
		games:Increment()
	end)

	task.spawn(function()
		pcall(function()
			repeat task.wait(0.1) until store.matchState ~= 0 or vape.Loaded == nil
			if vape.Loaded == nil then return end
			mapname = workspace:WaitForChild('Map', 5):WaitForChild('Worlds', 5):GetChildren()[1].Name
			mapname = string.gsub(string.split(mapname, '_')[2] or mapname, '-', '') or 'Blank'
		end)
	end)

	vape:Clean(vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
		if bedTable.player and bedTable.player.UserId == lplr.UserId then
			beds:Increment()
		end
	end))

	vape:Clean(vapeEvents.MatchEndEvent.Event:Connect(function(winTable)
		if (bedwars.Store:getState().Game.myTeam or {}).id == winTable.winningTeamId or lplr.Neutral then
			wins:Increment()
		end
	end))

	vape:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
		local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
		local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
		if not killed or not killer then return end

		if killed ~= lplr and killer == lplr then
			kills:Increment()
		end
	end))

	task.spawn(function()
		repeat
			if entitylib.isAlive then
				entitylib.character.AirTime = entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entitylib.character.AirTime
			end

			for _, v in entitylib.List do
				v.LandTick = math.abs(v.RootPart.Velocity.Y) < 0.1 and v.LandTick or tick()
				if (tick() - v.LandTick) > 0.2 and v.Jumps ~= 0 then
					v.Jumps = 0
					v.Jumping = false
				end
			end
			task.wait(0.1)
		until vape.Loaded == nil
	end)

	pcall(function()
		if getthreadidentity and setthreadidentity then
			local old = getthreadidentity()
			setthreadidentity(2)

			bedwars.Shop = require(replicatedStorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop
			bedwars.ShopItems = debug.getupvalue(debug.getupvalue(bedwars.Shop.getShopItem, 1), 2)
			bedwars.Shop.getShopItem('iron_sword', lplr)

			setthreadidentity(old)
			store.shopLoaded = true
		else
			task.spawn(function()
				repeat
					task.wait(0.1)
				until vape.Loaded == nil or bedwars.AppController:isAppOpen('BedwarsItemShopApp')

				bedwars.Shop = require(replicatedStorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop
				bedwars.ShopItems = debug.getupvalue(debug.getupvalue(bedwars.Shop.getShopItem, 1), 2)
				store.shopLoaded = true
			end)
		end
	end)

	vape:Clean(function()
		Client.Get = OldGet
		bedwars.BlockController.isBlockBreakable = OldBreak
		store.blockPlacer:disable()
		for _, v in vapeEvents do
			v:Destroy()
		end
		for _, v in cache do
			table.clear(v[3])
			table.clear(v)
		end
		table.clear(store.blockPlacer)
		table.clear(vapeEvents)
		table.clear(bedwars)
		table.clear(store)
		table.clear(cache)
		table.clear(sides)
		table.clear(remotes)
		storeChanged:disconnect()
		storeChanged = nil
	end)
end)
run(function()	

	NM = vape.Categories.Troll:CreateModule({
		Name = 'Nightmare Emote',
		Tooltip = 'Client-Sided nightmare emote, animation is Server-Side visuals are Client-Sided',
		Function = function(callback)
			if callback then				
				local l__TweenService__9 = game:GetService("TweenService")
				local player = game:GetService("Players").LocalPlayer
				local p6 = player.Character
				
				if not p6 then return end
				
				local v10 = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("NightmareEmote"):Clone();
				asset = v10
				v10.Parent = game.Workspace
				lastPosition = p6.PrimaryPart and p6.PrimaryPart.Position or Vector3.new()
				
				task.spawn(function()
					while asset ~= nil do
						local currentPosition = p6.PrimaryPart and p6.PrimaryPart.Position
						if currentPosition and (currentPosition - lastPosition).Magnitude > 0.1 then
							asset:Destroy()
							asset = nil
							NM:Toggle()
							break
						end
						lastPosition = currentPosition
						v10:SetPrimaryPartCFrame(p6.LowerTorso.CFrame + Vector3.new(0, -2, 0));
						task.wait(0.1)
					end
				end)
				
				local v11 = v10:GetDescendants();
				local function v12(p8)
					if p8:IsA("BasePart") then
						p8.CanCollide = false;
						p8.Anchored = true;
					end;
				end;
				for v13, v14 in ipairs(v11) do
					v12(v14, v13 - 1, v11);
				end;
				local l__Outer__15 = v10:FindFirstChild("Outer");
				if l__Outer__15 then
					l__TweenService__9:Create(l__Outer__15, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = l__Outer__15.Orientation + Vector3.new(0, 360, 0)
					}):Play();
				end;
				local l__Middle__16 = v10:FindFirstChild("Middle");
				if l__Middle__16 then
					l__TweenService__9:Create(l__Middle__16, TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = l__Middle__16.Orientation + Vector3.new(0, -360, 0)
					}):Play();
				end;
                anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://9191822700"
				anim = p6.Humanoid:LoadAnimation(anim)
				anim:Play()
			else 
                if anim then 
					anim:Stop()
					anim = nil
				end
				if asset then
					asset:Destroy() 
					asset = nil
				end
			end
		end
	})
end)


run(function()
	local GetHost = {}
	GetHost = vape.Categories.Troll:CreateModule({
		Name = "GetHost",
		Tooltip = "this module is only for show. None of the settings will work.",
		Function = function(callback) 
			if callback then
				task.spawn(function()
					game.Players.LocalPlayer:SetAttribute("CustomMatchRole", "host")
				end)
			end	
		end
	})
end)

run(function()
	GetExecuter = vape.Categories.Render:CreateModule({
		Name = "GetExecuter",
		Tooltip = "gets ur current executer(USED FOR DEBUGGING)",
		Function = function(callback)
			if callback then
				task.spawn(function()
				local timer = 4.5
					vape:CreateNotification('Loading...', "Currently searching for your executor", timer)
					if identifyexecutor then
					task.wait(timer + 0.5)
						vape:CreateNotification("Success", "Could find your executor '"..identifyexecutor().."'", 20)
					else
						vape:CreateNotification("Error", "Couldn't find your function 'identifyexecutor' for your executor", 5,"alert")
					end
				end)
			end
		end	
	})
end)


run(function()
	local collectionService = game:GetService("CollectionService")
	local debris = game:GetService("Debris")
	local Icons = {
		["iron"] = "rbxassetid://6850537969",
		["bee"] = "rbxassetid://7343272839",
		["natures_essence_1"] = "rbxassetid://11003449842",
		["thorns"] = "rbxassetid://9134549615",
		["mushrooms"] = "rbxassetid://9134534696",
		["wild_flower"] = "rbxassetid://9134545166",
		["crit_star"] = "rbxassetid://9866757805",
		["vitality_star"] = "rbxassetid://9866757969",
		["sheep"] = "rbxassetid://78493823174512",
		["crystal"] = "rbxassetid://94842987168294",
		["Ghost"] = "rbxassetid://78249785309968",
		['Spirit'] = "rbxassetid://132108376114488"
	}
	local espobjs = {}
	local espfold = Instance.new("Folder")
	local gui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer.PlayerGui)
	gui.ResetOnSpawn = false
	espfold.Parent = gui

	local hidden = false

	local function isKeybindValid(key)
		return Enum.KeyCode[key] ~= nil
	end

	local function showNotification(message)
		local notification = Instance.new("TextLabel")
		notification.Size = UDim2.new(0, 300, 0, 50)
		notification.Position = UDim2.new(0.5, -150, 0, 50)
		notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		notification.TextColor3 = Color3.new(1, 1, 1)
		notification.Font = Enum.Font.SourceSansBold
		notification.TextSize = 20
		notification.Text = message
		notification.AnchorPoint = Vector2.new(0.5, 0)
		notification.Parent = gui

		debris:AddItem(notification, 3)
	end

	local function espadd(v, icon)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = espfold
		billboard.Name = "iron"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = Icons[icon] or ""
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local connections = {}

	local function reset()
		for _, v in pairs(connections) do
			pcall(function() v:Disconnect() end)
		end
		espfold:ClearAllChildren()
		table.clear(espobjs)
	end

	local function addKit(tag, icon, custom)
		if not custom then
			local con1 = collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
				espadd(v.PrimaryPart, icon)
			end)
			local con2 = collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
				if espobjs[v.PrimaryPart] then
					espobjs[v.PrimaryPart]:Destroy()
					espobjs[v.PrimaryPart] = nil
				end
			end)
			table.insert(connections, con1)
			table.insert(connections, con2)
			for _, v in pairs(collectionService:GetTagged(tag)) do
				espadd(v.PrimaryPart, icon)
			end
		else
			local function check(v)
				if v.Name == tag and v.ClassName == "Model" then
					espadd(v.PrimaryPart, icon)
				end
			end
			KitESP:Clean(game.Workspace.ChildAdded:Connect(check))
			KitESP:Clean(game.Workspace.ChildRemoved:Connect(function(v)
				pcall(function()
					if espobjs[v.PrimaryPart] then
						espobjs[v.PrimaryPart]:Destroy()
						espobjs[v.PrimaryPart] = nil
					end
				end)
			end))
			for _, v in pairs(game.Workspace:GetChildren()) do
				check(v)
			end
		end
	end

	local function recreateESP()
		reset()
		addKit("hidden-metal", "iron")
		addKit("bee", "bee")
		addKit("treeOrb", "natures_essence_1")
		
		addKit("Thorns", "thorns", true)
		addKit("Mushrooms", "mushrooms", true)
		addKit("Flower", "wild_flower", true)
		addKit("CritStar", "crit_star", true)
		addKit("VitalityStar", "vitality_star", true)
		addKit("alchemy_crystal", "crystal")															
		addKit("SheepModel", "sheep")															
		addKit("ghost", "Ghost")	
		addKit('spirit_gardener_energy','Spirit',true)
	end

	KitESP = vape.Categories.Minigames:CreateModule({
		Name = "KitESP",
		Tooltip = "Specfic kits work for this module",
		Function = function(callback)
			if callback then
				recreateESP()
			else
				reset()
			end
		end
	})

end)

run(function()
    local ClientCrasher
    local Method

    ClientCrasher = vape.Categories.Exploits:CreateModule({
        Name = 'Client Crasher',
        Function = function(callback)
    			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				ClientCrasher:Toggle(false)
					vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
					
				return
			end       
	if callback then
                for _, v in getconnections(game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("abilityUsed").OnClientEvent) do
                    v:Disconnect()    
                end

                ClientCrasher:Clean(collectionService:GetInstanceAddedSignal('inventory-entity'):Connect(function(player: Model)
                   local item = player:WaitForChild('HandInvItem') 
                    for i,v in getconnections(item.Changed) do
                        v:Disable()
                    end                
                end))

                repeat
                    if entitylib.isAlive then
                        if Method.Value == 'Ability' then
                            for _ = 1, 25 do
                                replicatedStorage['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].useAbility:FireServer('oasis_swap_staff')
                            end
                            task.wait(0.1)
                        elseif Method.Value == 'Item' then
                            for _, tool in store.inventory.inventory.items do
                                task.spawn(switchItem, tool.tool, 0, true)
                            end
                        end
                    end
                    task.wait(0.1)
                until not ClientCrasher.Enabled
            end
        end
    })

    Method = ClientCrasher:CreateDropdown({
        Name = 'Method',
        List = {'Item', 'Ability'}
    })
end) 

																																								
run(function()
    local Users = {
        KnownUsers = {
            Chase = {22808138, 4782733628, 7447190808, 3196162848},
            Orion = {547598710, 5728889572, 4652232128, 7043591647, 7209929547, 7043958628, 7418525152, 3774791573, 8606089749},
            LisNix = {162442297, 702354331, 9350301723},
            Nwr = {307212658, 5097000699, 4923561416},
            Gorilla = {514679433, 2431747703, 4531785383},
            Typhoon = {2428373515, 7659437319},
            Erin = {2465133159},
            Ghost = {7558211130, 1708400489,9554637663},
            Sponge = {376388734, 5157136850},
            Gora = {589533315, 567497793},
            Apple = {334013471, 145981200, 4721068661, 8006518573, 3547758846, 7155624750, 7468661659},
            Dom = {239431610, 2621170992},
            Kevin = {575474067, 4785639950, 8735055832},
            Vic = {839818760, 1524739259},
        },
        UnknownUsers = {
            7547477786, 7574577126, 5816563976, 240526951, 7587479685, 7876617827,
            2568824396, 7604102307, 7901878324, 5087196317, 7187604802, 7495829767,
            7718511355, 7928472983, 7922414080, 7758683476, 4079687909, 1160595313
        }
    }

    local ACMOD
    local Side
    local Specific
    local IncludeOffline
    local IncludeStudio

    ACMOD = vape.Categories.Exploits:CreateModule({
        Name = 'Anti-Cheat Mods',
        Tooltip = "Fetches all AC mod users (including unknowns)",
        Function = function()
            vape:CreateNotification('Onyx', "Currently fetching mods", 3)
            task.wait(4)

            local HttpService = game:GetService("HttpService")
            local Players = game:GetService("Players")

            local Offline, InGame, Online, Studio = 0, 0, 0, 0
            local url = "https://presence.roproxy.com/v1/presence/users"
            local data = {userIds = {}}

            if Side and Side.Value == "Known" then
                if Specific and Specific.Value == "All" then
                    for _, numbers in pairs(Users.KnownUsers) do
                        for _, num in ipairs(numbers) do
                            table.insert(data.userIds, num)
                        end
                    end
                elseif Specific and Users.KnownUsers[Specific.Value] then
                    for _, num in ipairs(Users.KnownUsers[Specific.Value]) do
                        table.insert(data.userIds, num)
                    end
                end
            elseif Side and Side.Value == "Unknown" then
                for _, num in ipairs(Users.UnknownUsers) do
                    table.insert(data.userIds, num)
                end
            end

            if #data.userIds == 0 then
                vape:CreateNotification('Onyx', "No Users Selected, Pick a Side/Specific to fetch", 5, "alert")
                return
            end

            local jsonData = HttpService:JSONEncode(data)
            local response
            local success, err = pcall(function()
                response = HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
            end)

            if success and response then
                local okDecode, result = pcall(function()
                    return HttpService:JSONDecode(response)
                end)

                if not okDecode or not result then
                    vape:CreateNotification('Onyx', "Failed to decode presence JSON", 15, "alert")
                    return
                end

                if result.userPresences then
                    for _, user in pairs(result.userPresences) do
                        local username = tostring(user.userId)
                        local okName, nameOrErr = pcall(function()
                            return Players:GetNameFromUserIdAsync(user.userId)
                        end)
                        if okName and nameOrErr then
                            username = nameOrErr
                        end

                        if user.userPresenceType == 0 then
                            Offline = Offline + 1
                            if IncludeOffline and IncludeOffline.Value then
                                vape:CreateNotification('Onyx', username, 5, "alert")
                            end
                        elseif user.userPresenceType == 1 then 
                            Online = Online + 1
                            vape:CreateNotification('Onyx', username, 15, "warning")
                        elseif user.userPresenceType == 2 then 
                            InGame = InGame + 1
                            vape:CreateNotification('Onyx', username, 15, "warning")
                        elseif user.userPresenceType == 3 then 
                            Studio = Studio + 1
                            if IncludeStudio and IncludeStudio.Value then
                                vape:CreateNotification('Onyx', username, 5, "warning")
                            end
                        end
                    end
                end

                task.wait(5)
                if InGame >= 2 then
                    vape:CreateNotification('Onyx', "There are [" .. InGame .. "] mods in game", 45)
                elseif InGame == 0 then
                    vape:CreateNotification('Onyx', "There are none in-game", 45)
                end

                if Online >= 2 then
                    vape:CreateNotification('Onyx', "There are [" .. Online .. "] mods online", 45)
                elseif Online == 0 then
                    vape:CreateNotification('Onyx', "There are none online", 45)
                end
            else
                vape:CreateNotification('Onyx', "Failed to get presence data: " .. tostring(err), 15, "alert")
            end
        end
    })

    Side = ACMOD:CreateDropdown({
        Name = "Version",
        List = {'Known', 'Unknown'},
    })

    Specific = ACMOD:CreateDropdown({
        Name = "Specific",
        Tooltip = 'Fetch a specific user (mains and alts)',
        List = {'All', 'Chase', 'Orion', 'LisNix', 'Nwr', 'Gorilla', 'Typhoon', 'Vic', 'Erin', 'Ghost', 'Sponge', 'Apple', 'Dom', 'Gora', 'Kevin'},
    })

    IncludeStudio = ACMOD:CreateToggle({
        Name = "Include Studio",
        Tooltip = "Include when a mod is in studio",
        Default = false
    })

    IncludeOffline = ACMOD:CreateToggle({
        Name = "Include Offline",
        Tooltip = "Include when a mod is offline",
        Default = false
    })
end)




run(function()																																																																											
    local UsersList = {
        22808138, 4782733628, 7447190808, 3196162848,
        547598710, 5728889572, 4652232128, 7043591647, 7209929547, 7043958628, 7418525152, 3774791573, 8606089749,
        162442297, 702354331, 9350301723,
        307212658, 5097000699, 4923561416,
        514679433, 2431747703, 4531785383,
        2428373515, 7659437319,
        2465133159,
        7558211130, 1708400489,
        376388734, 5157136850,
        589533315, 567497793,
        334013471, 145981200, 4721068661, 8006518573, 3547758846, 7155624750, 7468661659,
        239431610, 2621170992,
        575474067, 4785639950, 8735055832,
        839818760, 1524739259,
        7547477786, 7574577126, 5816563976, 240526951, 7587479685, 7876617827,
        2568824396, 7604102307, 7901878324, 5087196317, 7187604802, 7495829767,
        7718511355, 7928472983, 7922414080, 7758683476, 4079687909, 1160595313,9613415615
    }

    local UsersSet = {}
    for _, id in ipairs(UsersList) do
        UsersSet[id] = true
    end

    local playersService = game:GetService("Players")
    local lplr = playersService.LocalPlayer
    local joined = {} 

    local StaffDetector
    local Party
    local IncludeSpecs
    local CreateLogsOfMODS
	local IdentifyMod
																																																																																		
    local function notif(title, body, duration, typ)
        if vape and vape.CreateNotification then
            vape:CreateNotification(title, body, duration or 5, typ)
        else
            print(("NOTIF [%s] %s"):format(title, body))
        end
    end

    local function checkFriends(list)
        for _, v in ipairs(list) do
            local id = v
            if type(v) == "table" and v.Id then id = v.Id end
            if joined[id] then
                return joined[id]
            end
        end
        return nil
    end

local function staffFunction(plr, checktype, checktypee)
    if not vape or not vape.Loaded then
        repeat task.wait(0.1) until vape and vape.Loaded
    end
if checktype == "spectator_join" then
	if 	IdentifyMod.Enabled then 
		if plr.UserId == 22808138 or  plr.UserId == 4782733628 or  plr.UserId == 7447190808 or  plr.UserId == 3196162848 then
		vape:CreateNotification('Onyx', "Chase Has joined!","alert", 15)																																																																																
		end
	if plr.UserId == 547598710 or  plr.UserId == 5728889572 or  plr.UserId == 4652232128 or  plr.UserId == 7043591647  or  plr.UserId == 7209929547 or  plr.UserId == 7043958628 or  plr.UserId == 7418525152 or  plr.UserId == 3774791573 or  plr.UserId == 8606089749 then
	vape:CreateNotification('Onyx', "Orion Has joined!","alert", 15)
	end
	if plr.UserId == 162442297 or  plr.UserId == 702354331 or  plr.UserId == 9350301723  then
	vape:CreateNotification('Onyx', "Lisnix Has joined!","alert", 15)
	end
	if plr.UserId == 307212658 or  plr.UserId == 5097000699 or  plr.UserId == 4923561416 then
	vape:CreateNotification('Onyx', "Nwr Has joined!","alert", 15)
	end
	if plr.UserId == 514679433 or  plr.UserId == 2431747703 or  plr.UserId == 4531785383 then
	vape:CreateNotification('Onyx', "Gorilla Has joined!","alert", 15)
	end
	if plr.UserId == 2428373515 or  plr.UserId == 7659437319 then
	vape:CreateNotification('Onyx', "Typhoon Has joined!","alert", 15)
	end
	if plr.UserId == 2465133159 then
	vape:CreateNotification('Onyx', "Erin Has joined!","alert", 15)
	end
	if plr.UserId == 7558211130 or  plr.UserId == 1708400489 or  plr.UserId == 9554637663 then
	vape:CreateNotification('Onyx', "Ghost Has joined!","alert", 15)
	end
	if plr.UserId == 376388734 or  plr.UserId == 5157136850 then
	vape:CreateNotification('Onyx', "Sponge Has joined!","alert", 15)
	end
	if plr.UserId == 589533315 or  plr.UserId == 567497793 then
	vape:CreateNotification('Onyx', "Gora Has joined!","alert", 15)
	end
	if plr.UserId == 334013471 or  plr.UserId == 145981200 or  plr.UserId == 4721068661 or  plr.UserId == 8006518573 or  plr.UserId == 3547758846 or  plr.UserId == 7155624750 or  plr.UserId == 7468661659 or plr.UserId == 9575298878 then
	vape:CreateNotification('Onyx', "Apple Has joined!","alert", 15)
	end
	if plr.UserId == 239431610 or  plr.UserId == 2621170992 or  plr.UserId == 9613415615 then
	vape:CreateNotification('Onyx', "Dom Has joined!","alert", 15)
	end
	if plr.UserId == 575474067 or  plr.UserId == 4785639950 or  plr.UserId == 8735055832 or plr.UserId == 9636668830 then
	vape:CreateNotification('Onyx', "Kevin Has joined!","alert", 15)
	end
	if plr.UserId == 839818760 or plr.UserId == 1524739259  then
	vape:CreateNotification('Onyx', "Vic Has joined!","alert", 15)
	end
if plr.UserId == 1092621569 or  plr.UserId == 9673014247 or  plr.UserId == 9673085642 or  plr.UserId == 9701608749 or  plr.UserId == 9617190012 or  plr.UserId == 9673029143 or plr.UserId == 9705518292  then
	vape:CreateNotification('Onyx', "Soryed Has joined!","alert", 15)
end
		end	
else
notif('StaffDetector', 'Staff Detected ('..checktype..'): '..plr.Name..' ('..plr.UserId..')', 60, checktypee)
	if 	IdentifyMod.Enabled then 
		if plr.UserId == 22808138 or  plr.UserId == 4782733628 or  plr.UserId == 7447190808 or  plr.UserId == 3196162848 then
		vape:CreateNotification('Onyx', "Chase Has joined!","alert", 15)																																																																																
		end
	if plr.UserId == 547598710 or  plr.UserId == 5728889572 or  plr.UserId == 4652232128 or  plr.UserId == 7043591647  or  plr.UserId == 7209929547 or  plr.UserId == 7043958628 or  plr.UserId == 7418525152 or  plr.UserId == 3774791573 or  plr.UserId == 8606089749 then
	vape:CreateNotification('Onyx', "Orion Has joined!","alert", 15)
	end
	if plr.UserId == 162442297 or  plr.UserId == 702354331 or  plr.UserId == 9350301723  then
	vape:CreateNotification('Onyx', "Lisnix Has joined!","alert", 15)
	end
	if plr.UserId == 307212658 or  plr.UserId == 5097000699 or  plr.UserId == 4923561416 then
	vape:CreateNotification('Onyx', "Nwr Has joined!","alert", 15)
	end
	if plr.UserId == 514679433 or  plr.UserId == 2431747703 or  plr.UserId == 4531785383 then
	vape:CreateNotification('Onyx', "Gorilla Has joined!","alert", 15)
	end
	if plr.UserId == 2428373515 or  plr.UserId == 7659437319 then
	vape:CreateNotification('Onyx', "Typhoon Has joined!","alert", 15)
	end
	if plr.UserId == 2465133159 then
	vape:CreateNotification('Onyx', "Erin Has joined!","alert", 15)
	end
	if plr.UserId == 7558211130 or  plr.UserId == 1708400489 or  plr.UserId == 9554637663 then
	vape:CreateNotification('Onyx', "Ghost Has joined!","alert", 15)
	end
	if plr.UserId == 376388734 or  plr.UserId == 5157136850 then
	vape:CreateNotification('Onyx', "Sponge Has joined!","alert", 15)
	end
	if plr.UserId == 589533315 or  plr.UserId == 567497793 then
	vape:CreateNotification('Onyx', "Gora Has joined!","alert", 15)
	end
	if plr.UserId == 334013471 or  plr.UserId == 145981200 or  plr.UserId == 4721068661 or  plr.UserId == 8006518573 or  plr.UserId == 3547758846 or  plr.UserId == 7155624750 or  plr.UserId == 7468661659 or plr.UserId == 9575298878 then
	vape:CreateNotification('Onyx', "Apple Has joined!","alert", 15)
	end
	if plr.UserId == 239431610 or  plr.UserId == 2621170992 or  plr.UserId == 9613415615 then
	vape:CreateNotification('Onyx', "Dom Has joined!","alert", 15)
	end
	if plr.UserId == 575474067 or  plr.UserId == 4785639950 or  plr.UserId == 8735055832 or plr.UserId == 9636668830 then
	vape:CreateNotification('Onyx', "Kevin Has joined!","alert", 15)
	end
	if plr.UserId == 839818760 or plr.UserId == 1524739259  then
	vape:CreateNotification('Onyx', "Vic Has joined!","alert", 15)
	end
if plr.UserId == 1092621569 or  plr.UserId == 9673014247 or  plr.UserId == 9673085642 or  plr.UserId == 9701608749 or  plr.UserId == 9617190012 or  plr.UserId == 9673029143 or plr.UserId == 9705518292  then
	vape:CreateNotification('Onyx', "Soryed Has joined!","warning", 15)
end
																																																																																
     end																																																																																				
end
    

    if whitelist and whitelist.customtags then
        whitelist.customtags[plr.Name] = {{text = 'GAME STAFF', color = Color3.new(1, 0, 0)}}
    end


    if Party and Party.Enabled then
        if checktype == "impossible_join" or checktype == "detected_mod_join" then
            if bedwars and bedwars.PartyController and bedwars.PartyController.leaveParty then
                pcall(function()
                    bedwars.PartyController:leaveParty()
                end)
            end
        end
    end

    if CreateLogsOfMODS and CreateLogsOfMODS.Enabled then
        local Format
        local dateString = tostring(DateTime.now())

        if checktype == "impossible_join" then
            Format = "[USERNAME]:"..plr.Name.."|"..
                     "[USERID]:"..plr.UserId.."|"..
                     "[DATE]:"..dateString.."|"..
                     "[TYPE]:[IMPOSSIBLE JOIN]\n"

        elseif checktype == "detected_mod_join" then
            Format = "[USERNAME]:"..plr.Name.."|"..
                     "[USERID]:"..plr.UserId.."|"..
                     "[DATE]:"..dateString.."|"..
                     "[TYPE]:[KNOWN MOD JOIN]\n"

        elseif checktype == "spectator_join" then
            Format = "[USERNAME]:"..plr.Name.."|"..
                     "[USERID]:"..plr.UserId.."|"..
                     "[DATE]:"..dateString.."|"..
                     "[TYPE]:[SPECTATOR JOIN]\n"
        end
if Format then
    local path = "ReVape/profiles/logs.txt"

    if not isfolder("ReVape/profiles") then
        makefolder("ReVape/profiles")
    end

    if not isfile(path) then
        writefile(path, Format)
    else
        local prev = readfile(path)
        writefile(path, prev .. Format)
    end
end
     end
end
    local function checkJoin(plr, connection)
        if not plr or not plr.UserId then return false end

        local spectatorAttr = plr:GetAttribute('Spectator')
        local teamAttr = plr:GetAttribute('Team')
        local isCustomMatch = false
        if bedwars and bedwars.Store and bedwars.Store.getState then
            local ok, state = pcall(bedwars.Store.getState, bedwars.Store)
            if ok and state and state.Game and state.Game.customMatch then
                isCustomMatch = true
            end
        end

        if (not teamAttr) and spectatorAttr and not isCustomMatch then
            if connection then connection:Disconnect() end

            local tab = {}
            local success, pages = pcall(function()
                return playersService:GetFriendsAsync(plr.UserId)
            end)

            if not success or not pages then
                staffFunction(plr, 'impossible_join','warning')
                return true
            end

            for _ = 1, 4 do
                local currentPage = pages:GetCurrentPage()
                for _, v in ipairs(currentPage) do
                    table.insert(tab, v.Id or v.id or v.Id)
                end
                if pages.IsFinished then break end
                pages:AdvanceToNextPageAsync()
            end

            local friend = checkFriends(tab)
            if not friend then
                staffFunction(plr, 'impossible_join','warning')
                return true
            elseif UsersSet[plr.UserId] then
                staffFunction(plr, 'detected_mod_join','alert')
                return true
            else
                if IncludeSpecs and IncludeSpecs.Enabled then
                    notif('StaffDetector', string.format('Spectator %s joined from %s', plr.Name, tostring(friend)), 20, 'warning')
                    if CreateLogsOfMODS and CreateLogsOfMODS.Enabled then
                        staffFunction(plr, "spectator_join", 'info')
                    end
                end
            end
        end

        return false
    end

    local function playerAdded(plr)
        if not plr then return end
        joined[plr.UserId] = plr.Name
        if plr == lplr then return end

        local connection
        connection = plr:GetAttributeChangedSignal('Spectator'):Connect(function()
            checkJoin(plr, connection)
        end)
        if StaffDetector and StaffDetector.Clean then
            StaffDetector:Clean(connection)
        end

        if checkJoin(plr, connection) then
            return
        end
    end

    StaffDetector = vape.Categories.Utility:CreateModule({
        Name = 'StaffDetectorV2',
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				StaffDetector:Toggle(false)
							vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
            if callback then
                if playersService and playersService.PlayerAdded then
                    StaffDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
                end
                for _, v in ipairs(playersService:GetPlayers()) do
                    task.spawn(playerAdded, v)
                end
            else
                table.clear(joined)
            end
        end,
        Tooltip = 'A Newer verison of Staff-Detector'
    })

    Party = StaffDetector:CreateToggle({
        Name = 'Leave party',
        Default = true,
    })
    IncludeSpecs = StaffDetector:CreateToggle({
        Name = 'Include Spectators',
        Tooltip = 'NOTE: Anti-Cheat mods could create new alts, ill say to keep this on to get the new username. BUT THIS CAN DO FALSE DETECTIONS!!',
        Default = true,
    })
    CreateLogsOfMODS = StaffDetector:CreateToggle({
        Name = 'Logs',
        Default = false,
        Tooltip = 'all this does is keep track of every mod/spectators has joined you with a date'
    })

	IdentifyMod = StaffDetector:CreateToggle({
        Name = 'IdentifyMods',
        Default = true,
        Tooltip = "Identify's known mods"
    })																																																																																		
end)																																																												
run(function()
  local Players = game:GetService("Players")
local player = Players.LocalPlayer
    local PlayerLevel
	local level 
  

PlayerLevel = vape.Categories.Exploits:CreateModule({
        Name = 'SetPlayerLevel',
	Tooltip = "Sets your player level to 1000 (client sided)",
        Function = function()
		game.Players.LocalPlayer:SetAttribute("PlayerLevel", level.Value)
	end
})

level = PlayerLevel:CreateSlider({
        Name = 'Player Level',
        Min = 1,
        Max = 1000,
        Default = 100,
	Function = function(val)
	    player:SetAttribute("PlayerLevel", val)
	end
    })


end)

run(function()
    local KitRender
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")

    local ids = {
        ['none'] = "rbxassetid://16493320215",
        ["random"] = "rbxassetid://79773209697352",
        ["cowgirl"] = "rbxassetid://9155462968",
        ["davey"] = "rbxassetid://9155464612",
        ["warlock"] = "rbxassetid://15186338366",
        ["ember"] = "rbxassetid://9630017904",
        ["black_market_trader"] = "rbxassetid://9630017904",
        ["yeti"] = "rbxassetid://9166205917",
        ["scarab"] = "rbxassetid://137137517627492",
        ["defender"] = "rbxassetid://131690429591874",
        ["cactus"] = "rbxassetid://104436517801089",
        ["oasis"] = "rbxassetid://120283205213823",
        ["berserker"] = "rbxassetid://90258047545241",
        ["sword_shield"] = "rbxassetid://131690429591874",
        ["airbender"] = "rbxassetid://74712750354593",
        ["gun_blade"] = "rbxassetid://138231219644853",
        ["frost_hammer_kit"] = "rbxassetid://11838567073",
        ["spider_queen"] = "rbxassetid://95237509752482",
        ["archer"] = "rbxassetid://9224796984",
        ["axolotl"] = "rbxassetid://9155466713",
        ["baker"] = "rbxassetid://9155463919",
        ["barbarian"] = "rbxassetid://9166207628",
        ["builder"] = "rbxassetid://9155463708",
        ["necromancer"] = "rbxassetid://11343458097",
        ["cyber"] = "rbxassetid://9507126891",
        ["sorcerer"] = "rbxassetid://97940108361528",
        ["bigman"] = "rbxassetid://9155467211",
        ["spirit_assassin"] = "rbxassetid://10406002412",
        ["farmer_cletus"] = "rbxassetid://9155466936",
        ["ice_queen"] = "rbxassetid://9155466204",
        ["grim_reaper"] = "rbxassetid://9155467410",
        ["spirit_gardener"] = "rbxassetid://132108376114488",
        ["hannah"] = "rbxassetid://10726577232",
        ["shielder"] = "rbxassetid://9155464114",
        ["summoner"] = "rbxassetid://18922378956",
        ["glacial_skater"] = "rbxassetid://84628060516931",
        ["dragon_sword"] = "rbxassetid://16215630104",
        ["lumen"] = "rbxassetid://9630018371",
        ["flower_bee"] = "rbxassetid://101569742252812",
        ["jellyfish"] = "rbxassetid://18129974852",
        ["melody"] = "rbxassetid://9155464915",
        ["mimic"] = "rbxassetid://14783283296",
        ["miner"] = "rbxassetid://9166208461",
        ["nazar"] = "rbxassetid://18926951849",
        ["seahorse"] = "rbxassetid://11902552560",
        ["elk_master"] = "rbxassetid://15714972287",
        ["rebellion_leader"] = "rbxassetid://18926409564",
        ["void_hunter"] = "rbxassetid://122370766273698",
        ["taliyah"] = "rbxassetid://13989437601",
        ["angel"] = "rbxassetid://9166208240",
        ["harpoon"] = "rbxassetid://18250634847",
        ["void_walker"] = "rbxassetid://78915127961078",
        ["spirit_summoner"] = "rbxassetid://95760990786863",
        ["triple_shot"] = "rbxassetid://9166208149",
        ["void_knight"] = "rbxassetid://73636326782144",
        ["regent"] = "rbxassetid://9166208904",
        ["vulcan"] = "rbxassetid://9155465543",
        ["owl"] = "rbxassetid://12509401147",
        ["dasher"] = "rbxassetid://9155467645",
        ["disruptor"] = "rbxassetid://11596993583",
        ["wizard"] = "rbxassetid://13353923546",
        ["aery"] = "rbxassetid://9155463221",
        ["agni"] = "rbxassetid://17024640133",
        ["alchemist"] = "rbxassetid://9155462512",
        ["spearman"] = "rbxassetid://9166207341",
        ["beekeeper"] = "rbxassetid://9312831285",
        ["falconer"] = "rbxassetid://17022941869",
        ["bounty_hunter"] = "rbxassetid://9166208649",
        ["blood_assassin"] = "rbxassetid://12520290159",
        ["battery"] = "rbxassetid://10159166528",
        ["steam_engineer"] = "rbxassetid://15380413567",
        ["vesta"] = "rbxassetid://9568930198",
        ["beast"] = "rbxassetid://9155465124",
        ["dino_tamer"] = "rbxassetid://9872357009",
        ["drill"] = "rbxassetid://12955100280",
        ["elektra"] = "rbxassetid://13841413050",
        ["fisherman"] = "rbxassetid://9166208359",
        ["queen_bee"] = "rbxassetid://12671498918",
        ["card"] = "rbxassetid://13841410580",
        ["frosty"] = "rbxassetid://9166208762",
        ["gingerbread_man"] = "rbxassetid://9155464364",
        ["ghost_catcher"] = "rbxassetid://9224802656",
        ["tinker"] = "rbxassetid://17025762404",
        ["ignis"] = "rbxassetid://13835258938",
        ["oil_man"] = "rbxassetid://9166206259",
        ["jade"] = "rbxassetid://9166306816",
        ["dragon_slayer"] = "rbxassetid://10982192175",
        ["paladin"] = "rbxassetid://11202785737",
        ["pinata"] = "rbxassetid://10011261147",
        ["merchant"] = "rbxassetid://9872356790",
        ["metal_detector"] = "rbxassetid://9378298061",
        ["slime_tamer"] = "rbxassetid://15379766168",
        ["nyoka"] = "rbxassetid://17022941410",
        ["midnight"] = "rbxassetid://9155462763",
        ["pyro"] = "rbxassetid://9155464770",
        ["raven"] = "rbxassetid://9166206554",
        ["santa"] = "rbxassetid://9166206101",
        ["sheep_herder"] = "rbxassetid://9155465730",
        ["smoke"] = "rbxassetid://9155462247",
        ["spirit_catcher"] = "rbxassetid://9166207943",
        ["star_collector"] = "rbxassetid://9872356516",
        ["styx"] = "rbxassetid://17014536631",
        ["block_kicker"] = "rbxassetid://15382536098",
        ["trapper"] = "rbxassetid://9166206875",
        ["hatter"] = "rbxassetid://12509388633",
        ["ninja"] = "rbxassetid://15517037848",
        ["jailor"] = "rbxassetid://11664116980",
        ["warrior"] = "rbxassetid://9166207008",
        ["mage"] = "rbxassetid://10982191792",
        ["void_dragon"] = "rbxassetid://10982192753",
        ["cat"] = "rbxassetid://15350740470",
        ["wind_walker"] = "rbxassetid://9872355499",
		['skeleton'] = "rbxassetid://120123419412119"
    }

    local function createkitrender(plr)
        local icon = Instance.new("ImageLabel")
        icon.Name = "ReVapeKitRender"
        icon.AnchorPoint = Vector2.new(1, 0.5)
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(1.05, 0, 0.5, 0)
        icon.Size = UDim2.new(1.5, 0, 1.5, 0)
        icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
        icon.ImageTransparency = 0.4
        icon.ScaleType = Enum.ScaleType.Crop
        local uar = Instance.new("UIAspectRatioConstraint")
        uar.AspectRatio = 1
        uar.AspectType = Enum.AspectType.FitWithinMaxSize
        uar.DominantAxis = Enum.DominantAxis.Width
        uar.Parent = icon
        icon.Image = ids[plr:GetAttribute("PlayingAsKits")] or  ids[plr:GetAttribute("PlayingAsKit")] or ids["none"]
        return icon
    end

    local function removeallkitrenders()
        for _, v in ipairs(PlayerGui:GetDescendants()) do
            if v:IsA("ImageLabel") and v.Name == "ReVapeKitRender" then
                v:Destroy()
            end
        end
    end

    local function refreshicon(icon, plr)
        icon.Image = ids[plr:GetAttribute("PlayingAsKits")] or  ids[plr:GetAttribute("PlayingAsKit")] or ids["none"]
    end

    local function findPlayer(label, container)
        local render = container:FindFirstChild("PlayerRender", true)
        if render and render:IsA("ImageLabel") and render.Image then
            local userId = string.match(render.Image, "id=(%d+)")
            if userId then
                local plr = Players:GetPlayerByUserId(tonumber(userId))
                if plr then return plr end
            end
        end
        local text = label.Text
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name == text or plr.DisplayName == text or plr:GetAttribute("DisguiseDisplayName") == text then
                return plr
            end
        end
    end

    local function handleLabel(label)
        if not (label:IsA("TextLabel") and label.Name == "PlayerName") then return end
        task.spawn(function()
            local container = label.Parent
            for _ = 1, 3 do
                if container and container.Parent then
                    container = container.Parent
                end
            end
            if not container or not container:IsA("Frame") then return end
            local playerFound = findPlayer(label, container)
            if not playerFound then
                task.wait(0.5)
                playerFound = findPlayer(label, container)
            end
            if not playerFound then return end
            container.Name = playerFound.Name
            local card = container:FindFirstChild("1") and container["1"]:FindFirstChild("MatchDraftPlayerCard")
            if not card then return end
            local icon = card:FindFirstChild("ReVapeKitRender")
            if not icon then
                icon = createkitrender(playerFound)
                icon.Parent = card
            end
            task.spawn(function()
                while container and container.Parent do
                    local updatedPlayer = findPlayer(label, container)
                    if updatedPlayer and updatedPlayer ~= playerFound then
                        playerFound = updatedPlayer
                    end
                    if playerFound and icon then
                        refreshicon(icon, playerFound)
                    end
                    task.wait(1)
                end
            end)
        end)
    end

    KitRender = vape.Categories.Exploits:CreateModule({
        Name = "KitRender",
        Tooltip = "Allows you to see everyone's kit during kit phase (5v5, Ranked)",
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" then
				KitRender:Toggle(false)
										vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
            if callback then
                task.spawn(function()
                    local team2 = PlayerGui:WaitForChild("MatchDraftApp"):WaitForChild("DraftAppBackground"):WaitForChild("BodyContainer"):WaitForChild("Team2Column")
                    for _, child in ipairs(team2:GetDescendants()) do
                        if KitRender.Enabled then handleLabel(child) end
                    end
                    KitRender:Clean(team2.DescendantAdded:Connect(function(child)
                        if KitRender.Enabled then handleLabel(child) end
                    end))
                end)
            else
                removeallkitrenders()
            end
        end
    })
end)

run(function()

    local aim = 0.158
    local tnt = 0.0045
    local aunchself = 0.395

    local defaultaim = 0.4
    local defaulttnt = 0.2
    local defaultself = 0.4

    local function getWorldFolder()
        local Map = workspace:WaitForChild("Map", math.huge)
        local Worlds = Map:WaitForChild("Worlds", math.huge)
        if not Worlds then return nil end

        return Worlds:GetChildren()[1] 
    end

    local function setCannonSpeeds(blocksFolder, aimDur, tntDur, selfDur)
        for _, v in ipairs(blocksFolder:GetChildren()) do 
            if v:IsA("BasePart") and v.Name == "cannon" then
                local AimPrompt = v:FindFirstChild("AimPrompt")
                local FirePrompt = v:FindFirstChild("FirePrompt")
                local LaunchSelfPrompt = v:FindFirstChild("LaunchSelfPrompt")
                if AimPrompt and FirePrompt and LaunchSelfPrompt then
                    AimPrompt.HoldDuration = aimDur
                    FirePrompt.HoldDuration = tntDur
                    LaunchSelfPrompt.HoldDuration = selfDur
                end
            end
        end
    end

    BetterDavey = vape.Categories.Exploits:CreateModule({
        Name = "BetterDavey",
        Tooltip = "makes your cannon faster lol",
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				BetterDavey:Toggle(false)
											vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
			if not game:GetService("Players").LocalPlayer:GetAttribute("PlayingAsKits") == "davey" or game:GetService("Players").LocalPlayer:GetAttribute("PlayingAsKit") == "davey" then vape:CreateNotification("Onyx", "You are not davey this will be ignored!", 10, "alert") return end
            local worldFolder = getWorldFolder()
            if not worldFolder then return end
            local blocks = worldFolder:WaitForChild("Blocks")

            if callback then
                setCannonSpeeds(blocks, aim, tnt, aunchself)

               BetterDavey:Clean( blocks.ChildAdded:Connect(function(child)
                    if child:IsA("BasePart") and child.Name == "cannon" and BetterDavey.Enabled then
                        local AimPrompt = child:WaitForChild("AimPrompt")
                        local FirePrompt = child:WaitForChild("FirePrompt")
                        local LaunchSelfPrompt = child:WaitForChild("LaunchSelfPrompt")

                        AimPrompt.HoldDuration = aim
                        FirePrompt.HoldDuration = tnt
                        LaunchSelfPrompt.HoldDuration = aunchself
					BetterDavey:Clean(LaunchSelfPrompt.Triggered:Connect(function(p)
						local humanoid = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
					
						if not humanoid then return end
					
						if Speed.Enabled and Fly.Enabled then
							Fly:Toggle(false)
							task.wait(0.025)
							Speed:Toggle(false)
						elseif Speed.Enabled then
							Speed:Toggle(false)
						elseif Fly.Enabled then
							Fly:Toggle(false)
						end
					
						bedwars.breakBlock(child)

					
						if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end
					end))
                    end
                end))
            else
                setCannonSpeeds(blocks, defaultaim, defaulttnt, defaultself)
            end
        end
    })

end)



run(function() 
	local MatchHistory
	MatchHistory = vape.Categories.AltFarm:CreateModule({
		Name = "MatchHistory",
		Tooltip = 'Resets ur history',
		Function = function(callback)
				   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" then
			MatchHistory:Toggle(false)
												vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       

			if callback then 
				MatchHistory:Toggle(false)
				local TeleportService = game:GetService("TeleportService")
				local data = TeleportService:GetLocalPlayerTeleportData()
				MatchHistory:Clean(game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer, data))
			end
		end,
	}) 
end)
run(function() 
	local AutoBan
	AutoBan = vape.Categories.AltFarm:CreateModule({
		Name = "AutoBan",
		Tooltip = 'Automatically bans a kit for you(5v5, ranked only)',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend"then
				AutoBan:Toggle(false)
													vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
			if callback then 
				AutoBan:Toggle(false)
				  local kits = {"berserker", "hatter", "flower_bee", "glacial_skater",'void_dragon','card','cat'}
    for _, kit in ipairs(kits) do
        for i = 0, 1 do
            local args = {kit, i}
            game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("BanKit")
                :InvokeServer(unpack(args))
        end
    end

    for i = 0, 1 do
        local args = {"none", i}
        game:GetService("ReplicatedStorage")
            :WaitForChild("rbxts_include")
            :WaitForChild("node_modules")
            :WaitForChild("@rbxts")
            :WaitForChild("net")
            :WaitForChild("out")
            :WaitForChild("_NetManaged")
            :WaitForChild("SelectKit")
            :InvokeServer(unpack(args))
    end

    task.wait(0.01)
			end
		end,
	}) 
end)



run(function()
	local ItemlessLongjump = {Enabled = false}

	ItemlessLongjump = vape.Categories.Blatant:CreateModule({
		Name = "ItemlessLongjump",
		Function = function(call)
			ItemlessLongjump.Enabled = call
			if call then
				lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + Vector3.new(0, 100, 0)
				task.wait(0.3)
				for i = 1, 4 do
					task.wait(0.4)
					lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + Vector3.new(0, 75, 0)
				end
task.wait(0.025)
				for i = 1, 2 do
					task.wait(0.125)
					lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + Vector3.new(0, 85, 0)
				end

			else
				workspace.Gravity = 192.6
			end
		end,
		Tooltip = "Lets you do a longjump without any items/kits"
	})
end)

run(function()
	local enabled
	local Desync
		
	Desync = vape.Categories.Exploits:CreateModule({
		Name = "Desync",
		Function = function()
			if not enabled.Enabled then vape:CreateNotification('Onyx', "Ignored, You do not have the setting on to use this module",5,"warning") return end
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				Desync:Toggle(false)
																vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
																						vape:CreateNotification('Onyx', "Note setfflag does not work for every supported executor now, this function just throws an error for now",10,"alert")
		setfflag("FFlagDebugGraphicsPreferD3D11","True")
		setfflag("FLogNetwork","7")
		setfflag("FFlagHandleAltEnterFullscreenManually","False")
		setfflag("DFFlagPlayerHumanoidPropertyUpdateRestrict","False")
		setfflag("DFIntDebugDefaultTargetWorldStepsPerFrame","-2147483648")
		setfflag("DFIntDebugSendDistInSteps","-2147483648")
		setfflag("DFIntMaxMissedWorldStepsRemembered","-2147483648")
		setfflag("DFIntWorldStepMax","-2147483648")
		end,
		Tooltip = "Note this will ban you for client modifications.",
	})
	enabled = Desync:CreateToggle({
        Name = 'Enabled',
        Default = false,
        Tooltip = 'Enables so you can use desync fflag method'
	})
end)


run(function()
local AutoReport 
	 AutoReport = vape.Categories.Exploits:CreateModule({
		Name = "AutoReport",
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				AutoReport:Toggle(false)
																						vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
			if callback then

				for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
					if v ~= game.Players.LocalPlayer then
					bedwars.Client:Get("ReportPlayer"):SendToServer(v)
						vape:CreateNotification('Onyx', "Reported '" .. v.Name .. "'", 1, "alert")
							task.wait(1 + math.random())
					end
				end
			end
		end,
		Tooltip = "Automatically reports everyone in the game",
	})
	AutoReport:Toggle(false)
end)


run(function()
	local AutoQueue
	

	
	AutoQueue = vape.Categories.Exploits:CreateModule({
		Name = 'AutoQueue',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				AutoQueue:Toggle(false)
																							vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
			if callback then
				AutoQueue:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill and deathTable.entityInstance == lplr.Character and isEveryoneDead() and store.matchState ~= 2 then
						joinQueue()
					end
				end))
				AutoQueue:Clean(vapeEvents.MatchEndEvent.Event:Connect(joinQueue))
			end
		end,
		Tooltip = 'Automatically queues for the next match'
	})

end)
			
run(function()
    local QueueDisplayConfig = {
        ActiveState = false,
        GradientControl = {Enabled = true},
        ColorSettings = {
            Gradient1 = {Hue = 0, Saturation = 0, Brightness = 1},
            Gradient2 = {Hue = 0, Saturation = 0, Brightness = 0.8}
        },
        Animation = {Speed = 0.5, Progress = 0}
    }

    local DisplayUtils = {
        createGradient = function(parent)
            local gradient = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
            gradient.Parent = parent
            return gradient
        end,
        updateColor = function(gradient, config)
            local time = tick() * config.Animation.Speed
            local interp = (math.sin(time) + 1) / 2
            local h = config.ColorSettings.Gradient1.Hue + (config.ColorSettings.Gradient2.Hue - config.ColorSettings.Gradient1.Hue) * interp
            local s = config.ColorSettings.Gradient1.Saturation + (config.ColorSettings.Gradient2.Saturation - config.ColorSettings.Gradient1.Saturation) * interp
            local b = config.ColorSettings.Gradient1.Brightness + (config.ColorSettings.Gradient2.Brightness - config.ColorSettings.Gradient1.Brightness) * interp
            gradient.Color = ColorSequence.new(Color3.fromHSV(h, s, b))
        end
    }

	local CoreConnection

    local function enhanceQueueDisplay()
		pcall(function() 
			CoreConnection:Disconnect()
		end)
        local success, err = pcall(function()
            if not lplr.PlayerGui:FindFirstChild('QueueApp') then return end
            
            for attempt = 1, 3 do
                if QueueDisplayConfig.GradientControl.Enabled then
                    local queueFrame = lplr.PlayerGui.QueueApp['1']
                    queueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    
                    local gradient = DisplayUtils.createGradient(queueFrame)
                    gradient.Rotation = 180
                    
                    local displayInterface = {
                        module = vape.watermark,
                        gradient = gradient,
                        GetEnabled = function()
                            return QueueDisplayConfig.ActiveState
                        end,
                        SetGradientEnabled = function(state)
                            QueueDisplayConfig.GradientControl.Enabled = state
                            gradient.Enabled = state
                        end
                    }
                    CoreConnection = game:GetService("RunService").RenderStepped:Connect(function()
                        if QueueDisplayConfig.ActiveState and QueueDisplayConfig.GradientControl.Enabled then
                            DisplayUtils.updateColor(gradient, QueueDisplayConfig)
                        end
                    end)
                end
                task.wait(0.1)
            end
        end)
        
        if not success then
            warn("Queue display enhancement failed: " .. tostring(err))
        end
    end

    local QueueDisplayEnhancer
    QueueDisplayEnhancer = vape.Categories.Utility:CreateModule({
        Name = 'QueueMods',
        Tooltip = 'Enhances the Queues display with dynamic gradients!! very cool lel',
        Function = function(enabled)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				QueueDisplayEnhancer:Toggle(false)
																								vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
            QueueDisplayConfig.ActiveState = enabled
            if enabled then
                enhanceQueueDisplay()
                QueueDisplayEnhancer:Clean(lplr.PlayerGui.ChildAdded:Connect(enhanceQueueDisplay))
			else
				pcall(function() 
					CoreConnection:Disconnect()
				end)
			end
        end
    })

   	QueueDisplayEnhancer:CreateSlider({
        Name = "Animation Speed",
        Function = function(speed)
            QueueDisplayConfig.Animation.Speed = math.clamp(speed, 0.1, 5)
        end,
        Min = 1,
        Max = 8,
        Default = 5
    })

    QueueDisplayEnhancer:CreateColorSlider({
        Name = "Color 1",
        Function = function(h, s, v)
            QueueDisplayConfig.ColorSettings.Gradient1 = {Hue = h, Saturation = s, Brightness = v}
        end
    })

    QueueDisplayEnhancer:CreateColorSlider({
        Name = "Color 2",
        Function = function(h, s, v)
            QueueDisplayConfig.ColorSettings.Gradient2 = {Hue = h, Saturation = s, Brightness = v}
        end
    })
end)

run(function()
local ReportStatus 
	 ReportStatus = vape.Categories.Exploits:CreateModule({
		Name = "ReportStatus",
		Function = function(callback)

			if callback then
																														ReportStatus:Toggle(false)

vape:CreateNotification("Onyx","This module is not finished",6,"alert")
			end
		end,
		Tooltip = "Returns a report status of your account",
	})
end)


run(function()
	local SetFPS
	local FPS
	
	SetFPS = vape.Categories.Utility:CreateModule({
		Name = "SetFPS",
		Function = function(callback)
			

			if callback then
				setfpscap(FPS.Value)
			else
				setfpscap(240)
			end
		end,
		Tooltip = "Removes or customizes the Frame-Per-Second limit",
	})
	
	FPS = SetFPS:CreateSlider({
		Name = "Frames Per Second",
		Min = 0,
		Max = 420,
		Default = 240,
		Function = function(value)
			setfpscap(value)
		end
	})
end)

local Attacking
run(function()
	local Killaura
	local SyncHits
	local Targets
	local Sort
	local SwingRange
	local AttackRange
	local ChargeTime
	local UpdateRate
	local AngleSlider
	local MaxTargets
	local Mouse
	local Swing
	local GUI
	local BoxSwingColor
	local BoxAttackColor
	local ParticleTexture
	local ParticleColor1
	local ParticleColor2
	local ParticleSize
	local Face
	local Animation
	local AnimationMode
	local AnimationSpeed
	local AnimationTween
	local Limit
	local LegitAura = {}
	local Particles, Boxes = {}, {}
	local anims, AnimDelay, AnimTween, armC0 = vape.Libraries.auraanims, tick()
	local AttackRemote = {FireServer = function() end}
	task.spawn(function()
		AttackRemote = bedwars.Client:Get(remotes.AttackEntity).instance
	end)

	local function getAttackData()
		if Mouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end

		if GUI.Enabled then
			if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then return false end
		end

		local sword = Limit.Enabled and store.hand or store.tools.sword
		if not sword or not sword.tool then return false end

		local meta = bedwars.ItemMeta[sword.tool.Name]
		if Limit.Enabled then
			if store.hand.toolType ~= 'sword' or bedwars.DaoController.chargingMaid then return false end
		end

		if LegitAura.Enabled then
			if (tick() - bedwars.SwordController.lastSwing) > 0.2 then return false end
		end

		return sword, meta
	end

	Killaura = vape.Categories.Blatant:CreateModule({
		Name = 'Killaura',
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function()
						lplr.PlayerGui.MobileUI['2'].Visible = Limit.Enabled
					end)
				end

				if Animation.Enabled and not (identifyexecutor and table.find({'Argon', 'Delta'}, ({identifyexecutor()})[1])) then
					local fake = {
						Controllers = {
							ViewmodelController = {
								isVisible = function()
									return not Attacking
								end,
								playAnimation = function(...)
									if not Attacking then
										bedwars.ViewmodelController:playAnimation(select(2, ...))
									end
								end
							}
						}
					}
					debug.setupvalue(oldSwing or bedwars.SwordController.playSwordEffect, 6, fake)
					debug.setupvalue(bedwars.ScytheController.playLocalAnimation, 3, fake)

					task.spawn(function()
						local started = false
						repeat
							if Attacking then
								if not armC0 then
									armC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
								end
								local first = not started
								started = true

								if AnimationMode.Value == 'Random' then
									anims.Random = {{CFrame = CFrame.Angles(math.rad(math.random(1, 360)), math.rad(math.random(1, 360)), math.rad(math.random(1, 360))), Time = 0.12}}
								end

								for _, v in anims[AnimationMode.Value] do
									AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(first and (AnimationTween.Enabled and 0.001 or 0.1) or v.Time / AnimationSpeed.Value, Enum.EasingStyle.Linear), {
										C0 = armC0 * v.CFrame
									})
									AnimTween:Play()
									AnimTween.Completed:Wait()
									first = false
									if (not Killaura.Enabled) or (not Attacking) then break end
								end
							elseif started then
								started = false
								AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationTween.Enabled and 0.001 or 0.3, Enum.EasingStyle.Exponential), {
									C0 = armC0
								})
								AnimTween:Play()
							end

							if not started then
								task.wait(1 / UpdateRate.Value)
							end
						until (not Killaura.Enabled) or (not Animation.Enabled)
					end)
				end

				local swingCooldown = 0
				repeat
					local attacked, sword, meta = {}, getAttackData()
					Attacking = false
					store.KillauraTarget = nil
					if sword then
						local plrs = entitylib.AllPosition({
							Range = SwingRange.Value,
							Wallcheck = Targets.Walls.Enabled or nil,
							Part = 'RootPart',
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = MaxTargets.Value,
							Sort = sortmethods[Sort.Value]
						})

						if #plrs > 0 then
							switchItem(sword.tool, 0)
							local selfpos = entitylib.character.RootPart.Position
							local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)

							for _, v in plrs do
								local delta = (v.RootPart.Position - selfpos)
								local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
								if angle > (math.rad(AngleSlider.Value) / 2) then continue end

								table.insert(attacked, {
									Entity = v,
									Check = delta.Magnitude > AttackRange.Value and BoxSwingColor or BoxAttackColor
								})
								targetinfo.Targets[v] = tick() + 1

								if not Attacking then
									Attacking = true
									store.KillauraTarget = v
									if not Swing.Enabled and AnimDelay < tick() and not LegitAura.Enabled then
										AnimDelay = tick() + (meta.sword.respectAttackSpeedForEffects and meta.sword.attackSpeed or math.max(ChargeTime.Value, 0.11))
										bedwars.SwordController:playSwordEffect(meta, false)
										if meta.displayName:find(' Scythe') then
											bedwars.ScytheController:playLocalAnimation()
										end

										if vape.ThreadFix then
											setthreadidentity(8)
										end
									end
								end

								if delta.Magnitude > AttackRange.Value then continue end
								if delta.Magnitude < 14.4 and (tick() - swingCooldown) < math.max(ChargeTime.Value, 0.02) then continue end

								local actualRoot = v.Character.PrimaryPart
								if actualRoot then
									local dir = CFrame.lookAt(selfpos, actualRoot.Position).LookVector
									local pos = selfpos + dir * math.max(delta.Magnitude - 14.399, 0)
									swingCooldown = tick()
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									store.attackReach = (delta.Magnitude * 100) // 1 / 100
									store.attackReachUpdate = tick() + 1

									if delta.Magnitude < 14.4 and ChargeTime.Value > 0.11 then
										AnimDelay = tick()
									end

local Q = 0.5
																																if SyncHit.Enabled  then Q = 0.35 else Q = 0.5 end
									AttackRemote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = 0},
										lastSwingServerTimeDelta = Q,
										entityInstance = v.Character,
										validate = {
											raycast = {
												cameraPosition = {value = pos},
												cursorDirection = {value = dir}
											},
											targetPosition = {value = actualRoot.Position},
											selfPosition = {value = pos}
										}
									})
								end
							end
						end
					end

					for i, v in Boxes do
						v.Adornee = attacked[i] and attacked[i].Entity.RootPart or nil
						if v.Adornee then
							v.Color3 = Color3.fromHSV(attacked[i].Check.Hue, attacked[i].Check.Sat, attacked[i].Check.Value)
							v.Transparency = 1 - attacked[i].Check.Opacity
						end
					end

					for i, v in Particles do
						v.Position = attacked[i] and attacked[i].Entity.RootPart.Position or Vector3.new(9e9, 9e9, 9e9)
						v.Parent = attacked[i] and gameCamera or nil
					end

					if Face.Enabled and attacked[1] then
						local vec = attacked[1].Entity.RootPart.Position * Vector3.new(1, 0, 1)
						entitylib.character.RootPart.CFrame = CFrame.lookAt(entitylib.character.RootPart.Position, Vector3.new(vec.X, entitylib.character.RootPart.Position.Y + 0.001, vec.Z))
					end

					--#attacked > 0 and #attacked * 0.02 or
local S = 0
					if SyncHit.Enabled then S = 1 / UpdateRate.Value else S = 0.75 / UpdateRate.Value end
					task.wait(S)
				until not Killaura.Enabled
			else
				store.KillauraTarget = nil
				for _, v in Boxes do
					v.Adornee = nil
				end
				for _, v in Particles do
					v.Parent = nil
				end
				if inputService.TouchEnabled then
					pcall(function()
						lplr.PlayerGui.MobileUI['2'].Visible = true
					end)
				end
				debug.setupvalue(oldSwing or bedwars.SwordController.playSwordEffect, 6, bedwars.Knit)
				debug.setupvalue(bedwars.ScytheController.playLocalAnimation, 3, bedwars.Knit)
				Attacking = false
				if armC0 then
					AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationTween.Enabled and 0.001 or 0.3, Enum.EasingStyle.Exponential), {
						C0 = armC0
					})
					AnimTween:Play()
				end
			end
		end,
		Tooltip = 'Attack players around you\nwithout aiming at them.'
	})
	Targets = Killaura:CreateTargets({
		Players = true,
		NPCs = true
	})
	local methods = {'Damage', 'Distance'}
	for i in sortmethods do
		if not table.find(methods, i) then
			table.insert(methods, i)
		end
	end

if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
	SwingRange = Killaura:CreateSlider({
		Name = 'Swing range',
		Min = 1,
		Max = 18,
		Default = 18,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AttackRange = Killaura:CreateSlider({
		Name = 'Attack range',
		Min = 1,
		Max = 18,
		Default = 18,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	ChargeTime = Killaura:CreateSlider({
		Name = 'Swing time',
		Min = 0,
		Max = 1,
		Default = 0.3,
		Decimal = 100
	})
			SyncHit = {Enabled = false}
else
	SwingRange = Killaura:CreateSlider({
		Name = 'Swing range',
		Min = 1,
		Max = 32,
		Default = 18,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AttackRange = Killaura:CreateSlider({
		Name = 'Attack range',
		Min = 1,
		Max = 32,
		Default = 18,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	ChargeTime = Killaura:CreateSlider({
		Name = 'Swing time',
		Min = 0,
		Max = 1,
		Default = 0.3,
		Decimal = 100
	})
		SyncHit = Killaura:CreateToggle({
		Name = 'Sync Hit-Time',
		Tooltip = "Synchronize's ur hit time",
		Default = false
	})
end

	AngleSlider = Killaura:CreateSlider({
		Name = 'Max angle',
		Min = 1,
		Max = 360,
		Default = 360
	})
	UpdateRate = Killaura:CreateSlider({
		Name = 'Update rate',
		Min = 1,
		Max = 360,
		Default = 60,
		Suffix = 'hz'
	})
	MaxTargets = Killaura:CreateSlider({
		Name = 'Max targets',
		Min = 1,
		Max = 8,
		Default = 5
	})
	Sort = Killaura:CreateDropdown({
		Name = 'Target Mode',
		List = methods
	})
	Mouse = Killaura:CreateToggle({Name = 'Require mouse down'})
	Swing = Killaura:CreateToggle({Name = 'No Swing'})
	GUI = Killaura:CreateToggle({Name = 'GUI check'})
	Killaura:CreateToggle({
		Name = 'Show target',
		Function = function(callback)
			BoxSwingColor.Object.Visible = callback
			BoxAttackColor.Object.Visible = callback
			if callback then
				for i = 1, 10 do
					local box = Instance.new('BoxHandleAdornment')
					box.Adornee = nil
					box.AlwaysOnTop = true
					box.Size = Vector3.new(3, 5, 3)
					box.CFrame = CFrame.new(0, -0.5, 0)
					box.ZIndex = 0
					box.Parent = vape.gui
					Boxes[i] = box
				end
			else
				for _, v in Boxes do
					v:Destroy()
				end
				table.clear(Boxes)
			end
		end
	})
	BoxSwingColor = Killaura:CreateColorSlider({
		Name = 'Target Color',
		Darker = true,
		DefaultHue = 0.6,
		DefaultOpacity = 0.5,
		Visible = false
	})
	BoxAttackColor = Killaura:CreateColorSlider({
		Name = 'Attack Color',
		Darker = true,
		DefaultOpacity = 0.5,
		Visible = false
	})
	Killaura:CreateToggle({
		Name = 'Target particles',
		Function = function(callback)
			ParticleTexture.Object.Visible = callback
			ParticleColor1.Object.Visible = callback
			ParticleColor2.Object.Visible = callback
			ParticleSize.Object.Visible = callback
			if callback then
				for i = 1, 10 do
					local part = Instance.new('Part')
					part.Size = Vector3.new(2, 4, 2)
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1
					part.CanQuery = false
					part.Parent = Killaura.Enabled and gameCamera or nil
					local particles = Instance.new('ParticleEmitter')
					particles.Brightness = 1.5
					particles.Size = NumberSequence.new(ParticleSize.Value)
					particles.Shape = Enum.ParticleEmitterShape.Sphere
					particles.Texture = ParticleTexture.Value
					particles.Transparency = NumberSequence.new(0)
					particles.Lifetime = NumberRange.new(0.4)
					particles.Speed = NumberRange.new(16)
					particles.Rate = 128
					particles.Drag = 16
					particles.ShapePartial = 1
					particles.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
					})
					particles.Parent = part
					Particles[i] = part
				end
			else
				for _, v in Particles do
					v:Destroy()
				end
				table.clear(Particles)
			end
		end
	})
	ParticleTexture = Killaura:CreateTextBox({
		Name = 'Texture',
		Default = 'rbxassetid://14736249347',
		Function = function()
			for _, v in Particles do
				v.ParticleEmitter.Texture = ParticleTexture.Value
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleColor1 = Killaura:CreateColorSlider({
		Name = 'Color Begin',
		Function = function(hue, sat, val)
			for _, v in Particles do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
				})
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleColor2 = Killaura:CreateColorSlider({
		Name = 'Color End',
		Function = function(hue, sat, val)
			for _, v in Particles do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, val))
				})
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleSize = Killaura:CreateSlider({
		Name = 'Size',
		Min = 0,
		Max = 1,
		Default = 0.2,
		Decimal = 100,
		Function = function(val)
			for _, v in Particles do
				v.ParticleEmitter.Size = NumberSequence.new(val)
			end
		end,
		Darker = true,
		Visible = false
	})
	Face = Killaura:CreateToggle({Name = 'Face target'})
	Animation = Killaura:CreateToggle({
		Name = 'Custom Animation',
		Function = function(callback)
			AnimationMode.Object.Visible = callback
			AnimationTween.Object.Visible = callback
			AnimationSpeed.Object.Visible = callback
			if Killaura.Enabled then
				Killaura:Toggle()
				Killaura:Toggle()
			end
		end
	})
	local animnames = {}
	for i in anims do
		table.insert(animnames, i)
	end
	AnimationMode = Killaura:CreateDropdown({
		Name = 'Animation Mode',
		List = animnames,
		Darker = true,
		Visible = false
	})
	AnimationSpeed = Killaura:CreateSlider({
		Name = 'Animation Speed',
		Min = 0,
		Max = 2,
		Default = 1,
		Decimal = 10,
		Darker = true,
		Visible = false
	})
	AnimationTween = Killaura:CreateToggle({
		Name = 'No Tween',
		Darker = true,
		Visible = false
	})
	Limit = Killaura:CreateToggle({
		Name = 'Limit to items',
		Function = function(callback)
			if inputService.TouchEnabled and Killaura.Enabled then
				pcall(function()
					lplr.PlayerGui.MobileUI['2'].Visible = callback
				end)
			end
		end,
		Tooltip = 'Only attacks when the sword is held'
	})
	--[[LegitAura = Killaura:CreateToggle({
		Name = 'Swing only',
		Tooltip = 'Only attacks while swinging manually'
	})]]
end)

run(function()
	local Clutch
	local lastY = 0

	local function getHeldBlock()
		if store.hand.toolType == 'block' then
			return store.hand.tool.Name
		end
	end

local function tryClutch() 
if not entitylib.isAlive then return end 
local root = entitylib.character.RootPart
 local humanoid = entitylib.character.Humanoid
 if not root or not humanoid then return end
 local heldBlock = getHeldBlock() 
if not heldBlock then return end
 local velocity = root.Velocity 
local posBelow = root.Position - Vector3.new(0, entitylib.character.HipHeight + 3, 0)
 if velocity.Y < -2 and humanoid.FloorMaterial == Enum.Material.Air then 
local block, blockPos = getPlacedBlock(posBelow) 
if not block then 
task.spawn(bedwars.placeBlock, blockPos * 3, heldBlock, false) 

end 
end 
end

	Clutch = vape.Categories.Exploits:CreateModule({
		Name = "Clutch",
		Function = function(callback)
		   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
			Clutch:Toggle(false)
																															vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
			if callback then
				repeat
					pcall(tryClutch)
					task.wait(0.01)
				until not Clutch.Enabled
			end
		end,
		Tooltip = "Automatically clutches you by placing a block under your feet when falling."
	})
end)

run(function()

local BedAlarm 
	 BedAlarm = vape.Categories.Exploits:CreateModule({
		Name = "BedAlarm",
		Function = function(callback)

			if callback then
																																						BedAlarm:Toggle(false)

vape:CreateNotification("Onyx","This module is nearly finished",6,"alert")
			end
		end,
		Tooltip = "Alerts you without needing to purchase the bed alarm upgrade",
	})
end)


run(function()
	local MS
	local AutoShoot
	local shooting = false
	local old

	AutoShoot = vape.Categories.Exploits:CreateModule({
		Name = "AutoShoot",
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				AutoShoot:Toggle(false)
																																	vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       

			if callback then
				old = bedwars.ProjectileController.createLocalProjectile

				bedwars.ProjectileController.createLocalProjectile = function(...)
					local source, data, proj = ...
					local projectileWhitelist = {
						"banana_peel", "bananarang", "beehive_grenade", "blackhole_bomb", "boba_blaster", "carrot_cannon",
						"glue_projectile_charging", "chicken_deploy", "cluster_bomb", "orions_belt_bow", "pit",
						"ninja_chakram_1", "ninja_chakram_2", "ninja_chakram_3", "ninja_chakram_4",
						"disco_grenade", "dizzy_toad", "feather_bow", "falconer_bow", "falconer_crossbow",
						"falconer_headhuter", "firecrackers", "firework_rocket_launcher", "flower_bow",
						"flower_crossbow", "flower_headhunter", "frozen_fortness", "glue_projectile",
						"gumball_launcher", "impulse_grenade", "pumpkin_bomb_1", "pumpkin_bomb_2",
						"pumpkin_bomb_3", "large_rock", "life_bow", "life_crossbow", "life_headhunter",
						"meteor_shower", "necromancer_staff", "oil_consumable", "party_hat_launcher",
						"poison_splash_potion", "popup_cube", "glitch_popup_cube", "throwable_bridge",
						"glitch_throwable_bridge", "c4_bomb", "robbery_ball", "glitch_robbery_ball",
						"grenade_launcher", "rocket_launcher", "glitch_grenade_launcher", "santa_bomb_siege",
						"santa_bomb", "sheriff_crossbow", "sand_spear", "sleep_splash_potion", "smoke_grenade",
						"glitch_snowball", "spear", "rainbow_bow", "spirit", "sticky_firework", "swap_ball", "tennis_racket",
						"arrow", "fireball", "snowball", "frosted_snowball"
					}
					
					local function isProjectileAllowed(name)
						for _, projName in ipairs(projectileWhitelist) do
							if name == projName then
								return true
							end
						end
						return false
					end
				if source and isProjectileAllowed(proj) and not shooting then
						task.spawn(function()
							local bows = getCrossbows()
							if #bows > 0 then
								shooting = true
								task.wait(0.15)
								local selected = store.inventory.hotbarSlot

								for _, v in getCrossbows() do
									if hotbarSwitch(v) then
										task.wait(MS.Value / 1000)
										mouse1click()
										task.wait(MS.Value / 1000)
									end
								end

								hotbarSwitch(selected)
								shooting = false
							end
						end)
					end
					return old(...)
				end
			else
				if old then
					bedwars.ProjectileController.createLocalProjectile = old
				end
			end
		end,
		Tooltip = "Automatically shoots for you with every projectile, rewrite soon does not work due to a patch",
	})

	MS = AutoShoot:CreateSlider({
		Name = "Swap Delay",
		Min = 50,
		Max = 1000,
		Default = 150,
		Suffix = "ms"
	})
end)


run(function()
	local Disabler
	
	local function characterAdded(char)
		for _, v in getconnections(char.RootPart:GetPropertyChangedSignal('CFrame')) do
			hookfunction(v.Function, function() end)
		end
		for _, v in getconnections(char.RootPart:GetPropertyChangedSignal('Velocity')) do
			hookfunction(v.Function, function() end)
		end
	end
	
	Disabler = vape.Categories.Exploits:CreateModule({
		Name = 'Disabler',
		Function = function(callback)
			if callback then
				Disabler:Clean(entitylib.Events.LocalAdded:Connect(characterAdded))
				if entitylib.isAlive then
					characterAdded(entitylib.character)
				end
			end
		end,
		Tooltip = 'Disables GetPropertyChangedSignal detections for movement'
	})
end)

run(function()
	local function test()
		local root = entitylib.character.RootPart
		local basePos = root.Position

		local item, amount = getWool()
		if not item then
			vape:CreateNotification("Funny", "No wool found in inventory!", 5, "alert")
			return
		end
		bedwars.placeBlock(basePos, item)
	end
	

	local function penis()
		local root = entitylib.character.RootPart
		local basePos = root.Position

		local item, amount = getWool()
		if not item then
			vape:CreateNotification("Funny", "No wool found in inventory!", 5, "alert")
			return
		end

			local forward = root.CFrame.LookVector * 3
		local origin = (basePos + forward) - Vector3.new(0, 3, 0)

		local pattern = {
			Vector3.new(0, 0, 0),  
			Vector3.new(-1, 0, 0),
			Vector3.new(1, 0, 0),  
			Vector3.new(0, 1, 0), 
			Vector3.new(0, 2, 0),  
		}
		for _, offset in ipairs(pattern) do
			local pos = basePos + offset * 3

			bedwars.placeBlock(pos, item)
			task.wait(0.01)
		end
	end
local Funny
local Options
	Funny = vape.Categories.Troll:CreateModule({
		Name = "Funny",
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" then
				Funny:Toggle(false)
																																			vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end

			if callback then
				if Options.Value == "penis" then
					penis()
				elseif Options.Value == "smile" then
					vape:CreateNotification("Funny", "Coming soon :D", 5)
				elseif Options.Value == "nazi" then
					vape:CreateNotification("Funny", "Coming soon :D", 5)
				elseif Options.Value == "test" then
					test()
				end
			end
		end,
		Tooltip = ":troll: rewrite soon"
	})

	Options = Funny:CreateDropdown({
		Name = "Options",
		List = {"penis", "nazi", "smile",'test'}
	})
end)


run(function()
    local TypeData
    local PlayerData
    local includeEmptyMatches
	local Clean
    PlayerData = vape.Categories.Minigames:CreateModule({
        Name = "PlayerData",
        Function = function(callback)
			   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				PlayerData:Toggle(false)
																																				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
	    	if not callback then return end

            local http = game:GetService("HttpService")
            local store = bedwars.Store:getState()

            if TypeData.Value == "important" then
                local stats = {}
                local totals = {
                    TotalWins = 0,
                    TotalLosses = 0,
                    TotalMatches = 0,
                    TotalBedBreaks = 0,
                    TotalFinalKills = 0
                }

                local leaderboard = store and store.Leaderboard and store.Leaderboard.queues

                if leaderboard then
                    for mode, data in pairs(leaderboard) do
                        local wins = data.wins or 0																
                        local losses = data.losses or 0
						local ties = data.ties or 0
                        local matches = data.matches or (wins + losses)
                        local winrate = (wins + losses > 0) and ((wins / (wins + losses)) * 100) or 0
						local earlyleaves = data.earlyLeaves or 0
                        local bedBreaks = data.bedBreaks or 0
                        local finalKills = data.finalKills or 0

                        totals.TotalWins += wins
                        totals.TotalLosses += losses
                        totals.TotalMatches += matches
                        totals.TotalBedBreaks += bedBreaks
                        totals.TotalFinalKills += finalKills

                        if includeEmptyMatches.Value or (wins > 0 or losses > 0 or matches > 0) then
                            stats[mode] = {
                                Winrate = string.format("%.2f%%", winrate),
                                Wins = wins,
                                Losses = losses,
								Ties = ties,
                                Matches = matches,
								EarlyLeaves = earlyleaves,
                                BedBreaks = bedBreaks,
                                FinalKills = finalKills
                            }
                        end
                    end
                end

                local achievements = {}
                if store and store.Bedwars and store.Bedwars.achievements then
                    for _, ach in pairs(store.Bedwars.achievements) do
                        table.insert(achievements, ach)
                    end
                elseif leaderboard and leaderboard.bedwars_duels and leaderboard.bedwars_duels.obtainedAchievements then
                    achievements = leaderboard.bedwars_duels.obtainedAchievements
                end

                local dataOut = {
					GameModes = stats,
                    Totals = totals,
                    Achievements = achievements
                }
				if Clean then
					local json = http:JSONEncode(dataOut)
	                json = json:gsub(',"', ',\n    "')
	                json = json:gsub('{', '{\n    ')
	                json = json:gsub('}', '\n}')
	
	                writefile("ReVape/profiles/PlayerData.txt", json)
	                vape:CreateNotification("PlayerData", "Created PlayerData.txt file at profiles", 10)
					else
						local json = dataOut
						
                		writefile("ReVape/profiles/PlayerData.txt", json)
                		vape:CreateNotification("PlayerData", "Created PlayerData.txt file at profiles", 10)
					end
            elseif TypeData.Value == "full" then

				if Clean then
					local json = http:JSONEncode(bedwars.Store:getState())
	                json = json:gsub(',"', ',\n    "')
	                json = json:gsub('{', '{\n    ')
	                json = json:gsub('}', '\n}')
	
	                writefile("ReVape/profiles/PlayerDataJSON.txt", json)
	                vape:CreateNotification("PlayerData", "Created PlayerData.json file at profiles", 10)
					else
						local json = http:JSONEncode(bedwars.Store:getState())
						
                		writefile("ReVape/profiles/PlayerDataJSON.txt", json)
                		vape:CreateNotification("PlayerData", "Created PlayerData.json file at profiles", 10)
					end
            end
		PlayerData:Toggle()
        end,
        Tooltip = "Creates a file that has your data"
    })

    TypeData = PlayerData:CreateDropdown({
        Name = "Type",
        List = {"important", "full"}
    })

    includeEmptyMatches = PlayerData:CreateToggle({
        Name = "EmptyMatches",
        Default = false,
        Tooltip = "ONLY FOR IMPORTANT TYPE (adds 0-stats matches to your file)"
    })
	Clean = PlayerData:CreateToggle({
        Name = "Clean",
        Default = true,
        Tooltip = "Cleans up the JSON file"
    })
end)



run(function()
local AutoWin 
	 AutoWin = vape.Categories.Exploits:CreateModule({
		Name = "AutoWin",
		Function = function(callback)

			if callback then
																																						AutoWin:Toggle(false)

vape:CreateNotification("Onyx","This module is NOT finished",10,"alert")
			end
		end,
		Tooltip = "New Method for autowinning",
	})
end)

run(function()
local LP 
	 LP = vape.Categories.Exploits:CreateModule({
		Name = "LeaveParty",
		Function = function(callback)

			if callback then
																																						LP:Toggle(false)

bedwars.PartyController:leaveParty()
			end
		end,
		Tooltip = "Makes u leave ur current party",
	})
end)

end
