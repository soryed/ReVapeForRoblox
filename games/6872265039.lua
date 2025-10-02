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
	NM = vape.Categories.Exploits:CreateModule({
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
	GetExecutor = vape.Categories.Exploits:CreateModule({
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
			Chase = {
				22808138, 4782733628,7447190808, 3196162848
			},
			Orion = {
				547598710,5728889572,4652232128,7043591647,7209929547,7043958628,7418525152,3774791573,8606089749
			},
			LisNix = {
			162442297,702354331,9350301723
			},
			Nwr = {
				307212658,5097000699,4923561416
			},
			Gorilla = {
				514679433,2431747703,4531785383
			},
			Typhoon = {
				2428373515,7659437319
			},
			Erin = {
				2465133159,
			},
			Ghost = {
				7558211130,1708400489
			},
			Sponge = {
				376388734,5157136850
			},
			Gora = {
				589533315,567497793
			},
			Apple = {
				334013471,145981200,4721068661,8006518573,3547758846,7155624750,7468661659
			},
			Dom = {
				239431610,2621170992
			},
			Kevin = {
				575474067,4785639950,8735055832
			},
			Vic = {
				839818760,1524739259
			},
	},
	UnknownUsers = {
		7547477786, 7574577126, 5816563976, 240526951, 7587479685, 7876617827, 2568824396, 7604102307, 7901878324, 5087196317, 7187604802, 7495829767, 7718511355, 7928472983, 7922414080, 7758683476, 4079687909, 1160595313,	
	}
}
													
    local ACMOD
	local Side
	local Specific
	local IncludeOffline
	local IncludeStudio
    ACMOD = vape.Categories.Exploits:CreateModule({
		Name = 'Anti-Cheat Mods',
		Tooltip = "Fetches all ac mods users(including unknown's)",
        Function = function()
			vape:CreateNotification('Loading...', "Currently fetching mods", 3)
task.wait(4)
	    local HttpService = game:GetService("HttpService")
		
		local Offline, InGame, Online, Studio = 0, 0, 0, 0
		local url = "https://presence.roproxy.com/v1/presence/users"
		local headers = {
		    ["Content-Type"] = "application/json"
		}						
		local data = {userIds = {}}
		
		if Side.Value == "Known" then
		    if Specific.Value == "All" then
		        for _, numbers in pairs(Users.KnownUsers) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end
			elseif Specific.Value == "Chase" then
		        for _, numbers in pairs(Users.KnownUsers.Chase) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Orion" then
		        for _, numbers in pairs(Users.KnownUsers.Orion) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Lisnix" then
		        for _, numbers in pairs(Users.KnownUsers.LisNix) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Nwr" then
		        for _, numbers in pairs(Users.KnownUsers.Nwr) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Gorilla" then
		        for _, numbers in pairs(Users.KnownUsers.Gorilla) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Typhoon" then
		        for _, numbers in pairs(Users.KnownUsers.Typhoon) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Vic" then
		        for _, numbers in pairs(Users.KnownUsers.Vic) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Erin" then
		        for _, numbers in pairs(Users.KnownUsers.Erin) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Gora" then
		        for _, numbers in pairs(Users.KnownUsers.Gora) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Ghost" then
		        for _, numbers in pairs(Users.KnownUsers.Ghost) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Sponge" then
		        for _, numbers in pairs(Users.KnownUsers.Sponge) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Apple" then
		        for _, numbers in pairs(Users.KnownUsers.Apple) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Dom" then
		        for _, numbers in pairs(Users.KnownUsers.Dom) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
			elseif Specific.Value == "Kevin" then
		        for _, numbers in pairs(Users.KnownUsers.Kevin) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
		    end
		elseif Side.Value == "Unknown" then
		        for _, numbers in pairs(Users.UnknownUsers) do
		            for _, num in ipairs(numbers) do
		                table.insert(data.userIds, num)
		            end
		        end	
		end
		
		local jsonData = HttpService:JSONEncode(data)
		
		local response
		local success, err = pcall(function()
		    response = HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
		end)
		
		if success then
		    local result = HttpService:JSONDecode(response)
		
		    for _, user in pairs(result) do
		        if user.userPresenceType == "Offline" then
		            Offline = Offline + 1
					if IncludeOffline.Value == true										
						vape:CreateNotification('Offline Mod detected!', game:GetService("Players"):GetNameFromUserIdAsync(user.userId), 5,"alert")
					end
		        end
									
		        elseif user.userPresenceType == "InGame" then
		            InGame = InGame + 1
					vape:CreateNotification('InGame Mods detected!', game:GetService("Players"):GetNameFromUserIdAsync(user.userId), 15,"warning")
		        elseif user.userPresenceType == "Online" then
		            Online = Online + 1
					vape:CreateNotification('Online Mods detected!', game:GetService("Players"):GetNameFromUserIdAsync(user.userId), 15,"warning")
		        elseif user.userPresenceType == "Studio" then
		            Studio = Studio + 1
				if IncludeStudio.Value == true										
						vape:CreateNotification('Studio Mods detected!', game:GetService("Players"):GetNameFromUserIdAsync(user.userId), 5,"warning")
					end
		        end
		    end		
			task.wait(5)	
			if InGame >= 2 then
				vape:CreateNotification('Mutiple mods Ingame!', "They are over ["..Status.."], mods ingame", 45)
			end
			if Online >= 2 then
				vape:CreateNotification('Mutiple mods Online!', "They are over ["..Status.."], mods Online", 45)
			end
			if InGame == 0 then
			    vape:CreateNotification('No mods Ingame!', "There are ["..InGame.."] mods ingame", 45)
			end
			
			if Online == 0 then
			    vape:CreateNotification('No mods Online!', "There are ["..Online.."] mods online", 45)
			end
		else
			vape:CreateNotification('Failed!', "failed to get presence data: "..err, 15,"alert")
		end
    })
	Side = ACMOD:CreateDropdown({
		Name = "Verison",
		List = {'Known','Unknown'}
	})
	Specific = ACMOD:CreateDropdown({
		Name = "Specific",
		Tooltip = 'This will fetech a specific user (mains, and their alts)',
		List = {'Chase','Orion','Lisnix', 'Nwr', 'Gorilla', 'Typhon', 'Vic', 'Erin', 'Ghost', 'Sponge', 'Apple', 'Dom','Gora', 'Kevin','All'}
	})
	IncludeStudio:CreateToggle({
	Name = "Include Studio",
	Tooltip = "Include when a mod is in studio",
	Default = false
})
	IncludeOffline:CreateToggle({
	Name = "Include Offline",
	Tooltip = "Include when a mod is offline",
	Default = false
})

end)		

run(function()
	local Header = "Small Update!"
	local Verison = "0.1.2"
	local notes = "A small update, upped KA attack range. I have also made three more functions in exploits 'Anti-Cheat Mods, Patch Notes, and Switch Gui'. Anti-Cheat mods detect all known and unknown mods, patch notes is this. And lastly switch gui this will switch ur type of gui, you are using '"..vape:GUIType().."'!"
	local time = 30
	local patchnotes = vape.Categories.Exploits:CreateModule({
		Name = "Patch Notes",
		Tooltip = "This shows off the updates logs",
		Function = function()
			vape:CreateNotification(Header.."|"..Verison,notes,time)
		end		
	})
end)
