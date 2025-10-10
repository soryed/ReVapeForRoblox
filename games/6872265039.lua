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
	local Sprint
	local old
	
	Sprint = vape.Categories.Combat:CreateModule({
		Name = 'Sprint',
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then pcall(function() lplr.PlayerGui.MobileUI['2'].Visible = false end) end
				old = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local call = old(...)
					bedwars.SprintController:startSprinting()
					return call
				end
				Sprint:Clean(entitylib.Events.LocalAdded:Connect(function() bedwars.SprintController:stopSprinting() end))
				bedwars.SprintController:stopSprinting()
			else
				if inputService.TouchEnabled then pcall(function() lplr.PlayerGui.MobileUI['2'].Visible = true end) end
				bedwars.SprintController.stopSprinting = old
				bedwars.SprintController:stopSprinting()
			end
		end,
		Tooltip = 'Sets your sprinting to true.'
	})
end)
	
run(function()
	local AutoGamble
	
	AutoGamble = vape.Categories.Minigames:CreateModule({
		Name = 'AutoGamble',
		Function = function(callback)
			if callback then
				AutoGamble:Clean(bedwars.Client:GetNamespace('RewardCrate'):Get('CrateOpened'):Connect(function(data)
					if data.openingPlayer == lplr then
						local tab = bedwars.CrateItemMeta[data.reward.itemType] or {displayName = data.reward.itemType or 'unknown'}
						notif('AutoGamble', 'Won '..tab.displayName, 5)
					end
				end))
	
				repeat
					if not bedwars.CrateAltarController.activeCrates[1] then
						for _, v in bedwars.Store:getState().Consumable.inventory do
							if v.consumable:find('crate') then
								bedwars.CrateAltarController:pickCrate(v.consumable, 1)
								task.wait(1.2)
								if bedwars.CrateAltarController.activeCrates[1] and bedwars.CrateAltarController.activeCrates[1][2] then
									bedwars.Client:GetNamespace('RewardCrate'):Get('OpenRewardCrate'):SendToServer({
										crateId = bedwars.CrateAltarController.activeCrates[1][2].attributes.crateId
									})
								end
								break
							end
						end
					end
					task.wait(1)
				until not AutoGamble.Enabled
			end
		end,
		Tooltip = 'Automatically opens lucky crates, piston inspired!'
	})
end)
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

    local Users = {
        KnownUsers = {
            Chase = {22808138, 4782733628, 7447190808, 3196162848},
            Orion = {547598710, 5728889572, 4652232128, 7043591647, 7209929547, 7043958628, 7418525152, 3774791573, 8606089749},
            LisNix = {162442297, 702354331, 9350301723},
            Nwr = {307212658, 5097000699, 4923561416},
            Gorilla = {514679433, 2431747703, 4531785383},
            Typhoon = {2428373515, 7659437319},
            Erin = {2465133159},
            Ghost = {7558211130, 1708400489},
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

    ACMOD = vape.Categories.Minigames:CreateModule({
        Name = 'Anti-Cheat Mods',
        Tooltip = "Fetches all AC mod users (including unknowns)",
        Function = function()
            vape:CreateNotification('Loading...', "Currently fetching mods", 3)
            task.wait(4)

            local HttpService = game:GetService("HttpService")
            local Players = game:GetService("Players")

            local Offline, InGame, Online, Studio = 0, 0, 0, 0
            local url = "https://presence.roproxy.com/v1/presence/users"
            local headers = {["Content-Type"] = "application/json"}
            local data = {userIds = {}}

            if Side.Value == "Known" then
                if Specific.Value == "All" then
                    for _, numbers in pairs(Users.KnownUsers) do
                        for _, num in ipairs(numbers) do
                            table.insert(data.userIds, num)
                        end
                    end
                elseif Users.KnownUsers[Specific.Value] then
                    for _, num in ipairs(Users.KnownUsers[Specific.Value]) do
                        table.insert(data.userIds, num)
                    end
                end
            elseif Side.Value == "Unknown" then
                for _, num in ipairs(Users.UnknownUsers) do
                    table.insert(data.userIds, num)
                end
            end

            local jsonData = HttpService:JSONEncode(data)
            local response
            local success, err = pcall(function()
                response = HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
            end)

            if success then
                local result = HttpService:JSONDecode(response)
                if result.userPresences then
                    for _, user in pairs(result.userPresences) do
                        local username = Players:GetNameFromUserIdAsync(user.userId)
                        if user.userPresenceType == 0 then
                            Offline += 1
                            if IncludeOffline.Value then
                                vape:CreateNotification('Offline Mod detected!', username, 5, "alert")
                            end
                        elseif user.userPresenceType == 1 then 
                            Online += 1
                            vape:CreateNotification('Online Mod detected!', username, 15, "warning")
                        elseif user.userPresenceType == 2 then 
                            InGame += 1
                            vape:CreateNotification('InGame Mod detected!', username, 15, "warning")
                        elseif user.userPresenceType == 3 then 
                            Studio += 1
                            if IncludeStudio.Value then
                                vape:CreateNotification('Studio Mod detected!', username, 5, "warning")
                            end
                        end
                    end
                end

                local Status = InGame + Online

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
                vape:CreateNotification('Failed!', "Failed to get presence data: " .. tostring(err), 15, "alert")
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
	local Header = "Small Update!"
	local Verison = "0.1.3"
	local notes = "A small update, upped KA attack range. I have also made three more functions in Minigames 'Anti-Cheat Mods, Patch Notes, and Switch Gui'. Anti-Cheat mods detect all known and unknown mods, patch notes is this, and i have also created switching ur verison of gui!"
	local time = 45
	local patchnotes = vape.Categories.Minigames:CreateModule({
		Name = "Patch Notes",
		Tooltip = "This shows off the updates logs",
		Function = function()
			vape:CreateNotification(Header.."|"..Verison,notes,time)
		end		
	})
end)

run(function()
    local Users = {
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
    local NSD
    local Party
    local IncludeSpecs
    local CreateLogsOfMODS    


	local function checkFriends(list)
		for _, v in list do
			if joined[v] then
				return joined[v]
			end
		end
		return nil
	end

	local function staffFunction(plr, checktype)
		if not vape.Loaded then
			repeat task.wait() until vape.Loaded
		end
	
		notif('StaffDetector', 'Staff Detected ('..checktype..'): '..plr.Name..' ('..plr.UserId..')', 60, 'alert')
		whitelist.customtags[plr.Name] = {{text = 'GAME STAFF', color = Color3.new(1, 0, 0)}}
	
		if Party.Enabled and not checktype:find('clan') then
			bedwars.PartyController:leaveParty()
		end
		if CreateLogsOfMODS.Enabled then
 		     local Format
		    if checktype == 'impossible_join' then
		Format	= "[USERNAME]:"..plr.Name.."|".."[USERID]:"..plr.UserId.."|".."[DATE]:"..tostring(DateTime:now()).."|".."[TYPE]:".."[IMPOSSIBLE JOIN]"
		end    
		    if checktype == 'detected_mod_join' then
		Format	= "[USERNAME]:"..plr.Name.."|".."[USERID]:"..plr.UserId.."|".."[DATE]:"..tostring(DateTime:now()).."|".."[TYPE]:".."[KNOWN MOD JOIN]"
		end    

		    if not isfile('newvape/profiles/logs.txt') then
			writefile('newvape/profiles/logs.txt', Format)
		    else
			writefile('newvape/profiles/logs.txt', Format)
		    end 
		end
	end	
	local function checkJoin(plr, connection)
		if not plr:GetAttribute('Team') and plr:GetAttribute('Spectator') and not bedwars.Store:getState().Game.customMatch then
			connection:Disconnect()
			local tab, pages = {}, playersService:GetFriendsAsync(plr.UserId)
			for _ = 1, 4 do
				for _, v in pages:GetCurrentPage() do
					table.insert(tab, v.Id)
				end
				if pages.IsFinished then break end
				pages:AdvanceToNextPageAsync()
			end
	
			for i, v in Users do
			    
			end

			local friend = checkFriends(tab)
			if not friend then
				staffFunction(plr, 'impossible_join')
				return true
			elseif Users[plr.UserId] then
			    staffFunction(plr, 'detected_mod_join')
			    return true
			else
				notif('StaffDetector', string.format('Spectator %s joined from %s', plr.Name, friend), 20, 'warning')
		if CreateLogsOfMODS.Enabled then
		    local Format = "[USERNAME]:"..plr.Name.."|".."[USERID]:"..plr.UserId.."|".."[DATE]:"..tostring(DateTime:now()).."|".."[TYPE]:".."[SPECTATOR JOIN]"

		    if not isfile('newvape/profiles/logs.txt') then
			writefile('newvape/profiles/logs.txt', Format)
		    else
			writefile('newvape/profiles/logs.txt', Format)
		    end 
		end
			end
		end
	end
	
	local function playerAdded(plr)
		joined[plr.UserId] = plr.Name
		if plr == lplr then return end
	

			local connection
			connection = plr:GetAttributeChangedSignal('Spectator'):Connect(function()
			    if IncludeSpecs.Enabled then
				checkJoin(plr, connection)
			    end
			end)
			StaffDetector:Clean(connection)
			if checkJoin(plr, connection) then
				return
			end
	
	
	end

    NSD = vape.Categories.Utility:CreateModule({
		Name = 'StaffDetectorV2',
		Function = function(callback)
			if callback then
				StaffDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
				for _, v in playersService:GetPlayers() do
					task.spawn(playerAdded, v)
				end
			else
				table.clear(joined)
			end
		end,
		Tooltip = 'A Newer verison of Staff-Detector'
	})

    Party = NSD:CreateToggle({
	Name = 'Leave party',
	Default = true,
   })
    IncludeSpecs = NSD:CreateToggle({
	Name = 'Include Spectators',
        Tooltip = 'NOTE: Anti-Cheat mods could create new alts, ill say to keep this on to get the new username. BUT THIS CAN DO FALSE DETECTIONS!!',
	Default = true,
   })
    CreateLogsOfMODS = NSD:CreateToggle({
	Name = 'Logs',
	Default = false,
	Tooltip = 'all this does is keep track of every mod/spectators has joined you with a date'
   })
end)


--[[

run(function()
	local method
	FTLMFAO = vape.Categories.Minigames:CreateModule({
		Name = "FTLMAO",
		Function = function(callback)
			if callback then
			    if method.Value == 'RemoteEvents' then
				for i, v in game:GetDescendants() do
					if v:IsA('RemoteEvent') or v:IsA('UnreliableRemoteEvent') then
					while FTLMFAO.Enabled do
						v:FireServer()					 
						task.wait()
					end
				   end
				end
			   end
if method.Value == 'RemoteFunctions' then
				for i, v in game:GetDescendants()do
					if v:IsA('RemoteFunction') then
					while FTLMFAO.Enabled do
						v:InvokeServer()					 
						task.wait()
					end
				   end
				end
			   end
if method.Value == 'BindableEvents' then
				for i, v in game:GetDescendants()do
					if v:IsA('BindableEvent')  then
					while FTLMFAO.Enabled do
						v:Fire()					 
						task.wait()
					end
				   end
				end
			   end

			end
if method.Value == 'BindableFunctions' then
				for i, v in game:GetDescendants()do
					if  v:IsA('BindableFunction') then
					while FTLMFAO.Enabled do
						v:Invoke()					 
						task.wait()
					end
				   end
				end
			   end

			end

		end	
	})
	method = FTLMFAO:CreateDrowndrop({
	   Name = 'Method',
	   List = {'RemoteEvents','RemoteFunctions','BindableEvents','BindableFunctions'}
	})
end)

]]--

run(function()
    local TAG
    local CustomTAG
    local R, G, B
    local Org = ""
    local OrgText = ""
    local player = game:GetService('Players').LocalPlayer
    if not player.Tags['0'] then
	notif('Failed', "Couldn't find the folder 'TAGS' to change ur tag", 20, 'alert')

    end
	local function Color3ToHex(r,g,b)
		return string.lower(string.format("#%02X%02X%02X", r , g , b))
	end

    Org = player.Tags['0'].Value
    OrgText =  player.Tags['0']:GetAttribute('Text')
    CustomTAG = vape.Categories.Minigames:CreateModule({
        Name = 'CustomTag',
        Function = function(callback)
            if callback then
                player.Tags['0'].Value = "<font color='rgb("..R.Value..","..G.Value..","..B.Value..")'>["..TAG.Value.."]</font>"
		 player.Tags['0']:SetAttribute('Text',TAG.Value)
				 player:SetAttribute('ClanTag',TAG.Value)
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
							 player.Tags['0']:GetAttribute('Text'),
							nameToFind
						)
					end
				end
			end
		end)
	end
end)

            else
                player.Tags['0'].Value = Org
		 player.Tags['0']:SetAttribute('Text',OrgText)
player:SetAttribute('ClanTag',OrgText)
            end
        end,
        Tooltip = 'Client-Sided visual custom clan tag on-chat'
    })

    TAG = CustomTAG:CreateTextBox({
        Name = 'Tag Text',
        Placeholder = '',
	Function = function()
	    CustomTAG:Toggle()
task.wait()
CustomTAG:Toggle()
	end
    })

   R = CustomTAG:CreateSlider({
        Name = 'R',
        Min = 0,
        Max = 255,
        Default = 255,
	Function = function()
CustomTAG:Toggle()
task.wait()
CustomTAG:Toggle()
	end
    })
     G = CustomTAG:CreateSlider({
        Name = 'G',
        Min = 0,
        Max = 255,
        Default = 255,
	Function = function()
	    CustomTAG:Toggle()
task.wait()
CustomTAG:Toggle()
	end
    })
   B =  CustomTAG:CreateSlider({
        Name = 'B',
        Min = 0,
        Max = 255,
        Default = 255,
	Function = function()
	   CustomTAG:Toggle()
task.wait()
CustomTAG:Toggle()
	end
    })
end)

run(function()
  local Players = game:GetService("Players")
local player = Players.LocalPlayer
    local PlayerLevel
	local level 
  

PlayerLevel = vape.Categories.Minigames:CreateModule({
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
