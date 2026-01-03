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
local TeleportService = cloneref(game:GetService("TeleportService"))
local lightingService = cloneref(game:GetService("Lighting"))
local isnetworkowner = identifyexecutor and table.find({'Nihon','Volt'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
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
local role = vape.role
local user = vape.user
task.spawn(function()
	while task.wait(0.01) do
		vape.role = NR
		vape.user = NU
	end
end)

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
local InfiniteFly
local TrapDisabler
local AntiFallPart
local Speed
local Fly
local Breaker
local Scaffold
local AutoTool
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

local pos = {}
vape:Clean(function()
	workspace.ItemDrops.ChildAdded:Connect(function(obj)
		if obj then
			table.insert(pos,obj.Position)
		end
	end)
	workspace.ItemDrop.ChildRemoved:Connect(function(obj)
		table.remove(pos,obj.Position)
	end)
end)

local function GetNearGen(legit, origin)

	local MaxStuds = legit and 10 or 23
	local closest, dist
	for _, pos in ipairs(pos) do
		if pos ~= currentbedpos then
			local d = (pos - origin).Magnitude
			if d <= MaxStuds then
				if not dist or d < dist then
					dist = d
					closest = pos
				end
			end
		end
	end

	return closest
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

local function getSwordSlot()
	for i, v in store.inventory.hotbar do
		if v.item and bedwars.ItemMeta[v.item.itemType] then
			local meta = bedwars.ItemMeta[v.item.itemType]
			if meta.sword then
				return i - 1
			end
		end
	end
	return nil
end

local function getPickaxeSlot()
	local Obj = {}
	for i, v in store.inventory.hotbar do
		if v.item and v.item.itemType then
			local nme = string.find(v.item.itemType,'pickaxe')
			if v.item.itemType == nme then
				table.insert(Obj, i - 1)
			end
		end
	end
	return Obj
end

local function getObjSlot(nme)
	local Obj = {}
	for i, v in store.inventory.hotbar do
		if v.item and v.item.itemType then
			if v.item.itemType == nme then
				table.insert(Obj, i - 1)
			end
		end
	end
	return Obj
end

local function GetOriginalSlot()
	return store.inventory.hotbarSlot 
end

local function switchItemV2(tool, delayTime)
	delayTime = delayTime or 0.05
	delayTime = (delayTime == 0 and 0.05 or delayTime)
	if tool ~= nil and typeof(tool) == "string" then
		tool = getItem(tool) and getItem(tool).tool
	end
	task.delay(delayTime,function()
		bedwars.Client:Get('SetInvItem'):CallServer({hand = tool})
	end)
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

local function lobby()
	game.ReplicatedStorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged.TeleportToLobby:FireServer()
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
		return (a.Entity.Player and kitorder[a.Entity.Player:GetAttribute('PlayingAsKits')] or 0) > (b.Entity.Player and kitorder[b.Entity.Player:GetAttribute('PlayingAsKits')] or 0)
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
			table.insert(tab, ent.Player:GetAttributeChangedSignal('PlayingAsKits'))
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
local function safeGetProto(func, index)
    if not func then return nil end
    local success, proto = pcall(safeGetProto, func, index)
    if success then
        return proto
    else
        warn("function:", func, "index:", index,", WM - proto") 
        return nil
    end
end



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
		GamePlayer = require(replicatedStorage.TS.player['game-player']),
		OfflinePlayerUtil = require(replicatedStorage.TS.player['offline-player-util']),
		PlayerUtil = require(replicatedStorage.TS.player['player-util']),
		KKKnitController = require(lplr.PlayerScripts.TS.lib.knit['knit-controller']),
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
		SharedConstants = require(replicatedStorage.TS['shared-constants']),
		DamageIndicator = Knit.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.global.locker['kill-effect'].effects['default-kill-effect']),
		EmoteType = require(replicatedStorage.TS.locker.emote['emote-type']).EmoteType,
		GameAnimationUtil = require(replicatedStorage.TS.animation['animation-util']).GameAnimationUtil,
		NotificationController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/notification-controller@NotificationController'),
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
		MatchHistoryController = require(lplr.PlayerScripts.TS.controllers.global['match-history']['match-history-controller']),
		PlayerProfileUIController = require(lplr.PlayerScripts.TS.controllers.global['player-profile']['player-profile-ui-controller']),
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
		SoundManager = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.shared.sound['sound-manager']).SoundManager,
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
		AfkStatus = safeGetProto(Knit.Controllers.AfkController.KnitStart, 1),
		AttackEntity = Knit.Controllers.SwordController.sendServerRequest,
		BeePickup = Knit.Controllers.BeeNetController.trigger,
		CannonAim = safeGetProto(Knit.Controllers.CannonController.startAiming, 5),
		CannonLaunch = Knit.Controllers.CannonHandController.launchSelf,
		ConsumeBattery = safeGetProto(Knit.Controllers.BatteryController.onKitLocalActivated, 1),
		ConsumeItem = safeGetProto(Knit.Controllers.ConsumeController.onEnable, 1),
		ConsumeSoul = Knit.Controllers.GrimReaperController.consumeSoul,
		ConsumeTreeOrb = safeGetProto(Knit.Controllers.EldertreeController.createTreeOrbInteraction, 1),
		DepositPinata = safeGetProto(Knit.Controllers.PiggyBankController.KnitStart, 5),
		DragonBreath = safeGetProto(Knit.Controllers.VoidDragonController.onKitLocalActivated, 5),
		DragonEndFly = safeGetProto(Knit.Controllers.VoidDragonController.flapWings, 1),
		DragonFly = Knit.Controllers.VoidDragonController.flapWings,
		DropItem = Knit.Controllers.ItemDropController.dropItemInHand,
		FireProjectile = debug.getupvalue(Knit.Controllers.ProjectileController.launchProjectileWithValues, 2),
		GroundHit = Knit.Controllers.FallDamageController.KnitStart,
		GuitarHeal = Knit.Controllers.GuitarController.performHeal,
		HannahKill = safeGetProto(Knit.Controllers.HannahController.registerExecuteInteractions, 1),
		HarvestCrop = safeGetProto(safeGetProto(Knit.Controllers.CropController.KnitStart, 4), 1),
		KaliyahPunch = safeGetProto(Knit.Controllers.DragonSlayerController.onKitLocalActivated, 1),
		MageSelect = safeGetProto(Knit.Controllers.MageController.registerTomeInteraction, 1),
		MinerDig = safeGetProto(Knit.Controllers.MinerController.setupMinerPrompts, 1),
		PickupItem = Knit.Controllers.ItemDropController.checkForPickup,
		PickupMetal = safeGetProto(Knit.Controllers.HiddenMetalController.onKitLocalActivated, 4),
		ReportPlayer = require(lplr.PlayerScripts.TS.controllers.global.report['report-controller']).default.reportPlayer,
		ResetCharacter = safeGetProto(Knit.Controllers.ResetController.createBindable, 1),
		SpawnRaven = safeGetProto(Knit.Controllers.RavenController.KnitStart, 1),
		SummonerClawAttack = Knit.Controllers.SummonerClawHandController.attack,
		WarlockTarget = safeGetProto(Knit.Controllers.WarlockStaffController.KnitStart, 2),
		EquipItem = safeGetProto(require(replicatedStorage.TS.entity.entities['inventory-entity']).InventoryEntity.equipItem, 3),

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
			notif('Onyx', 'Failed to grab remote ('..i..')', 10, 'alert')
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

	bedwars.breakBlock = function(block, effects, anim, customHealthbar,at)
		if lplr:GetAttribute('DenyBlockBreak') or not entitylib.isAlive or InfiniteFly.Enabled then return end
		
		task.spawn(function()
				if at then
					local event
				
					local function switchHotbarItem(block)
						if block and not block:GetAttribute('NoBreak') and not block:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') then
							local tool, slot = store.tools[bedwars.ItemMeta[block.Name].block.breakType], nil
							if tool then
								for i, v in store.inventory.hotbar do
									if v.item and v.item.itemType == tool.itemType then slot = i - 1 break end
								end
					
								if hotbarSwitch(slot) then
									if inputService:IsMouseButtonPressed(0) then 
										event:Fire() 
									end
									return true
								end
							end
						end
					end

					event = Instance.new('BindableEvent')
					event.Event:Connect(function()
						contextActionService:CallFunction('block-break', Enum.UserInputState.Begin, newproxy(true))
					end)

					if switchHotbarItem(block) then return end
				else
					
				end
		end)

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

if not bedwars.Client then
end
local KaidaController = {}
function KaidaController:request(target)
	if target then 
		return bedwars.Client:Get("SummonerClawAttackRequest"):SendToServer({
			["position"] = target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart").Position,
			["direction"] = (target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart").Position - lplr.Character.HumanoidRootPart.Position).unit, 
			["clientTime"] = workspace:GetServerTimeNow(), 
		})
	else return nil end
end

function KaidaController:requestBetter(v1,v2)
	if target then 
		return bedwars.Client:Get("SummonerClawAttackRequest"):SendToServer({
			["position"] = v1,
			["direction"] = v2, 
			["clientTime"] = workspace:GetServerTimeNow(), 
		})
	else return nil end
end

local WhisperController = {}
function WhisperController:request(type)
	if type == "Heal" then
		if bedwars.AbilityController:canUseAbility('OWL_HEAL') then
			bedwars.AbilityController:useAbility('OWL_HEAL')
		end
	elseif type == "Fly" then
		if bedwars.AbilityController:canUseAbility('OWL_LIFT') then
			bedwars.AbilityController:useAbility('OWL_LIFT')
		end
	end
end
local NazarController = {}
function NazarController:request(type)
	if type == "enabled" then
		if bedwars.AbilityController:canUseAbility('enable_life_force_attack') then
			bedwars.AbilityController:useAbility('enable_life_force_attack')
		end
	elseif type == "disabled" then
		if bedwars.AbilityController:canUseAbility('enable_life_force_attack') then
			bedwars.AbilityController:useAbility('disable_life_force_attack')
		end
	elseif type == "heal" then
		if bedwars.AbilityController:canUseAbility('consume_life_force') then
			bedwars.AbilityController:useAbility('consume_life_force')
		end
	end
end
local notificationConstant = require(replicatedStorage.rbxts_include.node_modules['@easy-games']['game-core'].out['shared'].notification['notification-const'])
local oldtime = notificationConstant.NOTIFICATION_TIME 
local function BedwarsInfoNotification(msg,lifetime)
	lifetime = lifetime or 12
	notificationConstant.NOTIFICATION_TIME = lifetime
	bedwars.NotificationController:sendInfoNotification({
		message = msg
	})
	task.wait(lifetime + 0.5)
	notificationConstant.NOTIFICATION_TIME = old
end

local function BedwarsErrorNotification(msg,lifetime)
	lifetime = lifetime or 12
	notificationConstant.NOTIFICATION_TIME = lifetime
	bedwars.NotificationController:sendErrorNotification({
		message = msg
	})
	task.wait(lifetime + 0.5)
	notificationConstant.NOTIFICATION_TIME = old
end

local reportedPlayers = {}
local function TryToReport(targettedplayer,value)
    reportedPlayers[targettedplayer] = true
	if value == "VapeNotify" then
	    if reportedPlayers[targettedplayer] then
	       	vape:CreateNotification('AutoReport', "You have already reported this player!", 1, "alert")
	        return
		else
	bedwars.Client:Get("ReportPlayer"):SendToServer(targettedplayer)
		vape:CreateNotification('AutoReport', "Reported '" .. targettedplayer.Name .. "'", 1)
		task.wait(1 + math.random())
	    end


	elseif value == "BedwarsNotify" then
	    if reportedPlayers[targettedplayer] then
	        BedwarsErrorNotification("You have already reported this player!")
	        return
		else
			bedwars.Client:Get("ReportPlayer"):SendToServer(targettedplayer)
			BedwarsInfoNotification("Reported " .. targettedplayer.Name)
			task.wait(1 + math.random())
	    end

	elseif value == "Hidden" then
		bedwars.Client:Get("ReportPlayer"):SendToServer(targettedplayer)
		task.wait(1 + math.random())
	else
		bedwars.Client:Get("ReportPlayer"):SendToServer(targettedplayer)
		task.wait(1 + math.random())
	end
end

getgenv().BIN = BedwarsInfoNotification
getgenv().BEN = BedwarsErrorNotification

for _, v in {'AntiRagdoll', 'TriggerBot', 'AutoRejoin', 'Rejoin', 'Disabler', 'Timer', 'ServerHop', 'MouseTP', 'MurderMystery','SilentAim','GetUnc','GetExecutor'} do
	vape:Remove(v)
end

run(function()
	local AimAssist
	local MaxTargets
	local Targets
	local Shake
	local ShakeV
	local Sort
	local AimSpeed
	local Distance
	local AngleSlider
	local StrafeIncrease
	local KillauraTarget
	local ClickAim
	
	local shakeTime = 0

	AimAssist = vape.Categories.Combat:CreateModule({
		Name = 'AimAssist',
		Function = function(callback)
			if callback then
				AimAssist:Clean(runService.Heartbeat:Connect(function(dt)
					shakeTime += dt
					if entitylib.isAlive and ((not ClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
						local ent = not KillauraTarget.Enabled and entitylib.EntityPosition({
							Range = Distance.Value,
							Part = 'RootPart',
							Wallcheck = Targets.Walls.Enabled,
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = MaxTargets.Value,
							Sort = sortmethods[Sort.Value]
						}) or store.KillauraTarget

						if ent then
							local root = entitylib.character.RootPart
							local delta = ent.RootPart.Position - root.Position
							local localfacing = root.CFrame.LookVector * Vector3.new(1, 0, 1)
							local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
							if angle >= (math.rad(AngleSlider.Value) / 2) then return end

							targetinfo.Targets[ent] = tick() + 1

							local shakeOffset = Vector3.zero
							if Shake.Enabled then
								local freq = (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 16 or 10
								local x = math.sin(shakeTime * freq) * ShakeV.Value
								shakeOffset = gameCamera.CFrame.RightVector * x * 0.05
							end

							local speed = (AimSpeed.Value + (StrafeIncrease.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 10 or 0)) * dt

							gameCamera.CFrame = gameCamera.CFrame:Lerp(CFrame.lookAt(gameCamera.CFrame.Position, ent.RootPart.Position + shakeOffset), speed)
						end
					end
				end))
			end
		end,
		Tooltip = 'Smoothly aims to closest valid target'
	})

	MaxTargets = AimAssist:CreateSlider({
		Name = "Max Targets",
		Min = 1,
		Max = 8,
		Default = 5,
	})

	Targets = AimAssist:CreateTargets({
		Players = true,
		Walls = true
	})

	local methods = {'Damage', 'Distance'}
	for i in sortmethods do
		if not table.find(methods, i) then
			table.insert(methods, i)
		end
	end

	Sort = AimAssist:CreateDropdown({
		Name = 'Target Mode',
		List = methods
	})

	AimSpeed = AimAssist:CreateSlider({
		Name = 'Aim Speed',
		Min = 1,
		Max = 20,
		Default = getgenv().Closet and 4 or 6
	})

	Distance = AimAssist:CreateSlider({
		Name = 'Distance',
		Min = 1,
		Max = 30,
		Default = 30,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})

	AngleSlider = AimAssist:CreateSlider({
		Name = 'Max angle',
		Min = 1,
		Max = 360,
		Default = 70
	})

	ClickAim = AimAssist:CreateToggle({
		Name = 'Click Aim',
		Default = true
	})

	Shake = AimAssist:CreateToggle({
		Name = 'Shake',
		Default = false,
		Function = function(callback)
			ShakeV.Object.Visible = callback
		end
	})

	ShakeV = AimAssist:CreateSlider({
		Name = "Shake Power",
		Min = 0,
		Max = 1,
		Default = .5,
		Visible = false,
		Decimal = 100,
	})

	KillauraTarget = AimAssist:CreateToggle({
		Name = 'Use killaura target',
	})

	StrafeIncrease = AimAssist:CreateToggle({Name = 'Strafe increase'})
end)



	
run(function()
	local old
	
	AutoCharge = vape.Categories.Combat:CreateModule({
	    Name = 'AutoCharge',
	    Function = function(callback)
	        debug.setconstant(bedwars.SwordController.attackEntity, 58, callback and 'damage' or 'multiHitCheckDurationSec')
	        if callback then
	            local chargeSwingTime = 0
	            local canSwing
	
	            old = bedwars.SwordController.sendServerRequest
	            bedwars.SwordController.sendServerRequest = function(self, ...)
	                if (os.clock() - chargeSwingTime) < AutoChargeTime.Value then return end
	                self.lastSwingServerTimeDelta = 0.5
	                chargeSwingTime = os.clock()
	                canSwing = true
	
	                local item = self:getHandItem()
	                if item and item.tool then
	                    self:playSwordEffect(bedwars.ItemMeta[item.tool.Name], false)
	                end
	
	                return old(self, ...)
	            end
	
	            oldSwing = bedwars.SwordController.playSwordEffect
	            bedwars.SwordController.playSwordEffect = function(...)
	                if not canSwing then return end
	                canSwing = false
	                return oldSwing(...)
	            end
	        else
	            if old then
	                bedwars.SwordController.sendServerRequest = old
	                old = nil
	            end
	
	            if oldSwing then
	                bedwars.SwordController.playSwordEffect = oldSwing
	                oldSwing = nil
	            end
	        end
	    end,
	    Tooltip = 'Allows you to get charged hits while spam clicking.'
	})
	AutoChargeTime = AutoCharge:CreateSlider({
	    Name = 'Charge Time',
	    Min = 0,
	    Max = 0.5,
	    Default = 0.4,
	    Decimal = 100
	})
				
end)
	
run(function()
	local AutoClicker
	local CPS
	local BlockCPS = {}
	local Thread
	
	local function AutoClick()
		if Thread then
			task.cancel(Thread)
		end
	
		Thread = task.delay(1 / 7, function()
			repeat
				if not bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then
					local blockPlacer = bedwars.BlockPlacementController.blockPlacer
					if store.hand.toolType == 'block' and blockPlacer then
						if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) >= ((1 / 12) * 0.5) then
							local mouseinfo = blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
							if mouseinfo and mouseinfo.placementPosition == mouseinfo.placementPosition then
								task.spawn(blockPlacer.placeBlock, blockPlacer, mouseinfo.placementPosition)
							end
						end
					elseif store.hand.toolType == 'sword' then
						bedwars.SwordController:swingSwordAtMouse(0.39)
					end
				end
	
				task.wait(1 / (store.hand.toolType == 'block' and BlockCPS or CPS).GetRandomValue())
			until not AutoClicker.Enabled
		end)
	end
	
	AutoClicker = vape.Categories.Combat:CreateModule({
		Name = 'AutoClicker',
		Function = function(callback)
			if callback then
				AutoClicker:Clean(inputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						AutoClick()
					end
				end))
	
				AutoClicker:Clean(inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and Thread then
						task.cancel(Thread)
						Thread = nil
					end
				end))
	
				if inputService.TouchEnabled then
					pcall(function()
						AutoClicker:Clean(lplr.PlayerGui.MobileUI['2'].MouseButton1Down:Connect(AutoClick))
						AutoClicker:Clean(lplr.PlayerGui.MobileUI['2'].MouseButton1Up:Connect(function()
							if Thread then
								task.cancel(Thread)
								Thread = nil
							end
						end))
					end)
				end
			else
				if Thread then
					task.cancel(Thread)
					Thread = nil
				end
			end
		end,
		Tooltip = 'Hold attack button to automatically click'
	})
	CPS = AutoClicker:CreateTwoSlider({
		Name = 'CPS',
		Min = 1,
		Max = 9,
		DefaultMin = 7,
		DefaultMax = 7
	})
	AutoClicker:CreateToggle({
		Name = 'Place Blocks',
		Default = true,
		Function = function(callback)
			if BlockCPS.Object then
				BlockCPS.Object.Visible = callback
			end
		end
	})
	BlockCPS = AutoClicker:CreateTwoSlider({
		Name = 'Block CPS',
		Min = 1,
		Max = 12,
		DefaultMin = 12,
		DefaultMax = 12,
		Darker = true
	})
end)
	
run(function()
	local old
	local Delay
	local NoClickDelay
	NoClickDelay = vape.Categories.Combat:CreateModule({
		Name = 'NoClickDelay',
		Function = function(callback)
			if callback then
				old = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self)
				if Delay.Value == 0 then
					Delay.Value = os.clock()
				else
					Delay.Value = Delay.Value
				end
				
					self.lastSwing = Delay.Value
					return false
				end
			else
				bedwars.SwordController.isClickingTooFast = old
			end
		end,
		Tooltip = 'Remove the CPS cap'
	})
	Delay  = NoClickDelay:CreateSlider({
		Name = "Delay",
		Min = 0,
		Max = 1,
		Decimal = 100,
	})
end)
	
run(function()
	local Attack
	local Mine
	local Place
	local oldAttackReach, oldMineReach, oldPlaceReach

	Reach = vape.Categories.Combat:CreateModule({
		Name = 'Reach',
		Function = function(callback)
			if callback then
				oldAttackReach = bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE
				
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = Attack.Value + 2
				
				task.spawn(function()
					repeat task.wait(0.1) until bedwars.BlockBreakController or not Reach.Enabled
					if not Reach.Enabled then return end
					
					pcall(function()
						local blockBreaker = bedwars.BlockBreakController:getBlockBreaker()
						if blockBreaker then
							oldMineReach = oldMineReach or blockBreaker:getRange()
							blockBreaker:setRange(Mine.Value)
						end
					end)
				end)
				
				task.spawn(function()
					while Reach.Enabled do
						if bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE ~= Attack.Value + 2 then
							bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = Attack.Value + 2
						end
						
						pcall(function()
							local blockBreaker = bedwars.BlockBreakController:getBlockBreaker()
							if blockBreaker and blockBreaker:getRange() ~= Mine.Value then
								blockBreaker:setRange(Mine.Value)
							end
						end)
						
						task.wait(0.5)
					end
				end)
			else
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = oldAttackReach or 14.4
				
				pcall(function()
					local blockBreaker = bedwars.BlockBreakController:getBlockBreaker()
					if blockBreaker then
						blockBreaker:setRange(oldMineReach or 18)
					end
				end)
				
				oldAttackReach, oldMineReach = nil, nil
			end
		end,
		Tooltip = 'Extends reach for attacking and mining'
	})
	
	Attack = Reach:CreateSlider({
		Name = 'Attack Range',
		Min = 0,
		Max = 30,
		Default = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	
	Place = Reach:CreateSlider({
		Name = 'Place Range',
		Min = 0,
		Max = 30,
		Default = 18,
		Function = function(val)
			if Reach.Enabled then
				pcall(function()
					local blockBreaker = bedwars.BlockBreakController:getBlockBreaker()
					if blockBreaker then
						blockBreaker:setRange(val)
					end
				end)
			end
		end,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})

	Mine = Reach:CreateSlider({
		Name = 'Mine Range',
		Min = 0,
		Max = 30,
		Default = 18,
		Function = function(val)
			if Reach.Enabled then
				pcall(function()
					local blockBreaker = bedwars.BlockBreakController:getBlockBreaker()
					if blockBreaker then
						blockBreaker:setRange(val)
					end
				end)
			end
		end,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)
	
run(function()
	local Sprint
	local old
	
	Sprint = vape.Categories.Combat:CreateModule({
		Name = 'Sprint',
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then 
					pcall(function() 
						lplr.PlayerGui.MobileUI['4'].Visible = false 
					end) 
				end
				old = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local call = old(...)
					bedwars.SprintController:startSprinting()
					return call
				end
				Sprint:Clean(entitylib.Events.LocalAdded:Connect(function() 
					task.delay(0.1, function() 
						bedwars.SprintController:stopSprinting() 
					end) 
				end))
				bedwars.SprintController:stopSprinting()
			else
				if inputService.TouchEnabled then 
					pcall(function() 
						lplr.PlayerGui.MobileUI['4'].Visible = true 
					end) 
				end
				bedwars.SprintController.stopSprinting = old
				bedwars.SprintController:stopSprinting()
			end
		end,
		Tooltip = 'Sets your sprinting to true.'
	})
end)
	
run(function()
	local TriggerBot
	local CPS
	local rayParams = RaycastParams.new()
	
	TriggerBot = vape.Categories.Combat:CreateModule({
		Name = 'TriggerBot',
		Function = function(callback)
			if callback then
				repeat
					local doAttack
					if not bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then
						if entitylib.isAlive and store.hand.toolType == 'sword' and bedwars.DaoController.chargingMaid == nil then
							local attackRange = bedwars.ItemMeta[store.hand.tool.Name].sword.attackRange
							rayParams.FilterDescendantsInstances = {lplr.Character}
	
							local unit = lplr:GetMouse().UnitRay
							local localPos = entitylib.character.RootPart.Position
							local rayRange = (attackRange or 14.4)
							local ray = bedwars.QueryUtil:raycast(unit.Origin, unit.Direction * 200, rayParams)
							if ray and (localPos - ray.Instance.Position).Magnitude <= rayRange then
								local limit = (attackRange)
								for _, ent in entitylib.List do
									doAttack = ent.Targetable and ray.Instance:IsDescendantOf(ent.Character) and (localPos - ent.RootPart.Position).Magnitude <= rayRange
									if doAttack then
										break
									end
								end
							end
	
							doAttack = doAttack or bedwars.SwordController:getTargetInRegion(attackRange or 3.8 * 3, 0)
							if doAttack then
								bedwars.SwordController:swingSwordAtMouse()
							end
						end
					end
	
					task.wait(doAttack and 1 / CPS.GetRandomValue() or 0.016)
				until not TriggerBot.Enabled
			end
		end,
		Tooltip = 'Automatically swings when hovering over a entity'
	})
	CPS = TriggerBot:CreateTwoSlider({
		Name = 'CPS',
		Min = 1,
		Max = 9,
		DefaultMin = 7,
		DefaultMax = 7
	})
end)
	
run(function()
	local Velocity
	local Horizontal
	local Vertical
	local Chance
	local TargetCheck
	local rand, old = math.random(0,100)
	
	Velocity = vape.Categories.Combat:CreateModule({
		Name = 'Velocity',
		Function = function(callback)
			if callback then
				old = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					if rand > Chance.Value then 
						rand = math.random(0,100)
						return 
					end
					local check = (not TargetCheck.Enabled) or entitylib.EntityPosition({
						Range = 50,
						Part = 'RootPart',
						Players = true
					})
	
					if check then
						knockback = knockback or {}
						if Horizontal.Value == 0 and Vertical.Value == 0 then return end
						knockback.horizontal = (knockback.horizontal or 1) * (Horizontal.Value / 100)
						knockback.vertical = (knockback.vertical or 1) * (Vertical.Value / 100)
					end
					
					return old(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = old
			end
		end,
		Tooltip = 'Reduces knockback taken'
	})
	Horizontal = Velocity:CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 100,
		Default = 0,
		Suffix = '%'
	})
	Vertical = Velocity:CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 100,
		Default = 0,
		Suffix = '%'
	})
	Chance = Velocity:CreateSlider({
		Name = 'Chance',
		Min = 0,
		Max = 100,
		Default = 100,
		Suffix = '%'
	})
	TargetCheck = Velocity:CreateToggle({Name = 'Only when targeting'})
end)
	
	
local AntiFallDirection
run(function()
	local AntiFall
	local Mode
	local Material
	local Color
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true

	local function getLowGround()
		local mag = math.huge
		for _, pos in bedwars.BlockController:getStore():getAllBlockPositions() do
			pos = pos * 3
			if pos.Y < mag and not getPlacedBlock(pos + Vector3.new(0, 3, 0)) then
				mag = pos.Y
			end
		end
		return mag
	end

	AntiFall = vape.Categories.Blatant:CreateModule({
		Name = 'AntiFall',
		Function = function(callback)
			if callback then
				repeat task.wait(0.1) until store.matchState ~= 0 or (not AntiFall.Enabled)
				if not AntiFall.Enabled then return end

				local pos, debounce = getLowGround(), tick()
				if pos ~= math.huge then
					AntiFallPart = Instance.new('Part')
					AntiFallPart.Size = Vector3.new(10000, 1, 10000)
					AntiFallPart.Transparency = 1 - Color.Opacity
					AntiFallPart.Material = Enum.Material[Material.Value]
					AntiFallPart.Color = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
					AntiFallPart.Position = Vector3.new(0, pos - 2, 0)
					AntiFallPart.CanCollide = Mode.Value == 'Collide'
					AntiFallPart.Anchored = true
					AntiFallPart.CanQuery = false
					AntiFallPart.Parent = workspace
					AntiFall:Clean(AntiFallPart)
					AntiFall:Clean(AntiFallPart.Touched:Connect(function(touched)
						if touched.Parent == lplr.Character and entitylib.isAlive and debounce < tick() then
							debounce = tick() + 0.1
							if Mode.Value == 'Normal' then
								local top = getNearGround()
								if top then
									local lastTeleport = lplr:GetAttribute('LastTeleported')
									local connection
									connection = runService.PreSimulation:Connect(function()
										if vape.Modules.Fly.Enabled or vape.Modules.InfiniteFly.Enabled or vape.Modules.LongJump.Enabled then
											connection:Disconnect()
											AntiFallDirection = nil
											return
										end

										if entitylib.isAlive and lplr:GetAttribute('LastTeleported') == lastTeleport then
											local delta = ((top - entitylib.character.RootPart.Position) * Vector3.new(1, 0, 1))
											local root = entitylib.character.RootPart
											AntiFallDirection = delta.Unit == delta.Unit and delta.Unit or Vector3.zero
											root.Velocity *= Vector3.new(1, 0, 1)
											rayCheck.FilterDescendantsInstances = {gameCamera, lplr.Character}
											rayCheck.CollisionGroup = root.CollisionGroup

											local ray = workspace:Raycast(root.Position, AntiFallDirection, rayCheck)
											if ray then
												for _ = 1, 10 do
													local dpos = roundPos(ray.Position + ray.Normal * 1.5) + Vector3.new(0, 3, 0)
													if not getPlacedBlock(dpos) then
														top = Vector3.new(top.X, pos.Y, top.Z)
														break
													end
												end
											end

											root.CFrame += Vector3.new(0, top.Y - root.Position.Y, 0)
											if not frictionTable.Speed then
												root.AssemblyLinearVelocity = (AntiFallDirection * getSpeed()) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
											end

											if delta.Magnitude < 1 then
												connection:Disconnect()
												AntiFallDirection = nil
											end
										else
											connection:Disconnect()
											AntiFallDirection = nil
										end
									end)
									AntiFall:Clean(connection)
								end
							elseif Mode.Value == 'Velocity' then
								entitylib.character.RootPart.Velocity = Vector3.new(entitylib.character.RootPart.Velocity.X, 100, entitylib.character.RootPart.Velocity.Z)
							end
						end
					end))
				end
			else
				AntiFallDirection = nil
			end
		end,
		Tooltip = 'Help\'s you with your Parkinson\'s\nPrevents you from falling into the void.'
	})
	Mode = AntiFall:CreateDropdown({
		Name = 'Move Mode',
		List = {'Normal', 'Collide', 'Velocity'},
		Function = function(val)
			if AntiFallPart then
				AntiFallPart.CanCollide = val == 'Collide'
			end
		end,
	Tooltip = 'Normal - Smoothly moves you towards the nearest safe point\nVelocity - Launches you upward after touching\nCollide - Allows you to walk on the part'
	})
	local materials = {'ForceField'}
	for _, v in Enum.Material:GetEnumItems() do
		if v.Name ~= 'ForceField' then
			table.insert(materials, v.Name)
		end
	end
	Material = AntiFall:CreateDropdown({
		Name = 'Material',
		List = materials,
		Function = function(val)
			if AntiFallPart then
				AntiFallPart.Material = Enum.Material[val]
			end
		end
	})
	Color = AntiFall:CreateColorSlider({
		Name = 'Color',
		DefaultOpacity = 0.5,
		Function = function(h, s, v, o)
			if AntiFallPart then
				AntiFallPart.Color = Color3.fromHSV(h, s, v)
				AntiFallPart.Transparency = 1 - o
			end
		end
	})
end)
local FastBreak
run(function()
	local Time
	local Blacklist
	local blocks
	local old, event
	
	local function IgnoreFastBreak(block)
		if not block then return false end
		if block:GetAttribute("NoBreak") then return true end
		if block:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") then return true end
		local name = block.Name:lower()
		for _, v in pairs(blocks.ListEnabled) do
			if name:find(v:lower(), 1, true) or (value == "bed" and workspace:FindFirstChild(name)) then
				return true
			end
		end
		return false
	end
	FastBreak = vape.Categories.Blatant:CreateModule({
		Name = 'FastBreak',
		Function = function(callback)
			if callback then
				if Blacklist.Enabled then
					event = Instance.new('BindableEvent')
					FastBreak:Clean(event)
					FastBreak:Clean(event.Event:Connect(function()
						contextActionService:CallFunction('block-break', Enum.UserInputState.Begin, newproxy(true))
					end))

					old = bedwars.BlockBreaker.hitBlock																			
						repeat
							bedwars.BlockBreaker.hitBlock = function(self, maid, raycastparams, ...)
								local block = self.clientManager:getBlockSelector():getMouseInfo(1, {ray = raycastparams})
								local NewBlock = block and block.target and block.target.blockInstance or ni																				
								if IgnoreFastBreak(NewBlock) then 
									bedwars.BlockBreakController.blockBreaker:setCooldown(0.3)
								else
									bedwars.BlockBreakController.blockBreaker:setCooldown(Time.Value)
								end
								return old(self, maid, raycastparams, ...)
							end
							task.wait(0.1)
						until not FastBreak.Enabled
				else
					repeat
						bedwars.BlockBreakController.blockBreaker:setCooldown(Time.Value)
						task.wait(0.1)
					until not FastBreak.Enabled
				end
			else
				if Blacklist.Enabled then
					bedwars.BlockBreaker.hitBlock = old
					bedwars.BlockBreakController.blockBreaker:setCooldown(0.3)
				else
					bedwars.BlockBreakController.blockBreaker:setCooldown(0.3)
				end
			end
		end,
		Tooltip = 'Decreases block hit cooldown'
	})
	blocks = FastBreak:CreateTextList({
		Name = "Blacklisted Blocks",
		Placeholder = "bed",
		Visible = false
	})
																				
	Time = FastBreak:CreateSlider({
		Name = 'Break speed',
		Min = 0,
		Max = 0.25,
		Default = 0.25,
		Decimal = 100,
		Suffix = 'seconds'
	})
	Blacklist = FastBreak:CreateToggle({
		Name = "Blacklist Blocks",
		Default = false,
		Tooltip = "when ur mining the selected block it uses normal break speed",
		Function = function(v)
			blocks.Object.Visible = v
		end
	})
end)
local LongJump

	
run(function()
	local Mode
	local Expand
	local objects, set = {}
	
	local function createHitbox(ent)
		if ent.Targetable and ent.Player then
			local hitbox = Instance.new('Part')
			hitbox.Size = Vector3.new(3, 6, 3) + Vector3.one * (Expand.Value / 5)
			hitbox.Position = ent.RootPart.Position
			hitbox.CanCollide = false
			hitbox.Massless = true
			hitbox.Transparency = 1
			hitbox.Parent = ent.Character
			local weld = Instance.new('Motor6D')
			weld.Part0 = hitbox
			weld.Part1 = ent.RootPart
			weld.Parent = hitbox
			objects[ent] = hitbox
		end
	end
	
	HitBoxes = vape.Categories.Blatant:CreateModule({
		Name = 'HitBoxes',
		Function = function(callback)
			if callback then
				if Mode.Value == 'Sword' then
					debug.setconstant(bedwars.SwordController.swingSwordInRegion, 6, (Expand.Value / 3))
					set = true
				else
					HitBoxes:Clean(entitylib.Events.EntityAdded:Connect(createHitbox))
					HitBoxes:Clean(entitylib.Events.EntityRemoving:Connect(function(ent)
						if objects[ent] then
							objects[ent]:Destroy()
							objects[ent] = nil
						end
					end))
					for _, ent in entitylib.List do
						createHitbox(ent)
					end
				end
			else
				if set then
					debug.setconstant(bedwars.SwordController.swingSwordInRegion, 6, 3.8)
					set = nil
				end
				for _, part in objects do
					part:Destroy()
				end
				table.clear(objects)
			end
		end,
		Tooltip = 'Expands attack hitbox'
	})
	Mode = HitBoxes:CreateDropdown({
		Name = 'Mode',
		List = {'Sword', 'Player'},
		Function = function()
			if HitBoxes.Enabled then
				HitBoxes:Toggle(false)
				HitBoxes:Toggle(true)
			end
		end,
		Tooltip = 'Sword - Increases the range around you to hit entities\nPlayer - Increases the players hitbox'
	})
	Expand = HitBoxes:CreateSlider({
		Name = 'Expand amount',
		Min = 0,
		Max = 14.4,
		Default = 14.4,
		Decimal = 10,
		Function = function(val)
			if HitBoxes.Enabled then
				if Mode.Value == 'Sword' then
					debug.setconstant(bedwars.SwordController.swingSwordInRegion, 6, (val / 3))
				else
					for _, part in objects do
						part.Size = Vector3.new(3, 6, 3) + Vector3.one * (val / 5)
					end
				end
			end
		end,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)
	
run(function()
	vape.Categories.Blatant:CreateModule({
		Name = 'KeepSprint',
		Function = function(callback)
			debug.setconstant(bedwars.SprintController.startSprinting, 5, callback and 'blockSprinting' or 'blockSprint')
			bedwars.SprintController:stopSprinting()
		end,
		Tooltip = 'Lets you sprint with a speed potion.'
	})
end)

local Attacking

																	
	
run(function()
	local Value
	local CameraDir
	local start
	local JumpTick, JumpSpeed, Direction = tick(), 0
	local projectileRemote = {InvokeServer = function() end}
	task.spawn(function()
		projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
	end)
	
	local function launchProjectile(item, pos, proj, speed, dir)
		if not pos then return end
	
		pos = pos - dir * 0.1
		local shootPosition = (CFrame.lookAlong(pos, Vector3.new(0, -speed, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ)))
		switchItem(item.tool, 0)
		task.wait(0.1)
		bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta[proj], proj, proj, shootPosition.Position, '', shootPosition.LookVector * speed, {drawDurationSeconds = 1})
		if projectileRemote:InvokeServer(item.tool, proj, proj, shootPosition.Position, pos, shootPosition.LookVector * speed, httpService:GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045) then
			local shoot = bedwars.ItemMeta[item.itemType].projectileSource.launchSound
			shoot = shoot and shoot[math.random(1, #shoot)] or nil
			if shoot then
				bedwars.SoundManager:playSound(shoot)
			end
		end
	end
	
	local LongJumpMethods = {
		cannon = function(_, pos, dir)
			pos = pos - Vector3.new(0, (entitylib.character.HipHeight + (entitylib.character.RootPart.Size.Y / 2)) - 3, 0)
			local rounded = Vector3.new(math.round(pos.X / 3) * 3, math.round(pos.Y / 3) * 3, math.round(pos.Z / 3) * 3)
			bedwars.placeBlock(rounded, 'cannon', false)
	
			task.delay(0, function()
				local block, blockpos = getPlacedBlock(rounded)
				if block and block.Name == 'cannon' and (entitylib.character.RootPart.Position - block.Position).Magnitude < 20 then
					local breaktype = bedwars.ItemMeta[block.Name].block.breakType
					local tool = store.tools[breaktype]
					if tool then
						switchItem(tool.tool)
					end
	
					bedwars.Client:Get(remotes.CannonAim):SendToServer({
						cannonBlockPos = blockpos,
						lookVector = dir
					})
	
					local broken = 0.1
					if bedwars.BlockController:calculateBlockDamage(lplr, {blockPosition = blockpos}) < block:GetAttribute('Health') then
						broken = 0.4
						bedwars.breakBlock(block, true, true)
					end
	
					task.delay(broken, function()
						for _ = 1, 3 do
							local call = bedwars.Client:Get(remotes.CannonLaunch):CallServer({cannonBlockPos = blockpos})
							if call then
								bedwars.breakBlock(block, true, true)
								JumpSpeed = 5.25 * Value.Value
								JumpTick = tick() + 2.3
								Direction = Vector3.new(dir.X, 0, dir.Z).Unit
								break
							end
							task.wait(0.1)
						end
					end)
																																				LongJump:Toggle()
				end
			end)
		end,
		cat = function(_, _, dir)
			LongJump:Clean(vapeEvents.CatPounce.Event:Connect(function()
				JumpSpeed = 4 * Value.Value
				JumpTick = tick() + 2.5
				Direction = Vector3.new(dir.X, 0, dir.Z).Unit
				entitylib.character.RootPart.Velocity = Vector3.zero
			end))
	
			if not bedwars.AbilityController:canUseAbility('CAT_POUNCE') then
				repeat task.wait(0.1) until bedwars.AbilityController:canUseAbility('CAT_POUNCE') or not LongJump.Enabled
			end
	
			if bedwars.AbilityController:canUseAbility('CAT_POUNCE') and LongJump.Enabled then
				bedwars.AbilityController:useAbility('CAT_POUNCE')
			end
																																																																					LongJump:Toggle()
LongJump:Toggle()
		end,
		fireball = function(item, pos, dir)
			launchProjectile(item, pos, 'fireball', 60, dir)
																																																																					LongJump:Toggle()
LongJump:Toggle()
		end,
		grappling_hook = function(item, pos, dir)
			launchProjectile(item, pos, 'grappling_hook_projectile', 140, dir)
																																	LongJump:Toggle()
		end,
		jade_hammer = function(item, _, dir)
			if not bedwars.AbilityController:canUseAbility(item.itemType..'_jump') then
				repeat task.wait(0.1) until bedwars.AbilityController:canUseAbility(item.itemType..'_jump') or not LongJump.Enabled
			end
	
			if bedwars.AbilityController:canUseAbility(item.itemType..'_jump') and LongJump.Enabled then
				bedwars.AbilityController:useAbility(item.itemType..'_jump')
				JumpSpeed = 1.4 * Value.Value
				JumpTick = tick() + 2.5
				Direction = Vector3.new(dir.X, 0, dir.Z).Unit
			end
																																	LongJump:Toggle()
		end,
		tnt = function(item, pos, dir)
			pos = pos - Vector3.new(0, (entitylib.character.HipHeight + (entitylib.character.RootPart.Size.Y / 2)) - 3, 0)
			local rounded = Vector3.new(math.round(pos.X / 3) * 3, math.round(pos.Y / 3) * 3, math.round(pos.Z / 3) * 3)
			start = Vector3.new(rounded.X, start.Y, rounded.Z) + (dir * (item.itemType == 'pirate_gunpowder_barrel' and 2.6 or 0.2))
			bedwars.placeBlock(rounded, item.itemType, false)
																																	LongJump:Toggle()
		end,
		wood_dao = function(item, pos, dir)
			if (lplr.Character:GetAttribute('CanDashNext') or 0) > workspace:GetServerTimeNow() or not bedwars.AbilityController:canUseAbility('dash') then
				repeat task.wait(0.1) until (lplr.Character:GetAttribute('CanDashNext') or 0) < workspace:GetServerTimeNow() and bedwars.AbilityController:canUseAbility('dash') or not LongJump.Enabled
			end
	
			if LongJump.Enabled then
				bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
				switchItem(item.tool, 0.1)
				replicatedStorage['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].useAbility:FireServer('dash', {
					direction = dir,
					origin = pos,
					weapon = item.itemType
				})
				JumpSpeed = 4.5 * Value.Value
				JumpTick = tick() + 2.4
				Direction = Vector3.new(dir.X, 0, dir.Z).Unit


			
			end
																																	LongJump:Toggle()
		end
	}
	for _, v in {'stone_dao', 'iron_dao', 'diamond_dao', 'emerald_dao'} do
		LongJumpMethods[v] = LongJumpMethods.wood_dao
	end
	LongJumpMethods.void_axe = LongJumpMethods.jade_hammer
	LongJumpMethods.siege_tnt = LongJumpMethods.tnt
	LongJumpMethods.pirate_gunpowder_barrel = LongJumpMethods.tnt
	
	LongJump = vape.Categories.Blatant:CreateModule({
		Name = 'LongJump',
		Function = function(callback)
			frictionTable.LongJump = callback or nil
			updateVelocity()
			if callback then
				LongJump:Clean(vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and damageTable.fromEntity == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then
						local knockbackBoost = bedwars.KnockbackUtil.calculateKnockbackVelocity(Vector3.one, 1, {
							vertical = 0,
							horizontal = (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal or 1)
						}).Magnitude * 1.1
	
						if knockbackBoost >= JumpSpeed then
							local pos = damageTable.fromPosition and Vector3.new(damageTable.fromPosition.X, damageTable.fromPosition.Y, damageTable.fromPosition.Z) or damageTable.fromEntity and damageTable.fromEntity.PrimaryPart.Position
							if not pos then return end
							local vec = (entitylib.character.RootPart.Position - pos)
							JumpSpeed = knockbackBoost
							JumpTick = tick() + 2.5
							Direction = Vector3.new(vec.X, 0, vec.Z).Unit
						end
					end
				end))
				LongJump:Clean(vapeEvents.GrapplingHookFunctions.Event:Connect(function(dataTable)
					if dataTable.hookFunction == 'PLAYER_IN_TRANSIT' then
						local vec = entitylib.character.RootPart.CFrame.LookVector
						JumpSpeed = 2.5 * Value.Value
						JumpTick = tick() + 2.5
						Direction = Vector3.new(vec.X, 0, vec.Z).Unit
					end
				end))
	
				start = entitylib.isAlive and entitylib.character.RootPart.Position or nil
				LongJump:Clean(runService.PreSimulation:Connect(function(dt)
					local root = entitylib.isAlive and entitylib.character.RootPart or nil
	
					if root and isnetworkowner(root) then
						if JumpTick > tick() then
							root.AssemblyLinearVelocity = Direction * (getSpeed() + ((JumpTick - tick()) > 1.1 and JumpSpeed or 0)) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
							if entitylib.character.Humanoid.FloorMaterial == Enum.Material.Air and not start then
								root.AssemblyLinearVelocity += Vector3.new(0, dt * (workspace.Gravity - 23), 0)
							else
								root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 15, root.AssemblyLinearVelocity.Z)
							end
							start = nil
						else
							if start then
								root.CFrame = CFrame.lookAlong(start, root.CFrame.LookVector)
							end
							root.AssemblyLinearVelocity = Vector3.zero
							JumpSpeed = 0
						end
					else
						start = nil
					end
				end))
	
				if store.hand and LongJumpMethods[store.hand.tool.Name] then
					task.spawn(LongJumpMethods[store.hand.tool.Name], getItem(store.hand.tool.Name), start, (CameraDir.Enabled and gameCamera or entitylib.character.RootPart).CFrame.LookVector)
					return
				end
	
				for i, v in LongJumpMethods do
					local item = getItem(i)
					if item or store.equippedKit == i then
						task.spawn(v, item, start, (CameraDir.Enabled and gameCamera or entitylib.character.RootPart).CFrame.LookVector)
						break
					end
				end
			else
				JumpTick = tick()
				Direction = nil
				JumpSpeed = 0
			end
		end,
		ExtraText = function()
			return 'Heatseeker'
		end,
		Tooltip = 'Lets you jump farther'
	})
	Value = LongJump:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 37,
		Default = 37,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	CameraDir = LongJump:CreateToggle({
		Name = 'Camera Direction'
	})
end)
	
run(function() 
	local NoFall
	local DamageAccuracy
	local rayParams = RaycastParams.new()
	NoFall = vape.Categories.Blatant:CreateModule({ 
		Name = 'NoFall',
		Function = function(callback)
			if callback then
				local extraGravity = 0
				NoFall:Clean(runService.PreSimulation:Connect(function(dt)
					if not entitylib.isAlive then return end
					local root = store.rootpart or entitylib.character.RootPart
					local velY = root.AssemblyLinearVelocity.Y
					local accuracy = DamageAccuracy.Value / 100
					if accuracy <= 0 then extraGravity = 0; return end
					if velY < -85 then
						rayParams.FilterDescendantsInstances = {lplr.Character, gameCamera}
						rayParams.CollisionGroup = root.CollisionGroup
						local rootSize = root.Size.Y / 2.5 + entitylib.character.HipHeight
						local ray = workspace:Blockcast(root.CFrame,Vector3.new(3, 3, 3),Vector3.new(0, -rootSize, 0),rayParams)
						if not ray then
							local targetY = -86
							local newY = velY + (targetY - velY) * accuracy
							print(newY)
							root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, newY, root.AssemblyLinearVelocity.Z)
							root.CFrame += Vector3.new(0, extraGravity * dt, 0)
							extraGravity -= workspace.Gravity * dt
						end
					else
						extraGravity = 0
					end
				end))
			end
		end,
		Tooltip = 'Prevents or reduces fall damage.'
	})

	DamageAccuracy = NoFall:CreateSlider({
		Name = 'Damage Accuracy',
		Min = 0,
		Max = 100,
		Suffix = '%',
		Default = 0,
		Decimal = 5
	})
end)
																														
	
run(function()
	local old
	
	vape.Categories.Blatant:CreateModule({
		Name = 'NoSlowdown',
		Function = function(callback)
			local modifier = bedwars.SprintController:getMovementStatusModifier()
			if callback then
				old = modifier.addModifier
				modifier.addModifier = function(self, tab)
					if tab.moveSpeedMultiplier then
						tab.moveSpeedMultiplier = math.max(tab.moveSpeedMultiplier, 1)
					end
					return old(self, tab)
				end
	
				for i in modifier.modifiers do
					if (i.moveSpeedMultiplier or 1) < 1 then
						modifier:removeModifier(i)
					end
				end
			else
				modifier.addModifier = old
				old = nil
			end
		end,
		Tooltip = 'Prevents slowing down when using items.'
	})
end)
	
run(function()
	local TargetPart
	local Targets
	local FOV
	local OtherProjectiles
	local rayCheck = RaycastParams.new()
	rayCheck.FilterType = Enum.RaycastFilterType.Include
	rayCheck.FilterDescendantsInstances = {workspace:FindFirstChild('Map')}
	local old
	
	local ProjectileAimbot = vape.Categories.Combat:CreateModule({
		Name = 'SilentAim',
		Function = function(callback)
			if callback then
				old = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(...)
					local self, projmeta, worldmeta, origin, shootpos = ...
					local plr = entitylib.EntityMouse({
						Part = 'RootPart',
						Range = FOV.Value,
						Players = Targets.Players.Enabled,
						NPCs = Targets.NPCs.Enabled,
						Wallcheck = Targets.Walls.Enabled,
						Origin = entitylib.isAlive and (shootpos or entitylib.character.RootPart.Position) or Vector3.zero
					})
	
					if plr then
						local pos = shootpos or self:getLaunchPosition(origin)
						if not pos then
							return old(...)
						end
	
						if (not OtherProjectiles.Enabled) and not projmeta.projectile:find('arrow') then
							return old(...)
						end
	
						local meta = projmeta:getProjectileMeta()
						local lifetime = (worldmeta and meta.predictionLifetimeSec or meta.lifetimeSec or 3)
						local gravity = (meta.gravitationalAcceleration or 196.2) * projmeta.gravityMultiplier
						local projSpeed = (meta.launchVelocity or 100)
						local offsetpos = pos + (projmeta.projectile == 'owl_projectile' and Vector3.zero or projmeta.fromPositionOffset)
						local balloons = plr.Character:GetAttribute('InflatedBalloons')
						local playerGravity = workspace.Gravity
	
						if balloons and balloons > 0 then
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end
	
						if plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then
							playerGravity = 6
						end
	
						if plr.Player:GetAttribute('IsOwlTarget') then
							for _, owl in collectionService:GetTagged('Owl') do
								if owl:GetAttribute('Target') == plr.Player.UserId and owl:GetAttribute('Status') == 2 then
									playerGravity = 0
								end
							end
						end
	
						local newlook = CFrame.new(offsetpos, plr[TargetPart.Value].Position) * CFrame.new(projmeta.projectile == 'owl_projectile' and Vector3.zero or Vector3.new(bedwars.BowConstantsTable.RelX, bedwars.BowConstantsTable.RelY, bedwars.BowConstantsTable.RelZ))
						local calc = prediction.SolveTrajectory(newlook.p, projSpeed, gravity, plr[TargetPart.Value].Position, projmeta.projectile == 'telepearl' and Vector3.zero or plr[TargetPart.Value].Velocity, playerGravity, plr.HipHeight, plr.Jumping and 42.6 or nil, rayCheck)
						if calc then
							targetinfo.Targets[plr] = tick() + 1
							return {
								initialVelocity = CFrame.new(newlook.Position, calc).LookVector * projSpeed,
								positionFrom = offsetpos,
								deltaT = lifetime,
								gravitationalAcceleration = gravity,
								drawDurationSeconds = 5
							}
						end
					end
	
					return old(...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = old
			end
		end,
		Tooltip = 'Silently adjusts your aim towards the enemy'
	})
	Targets = ProjectileAimbot:CreateTargets({
		Players = true,
		Walls = true
	})
	TargetPart = ProjectileAimbot:CreateDropdown({
		Name = 'Part',
		List = {'RootPart', 'Head'}
	})
	FOV = ProjectileAimbot:CreateSlider({
		Name = 'FOV',
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	OtherProjectiles = ProjectileAimbot:CreateToggle({
		Name = 'Other Projectiles',
		Default = true
	})
end)
	
run(function()
	local ProjectileAura
	local Targets
	local Range
	local List
	local rayCheck = RaycastParams.new()
	rayCheck.FilterType = Enum.RaycastFilterType.Include
	local projectileRemote = {InvokeServer = function() end}
	local FireDelays = {}
	task.spawn(function()
		projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
	end)
	
	local function getAmmo(check)
		for _, item in store.inventory.inventory.items do
			if check.ammoItemTypes and table.find(check.ammoItemTypes, item.itemType) then
				return item.itemType
			end
		end
	end
	
	local function getProjectiles()
		local items = {}
		for _, item in store.inventory.inventory.items do
			local proj = bedwars.ItemMeta[item.itemType].projectileSource
			local ammo = proj and getAmmo(proj)
			if ammo and table.find(List.ListEnabled, ammo) then
				table.insert(items, {
					item,
					ammo,
					proj.projectileType(ammo),
					proj
				})
			end
		end
		return items
	end
	
	ProjectileAura = vape.Categories.Blatant:CreateModule({
		Name = 'ProjectileAura',
		Function = function(callback)
			if callback then
				repeat
					if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) > 0.5 then
						local ent = entitylib.EntityPosition({
							Part = 'RootPart',
							Range = Range.Value,
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Wallcheck = Targets.Walls.Enabled
						})
	
						if ent then
							local pos = entitylib.character.RootPart.Position
							for _, data in getProjectiles() do
								local item, ammo, projectile, itemMeta = unpack(data)
								if (FireDelays[item.itemType] or 0) < tick() then
									rayCheck.FilterDescendantsInstances = {workspace.Map}
									local meta = bedwars.ProjectileMeta[projectile]
									local projSpeed, gravity = meta.launchVelocity, meta.gravitationalAcceleration or 196.2
									local calc = prediction.SolveTrajectory(pos, projSpeed, gravity, ent.RootPart.Position, ent.RootPart.Velocity, workspace.Gravity, ent.HipHeight, ent.Jumping and 42.6 or nil, rayCheck)
									if calc then
										targetinfo.Targets[ent] = tick() + 1
										local switched = switchItem(item.tool)
	
										task.spawn(function()
											local dir, id = CFrame.lookAt(pos, calc).LookVector, httpService:GenerateGUID(true)
											local shootPosition = (CFrame.new(pos, calc) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).Position
											bedwars.ProjectileController:createLocalProjectile(meta, ammo, projectile, shootPosition, id, dir * projSpeed, {drawDurationSeconds = 1})
											local res = projectileRemote:InvokeServer(item.tool, ammo, projectile, shootPosition, pos, dir * projSpeed, id, {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
											if not res then
												FireDelays[item.itemType] = tick()
											else
												local shoot = itemMeta.launchSound
												shoot = shoot and shoot[math.random(1, #shoot)] or nil
												if shoot then
													bedwars.SoundManager:playSound(shoot)
												end
											end
										end)
	
										FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
										if switched then
											task.wait(0.05)
										end
									end
								end
							end
						end
					end
					task.wait(0.1)
				until not ProjectileAura.Enabled
			end
		end,
		Tooltip = 'Shoots people around you'
	})
	Targets = ProjectileAura:CreateTargets({
		Players = true,
		Walls = true
	})
	List = ProjectileAura:CreateTextList({
		Name = 'Projectiles',
		Default = {'arrow', 'snowball'}
	})
	Range = ProjectileAura:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 50,
		Default = 50,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)
	

	
run(function()
	local BedESP
	local Reference = {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	
	local function Added(bed)
		if not BedESP.Enabled then return end
		local BedFolder = Instance.new('Folder')
		BedFolder.Parent = Folder
		Reference[bed] = BedFolder
		local parts = bed:GetChildren()
		table.sort(parts, function(a, b)
			return a.Name > b.Name
		end)
	
		for _, part in parts do
			if part:IsA('BasePart') and part.Name ~= 'Blanket' then
				local handle = Instance.new('BoxHandleAdornment')
				handle.Size = part.Size + Vector3.new(.01, .01, .01)
				handle.AlwaysOnTop = true
				handle.ZIndex = 2
				handle.Visible = true
				handle.Adornee = part
				handle.Color3 = part.Color
				if part.Name == 'Legs' then
					handle.Color3 = Color3.fromRGB(167, 112, 64)
					handle.Size = part.Size + Vector3.new(.01, -1, .01)
					handle.CFrame = CFrame.new(0, -0.4, 0)
					handle.ZIndex = 0
				end
				handle.Parent = BedFolder
			end
		end
	
		table.clear(parts)
	end
	
	BedESP = vape.Categories.Render:CreateModule({
		Name = 'BedESP',
		Function = function(callback)
			if callback then
				BedESP:Clean(collectionService:GetInstanceAddedSignal('bed'):Connect(function(bed)
					task.delay(0.2, Added, bed)
				end))
				BedESP:Clean(collectionService:GetInstanceRemovedSignal('bed'):Connect(function(bed)
					if Reference[bed] then
						Reference[bed]:Destroy()
						Reference[bed] = nil
					end
				end))
				for _, bed in collectionService:GetTagged('bed') do
					Added(bed)
				end
			else
				Folder:ClearAllChildren()
				table.clear(Reference)
			end
		end,
		Tooltip = 'Render Beds through walls'
	})
end)
	
run(function()
	local Health
	
	Health = vape.Categories.Render:CreateModule({
		Name = 'Health',
		Function = function(callback)
			if callback then
				local label = Instance.new('TextLabel')
				label.Size = UDim2.fromOffset(100, 20)
				label.Position = UDim2.new(0.5, 6, 0.5, 30)
				label.BackgroundTransparency = 1
				label.AnchorPoint = Vector2.new(0.5, 0)
				label.Text = entitylib.isAlive and math.round(lplr.Character:GetAttribute('Health'))..' ❤️' or ''
				label.TextColor3 = entitylib.isAlive and Color3.fromHSV((lplr.Character:GetAttribute('Health') / lplr.Character:GetAttribute('MaxHealth')) / 2.8, 0.86, 1) or Color3.new()
				label.TextSize = 18
				label.Font = Enum.Font.Arial
				label.Parent = vape.gui
				Health:Clean(label)
				Health:Clean(vapeEvents.AttributeChanged.Event:Connect(function()
					label.Text = entitylib.isAlive and math.round(lplr.Character:GetAttribute('Health'))..' ❤️' or ''
					label.TextColor3 = entitylib.isAlive and Color3.fromHSV((lplr.Character:GetAttribute('Health') / lplr.Character:GetAttribute('MaxHealth')) / 2.8, 0.86, 1) or Color3.new()
				end))
			end
		end,
		Tooltip = 'Displays your health in the center of your screen.'
	})
end)

run(function()
	local NameTags
	local Targets
	local Color
	local Background
	local DisplayName
	local Health
	local Distance
	local Equipment
	local DrawingToggle
	local Scale
	local FontOption
	local Teammates
	local DistanceCheck
	local DistanceLimit
	local Strings, Sizes, Reference = {}, {}, {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	local methodused
	
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
		['skeleton'] = "rbxassetid://120123419412119",
		['winter_lady'] = "rbxassetid://83274578564074",
    }

	local Added = {
		Normal = function(ent)
			if not Targets.Players.Enabled and ent.Player then return end
			if not Targets.NPCs.Enabled and ent.NPC then return end
			--if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then return end
	
			local nametag = Instance.new('TextLabel')
			Strings[ent] = ent.Player and whitelist:tag(ent.Player, true, true)..(DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
	
			if Health.Enabled then
				local healthColor = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
				Strings[ent] = Strings[ent]..' <font color="rgb('..tostring(math.floor(healthColor.R * 255))..','..tostring(math.floor(healthColor.G * 255))..','..tostring(math.floor(healthColor.B * 255))..')">'..math.round(ent.Health)..'</font>'
			end
	
			if Distance.Enabled then
				Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..Strings[ent]
			end
	
			if Equipment.Enabled then
				for i, v in {'Hand', 'Helmet', 'Chestplate', 'Boots', 'Kit'} do
					local Icon = Instance.new('ImageLabel')
					Icon.Name = v
					Icon.Size = UDim2.fromOffset(30, 30)
					Icon.Position = UDim2.fromOffset(-60 + (i * 30), -30)
					Icon.BackgroundTransparency = 1
					Icon.Image = ''
					Icon.Parent = nametag
				end
			end
	
			nametag.TextSize = 14 * Scale.Value
			nametag.FontFace = FontOption.Value
			local size = getfontsize(removeTags(Strings[ent]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
			nametag.Name = ent.Player and ent.Player.Name or ent.Character.Name
			nametag.Size = UDim2.fromOffset(size.X + 8, size.Y + 7)
			nametag.AnchorPoint = Vector2.new(0.5, 1)
			nametag.BackgroundColor3 = Color3.new()
			nametag.BackgroundTransparency = Background.Value
			nametag.BorderSizePixel = 0
			nametag.Visible = false
			nametag.Text = Strings[ent]
			nametag.TextColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			nametag.RichText = true
			nametag.Parent = Folder
			Reference[ent] = nametag
		end,
		Drawing = function(ent)
			if not Targets.Players.Enabled and ent.Player then return end
			if not Targets.NPCs.Enabled and ent.NPC then return end
			--if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then return end
	
			local nametag = {}
			nametag.BG = Drawing.new('Square')
			nametag.BG.Filled = true
			nametag.BG.Transparency = 1 - Background.Value
			nametag.BG.Color = Color3.new()
			nametag.BG.ZIndex = 1
			nametag.Text = Drawing.new('Text')
			nametag.Text.Size = 15 * Scale.Value
			nametag.Text.Font = 0
			nametag.Text.ZIndex = 2
			Strings[ent] = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
	
			if Health.Enabled then
				Strings[ent] = Strings[ent]..' '..math.round(ent.Health)
			end
	
			if Distance.Enabled then
				Strings[ent] = '[%s] '..Strings[ent]
			end
	
			nametag.Text.Text = Strings[ent]
			nametag.Text.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
			Reference[ent] = nametag
		end
	}
	
	local Removed = {
		Normal = function(ent)
			local v = Reference[ent]
			if v then
				Reference[ent] = nil
				Strings[ent] = nil
				Sizes[ent] = nil
				v:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = Reference[ent]
			if v then
				Reference[ent] = nil
				Strings[ent] = nil
				Sizes[ent] = nil
				for _, obj in v do
					pcall(function()
						obj.Visible = false
						obj:Remove()
					end)
				end
			end
		end
	}
	
	local Updated = {
		Normal = function(ent)
			local nametag = Reference[ent]
			if nametag then
				Sizes[ent] = nil
				Strings[ent] = ent.Player and whitelist:tag(ent.Player, true, true)..(DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
	
				if Health.Enabled then
					local healthColor = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
					Strings[ent] = Strings[ent]..' <font color="rgb('..tostring(math.floor(healthColor.R * 255))..','..tostring(math.floor(healthColor.G * 255))..','..tostring(math.floor(healthColor.B * 255))..')">'..math.round(ent.Health)..'</font>'
				end
	
				if Distance.Enabled then
					Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..Strings[ent]
				end
	
				if Equipment.Enabled and store.inventories[ent.Player] then
					local kit = ent.Player:GetAttribute('PlayingAsKits')
					local inventory = store.inventories[ent.Player]
					nametag.Hand.Image = bedwars.getIcon(inventory.hand or {itemType = ''}, true)
					nametag.Helmet.Image = bedwars.getIcon(inventory.armor[4] or {itemType = ''}, true)
					nametag.Chestplate.Image = bedwars.getIcon(inventory.armor[5] or {itemType = ''}, true)
					nametag.Boots.Image = bedwars.getIcon(inventory.armor[6] or {itemType = ''}, true)
					nametag.Kit.Image = ids[kit] or ''
				end
	
				local size = getfontsize(removeTags(Strings[ent]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
				nametag.Size = UDim2.fromOffset(size.X + 8, size.Y + 7)
				nametag.Text = Strings[ent]
			end
		end,
		Drawing = function(ent)
			local nametag = Reference[ent]
			if nametag then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Sizes[ent] = nil
				Strings[ent] = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
	
				if Health.Enabled then
					Strings[ent] = Strings[ent]..' '..math.round(ent.Health)
				end
	
				if Distance.Enabled then
					Strings[ent] = '[%s] '..Strings[ent]
					nametag.Text.Text = entitylib.isAlive and string.format(Strings[ent], math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude)) or Strings[ent]
				else
					nametag.Text.Text = Strings[ent]
				end
	
				nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
				nametag.Text.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			end
		end
	}
	
	local ColorFunc = {
		Normal = function(hue, sat, val)
			local color = Color3.fromHSV(hue, sat, val)
			for i, v in Reference do
				v.TextColor3 = entitylib.getEntityColor(i) or color
			end
		end,
		Drawing = function(hue, sat, val)
			local color = Color3.fromHSV(hue, sat, val)
			for i, v in Reference do
				v.Text.Color = entitylib.getEntityColor(i) or color
			end
		end
	}
	
	local Loop = {
		Normal = function()
			for ent, nametag in Reference do
				if DistanceCheck.Enabled then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						nametag.Visible = false
						continue
					end
				end
	
				local headPos, headVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
				nametag.Visible = headVis
				if not headVis then
					continue
				end
	
				if Distance.Enabled then
					local mag = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude) or 0
					if Sizes[ent] ~= mag then
						nametag.Text = string.format(Strings[ent], mag)
						local ize = getfontsize(removeTags(nametag.Text), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
						nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7)
						Sizes[ent] = mag
					end
				end
				nametag.Position = UDim2.fromOffset(headPos.X, headPos.Y)
			end
		end,
		Drawing = function()
			for ent, nametag in Reference do
				if DistanceCheck.Enabled then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						nametag.Text.Visible = false
						nametag.BG.Visible = false
						continue
					end
				end
	
				local headPos, headVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
				nametag.Text.Visible = headVis
				nametag.BG.Visible = headVis
				if not headVis then
					continue
				end
	
				if Distance.Enabled then
					local mag = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude) or 0
					if Sizes[ent] ~= mag then
						nametag.Text.Text = string.format(Strings[ent], mag)
						nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
						Sizes[ent] = mag
					end
				end
				nametag.BG.Position = Vector2.new(headPos.X - (nametag.BG.Size.X / 2), headPos.Y - nametag.BG.Size.Y)
				nametag.Text.Position = nametag.BG.Position + Vector2.new(4, 3)
			end
		end
	}
	
	NameTags = vape.Categories.Render:CreateModule({
		Name = 'NameTags',
		Function = function(callback)
			if callback then
				methodused = DrawingToggle.Enabled and 'Drawing' or 'Normal'
				if Removed[methodused] then
					NameTags:Clean(entitylib.Events.EntityRemoved:Connect(Removed[methodused]))
				end
				if Added[methodused] then
					for _, v in entitylib.List do
						if Reference[v] then
							Removed[methodused](v)
						end
						Added[methodused](v)
					end
					NameTags:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
						if Reference[ent] then
							Removed[methodused](ent)
						end
						Added[methodused](ent)
					end))
				end
				if Updated[methodused] then
					NameTags:Clean(entitylib.Events.EntityUpdated:Connect(Updated[methodused]))
					for _, v in entitylib.List do
						Updated[methodused](v)
					end
				end
				if ColorFunc[methodused] then
					NameTags:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
						ColorFunc[methodused](Color.Hue, Color.Sat, Color.Value)
					end))
				end
				if Loop[methodused] then
					NameTags:Clean(runService.RenderStepped:Connect(Loop[methodused]))
				end
			else
				if Removed[methodused] then
					for i in Reference do
						Removed[methodused](i)
					end
				end
			end
		end,
		Tooltip = 'Renders nametags on entities through walls.'
	})
	Targets = NameTags:CreateTargets({
		Players = true,
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	FontOption = NameTags:CreateFont({
		Name = 'Font',
		Blacklist = 'Arial',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	Color = NameTags:CreateColorSlider({
		Name = 'Player Color',
		Function = function(hue, sat, val)
			if NameTags.Enabled and ColorFunc[methodused] then
				ColorFunc[methodused](hue, sat, val)
			end
		end
	})
	Scale = NameTags:CreateSlider({
		Name = 'Scale',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = 1,
		Min = 0.1,
		Max = 1.5,
		Decimal = 10
	})
	Background = NameTags:CreateSlider({
		Name = 'Transparency',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = 0.5,
		Min = 0,
		Max = 1,
		Decimal = 10
	})
	Health = NameTags:CreateToggle({
		Name = 'Health',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	Distance = NameTags:CreateToggle({
		Name = 'Distance',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	Equipment = NameTags:CreateToggle({
		Name = 'Equipment',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	DisplayName = NameTags:CreateToggle({
		Name = 'Use Displayname',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = true
	})
	Teammates = NameTags:CreateToggle({
		Name = 'Priority Only',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = true
	})
	DrawingToggle = NameTags:CreateToggle({
		Name = 'Drawing',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
	})
	DistanceCheck = NameTags:CreateToggle({
		Name = 'Distance Check',
		Function = function(callback)
			DistanceLimit.Object.Visible = callback
		end
	})
	DistanceLimit = NameTags:CreateTwoSlider({
		Name = 'Player Distance',
		Min = 0,
		Max = 256,
		DefaultMin = 0,
		DefaultMax = 64,
		Darker = true,
		Visible = false
	})
end)
	
run(function()
	local StorageESP
	local List
	local Background
	local Color = {}
	local Reference = {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	
	local function nearStorageItem(item)
		for _, v in List.ListEnabled do
			if item:find(v) then return v end
		end
	end
	
	local function refreshAdornee(v)
		local chest = v.Adornee:FindFirstChild('ChestFolderValue')
		chest = chest and chest.Value or nil
		if not chest then
			v.Enabled = false
			return
		end
	
		local chestitems = chest and chest:GetChildren() or {}
		for _, obj in v.Frame:GetChildren() do
			if obj:IsA('ImageLabel') and obj.Name ~= 'Blur' then
				obj:Destroy()
			end
		end
	
		v.Enabled = false
		local alreadygot = {}
		for _, item in chestitems do
			if not alreadygot[item.Name] and (table.find(List.ListEnabled, item.Name) or nearStorageItem(item.Name)) then
				alreadygot[item.Name] = true
				v.Enabled = true
				local blockimage = Instance.new('ImageLabel')
				blockimage.Size = UDim2.fromOffset(32, 32)
				blockimage.BackgroundTransparency = 1
				blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
				blockimage.Parent = v.Frame
			end
		end
		table.clear(chestitems)
	end
	
	local function Added(v)
		local chest = v:WaitForChild('ChestFolderValue', 3)
		if not (chest and StorageESP.Enabled) then return end
		chest = chest.Value
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = Folder
		billboard.Name = 'chest'
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
		billboard.Size = UDim2.fromOffset(36, 36)
		billboard.AlwaysOnTop = true
		billboard.ClipsDescendants = false
		billboard.Adornee = v
		local blur = addBlur(billboard)
		blur.Visible = Background.Enabled
		local frame = Instance.new('Frame')
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
		frame.BackgroundTransparency = 1 - (Background.Enabled and Color.Opacity or 0)
		frame.Parent = billboard
		local layout = Instance.new('UIListLayout')
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 4)
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			billboard.Size = UDim2.fromOffset(math.max(layout.AbsoluteContentSize.X + 4, 36), 36)
		end)
		layout.Parent = frame
		local corner = Instance.new('UICorner')
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = frame
		Reference[v] = billboard
		StorageESP:Clean(chest.ChildAdded:Connect(function(item)
			if table.find(List.ListEnabled, item.Name) or nearStorageItem(item.Name) then
				refreshAdornee(billboard)
			end
		end))
		StorageESP:Clean(chest.ChildRemoved:Connect(function(item)
			if table.find(List.ListEnabled, item.Name) or nearStorageItem(item.Name) then
				refreshAdornee(billboard)
			end
		end))
		task.spawn(refreshAdornee, billboard)
	end
	
	StorageESP = vape.Categories.Render:CreateModule({
		Name = 'StorageESP',
		Function = function(callback)
			if callback then
				StorageESP:Clean(collectionService:GetInstanceAddedSignal('chest'):Connect(Added))
				for _, v in collectionService:GetTagged('chest') do
					task.spawn(Added, v)
				end
			else
				table.clear(Reference)
				Folder:ClearAllChildren()
			end
		end,
		Tooltip = 'Displays items in chests'
	})
	List = StorageESP:CreateTextList({
		Name = 'Item',
		Function = function()
			for _, v in Reference do
				task.spawn(refreshAdornee, v)
			end
		end
	})
	Background = StorageESP:CreateToggle({
		Name = 'Background',
		Function = function(callback)
			if Color.Object then Color.Object.Visible = callback end
			for _, v in Reference do
				v.Frame.BackgroundTransparency = 1 - (callback and Color.Opacity or 0)
				v.Blur.Visible = callback
			end
		end,
		Default = true
	})
	Color = StorageESP:CreateColorSlider({
		Name = 'Background Color',
		DefaultValue = 0,
		DefaultOpacity = 0.5,
		Function = function(hue, sat, val, opacity)
			for _, v in Reference do
				v.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
				v.Frame.BackgroundTransparency = 1 - opacity
			end
		end,
		Darker = true
	})
end)
	
run(function()
	local AutoBalloon
	
	AutoBalloon = vape.Categories.Utility:CreateModule({
		Name = 'AutoBalloon',
		Function = function(callback)
			if callback then
				repeat task.wait(0.1) until store.matchState ~= 0 or (not AutoBalloon.Enabled)
				if not AutoBalloon.Enabled then return end
	
				local lowestpoint = math.huge
				for _, v in store.blocks do
					local point = (v.Position.Y - (v.Size.Y / 2)) - 50
					if point < lowestpoint then 
						lowestpoint = point 
					end
				end
	
				repeat
					if entitylib.isAlive then
						if entitylib.character.RootPart.Position.Y < lowestpoint and (lplr.Character:GetAttribute('InflatedBalloons') or 0) < 3 then
							local balloon = getItem('balloon')
							if balloon then
								for _ = 1, 3 do 
									bedwars.BalloonController:inflateBalloon() 
								end
							end
							task.wait(0.1)
						end
					end
					task.wait(0.1)
				until not AutoBalloon.Enabled
			end
		end,
		Tooltip = 'Inflates when you fall into the void'
	})
end)
		
run(function()
	local AutoPearl
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	local projectileRemote = {InvokeServer = function() end}
	task.spawn(function()
		projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
	end)
	
	local function firePearl(pos, spot, item)
		switchItem(item.tool)
		local meta = bedwars.ProjectileMeta.telepearl
		local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
	
		if calc then
			local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
			bedwars.ProjectileController:createLocalProjectile(meta, 'telepearl', 'telepearl', pos, nil, dir, {drawDurationSeconds = 1})
			projectileRemote:InvokeServer(item.tool, 'telepearl', 'telepearl', pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
		end
	
		if store.hand then
			switchItem(store.hand.tool)
		end
	end
	
	AutoPearl = vape.Categories.Utility:CreateModule({
		Name = 'AutoPearl',
		Function = function(callback)
			if callback then
				local check
				repeat
					if entitylib.isAlive then
						local root = entitylib.character.RootPart
						local pearl = getItem('telepearl')
						rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, AntiFallPart}
						rayCheck.CollisionGroup = root.CollisionGroup
	
						if pearl and root.Velocity.Y < -100 and not workspace:Raycast(root.Position, Vector3.new(0, -200, 0), rayCheck) then
							if not check then
								check = true
								local ground = getNearGround(20)
	
								if ground then
									firePearl(root.Position, ground, pearl)
								end
							end
						else
							check = false
						end
					end
					task.wait(0.1)
				until not AutoPearl.Enabled
			end
		end,
		Tooltip = 'Automatically throws a pearl onto nearby ground after\nfalling a certain distance.'
	})
end)
	

	

	
run(function()
	local AutoToxic
	local GG
	local Toggles, Lists, said, dead = {}, {}, {}
	
	local function sendMessage(name, obj, default)
		local tab = Lists[name].ListEnabled
		local custommsg = #tab > 0 and tab[math.random(1, #tab)] or default
		if not custommsg then return end
		if #tab > 1 and custommsg == said[name] then
			repeat 
				task.wait(0.1) 
				custommsg = tab[math.random(1, #tab)] 
			until custommsg ~= said[name]
		end
		said[name] = custommsg
	
		custommsg = custommsg and custommsg:gsub('<obj>', obj or '') or ''
		if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
		else
			replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(custommsg, 'All')
		end
	end
	
	AutoToxic = vape.Categories.Utility:CreateModule({
		Name = 'AutoToxic',
		Function = function(callback)
			if callback then
				AutoToxic:Clean(vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if Toggles.BedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute('Team') then
						sendMessage('BedDestroyed', (bedTable.player.DisplayName or bedTable.player.Name), 'why would you bed break me <obj> onyx will obviously diff you xd')
					elseif Toggles.Bed.Enabled and bedTable.player.UserId == lplr.UserId then
						local team = bedwars.QueueMeta[store.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
						sendMessage('Bed', team and team.displayName:lower() or 'white', 'nice bed btw, switch to onyx forever on top | <obj>')
					end
				end))
				AutoToxic:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then
							if (not dead) and killer ~= lplr and Toggles.Death.Enabled then
								dead = true
								sendMessage('Death', (killer.DisplayName or killer.Name), 'ur trash btw and onyx on top forever :( | <obj>')
							end
						elseif killer == lplr and Toggles.Kill.Enabled then
							sendMessage('Kill', (killed.DisplayName or killed.Name), 'you should switch to onyx my friend named | <obj>')
						end
					end
				end))
				AutoToxic:Clean(vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					if GG.Enabled then
						if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync('ez + onyx forever')
						else
							replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('ez and onyx forever', 'All')
						end
					end
					
					local myTeam = bedwars.Store:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if Toggles.Win.Enabled then 
							sendMessage('Win', nil, 'yall garbage and onyx on top') 
						end
					end
				end))
			end
		end,
		Tooltip = 'Says a message after a certain action'
	})
	GG = AutoToxic:CreateToggle({
		Name = 'AutoGG',
		Default = true
	})
	for _, v in {'Kill', 'Death', 'Bed', 'BedDestroyed', 'Win'} do
		Toggles[v] = AutoToxic:CreateToggle({
			Name = v..' ',
			Function = function(callback)
				if Lists[v] then
					Lists[v].Object.Visible = callback
				end
			end
		})
		Lists[v] = AutoToxic:CreateTextList({
			Name = v,
			Darker = true,
			Visible = false
		})
	end
end)
	
run(function()
	local AutoVoidDrop
	local OwlCheck
	
	AutoVoidDrop = vape.Categories.Utility:CreateModule({
		Name = 'AutoVoidDrop',
		Function = function(callback)
			if callback then
				repeat task.wait(0.1) until store.matchState ~= 0 or (not AutoVoidDrop.Enabled)
				if not AutoVoidDrop.Enabled then return end
	
				local lowestpoint = math.huge
				for _, v in store.blocks do
					local point = (v.Position.Y - (v.Size.Y / 2)) - 50
					if point < lowestpoint then
						lowestpoint = point
					end
				end
	
				repeat
					if entitylib.isAlive then
						local root = entitylib.character.RootPart
						if root.Position.Y < lowestpoint and (lplr.Character:GetAttribute('InflatedBalloons') or 0) <= 0 and not getItem('balloon') then
							if not OwlCheck.Enabled or not root:FindFirstChild('OwlLiftForce') then
								for _, item in {'iron', 'diamond', 'emerald', 'gold'} do
									item = getItem(item)
									if item then
										item = bedwars.Client:Get(remotes.DropItem):CallServer({
											item = item.tool,
											amount = item.amount
										})
	
										if item then
											item:SetAttribute('ClientDropTime', tick() + 100)
										end
									end
								end
							end
						end
					end
	
					task.wait(0.1)
				until not AutoVoidDrop.Enabled
			end
		end,
		Tooltip = 'Drops resources when you fall into the void'
	})
	OwlCheck = AutoVoidDrop:CreateToggle({
		Name = 'Owl check',
		Default = true,
		Tooltip = 'Refuses to drop items if being picked up by an owl'
	})
end)
	
run(function()
	local MissileTP
	
	MissileTP = vape.Categories.Utility:CreateModule({
		Name = 'MissileTP',
		Function = function(callback)
			if callback then
				MissileTP:Toggle()
				local plr = entitylib.EntityMouse({
					Range = 1000,
					Players = true,
					Part = 'RootPart'
				})
	
				if getItem('guided_missile') and plr then
					local projectile = bedwars.RuntimeLib.await(bedwars.GuidedProjectileController.fireGuidedProjectile:CallServerAsync('guided_missile'))
					if projectile then
						local projectilemodel = projectile.model
						if not projectilemodel.PrimaryPart then
							projectilemodel:GetPropertyChangedSignal('PrimaryPart'):Wait()
						end
	
						local bodyforce = Instance.new('BodyForce')
						bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
						bodyforce.Name = 'AntiGravity'
						bodyforce.Parent = projectilemodel.PrimaryPart
	
						repeat
							projectile.model:SetPrimaryPartCFrame(CFrame.lookAlong(plr.RootPart.CFrame.p, gameCamera.CFrame.LookVector))
							task.wait(0.1)
						until not projectile.model or not projectile.model.Parent
					else
						notif('MissileTP', 'Missile on cooldown.', 3)
					end
				end
			end
		end,
		Tooltip = 'Spawns and teleports a missile to a player\nnear your mouse.'
	})
end)
	
run(function()
	local PickupRange
	local Range
	local Network
	local Lower
	
	PickupRange = vape.Categories.Utility:CreateModule({
		Name = 'PickupRange',
		Function = function(callback)
			if callback then
				local items = collection('ItemDrop', PickupRange)
				repeat
					if entitylib.isAlive then
						local localPosition = entitylib.character.RootPart.Position
						for _, v in items do
							if tick() - (v:GetAttribute('ClientDropTime') or 0) < 2 then continue end
							if isnetworkowner(v) and Network.Enabled and entitylib.character.Humanoid.Health > 0 then 
								v.CFrame = CFrame.new(localPosition - Vector3.new(0, 3, 0)) 
							end
							
							if (localPosition - v.Position).Magnitude <= Range.Value then
								if Lower.Enabled and (localPosition.Y - v.Position.Y) < (entitylib.character.HipHeight - 1) then continue end
								task.spawn(function()
									bedwars.Client:Get(remotes.PickupItem):CallServerAsync({
										itemDrop = v
									}):andThen(function(suc)
										if suc and bedwars.SoundList then
											bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
											local sound = bedwars.ItemMeta[v.Name].pickUpOverlaySound
											if sound then
												bedwars.SoundManager:playSound(sound, {
													position = v.Position,
													volumeMultiplier = 0.9
												})
											end
										end
									end)
								end)
							end
						end
					end
					task.wait(0.1)
				until not PickupRange.Enabled
			end
		end,
		Tooltip = 'Picks up items from a farther distance'
	})
	Range = PickupRange:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 10,
		Default = 10,
		Suffix = function(val) 
			return val == 1 and 'stud' or 'studs' 
		end
	})
	Network = PickupRange:CreateToggle({
		Name = 'Network TP',
		Default = true
	})
	Lower = PickupRange:CreateToggle({Name = 'Feet Check'})
end)
	
run(function()
	local RavenTP
	
	RavenTP = vape.Categories.Utility:CreateModule({
		Name = 'RavenTP',
		Function = function(callback)
			if callback then
				RavenTP:Toggle()
				local plr = entitylib.EntityMouse({
					Range = 1000,
					Players = true,
					Part = 'RootPart'
				})
	
				if getItem('raven') and plr then
					bedwars.Client:Get(remotes.SpawnRaven):CallServerAsync():andThen(function(projectile)
						if projectile then
							local bodyforce = Instance.new('BodyForce')
							bodyforce.Force = Vector3.new(0, projectile.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
							bodyforce.Parent = projectile.PrimaryPart
	
							if plr then
								task.spawn(function()
									for _ = 1, 20 do
										if plr.RootPart and projectile then
											projectile:SetPrimaryPartCFrame(CFrame.lookAlong(plr.RootPart.Position, gameCamera.CFrame.LookVector))
										end
										task.wait(0.05)
									end
								end)
								task.wait(0.3)
								bedwars.RavenController:detonateRaven()
							end
						end
					end)
				end
			end
		end,
		Tooltip = 'Spawns and teleports a raven to a player\nnear your mouse.'
	})
end)

run(function()
	local Expand
	local Tower
	local Downwards
	local Diagonal
	local LimitItem
	local Mouse
	local adjacent, lastpos, label = {}, Vector3.zero
	
	for x = -3, 3, 3 do
		for y = -3, 3, 3 do
			for z = -3, 3, 3 do
				local vec = Vector3.new(x, y, z)
				if vec ~= Vector3.zero then
					table.insert(adjacent, vec)
				end
			end
		end
	end
	
	local function nearCorner(poscheck, pos)
		local startpos = poscheck - Vector3.new(3, 3, 3)
		local endpos = poscheck + Vector3.new(3, 3, 3)
		local check = poscheck + (pos - poscheck).Unit * 100
		return Vector3.new(math.clamp(check.X, startpos.X, endpos.X), math.clamp(check.Y, startpos.Y, endpos.Y), math.clamp(check.Z, startpos.Z, endpos.Z))
	end
	
	local function blockProximity(pos)
		local mag, returned = 60
		local tab = getBlocksInPoints(bedwars.BlockController:getBlockPosition(pos - Vector3.new(21, 21, 21)), bedwars.BlockController:getBlockPosition(pos + Vector3.new(21, 21, 21)))
		for _, v in tab do
			local blockpos = nearCorner(v, pos)
			local newmag = (pos - blockpos).Magnitude
			if newmag < mag then
				mag, returned = newmag, blockpos
			end
		end
		table.clear(tab)
		return returned
	end
	
	local function checkAdjacent(pos)
		for _, v in adjacent do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end
	
	local function getScaffoldBlock()
		if store.hand.toolType == 'block' then
			return store.hand.tool.Name, store.hand.amount
		elseif (not LimitItem.Enabled) then
			local wool, amount = getWool()
			if wool then
				return wool, amount
			else
				for _, item in store.inventory.inventory.items do
					if bedwars.ItemMeta[item.itemType].block then
						return item.itemType, item.amount
					end
				end
			end
		end
	
		return nil, 0
	end
	
	Scaffold = vape.Categories.Utility:CreateModule({
		Name = 'Scaffold',
		Function = function(callback)
			if label then
				label.Visible = callback
			end
	
			if callback then
				repeat
					if entitylib.isAlive then
						local wool, amount = getScaffoldBlock()
	
						if Mouse.Enabled then
							if not inputService:IsMouseButtonPressed(0) then
								wool = nil
							end
						end
	
						if label then
							amount = amount or 0
							label.Text = amount..' <font color="rgb(170, 170, 170)">(Scaffold)</font>'
							label.TextColor3 = Color3.fromHSV((amount / 128) / 2.8, 0.86, 1)
						end
	
						if wool then
							local root = entitylib.character.RootPart
							if Tower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and (not inputService:GetFocusedTextBox()) then
								root.Velocity = Vector3.new(root.Velocity.X, 38, root.Velocity.Z)
							end
	
							for i = Expand.Value, 1, -1 do
								local currentpos = roundPos(root.Position - Vector3.new(0, entitylib.character.HipHeight + (Downwards.Enabled and inputService:IsKeyDown(Enum.KeyCode.LeftShift) and 4.5 or 1.5), 0) + entitylib.character.Humanoid.MoveDirection * (i * 3))
								if Diagonal.Enabled then
									if math.abs(math.round(math.deg(math.atan2(-entitylib.character.Humanoid.MoveDirection.X, -entitylib.character.Humanoid.MoveDirection.Z)) / 45) * 45) % 90 == 45 then
										local dt = (lastpos - currentpos)
										if ((dt.X == 0 and dt.Z ~= 0) or (dt.X ~= 0 and dt.Z == 0)) and ((lastpos - root.Position) * Vector3.new(1, 0, 1)).Magnitude < 2.5 then
											currentpos = lastpos
										end
									end
								end
	
								local block, blockpos = getPlacedBlock(currentpos)
								if not block then
									blockpos = checkAdjacent(blockpos * 3) and blockpos * 3 or blockProximity(currentpos)
									if blockpos then
										task.spawn(bedwars.placeBlock, blockpos, wool, false)
									end
								end
								lastpos = currentpos
							end
						end
					end
	
					task.wait(0.03)
				until not Scaffold.Enabled
			else
				Label = nil
			end
		end,
		Tooltip = 'Helps you make bridges/scaffold walk.'
	})
	Expand = Scaffold:CreateSlider({
		Name = 'Expand',
		Min = 1,
		Max = 6
	})
	Tower = Scaffold:CreateToggle({
		Name = 'Tower',
		Default = true
	})
	Downwards = Scaffold:CreateToggle({
		Name = 'Downwards',
		Default = true
	})
	Diagonal = Scaffold:CreateToggle({
		Name = 'Diagonal',
		Default = true
	})
	LimitItem = Scaffold:CreateToggle({Name = 'Limit to items'})
	Mouse = Scaffold:CreateToggle({Name = 'Require mouse down'})
	Count = Scaffold:CreateToggle({
		Name = 'Block Count',
		Function = function(callback)
			if callback then
				label = Instance.new('TextLabel')
				label.Size = UDim2.fromOffset(100, 20)
				label.Position = UDim2.new(0.5, 6, 0.5, 60)
				label.BackgroundTransparency = 1
				label.AnchorPoint = Vector2.new(0.5, 0)
				label.Text = '0'
				label.TextColor3 = Color3.new(0, 1, 0)
				label.TextSize = 18
				label.RichText = true
				label.Font = Enum.Font.Arial
				label.Visible = Scaffold.Enabled
				label.Parent = vape.gui
			else
				label:Destroy()
				label = nil
			end
		end
	})
end)
	
--[[run(function()
	local ShopTierBypass
	local tiered, nexttier = {}, {}
	
	ShopTierBypass = vape.Categories.Utility:CreateModule({
		Name = 'ShopTierBypass',
		Function = function(callback)
			if ShopTierBypass.Enabled then
				if store.equippedKit == "berserker" then
					vape:CreateNotification("ShopTierBypass","Cannot use 'ShopTierBypass' with the current kit 'RAGNAR'",6,"warning")
					return
				end
			end
			if callback then
				repeat task.wait(0.1) until store.shopLoaded or not ShopTierBypass.Enabled
				if ShopTierBypass.Enabled then
					for _, v in bedwars.Shop.ShopItems do
						tiered[v] = v.tiered
						nexttier[v] = v.nextTier
						v.nextTier = nil
						v.tiered = nil
					end
				end
			else
				for i, v in tiered do
					i.tiered = v
				end
				for i, v in nexttier do
					i.nextTier = v
				end
				table.clear(nexttier)
				table.clear(tiered)
			end
		end,
		Tooltip = 'Lets you buy things like armor early.'
	})
end)--]]
	

run(function()
    local ShopTierBypass
    local tiered, nexttier = {}, {}
    local originalGetShop
    local shopItemsTracked = {}
    
    local function applyBypassToItem(item)
        if item and type(item) == "table" then
            if not tiered[item] then 
                tiered[item] = item.tiered 
            end
            if not nexttier[item] then 
                nexttier[item] = item.nextTier 
            end
            item.nextTier = nil
            item.tiered = nil
            shopItemsTracked[item] = true
        end
    end
    
    local function applyBypassToTable(tbl)
        if tbl and type(tbl) == "table" then
            for _, item in pairs(tbl) do
                if type(item) == "table" then
                    applyBypassToItem(item)
                end
            end
        end
    end
    
    local function getShopController()
        local success, result = pcall(function()
            local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
            if RuntimeLib then
                return RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "games", "bedwars", "shop", "bedwars-shop")
            end
        end)
        
        if success then
            return result
        end
        
        local shopModule = game:GetService("ReplicatedStorage"):FindFirstChild("TS"):FindFirstChild("games"):FindFirstChild("bedwars"):FindFirstChild("shop"):FindFirstChild("bedwars-shop")
        if shopModule and shopModule:IsA("ModuleScript") then
            return require(shopModule)
        end
        
        return nil
    end
    
    ShopTierBypass = vape.Categories.Utility:CreateModule({
        Name = 'ShopTierBypass',
        Function = function(callback)
            if callback then
                repeat task.wait() until store.shopLoaded or not ShopTierBypass.Enabled
                if ShopTierBypass.Enabled then
                    for _, v in pairs(bedwars.Shop.ShopItems) do
                        tiered[v] = v.tiered
                        nexttier[v] = v.nextTier
                        v.nextTier = nil
                        v.tiered = nil
                        shopItemsTracked[v] = true
                    end
                    
                    if bedwars.Shop.getShop and not originalGetShop then
                        originalGetShop = bedwars.Shop.getShop
                        bedwars.Shop.getShop = function(...)
                            local result = originalGetShop(...)
                            
                            if type(result) == "table" then
                                applyBypassToTable(result)
                            end
                            
                            return result
                        end
                    end
                    
                    local shopController = getShopController()
                    if shopController and shopController.BedwarsShop and shopController.BedwarsShop.getShop then
                        if not tiered["shopControllerHooked"] then
                            tiered["shopControllerHooked"] = true
                            local originalControllerGetShop = shopController.BedwarsShop.getShop
                            shopController.BedwarsShop.getShop = function(...)
                                local result = originalControllerGetShop(...)
                                if type(result) == "table" then
                                    applyBypassToTable(result)
                                end
                                return result
                            end
                        end
                    end
                end
            else
                for item, _ in pairs(shopItemsTracked) do
                    if item and type(item) == "table" then
                        if tiered[item] ~= nil then
                            item.tiered = tiered[item]
                        end
                        if nexttier[item] ~= nil then
                            item.nextTier = nexttier[item]
                        end
                    end
                end
                
                if tiered["shopControllerHooked"] then
                    local shopController = getShopController()
                    if shopController and shopController.BedwarsShop and shopController.BedwarsShop.getShop then
                    end
                    tiered["shopControllerHooked"] = nil
                end
                
                if originalGetShop then
                    bedwars.Shop.getShop = originalGetShop
                    originalGetShop = nil
                end
                
                table.clear(tiered)
                table.clear(nexttier)
                table.clear(shopItemsTracked)
            end
        end,
        Tooltip = 'Lets you buy things like armor and tools early.'
    })
end)


run(function()
	local StaffDetector
	local Mode
	local Clans
	local Party
	local Profile
	local Users
	local blacklistedclans = {'gg', 'gg2', 'DV', 'DV2'}
	local blacklisteduserids = {1502104539, 3826146717, 4531785383, 1049767300, 4926350670, 653085195, 184655415, 2752307430, 5087196317, 5744061325, 1536265275}
	local joined = {}
	
	local function getRole(plr, id)
		local suc, res = pcall(function()
			return plr:GetRankInGroup(id)
		end)
		if not suc then
			notif('StaffDetector', res, 30, 'alert')
		end
		return suc and res or 0
	end
	
	local function staffFunction(plr, checktype)
		if not vape.Loaded then
			repeat task.wait(0.1) until vape.Loaded
		end
	
		notif('StaffDetector', 'Staff Detected ('..checktype..'): '..plr.Name..' ('..plr.UserId..')', 60, 'alert')
		whitelist.customtags[plr.Name] = {{text = 'GAME STAFF', color = Color3.new(1, 0, 0)}}
	
		if Party.Enabled and not checktype:find('clan') then
			bedwars.PartyController:leaveParty()
		end
	
		if Mode.Value == 'Uninject' then
			task.spawn(function()
				vape:Uninject()
			end)
			game:GetService('StarterGui'):SetCore('SendNotification', {
				Title = 'StaffDetector',
				Text = 'Staff Detected ('..checktype..')\n'..plr.Name..' ('..plr.UserId..')',
				Duration = 60,
			})
		elseif Mode.Value == 'Requeue' then
			bedwars.QueueController:joinQueue(store.queueType)
		elseif Mode.Value == 'Profile' then
			vape.Save = function() end
			if vape.Profile ~= Profile.Value then
				vape:Load(true, Profile.Value)
			end
		elseif Mode.Value == 'AutoConfig' then
			local safe = {'AutoClicker', 'Reach', 'Sprint', 'HitFix', 'StaffDetector'}
			vape.Save = function() end
			for i, v in vape.Modules do
				if not (table.find(safe, i) or v.Category == 'Render') then
					if v.Enabled then
						v:Toggle()
					end
					v:SetBind('')
				end
			end
		end
	end
	
	local function checkFriends(list)
		for _, v in list do
			if joined[v] then
				return joined[v]
			end
		end
		return nil
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
	
			local friend = checkFriends(tab)
			if not friend then
				staffFunction(plr, 'impossible_join')
				return true
			else
				notif('StaffDetector', string.format('Spectator %s joined from %s', plr.Name, friend), 20, 'warning')
			end
		end
	end
	
	local function playerAdded(plr)
		joined[plr.UserId] = plr.Name
		if plr == lplr then return end
	
		if table.find(blacklisteduserids, plr.UserId) or table.find(Users.ListEnabled, tostring(plr.UserId)) then
			staffFunction(plr, 'blacklisted_user')
		elseif getRole(plr, 5774246) >= 100 then
			staffFunction(plr, 'staff_role')
		else
			local connection
			connection = plr:GetAttributeChangedSignal('Spectator'):Connect(function()
				checkJoin(plr, connection)
			end)
			StaffDetector:Clean(connection)
			if checkJoin(plr, connection) then
				return
			end
	
			if not plr:GetAttribute('ClanTag') then
				plr:GetAttributeChangedSignal('ClanTag'):Wait()
			end
	
			if table.find(blacklistedclans, plr:GetAttribute('ClanTag')) and vape.Loaded and Clans.Enabled then
				connection:Disconnect()
				staffFunction(plr, 'blacklisted_clan_'..plr:GetAttribute('ClanTag'):lower())
			end
		end
	end
	
	StaffDetector = vape.Categories.Utility:CreateModule({
		Name = 'StaffDetector',
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
		Tooltip = 'Detects people with a staff rank ingame'
	})
	Mode = StaffDetector:CreateDropdown({
		Name = 'Mode',
		List = {'Notify', 'Profile', 'Requeue', 'AutoConfig', 'Uninject'},
		Function = function(val)
			if Profile.Object then
				Profile.Object.Visible = val == 'Profile'
			end
		end
	})
	Clans = StaffDetector:CreateToggle({
		Name = 'Blacklist clans',
		Default = false
	})
	Party = StaffDetector:CreateToggle({
		Name = 'Leave party'
	})
	Profile = StaffDetector:CreateTextBox({
		Name = 'Profile',
		Default = 'default',
		Darker = true,
		Visible = false
	})
	Users = StaffDetector:CreateTextList({
		Name = 'Users',
		Placeholder = 'player (userid)'
	})
	

end)
	
run(function()
	TrapDisabler = vape.Categories.Utility:CreateModule({
		Name = 'TrapDisabler',
		Tooltip = 'Disables Snap Traps'
	})
end)
	
run(function()
	local afk
	local Customize
	local Custom = {
		MovementTick = nil,
		Jumps = nil,
		JumpTick = nil,
		Movement = {
			X = 0,
			Y = 0,
			Z = 0
		}
	}
	afk = vape.Categories.World:CreateModule({
			Name = 'Anti-AFK',
			Function = function(callback)
				if callback then
					if not Customize.Enabled then
						for _, v in getconnections(lplr.Idled) do
							v:Disconnect()
						end
			
						for _, v in getconnections(runService.Heartbeat) do
							if type(v.Function) == 'function' and table.find(debug.getconstants(v.Function), remotes.AfkStatus) then
								v:Disconnect()
							end
						end
			
						repeat 
							bedwars.Client:Get(remotes.AfkStatus):SendToServer({
								afk = false
							}) 
							task.wait(0.001)
						until not afk.Enabled
					else
						task.spawn(function()
							local target
							repeat
								Custom.Movement.X = math.random(1,5)
								Custom.Movement.Y = math.random(1,5)
								Custom.Movement.Z = math.random(1,5)
								target = CFrame.new(Custom.Movement.X,Custom.Movement.Y,Custom.Movement.Z)
								lplr.Character.Humanoid:MoveTo(target.Position)
								task.wait(1 / Custom.MovementTick.GetRandomValue())
							until not afk.Enabled
						end)
						task.spawn(function()
							repeat
								if Custom.Jumps.Enabled then
									entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								end
								task.wait(1 / Custom.JumpTick.GetRandomValue())
							until not afk.Enabled
						end)					
						task.spawn(function()
							for _, v in getconnections(lplr.Idled) do
								v:Disconnect()
							end
				
							for _, v in getconnections(runService.Heartbeat) do
								if type(v.Function) == 'function' and table.find(debug.getconstants(v.Function), remotes.AfkStatus) then
									v:Disconnect()
								end
							end
				
							repeat 
								bedwars.Client:Get(remotes.AfkStatus):SendToServer({
									afk = false
								}) 
								task.wait(0.001)
							until not afk.Enabled
						end)
					end
				end
			end,
			Tooltip = 'Lets you stay ingame without getting kicked'
	})
	Custom.MovementTick = afk:CreateTwoSlider({
		Name = 'Movement Tick',
		Visible = false,
		Min = 2,
		Max = 10,
		DefaultMin = 5,
		DefaultMax = 8,
	})
	Custom.JumpTick = afk:CreateTwoSlider({
		Name = 'Jump Tick',
		Visible = false,
		Min = 2,
		Max = 10,
		DefaultMin = 5,
		DefaultMax = 8,
	})
	Custom.Jumps = afk:CreateToggle({
		Name = 'Jump',
		Visible = false,
		Default = false,
		Function = function()
			Custom.JumpTick.Object.Visible = Custom.Jumps.Enabled
		end
	})
	Customize = afk:CreateToggle({
		Name = 'Customize',
		Default = false,
		Function = function()
			Custom.MovementTick.Enabled = Customize.Enabled
			Custom.Jumps.Enabled = Customize.Enabled
		end
	})

end)
	
run(function()
	local AutoSuffocate
	local Range
	local LimitItem
	local InstantSuffocate
	local SmartMode
	
	local function fixPosition(pos)
		return (bedwars.BlockController:getBlockPosition() * 3)
	end
	
	local function countSurroundingBlocks(pos)
		local count = 0
		for _, side in Enum.NormalId:GetEnumItems() do
			if side == Enum.NormalId.Top or side == Enum.NormalId.Bottom then continue end
			local checkPos = fixPosition(pos + Vector3.fromNormalId(side) * 2)
			if getPlacedBlock(checkPos) then
				count += 1
			end
		end
		return count
	end
	
	local function isInVoid(pos)
		for i = 1, 10 do
			local checkPos = fixPosition(pos - Vector3.new(0, i * 3, 0))
			if getPlacedBlock(checkPos) then
				return false
			end
		end
		return true
	end
	
	local function getSmartSuffocationBlocks(ent)
		local rootPos = ent.RootPart.Position
		local headPos = ent.Head.Position
		local needPlaced = {}
		local surroundingBlocks = countSurroundingBlocks(rootPos)
		local inVoid = isInVoid(rootPos)
		
		if surroundingBlocks >= 1 and surroundingBlocks <= 2 then
			for _, side in Enum.NormalId:GetEnumItems() do
				if side == Enum.NormalId.Top or side == Enum.NormalId.Bottom then continue end
				local sidePos = fixPosition(rootPos + Vector3.fromNormalId(side) * 2)
				if not getPlacedBlock(sidePos) then
					table.insert(needPlaced, sidePos)
				end
			end
			table.insert(needPlaced, fixPosition(headPos))
			table.insert(needPlaced, fixPosition(rootPos - Vector3.new(0, 3, 0)))
		
		elseif inVoid then
			table.insert(needPlaced, fixPosition(rootPos - Vector3.new(0, 3, 0)))
			table.insert(needPlaced, fixPosition(headPos + Vector3.new(0, 3, 0)))
			for _, side in Enum.NormalId:GetEnumItems() do
				if side == Enum.NormalId.Top or side == Enum.NormalId.Bottom then continue end
				local sidePos = fixPosition(rootPos + Vector3.fromNormalId(side) * 2)
				table.insert(needPlaced, sidePos)
			end
			table.insert(needPlaced, fixPosition(headPos))
		
		elseif surroundingBlocks == 3 then
			for _, side in Enum.NormalId:GetEnumItems() do
				if side == Enum.NormalId.Top or side == Enum.NormalId.Bottom then continue end
				local sidePos = fixPosition(rootPos + Vector3.fromNormalId(side) * 2)
				if not getPlacedBlock(sidePos) then
					table.insert(needPlaced, sidePos)
				end
			end
			table.insert(needPlaced, fixPosition(headPos))
			table.insert(needPlaced, fixPosition(rootPos - Vector3.new(0, 3, 0)))
		
		elseif surroundingBlocks >= 4 then
			table.insert(needPlaced, fixPosition(headPos))
			table.insert(needPlaced, fixPosition(rootPos - Vector3.new(0, 3, 0)))
		
		else
			table.insert(needPlaced, fixPosition(rootPos - Vector3.new(0, 3, 0)))
			for _, side in Enum.NormalId:GetEnumItems() do
				if side == Enum.NormalId.Top or side == Enum.NormalId.Bottom then continue end
				local sidePos = fixPosition(rootPos + Vector3.fromNormalId(side) * 2)
				table.insert(needPlaced, sidePos)
			end
			table.insert(needPlaced, fixPosition(headPos))
		end
		
		return needPlaced
	end
	
	local function getBasicSuffocationBlocks(ent)
		local needPlaced = {}
		
		for _, side in Enum.NormalId:GetEnumItems() do
			side = Vector3.fromNormalId(side)
			if side.Y ~= 0 then continue end
			
			side = fixPosition(ent.RootPart.Position + side * 2)
			if not getPlacedBlock(side) then
				table.insert(needPlaced, side)
			end
		end
		
		if #needPlaced < 3 then
			table.insert(needPlaced, fixPosition(ent.Head.Position))
			table.insert(needPlaced, fixPosition(ent.RootPart.Position - Vector3.new(0, 1, 0)))
		end
		
		return needPlaced
	end
	
	AutoSuffocate = vape.Categories.World:CreateModule({
		Name = 'AutoSuffocate',
		Function = function(callback)
			if callback then
				repeat
					local item = store.hand.toolType == 'block' and store.hand.tool.Name or not LimitItem.Enabled and getWool()
	
					if item then
						local plrs = entitylib.AllPosition({
							Part = 'RootPart',
							Range = Range.Value,
							Players = true
						})
	
						for _, ent in plrs do
							local needPlaced = SmartMode.Enabled and getSmartSuffocationBlocks(ent) or getBasicSuffocationBlocks(ent)
	
							if InstantSuffocate.Enabled then
								for _, pos in needPlaced do
									if not getPlacedBlock(pos) then
										task.spawn(bedwars.placeBlock, pos, item)
									end
								end
							else
								for _, pos in needPlaced do
									if not getPlacedBlock(pos) then
										task.spawn(bedwars.placeBlock, pos, item)
										break
									end
								end
							end
						end
					end
	
					task.wait(InstantSuffocate.Enabled and 0.05 or 0.09)
				until not AutoSuffocate.Enabled
			end
		end,
		Tooltip = 'Places blocks on nearby confined entities'
	})
	Range = AutoSuffocate:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 20,
		Default = 20,
		Function = function() end,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	SmartMode = AutoSuffocate:CreateToggle({
		Name = 'Smart Mode',
		Default = true,
	})
	LimitItem = AutoSuffocate:CreateToggle({
		Name = 'Limit to Items',
		Default = true,
	})
	InstantSuffocate = AutoSuffocate:CreateToggle({
		Name = 'Instant Suffocate',
	})
end)
	
run(function()

	local old, event
	
	local function switchHotbarItem(block)
		if block and not block:GetAttribute('NoBreak') and not block:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') then
			local tool, slot = store.tools[bedwars.ItemMeta[block.Name].block.breakType], nil
			if tool then
				for i, v in store.inventory.hotbar do
					if v.item and v.item.itemType == tool.itemType then slot = i - 1 break end
				end
	
				if hotbarSwitch(slot) then
					if inputService:IsMouseButtonPressed(0) then 
						event:Fire() 
					end
					return true
				end
			end
		end
	end

	AutoTool = vape.Categories.World:CreateModule({
		Name = 'AutoTool',
		Function = function(callback)
			if callback then
				event = Instance.new('BindableEvent')
				AutoTool:Clean(event)
				AutoTool:Clean(event.Event:Connect(function()
					contextActionService:CallFunction('block-break', Enum.UserInputState.Begin, newproxy(true))
				end))
				old = bedwars.BlockBreaker.hitBlock
				bedwars.BlockBreaker.hitBlock = function(self, maid, raycastparams, ...)
					local block = self.clientManager:getBlockSelector():getMouseInfo(1, {ray = raycastparams})
					if switchHotbarItem(block and block.target and block.target.blockInstance or nil) then return end
					return old(self, maid, raycastparams, ...)
				end
			else
				bedwars.BlockBreaker.hitBlock = old
				old = nil
			end
		end,
		Tooltip = 'Automatically selects the correct tool'
	})
end)
	
run(function()
    local BedProtector
	local Priority
	local Layers 
	local CPS 

	local BlockTypeCheck 
	local AutoSwitch 
	local HandCheck 
    
    local function getBedNear()
        local localPosition = entitylib.isAlive and entitylib.character.RootPart.Position or Vector3.zero
        for _, v in collectionService:GetTagged('bed') do
            if (localPosition - v.Position).Magnitude < 20 and v:GetAttribute('Team'..(lplr:GetAttribute('Team') or -1)..'NoBreak') then
                return v
            end
        end
    end

	local function isAllowed(block)
		if not BlockTypeCheck.Enabled then return true end
		local allowed = {"wool", "stone_brick", "wood_plank_oak", "ceramic", "obsidian"}
		for i,v in pairs(allowed) do
			if string.find(string.lower(tostring(block)), v) then 
				return true
			end
		end
		return false
	end

	local function getBlocks()
        local blocks = {}
		for _, item in store.inventory.inventory.items do
            local block = bedwars.ItemMeta[item.itemType].block
            if block and isAllowed(item.itemType) then
                table.insert(blocks, {itemType = item.itemType, health = block.health, tool = item.tool})
            end
        end

        local priorityMap = {}
        for i, v in pairs(Priority.ListEnabled) do
			local core = v:split("/")
            local blockType, layer = core[1], core[2]
            if blockType and layer then
                priorityMap[blockType] = tonumber(layer)
            end
        end

        local prioritizedBlocks = {}
        local fallbackBlocks = {}

        for _, block in pairs(blocks) do
			local prioLayer
			for i,v in pairs(priorityMap) do
				if string.find(string.lower(tostring(block.itemType)), string.lower(tostring(i))) then
					prioLayer = v
					break
				end
			end
            if prioLayer then
                table.insert(prioritizedBlocks, {itemType = block.itemType, health = block.health, layer = prioLayer, tool = block.tool})
            else
                table.insert(fallbackBlocks, {itemType = block.itemType, health = block.health, tool = block.tool})
            end
        end

        table.sort(prioritizedBlocks, function(a, b)
            return a.layer < b.layer
        end)

        table.sort(fallbackBlocks, function(a, b)
            return a.health > b.health
        end)

        local finalBlocks = {}
        for _, block in pairs(prioritizedBlocks) do
            table.insert(finalBlocks, {block.itemType, block.health})
        end
        for _, block in pairs(fallbackBlocks) do
            table.insert(finalBlocks, {block.itemType, block.health})
        end

        return finalBlocks
    end
    
    local function getPyramid(size, grid)
        local positions = {}
        for h = size, 0, -1 do
            for w = h, 0, -1 do
                table.insert(positions, Vector3.new(w, (size - h), ((h + 1) - w)) * grid)
                table.insert(positions, Vector3.new(w * -1, (size - h), ((h + 1) - w)) * grid)
                table.insert(positions, Vector3.new(w, (size - h), (h - w) * -1) * grid)
                table.insert(positions, Vector3.new(w * -1, (size - h), (h - w) * -1) * grid)
            end
        end
        return positions
    end

    local function tblClone(cltbl)
        local restbl = table.clone(cltbl)
        for i, v in pairs(cltbl) do
            table.insert(restbl, v)
        end
        return restbl
    end

    local function cleantbl(restbl, req)
        for i = #restbl, req + 1, -1 do
            table.remove(restbl, i)
        end
        return restbl
    end

    local res_attempts = 0
    
    local function buildProtection(bedPos, blocks, layers, cps)
        local delay = 1 / cps 
        local blockIndex = 1
        local posIndex = 1
        
        local function placeNextBlock()
            if not BedProtector.Enabled or blockIndex > layers then
                BedProtector:Toggle()
                return
            end

            local block = blocks[blockIndex]
            if not block then
                BedProtector:Toggle()
                return
            end

			if AutoSwitch.Enabled then
				switchItem(block.tool)
			end

            local positions = getPyramid(blockIndex - 1, 3) 
            if posIndex > #positions then
                blockIndex = blockIndex + 1
                posIndex = 1
                task.delay(delay, placeNextBlock)
                return
            end

            local pos = positions[posIndex]
            if not getPlacedBlock(bedPos + pos) then
                bedwars.placeBlock(bedPos + pos, block[1], false)
            end
            
            posIndex = posIndex + 1
            task.delay(delay, placeNextBlock)
        end
        
        placeNextBlock()
    end
    
	BedProtector = vape.Categories.World:CreateModule({
        Name = 'BedProtector',
        Function = function(callback)
            if callback then
                local bed = getBedNear()
                local bedPos = bed and bed.Position
                if bedPos then

					if HandCheck.Enabled and not AutoSwitch.Enabled then
						if not (store.hand and store.hand.toolType == "block") then
							BedProtector:Toggle(false)
							return
						end
					end

                    local blocks = getBlocks()                    
                    if #blocks < Layers.Value then
                        repeat 
                            blocks = tblClone(blocks)
                            blocks = cleantbl(blocks, Layers.Value)
                            task.wait()
                            res_attempts = res_attempts + 1
                        until #blocks == Layers.Value or res_attempts > (Layers.Value < 10 and Layers.Value or 10)
                    elseif #blocks > Layers.Value then
                        blocks = cleantbl(blocks, Layers.Value)
                    end
                    res_attempts = 0
                    
                    buildProtection(bedPos, blocks, Layers.Value, CPS.Value)
                else
                    notif('BedProtector', 'Please get closer to your bed!', 5)
                    BedProtector:Toggle()
                end
            else
                res_attempts = 0
            end
        end,
        Tooltip = 'Automatically places strong blocks around the bed with customizable speed.'
    })

    Layers = BedProtector:CreateSlider({
        Name = "Layers",
        Function = function() end,
        Min = 1,
        Max = 10,
        Default = 2,
    	Tooltip = "Number of protective layers around the bed"
    })

    CPS = BedProtector:CreateSlider({
        Name = "CPS",
        Function = function() end,
        Min = 5,
        Max = 50,
        Default = 50,
       	Tooltip = "Blocks placed per second"
    })

	AutoSwitch = BedProtector:CreateToggle({
		Name = "Auto Switch",
		Function = function() end,
		Default = true
	})

	HandCheck = BedProtector:CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})

	BlockTypeCheck = BedProtector:CreateToggle({
		Name = "Block Type Check",
		Function = function() end,
		Default = true
	})

	Priority = BedProtector:CreateTextList({
		Name = "Block/Layer",
		Function = function() end,
		TempText = "block/layer",
		SortFunction = function(a, b)
			local layer1 = a:split("/")
			local layer2 = b:split("/")
			layer1 = #layer1 and tonumber(layer1[2]) or 1
			layer2 = #layer2 and tonumber(layer2[2]) or 1
			return layer1 < layer2
		end
	})
end)
	
run(function()
	local ChestSteal
	local Range
	local Open
	local Skywars
	local Delay
	local Delays = {}
	local AnimPlayer
	local function lootChest(chest)
		chest = chest and chest.Value or nil
		local chestitems = chest and chest:GetChildren() or {}
		if #chestitems > 1 and (Delays[chest] or 0) < tick() then
			Delays[chest] = tick() + (Delay.Value)
			if AnimPlayer.Enabled then bedwars.ChestController.playChestOpenAnimation(chest) end
			bedwars.Client:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(chest)
	
			for _, v in chestitems do
				if v:IsA('Accessory') then
					task.spawn(function()
						pcall(function()
							bedwars.Client:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest, v)
						end)
					end)
				end
			end
	
			bedwars.Client:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(nil)
		end
	end

	ChestSteal = vape.Categories.World:CreateModule({
		Name = 'ChestSteal',
		Function = function(callback)
			if callback then
				local chests = collection('chest', ChestSteal)
				repeat task.wait(0.1) until store.queueType ~= 'bedwars_test'
				if (not Skywars.Enabled) or store.queueType:find('skywars') then
					repeat
						if entitylib.isAlive and store.matchState ~= 2 then
							if Open.Enabled then
								if bedwars.AppController:isAppOpen('ChestApp') then
									lootChest(lplr.Character:FindFirstChild('ObservedChestFolder'))
								end
							else
								local localPosition = entitylib.character.RootPart.Position
								for _, v in chests do
									if (localPosition - v.Position).Magnitude <= Range.Value then
										lootChest(v:FindFirstChild('ChestFolderValue'))
									end
								end
							end
						end
						task.wait(0.1)
					until not ChestSteal.Enabled
				end
			end
		end,
		Tooltip = 'Grabs items from near chests.'
	})
	Range = ChestSteal:CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 18,
		Default = 18,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	Delay = ChestSteal:CreateSlider({
		Name = 'Delay',
		Min = 0.05,
		Max = 1,
		Default = 0.2,
		Decimal = 100,
		Suffix = 's'
	})
	AnimPlayer = ChestSteal:CreateToggle({Name = 'Animation Player'})
	Open = ChestSteal:CreateToggle({Name = 'GUI Check'})
	Skywars = ChestSteal:CreateToggle({
		Name = 'Only Skywars',
		Function = function()
			if ChestSteal.Enabled then
				ChestSteal:Toggle()
				ChestSteal:Toggle()
			end
		end,
		Default = false
	})
end)
	
run(function()
	local Schematica
	local File
	local Mode
	local Transparency
	local parts, guidata, poschecklist = {}, {}, {}
	local point1, point2
	
	for x = -3, 3, 3 do
		for y = -3, 3, 3 do
			for z = -3, 3, 3 do
				if Vector3.new(x, y, z) ~= Vector3.zero then
					table.insert(poschecklist, Vector3.new(x, y, z))
				end
			end
		end
	end
	
	local function checkAdjacent(pos)
		for _, v in poschecklist do
			if getPlacedBlock(pos + v) then return true end
		end
		return false
	end
	
	local function getPlacedBlocksInPoints(s, e)
		local list, blocks = {}, bedwars.BlockController:getStore()
		for x = (e.X > s.X and s.X or e.X), (e.X > s.X and e.X or s.X) do
			for y = (e.Y > s.Y and s.Y or e.Y), (e.Y > s.Y and e.Y or s.Y) do
				for z = (e.Z > s.Z and s.Z or e.Z), (e.Z > s.Z and e.Z or s.Z) do
					local vec = Vector3.new(x, y, z)
					local block = blocks:getBlockAt(vec)
					if block and block:GetAttribute('PlacedByUserId') == lplr.UserId then
						list[vec] = block
					end
				end
			end
		end
		return list
	end
	
	local function loadMaterials()
		for _, v in guidata do 
			v:Destroy() 
		end
		local suc, read = pcall(function() 
			return isfile(File.Value) and httpService:JSONDecode(readfile(File.Value)) 
		end)
	
		if suc and read then
			local items = {}
			for _, v in read do 
				items[v[2]] = (items[v[2]] or 0) + 1 
			end
			
			for i, v in items do
				local holder = Instance.new('Frame')
				holder.Size = UDim2.new(1, 0, 0, 32)
				holder.BackgroundTransparency = 1
				holder.Parent = Schematica.Children
				local icon = Instance.new('ImageLabel')
				icon.Size = UDim2.fromOffset(24, 24)
				icon.Position = UDim2.fromOffset(4, 4)
				icon.BackgroundTransparency = 1
				icon.Image = bedwars.getIcon({itemType = i}, true)
				icon.Parent = holder
				local text = Instance.new('TextLabel')
				text.Size = UDim2.fromOffset(100, 32)
				text.Position = UDim2.fromOffset(32, 0)
				text.BackgroundTransparency = 1
				text.Text = (bedwars.ItemMeta[i] and bedwars.ItemMeta[i].displayName or i)..': '..v
				text.TextXAlignment = Enum.TextXAlignment.Left
				text.TextColor3 = uipallet.Text
				text.TextSize = 14
				text.FontFace = uipallet.Font
				text.Parent = holder
				table.insert(guidata, holder)
			end
			table.clear(read)
			table.clear(items)
		end
	end
	
	local function save()
		if point1 and point2 then
			local tab = getPlacedBlocksInPoints(point1, point2)
			local savetab = {}
			point1 = point1 * 3
			for i, v in tab do
				i = bedwars.BlockController:getBlockPosition(CFrame.lookAlong(point1, entitylib.character.RootPart.CFrame.LookVector):PointToObjectSpace(i * 3)) * 3
				table.insert(savetab, {
					{
						x = i.X, 
						y = i.Y, 
						z = i.Z
					}, 
					v.Name
				})
			end
			point1, point2 = nil, nil
			writefile(File.Value, httpService:JSONEncode(savetab))
			notif('Schematica', 'Saved '..getTableSize(tab)..' blocks', 5)
			loadMaterials()
			table.clear(tab)
			table.clear(savetab)
		else
			local mouseinfo = bedwars.BlockBreaker.clientManager:getBlockSelector():getMouseInfo(0)
			if mouseinfo and mouseinfo.target then
				if point1 then
					point2 = mouseinfo.target.blockRef.blockPosition
					notif('Schematica', 'Selected position 2, toggle again near position 1 to save it', 3)
				else
					point1 = mouseinfo.target.blockRef.blockPosition
					notif('Schematica', 'Selected position 1', 3)
				end
			end
		end
	end
	
	local function load(read)
		local mouseinfo = bedwars.BlockBreaker.clientManager:getBlockSelector():getMouseInfo(0)
		if mouseinfo and mouseinfo.target then
			local position = CFrame.new(mouseinfo.placementPosition * 3) * CFrame.Angles(0, math.rad(math.round(math.deg(math.atan2(-entitylib.character.RootPart.CFrame.LookVector.X, -entitylib.character.RootPart.CFrame.LookVector.Z)) / 45) * 45), 0)
	
			for _, v in read do
				local blockpos = bedwars.BlockController:getBlockPosition((position * CFrame.new(v[1].x, v[1].y, v[1].z)).p) * 3
				if parts[blockpos] then continue end
				local handler = bedwars.BlockController:getHandlerRegistry():getHandler(v[2]:find('wool') and getWool() or v[2])
				if handler then
					local part = handler:place(blockpos / 3, 0)
					part.Transparency = Transparency.Value
					part.CanCollide = false
					part.Anchored = true
					part.Parent = workspace
					parts[blockpos] = part
				end
			end
			table.clear(read)
	
			repeat
				if entitylib.isAlive then
					local localPosition = entitylib.character.RootPart.Position
					for i, v in parts do
						if (i - localPosition).Magnitude < 60 and checkAdjacent(i) then
							if not Schematica.Enabled then break end
							if not getItem(v.Name) then continue end
							bedwars.placeBlock(i, v.Name, false)
							task.delay(0.1, function()
								local block = getPlacedBlock(i)
								if block then
									v:Destroy()
									parts[i] = nil
								end
							end)
						end
					end
				end
				task.wait(0.1)
			until getTableSize(parts) <= 0
	
			if getTableSize(parts) <= 0 and Schematica.Enabled then
				notif('Schematica', 'Finished building', 5)
				Schematica:Toggle()
			end
		end
	end
	
	Schematica = vape.Categories.Legit:CreateModule({
		Name = 'Schematica',
		Function = function(callback)
			if callback then
				if not File.Value:find('.json') then
					notif('Schematica', 'Invalid file', 3)
					Schematica:Toggle()
					return
				end
	
				if Mode.Value == 'Save' then
					save()
					Schematica:Toggle()
				else
					local suc, read = pcall(function() 
						return isfile(File.Value) and httpService:JSONDecode(readfile(File.Value)) 
					end)
	
					if suc and read then
						load(read)
					else
						notif('Schematica', 'Missing / corrupted file', 3)
						Schematica:Toggle()
					end
				end
			else
				for _, v in parts do 
					v:Destroy() 
				end
				table.clear(parts)
			end
		end,
		Tooltip = 'Save and load placements of buildings'
	})
	File = Schematica:CreateTextBox({
		Name = 'File',
		Function = function()
			loadMaterials()
			point1, point2 = nil, nil
		end
	})
	Mode = Schematica:CreateDropdown({
		Name = 'Mode',
		List = {'Load', 'Save'}
	})
	Transparency = Schematica:CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 1,
		Default = 0.7,
		Decimal = 10,
		Function = function(val)
			for _, v in parts do 
				v.Transparency = val 
			end
		end
	})
end)
	
run(function()
	local ArmorSwitch
	local Mode
	local Targets
	local Range
	
	ArmorSwitch = vape.Categories.Inventory:CreateModule({
		Name = 'ArmorSwitch',
		Function = function(callback)
			if callback then
				if Mode.Value == 'Toggle' then
					repeat
						local state = entitylib.EntityPosition({
							Part = 'RootPart',
							Range = Range.Value,
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Wallcheck = Targets.Walls.Enabled
						}) and true or false
	
						for i = 0, 2 do
							if (store.inventory.inventory.armor[i + 1] ~= 'empty') ~= state and ArmorSwitch.Enabled then
								bedwars.Store:dispatch({
									type = 'InventorySetArmorItem',
									item = store.inventory.inventory.armor[i + 1] == 'empty' and state and getBestArmor(i) or nil,
									armorSlot = i
								})
								vapeEvents.InventoryChanged.Event:Wait()
							end
						end
						task.wait(0.1)
					until not ArmorSwitch.Enabled
				else
					ArmorSwitch:Toggle()
					for i = 0, 2 do
						bedwars.Store:dispatch({
							type = 'InventorySetArmorItem',
							item = store.inventory.inventory.armor[i + 1] == 'empty' and getBestArmor(i) or nil,
							armorSlot = i
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
				end
			end
		end,
		Tooltip = 'Puts on / takes off armor when toggled for baiting.'
	})
	Mode = ArmorSwitch:CreateDropdown({
		Name = 'Mode',
		List = {'Toggle', 'On Key'}
	})
	Targets = ArmorSwitch:CreateTargets({
		Players = true,
		NPCs = true
	})
	Range = ArmorSwitch:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 30,
		Default = 30,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)
	
run(function()
	local AutoBank
	local UIToggle
	local UI
	local Chests
	local Items = {}
	
	local function addItem(itemType, shop)
		local item = Instance.new('ImageLabel')
		item.Image = bedwars.getIcon({itemType = itemType}, true)
		item.Size = UDim2.fromOffset(32, 32)
		item.Name = itemType
		item.BackgroundTransparency = 1
		item.LayoutOrder = #UI:GetChildren() + 99
		item.Parent = UI
		local itemtext = Instance.new('TextLabel')
		itemtext.Name = 'Amount'
		itemtext.Size = UDim2.fromScale(1, 1)
		itemtext.BackgroundTransparency = 1
		itemtext.Text = ''
		itemtext.TextColor3 = Color3.new(1, 1, 1)
		itemtext.TextSize = 16
		itemtext.TextStrokeTransparency = 0.3
		itemtext.Font = Enum.Font.Arial
		itemtext.Parent = item
		Items[itemType] = {Object = itemtext, Type = shop}
	end
	
	local function refreshBank(echest)
		for i, v in Items do
			local item = echest:FindFirstChild(i)
			v.Object.Text = item and item:GetAttribute('Amount') or ''
		end
	end
	
	local function nearChest()
		if entitylib.isAlive then
			local pos = entitylib.character.RootPart.Position
			for _, chest in Chests do
				if (chest.Position - pos).Magnitude < 20 then
					return true
				end
			end
		end
	end
	
	local function handleState()
		local chest = replicatedStorage.Inventories:FindFirstChild(lplr.Name..'_personal')
		if not chest then return end
	
		local mapCF = workspace.MapCFrames:FindFirstChild((lplr:GetAttribute('Team') or 1)..'_spawn')
		if mapCF and (entitylib.character.RootPart.Position - mapCF.Value.Position).Magnitude < 80 then
			for _, v in chest:GetChildren() do
				local item = Items[v.Name]
				if item then
					task.spawn(function()
						bedwars.Client:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest, v)
						refreshBank(chest)
					end)
				end
			end
		else
			for _, v in store.inventory.inventory.items do
				local item = Items[v.itemType]
				if item then
					task.spawn(function()
						bedwars.Client:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(chest, v.tool)
						refreshBank(chest)
					end)
				end
			end
		end
	end
	
	AutoBank = vape.Categories.Inventory:CreateModule({
		Name = 'AutoBank',
		Function = function(callback)
			if callback then
				Chests = collection('personal-chest', AutoBank)
				UI = Instance.new('Frame')
				UI.Size = UDim2.new(1, 0, 0, 32)
				UI.Position = UDim2.fromOffset(0, -240)
				UI.BackgroundTransparency = 1
				UI.Visible = UIToggle.Enabled
				UI.Parent = vape.gui
				AutoBank:Clean(UI)
				local Sort = Instance.new('UIListLayout')
				Sort.FillDirection = Enum.FillDirection.Horizontal
				Sort.HorizontalAlignment = Enum.HorizontalAlignment.Center
				Sort.SortOrder = Enum.SortOrder.LayoutOrder
				Sort.Parent = UI
				addItem('iron', true)
				addItem('gold', true)
				addItem('diamond', false)
				addItem('emerald', true)
				addItem('void_crystal', true)
	
				repeat
					local hotbar = lplr.PlayerGui:FindFirstChild('hotbar')
					hotbar = hotbar and hotbar['1']:FindFirstChild('HotbarHealthbarContainer')
					if hotbar then
						UI.Position = UDim2.fromOffset(0, (hotbar.AbsolutePosition.Y + guiService:GetGuiInset().Y) - 40)
					end
	
					local newState = nearChest()
					if newState then
						handleState()
					end
	
					task.wait(0.1)
				until (not AutoBank.Enabled)
			else
				table.clear(Items)
			end
		end,
		Tooltip = 'Automatically puts resources in ender chest'
	})
	UIToggle = AutoBank:CreateToggle({
		Name = 'UI',
		Function = function(callback)
			if AutoBank.Enabled then
				UI.Visible = callback
			end
		end,
		Default = true
	})
end)
	
run(function()
	local AutoBuy
	local Sword
	local Armor
	local Upgrades
	local TierCheck
	local BedwarsCheck
	local GUI
	local SmartCheck
	local Custom = {}
	local CustomPost = {}
	local UpgradeToggles = {}
	local Functions, id = {}
	local Callbacks = {Custom, Functions, CustomPost}
	local npctick = tick()
	local swords = {
		'wood_sword',
		'stone_sword',
		'iron_sword',
		'diamond_sword',
		'emerald_sword'
	}
	
	local armors = {
		'none',
		'leather_chestplate',
		'iron_chestplate',
		'diamond_chestplate',
		'emerald_chestplate'
	}
	
	local axes = {
		'none',
		'wood_axe',
		'stone_axe',
		'iron_axe',
		'diamond_axe'
	}
	
	local pickaxes = {
		'none',
		'wood_pickaxe',
		'stone_pickaxe',
		'iron_pickaxe',
		'diamond_pickaxe'
	}
	
	local function getShopNPC()
		local shop, items, upgrades, newid = nil, false, false, nil
		if entitylib.isAlive then
			local localPosition = entitylib.character.RootPart.Position
			for _, v in store.shop do
				if (v.RootPart.Position - localPosition).Magnitude <= 20 then
					shop = v.Upgrades or v.Shop or nil
					upgrades = upgrades or v.Upgrades
					items = items or v.Shop
					newid = v.Shop and v.Id or newid
				end
			end
		end
		return shop, items, upgrades, newid
	end
	
	local function canBuy(item, currencytable, amount)
		amount = amount or 1
		if not currencytable[item.currency] then
			local currency = getItem(item.currency)
			currencytable[item.currency] = currency and currency.amount or 0
		end
		if item.ignoredByKit and table.find(item.ignoredByKit, store.equippedKit or '') then return false end
		if item.lockedByForge or item.disabled then return false end
		if item.require and item.require.teamUpgrade then
			if (bedwars.Store:getState().Bedwars.teamUpgrades[item.require.teamUpgrade.upgradeId] or -1) < item.require.teamUpgrade.lowestTierIndex then
				return false
			end
		end
		return currencytable[item.currency] >= (item.price * amount)
	end
	
	local function buyItem(item, currencytable)
		if not id then return end
		notif('AutoBuy', 'Bought '..bedwars.ItemMeta[item.itemType].displayName, 3)
		bedwars.Client:Get('BedwarsPurchaseItem'):CallServerAsync({
			shopItem = item,
			shopId = id
		}):andThen(function(suc)
			if suc then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.Store:dispatch({
					type = 'BedwarsAddItemPurchased',
					itemType = item.itemType
				})
				bedwars.BedwarsShopController.alreadyPurchasedMap[item.itemType] = true
			end
		end)
		currencytable[item.currency] -= item.price
	end
	
	local function buyUpgrade(upgradeType, currencytable)

		return
	end
	
	local function buyTool(tool, tools, currencytable)
		local bought, buyable = false
		tool = tool and table.find(tools, tool.itemType) and table.find(tools, tool.itemType) + 1 or math.huge
	
		for i = tool, #tools do
			local v = bedwars.Shop.getShopItem(tools[i], lplr)
			if canBuy(v, currencytable) then
				if SmartCheck.Enabled and bedwars.ItemMeta[tools[i]].breakBlock and i > 2 then
					if Armor.Enabled then
						local currentarmor = store.inventory.inventory.armor[2]
						currentarmor = currentarmor and currentarmor ~= 'empty' and currentarmor.itemType or 'none'
						if (table.find(armors, currentarmor) or 3) < 3 then break end
					end
					if Sword.Enabled then
						if store.tools.sword and (table.find(swords, store.tools.sword.itemType) or 2) < 2 then break end
					end
				end
				bought = true
				buyable = v
			end
			if TierCheck.Enabled and v.nextTier then break end
		end
	
		if buyable then
			buyItem(buyable, currencytable)
		end
	
		return bought
	end
	
	AutoBuy = vape.Categories.Inventory:CreateModule({
		Name = 'AutoBuy',
		Function = function(callback)
			if callback then
				repeat task.wait(0.1) until store.queueType ~= 'bedwars_test'
				if BedwarsCheck.Enabled and not store.queueType:find('bedwars') then return end
	
				local lastupgrades
				AutoBuy:Clean(vapeEvents.InventoryAmountChanged.Event:Connect(function()
					if (npctick - tick()) > 1 then npctick = tick() end
				end))
	
				repeat
					local npc, shop, upgrades, newid = getShopNPC()
					id = newid
					if GUI.Enabled then
						if not (bedwars.AppController:isAppOpen('BedwarsItemShopApp') or bedwars.AppController:isAppOpen('TeamUpgradeApp')) then
							npc = nil
						end
					end
	
					if npc and lastupgrades ~= upgrades then
						if (npctick - tick()) > 1 then npctick = tick() end
						lastupgrades = upgrades
					end
	
					if npc and npctick <= tick() and store.matchState ~= 2 and store.shopLoaded then
						local currencytable = {}
						local waitcheck
						for _, tab in Callbacks do
							for _, callback in tab do
								if callback(currencytable, shop, upgrades) then
									waitcheck = true
								end
							end
						end
						npctick = tick() + (waitcheck and 0.4 or math.huge)
					end
	
					task.wait(0.1)
				until not AutoBuy.Enabled
			else
				npctick = tick()
			end
		end,
		Tooltip = 'Automatically buys items when you go near the shop'
	})
	Sword = AutoBuy:CreateToggle({
		Name = 'Buy Sword',
		Function = function(callback)
			npctick = tick()
			Functions[2] = callback and function(currencytable, shop)
				if not shop then return end
	
				if store.equippedKit == 'dasher' then
					swords = {
						[1] = 'wood_dao',
						[2] = 'stone_dao',
						[3] = 'iron_dao',
						[4] = 'diamond_dao',
						[5] = 'emerald_dao'
					}
				elseif store.equippedKit == 'ice_queen' then
					swords[5] = 'ice_sword'
				elseif store.equippedKit == 'ember' then
					swords[5] = 'infernal_saber'
				elseif store.equippedKit == 'lumen' then
					swords[5] = 'light_sword'
				end
	
				return buyTool(store.tools.sword, swords, currencytable)
			end or nil
		end
	})
	Armor = AutoBuy:CreateToggle({
		Name = 'Buy Armor',
		Function = function(callback)
			npctick = tick()
			Functions[1] = callback and function(currencytable, shop)
				if not shop then return end
				local currentarmor = store.inventory.inventory.armor[2] ~= 'empty' and store.inventory.inventory.armor[2] or getBestArmor(1)
				currentarmor = currentarmor and currentarmor.itemType or 'none'
				return buyTool({itemType = currentarmor}, armors, currencytable)
			end or nil
		end,
		Default = true
	})
	AutoBuy:CreateToggle({
		Name = 'Buy Axe',
		Function = function(callback)
			npctick = tick()
			Functions[3] = callback and function(currencytable, shop)
				if not shop then return end
				return buyTool(store.tools.wood or {itemType = 'none'}, axes, currencytable)
			end or nil
		end
	})
	AutoBuy:CreateToggle({
		Name = 'Buy Pickaxe',
		Function = function(callback)
			npctick = tick()
			Functions[4] = callback and function(currencytable, shop)
				if not shop then return end
				return buyTool(store.tools.stone, pickaxes, currencytable)
			end or nil
		end
	})
	local count = 0
	for i, v in bedwars.TeamUpgradeMeta do
		local toggleCount = count
		table.insert(UpgradeToggles, AutoBuy:CreateToggle({
			Name = 'Buy '..(v.name == 'Armor' and 'Protection' or v.name),
			Function = function(callback)
				npctick = tick()
				Functions[5 + toggleCount + (v.name == 'Armor' and 20 or 0)] = callback and function(currencytable, shop, upgrades)
					if not upgrades then return end
					if v.disabledInQueue and table.find(v.disabledInQueue, store.queueType) then return end
					return buyUpgrade(i, currencytable)
				end or nil
			end,
			Darker = true,
			Default = (i == 'ARMOR' or i == 'DAMAGE')
		}))
		count += 1
	end
	TierCheck = AutoBuy:CreateToggle({Name = 'Tier Check'})
	BedwarsCheck = AutoBuy:CreateToggle({
		Name = 'Only Bedwars',
		Function = function()
			if AutoBuy.Enabled then
				AutoBuy:Toggle()
				AutoBuy:Toggle()
			end
		end,
		Default = true
	})
	GUI = AutoBuy:CreateToggle({Name = 'GUI check'})
	SmartCheck = AutoBuy:CreateToggle({
		Name = 'Smart check',
		Default = true,
		Tooltip = 'Buys iron armor before iron axe'
	})
	AutoBuy:CreateTextList({
		Name = 'Item',
		Placeholder = 'priority/item/amount/after',
		Function = function(list)
			table.clear(Custom)
			table.clear(CustomPost)
			for _, entry in list do
				local tab = entry:split('/')
				local ind = tonumber(tab[1])
				if ind then
					(tab[4] and CustomPost or Custom)[ind] = function(currencytable, shop)
						if not shop then return end
	
						local v = bedwars.Shop.getShopItem(tab[2], lplr)
						if v then
							local item = getItem(tab[2] == 'wool_white' and bedwars.Shop.getTeamWool(lplr:GetAttribute('Team')) or tab[2])
							item = (item and tonumber(tab[3]) - item.amount or tonumber(tab[3])) // v.amount
							if item > 0 and canBuy(v, currencytable, item) then
								for _ = 1, item do
									buyItem(v, currencytable)
								end
								return true
							end
						end
					end
				end
			end
		end
	})
end)
	
run(function()
	local AutoConsume
	local Health
	local SpeedPotion
	local Apple
	local ShieldPotion
	
	local function consumeCheck(attribute)
		if entitylib.isAlive then
			if SpeedPotion.Enabled and (not attribute or attribute == 'StatusEffect_speed') then
				local speedpotion = getItem('speed_potion')
				if speedpotion and (not lplr.Character:GetAttribute('StatusEffect_speed')) then
					for _ = 1, 4 do
						if bedwars.Client:Get(remotes.ConsumeItem):CallServer({item = speedpotion.tool}) then break end
					end
				end
			end
	
			if Apple.Enabled and (not attribute or attribute:find('Health')) then
				if (lplr.Character:GetAttribute('Health') / lplr.Character:GetAttribute('MaxHealth')) <= (Health.Value / 100) then
					local apple = getItem('orange') or (not lplr.Character:GetAttribute('StatusEffect_golden_apple') and getItem('golden_apple')) or getItem('apple')
					
					if apple then
						bedwars.Client:Get(remotes.ConsumeItem):CallServerAsync({
							item = apple.tool
						})
					end
				end
			end
	
			if ShieldPotion.Enabled and (not attribute or attribute:find('Shield')) then
				if (lplr.Character:GetAttribute('Shield_POTION') or 0) == 0 then
					local shield = getItem('big_shield') or getItem('mini_shield')
	
					if shield then
						bedwars.Client:Get(remotes.ConsumeItem):CallServerAsync({
							item = shield.tool
						})
					end
				end
			end
		end
	end
	
	AutoConsume = vape.Categories.Inventory:CreateModule({
		Name = 'AutoConsume',
		Function = function(callback)
			if callback then
				AutoConsume:Clean(vapeEvents.InventoryAmountChanged.Event:Connect(consumeCheck))
				AutoConsume:Clean(vapeEvents.AttributeChanged.Event:Connect(function(attribute)
					if attribute:find('Shield') or attribute:find('Health') or attribute == 'StatusEffect_speed' then
						consumeCheck(attribute)
					end
				end))
				consumeCheck()
			end
		end,
		Tooltip = 'Automatically heals for you when health or shield is under threshold.'
	})
	Health = AutoConsume:CreateSlider({
		Name = 'Health Percent',
		Min = 1,
		Max = 99,
		Default = 70,
		Suffix = '%'
	})
	SpeedPotion = AutoConsume:CreateToggle({
		Name = 'Speed Potions',
		Default = true
	})
	Apple = AutoConsume:CreateToggle({
		Name = 'Apple',
		Default = true
	})
	ShieldPotion = AutoConsume:CreateToggle({
		Name = 'Shield Potions',
		Default = true
	})
end)
	
run(function()
	local AutoHotbar
	local Mode
	local Clear
	local List
	local Active
	
	local function CreateWindow(self)
		local selectedslot = 1
		local window = Instance.new('Frame')
		window.Name = 'HotbarGUI'
		window.Size = UDim2.fromOffset(660, 465)
		window.Position = UDim2.fromScale(0.5, 0.5)
		window.BackgroundColor3 = uipallet.Main
		window.AnchorPoint = Vector2.new(0.5, 0.5)
		window.Visible = false
		window.Parent = vape.gui.ScaledGui
		local title = Instance.new('TextLabel')
		title.Name = 'Title'
		title.Size = UDim2.new(1, -10, 0, 20)
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 12)
		title.BackgroundTransparency = 1
		title.Text = 'AutoHotbar'
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = uipallet.Text
		title.TextSize = 13
		title.FontFace = uipallet.Font
		title.Parent = window
		local divider = Instance.new('Frame')
		divider.Name = 'Divider'
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Position = UDim2.fromOffset(0, 40)
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.04)
		divider.BorderSizePixel = 0
		divider.Parent = window
		addBlur(window)
		local modal = Instance.new('TextButton')
		modal.Text = ''
		modal.BackgroundTransparency = 1
		modal.Modal = true
		modal.Parent = window
		local corner = Instance.new('UICorner')
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = window
		local close = Instance.new('ImageButton')
		close.Name = 'Close'
		close.Size = UDim2.fromOffset(24, 24)
		close.Position = UDim2.new(1, -35, 0, 9)
		close.BackgroundColor3 = Color3.new(1, 1, 1)
		close.BackgroundTransparency = 1
		close.Image = getcustomasset('ReVape/assets/new/close.png')
		close.ImageColor3 = color.Light(uipallet.Text, 0.2)
		close.ImageTransparency = 0.5
		close.AutoButtonColor = false
		close.Parent = window
		close.MouseEnter:Connect(function()
			close.ImageTransparency = 0.3
			tween:Tween(close, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.6
			})
		end)
		close.MouseLeave:Connect(function()
			close.ImageTransparency = 0.5
			tween:Tween(close, TweenInfo.new(0.2), {
				BackgroundTransparency = 1
			})
		end)
		close.MouseButton1Click:Connect(function()
			window.Visible = false
			vape.gui.ScaledGui.ClickGui.Visible = true
		end)
		local closecorner = Instance.new('UICorner')
		closecorner.CornerRadius = UDim.new(1, 0)
		closecorner.Parent = close
		local bigslot = Instance.new('Frame')
		bigslot.Size = UDim2.fromOffset(110, 111)
		bigslot.Position = UDim2.fromOffset(11, 71)
		bigslot.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		bigslot.Parent = window
		local bigslotcorner = Instance.new('UICorner')
		bigslotcorner.CornerRadius = UDim.new(0, 4)
		bigslotcorner.Parent = bigslot
		local bigslotstroke = Instance.new('UIStroke')
		bigslotstroke.Color = color.Light(uipallet.Main, 0.034)
		bigslotstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bigslotstroke.Parent = bigslot
		local slotnum = Instance.new('TextLabel')
		slotnum.Size = UDim2.fromOffset(80, 20)
		slotnum.Position = UDim2.fromOffset(25, 200)
		slotnum.BackgroundTransparency = 1
		slotnum.Text = 'SLOT 1'
		slotnum.TextColor3 = color.Dark(uipallet.Text, 0.1)
		slotnum.TextSize = 12
		slotnum.FontFace = uipallet.Font
		slotnum.Parent = window
		for i = 1, 9 do
			local slotbkg = Instance.new('TextButton')
			slotbkg.Name = 'Slot'..i
			slotbkg.Size = UDim2.fromOffset(51, 52)
			slotbkg.Position = UDim2.fromOffset(89 + (i * 55), 382)
			slotbkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
			slotbkg.Text = ''
			slotbkg.AutoButtonColor = false
			slotbkg.Parent = window
			local slotimage = Instance.new('ImageLabel')
			slotimage.Size = UDim2.fromOffset(32, 32)
			slotimage.Position = UDim2.new(0.5, -16, 0.5, -16)
			slotimage.BackgroundTransparency = 1
			slotimage.Image = ''
			slotimage.Parent = slotbkg
			local slotcorner = Instance.new('UICorner')
			slotcorner.CornerRadius = UDim.new(0, 4)
			slotcorner.Parent = slotbkg
			local slotstroke = Instance.new('UIStroke')
			slotstroke.Color = color.Light(uipallet.Main, 0.04)
			slotstroke.Thickness = 2
			slotstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			slotstroke.Enabled = i == selectedslot
			slotstroke.Parent = slotbkg
			slotbkg.MouseEnter:Connect(function()
				slotbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
			end)
			slotbkg.MouseLeave:Connect(function()
				slotbkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
			end)
			slotbkg.MouseButton1Click:Connect(function()
				window['Slot'..selectedslot].UIStroke.Enabled = false
				selectedslot = i
				slotstroke.Enabled = true
				slotnum.Text = 'SLOT '..selectedslot
			end)
			slotbkg.MouseButton2Click:Connect(function()
				local obj = self.Hotbars[self.Selected]
				if obj then
					window['Slot'..i].ImageLabel.Image = ''
					obj.Hotbar[tostring(i)] = nil
					obj.Object['Slot'..i].Image = '	'
				end
			end)
		end
		local searchbkg = Instance.new('Frame')
		searchbkg.Size = UDim2.fromOffset(496, 31)
		searchbkg.Position = UDim2.fromOffset(142, 80)
		searchbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		searchbkg.Parent = window
		local search = Instance.new('TextBox')
		search.Size = UDim2.new(1, -10, 0, 31)
		search.Position = UDim2.fromOffset(10, 0)
		search.BackgroundTransparency = 1
		search.Text = ''
		search.PlaceholderText = ''
		search.TextXAlignment = Enum.TextXAlignment.Left
		search.TextColor3 = uipallet.Text
		search.TextSize = 12
		search.FontFace = uipallet.Font
		search.ClearTextOnFocus = false
		search.Parent = searchbkg
		local searchcorner = Instance.new('UICorner')
		searchcorner.CornerRadius = UDim.new(0, 4)
		searchcorner.Parent = searchbkg
		local searchicon = Instance.new('ImageLabel')
		searchicon.Size = UDim2.fromOffset(14, 14)
		searchicon.Position = UDim2.new(1, -26, 0, 8)
		searchicon.BackgroundTransparency = 1
		searchicon.Image = getcustomasset('ReVape/assets/new/search.png')
		searchicon.ImageColor3 = color.Light(uipallet.Main, 0.37)
		searchicon.Parent = searchbkg
		local children = Instance.new('ScrollingFrame')
		children.Name = 'Children'
		children.Size = UDim2.fromOffset(500, 240)
		children.Position = UDim2.fromOffset(144, 122)
		children.BackgroundTransparency = 1
		children.BorderSizePixel = 0
		children.ScrollBarThickness = 2
		children.ScrollBarImageTransparency = 0.75
		children.CanvasSize = UDim2.new()
		children.Parent = window
		local windowlist = Instance.new('UIGridLayout')
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.FillDirectionMaxCells = 9
		windowlist.CellSize = UDim2.fromOffset(51, 52)
		windowlist.CellPadding = UDim2.fromOffset(4, 3)
		windowlist.Parent = children
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / vape.guiscale.Scale)
		end)
		table.insert(vape.Windows, window)
	
		local function createitem(id, image)
			local slotbkg = Instance.new('TextButton')
			slotbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			slotbkg.Text = ''
			slotbkg.AutoButtonColor = false
			slotbkg.Parent = children
			local slotimage = Instance.new('ImageLabel')
			slotimage.Size = UDim2.fromOffset(32, 32)
			slotimage.Position = UDim2.new(0.5, -16, 0.5, -16)
			slotimage.BackgroundTransparency = 1
			slotimage.Image = image
			slotimage.Parent = slotbkg
			local slotcorner = Instance.new('UICorner')
			slotcorner.CornerRadius = UDim.new(0, 4)
			slotcorner.Parent = slotbkg
			slotbkg.MouseEnter:Connect(function()
				slotbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.04)
			end)
			slotbkg.MouseLeave:Connect(function()
				slotbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			end)
			slotbkg.MouseButton1Click:Connect(function()
				local obj = self.Hotbars[self.Selected]
				if obj then
					window['Slot'..selectedslot].ImageLabel.Image = image
					obj.Hotbar[tostring(selectedslot)] = id
					obj.Object['Slot'..selectedslot].Image = image
				end
			end)
		end
	
		local function indexSearch(text)
			for _, v in children:GetChildren() do
				if v:IsA('TextButton') then
					v:ClearAllChildren()
					v:Destroy()
				end
			end
	
			if text == '' then
				for _, v in {'diamond_sword', 'diamond_pickaxe', 'diamond_axe', 'shears', 'wood_bow', 'wool_white', 'fireball', 'apple', 'iron', 'gold', 'diamond', 'emerald'} do
					createitem(v, bedwars.ItemMeta[v].image)
				end
				return
			end
	
			for i, v in bedwars.ItemMeta do
				if text:lower() == i:lower():sub(1, text:len()) then
					if not v.image then continue end
					createitem(i, v.image)
				end
			end
		end
	
		search:GetPropertyChangedSignal('Text'):Connect(function()
			indexSearch(search.Text)
		end)
		indexSearch('')
	
		return window
	end
	
	vape.Components.HotbarList = function(optionsettings, children, api)
		if vape.ThreadFix then
			setthreadidentity(8)
		end
		local optionapi = {
			Type = 'HotbarList',
			Hotbars = {},
			Selected = 1
		}
		local hotbarlist = Instance.new('TextButton')
		hotbarlist.Name = 'HotbarList'
		hotbarlist.Size = UDim2.fromOffset(220, 40)
		hotbarlist.BackgroundColor3 = optionsettings.Darker and (children.BackgroundColor3 == color.Dark(uipallet.Main, 0.02) and color.Dark(uipallet.Main, 0.04) or color.Dark(uipallet.Main, 0.02)) or children.BackgroundColor3
		hotbarlist.Text = ''
		hotbarlist.BorderSizePixel = 0
		hotbarlist.AutoButtonColor = false
		hotbarlist.Parent = children
		local textbkg = Instance.new('Frame')
		textbkg.Name = 'BKG'
		textbkg.Size = UDim2.new(1, -20, 0, 31)
		textbkg.Position = UDim2.fromOffset(10, 4)
		textbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		textbkg.Parent = hotbarlist
		local textbkgcorner = Instance.new('UICorner')
		textbkgcorner.CornerRadius = UDim.new(0, 4)
		textbkgcorner.Parent = textbkg
		local textbutton = Instance.new('TextButton')
		textbutton.Name = 'HotbarList'
		textbutton.Size = UDim2.new(1, -2, 1, -2)
		textbutton.Position = UDim2.fromOffset(1, 1)
		textbutton.BackgroundColor3 = uipallet.Main
		textbutton.Text = ''
		textbutton.AutoButtonColor = false
		textbutton.Parent = textbkg
		textbutton.MouseEnter:Connect(function()
			tween:Tween(textbkg, TweenInfo.new(0.2), {
				BackgroundColor3 = color.Light(uipallet.Main, 0.14)
			})
		end)
		textbutton.MouseLeave:Connect(function()
			tween:Tween(textbkg, TweenInfo.new(0.2), {
				BackgroundColor3 = color.Light(uipallet.Main, 0.034)
			})
		end)
		local textbuttoncorner = Instance.new('UICorner')
		textbuttoncorner.CornerRadius = UDim.new(0, 4)
		textbuttoncorner.Parent = textbutton
		local textbuttonicon = Instance.new('ImageLabel')
		textbuttonicon.Size = UDim2.fromOffset(12, 12)
		textbuttonicon.Position = UDim2.fromScale(0.5, 0.5)
		textbuttonicon.AnchorPoint = Vector2.new(0.5, 0.5)
		textbuttonicon.BackgroundTransparency = 1
		textbuttonicon.Image = getcustomasset('ReVape/assets/new/add.png')
		textbuttonicon.ImageColor3 = Color3.fromHSV(0.46, 0.96, 0.52)
		textbuttonicon.Parent = textbutton
		local childrenlist = Instance.new('Frame')
		childrenlist.Size = UDim2.new(1, 0, 1, -40)
		childrenlist.Position = UDim2.fromOffset(0, 40)
		childrenlist.BackgroundTransparency = 1
		childrenlist.Parent = hotbarlist
		local windowlist = Instance.new('UIListLayout')
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.Padding = UDim.new(0, 3)
		windowlist.Parent = childrenlist
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			hotbarlist.Size = UDim2.fromOffset(220, math.min(43 + windowlist.AbsoluteContentSize.Y / vape.guiscale.Scale, 603))
		end)
		textbutton.MouseButton1Click:Connect(function()
			optionapi:AddHotbar()
		end)
		optionapi.Window = CreateWindow(optionapi)
	
		function optionapi:Save(savetab)
			local hotbars = {}
			for _, v in self.Hotbars do
				table.insert(hotbars, v.Hotbar)
			end
			savetab.HotbarList = {
				Selected = self.Selected,
				Hotbars = hotbars
			}
		end
	
		function optionapi:Load(savetab)
			for _, v in self.Hotbars do
				v.Object:ClearAllChildren()
				v.Object:Destroy()
				table.clear(v.Hotbar)
			end
			table.clear(self.Hotbars)
			for _, v in savetab.Hotbars do
				self:AddHotbar(v)
			end
			self.Selected = savetab.Selected or 1
		end
	
		function optionapi:AddHotbar(data)
			local hotbardata = {Hotbar = data or {}}
			table.insert(self.Hotbars, hotbardata)
			local hotbar = Instance.new('TextButton')
			hotbar.Size = UDim2.fromOffset(200, 27)
			hotbar.BackgroundColor3 = table.find(self.Hotbars, hotbardata) == self.Selected and color.Light(uipallet.Main, 0.034) or uipallet.Main
			hotbar.Text = ''
			hotbar.AutoButtonColor = false
			hotbar.Parent = childrenlist
			hotbardata.Object = hotbar
			local hotbarcorner = Instance.new('UICorner')
			hotbarcorner.CornerRadius = UDim.new(0, 4)
			hotbarcorner.Parent = hotbar
			for i = 1, 9 do
				local slot = Instance.new('ImageLabel')
				slot.Name = 'Slot'..i
				slot.Size = UDim2.fromOffset(17, 18)
				slot.Position = UDim2.fromOffset(-7 + (i * 18), 5)
				slot.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
				slot.Image = hotbardata.Hotbar[tostring(i)] and bedwars.getIcon({itemType = hotbardata.Hotbar[tostring(i)]}, true) or ''
				slot.BorderSizePixel = 0
				slot.Parent = hotbar
			end
			hotbar.MouseButton1Click:Connect(function()
				local ind = table.find(optionapi.Hotbars, hotbardata)
				if ind == optionapi.Selected then
					vape.gui.ScaledGui.ClickGui.Visible = false
					optionapi.Window.Visible = true
					for i = 1, 9 do
						optionapi.Window['Slot'..i].ImageLabel.Image = hotbardata.Hotbar[tostring(i)] and bedwars.getIcon({itemType = hotbardata.Hotbar[tostring(i)]}, true) or ''
					end
				else
					if optionapi.Hotbars[optionapi.Selected] then
						optionapi.Hotbars[optionapi.Selected].Object.BackgroundColor3 = uipallet.Main
					end
					hotbar.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
					optionapi.Selected = ind
				end
			end)
			local close = Instance.new('ImageButton')
			close.Name = 'Close'
			close.Size = UDim2.fromOffset(16, 16)
			close.Position = UDim2.new(1, -23, 0, 6)
			close.BackgroundColor3 = Color3.new(1, 1, 1)
			close.BackgroundTransparency = 1
			close.Image = getcustomasset('ReVape/assets/new/closemini.png')
			close.ImageColor3 = color.Light(uipallet.Text, 0.2)
			close.ImageTransparency = 0.5
			close.AutoButtonColor = false
			close.Parent = hotbar
			local closecorner = Instance.new('UICorner')
			closecorner.CornerRadius = UDim.new(1, 0)
			closecorner.Parent = close
			close.MouseEnter:Connect(function()
				close.ImageTransparency = 0.3
				tween:Tween(close, TweenInfo.new(0.2), {
					BackgroundTransparency = 0.6
				})
			end)
			close.MouseLeave:Connect(function()
				close.ImageTransparency = 0.5
				tween:Tween(close, TweenInfo.new(0.2), {
					BackgroundTransparency = 1
				})
			end)
			close.MouseButton1Click:Connect(function()
				local ind = table.find(self.Hotbars, hotbardata)
				local obj = self.Hotbars[self.Selected]
				local obj2 = self.Hotbars[ind]
				if obj and obj2 then
					obj2.Object:ClearAllChildren()
					obj2.Object:Destroy()
					table.remove(self.Hotbars, ind)
					ind = table.find(self.Hotbars, obj)
					self.Selected = table.find(self.Hotbars, obj) or 1
				end
			end)
		end
	
		api.Options.HotbarList = optionapi
	
		return optionapi
	end
	
	local function getBlock()
		local clone = table.clone(store.inventory.inventory.items)
		table.sort(clone, function(a, b)
			return a.amount < b.amount
		end)
	
		for _, item in clone do
			local block = bedwars.ItemMeta[item.itemType].block
			if block and not block.seeThrough then
				return item
			end
		end
	end
	
	local function getCustomItem(v)
		if v == 'diamond_sword' then
			local sword = store.tools.sword
			v = sword and sword.itemType or 'wood_sword'
		elseif v == 'diamond_pickaxe' then
			local pickaxe = store.tools.stone
			v = pickaxe and pickaxe.itemType or 'wood_pickaxe'
		elseif v == 'diamond_axe' then
			local axe = store.tools.wood
			v = axe and axe.itemType or 'wood_axe'
		elseif v == 'wood_bow' then
			local bow = getBow()
			v = bow and bow.itemType or 'wood_bow'
		elseif v == 'wool_white' then
			local block = getBlock()
			v = block and block.itemType or 'wool_white'
		end
	
		return v
	end
	
	local function findItemInTable(tab, item)
		for slot, v in tab do
			if item.itemType == getCustomItem(v) then
				return tonumber(slot)
			end
		end
	end
	
	local function findInHotbar(item)
		for i, v in store.inventory.hotbar do
			if v.item and v.item.itemType == item.itemType then
				return i - 1, v.item
			end
		end
	end
	
	local function findInInventory(item)
		for _, v in store.inventory.inventory.items do
			if v.itemType == item.itemType then
				return v
			end
		end
	end
	
	local function dispatch(...)
		bedwars.Store:dispatch(...)
		vapeEvents.InventoryChanged.Event:Wait()
	end
	
	local function sortCallback()
		if Active then return end
		Active = true
		local items = (List.Hotbars[List.Selected] and List.Hotbars[List.Selected].Hotbar or {})
	
		for _, v in store.inventory.inventory.items do
			local slot = findItemInTable(items, v)
			if slot then
				local olditem = store.inventory.hotbar[slot]
				if olditem.item and olditem.item.itemType == v.itemType then continue end
				if olditem.item then
					dispatch({
						type = 'InventoryRemoveFromHotbar',
						slot = slot - 1
					})
				end
	
				local newslot = findInHotbar(v)
				if newslot then
					dispatch({
						type = 'InventoryRemoveFromHotbar',
						slot = newslot
					})
					if olditem.item then
						dispatch({
							type = 'InventoryAddToHotbar',
							item = findInInventory(olditem.item),
							slot = newslot
						})
					end
				end
	
				dispatch({
					type = 'InventoryAddToHotbar',
					item = findInInventory(v),
					slot = slot - 1
				})
			elseif Clear.Enabled then
				local newslot = findInHotbar(v)
				if newslot then
				   	dispatch({
						type = 'InventoryRemoveFromHotbar',
						slot = newslot
					})
				end
			end
		end
	
		Active = false
	end
	
	AutoHotbar = vape.Categories.Inventory:CreateModule({
		Name = 'AutoHotbar',
		Function = function(callback)
			if callback then
				task.spawn(sortCallback)
				if Mode.Value == 'On Key' then
					AutoHotbar:Toggle()
					return
				end
	
				AutoHotbar:Clean(vapeEvents.InventoryAmountChanged.Event:Connect(sortCallback))
			end
		end,
		Tooltip = 'Automatically arranges hotbar to your liking.'
	})
	Mode = AutoHotbar:CreateDropdown({
		Name = 'Activation',
		List = {'Toggle', 'On Key'},
		Function = function()
			if AutoHotbar.Enabled then
				AutoHotbar:Toggle()
				AutoHotbar:Toggle()
			end
		end
	})
	Clear = AutoHotbar:CreateToggle({Name = 'Clear Hotbar'})
	List = AutoHotbar:CreateHotbarList({})
end)
	
run(function()
	local Value
	local oldclickhold, oldshowprogress
	
	local FastConsume = vape.Categories.Inventory:CreateModule({
		Name = 'FastConsume',
		Function = function(callback)
			if callback then
				oldclickhold = bedwars.ClickHold.startClick
				oldshowprogress = bedwars.ClickHold.showProgress
				bedwars.ClickHold.startClick = function(self)
					self.startedClickTime = tick()
					local handle = self:showProgress()
					local clicktime = self.startedClickTime
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(self.durationSeconds * (Value.Value / 40))
						if handle == self.handle and clicktime == self.startedClickTime and self.closeOnComplete then
							self:hideProgress()
							if self.onComplete then self.onComplete() end
							if self.onPartialComplete then self.onPartialComplete(1) end
							self.startedClickTime = -1
						end
					end)
				end
	
				bedwars.ClickHold.showProgress = function(self)
					local roact = debug.getupvalue(oldshowprogress, 1)
					local countdown = roact.mount(roact.createElement('ScreenGui', {}, { roact.createElement('Frame', {
						[roact.Ref] = self.wrapperRef,
						Size = UDim2.new(),
						Position = UDim2.fromScale(0.5, 0.55),
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 0.8
					}, { roact.createElement('Frame', {
						[roact.Ref] = self.progressRef,
						Size = UDim2.fromScale(0, 1),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 0.5
					}) }) }), lplr:FindFirstChild('PlayerGui'))
	
					self.handle = countdown
					local sizetween = tweenService:Create(self.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.fromScale(0.11, 0.005)
					})
					local countdowntween = tweenService:Create(self.progressRef:getValue(), TweenInfo.new(self.durationSeconds * (Value.Value / 100), Enum.EasingStyle.Linear), {
						Size = UDim2.fromScale(1, 1)
					})
	
					sizetween:Play()
					countdowntween:Play()
					table.insert(self.tweens, countdowntween)
					table.insert(self.tweens, sizetween)
					
					return countdown
				end
			else
				bedwars.ClickHold.startClick = oldclickhold
				bedwars.ClickHold.showProgress = oldshowprogress
				oldclickhold = nil
				oldshowprogress = nil
			end
		end,
		Tooltip = 'Use/Consume items quicker.'
	})
	Value = FastConsume:CreateSlider({
		Name = 'Multiplier',
		Min = 0,
		Max = 100
	})
end)
	
run(function()
	local FastDrop
	
	FastDrop = vape.Categories.Inventory:CreateModule({
		Name = 'FastDrop',
		Function = function(callback)
			if callback then
				repeat
					if entitylib.isAlive and (not store.inventory.opened) and (inputService:IsKeyDown(Enum.KeyCode.H) or inputService:IsKeyDown(Enum.KeyCode.Backspace)) and inputService:GetFocusedTextBox() == nil then
						task.spawn(bedwars.ItemDropController.dropItemInHand)
						task.wait(0.1)
					else
						task.wait(0.1)
					end
				until not FastDrop.Enabled
			end
		end,
		Tooltip = 'Drops items fast when you hold Q'
	})
end)
	
run(function()
	local BedPlates
	local MutiLayerChecker
	local Background
	local Color = {}
	local Reference = {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	local SCAN_PASSES = 2
	local function scanSide(self, start, tab)
		for _, side in sides do
			for i = 1, 15 do
				local block = getPlacedBlock(start + (side * i))
				if not block or block == self then break end
				if not block:GetAttribute('NoBreak') then
					tab[block.Name] = tab[block.Name] or {}
					tab[block.Name][i] = true
				end
			end
		end
	end
	local function refreshAdornee(v)
		for _, obj in v.Frame:GetChildren() do
			if obj:IsA('ImageLabel') then
				obj:Destroy()
			end
		end
		local start = v.Adornee.Position
		local blockLayers = {}
		scanSide(v.Adornee, start, blockLayers)
		scanSide(v.Adornee, start + Vector3.new(0, 0, 3), blockLayers)
		local blocks = {}
		for name, layers in blockLayers do
			local raw = 0
			for _ in layers do
				raw += 1
			end
			local count = math.max(1, math.floor(raw / SCAN_PASSES))
			table.insert(blocks, {name = name,count = count})
		end
		table.sort(blocks, function(a, b)
			return (bedwars.ItemMeta[a.name].block and bedwars.ItemMeta[a.name].block.health or 0) > (bedwars.ItemMeta[b.name].block and bedwars.ItemMeta[b.name].block.health or 0)
		end)
		v.Enabled = #blocks > 0
		for _, data in blocks do
			local blockimage = Instance.new('ImageLabel')
			blockimage.Size = UDim2.fromOffset(32, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = data.name}, true)
			blockimage.Parent = v.Frame
			if MutiLayerChecker.Enabled and data.count > 1 then
				local countLabel = Instance.new('TextLabel')
				countLabel.Size = UDim2.fromScale(1, 1)
				countLabel.BackgroundTransparency = 1
				countLabel.Text = tostring(data.count)
				countLabel.TextColor3 = Color3.new(1, 1, 1)
				countLabel.TextStrokeTransparency = 0
				countLabel.TextScaled = true
				countLabel.Font = Enum.Font.GothamBold
				countLabel.Parent = blockimage
			end
		end
	end

	local function Added(v)
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = Folder
		billboard.Name = 'bed'
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
		billboard.Size = UDim2.fromOffset(36, 36)
		billboard.AlwaysOnTop = true
		billboard.ClipsDescendants = false
		billboard.Adornee = v
		local blur = addBlur(billboard)
		blur.Visible = Background.Enabled
		local frame = Instance.new('Frame')
		frame.Name = 'Frame'
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
		frame.BackgroundTransparency = 1 - (Background.Enabled and Color.Opacity or 0)
		frame.Parent = billboard
		local layout = Instance.new('UIListLayout')
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 4)
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			billboard.Size = UDim2.fromOffset(math.max(layout.AbsoluteContentSize.X + 4, 36), 36)
		end)
		layout.Parent = frame
		local corner = Instance.new('UICorner')
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = frame
		Reference[v] = billboard
		refreshAdornee(billboard)
	end
	local function refreshNear(data)
		data = data.blockRef.blockPosition * 3
		for i, v in Reference do
			if (data - i.Position).Magnitude <= 30 then
				refreshAdornee(v)
			end
		end
	end
	BedPlates = vape.Categories.Utility:CreateModule({
		Name = 'BedPlates',
		Function = function(callback)
			if callback then
				for _, v in collectionService:GetTagged('bed') do
					task.spawn(Added, v)
				end
				BedPlates:Clean(vapeEvents.PlaceBlockEvent.Event:Connect(refreshNear))
				BedPlates:Clean(vapeEvents.BreakBlockEvent.Event:Connect(refreshNear))
				BedPlates:Clean(collectionService:GetInstanceAddedSignal('bed'):Connect(Added))
				BedPlates:Clean(collectionService:GetInstanceRemovedSignal('bed'):Connect(function(v)
					if Reference[v] then
						Reference[v]:Destroy()
						Reference[v] = nil
					end
				end))
			else
				table.clear(Reference)
				Folder:ClearAllChildren()
			end
		end,
		Tooltip = 'Displays blocks over the bed'
	})

	Background = BedPlates:CreateToggle({
		Name = 'Background',
		Default = true,
		Function = function(callback)
			if Color.Object then
				Color.Object.Visible = callback
			end
			for _, v in Reference do
				v.Frame.BackgroundTransparency = 1 - (callback and Color.Opacity or 0)
				v.Blur.Visible = callback
			end
		end
	})
	MutiLayerChecker = BedPlates:CreateToggle({
		Name = 'Mutiple Layers',
		Default = false,
		Function = function()
			for _, v in Reference do
				refreshAdornee(v)
			end
		end
	})
	Color = BedPlates:CreateColorSlider({
		Name = 'Background Color',
		DefaultValue = 0,
		DefaultOpacity = 0.5,
		Function = function(hue, sat, val, opacity)
			for _, v in Reference do
				v.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
				v.Frame.BackgroundTransparency = 1 - opacity
			end
		end,
		Darker = true
	})
end)
	



run(function()
	local BedBreakEffect
	local Mode
	local List
	local NameToId = {}
	
	BedBreakEffect = vape.Categories.Legit:CreateModule({
		Name = 'Bed Break Effect',
		Function = function(callback)
			if callback then
	            BedBreakEffect:Clean(vapeEvents.BedwarsBedBreak.Event:Connect(function(data)
	                firesignal(bedwars.Client:Get('BedBreakEffectTriggered').instance.OnClientEvent, {
	                    player = data.player,
	                    position = data.bedBlockPosition * 3,
	                    effectType = NameToId[List.Value],
	                    teamId = data.brokenBedTeam.id,
	                    centerBedPosition = data.bedBlockPosition * 3
	                })
	            end))
	        end
		end,
		Tooltip = 'Custom bed break effects'
	})
	local BreakEffectName = {}
	for i, v in bedwars.BedBreakEffectMeta do
		table.insert(BreakEffectName, v.name)
		NameToId[v.name] = i
	end
	table.sort(BreakEffectName)
	List = BedBreakEffect:CreateDropdown({
		Name = 'Effect',
		List = BreakEffectName
	})
end)
	

	
run(function()
	local old
	local Image
	
	local Crosshair = vape.Categories.Legit:CreateModule({
		Name = 'Crosshair',
		Function = function(callback)
			if callback then
				old = bedwars.ViewmodelController.showCrosshair
				bedwars.ViewmodelController.showCrosshair = function(tbl)
					tbl.crosshair = true
					if inputService.TouchEnabled then
						local ui = roact.createElement("ScreenGui",{IgnoreGuiInset=true},{roact.createElement("ImageLabel",{Size=UDim2.fromScale(0.04,0.04),SizeConstraint='RelativeYY',BackgroundTransparency=1,Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),Image=Image.Value,ResampleMode=Enum.ResamplerMode.Pixelated})})
						local mount = roact.mount(ui, lplr:WaitForChild("PlayerGui"))
						tbl.crosshairMaid:GiveTask(function()
							roact.unmount(mount)
						end)
					else
						cloneref(lplr:GetMouse()).Icon = Image.Value
						tbl.crosshairMaid:GiveTask(function()
							cloneref(lplr:GetMouse()).Icon = ''
						end)
					end
					
				end
			else
				bedwars.ViewmodelController.showCrosshair = old
				old = nil
			end
	
			if bedwars.ViewmodelController.crosshair then
				bedwars.ViewmodelController:hideCrosshair()
				bedwars.ViewmodelController:showCrosshair()
			end
		end,
		Tooltip = 'Custom first person crosshair depending on the image choosen.'
	})
	Image = Crosshair:CreateTextBox({
		Name = 'Image',
		Placeholder = 'image id (roblox) : eg rbxasset://123456789',
		Function = function(enter)
			if enter and Crosshair.Enabled then
				Crosshair:Toggle()
				Crosshair:Toggle()
			end
		end
	})
end)

run(function()
	local FOV
	local Value
	local old, old2
	
	FOV = vape.Categories.Legit:CreateModule({
		Name = 'FOV',
		Function = function(callback)
			if callback then
				old = bedwars.FovController.setFOV
				old2 = bedwars.FovController.getFOV
				bedwars.FovController.setFOV = function(self) 
					return old(self, Value.Value) 
				end
				bedwars.FovController.getFOV = function() 
					return Value.Value 
				end
			else
				bedwars.FovController.setFOV = old
				bedwars.FovController.getFOV = old2
			end
			
			bedwars.FovController:setFOV(bedwars.Store:getState().Settings.fov)
		end,
		Tooltip = 'Adjusts camera vision'
	})
	Value = FOV:CreateSlider({
		Name = 'FOV',
		Min = 30,
		Max = 120
	})
end)
	
run(function()
	local FPSBoost
	local Kill
	local Visualizer
	local effects, util = {}, {}
	
	FPSBoost = vape.Categories.Legit:CreateModule({
		Name = 'FPS Boost',
		Function = function(callback)
			if callback then
				if Kill.Enabled then
					for i, v in bedwars.KillEffectController.killEffects do
						if not i:find('Custom') then
							effects[i] = v
							bedwars.KillEffectController.killEffects[i] = {
								new = function() 
									return {
										onKill = function() end, 
										isPlayDefaultKillEffect = function() 
											return true 
										end
									} 
								end
							}
						end
					end
				end
	
				if Visualizer.Enabled then
					for i, v in bedwars.VisualizerUtils do
						util[i] = v
						bedwars.VisualizerUtils[i] = function() end
					end
				end
	
				repeat task.wait(0.1) until store.matchState ~= 0
				if not bedwars.AppController then return end
				bedwars.NametagController.addGameNametag = function() end
				for _, v in bedwars.AppController:getOpenApps() do
					if tostring(v):find('Nametag') then
						bedwars.AppController:closeApp(tostring(v))
					end
				end
			else
				for i, v in effects do 
					bedwars.KillEffectController.killEffects[i] = v 
				end
				for i, v in util do 
					bedwars.VisualizerUtils[i] = v 
				end
				table.clear(effects)
				table.clear(util)
			end
		end,
		Tooltip = 'Improves the framerate by turning off certain effects'
	})
	Kill = FPSBoost:CreateToggle({
		Name = 'Kill Effects',
		Function = function()
			if FPSBoost.Enabled then
				FPSBoost:Toggle()
				FPSBoost:Toggle()
			end
		end,
		Default = true
	})
	Visualizer = FPSBoost:CreateToggle({
		Name = 'Visualizer',
		Function = function()
			if FPSBoost.Enabled then
				FPSBoost:Toggle()
				FPSBoost:Toggle()
			end
		end,
		Default = true
	})
end)
	
run(function()
	local HitColor
	local Color
	local done = {}
	
	HitColor = vape.Categories.Legit:CreateModule({
		Name = 'Hit Color',
		Function = function(callback)
			if callback then 
				repeat
					for i, v in entitylib.List do 
						local highlight = v.Character and v.Character:FindFirstChild('_DamageHighlight_')
						if highlight then 
							if not table.find(done, highlight) then 
								table.insert(done, highlight) 
							end
							highlight.FillColor = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
							highlight.FillTransparency = Color.Opacity
						end
					end
					task.wait(0.1)
				until not HitColor.Enabled
			else
				for i, v in done do 
					v.FillColor = Color3.new(1, 0, 0)
					v.FillTransparency = 0.4
				end
				table.clear(done)
			end
		end,
		Tooltip = 'Customize the hit highlight options'
	})
	Color = HitColor:CreateColorSlider({
		Name = 'Color',
		DefaultOpacity = 0.4
	})
end)
	
	
run(function()
	local Interface
	local HotbarOpenInventory = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory
	local HotbarHealthbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar
	local HotbarApp = getRoactRender(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp.render)
	local old, new = {}, {}
	
	vape:Clean(function()
		for _, v in new do
			table.clear(v)
		end
		for _, v in old do
			table.clear(v)
		end
		table.clear(new)
		table.clear(old)
	end)
	
	local function modifyconstant(func, ind, val)
		if not func then return end
		if not old[func] then old[func] = {} end
		if not new[func] then new[func] = {} end
		if not old[func][ind] then
			old[func][ind] = debug.getconstant(func, ind)
		end
		if typeof(old[func][ind]) ~= typeof(val) then return end
		new[func][ind] = val
	
		if Interface.Enabled then
			if val then
				debug.setconstant(func, ind, val)
			else
				debug.setconstant(func, ind, old[func][ind])
				old[func][ind] = nil
			end
		end
	end
	
	Interface = vape.Categories.Legit:CreateModule({
		Name = 'Interface',
		Function = function(callback)
			for i, v in (callback and new or old) do
				for i2, v2 in v do
					debug.setconstant(i, i2, v2)
				end
			end
		end,
		Tooltip = 'Customize bedwars UI'
	})
	local fontitems = {'LuckiestGuy'}
	for _, v in Enum.Font:GetEnumItems() do
		if v.Name ~= 'LuckiestGuy' then
			table.insert(fontitems, v.Name)
		end
	end
	Interface:CreateDropdown({
		Name = 'Health Font',
		List = fontitems,
		Function = function(val)
			modifyconstant(HotbarHealthbar.render, 77, val)
		end
	})
	Interface:CreateColorSlider({
		Name = 'Health Color',
		Function = function(hue, sat, val)
			modifyconstant(HotbarHealthbar.render, 16, tonumber(Color3.fromHSV(hue, sat, val):ToHex(), 16))
			if Interface.Enabled then
				local hotbar = lplr.PlayerGui:FindFirstChild('hotbar')
				hotbar = hotbar and hotbar:FindFirstChild('HealthbarProgressWrapper', true)
				if hotbar then
					hotbar['1'].BackgroundColor3 = Color3.fromHSV(hue, sat, val)
				end
			end
		end
	})
	Interface:CreateColorSlider({
		Name = 'Hotbar Color',
		DefaultOpacity = 0.8,
		Function = function(hue, sat, val, opacity)
			local func = oldinvrender or HotbarOpenInventory.render
			modifyconstant(debug.getupvalue(HotbarApp, 23).render, 51, tonumber(Color3.fromHSV(hue, sat, val):ToHex(), 16))
			modifyconstant(debug.getupvalue(HotbarApp, 23).render, 58, tonumber(Color3.fromHSV(hue, sat, math.clamp(val > 0.5 and val - 0.2 or val + 0.2, 0, 1)):ToHex(), 16))
			modifyconstant(debug.getupvalue(HotbarApp, 23).render, 54, 1 - opacity)
			modifyconstant(debug.getupvalue(HotbarApp, 23).render, 55, math.clamp(1.2 - opacity, 0, 1))
			modifyconstant(func, 31, tonumber(Color3.fromHSV(hue, sat, val):ToHex(), 16))
			modifyconstant(func, 32, math.clamp(1.2 - opacity, 0, 1))
			modifyconstant(func, 34, tonumber(Color3.fromHSV(hue, sat, math.clamp(val > 0.5 and val - 0.2 or val + 0.2, 0, 1)):ToHex(), 16))
		end
	})
end)
	
run(function()
	local KillEffect
	local Mode
	local List
	local NameToId = {}
	
	local killeffects = {
		Gravity = function(_, _, char, _)
			char:BreakJoints()
			local highlight = char:FindFirstChildWhichIsA('Highlight')
			local nametag = char:FindFirstChild('Nametag', true)
			if highlight then
				highlight:Destroy()
			end
			if nametag then
				nametag:Destroy()
			end
	
			task.spawn(function()
				local partvelo = {}
				for _, v in char:GetDescendants() do
					if v:IsA('BasePart') then
						partvelo[v.Name] = v.Velocity
					end
				end
				char.Archivable = true
				local clone = char:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = workspace
				game:GetService('Debris'):AddItem(clone, 30)
				char:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				clone:BreakJoints()
				task.wait(0.01)
				for _, v in clone:GetDescendants() do
					if v:IsA('BasePart') then
						local bodyforce = Instance.new('BodyForce')
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(_, _, char, _)
			char:BreakJoints()
			local highlight = char:FindFirstChildWhichIsA('Highlight')
			if highlight then
				highlight:Destroy()
			end
			local startpos = 1125
			local startcf = char.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
	
			for i = startpos - 75, 0, -75 do
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then
					newpos2 = Vector3.zero
				end
				local part = Instance.new('Part')
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = workspace
				game:GetService('Debris'):AddItem(part, 0.5)
				game:GetService('Debris'):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then
					local soundpart = Instance.new('Part')
					soundpart.Transparency = 1
					soundpart.Anchored = true
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new('Sound')
					sound.SoundId = 'rbxassetid://6993372814'
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end,
		Delete = function(_, _, char, _)
			char:Destroy()
		end
	}
	
	KillEffect = vape.Categories.Legit:CreateModule({
		Name = 'Kill Effect',
		Function = function(callback)
			if callback then
				for i, v in killeffects do
					bedwars.KillEffectController.killEffects['Custom'..i] = {
						new = function()
							return {
								onKill = v,
								isPlayDefaultKillEffect = function()
									return false
								end
							}
						end
					}
				end
				KillEffect:Clean(lplr:GetAttributeChangedSignal('KillEffectType'):Connect(function()
					lplr:SetAttribute('KillEffectType', Mode.Value == 'Bedwars' and NameToId[List.Value] or 'Custom'..Mode.Value)
				end))
				lplr:SetAttribute('KillEffectType', Mode.Value == 'Bedwars' and NameToId[List.Value] or 'Custom'..Mode.Value)
			else
				for i in killeffects do
					bedwars.KillEffectController.killEffects['Custom'..i] = nil
				end
				lplr:SetAttribute('KillEffectType', 'default')
			end
		end,
		Tooltip = 'Custom final kill effects'
	})
	local modes = {'Bedwars'}
	for i in killeffects do
		table.insert(modes, i)
	end
	Mode = KillEffect:CreateDropdown({
		Name = 'Mode',
		List = modes,
		Function = function(val)
			List.Object.Visible = val == 'Bedwars'
			if KillEffect.Enabled then
				lplr:SetAttribute('KillEffectType', val == 'Bedwars' and NameToId[List.Value] or 'Custom'..val)
			end
		end
	})
	local KillEffectName = {}
	for i, v in bedwars.KillEffectMeta do
		table.insert(KillEffectName, v.name)
		NameToId[v.name] = i
	end
	table.sort(KillEffectName)
	List = KillEffect:CreateDropdown({
		Name = 'Bedwars',
		List = KillEffectName,
		Function = function(val)
			if KillEffect.Enabled then
				lplr:SetAttribute('KillEffectType', NameToId[val])
			end
		end,
		Darker = true
	})
end)
	
run(function()
	local ReachDisplay
	local label
	
	ReachDisplay = vape.Categories.Legit:CreateModule({
		Name = 'Reach Display',
		Function = function(callback)
			if callback then
				repeat
					label.Text = (store.attackReachUpdate > tick() and store.attackReach or '0.00')..' studs'
					task.wait(0.4)
				until not ReachDisplay.Enabled
			end
		end,
		Size = UDim2.fromOffset(100, 41)
	})
	ReachDisplay:CreateFont({
		Name = 'Font',
		Blacklist = 'Gotham',
		Function = function(val)
			label.FontFace = val
		end
	})
	ReachDisplay:CreateColorSlider({
		Name = 'Color',
		DefaultValue = 0,
		DefaultOpacity = 0.5,
		Function = function(hue, sat, val, opacity)
			label.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			label.BackgroundTransparency = 1 - opacity
		end
	})
	label = Instance.new('TextLabel')
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.5
	label.TextSize = 15
	label.Font = Enum.Font.Gotham
	label.Text = '0.00 studs'
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundColor3 = Color3.new()
	label.Parent = ReachDisplay.Children
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = label
end)
	
run(function()
	local SongBeats
	local List
	local FOV
	local FOVValue = {}
	local Volume
	local alreadypicked = {}
	local beattick = tick()
	local oldfov, songobj, songbpm, songtween
	
	local function choosesong()
		local list = List.ListEnabled
		if #alreadypicked >= #list then 
			table.clear(alreadypicked) 
		end
	
		if #list <= 0 then
			notif('SongBeats', 'no songs', 10)
			SongBeats:Toggle()
			return
		end
	
		local chosensong = list[math.random(1, #list)]
		if #list > 1 and table.find(alreadypicked, chosensong) then
			repeat 
				task.wait(0.1) 
				chosensong = list[math.random(1, #list)] 
			until not table.find(alreadypicked, chosensong) or not SongBeats.Enabled
		end
		if not SongBeats.Enabled then return end
	
		local split = chosensong:split('/')
		if not isfile(split[1]) then
			notif('SongBeats', 'Missing song ('..split[1]..')', 10)
			SongBeats:Toggle()
			return
		end
	
		songobj.SoundId = assetfunction(split[1])
		repeat task.wait(0.1) until songobj.IsLoaded or not SongBeats.Enabled
		if SongBeats.Enabled then
			beattick = tick() + (tonumber(split[3]) or 0)
			songbpm = 60 / (tonumber(split[2]) or 50)
			songobj:Play()
		end
	end
	
	SongBeats = vape.Categories.Legit:CreateModule({
		Name = 'Song Beats',
		Function = function(callback)
			if callback then
				songobj = Instance.new('Sound')
				songobj.Volume = Volume.Value / 100
				songobj.Parent = workspace
				repeat
					if not songobj.Playing then choosesong() end
					if beattick < tick() and SongBeats.Enabled and FOV.Enabled then
						beattick = tick() + songbpm
						oldfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
						gameCamera.FieldOfView = oldfov - FOVValue.Value
						songtween = tweenService:Create(gameCamera, TweenInfo.new(math.min(songbpm, 0.2), Enum.EasingStyle.Linear), {FieldOfView = oldfov})
						songtween:Play()
					end
					task.wait(0.1)
				until not SongBeats.Enabled
			else
				if songobj then
					songobj:Destroy()
				end
				if songtween then
					songtween:Cancel()
				end
				if oldfov then
					gameCamera.FieldOfView = oldfov
				end
				table.clear(alreadypicked)
			end
		end,
		Tooltip = 'Built in mp3 player'
	})
	List = SongBeats:CreateTextList({
		Name = 'Songs',
		Placeholder = 'filepath/bpm/start'
	})
	FOV = SongBeats:CreateToggle({
		Name = 'Beat FOV',
		Function = function(callback)
			if FOVValue.Object then
				FOVValue.Object.Visible = callback
			end
			if SongBeats.Enabled then
				SongBeats:Toggle()
				SongBeats:Toggle()
			end
		end,
		Default = true
	})
	FOVValue = SongBeats:CreateSlider({
		Name = 'Adjustment',
		Min = 1,
		Max = 30,
		Default = 5,
		Darker = true
	})
	Volume = SongBeats:CreateSlider({
		Name = 'Volume',
		Function = function(val)
			if songobj then 
				songobj.Volume = val / 100 
			end
		end,
		Min = 1,
		Max = 100,
		Default = 100,
		Suffix = '%'
	})
end)
	
run(function()
	local SoundChanger
	local List
	local soundlist = {}
	local old
	
	SoundChanger = vape.Categories.Legit:CreateModule({
		Name = 'SoundChanger',
		Function = function(callback)
			if callback then
				old = bedwars.SoundManager.playSound
				bedwars.SoundManager.playSound = function(self, id, ...)
					if soundlist[id] then
						id = soundlist[id]
					end
	
					return old(self, id, ...)
				end
			else
				bedwars.SoundManager.playSound = old
				old = nil
			end
		end,
		Tooltip = 'Change ingame sounds to custom ones.'
	})
	List = SoundChanger:CreateTextList({
		Name = 'Sounds',
		Placeholder = '(DAMAGE_1/ben.mp3)',
		Function = function()
			table.clear(soundlist)
			for _, entry in List.ListEnabled do
				local split = entry:split('/')
				local id = bedwars.SoundList[split[1]]
				if id and #split > 1 then
					soundlist[id] = split[2]:find('rbxasset') and split[2] or isfile(split[2]) and assetfunction(split[2]) or ''
				end
			end
		end
	})
end)
	
run(function()
	local UICleanup
	local OpenInv
	local KillFeed
	local OldTabList
	local HotbarApp = getRoactRender(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp.render)
	local HotbarOpenInventory = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory
	local old, new = {}, {}
	local oldkillfeed
	
	vape:Clean(function()
		for _, v in new do
			table.clear(v)
		end
		for _, v in old do
			table.clear(v)
		end
		table.clear(new)
		table.clear(old)
	end)
	
	local function modifyconstant(func, ind, val)
		if not old[func] then old[func] = {} end
		if not new[func] then new[func] = {} end
		if not old[func][ind] then
			local typing = type(old[func][ind])
			if typing == 'function' or typing == 'userdata' then return end
			old[func][ind] = debug.getconstant(func, ind)
		end
		if typeof(old[func][ind]) ~= typeof(val) and val ~= nil then return end
	
		new[func][ind] = val
		if UICleanup.Enabled then
			if val then
				debug.setconstant(func, ind, val)
			else
				debug.setconstant(func, ind, old[func][ind])
				old[func][ind] = nil
			end
		end
	end
	
	UICleanup = vape.Categories.Legit:CreateModule({
		Name = 'UI Cleanup',
		Function = function(callback)
			for i, v in (callback and new or old) do
				for i2, v2 in v do
					debug.setconstant(i, i2, v2)
				end
			end
			if callback then
				if OpenInv.Enabled then
					oldinvrender = HotbarOpenInventory.render
					HotbarOpenInventory.render = function()
						return bedwars.Roact.createElement('TextButton', {Visible = false}, {})
					end
				end
	
				if KillFeed.Enabled then
					oldkillfeed = bedwars.KillFeedController.addToKillFeed
					bedwars.KillFeedController.addToKillFeed = function() end
				end
	
				if OldTabList.Enabled then
					starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				end
			else
				if oldinvrender then
					HotbarOpenInventory.render = oldinvrender
					oldinvrender = nil
				end
	
				if KillFeed.Enabled then
					bedwars.KillFeedController.addToKillFeed = oldkillfeed
					oldkillfeed = nil
				end
	
				if OldTabList.Enabled then
					starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				end
			end
		end,
		Tooltip = 'Cleans up the UI for kits & main'
	})
	UICleanup:CreateToggle({
		Name = 'Resize Health',
		Function = function(callback)
			modifyconstant(HotbarApp, 60, callback and 1 or nil)
			modifyconstant(debug.getupvalue(HotbarApp, 15).render, 30, callback and 1 or nil)
			modifyconstant(debug.getupvalue(HotbarApp, 23).tweenPosition, 16, callback and 0 or nil)
		end,
		Default = true
	})
	UICleanup:CreateToggle({
		Name = 'No Hotbar Numbers',
		Function = function(callback)
			local func = oldinvrender or HotbarOpenInventory.render
			modifyconstant(debug.getupvalue(HotbarApp, 23).render, 90, callback and 0 or nil)
			modifyconstant(func, 71, callback and 0 or nil)
		end,
		Default = true
	})
	OpenInv = UICleanup:CreateToggle({
		Name = 'No Inventory Button',
		Function = function(callback)
			modifyconstant(HotbarApp, 78, callback and 0 or nil)
			if UICleanup.Enabled then
				if callback then
					oldinvrender = HotbarOpenInventory.render
					HotbarOpenInventory.render = function()
						return bedwars.Roact.createElement('TextButton', {Visible = false}, {})
					end
				else
					HotbarOpenInventory.render = oldinvrender
					oldinvrender = nil
				end
			end
		end,
		Default = true
	})
	KillFeed = UICleanup:CreateToggle({
		Name = 'No Kill Feed',
		Function = function(callback)
			if UICleanup.Enabled then
				if callback then
					oldkillfeed = bedwars.KillFeedController.addToKillFeed
					bedwars.KillFeedController.addToKillFeed = function() end
				else
					bedwars.KillFeedController.addToKillFeed = oldkillfeed
					oldkillfeed = nil
				end
			end
		end,
		Default = true
	})
	OldTabList = UICleanup:CreateToggle({
		Name = 'Old Player List',
		Function = function(callback)
			if UICleanup.Enabled then
				starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, callback)
			end
		end,
		Default = true
	})
	UICleanup:CreateToggle({
		Name = 'Fix Queue Card',
		Function = function(callback)
			modifyconstant(bedwars.QueueCard.render, 15, callback and 0.1 or nil)
		end,
		Default = true
	})
end)
	

	
run(function()
	local WinEffect
	local List
	local NameToId = {}
	
	WinEffect = vape.Categories.Legit:CreateModule({
		Name = 'WinEffect',
		Function = function(callback)
			if callback then
				WinEffect:Clean(vapeEvents.MatchEndEvent.Event:Connect(function()
					for i, v in getconnections(bedwars.Client:Get('WinEffectTriggered').instance.OnClientEvent) do
						if v.Function then
							v.Function({
								winEffectType = NameToId[List.Value],
								winningPlayer = lplr
							})
						end
					end
				end))
			end
		end,
		Tooltip = 'Allows you to select any clientside win effect'
	})
	local WinEffectName = {}
	for i, v in bedwars.WinEffectMeta do
		table.insert(WinEffectName, v.name)
		NameToId[v.name] = i
	end
	table.sort(WinEffectName)
	List = WinEffect:CreateDropdown({
		Name = 'Effects',
		List = WinEffectName
	})
end)

------------------

run(function()
	local Range
	local BreakSpeed
	local UpdateRate
	local Custom
	local Bed
	local LuckyBlock
	local IronOre
	local Effect
	local CustomHealth = {}
	local Animation
	local SelfBreak
	local InstantBreak
	local LimitItem
	local customlist, parts = {}, {}
	local WC
	local AT
	local NB
	local SB
	local old
	local event
	local function customHealthbar(self, blockRef, health, maxHealth, changeHealth, block)
		if block:GetAttribute('NoHealthbar') then return end
		if not self.healthbarPart or not self.healthbarBlockRef or self.healthbarBlockRef.blockPosition ~= blockRef.blockPosition then
			self.healthbarMaid:DoCleaning()
			self.healthbarBlockRef = blockRef
			local create = bedwars.Roact.createElement
			local percent = math.clamp(health / maxHealth, 0, 1)
			local cleanCheck = true
			local part = Instance.new('Part')
			part.Size = Vector3.one
			part.CFrame = CFrame.new(bedwars.BlockController:getWorldPosition(blockRef.blockPosition))
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.Parent = workspace
			self.healthbarPart = part
			bedwars.QueryUtil:setQueryIgnored(self.healthbarPart, true)
	
			local mounted = bedwars.Roact.mount(create('BillboardGui', {
				Size = UDim2.fromOffset(249, 102),
				StudsOffset = Vector3.new(0, 2.5, 0),
				Adornee = part,
				MaxDistance = 40,
				AlwaysOnTop = true
			}, {
				create('Frame', {
					Size = UDim2.fromOffset(160, 50),
					Position = UDim2.fromOffset(44, 32),
					BackgroundColor3 = Color3.new(),
					BackgroundTransparency = 0.5
				}, {
					create('UICorner', {CornerRadius = UDim.new(0, 5)}),
					create('ImageLabel', {
						Size = UDim2.new(1, 89, 1, 52),
						Position = UDim2.fromOffset(-48, -31),
						BackgroundTransparency = 1,
						Image = getcustomasset('newvape/assets/new/blur.png'),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(52, 31, 261, 502)
					}),
					create('TextLabel', {
						Size = UDim2.fromOffset(145, 14),
						Position = UDim2.fromOffset(13, 12),
						BackgroundTransparency = 1,
						Text = bedwars.ItemMeta[block.Name].displayName or block.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextColor3 = Color3.new(),
						TextScaled = true,
						Font = Enum.Font.Arial
					}),
					create('TextLabel', {
						Size = UDim2.fromOffset(145, 14),
						Position = UDim2.fromOffset(12, 11),
						BackgroundTransparency = 1,
						Text = bedwars.ItemMeta[block.Name].displayName or block.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextColor3 = color.Dark(uipallet.Text, 0.16),
						TextScaled = true,
						Font = Enum.Font.Arial
					}),
					create('Frame', {
						Size = UDim2.fromOffset(138, 4),
						Position = UDim2.fromOffset(12, 32),
						BackgroundColor3 = uipallet.Main
					}, {
						create('UICorner', {CornerRadius = UDim.new(1, 0)}),
						create('Frame', {
							[bedwars.Roact.Ref] = self.healthbarProgressRef,
							Size = UDim2.fromScale(percent, 1),
							BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
						}, {create('UICorner', {CornerRadius = UDim.new(1, 0)})})
					})
				})
			}), part)
	
			self.healthbarMaid:GiveTask(function()
				cleanCheck = false
				self.healthbarBlockRef = nil
				bedwars.Roact.unmount(mounted)
				if self.healthbarPart then
					self.healthbarPart:Destroy()
				end
				self.healthbarPart = nil
			end)
	
			bedwars.RuntimeLib.Promise.delay(5):andThen(function()
				if cleanCheck then
					self.healthbarMaid:DoCleaning()
				end
			end)
		end
	
		local newpercent = math.clamp((health - changeHealth) / maxHealth, 0, 1)
		tweenService:Create(self.healthbarProgressRef:getValue(), TweenInfo.new(0.3), {
			Size = UDim2.fromScale(newpercent, 1), BackgroundColor3 = Color3.fromHSV(math.clamp(newpercent / 2.5, 0, 1), 0.89, 0.75)
		}):Play()
	end
	
	local hit = 0
	
	local function switchHotbarItem(block)
		if block and not block:GetAttribute('NoBreak') and not block:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') then
			local tool, slot = store.tools[bedwars.ItemMeta[block.Name].block.breakType], nil
			if tool then
				for i, v in store.inventory.hotbar do
					if v.item and v.item.itemType == tool.itemType then slot = i - 1 break end
				end
	
				if hotbarSwitch(slot) then
					if inputService:IsMouseButtonPressed(0) then 
						event:Fire() 
					end
					return true
				end
			end
		end
	end

	local function canSee(part)
		local char = lplr.Character or lplr.CharacterAdded:Wait()
		local root = char:WaitForChild("HumanoidRootPart")

		if not part or not part:IsA("BasePart") then
			return false
		end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = {char, part}
		params.IgnoreWater = true

		local origin = root.Position
		local direction = (part.Position - origin)

		local result = workspace:Raycast(origin, direction, params)

		if not result then
			return true
		end

		return false
	end


    local function findClosestBreakableBlock(start, playerPos)
		local closestBlock = nil
		local closestDistance = math.huge
		local closestPos = nil
		local closestNormal = nil

		local vectorToNormalId = {
			[Vector3.new(1, 0, 0)] = Enum.NormalId.Right,
			[Vector3.new(-1, 0, 0)] = Enum.NormalId.Left,
			[Vector3.new(0, 1, 0)] = Enum.NormalId.Top,
			[Vector3.new(0, -1, 0)] = Enum.NormalId.Bottom,
			[Vector3.new(0, 0, 1)] = Enum.NormalId.Front,
			[Vector3.new(0, 0, -1)] = Enum.NormalId.Back
		}

		for _, side in sides do
			for i = 1, 15 do
				local blockPos = start + (side * i)
				local block = getPlacedBlock(blockPos)
				if not block or block:GetAttribute("NoBreak") then break end
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockPos / 3}, lplr) then
					local distance = (playerPos - blockPos).Magnitude
					if distance < closestDistance then
						closestDistance = distance
						closestBlock = block
						closestPos = blockPos
						local normalizedSide = side.Unit 
						for vector, normalId in pairs(vectorToNormalId) do
							if (normalizedSide - vector).Magnitude < 0.01 then 
								closestNormal = normalId
								break
							end
						end
					end
				end
			end
		end

		return closestBlock, closestPos, closestNormal
	end


	local function attemptBreak(tab, localPosition)
		if not tab then return end

		for _, v in tab do
			if (v.Position - localPosition).Magnitude < Range.Value
			and bedwars.BlockController:isBlockBreakable({blockPosition = v.Position / 3}, lplr) then

				if not SelfBreak.Enabled and v:GetAttribute('PlacedByUserId') == lplr.UserId then continue end
				if (v:GetAttribute('BedShieldEndTime') or 0) > workspace:GetServerTimeNow() then continue end
				if LimitItem.Enabled and not (store.hand.tool and bedwars.ItemMeta[store.hand.tool.Name].breakBlock) then continue end

				hit += 1

				if NB.Enabled then
					local playerPos = entitylib.character.HumanoidRootPart.Position
					local closestBlock, closestPos, closestNormal =
						findClosestBreakableBlock(v.Position, playerPos)

					if closestBlock and closestPos then
						bedwars.breakBlock(
							v,
							Effect.Enabled,
							Animation.Enabled,
							CustomHealth.Enabled and customHealthbar or nil,
							InstantBreak.Enabled,
							AT.Enabled
						)

						task.wait(
							InstantBreak.Enabled
							and (store.damageBlockFail > tick() and 4.5 or 0)
							or BreakSpeed.Value
						)

						return true
					end
				else
					bedwars.breakBlock(
						v,
						Effect.Enabled,
						Animation.Enabled,
						CustomHealth.Enabled and customHealthbar or nil,
						InstantBreak.Enabled,
						AT.Enabled
					)

					task.wait(
						InstantBreak.Enabled
						and (store.damageBlockFail > tick() and 4.5 or 0)
						or BreakSpeed.Value
					)

					return true
				end
			end
		end

		return false
	end

	
	Breaker = vape.Categories.Utility:CreateModule({
		Name = 'Nuker',
		Function = function(callback)
			if callback then
				for _ = 1, 30 do
					local part = Instance.new('Part')
					part.Anchored = true
					part.CanQuery = false
					part.CanCollide = false
					part.Transparency = 1
					part.Parent = gameCamera
					local highlight = Instance.new('BoxHandleAdornment')
					highlight.Size = Vector3.one
					highlight.AlwaysOnTop = true
					highlight.ZIndex = 1
					highlight.Transparency = 0.5
					highlight.Adornee = part
					highlight.Parent = part
					table.insert(parts, part)
				end
	
				local beds = collection('bed', Breaker)
				local luckyblock = collection('LuckyBlock', Breaker)
				local ironores = collection('iron-ore', Breaker)
				customlist = collection('block', Breaker, function(tab, obj)
					if table.find(Custom.ListEnabled, obj.Name) then
						table.insert(tab, obj)
					end
				end)
				repeat
					task.wait(1 / UpdateRate.Value)
					if not Breaker.Enabled then break end
					if entitylib.isAlive then
						local localPosition = entitylib.character.RootPart.Position
						
						if attemptBreak(Bed.Enabled and beds, localPosition) then continue end
						if attemptBreak(customlist, localPosition) then continue end
						if attemptBreak(LuckyBlock.Enabled and luckyblock, localPosition) then continue end
						if attemptBreak(IronOre.Enabled and ironores, localPosition) then continue end
	
						for _, v in parts do
							v.Position = Vector3.zero
						end
					end
				until not Breaker.Enabled
			else
				for _, v in parts do
					v:ClearAllChildren()
					v:Destroy()
				end
				table.clear(parts)
			end
		end,
		Tooltip = 'Break blocks around you automatically'
	})
	Range = Breaker:CreateSlider({
		Name = 'Break range',
		Min = 1,
		Max = 30,
		Default = 30,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	BreakSpeed = Breaker:CreateSlider({
		Name = 'Break speed',
		Min = 0,
		Max = 0.3,
		Default = 0.25,
		Decimal = 100,
		Suffix = 'seconds'
	})
	UpdateRate = Breaker:CreateSlider({
		Name = 'Update rate',
		Min = 1,
		Max = 120,
		Default = 80,
		Suffix = 'hz'
	})
	NB = Breaker:CreateToggle({
		Name = "Closest Block",
		Darker = true,
		Default = false,
		Tooltip = "Mines the nearest block to you"
	})
	AT = Breaker:CreateToggle({
		Name = "Auto Tool",
		Darker = true,
		Default = false,
		Tooltip = "Automatically selects the correct tool for you"
	})
	Custom = Breaker:CreateTextList({
		Name = 'Custom',
		Function = function()
			if not customlist then return end
			table.clear(customlist)
			for _, obj in store.blocks do
				if table.find(Custom.ListEnabled, obj.Name) then
					table.insert(customlist, obj)
				end
			end
		end
	})
	Bed = Breaker:CreateToggle({
		Name = 'Break Bed',
		Default = true
	})
	LuckyBlock = Breaker:CreateToggle({
		Name = 'Break Lucky Block',
		Default = true
	})
	IronOre = Breaker:CreateToggle({
		Name = 'Break Iron Ore',
		Default = true
	})
	Effect = Breaker:CreateToggle({
		Name = 'Show Healthbar & Effects',
		Function = function(callback)
			if CustomHealth.Object then
				CustomHealth.Object.Visible = callback
			end
		end,
		Default = true
	})
	CustomHealth = Breaker:CreateToggle({
		Name = 'Custom Healthbar',
		Default = true,
		Darker = true
	})
	Animation = Breaker:CreateToggle({Name = 'Animation'})
	SelfBreak = Breaker:CreateToggle({Name = 'Self Break'})
	InstantBreak = Breaker:CreateToggle({Name = 'Instant Break'})
	LimitItem = Breaker:CreateToggle({
		Name = 'Limit to items',
		Tooltip = 'Only breaks when tools are held'
	})
end)

run(function()
	local Viewmodel
	local Depth
	local Horizontal
	local Vertical
	local NoBob
	local Rots = {}
	local old, oldc1
	
	Viewmodel = vape.Categories.Combat:CreateModule({
		Name = 'NoBob',
		Function = function(callback)
			local viewmodel = gameCamera:FindFirstChild('Viewmodel')
			if callback then
				old = bedwars.ViewmodelController.playAnimation
				oldc1 = viewmodel and viewmodel.RightHand.RightWrist.C1 or CFrame.identity
				if NoBob.Enabled then
					bedwars.ViewmodelController.playAnimation = function(self, animtype, ...)
						if bedwars.AnimationType and animtype == bedwars.AnimationType.FP_WALK then return end
						return old(self, animtype, ...)
					end
				end
	
				bedwars.InventoryViewmodelController:handleStore(bedwars.Store:getState())
				if viewmodel then
					gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(Rots[1].Value), math.rad(Rots[2].Value), math.rad(Rots[3].Value))
				end
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -Depth.Value)
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', Horizontal.Value)
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', Vertical.Value)
			else
				bedwars.ViewmodelController.playAnimation = old
				if viewmodel then
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
	
				bedwars.InventoryViewmodelController:handleStore(bedwars.Store:getState())
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', 0)
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', 0)
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', 0)
				old = nil
			end
		end,
		Tooltip = 'Changes the viewmodel animations'
	})
	Depth = Viewmodel:CreateSlider({
		Name = 'Depth',
		Min = 0,
		Max = 2,
		Default = 0.8,
		Decimal = 10,
		Function = function(val)
			if Viewmodel.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -val)
			end
		end
	})
	Horizontal = Viewmodel:CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 2,
		Default = 0.8,
		Decimal = 10,
		Function = function(val)
			if Viewmodel.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', val)
			end
		end
	})
	Vertical = Viewmodel:CreateSlider({
		Name = 'Vertical',
		Min = -0.2,
		Max = 2,
		Default = -0.2,
		Decimal = 10,
		Function = function(val)
			if Viewmodel.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', val)
			end
		end
	})
	for _, name in {'Rotation X', 'Rotation Y', 'Rotation Z'} do
		table.insert(Rots, Viewmodel:CreateSlider({
			Name = name,
			Min = 0,
			Max = 360,
			Function = function(val)
				if Viewmodel.Enabled then
					gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(Rots[1].Value), math.rad(Rots[2].Value), math.rad(Rots[3].Value))
				end
			end
		}))
	end
	NoBob = Viewmodel:CreateToggle({
		Name = 'No Bobbing',
		Default = true,
		Function = function()
			if Viewmodel.Enabled then
				Viewmodel:Toggle()
				Viewmodel:Toggle()
			end
		end
	})
end)

run(function()
	local Value
	local WallCheck
	local AutoJump
	local AlwaysJump
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	
	Speed = vape.Categories.Blatant:CreateModule({
		Name = 'Speed',
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end    																																																							
			frictionTable.Speed = callback or nil
			updateVelocity()

	
			if callback then
				Speed:Clean(runService.PreSimulation:Connect(function(dt)
					bedwars.StatefulEntityKnockbackController.lastImpulseTime = callback and math.huge or time()
					if entitylib.isAlive and not Fly.Enabled and not InfiniteFly.Enabled and not LongJump.Enabled and isnetworkowner(entitylib.character.RootPart) then
						local state = entitylib.character.Humanoid:GetState()
						if state == Enum.HumanoidStateType.Climbing then return end
	
						local root, velo = entitylib.character.RootPart, getSpeed()
						local moveDirection = AntiFallDirection or entitylib.character.Humanoid.MoveDirection
						local destination = (moveDirection * math.max(Value.Value - velo, 0) * dt)
	
						if WallCheck.Enabled then
							rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
							rayCheck.CollisionGroup = root.CollisionGroup
							local ray = workspace:Raycast(root.Position, destination, rayCheck)
							if ray then
								destination = ((ray.Position + ray.Normal) - root.Position)
							end
						end
	
						root.CFrame += destination
						root.AssemblyLinearVelocity = (moveDirection * velo) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
						if AutoJump.Enabled and (state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed) and moveDirection ~= Vector3.zero and (Attacking or AlwaysJump.Enabled) then
							entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end
					end
				end))
			end
		end,
		ExtraText = function()
			return 'Heatseeker'
		end,
		Tooltip = 'Increases your movement with various methods. (higher than 23 will cause major anti-cheat)'
	})
	Value = Speed:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 45,
		Default = 23,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	WallCheck = Speed:CreateToggle({
		Name = 'Wall Check',
		Default = false
	})
	AutoJump = Speed:CreateToggle({
		Name = 'AutoJump',
		Function = function(callback)
			AlwaysJump.Object.Visible = callback
		end
	})
	AlwaysJump = Speed:CreateToggle({
		Name = 'Always Jump',
		Visible = false,
		Darker = true
	})
end)

run(function()
	local Value
	local VerticalValue
	local WallCheck
	local PopBalloons
	local TP
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	local up, down, old = 0, 0

	Fly = vape.Categories.Blatant:CreateModule({
		Name = 'Fly',
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end    																																																							
			frictionTable.Fly = callback or nil
			updateVelocity()
			if callback then
				up, down, old = 0, 0, bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end
				local tpTick, tpToggle, oldy = tick(), true

				if lplr.Character and (lplr.Character:GetAttribute('InflatedBalloons') or 0) == 0 and getItem('balloon') then
					bedwars.BalloonController:inflateBalloon()
				end
				Fly:Clean(vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed == 'InflatedBalloons' and (lplr.Character:GetAttribute('InflatedBalloons') or 0) == 0 and getItem('balloon') then
						bedwars.BalloonController:inflateBalloon()
					end
				end))
				Fly:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive and not InfiniteFly.Enabled and isnetworkowner(entitylib.character.RootPart) then
						local flyAllowed = (lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or store.matchState == 2
						local mass = (1.5 + (flyAllowed and 6 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)) + ((up + down) * VerticalValue.Value)
						local root, moveDirection = entitylib.character.RootPart, entitylib.character.Humanoid.MoveDirection
						local velo = getSpeed()
						local destination = (moveDirection * math.max(Value.Value - velo, 0) * dt)
						rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, AntiFallPart}
						rayCheck.CollisionGroup = root.CollisionGroup

						if WallCheck.Enabled then
							local ray = workspace:Raycast(root.Position, destination, rayCheck)
							if ray then
								destination = ((ray.Position + ray.Normal) - root.Position)
							end
						end

						if not flyAllowed then
							if tpToggle then
								local airleft = (tick() - entitylib.character.AirTime)
								if airleft > 2 then
									if not oldy then
										local ray = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rayCheck)
										if ray and TP.Enabled then
											tpToggle = false
											oldy = root.Position.Y
											tpTick = tick() + 0.11
											root.CFrame = CFrame.lookAlong(Vector3.new(root.Position.X, ray.Position.Y + entitylib.character.HipHeight, root.Position.Z), root.CFrame.LookVector)
										end
									end
								end
							else
								if oldy then
									if tpTick < tick() then
										local newpos = Vector3.new(root.Position.X, oldy, root.Position.Z)
										root.CFrame = CFrame.lookAlong(newpos, root.CFrame.LookVector)
										tpToggle = true
										oldy = nil
									else
										mass = 0
									end
								end
							end
						end

						root.CFrame += destination
						root.AssemblyLinearVelocity = (moveDirection * velo) + Vector3.new(0, mass, 0)
					end
				end))
				Fly:Clean(inputService.InputBegan:Connect(function(input)
					if not inputService:GetFocusedTextBox() then
						if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
							up = 1
						elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL2 then
							down = -1
						end
					end
				end))
				Fly:Clean(inputService.InputEnded:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
						up = 0
					elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL2 then
						down = 0
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						Fly:Clean(jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							up = jumpButton.ImageRectOffset.X == 146 and 1 or 0
						end))
					end)
				end
			else
				bedwars.BalloonController.deflateBalloon = old
				if PopBalloons.Enabled and entitylib.isAlive and (lplr.Character:GetAttribute('InflatedBalloons') or 0) > 0 then
					for _ = 1, 3 do
						bedwars.BalloonController:deflateBalloon()
					end
				end
			end
		end,
		ExtraText = function()
			return 'Heatseeker'
		end,
		Tooltip = 'Makes you go zoom.'
	})
	Value = Fly:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Default = 23,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	VerticalValue = Fly:CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 150,
		Default = 50,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	WallCheck = Fly:CreateToggle({
		Name = 'Wall Check',
		Default = true
	})
	PopBalloons = Fly:CreateToggle({
		Name = 'Pop Balloons',
		Default = true
	})
	TP = Fly:CreateToggle({
		Name = 'TP Down',
		Default = true
	})
end)
																																																						
run(function()	

	NM = vape.Categories.Render:CreateModule({
		Name = 'Nightmare Emote',
		Tooltip = 'Client-Sided nightmare emote, animation is Server-Side visuals are Client-Sided',
		Function = function(callback)
			if callback then				
				local CharForNM = lplr.Character
				
				if not CharForNM then return end
				
				local NightmareEmote = replicatedStorage:WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("NightmareEmote"):Clone()
				asset = NightmareEmote
				NightmareEmote.Parent = game.Workspace
				lastPosition = CharForNM.PrimaryPart and CharForNM.PrimaryPart.Position or Vector3.new()
				
				task.spawn(function()
					while asset ~= nil do
						local currentPosition = CharForNM.PrimaryPart and CharForNM.PrimaryPart.Position
						if currentPosition and (currentPosition - lastPosition).Magnitude > 0.1 then
							asset:Destroy()
							asset = nil
							NM:Toggle()
							break
						end
						lastPosition = currentPosition
						NightmareEmote:SetPrimaryPartCFrame(CharForNM.LowerTorso.CFrame + Vector3.new(0, -2, 0))
						task.wait(0.1)
					end
				end)
				
				local NMDescendants = NightmareEmote:GetDescendants()
				local function PartStuff(Prt)
					if Prt:IsA("BasePart") then
						Prt.CanCollide = false
						Prt.Anchored = true
					end
				end
				for i, v in ipairs(NMDescendants) do
					PartStuff(v, i - 1, NMDescendants)
				end
				local Outer = NightmareEmote:FindFirstChild("Outer")
				if Outer then
					tweenService:Create(Outer, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = Outer.Orientation + Vector3.new(0, 360, 0)
					}):Play()
				end
				local Middle = NightmareEmote:FindFirstChild("Middle")
				if Middle then
					tweenService:Create(Middle, TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = Middle.Orientation + Vector3.new(0, -360, 0)
					}):Play()
				end
                anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://9191822700"
				anim = CharForNM.Humanoid:LoadAnimation(anim)
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
	GetHost = vape.Categories.Render:CreateModule({
		Name = "GetHost",
		Tooltip = "this module is only for show. None of the settings will work.",
		Function = function(callback) 
			if callback then
				lplr:SetAttribute("CustomMatchRole", "host")
			else
				lplr:SetAttribute("CustomMatchRole", nil)
			end	
		end
	})
end)

run(function()
	local KitESP
	local Background
	local Color = {}
	local Reference = {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	
	local ESPKits = {
		alchemist = {'alchemist_ingedients', 'wild_flower'},
		beekeeper = {'bee', 'bee'},
		bigman = {'treeOrb', 'natures_essence_1'},
		ghost_catcher = {'ghost', 'ghost_orb'},
		metal_detector = {'hidden-metal', 'iron'},
		sheep_herder = {'SheepModel', 'purple_hay_bale'},
		sorcerer = {'alchemy_crystal', 'wild_flower'},
		star_collector = {'stars', 'crit_star'},
		black_market_trader = {'shadow_coin', 'shadow_coin'},
	}
	
	local function Added(v, icon)
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = Folder
		billboard.Name = icon
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
		billboard.Size = UDim2.fromOffset(36, 36)
		billboard.AlwaysOnTop = true
		billboard.ClipsDescendants = false
		billboard.Adornee = v
		local blur = addBlur(billboard)
		blur.Visible = Background.Enabled
		local image = Instance.new('ImageLabel')
		image.Size = UDim2.fromOffset(36, 36)
		image.Position = UDim2.fromScale(0.5, 0.5)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
		image.BackgroundTransparency = 1 - (Background.Enabled and Color.Opacity or 0)
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.Parent = billboard
		local uicorner = Instance.new('UICorner')
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		Reference[v] = billboard
	end
	
	local function addKit(tag, icon)
		KitESP:Clean(collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			Added(v.PrimaryPart, icon)
		end))
		KitESP:Clean(collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if Reference[v.PrimaryPart] then
				Reference[v.PrimaryPart]:Destroy()
				Reference[v.PrimaryPart] = nil
			end
		end))
		for _, v in collectionService:GetTagged(tag) do
			Added(v.PrimaryPart, icon)
		end
	end
	
	KitESP = vape.Categories.Utility:CreateModule({
		Name = 'KitESP',
		Function = function(callback)
			if callback then
				repeat task.wait() until store.equippedKit ~= '' or (not KitESP.Enabled)
				local kit = KitESP.Enabled and ESPKits[store.equippedKit] or nil
				if kit then
					addKit(kit[1], kit[2])
				end
			else
				Folder:ClearAllChildren()
				table.clear(Reference)
			end
		end,
		Tooltip = 'ESP for certain kit related objects'
	})
	Background = KitESP:CreateToggle({
		Name = 'Background',
		Function = function(callback)
			if Color.Object then Color.Object.Visible = callback end
			for _, v in Reference do
				v.ImageLabel.BackgroundTransparency = 1 - (callback and Color.Opacity or 0)
				v.Blur.Visible = callback
			end
		end,
		Default = true
	})
	Color = KitESP:CreateColorSlider({
		Name = 'Background Color',
		DefaultValue = 0,
		DefaultOpacity = 0.5,
		Function = function(hue, sat, val, opacity)
			for _, v in Reference do
				v.ImageLabel.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
				v.ImageLabel.BackgroundTransparency = 1 - opacity
			end
		end,
		Darker = true
	})
end)																																
																																																								
run(function()
    local PlayerLevel
	local level 
	local old

	PlayerLevel = vape.Categories.Utility:CreateModule({
        Name = 'SetPlayerLevel',
		Tooltip = "Sets your player level to 1000 (client sided)",
        Function = function(callback)
			if callback then
				old = lplr:GetAttribute("PlayerLevel")
				lplr:SetAttribute("PlayerLevel", level.Value)
			else
				lplr:SetAttribute("PlayerLevel", old)
				old = nil
			end
		end
	})

	level = PlayerLevel:CreateSlider({
		Name = 'Player Level',
		Min = 1,
		Max = 1000,
		Default = 100,
		Function = function(val)
			if PlayerLevel.Enabled then
				lplr:SetAttribute("PlayerLevel", val)
			end
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
		['skeleton'] = "rbxassetid://120123419412119",
		['winter_lady'] = "rbxassetid://83274578564074",
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
        icon.Image = ids[plr:GetAttribute("PlayingAsKits")] or ids["none"]
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
        icon.Image = ids[plr:GetAttribute("PlayingAsKits")] or ids["none"]
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
                    task.wait(0.95)
                end
            end)
        end)
    end

    KitRender = vape.Categories.Utility:CreateModule({
        Name = "KitRender",
        Tooltip = "Allows you to see everyone's kit during kit phase (5v5, Ranked)",
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
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

	local A
	local T
	local L
	local C
	local AJ
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

    BetterDavey = vape.Categories.Support:CreateModule({
        Name = "BetterDavey",
        Tooltip = "makes u look better with davey",
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
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
						local humanoid = entitylib.character.Humanoid
					
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

						if AJ.Enabled then
							if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
								humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end
						end
					end))
                    end
                end))
            else
                setCannonSpeeds(blocks, defaultaim, defaulttnt, defaultself)
            end
        end
    })
	AJ = BetterDavey:CreateToggle({
		Name = "Auto-Jump",
		Default = true																																																						
	})																																																					
	A = BetterDavey:CreateSlider({
		Name = "Aim",
		Visible = false,
		Min = 0,
		Max = 1,
		Default = aim,
		Decimal = 10,
		Function = function(v)
			aim = v
            local worldFolder = getWorldFolder()
            if not worldFolder then return end
            local blocks = worldFolder:WaitForChild("Blocks")
            setCannonSpeeds(blocks, aim, tnt, aunchself)
		end
	})

	T = BetterDavey:CreateSlider({
		Name = "Tnt",
		Visible = false,
		Min = 0,
		Max = 1,
		Default = tnt,
		Decimal = 10,
		Function = function(v)
			tnt = v
            local worldFolder = getWorldFolder()
            if not worldFolder then return end
            local blocks = worldFolder:WaitForChild("Blocks")
            setCannonSpeeds(blocks, aim, tnt, aunchself)
		end
	})

	L = BetterDavey:CreateSlider({
		Name = "Launch Self",
		Visible = false,
		Min = 0,
		Max = 1,
		Default = aunchself,
		Decimal = 10,
		Function = function(v)
			aunchself = v
            local worldFolder = getWorldFolder()
            if not worldFolder then return end
            local blocks = worldFolder:WaitForChild("Blocks")
            setCannonSpeeds(blocks, aim, tnt, aunchself)
		end
	})

	C = BetterDavey:CreateToggle({
		Name = "Customize",
		Default = false,
		Function = function(v)
			A.Object.Visible = v
			T.Object.Visible = v
			L.Object.Visible = v
			if not v then
				aim = 0.158
				tnt = 0.0045
				aunchself = 0.395
			end
		end
	})

end)
run(function() 
    local MatchHistory
    
    MatchHistory = vape.Categories.AltFarm:CreateModule({
        Name = "MatchHistory",
        Tooltip = "Resets your match history",
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end      
            if callback then 
                MatchHistory:Toggle(false)
                local TeleportService = game:GetService("TeleportService")
                local data = TeleportService:GetLocalPlayerTeleportData()
                MatchHistory:Clean(TeleportService:Teleport(game.PlaceId, lplr, data))
            end
        end,
    }) 
end)

run(function() 
	local AutoBan
	local Mode
	local Delay

	local function AltFarmBAN(cb,delay)
		while cb do
			local kits = {"berserker", "hatter", "flower_bee", "glacial_skater",'void_dragon','card','cat'}
			for _, kit in ipairs(kits) do
				for i = 0, 1 do
					local args = {kit, i}
					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("BanKit"):InvokeServer(unpack(args))		
				end
			end
			for i = 0, 1 do
				local args = {"none", i}
				game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SelectKit"):InvokeServer(unpack(args))		
			end
			task.wait(delay)
		end
	end

	local function SmartBAN(cb,delay)
		local kits = {'metal_detector','berserker','regent','cowgirl','wizard','summoner','pinata','davey','fisherman','gingerbread_man','airbender','ninja','star_collector','winter_lady','blood_assassin','owl','elk_master','seahorse','shielder','bigman','archer','black_market_trader'}
		while cb do
			for _, kit in ipairs(kits) do
				for i = 0, 1 do
					local args = {kit, i}
					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("BanKit"):InvokeServer(unpack(args))		
				end
			end
			task.wait(delay)
		end
	end


	local function NormalBAN(cb,delay)
		local kits = {'metal_detector','cowgirl','wizard','summoner','airbender','ninja','star_collector','blood_assassin','seahorse','agni','dasher','elektra','davey','black_market_trader'}
		while cb do
			for _, kit in ipairs(kits) do
				for i = 0, 1 do
					local args = {kit, i}
					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("BanKit"):InvokeServer(unpack(args))		
				end
			end
			task.wait(delay)
		end
	end

	local function MainBranch(callback,type,delay)
		if type == "Alt Farm" then
			AltFarmBAN(callback,0.1)
		elseif type == "Smart" then
			SmartBAN(callback,delay)
		elseif type == "Normal" then
			NormalBAN(callback,delay)
		else
			AltFarmBAN(callback,0.1)
		end
	end

	AutoBan = vape.Categories.AltFarm:CreateModule({
		Name = "AutoBan",
		Tooltip = 'Automatically bans a kit for you(5v5, ranked only)',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end      
			MainBranch(callback, Mode.Value,(Delay.Value / 1000))
		end,
	})
	Mode = AutoBan:CreateDropdown({
		Name = "Mode",
		Tooltip = "Alt Farm=AutoBans And Auto Selects ur kit used for alt farming insta bans and selection\nSmart=Selects a good/op kit depending on the match\nNormal=Selects basic/good kits for the match",
		List = {"Alt Farm","Smart","Normal"},
		Function = function()
			if Mode.Value == "Smart" or Mode.Value == "Normal" then
				Delay.Object.Visible = true
			else
				Delay.Object.Visible = false
			end
		end
	})
	Delay = AutoBan:CreateSlider({
		Name = "Delay",
		Visible = false,
		Min = 1,
		Max = 1000,
		Suffix = "ms",
	})
end)

run(function()
	local ItemlessLongjump = {Enabled = false}
	local added = 0
	ItemlessLongjump = vape.Categories.Blatant:CreateModule({
		Name = "ItemlessLongjump",
		Function = function(call)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			ItemlessLongjump.Enabled = call
			if call then
				added = 100																																																																																																																																																		
				lplr.Character.HumanoidRootPart.Velocity += Vector3.new(0, 100, 0)
				task.wait(0.3)
				added = 0																																																																																																																																																		
				for i = 1, 4 do
					task.wait(0.4)
					added += 75
					lplr.Character.HumanoidRootPart.Velocity += Vector3.new(0, 75, 0)
				end
				added = 0
				task.wait(0.025)
				for i = 1, 2 do
					task.wait(0.125)
					added += 85
					lplr.Character.HumanoidRootPart.Velocity += Vector3.new(0, 85, 0)
				end

			else
				repeat 
				added = added - 10
				lplr.Character.HumanoidRootPart.Velocity -= Vector3.new(0,added,0)
				task.wait(0.0025)
				until added == 0
			end
		end,
		Tooltip = "Lets you do a longjump without any items/kits"
	})
end)


run(function()
	local AutoQueue
	local Bypass
	AutoQueue = vape.Categories.Utility:CreateModule({
		Name = 'AutoQueue',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end       
			if callback then
				if Bypass.Enabled then
					bedwars.Client:Get('AfkInfo'):SendToServer({afk = false})
					task.wait(0.025)
					AutoQueue:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
						if deathTable.finalKill and deathTable.entityInstance == lplr.Character and isEveryoneDead() and store.matchState ~= 2 then
							bedwars.Client:Get('AfkInfo'):SendToServer({afk = false})
							joinQueue()
						end
					end))
					AutoQueue:Clean(vapeEvents.MatchEndEvent.Event:Connect(function(...)
						bedwars.Client:Get('AfkInfo'):SendToServer({afk = false})
						joinQueue()
					end))
				else
					AutoQueue:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
						if deathTable.finalKill and deathTable.entityInstance == lplr.Character and isEveryoneDead() and store.matchState ~= 2 then
							joinQueue()
						end
					end))
					AutoQueue:Clean(vapeEvents.MatchEndEvent.Event:Connect(joinQueue))
				end
			end
		end,
		Tooltip = 'Automatically queues for the next match'
	})
	Bypass = AutoQueue:CreateToggle({
		Name = "Bypass",
		Default = true
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
        Tooltip = 'Enhances the Queues display with dynamic gradients!! very cool lel xd nigger',
        Function = function(enabled)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
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


local Killaura
local ChargeTime
run(function()
	local SlientAura
	local Distance

	local currentTarget
	local chargeStart = 0
	local chargeDuration = 0

	SlientAura = vape.Categories.Combat:CreateModule({
		Name = "SlientAura",
		Tooltip = "Synchronizes swing timing with AimAssist within a 180 angle",
		Function = function(callback)
			if callback then
				if not Killaura.Enabled then
					vape:CreateNotification("SlientAura","You must have KillAura enabled!",8.5,"warning")
					SlientAura:Toggle(false)
					return
				end

				SlientAura:Clean(runService.Heartbeat:Connect(function(dt)
					if entitylib.isAlive then
						local ent = entitylib.EntityPosition({
							Range = Distance.Value,
							Part = "RootPart",
							Wallcheck = true,
							Players = true,
							NPCs = false,
							Sort = "Distance"
						})

						local root = entitylib.character.RootPart
						local delta = ent.RootPart.Position - root.Position
						local localfacing = root.CFrame.LookVector * Vector3.new(1, 0, 1)
						local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
						if angle > (math.rad(360) / 2) then return end
						if ent then
							chargeStart = tick()
							local base = math.clamp(ChargeTime.Value / 10, 0.1, 1)
							chargeDuration = math.clamp(base + math.random(-5, 5) / 100,0.1,1)

							local progress = math.clamp((tick() - chargeStart) / chargeDuration,0,1)
							local eased = progress * progress * (3 - 2 * progress)

							gameCamera.CFrame = gameCamera.CFrame:Lerp(CFrame.lookAt(gameCamera.CFrame.Position,ent.RootPart.Position),eased)
						end

					end
				end))
			end
		end
	})

	Distance = SlientAura:CreateSlider({
		Name = "Distance",
		Min = 1,
		Max = 30,
		Default = 12,
		Suffix = function(v)
			return v <= 1 and "stud" or "studs"
		end
	})

end)


run(function()

	local SyncHit
	local Targets
	local Sort
	local SwingRange
	local AttackRange
	local AfterSwing
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
	local SC = {Enabled = true}
	local RV
	local HR
	local FastHits
	local HitsDelay
	local HRTR = {
		[1] = 0.042,
		[2] = 0.0042,
	}
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

				if Animation.Enabled and not (identifyexecutor and table.find({'Argon', 'Delta','Codex'}, ({identifyexecutor()})[1])) then
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
						if SC.Enabled and entitylib.isAlive and lplr.Character:FindFirstChild("elk") then return end
						local isClaw = string.find(string.lower(tostring(sword and sword.itemType or "")), "summoner_claw")	
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
							if store.equippedKit == "ember" and sword.itemType == "infernal_saber" then
								bedwars.Client:Get('HellBladeRelease'):FireServer({chargeTime = 1, player = lplr, weapon = sword.tool})
							end
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
									swingCooldown = SyncHit.Enabled and (tick() - HRTR[1]) or tick()
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									store.attackReach = SyncHit.Enabled and ((delta.Magnitude * 100) // 1 / 100 - HRTR[1] - 0.055) or (delta.Magnitude * 100) // 1 / 100 - 0.055
									store.attackReachUpdate = SyncHit.Enabled and (tick() + 1 - HRTR[2]) or tick() + 1


									if delta.Magnitude < 14.4 and ChargeTime.Value > 0.11 then
										AnimDelay =  tick()
									end

									local Q = 0.5
									if SyncHit.Enabled  then Q = 0.35 else Q = 0.5 end
										if isClaw then
											KaidaController:request(v.Character)
										else
												AttackRemote:FireServer({
														weapon = sword.tool,
														chargedAttack = {chargeRatio = 0},
														entityInstance = v.Character,
														validate = {
															raycast = {},
															targetPosition = {value = actualRoot.Position},
															selfPosition = {value = pos}
														}
													})
										if not v.Character then
											print("player is dead")
										end
									end
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

					task.wait(1 / UpdateRate.Value)
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

	HR = Killaura:CreateSlider({
		Name = 'Hit Registration',
		Min = 1,
		Max = 36,
		Default = 36.5,
		Function = function(val)
			local function RegMath(sliderValue)
				local minValue1 = 0.042
				local maxValue1 = 0.045

				local minValue2 = 0.0042
				local maxValue2 = 0.0045

				local steps = 35 

				local value1 = minValue1 + ((sliderValue - 1) * ((maxValue1 - minValue1) / steps))
				local value2 = minValue2 + ((sliderValue - 1) * ((maxValue2 - minValue2) / steps))

				return math.abs(value1), math.abs(value2)
			end

			if Killaura.Enabled then
				local v1,v2 = RegMath(val)
				HRTR[1] = v1
				HRTR[2] = v2
			end
		end
	})

	local MaxRange = 0
	local CE = false
	if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"  then
		MaxRange = 14
		CE = false
		SyncHit = {Enabled = false}
	elseif role == "user" then
		MaxRange = 18
		CE = false
		SyncHit = Killaura:CreateToggle({
			Name = 'Sync Hit-Time',
			Tooltip = "Synchronize's ur hit time",
			Default = false,
		})
	elseif role == "premium" then
		MaxRange = 24
		CE = true
		SyncHit = Killaura:CreateToggle({
			Name = 'Sync Hit-Time',
			Tooltip = "Synchronize's ur hit time",
			Default = false,
		})
	elseif role == "friend" or role == "admin" or role == "coowner" or role == "owner" then
		MaxRange = 32
		CE = true
		SyncHit = Killaura:CreateToggle({
			Name = 'Sync Hit-Time',
			Tooltip = "Synchronize's ur hit time",
			Default = false,
		})
	else
		MaxRange = 18
		SyncHit = {Enabled = false}
	end

	SwingRange = Killaura:CreateSlider({
		Name = 'Swing range',
		Min = 1,
		Edit = CE,
		Max = MaxRange,
		Default = 18,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AttackRange = Killaura:CreateSlider({
		Name = 'Attack range',
		Min = 1,
		Max = MaxRange,
		Edit = CE,
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
	LegitAura = Killaura:CreateToggle({
		Name = 'Legit Aura',
		Tooltip = 'Only attacks when the mouse is clicking'
	})
end)


	run(function()
		local AutoWin
		local empty
		local Dashes = {Value = 2}
		if role ~= "owner" and  role ~= "coowner" and user ~= "generalcyan" and user ~= "yorender" and user ~= 'black'  then
			return 
		end
		AutoWin = vape.Categories.AltFarm:CreateModule({
			Name = 'AutoWinElektra',
			Function = function(callback)
				if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
					vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
					return
				end 
				if not callback then
					return  
				end
				if store.equippedKit == "elektra" then
					repeat task.wait(0.1) until store.matchState ~= 0 or (not AutoWin.Enabled)
					local beds = {}
					local currentbedpos 
					local function AllbedPOS()
						if workspace:FindFirstChild("MapCFrames") then
							for _, obj in ipairs(workspace:FindFirstChild("MapCFrames"):GetChildren()) do
								if string.match(obj.Name, "_bed$") then
									table.insert(beds, obj.Value.Position)
								end
							end
						end
					end
					local function UpdateCurrentBedPOS()
						if workspace:FindFirstChild("MapCFrames") then
							local currentTeam =  lplr.Character:GetAttribute("Team")
							if workspace:FindFirstChild("MapCFrames") then
								local CFRameName = tostring(currentTeam).."_bed"
								currentbedpos = workspace:FindFirstChild("MapCFrames"):FindFirstChild(CFRameName).Value.Position
							end
						end
					end
					local function closestBed(origin)
						local closest, dist
						for _, pos in ipairs(beds) do
							if pos ~= currentbedpos then
								local d = (pos - origin).Magnitude
								if not dist or d < dist then
									dist, closest = d, pos
								end
							end
						end
						return closest
					end
					local function tweenToBED(pos)
						if entitylib.isAlive then
							pos = pos + Vector3.new(0, 5, 0)
							local currentPosition = entitylib.character.RootPart.Position
							if (pos - currentPosition).Magnitude > 0.5 then
								if lplr.Character then
									lplr:SetAttribute('LastTeleported', 0)
								end
								local info = TweenInfo.new(0.72,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
								local tween = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.new(pos)})
								task.spawn(function() tween:Play() end)
								task.spawn(function()
								if Dashes.Value == 1 then
									task.wait(0.54)
									if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
										vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
										
										bedwars.AbilityController:useAbility('ELECTRIC_DASH')
									end
								elseif Dashes.Value == 2 then
									task.wait(0.36)
									if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
										vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
										bedwars.AbilityController:useAbility('ELECTRIC_DASH')
									end
									task.wait(0.54)
									if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
										vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
										bedwars.AbilityController:useAbility('ELECTRIC_DASH')
									end
								else
									task.wait(0.54)
									if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
										vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
										bedwars.AbilityController:useAbility('ELECTRIC_DASH')
									end				
								end

								end)
								task.spawn(function()
									tween.Completed:Wait()
								end)
								lplr:SetAttribute('LastTeleported', os.time())
								task.wait(0.25)
								if lplr.Character then
									task.wait(0.1235)
									lplr:SetAttribute('LastTeleported', os.time())
								end
							end
						end
					end
					AllbedPOS()
					UpdateCurrentBedPOS()
					bedpos = closestBed(entitylib.character.RootPart.Position)
					tweenToBED(bedpos)
				else
					vape:CreateNotification("AutoWin", "You need elektra for this method", 8,"warning")
				end
			end,
			Tooltip = 'new method for autowin! will be patched very soon:(' -- GGS METHOD IS PATCHED
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
	
	Disabler = vape.Categories.Utility:CreateModule({
		Name = 'Disabler',
		Function = function(callback)
			if callback then
				Disabler:Clean(entitylib.Events.LocalAdded:Connect(characterAdded))
				if entitylib.isAlive then
					characterAdded(entitylib.character)
				end
			end
		end,
		Tooltip = 'Disables GetPropertyChangedSignal detections for anti cheat'
	})
end)


run(function()
    local TypeData
    local PlayerData
    local includeEmptyMatches
	local Clean
    PlayerData = vape.Categories.Exploits:CreateModule({
        Name = "PlayerData",
        Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
	    	if not callback then return end

            local http = httpService
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
	local LP 
	 LP = vape.Categories.Exploits:CreateModule({
		Name = "LeaveParty",
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end   																															
			if callback then
				LP:Toggle(false)
				bedwars.PartyController:leaveParty()
			end
		end,
		Tooltip = "Makes u leave ur current party",
	})
end)

run(function()
	local Desync
	local enabled
	Desync = vape.Categories.World:CreateModule({
		Name = 'Desync',
		Function = function(callback)
			local function cb1()

				if not setfflag then vape:CreateNotification("Onyx", "Your current executor '"..identifyexecutor().."' does not support setfflag", 6, "warning"); return end     
				if callback then
					setfflag('NextGenReplicatorEnabledWrite4', 'true')
				else
					setfflag('NextGenReplicatorEnabledWrite4', 'false')
				end
			end
			local function cb2()
				vape:CreateNotification("Desync","Disabled...",8,'warning')
			end
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end
			vape:CreatePoll("Desync","Are you sure you want to use this?",8,"warning",cb1,cb2)
		end,
		Tooltip = 'Note this will ban you for client modifications.'
	})

end)



run(function()
    local Antihit = {Enabled = false}
    local Range, TimeUp, Down = 16, 0.2,0.05

    Antihit = vape.Categories.Blatant:CreateModule({
        Name = "AntiHit",
        Function = function(call)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
            if call then
                task.spawn(function()
                    while Antihit.Enabled do
                        local root = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            local orgPos = root.Position
                            local foundEnemy = false

                            for _, v in next, playersService:GetPlayers() do
                                if v ~= lplr and v.Team ~= lplr.Team then
                                    local enemyChar = v.Character
                                    local enemyRoot = enemyChar and enemyChar:FindFirstChild("HumanoidRootPart")
                                    local enemyHum = enemyChar and enemyChar:FindFirstChild("Humanoid")
                                    if enemyRoot and enemyHum and enemyHum.Health > 0 then
                                        local dist = (root.Position - enemyRoot.Position).Magnitude
                                        if dist <= Range.Value then
                                            foundEnemy = true
                                            break
                                        end
                                    end
                                end
                            end

                            if foundEnemy then
                                root.CFrame = CFrame.new(orgPos + Vector3.new(0, -230, 0))
                                task.wait(TimeUp.Value)
                                if Antihit.Enabled and lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                                    lplr.Character.HumanoidRootPart.CFrame = CFrame.new(orgPos)
                                end
                            end
                        end
                        task.wait(Down.Value)
                    end
                end)
            end
        end,
        Tooltip = "Prevents you from dying"
    })

    Range = Antihit:CreateSlider({
        Name = "Range",
        Min = 0,
        Max = 50,
        Default = 15,
        Function = function(val) Range.Value = val end
    })

    TimeUp = Antihit:CreateSlider({
        Name = "Time Up",
        Min = 0,
        Max = 1,
        Default = 0.2,
        Function = function(val) TimeUp.Value = val end
    })

    Down = Antihit:CreateSlider({
        Name = "Time Down",
        Min = 0,
        Max = 1,
        Default = 0.05,
        Function = function(val) Down.Value = val end
    })
end)

run(function()
    local BlockIn
    local PD
    local UseBlacklisted_Blocks
    local blacklisted
	local SlientAim
	local LimitedToItem

    local function getBlocks()
        local blocks = {}

        for _, item in store.inventory.inventory.items do
            local block = bedwars.ItemMeta[item.itemType].block
			print(block)
            if block then
                table.insert(blocks, { item.itemType, block.health })
            end
        end

        table.sort(blocks, function(a, b)
            return a[2] < b[2]
        end)

        return blocks
    end

    local function getPyramid(size, grid)
        return {
            Vector3.new(3, 0, 0),
            Vector3.new(0, 0, 3),
            Vector3.new(-3, 0, 0),
            Vector3.new(0, 0, -3),
            Vector3.new(3, 3, 0),
            Vector3.new(0, 3, 3),
            Vector3.new(-3, 3, 0),
            Vector3.new(0, 3, -3),
            Vector3.new(0, 6, 0),
            Vector3.new(0, -2.8, 0),
        }
    end

    BlockIn = vape.Categories.Blatant:CreateModule({
        Name = "BlockIn",
        Tooltip = "Automatically places strong blocks around the me.",
        Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			local number = 0
            if not callback then 
                return 
            end

            local me = entitylib.isAlive and entitylib.character.RootPart.Position or nil
            if not me then
                notif("BlockIn", "Unable to locate me", 5, "warning")
                BlockIn:Toggle(false)
                return
            end

            local item = getBlocks()
            if not item or #item == 0 then
                notif("BlockIn", "No blocks found in inventory!", 5, "warning")
                BlockIn:Toggle(false)
                return
            end
			for i, block in ipairs(item) do
			    for _, pos in ipairs(getPyramid(i, 3)) do
			        if not BlockIn.Enabled then 
			            break 
			        end
			
			        local targetPos = me + pos
			        if getPlacedBlock(targetPos) then 
			            continue 
			        end
					task.spawn(function()
						for i=0,8 do
					    	number = i
							task.wait(PD.Value / 100)																													
						end
					end)
					local woolitem,amount = getWool()
					switchItem(woolitem)
					repeat
    					task.spawn(bedwars.placeBlock, targetPos, block[1])
   						task.wait(PD.Value / 100)
    				until number == 8
			    end
			end
			
			if BlockIn.Enabled then
			    BlockIn:Toggle(false)
			end
        end
    })

	LimitedToItem = BlockIn:CreateToggle({
		Name = "Limited To Item",
		Default = false
	})

	SlientAim = BlockIn:CreateToggle({
		Name = "SlientAim",
		Default = false
	})

    PD = BlockIn:CreateSlider({
        Name = "Place Delay",
        Min = 0,
        Max = 5,
        Default = 3,
        Suffix = "ms"
    })

	UseBlacklisted_Blocks = BlockIn:CreateToggle({
		Name = "Use Blacklisted Blocks",
		Default = false
	})

	blacklisted = BlockIn:CreateTextList({
		Name = "Blacklisted Blocks",
		Placeholder = "tnt"
	})
end)


run(function()
    local DamageAffect = {Enabled = false}
    local connection
	local Fonts
	local customMSG
	local DamageMessages = {
		'Pow!',
		'Pop!',
		'Hit!',
		'Smack!',
		'Bang!',
		'Boom!',
		'Whoop!',
		'Damage!',
		'-9e9!',
		'Whack!',
		'Crash!',
		'Slam!',
		'Zap!',
		'Snap!',
		'Thump!',
		'Ouch!',
		'Crack!',
		'Bam!',
		'Clap!',
		'Blitz!',
		'Crunch!',
		'Shatter!',
		'Blast!',
		'Womp!',
		'Thunk!',
		'Zing!',
		'Rip!',
		'Rattle!',
		'Kaboom!',
		'Wack!',
		'Boomer!',
		'Slammer!',
		'Powee!',
		'Zappp!',
		'Thunker!',
		'Rippler!',
		'Bap!',
		'Bomp!',
		'Sock!',
		'Chop!',
		'Sting!',
		'Slice!',
		'Swipe!',
		'Punch!',
		'Tonk!',
		'Bonk!',
		'Jolt!',
		'Spike!',
		'Pierce!',
		'Crush!',
		'Bruise!',
		'Ding!',
	    'Clang!',
		'Crashhh!',
		'Kablam!',
		'Zapshot!',
		'Oynx On top!'
	}
	
	local RGBColors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 127, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(75, 0, 130),
		Color3.fromRGB(148, 0, 211)
	}
	
	local function randomizer(tbl)
	    if not typeof(tbl) == "table" then return end
	    local index = math.random(1,#tbl)
	    local value = tbl[index]
	    return value,index
	end
	local font  = 'Arial'
    DamageAffect = vape.Categories.Render:CreateModule({
        Name = "DamageAffects",
        Function = function(call)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			if call then
				DamageAffect:Clean(workspace.DescendantAdded:Connect(function(part)
				    if part.Name == "DamageIndicatorPart" and part:IsA("BasePart") then
				        for i, v in part:GetDescendants() do
				            if v:IsA("TextLabel") then
				                local txt = randomizer(DamageMessages)
				                local clr = randomizer(RGBColors)
								if customMSG.Enabled then
				                	v.Text = txt
								end
				                v.TextColor3 = clr
								v.FontFace = font
				            end
				        end
				    end
				end))
			else

			end
        end,
        Tooltip = "Customizes Damage Affects"
    })
	customMSG = DamageAffect:CreateToggle({
		Name = "Custom Messages",
		Default = true
	})
	Fonts = DamageAffect:CreateFont({
		Name = 'Font',
		Function = function(val)
			font = val
		end
	})
end)


run(function()
    local AutoChargeBow = {Enabled = false}
    local old
    
    AutoChargeBow = vape.Categories.Blatant:CreateModule({
        Name = 'AutoChargeBow',
        Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
            if callback then
                old = bedwars.ProjectileController.calculateImportantLaunchValues
                bedwars.ProjectileController.calculateImportantLaunchValues = function(...)
                    local self, projmeta, worldmeta, origin, shootpos = ...
                    
                    if projmeta.projectile:find('arrow') then
                        local pos = shootpos or self:getLaunchPosition(origin)
                        if not pos then
                            return old(...)
                        end
                        
                        local meta = projmeta:getProjectileMeta()
                        local lifetime = (worldmeta and meta.predictionLifetimeSec or meta.lifetimeSec or 3)
                        local gravity = (meta.gravitationalAcceleration or 196.2) * projmeta.gravityMultiplier
                        local projSpeed = (meta.launchVelocity or 100)
                        local offsetpos = pos + (projmeta.projectile == 'owl_projectile' and Vector3.zero or projmeta.fromPositionOffset)
                        
                        local camera = workspace.CurrentCamera
                        local mouse = lplr:GetMouse()
                        local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
                        
                        local targetPoint = unitRay.Origin + (unitRay.Direction * 1000)
                        local aimDirection = (targetPoint - offsetpos).Unit
                        
                        local newlook = CFrame.new(offsetpos, targetPoint) * CFrame.new(projmeta.projectile == 'owl_projectile' and Vector3.zero or Vector3.new(bedwars.BowConstantsTable.RelX, bedwars.BowConstantsTable.RelY, bedwars.BowConstantsTable.RelZ))
                        local finalDirection = (targetPoint - newlook.Position).Unit
                        
                        return {
                            initialVelocity = finalDirection * projSpeed,
                            positionFrom = offsetpos,
                            deltaT = lifetime,
                            gravitationalAcceleration = gravity,
                            drawDurationSeconds = 5
                        }
                    end
                    
                    return old(...)
                end
            else
                bedwars.ProjectileController.calculateImportantLaunchValues = old
				old = nil
            end
        end,
        Tooltip = 'Automatically charges your bow to full power with trajectory line preview'
    })
end)
	
run(function()
	local FlyY 
	local Fly
	local Heal
	local HealthHP
	local isWhispering
	local BetterWhisper
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true

    BetterWhisper = vape.Categories.Support:CreateModule({
        Name = 'BetterWhisper',
        Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end	
            if callback then
				BetterWhisper:Clean(bedwars.Client:Get("OwlSummoned"):Connect(function(data)
					if data.user == lplr then
						local target = data.target
						local chr = target.Character
						local hum = chr:FindFirstChild('Humanoid')
						local root = chr:FindFirstChild('HumanoidRootPart')
						isWhispering = true
						repeat
							rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, AntiVoidPart}
							rayCheck.CollisionGroup = root.CollisionGroup

							if Fly.Enabled and root.Velocity.Y <= FlyY.Value and not workspace:Raycast(root.Position, Vector3.new(0, -100, 0), rayCheck) then
								WhisperController:request("Fly")
							end
							if Heal.Enabled and (hum.MaxHealth - hum.Health) >= HealthHP.Value then
								WhisperController:request("Heal")
							end
							task.wait(0.05)
						until not isWhispering or not BetterWhisper.Enabled
					end
				end))
				BetterWhisper:Clean(bedwars.Client:Get("OwlDeattached"):Connect(function(data)
					if data.user == lplr then
						isWhispering = false
					end
				end))
			else
				isWhispering = false
			end
        end,
        Tooltip = "Better whisper skills and u look like u play like therac!"
    })
	FlyY = BetterWhisper:CreateSlider({
		Name = 'Y-Level fly',																																																																							
		Min = -50,
		Max = -100,
		Default = -90,
	})	
	HealthHP = BetterWhisper:CreateSlider({
		Name = 'Heal HP',																																																																							
		Min = 1,
		Max = 99,
		Default = 80,
	})	
	Fly = BetterWhisper:CreateToggle({
		Name = 'Fly',
		Default = true,
	})
	Heal = BetterWhisper:CreateToggle({
		Name = 'Heal',
		Default = true,
	})
end)
	
run(function()
		local char = lplr.Character or lplr.CharacterAdded:Wait()
		local teamID = char:GetAttribute("Team")
		local Distance = 15
		local db = true
		local ABDU
		local Upgrade
		local REMOTE = ""
		local tbllist = {
		    ["bed alarm"] = "bed_alarm",
		    ["bedalarm"] = "bed_alarm",
		    ["alarm"] = "bed_alarm",
		
		    ["bed shield"] = "bed_shield",
		    ["bedshield"] = "bed_shield",
		    ["shield"] = "bed_shield",
	
		    ["team"] = "TEAM_GENERATOR",
		    ["gen"] = "TEAM_GENERATOR",
		    ["team generator"] = "TEAM_GENERATOR",
		    ["team gen"] = "TEAM_GENERATOR",
		    ["teamgenerator"] = "TEAM_GENERATOR",
		    ["teamgen"] = "TEAM_GENERATOR",
		
		    ["diamond"] = "DIAMOND_GENERATOR",
		    ["diamond generator"] = "DIAMOND_GENERATOR",
		    ["diamond gen"] = "DIAMOND_GENERATOR",
		    ["diamondgen"] = "DIAMOND_GENERATOR",
		    ["diamondgenerator"] = "DIAMOND_GENERATOR",
		
		    ["dim"] = "DIAMOND_GENERATOR",
		    ["dim generator"] = "DIAMOND_GENERATOR",
		    ["dim gen"] = "DIAMOND_GENERATOR",
		    ["dimgenerator"] = "DIAMOND_GENERATOR",
		    ["dimgen"] = "DIAMOND_GENERATOR",
		
		    ["armor"] = "ARMOR",
		    ["arm"] = "ARMOR",
		
		    ["damage"] = "DAMAGE",
		    ["dmg"] = "DAMAGE",
	}
	local upgradePrices = {
	    bed_alarm = 2,
	    bed_shield = 5,
	
	    TEAM_GENERATOR = {4, 8, 16},
	    DIAMOND_GENERATOR = {4, 8, 12},
	
	    ARMOR = {4, 8, 18},
	    DAMAGE = {5, 10, 20},
	}

	local function getPrice(upgradeName, currentTier)
	    local prices = upgradePrices[upgradeName]
	    if not prices then return nil end
	
	    return prices[currentTier]  
	end
	local function purchase(upgrade)
	    local grade = string.lower(upgrade)
	    local mapped = tbllist[grade]
	
	    if not mapped then
	        getgenv().BEN("Invalid upgrade:", upgrade)
	        return
	    end
	
	    local function buyBed(price)
	        local item, amount = getItem("diamond")
	        if not (item and amount) then return end
	
	        if amount >= price then
	            game:GetService("ReplicatedStorage")
	                .rbxts_include.node_modules["@rbxts"].net.out._NetManaged
	                .RequestPurchaseBedTeamUpgrade:InvokeServer(mapped)
	            ABDU:Toggle(false)
	        else
	            getgenv().BEN("You do not have enough to autopurchase")
	        end
	    end
	
	    if mapped == "bed_alarm" then
	        buyBed(2)
	        return
	    end
	    if mapped == "bed_shield" then
	        buyBed(5)
	        return
	    end
	
	    local tier = 1
	
	    while true do
	        local price = getPrice(mapped, tier)
	        if not price then break end 
	
	        local item, amount = getItem("diamond")
	        if not (item and amount) then break end
	
	        if amount < price then
	            getgenv().BEN("Stopped: not enough for tier or max tier: "..tier)
	            break
	        end
	
	        game:GetService("ReplicatedStorage")
	            .rbxts_include.node_modules["@rbxts"].net.out._NetManaged
	            .RequestPurchaseTeamUpgrade:InvokeServer(mapped)
		
	        tier += 1
	    end
	end


	    ABDU = vape.Categories.Inventory:CreateModule({
	        Name = "AutoBuyUpgrades",
	        Function = function(callback)
	   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"and role ~= "user"then
					vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
					return
				end																																																																															
	            if callback then
	    			db = true

					while task.wait(0.5) do
					    for i, v in workspace:GetChildren() do
					        if v:IsA("BasePart") then
					            if v.Name == "1_upgrade_shop" then
					                if v:GetAttribute("GeneratorTeam") == teamID then
					                    local NewDis = (v.florist.PrimaryPart.Position - char.HumanoidRootPart.Position).Magnitude
					                    if NewDis <= Distance then
						                	purchase(Upgrade.Value)
					                    else
					                        
					                    end
					                else
					                    getgenv().BEN("Cannot locate where ur upgrade shop is at")
										db = false
										ABDU:Toggle(false)
					                end
					            end
					        end
					    end

						if not db then break end
					end
				else
					db = false
	            end
	        end,
	        Tooltip = "Automatically buys upgrades when you go near the shop",
	    })
		Upgrade = ABDU:CreateTextBox({
			Name = 'Upgrade',
			Placeholder = 'Generator/Damage/Armor/BedShield/BedAlarm/Etc',
			Darker = true,
		})																																									
end)



run(function()
	local BCR
	local Value
	local old
	local inf = math.huge or 9e9
	BCR = vape.Categories.Blatant:CreateModule({
		Name = "BlockCPSRemover",
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			if callback then
				old = bedwars.SharedConstants.CpsConstants['BLOCK_PLACE_CPS']
				bedwars.SharedConstants.CpsConstants['BLOCK_PLACE_CPS'] = Value.Value == 0 and inf or Value.Value
			else
				bedwars.SharedConstants.CpsConstants['BLOCK_PLACE_CPS'] = old
				old = nil
			end
		end,
	})
	Value = BCR:CreateSlider({
		Name = "CPS",
		Suffix = "s",
		Tooltip = "Changes the limit to the CPS cap(0 = remove)",
		Default = 0,
		Min = 0,
		Max = 100,
		Function = function()
			if BCR.Enabled then
				bedwars.SharedConstants.CpsConstants['BLOCK_PLACE_CPS'] = Value.Value == 0 and inf or Value.Value
			else
				if old == nil then old = 12 end
				bedwars.SharedConstants.CpsConstants['BLOCK_PLACE_CPS'] = old
				old = nil
			end
		end,
		
	})
end)

run(function()
	local Mode
	local jumps = 0
	local TP
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	InfiniteFly = vape.Categories.Blatant:CreateModule({
		Name = "Infinite Jump",
		Tooltip = "Allows you to jump infinitely.",
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			if callback then
				local tpTick, tpToggle, oldy = tick(), true
				jumps = 0														
				InfiniteFly:Clean(inputService.JumpRequest:Connect(function()
					jumps += 1
					if jumps > 1 and Mode.Value == "Velocity" then
						local power = math.sqrt(2 * workspace.Gravity * entitylib.character.Humanoid.JumpHeight)
						entitylib.character.RootPart.Velocity = Vector3.new(entitylib.character.RootPart.Velocity.X, power, entitylib.character.RootPart.Velocity.Z)
						if tpToggle then
							local airleft = (tick() - entitylib.character.AirTime)
							if airleft > 2 then
								if not oldy then
									local ray = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rayCheck)
									if ray and TP.Enabled then
										tpToggle = false
										oldy = root.Position.Y
										tpTick = tick() + 0.11
										root.CFrame = CFrame.lookAlong(Vector3.new(root.Position.X, ray.Position.Y + entitylib.character.HipHeight, root.Position.Z), root.CFrame.LookVector)
									end
								end
							end
						else
							if oldy then
								if tpTick < tick() then
									local newpos = Vector3.new(root.Position.X, oldy, root.Position.Z)
									root.CFrame = CFrame.lookAlong(newpos, root.CFrame.LookVector)
									tpToggle = true
									oldy = nil
								else
									mass = 0
								end
							end
						end
					elseif Mode.Value == "Jump" then
						
						entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						if tpToggle then
							local airleft = (tick() - entitylib.character.AirTime)
							if airleft > 2 then
								if not oldy then
									local ray = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rayCheck)
									if ray and TP.Enabled then
										tpToggle = false
										oldy = root.Position.Y
										tpTick = tick() + 0.11
										root.CFrame = CFrame.lookAlong(Vector3.new(root.Position.X, ray.Position.Y + entitylib.character.HipHeight, root.Position.Z), root.CFrame.LookVector)
									end
								end
							end
						else
							if oldy then
								if tpTick < tick() then
									local newpos = Vector3.new(root.Position.X, oldy, root.Position.Z)
									root.CFrame = CFrame.lookAlong(newpos, root.CFrame.LookVector)
									tpToggle = true
									oldy = nil
								else
									mass = 0
								end
							end
						end
					end
				end))
			end
		end,
		ExtraText = function() return Mode.Value or "HeatSeeker" end
	})
	Mode = InfiniteFly:CreateDropdown({
		Name = "Mode",
		List = {"Jump", "Velocity"}
	})
	TP = InfiniteFly:CreateToggle({
		Name = 'TP Down',
		Default = true
	})
end)



run(function()
		local BSA
		local TargetPart
		local Targets
		local FOV
		local Range
		local OtherProjectiles
		local Blacklist
		local TargetVisualiser
		
		local rayCheck = RaycastParams.new()
		rayCheck.FilterType = Enum.RaycastFilterType.Include
		rayCheck.FilterDescendantsInstances = {workspace:FindFirstChild('Map') or workspace}
		local old
		
		local selectedTarget = nil
		local targetOutline = nil
		local hovering = false
		local CoreConnections = {}
		
		local UserInputService = game:GetService("UserInputService")
		local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

		local function updateOutline(target)
			return
		end

		local function handlePlayerSelection()
			local mouse = lplr:GetMouse()
			local function selectTarget(target)
				if not target then return end
				if target and target.Parent then
					local plr = playersService:GetPlayerFromCharacter(target.Parent)
					if plr then
						if selectedTarget == plr then
							selectedTarget = nil
							updateOutline(nil)
						else
							selectedTarget = plr
							updateOutline(plr)
						end
					end
				end
			end
			
			local con
			if isMobile then
				con = UserInputService.TouchTapInWorld:Connect(function(touchPos)
					if not hovering then updateOutline(nil); return end
					if not BSA.Enabled then pcall(function() con:Disconnect() end); updateOutline(nil); return end
					local ray = workspace.CurrentCamera:ScreenPointToRay(touchPos.X, touchPos.Y)
					local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
					if result and result.Instance then
						selectTarget(result.Instance)
					end
				end)
				table.insert(CoreConnections, con)
			end
		end
		
		BSA = vape.Categories.Combat:CreateModule({
			Name = 'BetterPA',
			Function = function(callback)
				if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
					vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
					return
				end  
				if callback then
					handlePlayerSelection()
					
					old = bedwars.ProjectileController.calculateImportantLaunchValues
					bedwars.ProjectileController.calculateImportantLaunchValues = function(...)
						hovering = true
						local self, projmeta, worldmeta, origin, shootpos = ...
						local originPos = entitylib.isAlive and (shootpos or entitylib.character.RootPart.Position) or Vector3.zero
						
						local plr
						if selectedTarget and selectedTarget.Character and (selectedTarget.Character.PrimaryPart.Position - originPos).Magnitude <= Range.Value then
							plr = selectedTarget
						else
							plr = entitylib.EntityMouse({
								Part = TargetPart.Value,
								Range = FOV.Value,
								Players = Targets.Players.Enabled,
								NPCs = Targets.NPCs.Enabled,
								Wallcheck = Targets.Walls.Enabled,
								Origin = originPos
							})
						end
						updateOutline(plr)
		
						if plr and plr.Character and plr[TargetPart.Value] and (plr[TargetPart.Value].Position - originPos).Magnitude <= Range.Value then
							local pos = shootpos or self:getLaunchPosition(origin)
							if not pos then
								hovering = false
								return old(...)
							end
		
							if (not OtherProjectiles.Enabled) and not projmeta.projectile:find('arrow') then
								hovering = false
								return old(...)
							end

							if table.find(Blacklist.ListEnabled, projmeta.projectile) then
								hovering = false
								return old(...)
							end
		
							local meta = projmeta:getProjectileMeta()
							local lifetime = (worldmeta and meta.predictionLifetimeSec or meta.lifetimeSec or 3)
							local gravity = (meta.gravitationalAcceleration or 196.2) * projmeta.gravityMultiplier
							local projSpeed = (meta.launchVelocity or 100)
							local offsetpos = pos + (projmeta.projectile == 'owl_projectile' and Vector3.zero or projmeta.fromPositionOffset)
							local balloons = plr.Character:GetAttribute('InflatedBalloons')
							local playerGravity = workspace.Gravity
		
							if balloons and balloons > 0 then
								playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
							end
		
							if plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then
								playerGravity = 6
							end

							if plr.Player and plr.Player:GetAttribute('IsOwlTarget') then
								for _, owl in collectionService:GetTagged('Owl') do
									if owl:GetAttribute('Target') == plr.Player.UserId and owl:GetAttribute('Status') == 2 then
										playerGravity = 0
										break
									end
								end
							end

							if store.hand and store.hand.tool then
								if store.hand.tool.Name:find("spellbook") then
									local targetPos = plr.RootPart.Position
									local selfPos = lplr.Character.PrimaryPart.Position
									local expectedTime = (selfPos - targetPos).Magnitude / 160
									targetPos = targetPos + (plr.RootPart.Velocity * expectedTime)
									return {
										initialVelocity = (targetPos - selfPos).Unit * 160,
										positionFrom = offsetpos,
										deltaT = 2,
										gravitationalAcceleration = 1,
										drawDurationSeconds = 5
									}
								elseif store.hand.tool.Name:find("chakram") then
									local targetPos = plr.RootPart.Position
									local selfPos = lplr.Character.PrimaryPart.Position
									local expectedTime = (selfPos - targetPos).Magnitude / 80
									targetPos = targetPos + (plr.RootPart.Velocity * expectedTime)
									return {
										initialVelocity = (targetPos - selfPos).Unit * 80,
										positionFrom = offsetpos,
										deltaT = 2,
										gravitationalAcceleration = 1,
										drawDurationSeconds = 5
									}
								end
							end
		
							local newlook = CFrame.new(offsetpos, plr[TargetPart.Value].Position) * CFrame.new(projmeta.projectile == 'owl_projectile' and Vector3.zero or Vector3.new(bedwars.BowConstantsTable.RelX, bedwars.BowConstantsTable.RelY, bedwars.BowConstantsTable.RelZ))
							local calc = prediction.SolveTrajectory(newlook.p, projSpeed, gravity, plr[TargetPart.Value].Position, projmeta.projectile == 'telepearl' and Vector3.zero or plr[TargetPart.Value].Velocity, playerGravity, plr.HipHeight, plr.Jumping and 42.6 or nil, rayCheck)
							if calc then
								targetinfo.Targets[plr] = tick() + 1
								hovering = false
								return {
									initialVelocity = CFrame.new(newlook.Position, calc).LookVector * projSpeed,
									positionFrom = offsetpos,
									deltaT = lifetime,
									gravitationalAcceleration = gravity,
									drawDurationSeconds = 5
								}
							end
						end
		
						hovering = false
						return old(...)
					end
				else
					bedwars.ProjectileController.calculateImportantLaunchValues = old
					if targetOutline then
						targetOutline:Destroy()
						targetOutline = nil
					end
					selectedTarget = nil
					for i,v in pairs(CoreConnections) do
						pcall(function() v:Disconnect() end)
					end
					table.clear(CoreConnections)
				end
			end,
			Tooltip = 'Silently adjusts your aim towards the enemy. Click a player to lock onto them.'
		})
		
		Targets = BSA:CreateTargets({
			Players = true,
			Walls = true
		})
		TargetPart = BSA:CreateDropdown({
			Name = 'Part',
			List = {'RootPart', 'Head'}
		})
		FOV = BSA:CreateSlider({
			Name = 'FOV',
			Min = 1,
			Max = 1000,
			Default = 1000
		})
		Range = BSA:CreateSlider({
			Name = 'Range',
			Min = 10,
			Max = 500,
			Default = 100,
			Tooltip = 'Maximum distance for target locking'
		})
		TargetVisualiser = BSA:CreateToggle({
			Name = "Target Visualiser", 
			Default = true
		})
		OtherProjectiles = BSA:CreateToggle({
			Name = 'Other Projectiles',
			Default = true,
			Function = function(call)
				if Blacklist then
					Blacklist.Object.Visible = call
				end
			end
		})
		Blacklist = BSA:CreateTextList({
			Name = 'Blacklist',
			Darker = true,
			Default = {'telepearl'}
		})
end)

run(function()
	local BackTrackIncoming = {}
	local KPS
	local BackTrack = vape.Categories.World:CreateModule({
		Name = "BackTrack", 
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			if callback then
				game:GetService("NetworkClient"):SetOutgoingKBPSLimit(KPS.Value)
				if BackTrackIncoming.Enabled then 
					settings():GetService("NetworkSettings").IncomingReplicationLag = KPS.Value * 3
				end
			else
				game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
				if BackTrackIncoming.Enabled then 
					settings():GetService("NetworkSettings").IncomingReplicationLag = 0
				end
			end
		end, 
		Tooltip = "PositionRaper"
	})
	BackTrackIncoming = BackTrack:CreateToggle({
		Name = "Incoming",
		Function = function(callback)
			if callback then
				if BackTrack.Enabled then 
					settings():GetService("NetworkSettings").IncomingReplicationLag = 99999999
				end
			else
				if BackTrack.Enabled then 
					settings():GetService("NetworkSettings").IncomingReplicationLag = 0
				end
			end
		end
	})
	KPS = BackTrack:CreateSlider({
		Name = "KPS Limit",
		Max = 250,
		Min = 1,
		Default = 25,
		Function = function()
			if BackTrack.Enabled then
				if KPS.Value <= 0 then KPS.Value = 1 end
				game:GetService("NetworkClient"):SetOutgoingKBPSLimit(KPS.Value)
				if BackTrackIncoming.Enabled then 
					settings():GetService("NetworkSettings").IncomingReplicationLag = KPS.Value * 4
				end
			else
				game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
				if BackTrackIncoming.Enabled then 
					settings():GetService("NetworkSettings").IncomingReplicationLag = 0
				end
			end
		end
	})
end)

run(function()
    local function CreateUI()
        local Players = cloneref(game:GetService("Players"))
        local LocalPlayer = lplr

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CustomGui"
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        screenGui.IgnoreGuiInset = true 
        screenGui.ResetOnSpawn = false

        local frame = Instance.new("Frame")
        frame.Name = "MainFrame"
        frame.Size = UDim2.new(0, 150, 0, 150)
        frame.Position = UDim2.new(0, 0, 0, 0) 
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.ZIndex = 1
        frame.Parent = screenGui

        local playerLevel = LocalPlayer:GetAttribute("PlayerLevel") or 0

        local image = Instance.new("ImageLabel")
        image.Name = "IconImage"
        image.Size = UDim2.new(0, 48, 0, 48)
        image.Position = UDim2.new(0.5, -24, 0, 5)
        image.BackgroundTransparency = 1
        image.Image = "rbxassetid://138775259837229"
        image.Parent = frame

        local function createStyledLabel(name, text, posY)
            local textLabel = Instance.new("TextLabel")
            textLabel.Name = name
            textLabel.Size = UDim2.new(1, -10, 0, 20)
            textLabel.Position = UDim2.new(0, 5, 0, posY)
            textLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            textLabel.TextStrokeTransparency = 0.7
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.GothamMedium
            textLabel.BorderSizePixel = 0
            textLabel.Text = text
            textLabel.Parent = frame
        end

        createStyledLabel("PlayerLevelLabel", "Lvl: " .. tostring(playerLevel), 60)
        lplr:GetAttributeChangedSignal("PlayerLevel"):Connect(function()
            playerLevel = lplr:GetAttribute("PlayerLevel") or 0
            createStyledLabel("PlayerLevelLabel", "Lvl: " .. playerLevel, 60)
        end)
    end
	local Piston
	Piston = vape.Categories.Legit:CreateModule({
		Name = 'Piston Effect',
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= 'user' then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			if callback then
	           	CreateUI()
			else
				lplr.PlayerGui:FindFirstChild('CustomGui'):Destroy()
	        end
		end,
		Tooltip = 'Creates a piston frame!'
	})
end)


run(function()
	local ZoomUncapper
	local ZoomAmount = {Value = 500}
	local oldMaxZoom
	
	ZoomUncapper = vape.Categories.Legit:CreateModule({
		Name = 'ZoomUncapper',
		Function = function(callback)
			if callback then
				oldMaxZoom = lplr.CameraMaxZoomDistance
				lplr.CameraMaxZoomDistance = ZoomAmount.Value
			else
				if oldMaxZoom then
					lplr.CameraMaxZoomDistance = oldMaxZoom
				end
			end
		end,
		Tooltip = 'Uncaps camera zoom distance'
	})
	
	ZoomAmount = ZoomUncapper:CreateSlider({
		Name = 'Zoom Distance',
		Min = 20,
		Max = 600,
		Default = 100,
		Function = function(val)
			if ZoomUncapper.Enabled then
				lplr.CameraMaxZoomDistance = val
			end
		end
	})
end)


	
run(function()
    local FakeLag
    local Mode
    local Delay
    local TransmissionOffset
    local DynamicIntensity
    local originalRemotes = {}
    local queuedCalls = {}
    local isProcessing = false
    local callInterception = {}
    
    local function backupRemoteMethods()
        if not bedwars or not bedwars.Client then return end
        
        local oldGet = bedwars.Client.Get
        callInterception.oldGet = oldGet
        
        for name, path in pairs(remotes) do
            local remote = oldGet(bedwars.Client, path)
            if remote and remote.SendToServer then
                originalRemotes[path] = remote.SendToServer
            end
        end
    end
    
    local function processDelayedCalls()
        if isProcessing then return end
        isProcessing = true
        
        task.spawn(function()
            while FakeLag.Enabled and #queuedCalls > 0 do
                local currentTime = tick()
                local toExecute = {}
                
                for i = #queuedCalls, 1, -1 do
                    local call = queuedCalls[i]
                    if currentTime >= call.executeTime then
                        table.insert(toExecute, 1, call)
                        table.remove(queuedCalls, i)
                    end
                end
                
                for _, call in ipairs(toExecute) do
                    pcall(function()
                        if call.remote and call.method == "FireServer" then
                            call.remote:FireServer(unpack(call.args))
                        elseif call.remote and call.method == "InvokeServer" then
                            call.remote:InvokeServer(unpack(call.args))
                        elseif call.originalFunc then
                            call.originalFunc(call.remote, unpack(call.args))
                        end
                    end)
                end
                
                task.wait(0.001)
            end
            isProcessing = false
        end)
    end
    
    local function queueRemoteCall(remote, method, originalFunc, ...)
        local currentDelay = Delay.Value
        
        if Mode.Value == "Dynamic" then
            if entitylib.isAlive then
                local intensity = DynamicIntensity.Value / 100
                
                local velocity = entitylib.character.HumanoidRootPart.Velocity.Magnitude
                if velocity > 20 then
                    currentDelay = currentDelay * (1 + intensity * 0.5)
                end
                
                local lastDamage = entitylib.character.Character:GetAttribute('LastDamageTakenTime') or 0
                if tick() - lastDamage < 2 then
                    currentDelay = currentDelay * (1 + intensity * 0.7)
                end
            end
        elseif Mode.Value == "Track" then
            if entitylib.isAlive then
                local nearestDist = math.huge
                for _, entity in ipairs(entitylib.List) do
                    if entity.Targetable and entity.Player and entity.Player ~= lplr then
                        local dist = (entity.RootPart.Position - entitylib.character.RootPart.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                        end
                    end
                end
                
                if nearestDist < 15 then
                    local TrackFactor = (15 - nearestDist) / 15
                    currentDelay = currentDelay * (1 + (TrackFactor * 2))
                end
            end
        end
        
        table.insert(queuedCalls, {
            remote = remote,
            method = method,
            originalFunc = originalFunc,
            args = {...},
            executeTime = tick() + (currentDelay / 1000)
        })
        
        processDelayedCalls()
    end
    
    local function interceptRemotes()
        if not bedwars or not bedwars.Client then return end
        
        local oldGet = callInterception.oldGet
        bedwars.Client.Get = function(self, remotePath)
            local remote = oldGet(self, remotePath)
            
            if remote and remote.SendToServer then
                local originalSend = remote.SendToServer
                remote.SendToServer = function(self, ...)
                    if FakeLag.Enabled and Delay.Value > 0 then
                        queueRemoteCall(self, "SendToServer", originalSend, ...)
                        return
                    end
                    return originalSend(self, ...)
                end
            end
            
            return remote
        end
        
        local function interceptSpecificRemote(path)
            local remote = oldGet(bedwars.Client, path)
            if remote and remote.FireServer then
                local originalFire = remote.FireServer
                remote.FireServer = function(self, ...)
                    if FakeLag.Enabled and Delay.Value > 0 then
                        queueRemoteCall(self, "FireServer", originalFire, ...)
                        return
                    end
                    return originalFire(self, ...)
                end
            end
        end
        
        if remotes.AttackEntity then interceptSpecificRemote(remotes.AttackEntity) end
        if remotes.PlaceBlockEvent then interceptSpecificRemote(remotes.PlaceBlockEvent) end
        if remotes.BreakBlockEvent then interceptSpecificRemote(remotes.BreakBlockEvent) end
    end
    
    FakeLag = vape.Categories.World:CreateModule({
        Name = 'FakeLag',
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end
            if callback then
                backupRemoteMethods()
                interceptRemotes()
            else
                if callInterception.oldGet then
                    bedwars.Client.Get = callInterception.oldGet
                end
                
                for _, call in ipairs(queuedCalls) do
                    pcall(function()
                        if call.originalFunc then
                            call.originalFunc(call.remote, unpack(call.args))
                        end
                    end)
                end
                table.clear(queuedCalls)
            end
        end,
        Tooltip = 'Delays your character\'s network updates to simulate high ping'
    })
    
    Mode = FakeLag:CreateDropdown({
        Name = 'Mode',
        List = {'Latency', 'Dynamic', 'Track'},
        Function = function(v)
			if v == "Dynamic" then
				DynamicIntensity.Object.Visible = true
			else
				DynamicIntensity.Object.Visible = false
			end
		end
    })
    
    Delay = FakeLag:CreateSlider({
        Name = 'Delay',
        Min = 0,
        Max = 500,
        Default = 150,
        Suffix = 'ms'
    })
    
    DynamicIntensity = FakeLag:CreateSlider({
        Name = 'Intensity',
        Min = 0,
        Max = 100,
        Default = 50,
        Suffix = '%'
    })
end)
	
run(function()
	local function OnlineMods(Mod)
		local url = "https://onyxclient.fsl58.workers.dev/fetch?mods=" .. Mod

		local success, response = pcall(function()
			return request({
				Url = url,
				Method = "GET"
			})
		end)

		if not success or not response or response.StatusCode ~= 200 then
			warn("Request failed")
			return {}
		end

		local success2, data = pcall(function()
			return httpService:JSONDecode(response.Body)
		end)

		if not success2 or not data or not data.mods then
			warn("Invalid JSON response")
			return {}
		end

		local online = {}

		for _, mod in ipairs(data.mods) do
			local status = mod.status
			if status and status.presenceType and status.presenceType ~= "Offline" then
				table.insert(online, mod)

				vape:CreateNotification("StaffFetcher", string.format("[Mod Online]: Username: %s | Presence: %s",mod.username,status.presenceType),7.5)
			end
		end

		if #online == 0 then
			vape:CreateNotification("StaffFetcher", Mod.." Has no current online accounts!",3.23)
		end

		return online
	end
	local StaffFetcher
	local Type
	local Mod
	StaffFetcher = vape.Categories.Utility:CreateModule({
		Name = 'Staff Fetcher',
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if not callback then return
			if Type.Value == "Known" then
				OnlineMods(Mod.Value)
			else
				OnlineMods("nns")
			end
		end,
		Tooltip = 'Fetches Online status of known/unknown mods'
	})
	Mod = StaffFetcher:CreateDropdown({
		Name = "Type",
		List = {"Chase","Orion","LisNix","Nwr","Gorilla",'Typhoon',"Vic","Erin","Ghost","Sponge","Gora","Apple","Dom","Kevin"},
	})
	Type = StaffFetcher:CreateDropdown({
		Name = "Type",
		List = {"Known","Unknown"},
		Function = function()
			if Type.Value == "Known" then
				Mod.Visible = true
			else
				Mod.Visible = false
			end
		end
	})

end)

run(function()
	local Deflect
	local DeflectTm
	local Range
	local LimitToItem
	local old
	Deflect = vape.Categories.Utility:CreateModule({
		Name = 'Deflect',
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				local function getWorldFolder()
					local Map = workspace:WaitForChild("Map", math.huge)
					local Worlds = Map:WaitForChild("Worlds", math.huge)
					if not Worlds then return nil end

					return Worlds:GetChildren()[1] 
				end
				local blocks = getWorldFolder()
				local function GetPlayerFromUserID(id)
					return playersService:GetPlayerByUserId(id)
				end
				local bows = getBows()
				local originalSlot = store.inventory.hotbarSlot
				Deflect:Clean(blocks.ChildAdded:Connect(function(child)
                	if child:IsA("BasePart") and child.Name == "tnt" or child.Name == "siege_tnt" and Deflect.Enabled then
						if child:GetAttribute("PlacedByUserId") == lplr.UserId then return end
						local Distance = (child.Position - entitylib.character.RootPart.Position).Magnitude
						local nlplr = GetPlayerFromUserID(child:GetAttribute("PlacedByUserId"))
						if Distance <= Range.Value or 20 then
							if nlplr.Team == lplr.Team then
								if DeflectTm.Enabled then
									old = bedwars.ProjectileController.createLocalProjectile
									bedwars.ProjectileController.createLocalProjectile = function(...)
										local source, data, proj = ...
											for _, bowSlot in bows do
											if hotbarSwitch(bowSlot) then
												mouse1click()
												task.wait(0.135)
												hotbarSwitch(originalSlot)		
											end
										end
										return old(...)
									end
								else
									return
								end
							end
							old = bedwars.ProjectileController.createLocalProjectile
							bedwars.ProjectileController.createLocalProjectile = function(...)
								local source, data, proj = ...
									for _, bowSlot in bows do
									if hotbarSwitch(bowSlot) then
										mouse1click()
										task.wait(0.135)
										hotbarSwitch(originalSlot)		
									end
								end
								return old(...)
							end
						else
							return
						end
					end
				end))
				for i, child in blocks:GetDescendants() do
                	if child:IsA("BasePart") and child.Name == "tnt" or child.Name == "siege_tnt" and Deflect.Enabled then
						if child:GetAttribute("PlacedByUserId") == lplr.UserId then return end
						local Distance = (child.Position - entitylib.character.RootPart.Position).Magnitude
						local nlplr = GetPlayerFromUserID(child:GetAttribute("PlacedByUserId"))
						if Distance <= Range.Value or 20 then
							if nlplr.Team == lplr.Team then
								if DeflectTm.Enabled then
									old = bedwars.ProjectileController.createLocalProjectile
									bedwars.ProjectileController.createLocalProjectile = function(...)
										local source, data, proj = ...
											for _, bowSlot in bows do
											if hotbarSwitch(bowSlot) then
												mouse1click()
												task.wait(0.135)
												hotbarSwitch(originalSlot)		
											end
										end
										return old(...)
									end
								else
									return
								end
							end
							old = bedwars.ProjectileController.createLocalProjectile
							bedwars.ProjectileController.createLocalProjectile = function(...)
								local source, data, proj = ...
									for _, bowSlot in bows do
									if hotbarSwitch(bowSlot) then
										mouse1click()
										task.wait(0.135)
										hotbarSwitch(originalSlot)		
									end
								end
								return old(...)
							end
						else
							return
						end
					end
				end
			else
				bedwars.ProjectileController.createLocalProjectile = old
				old = nil
			end
		end,
		Tooltip = 'Deflects tnt in range'
	})
	DeflectTm = Deflect:CreateToggle({
		Name = "Teammate",
		Default = false,
		Tooltip = "Deflects your teammates tnt near you"
	})
	LimitToItem = Deflect:CreateToggle({
		Name = "Limit To Item",
		Default = false,
	})
	Range = Deflect:CreateSlider({
		Name = "Range",
		Default = 10,
		Min = 1,
		Max = 25,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})

end)

run(function()
	local BetterCait
	
	BetterCait = vape.Categories.Support:CreateModule({
		Name = 'BetterCaitlyn',
		Function = function(callback)
			local hitPlayers = {} 
				
			BetterCait:Clean(vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
				if not entitylib.isAlive then return end
					
				local attacker = playersService:GetPlayerFromCharacter(damageTable.fromEntity)
				local victim = playersService:GetPlayerFromCharacter(damageTable.entityInstance)
				
				if attacker == lplr and victim and victim ~= lplr then
					hitPlayers[victim] = true
						
					local storeState = bedwars.Store:getState()
					local activeContract = storeState.Kit.activeContract
					local availableContracts = storeState.Kit.availableContracts or {}
						
					if not activeContract then
						for _, contract in availableContracts do
							if contract.target == victim then
								bedwars.Client:Get('BloodAssassinSelectContract'):SendToServer({
									contractId = contract.id
								})
								break
							end
						end
					end
				end
			end))
			repeat task.wait(0.01) until not entitylib.isAlive or not BetterCait.Enabled
			table.clear(hitPlayers)
		end,
		Tooltip = 'Makes you look better with caitlyn'
	})
	
end)

run(function()
    local AutoDodge
    local Distance = 15
    local D

    AutoDodge = vape.Categories.Blatant:CreateModule({
        Name = 'AutoDodge',
        Tooltip = 'Automatically dodges arrows for you -- close range only',
        Function = function(callback)
            if not callback then return end
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
            AutoDodge:Clean(workspace.DescendantAdded:Connect(function(arrow)
                    if not AutoDodge.Enabled then return end
                    if not entitylib.isAlive then return end

                    if (arrow.Name == "crossbow_arrow" or arrow.Name == "arrow" or arrow.Name == "headhunter_arrow")and arrow:IsA("Model") then

                        if arrow:GetAttribute("ProjectileShooter") == lplr.UserId then return end

                        local root = arrow:FindFirstChildWhichIsA("BasePart")
                        if not root then return end

                        while AutoDodge.Enabled and root and root.Parent and entitylib.isAlive do
                            local char = lplr.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            if not hrp or not hum then break end

                            local dist = (hrp.Position - root.Position).Magnitude
                            if dist <= (Distance + 5) then
                                local dodgePos = hrp.Position + Vector3.new(8, 0, 0)
								if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
									humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								end
                                hum:MoveTo(dodgePos)
                                break
                            end

                            task.wait(0.05)
                        end
                    end
                end)
            )
        end
    })

    D = AutoDodge:CreateSlider({
        Name = "Distance",
        Min = 1,
        Max = 30,
        Default = 15,
        Suffix = function(val)
            return val == 1 and "stud" or "studs"
        end,
        Function = function(val)
            Distance = val
        end
    })
end)

run(function()
    local BetterKaida
    local CastDistance
    local AttackRange
    local Angle
    local Targets
	local CastChecks
	local MaxTargets
	local Sorts
    BetterKaida = vape.Categories.Support:CreateModule({
        Name = "BetterKaida",
        Tooltip = "Killaura-style Kaida",
        Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				repeat task.wait(0.1) until store.equippedKit ~= '' and store.matchState ~= 0 or (not BetterKaida.Enabled)
				repeat
		            local plrs = entitylib.AllPosition({
		                Range = AttackRange.Value,
		                Wallcheck = Targets.Walls.Enabled,
		                Part = "RootPart",
		                Players = Targets.Players.Enabled,
		                NPCs = Targets.NPCs.Enabled,
		                Limit = MaxTargets.Value,
		                Sort = sortmethods[Sorts.Value]
		            })
					local castplrs = nil

					if CastChecks.Enabled then
						castplrs = entitylib.AllPosition({
							Range = CastDistance.Value,
							Wallcheck = Targets.Walls.Enabled,
							Part = "RootPart",
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = MaxTargets.Value,
							Sort = sortmethods[Sorts.Value]
		            	})
					end
		
		            local char = entitylib.character
		            local root = char.RootPart
		
		            if plrs then
		                local ent = plrs[1]
		                if ent and ent.RootPart then
		                    local delta = ent.RootPart.Position - root.Position
		                    local localFacing = root.CFrame.LookVector * Vector3.new(1, 0, 1)
		                    local angle = math.acos(localFacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
		                    if angle > (math.rad(Angle.Value) / 2) then continue end
		                        local localPosition = root.Position
		                        local shootDir = CFrame.lookAt(localPosition, ent.RootPart.Position).LookVector
		                        localPosition = localPosition + shootDir * math.max((localPosition - ent.RootPart.Position).Magnitude - 16, 0)
		
		                        pcall(function()
		                            bedwars.AnimationUtil:playAnimation(lplr, bedwars.GameAnimationUtil:getAssetId(bedwars.AnimationType.SUMMONER_CHARACTER_SWIPE),{looped = false})
		                        end)
		
		                        task.spawn(function()
		                            pcall(function()
		                                local clawModel = replicatedStorage.Assets.Misc.Kaida.Summoner_DragonClaw:Clone()
		                                clawModel.Parent = workspace
		
		                                if gameCamera.CFrame.Position and (gameCamera.CFrame.Position - root.Position).Magnitude < 1 then
		                                    for _, part in clawModel:GetDescendants() do
		                                        if part:IsA("MeshPart") then
		                                            part.Transparency = 0.6
		                                        end
		                                    end
		                                end
		
		                                local unitDir = Vector3.new(shootDir.X, 0, shootDir.Z).Unit
		                                local startPos = root.Position + unitDir:Cross(Vector3.new(0, 1, 0)).Unit * -5 + unitDir * 6
		                                local direction = (startPos + shootDir * 13 - startPos).Unit
		                                clawModel:PivotTo(CFrame.new(startPos, startPos + direction))
		                                clawModel.PrimaryPart.Anchored = true
		
		                                if clawModel:FindFirstChild("AnimationController") then
		                                    local animator = clawModel.AnimationController:FindFirstChildOfClass("Animator")
		                                    if animator then
		                                        bedwars.AnimationUtil:playAnimation(animator,bedwars.GameAnimationUtil:getAssetId(bedwars.AnimationType.SUMMONER_CLAW_ATTACK),{looped = false, speed = 1})
		                                    end
		                                end
										KaidaController:requestBetter(localPosition,shootDir)

		                                pcall(function()
		                                    local sounds = {
		                                        bedwars.SoundList.SUMMONER_CLAW_ATTACK_1,
		                                        bedwars.SoundList.SUMMONER_CLAW_ATTACK_2,
		                                        bedwars.SoundList.SUMMONER_CLAW_ATTACK_3,
		                                        bedwars.SoundList.SUMMONER_CLAW_ATTACK_4
		                                    }
		                                    bedwars.SoundManager:playSound(sounds[math.random(1, #sounds)], { position = root.Position })
		                                end)
		
		                                task.wait(0.75)
		                                clawModel:Destroy()
		                            end)
		                        end)
		                    end
		            end
					if castplrs then
		                local ent = plrs[1]
		                if ent and ent.RootPart then
							if CastChecks.Enabled then
								if bedwars.AbilityController:canUseAbility('summoner_start_charging') then
									bedwars.AbilityController:useAbility('summoner_start_charging')
									task.wait(1)
									if bedwars.AbilityController:canUseAbility('summoner_finish_charging') then
										bedwars.AbilityController:useAbility('summoner_finish_charging')
									else
										task.wait(0.95)
										bedwars.AbilityController:useAbility('summoner_finish_charging')
									end
								end
							end
						end
					end
					task.wait(0.05)
				until not BetterKaida.Enabled
			end
        end
    })
    Targets = BetterKaida:CreateTargets({
        Players = true,
        NPCs = true,
        Walls = true
    })
	Sorts = BetterKaida:CreateDropdown({
		Name = "Sorts",
		List = {'Damage','Threat','Kit','Health','Angle'}
	})
	MaxTargets = BetterKaida:CreateSlider({
		Name = "Max Targets",
		Min = 1,
		Max = 5,
		Default = 2
	})
    CastDistance = BetterKaida:CreateSlider({
        Name = "Cast Distance",
        Min = 1,
        Max = 10,
        Default = 5,
		Visible = false,
        Suffix = 'studs'
    })
	CastChecks = BetterKaida:CreateToggle({
		Name = "Check Checks",
		Tooltip = 'this allows you to use the cast ability',
		Default = false,
		Function = function(v)
			CastDistance.Object.Visible = v
		end
	})
    Angle = BetterKaida:CreateSlider({
        Name = "Angle",
        Min = 0,
        Max = 360,
        Default = 180
    })
    AttackRange = BetterKaida:CreateSlider({
        Name = "Attack Range",
        Min = 1,
        Max = 18,
        Default = 18,
        Suffix = function(val) return val == 1 and "stud" or "studs" end
    })
end)

run(function()
		local BetterNazar
		local AutoHeal

		BetterNazar = vape.Categories.Support:CreateModule({
			Name = "BetterNazar",
			Tooltip = "makes you look good with nazar lmfao",
			Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
				if callback then
					local lastHitTime = 0
					local hitTimeout = 3
					BetterNazar:Clean(vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
						if not entitylib.isAlive then return end
							
						local attacker = playersService:GetPlayerFromCharacter(damageTable.fromEntity)
						local victim = playersService:GetPlayerFromCharacter(damageTable.entityInstance)
							
						if attacker == lplr and victim and victim ~= lplr then
							lastHitTime = workspace:GetServerTimeNow()
							NazarController:request('enabled')
						end
					end))
						
					BetterNazar:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
						if not entitylib.isAlive then return end
							
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
							
						if killer == lplr and killed and killed ~= lplr then
							NazarController:request('disabled')
						end
					end))
						
					repeat
						if entitylib.isAlive then
							local currentTime = workspace:GetServerTimeNow()
								
							if empoweredMode and (currentTime - lastHitTime) >= hitTimeout then
								NazarController:request('disabled')
							end

							if  entitylib.character.Humanoid.Health <= AutoHeal.Value then
								NazarController:request('heal')
							end

						else
							if empoweredMode then
								NazarController:request('disabled')
							end
						end
							
						task.wait(0.1)
					until not BetterNazar.Enabled
						
					if empoweredMode then
						NazarController:request('disabled')
					end
				end
			end
		})

		AutoHeal = BetterNazar:CreateSlider({
			Name = "Heal",
			Min = 35,
			Max = 85,
			Default = 75,
		})
end)




run(function()
    local BetterAdetunde
    local BetterAdetunde_List

    local adetunde_remotes = {
        ["Shield"] = function()
            local args = { [1] = "shield" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Speed"] = function()
            local args = { [1] = "speed" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Strength"] = function()
            local args = { [1] = "strength" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end
    }

    local current_upgrador = "Shield"
    local hasnt_upgraded_everything = true
    local testing = 1

    BetterAdetunde = vape.Categories.Support:CreateModule({
        Name = 'BetterAdetunde',
        Function = function(calling)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
            if calling then 
                if store.equippedKit == "frost_hammer_kit" then
					current_upgrador = BetterAdetunde_List.Value
					task.spawn(function()
						repeat
							local returning_table = adetunde_remotes[current_upgrador]()
							
							if type(returning_table) == "table" then
								local Speed = returning_table["speed"]
								local Strength = returning_table["strength"]
								local Shield = returning_table["shield"]

								if returning_table[string.lower(current_upgrador)] == 3 then
									if Strength and Shield and Speed then
										if Strength == 3 or Speed == 3 or Shield == 3 then
											if (Strength == 3 and Speed == 2 and Shield == 2) or
											(Strength == 2 and Speed == 3 and Shield == 2) or
											(Strength == 2 and Speed == 2 and Shield == 3) then
												vape:CreateNotification("BetterAdetunde", "Fully upgraded everything possible!", 7,'warning')
												hasnt_upgraded_everything = false
											else
												local things = {}
												for i, v in pairs(adetunde_remotes) do
													table.insert(things, i)
												end
												for i, v in pairs(things) do
													if things[i] == current_upgrador then
														table.remove(things, i)
													end
												end
												local random = things[math.random(1, #things)]
												current_upgrador = random
											end
										end
									end
								end
							else
								local things = {}
								for i, v in pairs(adetunde_remotes) do
									table.insert(things, i)
								end
								for i, v in pairs(things) do
									if things[i] == current_upgrador then
										table.remove(things, i)
									end
								end
								local random = things[math.random(1, #things)]
								current_upgrador = random
							end
							task.wait(0.1)
						until not BetterAdetunde.Enabled or not hasnt_upgraded_everything
					end)
                else
                	vape:CreateNotification("BetterAdetunde", "Kit required only!", 5,'warning')
					BetterAdetunde:Toggle(false)
                end
            end
        end
    })

    local real_list = {}
    for i, v in pairs(adetunde_remotes) do
        table.insert(real_list, i)
    end

    BetterAdetunde_List = BetterAdetunde:CreateDropdown({
        Name = 'Preferred Upgrade',
        List = real_list,
        Function = function() end,
        Default = "Shield"
    })
end)

run(function()
	local NoNameTag
	NoNameTag = vape.Categories.Legit:CreateModule({
		Name = 'NoNameTag',
        Tooltip = 'Removes your NameTag.',
		Function = function(callback)
			if callback then
				NoNameTag:Clean(runService.RenderStepped:Connect(function()
					pcall(function()
						lplr.Character.Head.Nametag:Destroy()
					end)
				end))
			end
		end,
	})
end)


run(function()
	local FastBow
	local old
	local oldShootProp = {}
	FastBow = vape.Categories.Blatant:CreateModule({
		Name = 'FastBow',
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				old = bedwars.CooldownController.setOnCooldown
				bedwars.CooldownController.setOnCooldown = function(self, cooldownId, duration, options, ...)
					if (tostring(cooldownId):find("proj-source") or tostring(cooldownId):find("bow") or tostring(cooldownId):find("crossbow") or tostring(cooldownId):find("headhunter")) then
						duration = 0.45
					end
					return old(self, cooldownId, duration, options, ...)
				end
				
				for _, item in pairs(bedwars.ItemMeta) do
					if item.projectileSource then
						oldShootProp[item.projectileSource] = item.projectileSource.fireDelaySec
						item.projectileSource.fireDelaySec = 0.75
					end
				end
			else
				bedwars.CooldownController.setOnCooldown = old
				
				for _, item in pairs(bedwars.ItemMeta) do
					if item.projectileSource then
						local originalDelay = oldShootProp[item.projectileSource]
						item.projectileSource.fireDelaySec = originalDelay
						oldShootProp[item.projectileSource] = nil
					end
				end
				old = nil
			end
		end,
		Tooltip = 'Makes your projectiles shoot out faster(ty aero for the idea)'
	})
end)

run(function()
	local JumpHeight
	local Height 

	JumpHeight = vape.Categories.Blatant:CreateModule({
		Name = "JumpHeight",
		Tooltip = "Increases your jump height by stacked jumping",
		Function = function(callback)
			if callback then
				bedwars.JumpHeightController:getJumpModifier():addModifier({airJumps = Height.Value})
			else
		    	bedwars.JumpHeightController:getJumpModifier():addModifier({airJumps = 0})
			end
		end
	})

	Height = JumpHeight:CreateSlider({
		Name = "Height",
		Min = 1,
		Max = 8,
		Default = 0,
		Function = function(val)
			if JumpHeight.Enabled then
				bedwars.JumpHeightController:getJumpModifier():addModifier({airJumps = val})
			end
		end
	})
end)

run(function()
	local CustomTags
	local Color
	local TAG
	local old, old2
	local tagConnections = {}
	local tagRenderConn
	local tagGuiConn


	local function Color3ToHex(r, g, b)
		return string.lower(string.format("#%02X%02X%02X", r, g, b))
	end

	local function CompleteTagEffect()
		if not lplr:FindFirstChild("Tags") then return end
		local tagObj = lplr.Tags:FindFirstChild("0")
		if not tagObj then return end

		if not old then
			old = tagObj.Value
			old2 = tagObj:GetAttribute("Text")
		end

		local color = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
		local R = math.floor(color.R * 255)
		local G = math.floor(color.G * 255)
		local B = math.floor(color.B * 255)

		tagObj.Value = string.format("<font color='rgb(%d,%d,%d)'>[%s]</font>",R, G, B, TAG.Value)
		tagObj:SetAttribute("Text", TAG.Value)
		lplr:SetAttribute("ClanTag", TAG.Value)

		if tagRenderConn then
			tagRenderConn:Disconnect()
			tagRenderConn = nil
		end
		if tagGuiConn then
			tagGuiConn:Disconnect()
			tagGuiConn = nil
		end

		tagGuiConn = lplr.PlayerGui.ChildAdded:Connect(function(child)
			if child.Name ~= "TabListScreenGui" or not child:IsA("ScreenGui") then return end
			tagRenderConn = runService.RenderStepped:Connect(function()
				local nameToFind = (lplr.DisplayName == "" or lplr.DisplayName == lplr.Name) and lplr.Name or lplr.DisplayName
				for _, v in ipairs(child:GetDescendants()) do
					if v:IsA("TextLabel") and string.find(string.lower(v.Text), string.lower(nameToFind)) then
						v.Text = string.format('<font transparency="0.3" color="%s">[%s]</font> %s',Color3ToHex(R, G, B),TAG.Value,nameToFind)
					end
				end
			end)
		end)
	end
	
	local function RemoveTagEffect()
		if tagRenderConn then
			tagRenderConn:Disconnect()
			tagRenderConn = nil
		end

		if tagGuiConn then
			tagGuiConn:Disconnect()
			tagGuiConn = nil
		end

		if lplr:FindFirstChild("Tags") then
			local tagObj = lplr.Tags:FindFirstChild("0")
			if tagObj then
				if old then
					tagObj.Value = old
				end
				if old2 then
					tagObj:SetAttribute("Text", old2)
				end
			end
		end

		if lplr:GetAttribute("ClanTag") then
			lplr:SetAttribute("ClanTag", old)
		end

		old = nil
		old2 = nil
	end

	CustomTags = vape.Categories.Render:CreateModule({
		Name = "CustomTags",
		Tooltip = "Client-Sided visual custom clan tag on-chat",
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"  then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				CompleteTagEffect()
			else
 				RemoveTagEffect()
			end
		end
	})

	Color = CustomTags:CreateColorSlider({
		Name = 'Color',
		Function = function()
			if CustomTags.Enabled then
				CompleteTagEffect()
			end
		end
	})

	TAG = CustomTags:CreateTextBox({
		Name = 'Tag',
		Default = "KKK",
		Function = function()
			if CustomTags.Enabled then
				CompleteTagEffect()
			end
		end
	})
end)

run(function()
	local MLG 
	local Pearls
	local Fireball
	local Gumdrop
	local check = false
	local rayCheck = RaycastParams.new()
	rayCheck.RespectCanCollide = true
	local projectileRemote = {InvokeServer = function() end}
	task.spawn(function()
		projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
	end)

	local function getDropDistance(root)
		local result = workspace:Raycast(root.Position,Vector3.new(0, -500, 0),rayCheck)

		if result then
			return (root.Position.Y - result.Position.Y)
		end

		return math.huge 
	end
	
	local function firePearl(pos, spot, item)
		if item then		
			local pearl = getObjSlot('telepearl')
			local originalSlot = store.inventory.hotbarSlot
			hotbarSwitch(pearl)
			local meta = bedwars.ProjectileMeta.telepearl
			local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
			if calc then
				local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
				bedwars.ProjectileController:createLocalProjectile(meta, 'telepearl', 'telepearl', pos, nil, dir, {drawDurationSeconds = 1})
				projectileRemote:InvokeServer(item.tool, 'telepearl', 'telepearl', pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
				task.wait(0.15)
				hotbarSwitch(originalSlot)
			end
		end
	end

	local function fireFireball(pos, spot, item)		
		if item then	
			local fireball = getObjSlot('fireball')
			local originalSlot = store.inventory.hotbarSlot
			hotbarSwitch(fireball)
			local meta = bedwars.ProjectileMeta.fireball
			local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
			if calc then
				local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
				bedwars.ProjectileController:createLocalProjectile(meta, 'fireball', 'fireball', pos, nil, dir, {drawDurationSeconds = 1})
				projectileRemote:InvokeServer(item.tool, 'fireball', 'fireball', pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
				task.wait(0.15)
				hotbarSwitch(originalSlot)
			end
		end
	end

	local function launchpad(item)
		if item then
			local gum = getObjSlot('gumdrop_bounce_pad')
			local originalSlot = store.inventory.hotbarSlot
			hotbarSwitch(gum)
			task.wait(0.15)
			hotbarSwitch(originalSlot)
			local old = bedwars.LaunchPadController.attemptLaunch
			bedwars.LaunchPadController.attemptLaunch = function(...)
				local res = {old(...)}
				local self, block = ...
			
				if (workspace:GetServerTimeNow() - self.lastLaunch) < 0.4 then
					if block:GetAttribute('PlacedByUserId') == lplr.UserId and (block.Position - entitylib.character.RootPart.Position).Magnitude < 30 then
						task.spawn(bedwars.breakBlock, block, false, nil, true)
					end
				end
			
					return unpack(res)
				end
			
			MLG:Clean(function()
				bedwars.LaunchPadController.attemptLaunch = old
			end)
		end
	end

	MLG = vape.Categories.Utility:CreateModule({
		Name = "MLG",
		Tooltip = "Impressive game plays tactics",
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				if not Pearls.Enabled and not Fireball.Enabled and not Gumdrop.Enabled then
					vape:CreateNotification("MLG", "nigga you dont have anything enabled for this holy useless gng", 10, "alert")
					MLG:Toggle(false)
					return
				end
				repeat
					if Pearls.Enabled then
						if entitylib.isAlive then
							local root = entitylib.character.RootPart
							local pearl = getItem('telepearl')
							rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, AntiFallPart}
							rayCheck.CollisionGroup = root.CollisionGroup
							local drop = getDropDistance(root)

							if pearl and root.Velocity.Y < -80 and drop > 20  then
								if not check then
									check = true
									local ground = getNearGround(20)
		
									if ground then
										firePearl(root.Position, ground, pearl)
									end
								end
							else
								check = false
							end
						end
					end
					if Fireball.Enabled then
						if entitylib.isAlive then
							local root = entitylib.character.RootPart
							local fireball = getItem('fireball')
							rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, AntiFallPart}
							rayCheck.CollisionGroup = root.CollisionGroup
							local drop = getDropDistance(root)

							if fireball and drop < 20  then
								if not check then
									check = true
									local ground = getNearGround(20)
		
									if ground then
										fireFireball(root.Position, ground, fireball)
									end
								end
							else
								check = false
							end
						end
					end
					if Gumdrop.Enabled then
						if entitylib.isAlive then
							local root = entitylib.character.RootPart
							local gum = getItem('gumdrop_bounce_pad')
							rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, AntiFallPart}
							rayCheck.CollisionGroup = root.CollisionGroup
							local drop = getDropDistance(root)

							if gum and drop <= 10  then
								if not check then
									check = true
									local ground = getNearGround(20)
		
									if ground then
										launchpad(gum)
									end
								end
							else
								check = false
							end
						end
					end
					task.wait(0.05)
				until MLG.Enabled
			else
 				
			end
		end
	})

	Pearls = MLG:CreateToggle({
		Name = "Pearl",
		Tooltip = "Good pearl plays, void and high ground",
		Default = true
	})
	Fireball = MLG:CreateToggle({
		Name = "Fireball",
		Tooltip = "Fires a fireball at the ground when close to ground deflecting fall damage",
		Default = true
	})
	Gumdrop = MLG:CreateToggle({
		Name = "Gumdrop",
		Tooltip = "Places an gumdrop whenever ur close to falling to the ground deflecting the fall damage",
		Default = true
	})
end)

run(function()
	local FullBright
	FullBright = vape.Categories.Render:CreateModule({
		Name = 'FullBright',
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				lightingService.GlobalShadows = false
			else
				lightingService.GlobalShadows = true
			end
		end,
		Tooltip = 'Turns off global shadows, fps booster as well!'
	})
end)

run(function()
    local BuyBlocksModule
    local GUICheck
    local DelaySlider
    local running = false

    local function getShopNPC()
        local shopFound = false
        if entitylib.isAlive then
            local localPosition = entitylib.character.RootPart.Position
            for _, v in store.shop do
                if (v.RootPart.Position - localPosition).Magnitude <= 20 then
                    shopFound = true
                    break
                end
            end
        end
        return shopFound
    end

    BuyBlocksModule = vape.Categories.Utility:CreateModule({
        Name = "BuyBlocks",
        Function = function(cb)
            running = cb

            if cb then
                task.spawn(function()
                    while running do
                        local canBuy = true
                        
                        if GUICheck.Enabled then
                            if bedwars.AppController:isAppOpen('BedwarsItemShopApp') then
                                canBuy = true
                            else
                                canBuy = false
                            end
                        else
                            canBuy = getShopNPC()
                        end

                        if canBuy then
                            local args = {
                                {
                                    shopItem = {
                                        currency = "iron",
                                        itemType = "wool_white",
                                        amount = 16,
                                        price = 8,
                                        category = "Blocks"
                                    },
                                    shopId = "2_item_shop_1"
                                }
                            }

                            pcall(function()
                                game:GetService("ReplicatedStorage")
                                :WaitForChild("rbxts_include")
                                :WaitForChild("node_modules")
                                :WaitForChild("@rbxts")
                                :WaitForChild("net")
                                :WaitForChild("out")
                                :WaitForChild("_NetManaged")
                                :WaitForChild("BedwarsPurchaseItem")
                                :InvokeServer(unpack(args))
                            end)
                        end

                        task.wait(1 / DelaySlider.GetRandomValue())
                    end
                end)
            end
        end,
        Tooltip = "Automatically buys wool blocks for your lazy ass(thanks to synv4 for giving me this script)"
    })

    GUICheck = BuyBlocksModule:CreateToggle({
        Name = "GUI Check",
        Tooltip = "Only buy when shop GUI is open",
        Default = false
    })

    DelaySlider = BuyBlocksModule:CreateTwoSlider({
        Name = "Delay",
        Min = 0.1,
        Max = 2,
		DefaultMin = 0.1,
		DefaultMax = 0.4,
        Decimal = 10,
		Suffix = "s",
        Tooltip = "Delay between purchases"
    })
end)
run(function()
    local RepelLag
    local Delay
    local TransmissionOffset
    local originalRemotes = {}
    local queuedCalls = {}
    local isProcessing = false
    local callInterception = {}
    
    local function backupRemoteMethods()
        if not bedwars or not bedwars.Client then return end
        
        local oldGet = bedwars.Client.Get
        callInterception.oldGet = oldGet
        
        for name, path in pairs(remotes) do
            local remote = oldGet(bedwars.Client, path)
            if remote and remote.SendToServer then
                originalRemotes[path] = remote.SendToServer
            end
        end
    end
    
    local function processDelayedCalls()
        if isProcessing then return end
        isProcessing = true
        
        task.spawn(function()
            while RepelLag.Enabled and #queuedCalls > 0 do
                local currentTime = tick()
                local toExecute = {}
                
                for i = #queuedCalls, 1, -1 do
                    local call = queuedCalls[i]
                    if currentTime >= call.executeTime then
                        table.insert(toExecute, 1, call)
                        table.remove(queuedCalls, i)
                    end
                end
                
                for _, call in ipairs(toExecute) do
                    pcall(function()
                        if call.remote and call.method == "FireServer" then
                            call.remote:FireServer(unpack(call.args))
                        elseif call.remote and call.method == "InvokeServer" then
                            call.remote:InvokeServer(unpack(call.args))
                        elseif call.originalFunc then
                            call.originalFunc(call.remote, unpack(call.args))
                        end
                    end)
                end
                
                task.wait(0.001)
            end
            isProcessing = false
        end)
    end
    
    local function queueRemoteCall(remote, method, originalFunc, ...)
        local currentDelay = Delay.Value
            if entitylib.isAlive then
                local nearestDist = math.huge
                for _, entity in ipairs(entitylib.List) do
                    if entity.Targetable and entity.Player and entity.Player ~= lplr then
                        local dist = (entity.RootPart.Position - entitylib.character.RootPart.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                        end
                    end
                end
                
                if nearestDist < 15 then
                    local repelFactor = (15 - nearestDist) / 15
                    currentDelay = currentDelay * (1 + (repelFactor * 2))
                end
            end
        
        if TransmissionOffset.Value > 0 then
            local jitter = math.random(-TransmissionOffset.Value, TransmissionOffset.Value)
            currentDelay = math.max(0, currentDelay + jitter)
        end
        
        table.insert(queuedCalls, {
            remote = remote,
            method = method,
            originalFunc = originalFunc,
            args = {...},
            executeTime = tick() + (currentDelay / 1000)
        })
        
        processDelayedCalls()
    end
    
    local function interceptRemotes()
        if not bedwars or not bedwars.Client then return end
        
        local oldGet = callInterception.oldGet
        bedwars.Client.Get = function(self, remotePath)
            local remote = oldGet(self, remotePath)
            
            if remote and remote.SendToServer then
                local originalSend = remote.SendToServer
                remote.SendToServer = function(self, ...)
                    if RepelLag.Enabled and Delay.Value > 0 then
                        queueRemoteCall(self, "SendToServer", originalSend, ...)
                        return
                    end
                    return originalSend(self, ...)
                end
            end
            
            return remote
        end
        
        local function interceptSpecificRemote(path)
            local remote = oldGet(bedwars.Client, path)
            if remote and remote.FireServer then
                local originalFire = remote.FireServer
                remote.FireServer = function(self, ...)
                    if RepelLag.Enabled and Delay.Value > 0 then
                        queueRemoteCall(self, "FireServer", originalFire, ...)
                        return
                    end
                    return originalFire(self, ...)
                end
            end
        end
        
        if remotes.AttackEntity then interceptSpecificRemote(remotes.AttackEntity) end
        if remotes.PlaceBlockEvent then interceptSpecificRemote(remotes.PlaceBlockEvent) end
        if remotes.BreakBlockEvent then interceptSpecificRemote(remotes.BreakBlockEvent) end
    end
    
    RepelLag = vape.Categories.World:CreateModule({
        Name = 'RepelLag',
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"  then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end
            if callback then
                backupRemoteMethods()
                interceptRemotes()
                
            else
                if bedwars and bedwars.Client and callInterception.oldGet then
                    bedwars.Client.Get = callInterception.oldGet
                end
                
                for _, call in ipairs(queuedCalls) do
                    pcall(function()
                        if call.originalFunc then
                            call.originalFunc(call.remote, unpack(call.args))
                        end
                    end)
                end
                table.clear(queuedCalls)
            end
        end,
        Tooltip = 'Desync but sync\'s with the current world making you look fakelag and alittle with backtrack'

    })
    TransmissionOffset = RepelLag:CreateSlider({
		Name = "Transmission",
		Min = 0,
		Max = 5,
		Default = 2,
		Tooltip = 'jitteries ur movement'
	})
	Delay = RepelLag:CreateSlider({
		Name = "Delay",
		Suffix = "ms",
		Min = 5,
		Max = 1000,
		Default = math.floor(math.random(100,250) - math.random(1,5) - math.random())
	})
    
end)

run(function()
	local AEGT
	local e
	local function Reset()
		if #playersService:GetChildren() == 1 then return end
		local TeleportService = game:GetService("TeleportService")
		local data = TeleportService:GetLocalPlayerTeleportData()
		AEGT:Clean(TeleportService:Teleport(game.PlaceId, lplr, data))
	end
	AEGT = vape.Categories.AltFarm:CreateModule({
		Name = 'AutoEmptyGameTP',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				if E.Enabled then
					AEGT:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
						if deathTable.finalKill and deathTable.entityInstance == lplr.Character and isEveryoneDead() and store.matchState ~= 2 then
							Reset()
						end
					end))
					AEGT:Clean(vapeEvents.MatchEndEvent.Event:Connect(Reset))
				else
                    if #playersService:GetChildren() > 1 then
                        vape:CreateNotification("AutoEmptyGameTP", "Teleporting to Empty Game!", 6)
                        task.wait((6 / 3.335))
						Reset()
					end
				end
			else
				return
			end
		end,
		Tooltip = 'Makes you automatically TP to a empty game'
	})
	E = AEGT:CreateToggle({
		Name = "Game Ended",
		Default = true,
		Tooltip = "Makes you TP whenever you win/lose a match causing you to reset the history"
	})
end)



run(function()
	local MouseTP
	local mode
	local pos
	local function getNearestPlayer()
		local character = entitylib.character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then return nil end

		local nearestPlayer = nil
		local shortestDistance = math.huge or (2^1024-1)
		local myPos = hrp.Position

		for _, player in ipairs(playersService:GetPlayers()) do
			if player ~= lplr then
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")

				if root and hum and hum.Health > 0 then
					local dist = (root.Position - myPos).Magnitude
					if dist < shortestDistance then
						nearestPlayer = player
					end
				end
			end
		end

		return nearestPlayer
	end
	local function Elektra(type)
		if type == "Mouse" then
			local rayCheck = RaycastParams.new()
			rayCheck.RespectCanCollide = true
			local ray = cloneref(lplr:GetMouse()).UnitRay
			rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
			ray = workspace:Raycast(ray.Origin, ray.Direction * 10000, rayCheck)
			position = ray and ray.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)
			if not position then
				notif('MouseTP', 'No position found.', 5)
				MouseTP:Toggle(false)
				return
			end
			
			if bedwars.AbilityController:canUseAbility('ELECTRIC_DASH') then
				local info = TweenInfo.new(0.72,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
				local tween = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.lookAlong(position, entitylib.character.RootPart.CFrame.LookVector)})
				tween:Play()
				task.wait(0.69)
				bedwars.AbilityController:useAbility('ELECTRIC_DASH')
				MouseTP:Toggle(false)
			end
		else
			local FoundedPLR = getNearestPlayer()
			if FoundedPLR then
				local position = FoundedPLR.Character.HumanoidRootPart.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)
				if not position then
					notif('MouseTP', 'No position found.', 5)
					MouseTP:Toggle(false)
					return
				end
				
				if bedwars.AbilityController:canUseAbility('ELECTRIC_DASH') then
					local info = TweenInfo.new(0.72,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
					local tween = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.lookAlong(position, entitylib.character.RootPart.CFrame.LookVector)})
					tween:Play()
					task.wait(0.69)
					bedwars.AbilityController:useAbility('ELECTRIC_DASH')
					MouseTP:Toggle(false)
				end
			end
		end
	end
	
	local function Davey(type)
		if type == "Mouse" then
			local Cannon = getItem("cannon")
			local ray = cloneref(lplr:GetMouse()).UnitRay
			local rayCheck = RaycastParams.new()
			rayCheck.RespectCanCollide = true
			rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
			ray = workspace:Raycast(ray.Origin, ray.Direction * 10000, rayCheck)
			position = ray and ray.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)

			if not position then
				notif('MouseTP', 'No position found.', 5,"warning")
				MouseTP:Toggle(false)
				return
			end

				
			if not Cannon then
				notif('MouseTP', 'No cannon found.', 5,"warning")
				MouseTP:Toggle(false)
				return
			end

			if not entitylib.isAlive then
				notif('MouseTP', 'Cannot locate where i am at?', 5,"warning")
				MouseTP:Toggle(false)
				return
			end
			local pos = entitylib.character.RootPart.Position
			pos = pos - Vector3.new(0, (entitylib.character.HipHeight + (entitylib.character.RootPart.Size.Y / 2)) - 3, 0)
			local rounded = Vector3.new(math.round(pos.X / 3) * 3, math.round(pos.Y / 3) * 3, math.round(pos.Z / 3) * 3)
			bedwars.placeBlock(rounded, 'cannon', false)
			local block, blockpos = getPlacedBlock(rounded)
			if block then
				if block.Name == "cannon" then
					if (entitylib.character.RootPart.Position - block.Position).Magnitude < 20 then
						bedwars.Client:Get(remotes.CannonAim):SendToServer({
							cannonBlockPos = blockpos,
							lookVector = position
						})
						local broken = 0.1
						if bedwars.BlockController:calculateBlockDamage(lplr, {blockPosition = blockpos}) < block:GetAttribute('Health') then
							broken = 0.4
							bedwars.breakBlock(block, true, true)
						end
			
						task.delay(broken, function()
							for _ = 1, 3 do
								local call = bedwars.Client:Get(remotes.CannonLaunch):CallServer({cannonBlockPos = blockpos})
								if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
									humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								end
								if call then
									bedwars.breakBlock(block, true, true)
									break
								end
								task.wait(0.1)
							end
						end)
						MouseTP:Toggle(false)
					end
				end
			end
		else
			local Cannon = getItem("cannon")
			local FoundedPLR = getNearestPlayer()
			if FoundedPLR then
				local position = FoundedPLR.Character.HumanoidRootPart.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)
				local old = nil
				if not position then
					notif('MouseTP', 'No position found.', 5)
					MouseTP:Toggle(false)
					return
				end
				if not Cannon then
					notif('MouseTP', 'No cannon found.', 5,"warning")
					MouseTP:Toggle(false)
					return
				end

				if not entitylib.isAlive then
					notif('MouseTP', 'Cannot locate where i am at?', 5,"warning")
					MouseTP:Toggle(false)
					return
				end
				local pos = entitylib.character.RootPart.Position
				pos = pos - Vector3.new(0, (entitylib.character.HipHeight + (entitylib.character.RootPart.Size.Y / 2)) - 3, 0)
				local rounded = Vector3.new(math.round(pos.X / 3) * 3, math.round(pos.Y / 3) * 3, math.round(pos.Z / 3) * 3)
				bedwars.placeBlock(rounded, 'cannon', false)
				local block, blockpos = getPlacedBlock(rounded)
				if block then
					if block.Name == "cannon" then
						if (entitylib.character.RootPart.Position - block.Position).Magnitude < 20 then
							bedwars.Client:Get(remotes.CannonAim):SendToServer({
								cannonBlockPos = blockpos,
								lookVector = position
							})
							local broken = 0.1
							if bedwars.BlockController:calculateBlockDamage(lplr, {blockPosition = blockpos}) < block:GetAttribute('Health') then
								broken = 0.4
								bedwars.breakBlock(block, true, true)
							end
				
							task.delay(broken, function()
								for _ = 1, 3 do
									local call = bedwars.Client:Get(remotes.CannonLaunch):CallServer({cannonBlockPos = blockpos})
									if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
										humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
									end
									if call then
										bedwars.breakBlock(block, true, true)
										break
									end
									task.wait(0.1)
								end
							end)
							MouseTP:Toggle(false)
						end
					end
				end
			end
		end
	end

	local function Yuzi(type)
		if type == "Mouse" then
			local old = nil
			local rayCheck = RaycastParams.new()
			rayCheck.RespectCanCollide = true
			local ray = cloneref(lplr:GetMouse()).UnitRay
			rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
			ray = workspace:Raycast(ray.Origin, ray.Direction * 10000, rayCheck)
			position = ray and ray.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)
			if not position then
				notif('MouseTP', 'No position found.', 5)
				MouseTP:Toggle(false)
				return
			end
			
			if bedwars.AbilityController:canUseAbility('dash') then
				old = bedwars.YuziController.dashForward
				bedwars.YuziController.dashForward = function(v1,v2)
					local arg = nil
					if v1 then
						arg = v1
					else
						arg = v2
					end
					if entitylib.isAlive then
						entitylib.character.RootPart.CFrame = CFrame.lookAt(entitylib.character.RootPart.Position,entitylib.character.RootPart.Position + arg * Vector3.new(1, 0, 1))
						entitylib.character.Humanoid.JumpHeight = 0.5
						entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						entitylib.character.RootPart:ApplyImpulse(CFrame.lookAlong(position, entitylib.character.RootPart.CFrame.LookVector))
						bedwars.JumpHeightController:setJumpHeight(cloneref(game:GetService("StarterPlayer")).CharacterJumpHeight)
						bedwars.SoundManager:playSound(bedwars.SoundList.DAO_SLASH)
						local any_playAnimation_result1 = bedwars.GameAnimationUtil:playAnimation(lplr, bedwars.AnimationType.DAO_DASH)
						if any_playAnimation_result1 ~= nil then
							any_playAnimation_result1:AdjustSpeed(2.5)
						end
					end
				end
				bedwars.AbilityController:useAbility('dash',nil,{
					direction = gameCamera.CFrame.LookVector,
					origin = entitylib.character.RootPart.Position,
					weapon = store.hand.tool.Name.itemType,
				})
				task.wait(0.15)
				bedwars.YuziController.dashForward = old
				old = nil
				MouseTP:Toggle(false)
			end
		else
			local FoundedPLR = getNearestPlayer()
			if FoundedPLR then
				local position = FoundedPLR.Character.HumanoidRootPart.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)
				local old = nil
				if not position then
					notif('MouseTP', 'No position found.', 5)
					MouseTP:Toggle(false)
					return
				end
				
				if bedwars.AbilityController:canUseAbility('dash') then
					old = bedwars.YuziController.dashForward
					bedwars.YuziController.dashForward = function(v1,v2)
						local arg = nil
						if v1 then
							arg = v1
						else
							arg = v2
						end
						if entitylib.isAlive then
							entitylib.character.RootPart.CFrame = CFrame.lookAt(entitylib.character.RootPart.Position,entitylib.character.RootPart.Position + arg * Vector3.new(1, 0, 1))
							entitylib.character.Humanoid.JumpHeight = 0.5
							entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							entitylib.character.RootPart:ApplyImpulse(CFrame.lookAlong(position, entitylib.character.RootPart.CFrame.LookVector))
							bedwars.JumpHeightController:setJumpHeight(cloneref(game:GetService("StarterPlayer")).CharacterJumpHeight)
							bedwars.SoundManager:playSound(bedwars.SoundList.DAO_SLASH)
							local any_playAnimation_result1 = bedwars.GameAnimationUtil:playAnimation(lplr, bedwars.AnimationType.DAO_DASH)
							if any_playAnimation_result1 ~= nil then
								any_playAnimation_result1:AdjustSpeed(2.5)
							end
						end
					end
					bedwars.AbilityController:useAbility('dash',nil,{
						direction = gameCamera.CFrame.LookVector,
						origin = entitylib.character.RootPart.Position,
						weapon = store.hand.tool.Name.itemType,
					})
					task.wait(0.15)
					bedwars.YuziController.dashForward = old
					old = nil
					MouseTP:Toggle(false)
				end
			end
		end
	end

	local function Zar(type)
		notif('MouseTP', 'Comming soon!', 8,'warning')
		MouseTP:Toggle(false)
		return
	end

	local function Mouse(type)
		if type == "Mouse" then
			local position
			local rayCheck = RaycastParams.new()
			rayCheck.RespectCanCollide = true
			local ray = cloneref(lplr:GetMouse()).UnitRay
			rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
			ray = workspace:Raycast(ray.Origin, ray.Direction * 10000, rayCheck)
			position = ray and ray.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)
			entitylib.character.RootPart.CFrame = CFrame.lookAlong(position, entitylib.character.RootPart.CFrame.LookVector)
		
			if not position then
				notif('MouseTP', 'No position found.', 5)
				MouseTP:Toggle(false)
				return
			end
		else
			local FoundedPLR = getNearestPlayer()
			if FoundedPLR then
				local position = FoundedPLR.Character.HumanoidRootPart.Position + Vector3.new(0, entitylib.character.HipHeight or 2, 0)
				entitylib.character.RootPart.CFrame = CFrame.lookAlong(position, entitylib.character.RootPart.CFrame.LookVector)
				if not position then
					notif('MouseTP', 'No player found.', 5)
					MouseTP:Toggle(false)
					return
				end
			end
		end
		MouseTP:Toggle(false)
	end

	MouseTP = vape.Categories.Utility:CreateModule({
		Name = 'MouseTP',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"  then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if not callback then return end
			if callback then
				if mode.Value == "Mouse" then
					Mouse(pos.Value)
				elseif mode.Value == "Kits" then
					if store.equippedKit == "elektra" then
						Elektra(pos.Value)
					elseif store.equippedKit == "davey" then
						Davey(pos.Value)
					elseif store.equippedKit == "dasher" then
						Yuzi(pos.Value)
					elseif store.equippedKit == "gun_blade" then
						Zar(pos.Value)
					else
						vape:CreateNotification("MouseTP", "Current kit is not supported for MouseTP", 4.5, "warning")
						MouseTP:Toggle(false)
						return
					end
				else
					Mouse()
				end
			end
		end,
	})
	mode = MouseTP:CreateDropdown({
		Name = "Mode",
		List = {'Mouse','Kits'}
	})
	pos =  MouseTP:CreateDropdown({
		Name = "Position",
		List = {'Cloeset Player', 'Mouse'}
	})
end)
--[[
run(function()
	local FalseBan
	local real_list = {}
	local PlayersDropdown
	local RefreshButton
	local Type 
	local target = ""

	local function CreatePlayerList()
		target = ""
		if real_list == nil then
			for _, v in pairs(playersService:GetPlayers()) do
				if v == lplr then
					continue
				end
				table.insert(real_list, v.Name)
			end
	else
				table.clear(real_list)
			for _, v in pairs(playersService:GetPlayers()) do
				if v == lplr then
					continue
				end
				table.insert(real_list, v.Name)
			end
		end

	end

	local function FakeReach(call)
		local cb = call
		local MaxDistance = 30
		local PLRTarget = playersService:FindFirstChild(target)
		if PLRTarget then
			local CurrentDistance = 0
			while cb do
				CurrentDistance = (PLRTarget.Character.HumanoidRootPart.Position - entitylib.character.RootPart.Position).Magnitude
				if CurrentDistance <= MaxDistance then
					local Damage = math.random(10,25)
					local NewDmg = math.floor((Damage - math.random(2,5) - math.random()))
					entitylib.character.Humanoid:TakeDamage(NewDmg)
				else
					continue
				end
				task.wait(0.5)
			end
		else
			cb = false
			vape:CreateNotification("FalseBan", target.." Does not exist! check again later",4,"warning")
			FalseBan:Toggle(false)
			return
		end
	end

	local function FakeGodMode(call)
		local cb = call
		local MaxDistance = 45
		local PLRTarget = playersService:FindFirstChild(target)
		local old = {}
		if PLRTarget then
			local CurrentDistance = 0
			while cb do
				CurrentDistance = (PLRTarget.Character.HumanoidRootPart.Position - entitylib.character.RootPart.Position).Magnitude
				if CurrentDistance <= MaxDistance then
					for i, v in PLRTarget.Character:GetDescendants() do
						if (v:IsA("BasePart") or v:IsA("Decal")) and old[v] == nil then
							old[v] = v.Transparency
							v.Transparency = 1
						end
					end
				else
					for inst, transparency in pairs(old) do
						if inst and inst.Parent then
							inst.Transparency = transparency
						end
						old[inst] = nil
					end
					continue
				end
				task.wait(0.3456)
			end
		else
			vape:CreateNotification("FalseBan", target.." Does not exist! check again later",4,"warning")
			cb = false
			FalseBan:Toggle(false)
			return
		end
	end

	local function FakeInv(call)
		local cb = call
		local MaxDistance = math.huge or (2^1024-1) -- seem some executors who cannot handle math.huge SON IM CRINE
		local PLRTarget = playersService:FindFirstChild(target)
		local old = {}
		if PLRTarget then
			local CurrentDistance = 0
			task.spawn(function()
				if not cb then
					for inst, transparency in pairs(old) do
						if inst and inst.Parent then
							inst.Transparency = transparency
						end
						old[inst] = nil
					end
				end
			end)
			while cb do
				CurrentDistance = (PLRTarget.Character.HumanoidRootPart.Position - entitylib.character.RootPart.Position).Magnitude
				if CurrentDistance <= MaxDistance then
					for i, v in PLRTarget.Character:GetDescendants() do
						if (v:IsA("BasePart") or v:IsA("Decal")) and old[v] == nil then
							old[v] = v.Transparency
							v.Transparency = 1
						end
					end
				else
					for inst, transparency in pairs(old) do
						if inst and inst.Parent then
							inst.Transparency = transparency
						end
						old[inst] = nil
					end
					continue
				end
				task.wait(0.3456)
			end

		else
			cb = false
			vape:CreateNotification("FalseBan", target.." Does not exist! check again later",4,"warning")
			FalseBan:Toggle(false)
			return
		end
	end

	local function MainTree(cb,type)
		if type == "Godmode" then
			FakeGodMode(cb)
		elseif type == "Reach" then
			FakeReach(cb)
		elseif type == "Invisible" then
			FakeInv(cb)
		else
			FakeGodMode(cb)
		end
	end

	CreatePlayerList()
	FalseBan = vape.Categories.World:CreateModule({
		Name = 'FalseBan',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end
			MainTree(callback, Type.Value)
		end,
		Tooltip = 'makes the targetted player be blatant for you to clip and get him banned'
	})

	PlayersDropdown = FalseBan:CreateDropdown({
		Name = "Players",
		List = real_list,
		Function = function()
			target = PlayersDropdown.Value
		end
	})
	RefreshButton = FalseBan:CreateButton({
		Name = "Refresh",
		Darker = true,
		Function = function()
			CreatePlayerList()
			PlayersDropdown.List = real_list
		end
	})
	Type = FalseBan:CreateDropdown({
		Name = "Type",
		List = {"Godmode",'Reach','Invisible'}
	})
end)
--]]
run(function()
    local AutoWin
	local function Duels()
		if Speed.Enabled and Fly.Enabled then
			Fly:Toggle(false)
			task.wait(0.025)
			Speed:Toggle(false)
		elseif Speed.Enabled then
			Speed:Toggle(false)
		elseif Fly.Enabled then
			Fly:Toggle(false)
		end

		if not Scaffold.Enabled and not Breaker.Enabled then
			Breaker:Toggle(true)
			task.wait(0.025)
			Scaffold:Toggle(true)
		elseif not Scaffold.Enabled then
			Scaffold:Toggle(true)
		elseif not Breaker.Enabled then
			Breaker:Toggle(true)
		end

                    local T = 50
                    if #playersService:GetChildren() > 1 then
                        vape:CreateNotification("AutoWin", "Teleporting to Empty Game!", 6)
                        task.wait((6 / 3.335))
                        local data = TeleportService:GetLocalPlayerTeleportData()
                        AutoWin:Clean(TeleportService:Teleport(game.PlaceId, lplr, data))
                    end
                    if lplr.Team.Name ~= "Orange" and lplr.Team.Name ~= "Blue" then
                        vape:CreateNotification("AutoWin","Waiting for an assigned team! (this may take a while if early loaded)", 6)
                        task.wait(15)
                    end
                    local ID = lplr:GetAttribute("Team")
                    local GeneratorName = "cframe-" .. ID .. "_generator"
                    local ItemShopName = ID .. "_item_shop"
					if ID == "2" then
						ItemShopName = ID .. "_item_shop_1"
					else
						ItemShopName = ItemShopName
					end
                    local CurrentGen = workspace:FindFirstChild(GeneratorName)
                    local CurrentItemShop = workspace:FindFirstChild(ItemShopName)
                    local id = "0"
                	local oppTeamName = "nil"
                    if ID == "1" then
                        id = "2"
                        oppTeamName = "Orange"
                    else
                        id = "1"
                        oppTeamName = "Blue"
                    end
                    local OppBedName = id .. "_bed"
                    local OppositeTeamBedPos = workspace:FindFirstChild("MapCFrames"):FindFirstChild(OppBedName).Value.Position

					local function PurchaseWool()
					    replicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.BedwarsPurchaseItem:InvokeServer({
					        shopItem = {
					            currency = "iron",
					            itemType = "wool_white",
					            amount = 16,
					            price = 8,
					            category = "Blocks",
					            disabledInQueue = {"mine_wars"}
					        },
					        shopId = "1_item_shop"
					    })
					end
					
					local function fly()
					    task.spawn(function()
					        while task.wait() do
					            if entitylib and entitylib.isAlive then
					                local char = lplr.Character
					                local root = char and char.PrimaryPart
					                if root then
					                    local v = root.Velocity
					                    root.Velocity = Vector3.new(v.X, 0, v.Z)
					                end
					            end
					        end
					    end)
					end
					
					local function Speed()
					    task.spawn(function()
					        while task.wait() do
					            if entitylib and entitylib.isAlive then
					                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
					                if hum then
					                    hum.WalkSpeed = 23.05
					                end
					            end
					        end
					    end)
					end
					
					local function checkWallClimb()
					    if not (entitylib and entitylib.isAlive) then
					        return false
					    end
					
					    local character = lplr.Character
					    local root = character and character.PrimaryPart
					    if not root then
					        return false
					    end
					
					    local raycastParams = RaycastParams.new()
					    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					    raycastParams.FilterDescendantsInstances = {
					        character,
					        camera and camera:FindFirstChild("Viewmodel"),
					        Workspace:FindFirstChild("ItemDrops")
					    }
					
					    local origin = root.Position - Vector3.new(0, 1, 0)
					    local direction = root.CFrame.LookVector * 1.5
					
					    local result = Workspace:Raycast(origin, direction, raycastParams)
					    if result and result.Instance and result.Instance.Transparency < 1 then
					        root.Velocity = Vector3.new(root.Velocity.X, 100, root.Velocity.Z)
					    end
					
					    return true
					end
					
					local function climbwalls()
					    task.spawn(function()
					        while task.wait() do
					            if entitylib and entitylib.isAlive then
					                pcall(checkWallClimb)
					            else
					                break
					            end
					        end
					    end)
					end
                        local function MapLayoutBLUE()
                            if workspace.Map.Worlds:FindFirstChild("duels_Swamp") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.15)
                                local pos = {
                                    [1] = Vector3.new(54.42063522338867, 22.4999942779541, 99.56651306152344),
                                    [2] = Vector3.new(119.33378601074219, 22.4999942779541, 99.06503295898438),
                                    [3] = Vector3.new(231.82752990722656, 19.4999942779541, 98.30278015136719),
                                    [4] = Vector3.new(230.23426818847656, 19.4999942779541, 142.17169189453125),
                                    [5] = Vector3.new(237.4776153564453, 22.4999942779541, 142.03660583496094)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 5 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Blossom") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(153.83029174804688, 37.4999885559082, 146.81619262695312),
                                    [2] = Vector3.new(172.6735382080078, 37.4999885559082, 120.15453338623047),
                                    [3] = Vector3.new(172.6735382080078, 37.4999885559082, 120.15453338623047),
                                    [4] = Vector3.new(284.78765869140625, 37.4999885559082, 124.80931854248047),
                                    [5] = Vector3.new(293.6907958984375, 37.4999885559082, 143.09649658203125)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Darkholm") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(56.4425163269043, 70.4999771118164, 196.7547607421875),
                                    [2] = Vector3.new(188.90316772460938, 70.4999771118164, 198.4145050048828),
                                    [3] = Vector3.new(194.74700927734375, 73.4999771118164, 198.49697875976562),
                                    [4] = Vector3.new(198.50704956054688, 76.4999771118164, 198.38743591308594),
                                    [5] = Vector3.new(201.18421936035156, 79.4999771118164, 198.30943298339844),
                                    [6] = Vector3.new(340.8443603515625, 70.4999771118164, 197.34677124023438)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 3 or i == 4 or i == 5 or i == 6 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Christmas") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(143.5197296142578, 40.4999885559082, 410.59930419921875),
                                    [2] = Vector3.new(143.98350524902344, 40.4999885559082, 328.6651306152344),
                                    [3] = Vector3.new(133.665771484375, 40.4999885559082, 328.6337585449219),
                                    [4] = Vector3.new(134.53382873535156, 40.4999885559082, 253.40147399902344),
                                    [5] = Vector3.new(106.36888122558594, 40.4999885559082, 253.07655334472656),
                                    [6] = Vector3.new(108.05854797363281, 40.4999885559082, 162.84751892089844),
                                    [7] = Vector3.new(150.0508575439453, 40.4999885559082, 139.75106811523438)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Crystalmount") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(56.529605865478516, 31.4999942779541, 117.44342803955078),
                                    [2] = Vector3.new(243.1451873779297, 28.4999942779541, 117.13523864746094),
                                    [3] = Vector3.new(243.86920166015625, 28.4999942779541, 132.01922607421875),
                                    [4] = Vector3.new(284.8253173828125, 28.4999942779541, 131.13760375976562),
                                    [5] = Vector3.new(284.3399963378906, 28.4999942779541, 197.74057006835938),
                                    [6] = Vector3.new(336.2626953125, 28.4999942779541, 197.87362670898438),
                                    [7] = Vector3.new(336.4390563964844, 28.4999942779541, 212.56610107421875)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Desert-Shrine") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(160.9988250732422, 37.4999885559082, 104.86061096191406),
                                    [2] = Vector3.new(211.70367431640625, 37.4999885559082, 104.84205627441406),
                                    [3] = Vector3.new(225.6957244873047, 40.4999885559082, 105.22856140136719),
                                    [4] = Vector3.new(231.78103637695312, 43.4999885559082, 105.20640563964844),
                                    [5] = Vector3.new(240.7913360595703, 46.4999885559082, 105.17339324951172),
                                    [6] = Vector3.new(261.78643798828125, 46.4999885559082, 105.35729217529297),
                                    [7] = Vector3.new(260.72406005859375, 37.4999885559082, 147.41888427734375)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 4 or i == 5 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Canyon") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(106.2856216430664, 22.4999942779541, 167.7103271484375),
                                    [2] = Vector3.new(205.44677734375, 22.4999942779541, 168.1051483154297),
                                    [3] = Vector3.new(206.19129943847656, 22.4999942779541, 122.0677261352539),
                                    [4] = Vector3.new(246.20388793945312, 22.4999942779541, 122.23123931884766),
                                    [5] = Vector3.new(246.25616455078125, 22.4999942779541, 117.90743255615234),
                                    [6] = Vector3.new(340.50830078125, 22.4999942779541, 119.04676818847656),
                                    [7] = Vector3.new(408.0753479003906, 22.4999942779541, 119.86353302001953),
                                    [8] = Vector3.new(408.1478576660156, 25.4999942779541, 147.79750061035156),
                                    [9] = Vector3.new(408.3157958984375, 28.4999942779541, 152.88963317871094),
                                    [10] = Vector3.new(408.40478515625, 31.4999942779541, 156.04873657226562),
                                    [11] = Vector3.new(416.6556396484375, 31.4999942779541, 156.042724609375)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 3 or i == 9 or i == 10 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    if i == 8 then
                                        task.wait(0.85)
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Fountain-Peaks") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(197.8756103515625, 55.4999885559082, 146.2112274169922),
                                    [2] = Vector3.new(197.74893188476562, 55.4999885559082, 203.87440490722656),
                                    [3] = Vector3.new(197.7208709716797, 55.4999885559082, 216.67771911621094),
                                    [4] = Vector3.new(197.707763671875, 58.4999885559082, 222.7259063720703),
                                    [5] = Vector3.new(197.6983184814453, 61.4999885559082, 228.9031219482422),
                                    [6] = Vector3.new(197.71287536621094, 64.4999771118164, 234.8250732421875),
                                    [7] = Vector3.new(197.7032470703125, 67.4999771118164, 240.8802947998047),
                                    [8] = Vector3.new(197.7696990966797, 70.4999771118164, 242.91575622558594),
                                    [9] = Vector3.new(216.24256896972656, 70.4999771118164, 257.28955078125),
                                    [10] = Vector3.new(216.3074188232422, 70.4999771118164, 278.1252746582031),
                                    [11] = Vector3.new(198.38975524902344, 70.4999771118164, 278.18292236328125),
                                    [12] = Vector3.new(197.85623168945312, 55.4999885559082, 325.6739196777344)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 4 or i == 5 or i == 6 or i == 7 or i == 8 or i == 9 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Glacier") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(170.14671325683594, 28.4999942779541, 101.89541625976562),
                                    [2] = Vector3.new(170.22109985351562, 28.4999942779541, 84.97834777832031),
                                    [3] = Vector3.new(175.1810760498047, 31.4999942779541, 85.0855484008789),
                                    [4] = Vector3.new(183.48684692382812, 34.4999885559082, 85.162353515625),
                                    [5] = Vector3.new(251.9368896484375, 34.4999885559082, 85.79531860351562),
                                    [6] = Vector3.new(251.87530517578125, 34.4999885559082, 123.78746032714844),
                                    [7] = Vector3.new(312.71527099609375, 28.4999942779541, 124.30342864990234),
                                    [8] = Vector3.new(372.5546875, 28.4999942779541, 124.64036560058594)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 3 or i == 4 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Enchanted-Forest") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(150.46469116210938, 16.4999942779541, 86.60432434082031),
                                    [2] = Vector3.new(210.5728759765625, 16.4999942779541, 87.79756164550781),
                                    [3] = Vector3.new(216.8912811279297, 19.4999942779541, 87.77125549316406),
                                    [4] = Vector3.new(222.78244018554688, 22.4999942779541, 87.67369842529297),
                                    [5] = Vector3.new(227.1719512939453, 25.4999942779541, 87.5146484375),
                                    [6] = Vector3.new(226.99400329589844, 25.4999942779541, 130.34024047851562)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 3 or i == 4 or i == 5 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Glade") then
                                vape:CreateNotification("AutoWin", "Teleporting to lobby, incorrect map!", 4, "warning")
                                task.wait(2.25)
                                lobby()
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Mystic") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(220.50648498535156, 61.4999885559082, 56.93876647949219),
                                    [2] = Vector3.new(220.04396057128906, 49.4999885559082, 120.4498519897461),
                                    [3] = Vector3.new(219.68345642089844, 49.4999885559082, 206.69497680664062),
                                    [4] = Vector3.new(186.8123779296875, 49.4999885559082, 206.58248901367188),
                                    [5] = Vector3.new(186.54818725585938, 49.4999885559082, 218.91282653808594),
                                    [6] = Vector3.new(141.8109588623047, 40.4999885559082, 217.94798278808594),
                                    [7] = Vector3.new(141.24285888671875, 40.4999885559082, 236.9816131591797),
                                    [8] = Vector3.new(140.99461364746094, 43.4999885559082, 243.62637329101562),
                                    [9] = Vector3.new(140.87582397460938, 46.4999885559082, 249.68634033203125),
                                    [10] = Vector3.new(140.93898010253906, 49.4999885559082, 256.1976013183594),
                                    [11] = Vector3.new(129.94161987304688, 49.4999885559082, 282.0950012207031),
                                    [12] = Vector3.new(129.7279815673828, 49.4999885559082, 341.5072326660156),
                                    [13] = Vector3.new(137.8108367919922, 49.4999885559082, 341.5338134765625),
                                    [14] = Vector3.new(137.6667022705078, 40.4999885559082, 382.5955810546875),
                                    [15] = Vector3.new(153.81500244140625, 40.4999885559082, 381.9942321777344),
                                    [16] = Vector3.new(159.4097442626953, 43.4999885559082, 381.96942138671875),
                                    [17] = Vector3.new(165.2544708251953, 46.4999885559082, 381.9435119628906),
                                    [18] = Vector3.new(172.84909057617188, 49.4999885559082, 381.909912109375),
                                    [19] = Vector3.new(181.5446319580078, 49.4999885559082, 383.2634582519531),
                                    [20] = Vector3.new(181.60052490234375, 49.4999885559082, 391.0975646972656),
                                    [21] = Vector3.new(218.74085998535156, 49.4999885559082, 391.41815185546875)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 8 or i == 9 or i == 10 or i == 11 or i == 16 or i == 17 or i == 18 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Nordic") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(149.74044799804688, 55.4999885559082, 128.84291076660156),
                                    [2] = Vector3.new(149.46397399902344, 52.4999885559082, 119.18580627441406),
                                    [3] = Vector3.new(194.9976806640625, 49.4999885559082, 118.41926574707031),
                                    [4] = Vector3.new(194.60174560546875, 49.4999885559082, 80.95228576660156),
                                    [5] = Vector3.new(251.18060302734375, 49.4999885559082, 81.73896789550781),
                                    [6] = Vector3.new(250.67430114746094, 49.4999885559082, 117.65328979492188),
                                    [7] = Vector3.new(277.3354797363281, 49.4999885559082, 118.02685546875),
                                    [8] = Vector3.new(301.5650634765625, 52.4999885559082, 119.07581329345703)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 8 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Nordic-Snowy") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(149.74044799804688, 55.4999885559082, 128.84291076660156),
                                    [2] = Vector3.new(149.46397399902344, 52.4999885559082, 119.18580627441406),
                                    [3] = Vector3.new(194.9976806640625, 49.4999885559082, 118.41926574707031),
                                    [4] = Vector3.new(194.60174560546875, 49.4999885559082, 80.95228576660156),
                                    [5] = Vector3.new(251.18060302734375, 49.4999885559082, 81.73896789550781),
                                    [6] = Vector3.new(250.67430114746094, 49.4999885559082, 117.65328979492188),
                                    [7] = Vector3.new(277.3354797363281, 49.4999885559082, 118.02685546875),
                                    [8] = Vector3.new(301.5650634765625, 52.4999885559082, 119.07581329345703)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 8 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Pinewood") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(129.2021026611328, 28.4999942779541, 135.2041473388672),
                                    [2] = Vector3.new(153.8468475341797, 28.4999942779541, 136.81089782714844),
                                    [3] = Vector3.new(167.808837890625, 25.4999942779541, 204.21250915527344),
                                    [4] = Vector3.new(167.5161590576172, 25.4999942779541, 225.06863403320312),
                                    [5] = Vector3.new(167.30459594726562, 28.4999942779541, 250.10618591308594),
                                    [6] = Vector3.new(126.89143371582031, 28.4999942779541, 249.57664489746094)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 5 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Seasonal") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(124.22999572753906, 22.4999942779541, 50.354896545410156),
                                    [2] = Vector3.new(124.38113403320312, 25.4999942779541, 77.86675262451172),
                                    [3] = Vector3.new(132.7975616455078, 25.4999942779541, 77.82051849365234),
                                    [4] = Vector3.new(132.92849731445312, 25.4999942779541, 101.65450286865234),
                                    [5] = Vector3.new(133.16488647460938, 25.4999942779541, 193.8179931640625),
                                    [6] = Vector3.new(133.18614196777344, 28.4999942779541, 202.04595947265625),
                                    [7] = Vector3.new(133.21290588378906, 31.4999942779541, 212.46200561523438),
                                    [8] = Vector3.new(133.52256774902344, 25.4999942779541, 297.04766845703125)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 2 or i == 6 or i == 7 or i == 8 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Snowman-Park") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(161.58139038085938, 16.4999942779541, 171.4049530029297),
                                    [2] = Vector3.new(205.41207885742188, 16.4999942779541, 171.3085174560547),
                                    [3] = Vector3.new(205.36370849609375, 16.4999942779541, 149.45138549804688)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_SteamPunk") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(160.793701171875, 82.4999771118164, 180.54180908203125),
                                    [2] = Vector3.new(218.45816040039062, 82.4999771118164, 179.80137634277344),
                                    [3] = Vector3.new(260.0395202636719, 82.4999771118164, 180.11831665039062),
                                    [4] = Vector3.new(265.80975341796875, 85.4999771118164, 180.09951782226562),
                                    [5] = Vector3.new(272.1552429199219, 88.4999771118164, 180.07870483398438),
                                    [6] = Vector3.new(292.67315673828125, 91.4999771118164, 179.76800537109375),
                                    [7] = Vector3.new(292.5359191894531, 91.4999771118164, 212.19924926757812),
                                    [8] = Vector3.new(292.81573486328125, 94.4999771118164, 216.00205993652344),
                                    [9] = Vector3.new(292.77001953125, 97.4999771118164, 219.78807067871094),
                                    [10] = Vector3.new(292.73516845703125, 100.4999771118164, 222.6680145263672),
                                    [11] = Vector3.new(292.6996154785156, 103.4999771118164, 225.60629272460938),
                                    [12] = Vector3.new(292.6380920410156, 106.4999771118164, 230.70294189453125),
                                    [13] = Vector3.new(339.04364013671875, 106.4999771118164, 231.263916015625),
                                    [14] = Vector3.new(336.16845703125, 106.4999771118164, 204.35227966308594),
                                    [15] = Vector3.new(344.0719299316406, 109.4999771118164, 204.4552001953125),
                                    [16] = Vector3.new(381.0630798339844, 91.4999771118164, 204.93626403808594),
                                    [17] = Vector3.new(381.4077453613281, 91.4999771118164, 178.77200317382812)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 4 or i == 5 or i == 6 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Volatile") then
                                vape:CreateNotification("AutoWin", "Teleporting to lobby, incorrect map!", 4, "warning")
                                task.wait(2.25)
                                lobby()
                            else
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(3)
                            end
                        end

                        local function MapLayoutORANGE()
                            if workspace.Map.Worlds:FindFirstChild("duels_Swamp") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.15)
                                local pos = {
                                    [1] = Vector3.new(354.59832763671875, 22.4999942779541, 141.19931030273438),
                                    [2] = Vector3.new(288.35980224609375, 22.4999942779541, 140.82131958007812),
                                    [3] = Vector3.new(178.31858825683594, 19.4999942779541, 140.5794677734375),
                                    [4] = Vector3.new(178.41314697265625, 19.4999942779541, 97.60221862792969),
                                    [5] = Vector3.new(167.98536682128906, 22.4999942779541, 97.5783920288086)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 5 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Blossom") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(305.7127685546875, 37.4999885559082, 143.80267333984375),
                                    [2] = Vector3.new(294.0784912109375, 37.4999885559082, 166.19984436035156),
                                    [3] = Vector3.new(172.51058959960938, 37.4999885559082, 166.019287109375),
                                    [4] = Vector3.new(172.54029846191406, 37.4999885559082, 142.85401916503906),
                                    [5] = Vector3.new(153.874755859375, 37.4999885559082, 142.830078125)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Darkholm") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(459.380615234375, 70.4999771118164, 185.4072265625),
                                    [2] = Vector3.new(327.0589599609375, 70.4999771118164, 185.53668212890625),
                                    [3] = Vector3.new(321.13018798828125, 73.4999771118164, 185.5518341064453),
                                    [4] = Vector3.new(318.7851867675781, 76.4999771118164, 185.55780029296875),
                                    [5] = Vector3.new(315.27337646484375, 79.4999771118164, 185.56675720214844),
                                    [6] = Vector3.new(173.04278564453125, 70.4999771118164, 185.9304962158203)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 3 or i == 4 or i == 5 or i == 6 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Christmas") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(138.04017639160156, 40.4999885559082, 140.58433532714844),
                                    [2] = Vector3.new(115.14994049072266, 40.4999885559082, 140.646240234375),
                                    [3] = Vector3.new(115.0350341796875, 40.4999885559082, 192.96180725097656),
                                    [4] = Vector3.new(107.36815643310547, 40.4999885559082, 192.94497680664062),
                                    [5] = Vector3.new(107.2378158569336, 40.4999885559082, 252.27471923828125),
                                    [6] = Vector3.new(115.74702453613281, 40.4999885559082, 326.864990234375),
                                    [7] = Vector3.new(145.2953338623047, 40.4999885559082, 326.3784484863281),
                                    [8] = Vector3.new(146.02037048339844, 40.4999885559082, 419.9883117675781),
                                    [9] = Vector3.new(121.12679290771484, 40.4999885559082, 420.07379150390625),
                                    [10] = Vector3.new(120.96660614013672, 40.4999885559082, 431.7377624511719),
                                    [11] = Vector3.new(102.22850036621094, 40.4999885559082, 432.4336242675781)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Crystalmount") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(523.8486328125, 31.4999942779541, 212.9307861328125),
                                    [2] = Vector3.new(404.15264892578125, 28.4999942779541, 212.3941650390625),
                                    [3] = Vector3.new(339.4782409667969, 28.4999942779541, 212.12184143066406),
                                    [4] = Vector3.new(339.5323181152344, 28.4999942779541, 193.957763671875),
                                    [5] = Vector3.new(315.8712158203125, 28.4999942779541, 193.65440368652344),
                                    [6] = Vector3.new(316.3773498535156, 28.4999942779541, 164.9138641357422),
                                    [7] = Vector3.new(268.30816650390625, 28.4999942779541, 165.28636169433594),
                                    [8] = Vector3.new(268.2789306640625, 28.4999942779541, 132.95947265625),
                                    [9] = Vector3.new(248.2838897705078, 28.4999942779541, 132.472412109375),
                                    [10] = Vector3.new(248.64834594726562, 28.4999942779541, 117.51133728027344)
                                }
                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Desert-Shrine") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(408.21319580078125, 43.4999885559082, 147.07444763183594),
                                    [2] = Vector3.new(319.3170166015625, 37.4999885559082, 146.8579864501953),
                                    [3] = Vector3.new(258.67718505859375, 37.4999885559082, 146.6586151123047),
                                    [4] = Vector3.new(251.12399291992188, 40.4999885559082, 146.63404846191406),
                                    [5] = Vector3.new(244.779296875, 43.4999885559082, 146.6132354736328),
                                    [6] = Vector3.new(233.6015625, 46.4999885559082, 146.5764923095703),
                                    [7] = Vector3.new(211.4630889892578, 46.4999885559082, 146.4730224609375),
                                    [8] = Vector3.new(210.13014221191406, 37.4999885559082, 105.5939712524414)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 4 or i == 5 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Canyon") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(409.8771667480469, 22.49999237060547, 116.0271224975586),
                                    [2] = Vector3.new(327.4731750488281, 22.4999942779541, 122.96821594238281),
                                    [3] = Vector3.new(327.6976013183594, 25.4999942779541, 130.06983947753906),
                                    [4] = Vector3.new(326.8793029785156, 25.4999942779541, 165.20481872558594),
                                    [5] = Vector3.new(271.6249084472656, 22.4999942779541, 165.552978515625),
                                    [6] = Vector3.new(271.6521911621094, 22.49999237060547, 169.8865509033203),
                                    [7] = Vector3.new(107.6816177368164, 22.49999237060547, 171.72158813476562),
                                    [8] = Vector3.new(108.24556732177734, 22.49999237060547, 154.60629272460938),
                                    [9] = Vector3.new(108.06343841552734, 25.4999942779541, 141.64547729492188),
                                    [10] = Vector3.new(107.85572814941406, 28.4999942779541, 135.289306640625),
                                    [11] = Vector3.new(106.55116271972656, 31.4999942779541, 122.169677734375)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 3 or i == 9 or i == 10 or i == 11 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Fountain-Peaks") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(197.80709838867188, 55.4999885559082, 380.91845703125),
                                    [2] = Vector3.new(198.08798217773438, 55.4999885559082, 330.4879150390625),
                                    [3] = Vector3.new(198.1407470703125, 55.4999885559082, 319.4066162109375),
                                    [4] = Vector3.new(198.16429138183594, 58.4999885559082, 314.4744873046875),
                                    [5] = Vector3.new(198.19857788085938, 61.4999885559082, 307.2679443359375),
                                    [6] = Vector3.new(198.23214721679688, 64.4999771118164, 300.2276306152344),
                                    [7] = Vector3.new(198.2572784423828, 67.4999771118164, 294.9621276855469),
                                    [8] = Vector3.new(198.0744171142578, 70.4999771118164, 277.3271484375),
                                    [9] = Vector3.new(198.19863891601562, 73.4999771118164, 261.74713134765625),
                                    [10] = Vector3.new(198.17916870117188, 55.4999885559082, 208.74942016601562),
                                    [11] = Vector3.new(198.27981567382812, 55.4999885559082, 154.0118865966797)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 4 or i == 5 or i == 6 or i == 7 or i == 8 or i == 9 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Glacier") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(307.63275146484375, 28.4999942779541, 107.5975570678711),
                                    [2] = Vector3.new(308.0843811035156, 28.4999942779541, 123.1988296508789),
                                    [3] = Vector3.new(302.8423156738281, 31.4999942779541, 123.20875549316406),
                                    [4] = Vector3.new(224.78607177734375, 34.4999885559082, 123.57905578613281),
                                    [5] = Vector3.new(224.7245635986328, 34.4999885559082, 85.76427459716797),
                                    [6] = Vector3.new(166.7411651611328, 28.4999942779541, 85.52276611328125)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 3 or i == 4 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Enchanted-Forest") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(297.86676025390625, 16.4999942779541, 128.88902282714844),
                                    [2] = Vector3.new(248.98641967773438, 16.4999942779541, 128.79608154296875),
                                    [3] = Vector3.new(239.7410430908203, 19.4999942779541, 128.74380493164062),
                                    [4] = Vector3.new(233.1702117919922, 22.4999942779541, 128.7002716064453),
                                    [5] = Vector3.new(229.46270751953125, 25.4999942779541, 128.67581176757812),
                                    [6] = Vector3.new(229.83551025390625, 25.4999942779541, 82.51109313964844)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 3 or i == 4 or i == 5 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Glade") then
                                vape:CreateNotification("AutoWin", "Teleporting to lobby, incorrect map!", 4, "warning")
                                task.wait(2.25)
                                lobby()
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Mystic") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(221.40838623046875, 49.4999885559082, 398.5241394042969),
                                    [2] = Vector3.new(254.4637451171875, 49.4999885559082, 397.211669921875),
                                    [3] = Vector3.new(254.8128204345703, 49.4999885559082, 386.21221923828125),
                                    [4] = Vector3.new(298.4759216308594, 40.4999885559082, 386.5443420410156),
                                    [5] = Vector3.new(298.58660888671875, 40.4999885559082, 370.09735107421875),
                                    [6] = Vector3.new(298.7728271484375, 43.4999885559082, 362.7982177734375),
                                    [7] = Vector3.new(298.9396667480469, 46.4999885559082, 357.5649108886719),
                                    [8] = Vector3.new(298.80377197265625, 49.4999885559082, 349.3194580078125),
                                    [9] = Vector3.new(298.58892822265625, 49.4999885559082, 339.3221740722656),
                                    [10] = Vector3.new(310.25390625, 49.4999885559082, 339.0869140625),
                                    [11] = Vector3.new(310.1837463378906, 49.4999885559082, 262.0010681152344),
                                    [12] = Vector3.new(300.18365478515625, 49.4999885559082, 261.933349609375),
                                    [13] = Vector3.new(300.37420654296875, 40.4999885559082, 223.8512725830078),
                                    [14] = Vector3.new(285.1274719238281, 40.4999885559082, 223.8217315673828),
                                    [15] = Vector3.new(279.4645690917969, 43.4999885559082, 223.8112335205078),
                                    [16] = Vector3.new(272.19329833984375, 46.4999885559082, 223.79776000976562),
                                    [17] = Vector3.new(266.0102844238281, 49.4999885559082, 223.78663635253906),
                                    [18] = Vector3.new(252.8553924560547, 49.4999885559082, 223.3814239501953),
                                    [19] = Vector3.new(252.7893829345703, 49.4999885559082, 211.234130859375),
                                    [20] = Vector3.new(219.3946075439453, 49.4999885559082, 211.3135223388672)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 6 or i == 7 or i == 8 or i == 15 or i == 16 or i == 17 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Nordic-Snowy") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(292.3473815917969, 37.4999885559082, 128.8502960205078),
                                    [2] = Vector3.new(292.2837829589844, 37.4999885559082, 103.8826904296875),
                                    [3] = Vector3.new(246.86444091796875, 34.4999885559082, 103.998046875),
                                    [4] = Vector3.new(246.81077575683594, 34.4999885559082, 82.9254379272461),
                                    [5] = Vector3.new(198.99082946777344, 34.4999885559082, 83.04700469970703),
                                    [6] = Vector3.new(200.015625, 34.4999885559082, 139.6517333984375),
                                    [7] = Vector3.new(173.64576721191406, 34.4999885559082, 139.46446228027344),
                                    [8] = Vector3.new(150.15530395507812, 37.4999885559082, 139.02587890625)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 8 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Nordic") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(292.3473815917969, 37.4999885559082, 128.8502960205078),
                                    [2] = Vector3.new(292.2837829589844, 37.4999885559082, 103.8826904296875),
                                    [3] = Vector3.new(246.86444091796875, 34.4999885559082, 103.998046875),
                                    [4] = Vector3.new(246.81077575683594, 34.4999885559082, 82.9254379272461),
                                    [5] = Vector3.new(198.99082946777344, 34.4999885559082, 83.04700469970703),
                                    [6] = Vector3.new(200.015625, 34.4999885559082, 139.6517333984375),
                                    [7] = Vector3.new(173.64576721191406, 34.4999885559082, 139.46446228027344),
                                    [8] = Vector3.new(150.15530395507812, 37.4999885559082, 139.02587890625)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 8 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Pinewood") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(129.27752685546875, 28.4999942779541, 241.45860290527344),
                                    [2] = Vector3.new(79.45954132080078, 28.49999237060547, 240.6741943359375),
                                    [3] = Vector3.new(80.80793762207031, 28.49999237060547, 155.99095153808594),
                                    [4] = Vector3.new(91.66584777832031, 28.49999237060547, 156.12608337402344),
                                    [5] = Vector3.new(91.90682983398438, 28.49999237060547, 136.84848022460938),
                                    [6] = Vector3.new(129.66644287109375, 28.49999237060547, 137.31893920898438)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Seasonal") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(135.16567993164062, 22.4999942779541, 409.7474365234375),
                                    [2] = Vector3.new(135.17654418945312, 25.4999942779541, 380.8885803222656),
                                    [3] = Vector3.new(124.0099105834961, 25.49999237060547, 380.8028869628906),
                                    [4] = Vector3.new(124.02178955078125, 25.49999237060547, 280.3576354980469),
                                    [5] = Vector3.new(123.74276733398438, 25.49999237060547, 262.22003173828125),
                                    [6] = Vector3.new(123.6146469116211, 28.4999942779541, 253.8889617919922),
                                    [7] = Vector3.new(123.49169921875, 31.4999942779541, 245.8935546875),
                                    [8] = Vector3.new(123.3890380859375, 25.4999942779541, 169.56488037109375),
                                    [9] = Vector3.new(140.38137817382812, 25.49999237060547, 169.5316925048828)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if i == 2 or i == 6 or i == 7 then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Snowman-Park") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(140.38137817382812, 25.49999237060547, 169.5316925048828),
                                    [2] = Vector3.new(244.02467346191406, 16.4999942779541, 193.6885223388672),
                                    [3] = Vector3.new(164.97314453125, 16.49999237060547, 194.03672790527344),
                                    [4] = Vector3.new(164.86520385742188, 16.49999237060547, 169.71209716796875)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_SteamPunk") then
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(2.33)
                                local pos = {
                                    [1] = Vector3.new(459.31365966796875, 82.4999771118164, 180.3105010986328),
                                    [2] = Vector3.new(406.04095458984375, 82.4999771118164, 179.7035369873047),
                                    [3] = Vector3.new(399.0287780761719, 85.4999771118164, 179.84088134765625),
                                    [4] = Vector3.new(393.3252258300781, 88.4999771118164, 179.9452667236328),
                                    [5] = Vector3.new(370.205322265625, 91.4999771118164, 179.96041870117188),
                                    [6] = Vector3.new(371.1557312011719, 91.4999771118164, 148.01693725585938),
                                    [7] = Vector3.new(371.19158935546875, 94.4999771118164, 143.04385375976562),
                                    [8] = Vector3.new(371.111572265625, 97.4999771118164, 140.0428924560547),
                                    [9] = Vector3.new(371.05657958984375, 100.4999771118164, 137.93524169921875),
                                    [10] = Vector3.new(370.9500732421875, 103.4999771118164, 134.1337127685547),
                                    [11] = Vector3.new(370.477294921875, 106.4999771118164, 124.73361206054688),
                                    [12] = Vector3.new(335.9317321777344, 106.4999771118164, 124.79263305664062),
                                    [13] = Vector3.new(335.83599853515625, 106.4999771118164, 154.04205322265625),
                                    [14] = Vector3.new(324.33575439453125, 106.4999771118164, 154.00502014160156),
                                    [15] = Vector3.new(320.086669921875, 109.4999771118164, 153.9910888671875),
                                    [16] = Vector3.new(287.7663269042969, 91.4999771118164, 153.884765625),
                                    [17] = Vector3.new(287.6502380371094, 91.4999771118164, 181.8335723876953)
                                }

                                for i, waypoint in ipairs(pos) do
                                    vape:CreateNotification("AutoWin | Specific", "Fixing Position [" .. i .. "] !", 8)
                                    lplr.Character.Humanoid:MoveTo(waypoint)
                                    if
                                        i == 3 or i == 4 or i == 5 or i == 7 or i == 8 or i == 9 or i == 10 or i == 11 or
                                            i == 15
                                     then
                                        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    lplr.Character.Humanoid.MoveToFinished:Wait()
                                    task.wait(0.5)
                                end
                            elseif workspace.Map.Worlds:FindFirstChild("duels_Volatile") then
                                vape:CreateNotification("AutoWin", "Teleporting to lobby, incorrect map!", 4, "warning")
                                task.wait(2.25)
                                lobby()
                            else
                                vape:CreateNotification("AutoWin", "Moving back to Iron Gen!", 8)
                                lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                                task.wait(3)
                            end
                        end

                        if CurrentGen then
                            vape:CreateNotification("AutoWin", "Moving to Iron Gen!", 8)
                            lplr.Character.Humanoid:MoveTo(CurrentGen.Value.Position)
                            task.wait((T + 3.33))
                            vape:CreateNotification("AutoWin", "Moving to Shop!", 8)
                            lplr.Character.Humanoid:MoveTo(CurrentItemShop.Position)
                            Speed()
                            task.wait(1.5)
                            vape:CreateNotification("AutoWin", "Purchasing Wool!", 8)
                            task.wait(3)
                            for i = 6, 0, -1 do
                                PurchaseWool()
                                task.wait(0.05)
                            end
                            if oppTeamName == "Orange" then
                                MapLayoutBLUE()
                            else
                                MapLayoutORANGE()
                            end
                            vape:CreateNotification("AutoWin", "Moving to " .. oppTeamName .. "'s Bed!", 8)
                            fly()
                            climbwalls()
                            task.spawn(function()
                                lplr.Character.Humanoid:MoveTo(OppositeTeamBedPos)
                            end)
                            
                            lplr.Character.Humanoid.MoveToFinished:Connect(function()
								lplr.Character.Humanoid:MoveTo(OppositeTeamBedPos)
							end)
                        end
	end

	local function Skywars()
        local T = 10
        if #playersService:GetChildren() > 1 then
            vape:CreateNotification("AutoWin", "Teleporting to Empty Game!", 6)
            task.wait((6 / 3.335))
            local data = TeleportService:GetLocalPlayerTeleportData()
            AutoWin:Clean(TeleportService:Teleport(game.PlaceId, lplr, data))
        end
		task.wait((T + 3.33))
		local Delays = {}
		local function lootChest(chest)
            vape:CreateNotification("AutoWin", "Grabbing Items in chest", 8)
			chest = chest and chest.Value or nil
			local chestitems = chest and chest:GetChildren() or {}
			if #chestitems > 1 and (Delays[chest] or 0) < tick() then
				Delays[chest] = tick() + 0.2
				bedwars.Client:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(chest)
		
				for _, v in chestitems do
					if v:IsA('Accessory') then
						task.spawn(function()
							pcall(function()
								bedwars.Client:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest, v)
							end)
						end)
					end
				end
		
				bedwars.Client:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(nil)
			end
		end
	
		local localPosition = entitylib.character.RootPart.Position
		local chests = collection('chest', AutoWin)
		repeat task.wait(0.1) until store.queueType ~= 'bedwars_test'
		if not store.queueType:find('skywars') then return end
		for _, v in chests do
			if (localPosition - v.Position).Magnitude <= 30 then
				vape:CreateNotification("AutoWin", "Moving to chest",2)
				entitylib.character.Humanoid:MoveTo(v.Position)
				lootChest(v:FindFirstChild('ChestFolderValue'))
			end
		end
		task.wait(4.85)
        vape:CreateNotification("AutoWin", "Resetting..", 3)
		entitylib.character.Humanoid.Health = (lplr.Character:GetAttribute("MaxHealth") - lplr.Character:GetAttribute("Health"))
		vape:CreateNotification("AutoWin", "Requeueing.", 1.85)
		AutoWin:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
				if deathTable.finalKill and deathTable.entityInstance == lplr.Character and isEveryoneDead() and store.matchState ~= 2 then
					bedwars.QueueController:joinQueue(store.queueType)
				end
		end))
		AutoWin:Clean(vapeEvents.MatchEndEvent.Event:Connect(function(...)
			bedwars.QueueController:joinQueue(store.queueType)
		end))
	end


    AutoWin = vape.Categories.AltFarm:CreateModule({
        Name = "AutoWin",
        Tooltip = "makes you go into a empty game and win for you!",
        Function = function(callback)
            if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium"then
                vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
                return
            end
            if not callback then
           	 	vape:CreateNotification("AutoWin", "Disabled next game!", 4.5, "warning")
                return
            end
			local GameMode = readfile('ReVape/profiles/autowin.txt')
			if GameMode == "duels" then
				Duels()
			elseif GameMode == "skywars" then
				Skywars()
			else
           	 	vape:CreateNotification("AutoWin", "File does not exist? switching to use duels method!", 4.5, "warning")
                Duels()
			end
    	end
    })
end)

run(function()
	local ZephyrExploit
	local zepcontroller = require(lplr.PlayerScripts.TS.controllers.games.bedwars.kit.kits['wind-walker']['wind-walker-controller'])
	local old, old2
	ZephyrExploit = vape.Categories.Exploits:CreateModule({
		Name = 'ZephyrExploit',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				old = zepcontroller.updateSpeed
				old2 = zepcontroller.updateJump
				zepcontroller.updateSpeed = function(v1,v2) 
					v1 = {currentSpeedModifier = nil}
					v2 = 5
					return old(v1,v2)
				end
				zepcontroller.updateJump = function(v1,v2) 
					v1 = {doubleJumpActive = nil}
					v2 = 5
					return old2(v1,v2)
				end
			else
				zepcontroller.updateSpeed = old
				zepcontroller.updateJump = old2
				old = nil
				old2 = nil
			end
		end,
		Tooltip = 'Anti-Cheat Bypasser!'
	})

end)

run(function()
    local NewAutoWin
	local Methods 
	local hiding = true
	local gui
	local beds,currentbedpos,Dashes = {}, nil, {Value  =2}
	local function create(Name,values)
		local obj = Instance.new(Name)
		for i, v in values do
			obj[i] = v
		end
		return obj
	end
	local function Reset()
		NewAutoWin:Clean(TeleportService:Teleport(game.PlaceId, lplr, TeleportService:GetLocalPlayerTeleportData()))
	end
	local function AllbedPOS()
		if workspace:FindFirstChild("MapCFrames") then
			for _, obj in ipairs(workspace:FindFirstChild("MapCFrames"):GetChildren()) do
				if string.match(obj.Name, "_bed$") then
					table.insert(beds, obj.Value.Position)
				end
			end
		end
	end
	local function UpdateCurrentBedPOS()
		if workspace:FindFirstChild("MapCFrames") then
			local currentTeam =  lplr.Character:GetAttribute("Team")
			if workspace:FindFirstChild("MapCFrames") then
				local CFRameName = tostring(currentTeam).."_bed"
				currentbedpos = workspace:FindFirstChild("MapCFrames"):FindFirstChild(CFRameName).Value.Position
			end
		end
	end
	local function closestBed(origin)
		local closest, dist
		for _, pos in ipairs(beds) do
			if pos ~= currentbedpos then
				local d = (pos - origin).Magnitude
				if not dist or d < dist then
					dist, closest = d, pos
				end
			end
		end
		return closest
	end
	local function tweenToBED(pos)
		if entitylib.isAlive then
			local oldpos = pos
			pos = pos + Vector3.new(0, 5, 0)
			local currentPosition = entitylib.character.RootPart.Position
			if (pos - currentPosition).Magnitude > 0.5 then
				if lplr.Character then
					lplr:SetAttribute('LastTeleported', 0)
				end
				local info = TweenInfo.new(0.72,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
				local tween = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.new(pos)})
				local tween2 = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.new(pos)})
				task.spawn(function() tween:Play() end)
				task.spawn(function()
					if Dashes.Value == 1 then
						task.wait(0.36)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
					elseif Dashes.Value == 2 then
						task.wait(0.36)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
						task.wait(0.54)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
					else
						task.wait(0.54)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
							end				
						end
				end)
				task.spawn(function()
					tween.Completed:Wait()
					lplr:SetAttribute('LastTeleported', os.time())
				end)
				lplr:SetAttribute('LastTeleported', os.time())
				task.wait(0.25)
				if lplr.Character then
					task.wait(0.1235)
					lplr:SetAttribute('LastTeleported', os.time())
				end
				task.wait(1.45)
				vape:CreateNotification("AutoWin", "Fixing position!", 1)
				task.spawn(function() tween2:Play() end)
				task.spawn(function()
					tween.Completed:Wait()
					lplr:SetAttribute('LastTeleported', os.time())
				end)
				lplr:SetAttribute('LastTeleported', os.time())
				task.wait(0.25)
				if lplr.Character then
					task.wait(0.1235)
					lplr:SetAttribute('LastTeleported', os.time())
				end
				task.wait(0.85)
				vape:CreateNotification("AutoWin",'nuking bed...',2)
				if not Breaker.Enabled then
					Breaker:Toggle(true)
					
				end
				NewAutoWin:Clean(lplr.PlayerGui.ChildAdded:Connect(function(obj)
					if obj.Name == "WinningTeam" then
						lplr:Kick("Don't disconnect, this will auto teleport you!")
						vape:CreateNotification("AutoWin",'Match ended you won... Teleporting you to a empty game.',3)
						task.wait(1.5)
						Reset()
					end
				end))
			end
		end
	end
	local function tweenToBED2(pos,msg,oppositeTeam)
		if entitylib.isAlive then
			local oldpos = pos
			pos = pos + Vector3.new(0, 5, 0)
			local currentPosition = entitylib.character.RootPart.Position
			if (pos - currentPosition).Magnitude > 0.5 then
				if lplr.Character then
					lplr:SetAttribute('LastTeleported', 0)
				end
				local info = TweenInfo.new(0.72,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
				local tween = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.new(pos)})
				local tween2 = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.new(pos)})
				task.spawn(function() tween:Play() end)
				task.spawn(function()
					if Dashes.Value == 1 then
						msg.Text = "Dashing to bypass Anti-Cheat. (0.36s)"
						task.wait(0.36)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
					elseif Dashes.Value == 2 then
						msg.Text = "Dashing to bypass Anti-Cheat. (0.36s)"
						task.wait(0.36)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
						msg.Text = "Dashing to bypass Anti-Cheat. (0.54s)"
						task.wait(0.54)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
					else
						msg.Text = "Dashing to bypass Anti-Cheat. (0.54s)"
						task.wait(0.54)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
							end				
						end
				end)
				task.spawn(function()
					tween.Completed:Wait()
					lplr:SetAttribute('LastTeleported', os.time())
				end)
				lplr:SetAttribute('LastTeleported', os.time())
				task.wait(0.25)
				if lplr.Character then
					task.wait(0.1235)
					lplr:SetAttribute('LastTeleported', os.time())
				end
				msg.Text = `Fixing current positon {bedwars.BlockController:getBlockPosition(entitylib.character.RootPart.Position)} to {pos}. (1.45s)`
				task.wait(1.45)
				task.spawn(function() tween2:Play() end)
				task.spawn(function()
					tween.Completed:Wait()
					lplr:SetAttribute('LastTeleported', os.time())
				end)
				lplr:SetAttribute('LastTeleported', os.time())
				task.wait(0.25)
				if lplr.Character then
					task.wait(0.1235)
					lplr:SetAttribute('LastTeleported', os.time())
				end
				msg.Text = `Nuking {oppositeTeam} bed.. (0.85s)`
				task.wait(0.85)
				if not Breaker.Enabled then
					Breaker:Toggle(true)
				end
				NewAutoWin:Clean(lplr.PlayerGui.ChildAdded:Connect(function(obj)
					msg.Text = `Your current Player Level is {lplr:GetAttribute("PlayerLevel")}. (0.85s)`
					task.wait(0.85)
					msg.Text = 'Match ended. ReTeleporting to another Empty Game... (1.5s)'
					task.wait(0.5)
					if obj.Name == "WinningTeam" then
						lplr:Kick("Don't disconnect, this will auto teleport you!")
						task.wait(1)
						Reset()
					end
				end))
			end
		end
	end
	local function tweenToBED3(pos,msg,oppositeTeam,Percent)
		if entitylib.isAlive then
			local oldpos = pos
			pos = pos + Vector3.new(0, 5, 0)
			local currentPosition = entitylib.character.RootPart.Position
			if (pos - currentPosition).Magnitude > 0.5 then
				if lplr.Character then
					lplr:SetAttribute('LastTeleported', 0)
				end
				local info = TweenInfo.new(0.72,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
				local tween = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.new(pos)})
				local tween2 = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.new(pos)})
				task.spawn(function() tween:Play() end)
				task.spawn(function()
					if Dashes.Value == 1 then
						Percent:SetAttribute("Percent",62)
						msg.Text = "Dashing to bypass Anti-Cheat.. (1)"
						task.wait(0.36)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
					elseif Dashes.Value == 2 then
						Percent:SetAttribute("Percent",62)
						msg.Text = "Dashing to bypass Anti-Cheat.. (1)"
						task.wait(0.36)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
						Percent:SetAttribute("Percent",72)
						msg.Text = "Dashing to bypass Anti-Cheat.. (2)"
						task.wait(0.54)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
						end
					else
						Percent:SetAttribute("Percent",72)
						msg.Text = "Dashing to bypass Anti-Cheat.. (1)"
						task.wait(0.54)
						if bedwars.AbilityController:canUseAbility("ELECTRIC_DASH") then
							bedwars.AbilityController:useAbility('ELECTRIC_DASH')
							end				
						end
				end)
				task.spawn(function()
					tween.Completed:Wait()
					lplr:SetAttribute('LastTeleported', os.time())
				end)
				lplr:SetAttribute('LastTeleported', os.time())
				task.wait(0.25)
				if lplr.Character then
					task.wait(0.1235)
					lplr:SetAttribute('LastTeleported', os.time())
				end
				Percent:SetAttribute("Percent",83)
				msg.Text = `Fixing current positon {bedwars.BlockController:getBlockPosition(entitylib.character.RootPart.Position)} to {pos}.`
				task.wait(1.45)
				task.spawn(function() tween2:Play() end)
				task.spawn(function()
					tween.Completed:Wait()
					lplr:SetAttribute('LastTeleported', os.time())
				end)
				lplr:SetAttribute('LastTeleported', os.time())
				task.wait(0.25)
				if lplr.Character then
					task.wait(0.1235)
					lplr:SetAttribute('LastTeleported', os.time())
				end
				Percent:SetAttribute("Percent",99)
				msg.Text = `Nuking {oppositeTeam} bed.. `
				task.wait(0.85)
				if not Breaker.Enabled then
					Breaker:Toggle(true)
				end
				NewAutoWin:Clean(lplr.PlayerGui.NotificationApp.ChildAdded:Connect(function(obj)
					obj:Destroy()
				end))
				NewAutoWin:Clean(lplr.PlayerGui.ChildAdded:Connect(function(obj)
					
					Percent:SetAttribute("Percent",100)
					msg.Text = 'Match ended. ReTeleporting to another Empty Game...'
					task.wait(0.5)
					if obj.Name == "WinningTeam" then
						lplr:Kick("Don't disconnect, this will auto teleport you!")
						task.wait(1)
						Reset()
					end
				end))
			end
		end
	end

	local function MethodOne()
		vape:CreateNotification("AutoWin",'finding all bed positions!',1.85)
		AllbedPOS()
		task.wait(0.958)
		vape:CreateNotification("AutoWin",'Founded my own bed position!',3.85)
		UpdateCurrentBedPOS()
		if currentbedpos then
			task.wait(2.125)
			vape:CreateNotification("AutoWin",'Finding the other team bed!',3.85)
			task.wait(2)
			bedpos = closestBed(entitylib.character.RootPart.Position)
			if bedpos then
				local bp = tostring(bedpos)
				if lplr.Team.Name == "Blue" then
						vape:CreateNotification("AutoWin",`Founded Orange's bed at {bp}`,4.85)
						tweenToBED(bedpos)
					else
						vape:CreateNotification("AutoWin",`Founded Blue's bed at {bp}`,4.85)
						tweenToBED(bedpos)
					end
				else
				if lplr.Team.Name == "Blue" then
					vape:CreateNotification("AutoWin",'Couldnt find Orange\'s bed position? ReTeleporting...','warning',10.85)
					lplr:Kick("Don't disconnect, this will auto teleport you!")
					task.wait(0.5)
					Reset()
				else
					vape:CreateNotification("AutoWin",'Couldnt find Blue\'s bed position? ReTeleporting...','warning',10.85)
					lplr:Kick("Don't disconnect, this will auto teleport you!")
					task.wait(0.5)
					Reset()
				end
			end
		else
			vape:CreateNotification("AutoWin",'Couldnt find my bed position? ReTeleporting...','warning',10.85)
			lplr:Kick("Don't disconnect, this will auto teleport you!")
			task.wait(0.5)
			Reset()
		end
	end
	
	local function MethodTwo(TooltipText)
		TooltipText.Text = 'Finding all current beds positions near me! (0.235s)'
		AllbedPOS()
		task.wait(0.2345)
		TooltipText.Text = 'Founded my team\'s bed position! (0.35s)'
		UpdateCurrentBedPOS()
		if currentbedpos then
			task.wait(0.35)
			TooltipText.Text = 'Finding other team\'s bed! (0.5s)'
			task.wait(.5)
			bedpos = closestBed(entitylib.character.RootPart.Position)
			if bedpos then
				local bp = tostring(bedpos)
				if lplr.Team.Name == "Blue" then
						TooltipText.Text = `Founded Orange's bed at {bp} (2s)`
						tweenToBED2(bedpos,TooltipText,'Orange')
					else
						TooltipText.Text = `Founded Blue's bed at {bp} (2s)`
						tweenToBED2(bedpos,TooltipText,'Blue')
					end
				else
				if lplr.Team.Name == "Blue" then
					TooltipText.Text = 'Couldn\'t find my Orange\'s bed position? ReTeleporting... (0.5s)'
					lplr:Kick("Don't disconnect, this will auto teleport you!")
					task.wait(0.5)
					Reset()
				else
					TooltipText.Text = 'Couldn\'t find my Blue\'s bed position? ReTeleporting... (0.5s)'
					lplr:Kick("Don't disconnect, this will auto teleport you!")
					task.wait(0.5)
					Reset()
				end
			end
		else
			TooltipText.Text = 'Couldn\'t find my bed position? ReTeleporting... (0.5s)'
			lplr:Kick("Don't disconnect, this will auto teleport you!")
			task.wait(0.5)
			Reset()
		end
		task.spawn(function()
			NewAutoWin:Clean(playersService.PlayerAdded:Connect(function(playerToBlock)
				local NewFoundedPlayersName = playerToBlock.Name
				if playersService:FindFirstChild(NewFoundedPlayersName) then

					local RobloxGui = coreGui:WaitForChild("RobloxGui")
					local CoreGuiModules = RobloxGui:WaitForChild("Modules")
					local PlayerDropDownModule = require(CoreGuiModules:WaitForChild("PlayerDropDown"))
					PlayerDropDownModule:InitBlockListAsync()
					local BlockingUtility = PlayerDropDownModule:CreateBlockingUtility()

					
					if BlockingUtility:IsPlayerBlockedByUserId(playerToBlock.UserId) then
						return
					end
					local successfullyBlocked = BlockingUtility:BlockPlayerAsync(playerToBlock)
					if successfullyBlocked then
						TooltipText.Text = string.format("Successfully blocked %s! lobbying... (1s)",NewFoundedPlayersName)
						writefile('ReVape/profiles/BlockedUsers.txt', isfile('ReVape/profiles/BlockedUsers.txt') and readfile('ReVape/profiles/BlockedUsers.txt') or "" ~= "" and (isfile('ReVape/profiles/BlockedUsers.txt') and readfile('ReVape/profiles/BlockedUsers.txt') or "" .. "\n" .. NewFoundedPlayersName) or NewFoundedPlayersName)
						task.wait(1.015)
					end
					lobby()
				end
			end))
		end)
	end
	
	local function MethodThree(TooltipText,Percent)
		Percent:SetAttribute("Percent",5)
		TooltipText.Text = 'Finding all current beds positions near me...'
		task.wait(0.015825)
		AllbedPOS()
		Percent:SetAttribute("Percent",15)
		task.wait(0.1345)
		Percent:SetAttribute("Percent",35)
		TooltipText.Text = 'Founded my team\'s bed position...'
		UpdateCurrentBedPOS()
		if currentbedpos then
			task.wait(0.15)
			Percent:SetAttribute("Percent",48)
			TooltipText.Text = 'Finding other team\'s bed...'
			task.wait(.485)
			bedpos = closestBed(entitylib.character.RootPart.Position)
			if bedpos then
				Percent:SetAttribute("Percent",54)
				local bp = tostring(bedpos)
				if lplr.Team.Name == "Blue" then
						TooltipText.Text = `Founded Orange's bed at {bp}`
						tweenToBED3(bedpos,TooltipText,'Orange',Percent)
					else
						TooltipText.Text = `Founded Blue's bed at {bp}`
						tweenToBED3(bedpos,TooltipText,'Blue',Percent)
					end
				else
				if lplr.Team.Name == "Blue" then
					TooltipText.Text = 'Couldn\'t find my Orange\'s bed position? ReTeleporting...'
					lplr:Kick("Don't disconnect, this will auto teleport you!")
					task.wait(0.5)
					Reset()
				else
					TooltipText.Text = 'Couldn\'t find my Blue\'s bed position? ReTeleporting...'
					lplr:Kick("Don't disconnect, this will auto teleport you!")
					task.wait(0.5)
					Reset()
				end
			end
		else
			TooltipText.Text = 'Couldn\'t find my bed position? ReTeleporting...'
			lplr:Kick("Don't disconnect, this will auto teleport you!")
			task.wait(0.5)
			Reset()
		end
		task.spawn(function()
			NewAutoWin:Clean(playersService.PlayerAdded:Connect(function(playerToBlock)
				local NewFoundedPlayersName = playerToBlock.Name
				if playersService:FindFirstChild(NewFoundedPlayersName) then

					local RobloxGui = coreGui:WaitForChild("RobloxGui")
					local CoreGuiModules = RobloxGui:WaitForChild("Modules")
					local PlayerDropDownModule = require(CoreGuiModules:WaitForChild("PlayerDropDown"))
					PlayerDropDownModule:InitBlockListAsync()
					local BlockingUtility = PlayerDropDownModule:CreateBlockingUtility()

					
					if BlockingUtility:IsPlayerBlockedByUserId(playerToBlock.UserId) then
						return
					end
					local successfullyBlocked = BlockingUtility:BlockPlayerAsync(playerToBlock)
					if successfullyBlocked then
						TooltipText.Text = string.format("Successfully blocked %s! lobbying... ",NewFoundedPlayersName)
						task.wait(0.125)
					end
					lobby()
				end
			end))
		end)
	end
	
	if role ~= "owner" and  role ~= "coowner" and user ~= "generalcyan" and user ~= "kev" and user ~= "yorender" and user ~= 'synioxzz' and user ~= 'black'    then
		return 
	end
    NewAutoWin = vape.Categories.AltFarm:CreateModule({
		Name = "NewElektraAutoWin",
		Tooltip = 'must have elektra to use this',
		Function = function(callback) 
			if callback then
				if Methods.Value == "Method 1" then
					local ScreenGui = create("ScreenGui",{Parent = lplr.PlayerGui,ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder =999,Name='AutowinUI'})
					local MainFrame = create("Frame",{Visible=gui.Enabled,Name='AutowinFrame',Parent=ScreenGui,BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.05,Size=UDim2.fromScale(1,1)})
					local SecondaryFrame = create("Frame",{Name='SecondaryFrame',Parent=MainFrame,BackgroundColor3=Color3.fromRGB(28,25,27),BackgroundTransparency=0.1,Size=UDim2.fromScale(1,1)})
					local ShowUserBtn = create("TextButton",{Name='UsernameButton',Parent=SecondaryFrame,Position=UDim2.fromScale(0.393,0.788),Size=UDim2.fromOffset(399,97),FontFace=Font.new('rbxasset://fonts/families/Arimo.json',Enum.FontWeight.SemiBold),Text='SHOW USERNAME',TextColor3=Color3.fromRGB(65,65,65),TextSize=32,TextTransparency=0.2,BackgroundColor3=Color3.fromHSV(vape.GUIColor.Hue,vape.GUIColor.Sat,vape.GUIColor.Value)})
					create("UICorner",{CornerRadius=UDim.new(0,6),Parent=ShowUserBtn})
					create("UIStroke",{ApplyStrokeMode='Border',Color=Color3.new(0,0,0),Thickness=5,Parent=ShowUserBtn})
					create("UIStroke",{ApplyStrokeMode='Contextual',Color=Color3.new(0,0,0),Thickness=1,Parent=ShowUserBtn})
					local MainIcon = create("ImageLabel",{Parent=SecondaryFrame,Name='AltFarmIcon',BackgroundTransparency=1,Image=getcustomasset('ReVape/assets/new/af.png'),ImageTransparency=0.63,ImageColor3=Color3.new(0,0,0),Position=UDim2.fromScale(0.388,0.193),Size=UDim2.fromOffset(346,341)})
					local SecondaryIcon = create("ImageLabel",{Parent=MainIcon,Name='MainIconAltFarm',BackgroundTransparency=1,Image=getcustomasset('ReVape/assets/new/af.png'),ImageTransparency=0.24,Position=UDim2.fromScale(0.069,0.053),Size=UDim2.fromOffset(297,305)})
					local Levels = create("TextButton",{Name='LevelText',Parent=SecondaryFrame,BackgroundTransparency=1,Position=UDim2.fromScale(0.435,0.596),Size=UDim2.fromOffset(200,50),FontFace=Font.new('rbxasset://fonts/families/Arimo.json',Enum.FontWeight.SemiBold,Enum.FontStyle.Italic),Text="Level: 0",TextSize=32})
					create("UIStroke",{ApplyStrokeMode='Contextual',Color=Color3.fromHSV(vape.GUIColor.Hue,vape.GUIColor.Sat,vape.GUIColor.Value),Thickness=2.1,Transparency=0.22,Parent=Levels})
					--local Wins = create("TextButton",{Name='WinsText',Parent=SecondaryFrame,BackgroundTransparency=1,Position=UDim2.fromScale(0.435,0.684),Size=UDim2.fromOffset(200,50),FontFace=Font.new('rbxasset://fonts/families/Arimo.json',Enum.FontWeight.SemiBold,Enum.FontStyle.Italic),Text="Wins: 0",TextSize=32})
					--create("UIStroke",{ApplyStrokeMode='Contextual',Color=Color3.fromHSV(vape.GUIColor.Hue,vape.GUIColor.Sat,vape.GUIColor.Value),Thickness=2.1,Transparency=0.22,Parent=Wins})
					local Username = create("TextButton",{Name='WinsText',Parent=SecondaryFrame,BackgroundTransparency=1,Position=UDim2.fromScale(0.365,0),Size=UDim2.fromOffset(425,89),FontFace=Font.new('rbxasset://fonts/families/Arimo.json',Enum.FontWeight.SemiBold,Enum.FontStyle.Italic),Text="Username: [HIDDEN]",TextSize=32})
					create("UIStroke",{ApplyStrokeMode='Contextual',Color=Color3.fromHSV(vape.GUIColor.Hue,vape.GUIColor.Sat,vape.GUIColor.Value),Thickness=2.1,Transparency=0.22,Parent=Username})
					task.spawn(function()
						repeat
							Levels.Text = "Level: "..tostring(lplr:GetAttribute("PlayerLevel")) or "0"
							task.wait(0.1)
						until not NewAutoWin.Enabled
					end)

					ShowUserBtn.Activated:Connect(function()
						if hiding then
							Username.Text = "Username: ["..lplr.Name.."]"
							MainIcon.Image = playersService:GetUserThumbnailAsync(lplr.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
							SecondaryIcon.Image = playersService:GetUserThumbnailAsync(lplr.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
						else
							Username.Text = "Username: [HIDDEN]"
							MainIcon.Image =getcustomasset('ReVape/assets/new/af.png')
							SecondaryIcon.Image = getcustomasset('ReVape/assets/new/af.png')
						end
						hiding = not hiding
					end)
					
					vape:CreateNotification("AutoWin",'checking if in empty game...',3)
					task.wait((3 / 1.85))
					if #playersService:GetChildren() ~= 1 then
						lplr:Kick("Don't disconnect, this will auto teleport you!")
						vape:CreateNotification("AutoWin",'players found! teleporting to a empty game!',6)
						task.wait((6 / 3.335))
						Reset()
					else
						repeat task.wait(0.1) until store.equippedKit ~= '' and store.matchState ~= 0 or (not NewAutoWin.Enabled)
						MethodOne()
					end
				elseif Methods.Value == "Method 2" then
					local AutoFarmUI = create("ScreenGui",{Name='AutowinUI',Parent=lplr.PlayerGui,IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999})
					local AutoFarmFrame = create("Frame",{Name='AutoFarmFrame',BackgroundColor3=Color3.fromRGB(15,15,15),Size=UDim2.fromScale(1,1),Parent=AutoFarmUI})
					local Title = create("TextLabel",{TextColor3=Color3.fromHSV(vape.GUIColor.Hue,vape.GUIColor.Sat,vape.GUIColor.Value),Parent=AutoFarmFrame,BackgroundTransparency=1,Position=UDim2.fromScale(0.396,0.264),Size=UDim2.fromOffset(322,125),Text='AUTOWIN',FontFace=Font.new('rbxasset://fonts/families/Arimo.json',Enum.FontWeight.SemiBold,Enum.FontStyle.Italic),TextSize=32,TextScaled=true})
					local TooltipText = create("TextLabel",{TextColor3=Color3.fromHSV(vape.GUIColor.Hue,vape.GUIColor.Sat,vape.GUIColor.Value),Parent=AutoFarmFrame,BackgroundTransparency=1,Position=UDim2.fromScale(0.435,0.596),Size=UDim2.fromOffset(200,50),Text='...',FontFace=Font.new('rbxasset://fonts/families/Arimo.json',Enum.FontWeight.Medium,Enum.FontStyle.Italic),TextSize=48})
					create("UIStroke",{Color=Color3.fromRGB(56,56,56),Thickness=2.1,Transparency=0.22,Parent=Title})
					create("UIStroke",{Color=Color3.fromRGB(56,56,56),Thickness=2.1,Transparency=0.22,Parent=TooltipText})
					local num = math.floor((3 / 1.85))
					TooltipText.Text = `checking if in empty game... ({num}s)`
					task.wait((3 / 1.85))
					if #playersService:GetChildren() ~= 1 then
						num = math.floor((6 / 3.335))
						TooltipText.Text = `player's found. Teleporting to a Empty Game.. ({num}s)`
						lplr:Kick("Don't disconnect, this will auto teleport you!")
						task.wait((6 / 3.335))
						Reset()
					else
						repeat task.wait(0.1) until store.equippedKit ~= '' and store.matchState ~= 0 or (not NewAutoWin.Enabled)
						MethodTwo(TooltipText)
					end
					
				elseif Methods.Value == 'Method 3' then
					local tips = {
						"you can always be afk while you farm...",
						"this is a tip lol...",
						'you can always sleep while afk farming...',
						'you have 2 other methods for auto farm...',
						'this is the most undetected farming and best method out here...',
						'note to bedwars dev/mods FUCK YOU...'
					}
					local lastTip
					local prefix = "tip: "
					local typeSpeed = 0.085
					local eraseSpeed = 0.04
					local waitBetween = 2
					local hidden = true
					local function AccAgeHook(txt)
						task.spawn(function()
							local daysTotal = math.max(lplr.AccountAge, 1)

							local YEARS = 365
							local MONTHS = 30
							local HOURS_IN_DAY = 24

							local years = math.floor(daysTotal / YEARS)
							local remainingDays = daysTotal % YEARS

							local months = math.floor(remainingDays / MONTHS)
							local days = remainingDays % MONTHS

							local hours = daysTotal == 1 and 1 or 0
							local minutes = daysTotal == 1 and 0 or 0

							local parts = {}

							if years > 0 then
								table.insert(parts, years .. (years == 1 and " year" or " years"))
							end

							if months > 0 then
								table.insert(parts, months .. (months == 1 and " month" or " months"))
							end

							if days > 0 then
								table.insert(parts, days .. (days == 1 and " day" or " days"))
							end

							if daysTotal <= 1 then
								table.insert(parts, hours .. (hours == 1 and " hour" or " hours"))
								table.insert(parts, minutes .. " minutes")
							end

							local result = table.concat(parts, ", ")
							txt.Text = 'Account age: '..result
						end)
					end

					local function LevelCheckHook(txt)
						task.spawn(function()
							while NewAutoWin.Enabled do
								txt.Text = 'level: '..tostring(lplr:GetAttribute("PlayerLevel")) or "0"
								task.wait(0.01)
							end
						end)
					end
					
					local function LogoBGBGTween(image)
						local MAX = 0.92
						local MIN = 0.84

						local tweenInfo = TweenInfo.new(
							0.96,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.InOut
						)


						local growTween = tweenService:Create(image, tweenInfo, {
							ImageTransparency = MAX
						})

						local shrinkTween = tweenService:Create(image, tweenInfo, {
							ImageTransparency = MIN
						})

						task.spawn(function()
							while NewAutoWin.Enabled do
								growTween:Play()
								growTween.Completed:Wait()

								shrinkTween:Play()
								shrinkTween.Completed:Wait()
							end
						end)
					end

					local function LogoBGTween(image)
						local MAX = 0.95
						local MIN = 0.9

						local tweenInfo = TweenInfo.new(
							0.96,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.InOut
						)


						local growTween = tweenService:Create(image, tweenInfo, {
							ImageTransparency = MAX
						})

						local shrinkTween = tweenService:Create(image, tweenInfo, {
							ImageTransparency = MIN
						})

						task.spawn(function()
							while NewAutoWin.Enabled do
								growTween:Play()
								growTween.Completed:Wait()

								shrinkTween:Play()
								shrinkTween.Completed:Wait()
							end
						end)
					end

					local function Vig1Tween(image)
						local MAX = 1
						local MIN = 0.85

						local tweenInfo = TweenInfo.new(
							1.5,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.InOut
						)

						local growTween = tweenService:Create(image, tweenInfo, {
							ImageTransparency = MAX
						})

						local shrinkTween = tweenService:Create(image, tweenInfo, {
							ImageTransparency = MIN
						})

						task.spawn(function()
							while NewAutoWin.Enabled do
								growTween:Play()
								growTween.Completed:Wait()

								shrinkTween:Play()
								shrinkTween.Completed:Wait()
							end
						end)
					end

					local function Vig2Tween(image)
						local MAX = 0.98
						local MIN = 0.48

						local tweenInfo = TweenInfo.new(
							1.2,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.InOut
						)


						local growTween = tweenService:Create(image, tweenInfo, {
							ImageTransparency = MAX
						})

						local shrinkTween = tweenService:Create(image, tweenInfo, {
							ImageTransparency = MIN
						})

						task.spawn(function()
							while NewAutoWin.Enabled do
								growTween:Play()
								growTween.Completed:Wait()

								shrinkTween:Play()
								shrinkTween.Completed:Wait()
							end
						end)
					end

					local function username(txt,btn)
						hidden = not hidden

						if hidden then
							txt.Text = "username: [HIDDEN]"
							btn.BackgroundColor3 = Color3.fromRGB(236, 78, 78)
							btn.Text = 'Reveal user'
						else
							txt.Text = "username: "..lplr.Name
							btn.BackgroundColor3 = Color3.fromRGB(141, 236, 78)
							btn.Text = 'Conceal user'
						end
					end

					local function playTip(txt)
						local index

						if #tips > 1 then
							repeat
								index = math.random(1, #tips)
							until index ~= lastTip
						else
							index = 1
						end

						lastTip = index
						local tipText = tips[index]

						txt.Text = prefix .. tipText
						txt.MaxVisibleGraphemes = #prefix

						for i = #prefix + 1, #prefix + #tipText do
							txt.MaxVisibleGraphemes = i
							task.wait(typeSpeed)
						end

						task.wait(1.5)

						for i = #prefix + #tipText, #prefix, -1 do
							txt.MaxVisibleGraphemes = i
							task.wait(eraseSpeed)
						end

						task.wait(waitBetween)
					end

					local function StartTips(txt)
						task.wait(2)
						task.spawn(function()
							while true do
								playTip(txt)
							end
						end)
					end

					local function PercentUpdate(txt,per,snd)
						per = math.clamp(per, 0, 100)
						txt.Text = tostring(per).."%"
						local MaxPercent = 100
						local NewPercent = (per / MaxPercent)

						local tweenInfo = TweenInfo.new(
							0.3,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.Out
						)


						local tween = tweenService:Create(snd, tweenInfo, {
							Size = UDim2.fromScale(NewPercent, 1)
						})
						tween:Play()
						tween.Completed:Connect(function()
							task.wait(.1)
							tween:Destroy()
						end)
					end

					local function hookcheck(txt,frame)
						task.spawn(function()
							txt:GetAttributeChangedSignal('Percent'):Connect(function()
								PercentUpdate(txt,txt:GetAttribute("Percent"),frame)
							end)
						end)
					end

					local AutoFarmUI = create("ScreenGui",{Name='AutowinUI',Parent=lplr.PlayerGui,IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999})
					local MainFrame = create("Frame",{Parent=AutoFarmUI,Name='AutoFarmFrame',BackgroundColor3=Color3.fromRGB(25,25,25),Size=UDim2.fromScale(1,1)})
					local PerFrameMain = create("Frame",{BorderSizePixel=0,Parent=MainFrame,Name='LevelFrame',BackgroundColor3=Color3.fromRGB(40,40,45),Position=UDim2.new(0.5,-150,0.5,80),Size=UDim2.fromOffset(300,3),ZIndex=2})
					local PerFrameSecondary = create("Frame",{BackgroundColor3=Color3.fromRGB(215,215,215),BorderSizePixel=0,Parent=PerFrameMain,Name='Secondary',Size=UDim2.fromScale(0,1),ZIndex=3})
					local PercentText = create("TextLabel",{Name='Percent',Parent=PerFrameMain,BackgroundTransparency=1,Position=UDim2.new(0.5,-50,-26.167,50),TextColor3 = Color3.fromRGB(200, 200, 200),BackgroundColor3=Color3.fromRGB(255,255,255),Size=UDim2.fromOffset(100,20),ZIndex=2,Font=Enum.Font.Code,Text='0%',TextSize=12})
					PercentText:SetAttribute("Percent",0)
					create("UIStroke",{Color=Color3.fromRGB(255,255,255),Transparency=0.8,Parent=PerFrameMain})
					local XPFrameTip = create("Frame",{Name='XPFrame',BackgroundTransparency=1,Position=UDim2.fromScale(0.881,0.742),Size=UDim2.fromOffset(184,219),Parent=MainFrame})
					local div = create("Frame",{Parent=XPFrameTip,Name='Divider',BackgroundColor3=Color3.fromRGB(56,56,56),Position=UDim2.fromScale(0.049,0.146),Size=UDim2.fromOffset(168,4)})
					create("UICorner",{Parent = div})
					create("TextLabel",{Name='d1',BackgroundTransparency=1,Position=UDim2.new(0.598,-110,0.288,-30),Size=UDim2.fromOffset(184,33),ZIndex=2,Font=Enum.Font.Code,Text='(Day 1) > Level 9',TextColor3=Color3.fromRGB(120,120,120),TextSize=14,TextWrapped=true,Parent = XPFrameTip})
					create("TextLabel",{Name='d2',BackgroundTransparency=1,Position=UDim2.new(0.598, -110,0.438, -30),Size=UDim2.fromOffset(184,33),ZIndex=2,Font=Enum.Font.Code,Text='(Day 2) > Level 13',TextColor3=Color3.fromRGB(120,120,120),TextSize=14,TextWrapped=true,Parent = XPFrameTip})
					create("TextLabel",{Name='d3',BackgroundTransparency=1,Position=UDim2.new(0.598, -110,0.589, -30),Size=UDim2.fromOffset(184,44),ZIndex=2,Font=Enum.Font.Code,Text='(Day 3) > Level 16',TextColor3=Color3.fromRGB(120,120,120),TextSize=14,TextWrapped=true,Parent = XPFrameTip})
					create("TextLabel",{Name='d4',BackgroundTransparency=1,Position=UDim2.new(0.598, -110,0.79, -30),Size=UDim2.fromOffset(184,43),ZIndex=2,Font=Enum.Font.Code,Text='(Day 4) > Level 19',TextColor3=Color3.fromRGB(120,120,120),TextSize=14,TextWrapped=true,Parent = XPFrameTip})
					create("TextLabel",{Name='d5',BackgroundTransparency=1,Position=UDim2.new(0.598, -110,0.986, -30),Size=UDim2.fromOffset(184,33),ZIndex=2,Font=Enum.Font.Code,Text='(Day 5) > Level 20(Rank!)',TextColor3=Color3.fromRGB(120,120,120),TextSize=14,TextWrapped=true,Parent = XPFrameTip})
					create("TextLabel",{Name='title',BackgroundTransparency=1,Position=UDim2.new(0.598, -110,0.137, -30),Size=UDim2.fromOffset(184,33),ZIndex=2,Font=Enum.Font.Code,Text='XP Capped Level\'s',TextColor3=Color3.fromRGB(120,120,120),TextSize=18,TextWrapped=true,Parent = XPFrameTip})
					local LogoBGBG = create("ImageLabel",{Parent=MainFrame,Name='LogoBGBG',BackgroundTransparency=1,Position=UDim2.new(0.5,-120,0.5,-170),Size=UDim2.fromOffset(240,240),Image='rbxassetid://127677235878436',ImageTransparency=0.84})
					local LogoBG = create("ImageLabel",{Parent=LogoBGBG,Name='LogoBG',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Image='rbxassetid://127677235878436',ImageTransparency=0.95})
					local Logo = create("ImageLabel",{Parent=LogoBG,Name='Logo',BackgroundTransparency=1,Position=UDim2.new(0.5,-100,0.708,-150),Size=UDim2.fromOffset(200,200),ZIndex=2,Image='rbxassetid://127677235878436'})
					local Vig1 = create("ImageLabel",{Parent=MainFrame,Name='Vig1',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=2,Image='rbxassetid://135131984221448',ImageTransparency=1})
					local Vig2 = create("ImageLabel",{Parent=MainFrame,Name='Vig2',BackgroundTransparency=1,Size=UDim2.fromScale(2,2),Position=UDim2.fromScale(-0.474,-0.02),Rotation=90,ZIndex=2,Image='rbxassetid://135131984221448',ImageTransparency=1})
					local AccAge = create("TextLabel",{Name='AccAge',BackgroundTransparency=1,Position=UDim2.new(0.068, -110,0.873, -30),Size=UDim2.fromOffset(184,33),ZIndex=2,Font=Enum.Font.Code,Text='Account age: ',TextColor3=Color3.fromRGB(120,120,120),TextSize=14,TextWrapped=true,Parent = MainFrame})
					local Tip = create("TextLabel",{TextXAlignment='Left',Name='Tip',BackgroundTransparency=1,Position=UDim2.new(0.5,-300,1,-40),Size=UDim2.fromOffset(1171,20),ZIndex=2,Font=Enum.Font.Code,Text='tip: ...',TextColor3=Color3.fromRGB(130,130,130),TextSize=10,TextWrapped=true,Parent = MainFrame})
					local Tooltip = create("TextLabel",{Name='Tooltip',BackgroundTransparency=1,Position=UDim2.new(0.5,-200,0.5,100),Size=UDim2.fromOffset(400,30),ZIndex=2,Font=Enum.Font.Code,Text='...',TextColor3=Color3.fromRGB(200,200,200),TextSize=14,TextWrapped=true,Parent = MainFrame})
					local LvL = create("TextLabel",{Name='lvl',BackgroundTransparency=1,Position=UDim2.new(0.068, -110,0.949, -30),Size=UDim2.fromOffset(184,33),ZIndex=2,Font=Enum.Font.Code,Text='level: 0',TextColor3=Color3.fromRGB(120,120,120),TextSize=14,TextWrapped=true,Parent = MainFrame})
					local Username = create("TextLabel",{Name='user',BackgroundTransparency=1,Position=UDim2.new(0.068, -110,0.911, -30),Size=UDim2.fromOffset(184,33),ZIndex=2,Font=Enum.Font.Code,Text='username: [HIDDEN]',TextColor3=Color3.fromRGB(120,120,120),TextSize=14,TextWrapped=true,Parent = MainFrame})
					local UserButton = create("TextButton",{Name='btn',TextColor3=Color3.fromRGB(255,255,255),BackgroundColor3=Color3.fromRGB(236,78,78),Position=UDim2.new(4.098, 0,0, 0),Size=UDim2.fromOffset(130,26),ZIndex=1,Font=Enum.Font.Code,Text='Reveal user',TextSize=18,Parent = Username})
					create("UICorner",{Parent = UserButton})

					UserButton.Activated:Connect(function()
						username(Username,UserButton)
					end)
					LevelCheckHook(LvL)
					AccAgeHook(AccAge)
					hookcheck(PercentText,PerFrameSecondary)
					LogoBGTween(LogoBG)
					LogoBGBGTween(LogoBGBG)
					Vig1Tween(Vig1)
					Vig2Tween(Vig2)
					StartTips(Tip)
					local num = math.floor((3 / 1.85))
					Tooltip.Text = 'checking if you are in empty game...'
					task.wait((3 / 1.85))
					if #playersService:GetChildren() ~= 1 then
						num = math.floor((6 / 3.335))
						Tooltip.Text = 'player\'s found. Teleporting to a Empty Game..'
						lplr:Kick("Don't disconnect, this will auto teleport you!")
						task.wait((6 / 3.335))
						Reset()
					else
						Tooltip.Text = 'waiting for match to start...'
						repeat task.wait(0.1) until store.equippedKit ~= '' and store.matchState ~= 0 or (not NewAutoWin.Enabled)
						MethodThree(Tooltip,PercentText)
					end
				else
					vape:CreateNotification("AutoWin",'str64 error','warning',5.245)
				end
			
			else
				entitylib.character.Humanoid.Health = -9e9
				if lplr.PlayerGui:FindFirstChild('AutowinUI') then
					lplr.PlayerGui:FindFirstChild('AutowinUI'):Destroy()
				end
			end
		end
	})
	Methods = NewAutoWin:CreateDropdown({
		Name = "Methods",
		List = {'Method 1', 'Method 2','Method 3'},
		Tooltip = 'Method 1 - normal but undetected and fast\nMethod 2 - faster and blocks people who join(with autolobby) and even more undetected!\n Method 3 - same as method 2 but has faster and better player detections'
	})
	gui = NewAutoWin:CreateToggle({
		Name = "Gui",
		Default = true,
		Function = function(v)
			if lplr.PlayerGui:FindFirstChild('AutowinUI') then
				lplr.PlayerGui:FindFirstChild('AutowinUI').Enabled = v
			end
		end
	})
end)

run(function()
	local AutoShoot
	local Delay
	local Blatant
	local old
	local rayCheck = RaycastParams.new()
	rayCheck.FilterType = Enum.RaycastFilterType.Include
	local projectileRemote = {InvokeServer = function() end}
	local FireDelays = {}
	task.spawn(function()
		projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
	end)
	
	local function getAmmo(check)
		for _, item in store.inventory.inventory.items do
			if check.ammoItemTypes and table.find(check.ammoItemTypes, item.itemType) then
				return item.itemType
			end
		end
	end
	
	local function getProjectiles()
		local items = {}
		for _, item in store.inventory.inventory.items do
			local proj = bedwars.ItemMeta[item.itemType].projectileSource
			local ammo = proj and getAmmo(proj)
			if ammo then
				table.insert(items, {
					item,
					ammo,
					proj.projectileType(ammo),
					proj
				})
			end
		end
		return items
	end
	
	AutoShoot = vape.Categories.Inventory:CreateModule({
		Name = 'AutoShoot',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end
			if callback then				
				repeat
					local ent = entitylib.EntityPosition({
						Part = 'RootPart',
						Range = Blatant.Enabled and 32 or 23,
						Players = true,
						Wallcheck = true
					})
					if ent then
						local pos = entitylib.character.RootPart.Position
						for _, data in getProjectiles() do
							local item, ammo, projectile, itemMeta = unpack(data)
							if (FireDelays[item.itemType] or 0) < tick() then
								rayCheck.FilterDescendantsInstances = {workspace.Map}
								local meta = bedwars.ProjectileMeta[projectile]
								local projSpeed, gravity = meta.launchVelocity, meta.gravitationalAcceleration or 196.2
								local calc = prediction.SolveTrajectory(pos, projSpeed, gravity, ent.RootPart.Position, ent.RootPart.Velocity, workspace.Gravity, ent.HipHeight, ent.Jumping and 42.6 or nil, rayCheck)
								if calc then
									local slot = getObjSlot(projectile)
									local switched = switchHotbar(slot)
									task.spawn(function()
										local dir, id = CFrame.lookAt(pos, calc).LookVector, httpService:GenerateGUID(true)
										local shootPosition = (CFrame.new(pos, calc) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).Position
										bedwars.ProjectileController:createLocalProjectile(meta, ammo, projectile, shootPosition, id, dir * projSpeed, {drawDurationSeconds = 1})
										local res = projectileRemote:InvokeServer(item.tool, ammo, projectile, shootPosition, pos, dir * projSpeed, id, {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
										if not res then
											FireDelays[item.itemType] = tick()
										else
											local shoot = itemMeta.launchSound
											shoot = shoot and shoot[math.random(1, #shoot)] or nil
											if shoot then
												bedwars.SoundManager:playSound(shoot)
											end
										end
									end)
									FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
									if switched then
										task.wait(0.05)
									end
								end
							end
						end
					end
					task.wait(Delay.Value / 1000)
				until not AutoShoot.Enabled
			end
		end,
		Tooltip = 'automatically\'s make you shoot all types of projectiles when near a player'
	})
	Delay = AutoShoot:CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 1000,
		Suffix = "ms",
		Default = 250,
	})
	Blatant = AutoShoot:CreateToggle({
		Name = "Blatant",
		Default = false,
	})
end)

run(function()
	local Clutch
	local UseBlacklisted_Blocks
	local blacklisted
	local Speed
	local LimitToItems
	local RequireMouse
	local SilentAim
	local lastPlace = 0
	local clutchCount = 0
	local lastResetTime = 0
	local function GetBlocks()
		if store.hand.toolType == 'block' then
			return store.hand.tool.Name, store.hand.amount
		elseif (not LimitToItems.Enabled) then
			local wool, amount = getWool()
			if wool then
				return wool, amount
			else
				for _, item in store.inventory.inventory.items do
					if bedwars.ItemMeta[item.itemType].block then
						return item.itemType, item.amount
					end
				end
			end
		end
	
		return nil, 0
	end

	local function callPlace(blockpos, block, rotate)
		task.spawn(bedwars.placeBlock, blockpos, block, rotate)
	end

	local function nearCorner(poscheck, pos)
		local startpos = poscheck - Vector3.new(3, 3, 3)
		local endpos = poscheck + Vector3.new(3, 3, 3)
		local check = poscheck + (pos - poscheck).Unit * 100
		return Vector3.new(math.clamp(check.X, startpos.X, endpos.X), math.clamp(check.Y, startpos.Y, endpos.Y), math.clamp(check.Z, startpos.Z, endpos.Z))
	end

	local function blockProximity(pos)
		local mag, returned = 60
		local tab = getBlocksInPoints(bedwars.BlockController:getBlockPosition(pos - Vector3.new(21, 21, 21)), bedwars.BlockController:getBlockPosition(pos + Vector3.new(21, 21, 21)))
		for _, v in tab do
			local blockpos = nearCorner(v, pos)
			local newmag = (pos - blockpos).Magnitude
			if newmag < mag then
				mag, returned = newmag, blockpos
			end
		end
		table.clear(tab)
		return returned
	end

	Clutch = vape.Categories.World:CreateModule({
		Name = 'Clutch',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end
			if callback then
				Clutch:Clean(runService.Heartbeat:Connect(function()
					if not entitylib.isAlive then return end
					local root = entitylib.character.RootPart
					local blocks = select(1, GetBlocks())
					if not blocks then return end
					
					if blocks and not UseBlacklisted_Blocks.Enabled then
						for i,v in blacklisted.ListEnabled do
							if blocks == v then
								return																																																																																																																																																																									
							end																																																																																																																																																																												
						end
					end
					
					if RequireMouse.Enabled and not inputService:IsMouseButtonPressed(0) then return end

					
					local vy = root.Velocity.Y
					local now = os.clock()
					
					if (now - lastResetTime) > 5 then
						clutchCount = 0
						lastResetTime = now
					end
					
					local cooldown = math.clamp(HoldBase - (Speed.Value * 0.015), 0.01, HoldBase)
					
					if vy < -6 and (now - lastPlace) > cooldown then
						local target = roundPos(root.Position - Vector3.new(0, entitylib.character.HipHeight + 4.5, 0))
						local exists, blockpos = getPlacedBlock(target)
						
						if not exists then
							local prox = blockProximity(target)
							local placePos = prox or (target * 3)
							
							callPlace(placePos, blocks, false)
							lastPlace = now
							clutchCount = clutchCount + 1
							
							
							if SilentAim.Enabled then
								local camera = workspace.CurrentCamera
								local camCFrame = camera and camera.CFrame
								local camType = camera and camera.CameraType
								local camSubject = camera and camera.CameraSubject
								local lv = root.CFrame.LookVector
								local newLook = -Vector3.new(lv.X, 0, lv.Z).Unit
								local rootPos = root.Position
								root.CFrame = CFrame.new(rootPos, rootPos + newLook)
								if camera and camCFrame then
									camera.CameraType = camType
									camera.CameraSubject = camSubject
									camera.CFrame = camCFrame
								end
							end
						end
					end
				end))
			end
		end,
		Tooltip = 'automatically\'s places a block when falling to clutch'
	})
	UseBlacklisted_Blocks = Clutch:CreateToggle({
		Name = "Use Blacklisted Blocks",
		Default = false,
		Tooltip = "Allows clutching with blacklisted blocks"
	})
	blacklisted = Clutch:CreateTextList({
		Name = "Blacklisted Blocks",
		Placeholder = "tnt"
	})
	Speed = Clutch:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 15,
		Default = 8,
		Tooltip = 'How fast it places the blocks'
	})
	LimitToItems = Clutch:CreateToggle({
		Name = 'Limit to items',
		Default = false,
		Tooltip = "Only clutch when holding blocks"
	})
	RequireMouse = Clutch:CreateToggle({
		Name = 'Require mouse down',
		Default = false,
		Tooltip = "Only clutch when holding left click"
	})
	SilentAim = Clutch:CreateToggle({
		Name = 'SilentAim',
		Default = false,
		Tooltip = "Corrects ur position when placing blocks"
	})
end)






run(function()
		local AutoWin
		local empty
		local Dashes = {Value = 2}
		local function Reset(db)
			if db then
				vape:CreateNotification("AutoWin", "Teleporting to empty game!", 4)
				local TeleportService = game:GetService("TeleportService")
				local data = TeleportService:GetLocalPlayerTeleportData()
				AutoWin:Clean(TeleportService:Teleport(game.PlaceId, lplr, data))
			else
				return
			end
		end
		AutoWin = vape.Categories.AltFarm:CreateModule({
			Name = 'YuziAutoWin',
			Function = function(callback)
				if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
					vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
					return
				end 
				if not callback then
					return  
				end
				if store.equippedKit == "dasher" then
					Reset(empty.Value)
					local beds = {}
					local currentbedpos 
					local function AllbedPOS()
						if workspace:FindFirstChild("MapCFrames") then
							for _, obj in ipairs(workspace:FindFirstChild("MapCFrames"):GetChildren()) do
								if string.match(obj.Name, "_bed$") then
									table.insert(beds, obj.Value.Position)
								end
							end
						end
					end
					local function UpdateCurrentBedPOS()
						if workspace:FindFirstChild("MapCFrames") then
							local currentTeam =  lplr.Character:GetAttribute("Team")
							if workspace:FindFirstChild("MapCFrames") then
								local CFRameName = tostring(currentTeam).."_bed"
								currentbedpos = workspace:FindFirstChild("MapCFrames"):FindFirstChild(CFRameName).Value.Position
							end
						end
					end
					local function closestBed(origin)
						local closest, dist
						for _, pos in ipairs(beds) do
							if pos ~= currentbedpos then
								local d = (pos - origin).Magnitude
								if not dist or d < dist then
									dist, closest = d, pos
								end
							end
						end
						return closest
					end
					local function tweenToBED(pos)
						if entitylib.isAlive then
							pos = pos + Vector3.new(0, 5, 0)
							local currentPosition = entitylib.character.RootPart.Position
							if (pos - currentPosition).Magnitude > 0.5 then
								if lplr.Character then
									lplr:SetAttribute('LastTeleported', 0)
								end
								local info = TweenInfo.new(1.34,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
								local tween = tweenService:Create(entitylib.character.RootPart,info,{CFrame = CFrame.new(pos)})
								task.spawn(function()
									if bedwars.AbilityController:canUseAbility("dash") then
										vape:CreateNotification("AutoWin", "Dashing to bypass anti cheat!", 1)
										bedwars.AbilityController:useAbility('dash',newproxy(true),{
											direction = gameCamera.CFrame,
											origin = entitylib.character.RootPart.Position,
											weapon = store.hand.tool.Name.itemType
										})
									end
									task.wait(0.0025)
									tween:Play()
								end)
								task.spawn(function()
									tween.Completed:Wait()
								end)
								lplr:SetAttribute('LastTeleported', os.time())
								task.wait(0.25)
								if lplr.Character then
									task.wait(0.1235)
									lplr:SetAttribute('LastTeleported', os.time())
								end
							end
						end
					end
					AllbedPOS()
					UpdateCurrentBedPOS()
					bedpos = closestBed(entitylib.character.RootPart.Position)
					tweenToBED(bedpos)
				else
					vape:CreateNotification("AutoWin", "You need yuzi for this method", 8,"warning")
				end
			end,
			Tooltip = 'new method for autowin! longjump but different'
		})
		empty = AutoWin:CreateToggle({
			Name = "EmptyGame",
			Default = false
		})
end)

run(function()
    local HitFix
	local PingBased
	local Options
    HitFix = vape.Categories.Blatant:CreateModule({
        Name = 'HitFix',
        Function = function(callback)
            if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" then
                vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
                return
            end  

            local function getPing()
                local stats = game:GetService("Stats")
                local ping = stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
                return tonumber(ping:match("%d+")) or 50
            end

            local function getDelay()
                local ping = getPing()

                if PingBased.Enabled then
                    if Options.Value == "Blatant" then
                        return math.clamp(0.08 + (ping / 1000), 0.08, 0.14)
                    else
                        return math.clamp(0.11 + (ping / 1200), 0.11, 0.15)
                    end
                end

                return Options.Value == "Blatant" and 0.1 or 0.13
            end

            if callback then
                pcall(function()
                    if bedwars.SwordController and bedwars.SwordController.swingSwordAtMouse then
                        local func = bedwars.SwordController.swingSwordAtMouse

                        if Options.Value == "Blatant" then
                            debug.setconstant(func, 23, "raycast")
                            debug.setupvalue(func, 4, bedwars.QueryUtil)
                        end

                        for i, v in ipairs(debug.getconstants(func)) do
                            if typeof(v) == "number" and (v == 0.15 or v == 0.1) then
                                debug.setconstant(func, i, getDelay())
                            end
                        end
                    end
                end)
            else
                pcall(function()
                    if bedwars.SwordController and bedwars.SwordController.swingSwordAtMouse then
                        local func = bedwars.SwordController.swingSwordAtMouse

                        debug.setconstant(func, 23, "Raycast")
                        debug.setupvalue(func, 4, workspace)

                        for i, v in ipairs(debug.getconstants(func)) do
                            if typeof(v) == "number" then
                                if v < 0.15 then
                                    debug.setconstant(func, i, 0.15)
                                end
                            end
                        end
                    end
                end)
            end
        end,
        Tooltip = 'Improves hit registration and decreases the chances of a ghost hit'
    })

    Options = HitFix:CreateDropdown({
        Name = "Mode",
        List = {"Blatant", "Legit"},
    })

    PingBased = HitFix:CreateToggle({
        Name = "Ping Based",
        Default = false,
    })
end)


run(function()
	local AutoKit
	local Legit
	local Toggles = {}
	local function kitCollection(id, func, range, specific)
		local objs = type(id) == 'table' and id or collection(id, AutoKit)
		repeat
			if entitylib.isAlive then
				local localPosition = entitylib.character.RootPart.Position
				for _, v in objs do
					if InfiniteFly.Enabled or not AutoKit.Enabled then break end
					local part = not v:IsA('Model') and v or v.PrimaryPart
					if part and (part.Position - localPosition).Magnitude <= (range) then
						func(v)
					end
				end
			end
			task.wait(0.1)
		until not AutoKit.Enabled
	end
	
	
		
	local AutoKitFunctions = {
		spearman = function()
			local function fireSpear(pos, spot, item)
				local projectileRemote = {InvokeServer = function() end}
				task.spawn(function()
					projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
				end)
				if item then		
					local spear = getObjSlot('spear')
					switchHotbar(spear)
					local meta = bedwars.ProjectileMeta.spear
					local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
					if calc then
						local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
						bedwars.ProjectileController:createLocalProjectile(meta, 'spear', 'spear', pos, nil, dir, {drawDurationSeconds = 1})
						projectileRemote:InvokeServer(item.tool, 'spear', 'spear', pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
					end
				end
			end
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local spearTool = getItem("spear")


				if not spearTool then task.wait(0.1) continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 15 or (15*2),
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					local pos = plr.RootPart.Position
					local spot = plr.RootPart.Velocity
					if spearTool then
						fireSpear(pos,spot,spearTool)
					end
		        end
				
				task.wait(.025)
		    until not AutoKit.Enabled
		end,
		owl = function()
			local isWhispering = false
			AutoKit:Clean(bedwars.Client:Get("OwlSummoned"):Connect(function(data)
				if data ~= lplr then
				local target = playersService:GetPlayerFromUserID(workspace:WaitForChild("ServerOwl"):GetAttribute("Target"))
				local chr = target.Character
				local hum = chr:FindFirstChild('Humanoid')
				local root = chr:FindFirstChild('HumanoidRootPart')
				isWhispering = true
				repeat
					local plr = entitylib.EntityPosition({
						Range = Legit.Enabled and (23/1.215) or 32,
						Part = "RootPart",
						Players = true,
						Sort = sortmethods.Health
					})
					rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, AntiVoidPart}
					rayCheck.CollisionGroup = root.CollisionGroup
					task.spawn(function()
						if root.Velocity.Y <= Legit.Enabled and -130 or -90 and not workspace:Raycast(root.Position, Vector3.new(0, -100, 0), rayCheck) then
							WhisperController:request("Fly")
						end
					end)
					task.spawn(function()
						if (hum.MaxHealth - hum.Health) >= Legit.Enabled and 45 or 85 then
							WhisperController:request("Heal")
						end
					end)
					task.spawn(function()
						if plr then
							WhisperController:request("Shoot",workspace:FindFirstChild("ClientOwl").Handle,plr,lplr)
						end
					end)	
					task.wait(0.05)
				until not isWhispering or not AutoKit.Enabled
				end
			end))
			AutoKit:Clean(bedwars.Client:Get("OwlDeattached"):Connect(function(data)
				if data ~= lplr then
					isWhispering = false
				end
			end))
		end,
		winter_lady = function()
			local projectileRemote = {InvokeServer = function() end}
			task.spawn(function()
				projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
			end)
			local function fireStaff(pos, spot, item,staff)
				if item then
					local meta = bedwars.ProjectileMeta[staff]
					local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
					if calc then
						local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
						bedwars.ProjectileController:createLocalProjectile(meta, staff, staff, pos, nil, dir, {drawDurationSeconds = 1})
						projectileRemote:InvokeServer(item.tool, staff, staff, pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
					end
				end
			end

			local function Shoot(plr)
				if plr == nil then return end
				local str = "frost_staff"
				local fireStaffStr = ""
				local fullstr = ""
				for i, v in replicatedStorage.Inventories[lplr.Name]:GetChildren() do
					if string.find(v.Name, str) then
						fullstr = v.Name
					end
				end
				if fullstr == "frost_staff_1" then
					FireStaffStr = "frosty_snowball_1"
				elseif fullstr == "frost_staff_2" then
					FireStaffStr = "frosty_snowball_2"
				elseif fullstr == "frost_staff_3" then
					FireStaffStr = "frosty_snowball_3"
				else
					FireStaffStr = "frosty_snowball_1" -- fallback if im retarded
				end
				fireStaff(plr.RootPart.Position,plr.RootPart.Velocity,getItem(fullstr),fireStaffStr)
			end
			local holding = false
			local function Hold(plr)
				if plr == nil then
					if holding then
						holding = false
						bedwars.Client:Get("FrostyGunFireActionRequest"):SendToServer({ keyHold = false })
					end
					return
				end

				if holding then return end

				holding = true
				bedwars.Client:Get("FrostyGunFireActionRequest"):SendToServer({ keyHold = true })
				task.wait(0.00456) -- math fucking sucks istg
				bedwars.Client:Get("FrostyGunFire"):SendToServer({
					userPosition = entitylib.character.RootPart.Position,
					direction = gameCamera.CFrame
				})
			end                      
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and (23/1.18) or 32,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
				local gui = lplr.PlayerGui:FindFirstChild("FrostyGunGUI")
				if not gui then continue end

				for _, v in gui:GetChildren() do
					if v:IsA("ImageLabel") and v.Name == "AbilityIcon" then
						if v.Image == "rbxassetid://11611911951" then
							if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
								Hold(plr)
							else
								Hold(nil)
							end
						elseif v.Image == "rbxassetid://139613766654382" then
							if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
								Shoot(plr)
							else
								Shoot(nil)
							end
						else
							if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
								Hold(plr) -- another fallback if im retarded
							else
								Hold(nil)
							end
						end
					end
				end

				task.wait(.4533)
		    until not AutoKit.Enabled
		end,
		void_walker = function()
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and (23/2.125) or 23,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if bedwars.AbilityController:canUseAbility('void_walker_warp') then
						bedwars.AbilityController:useAbility('void_walker_warp')
					end
		        end
				
				if lplr.Character:GetAttribute('Health') <= Legit.Enabled and 56 or 64 then
					if bedwars.AbilityController:canUseAbility('void_walker_rewind') then
						bedwars.AbilityController:useAbility('void_walker_rewind')
					end
				end

				task.wait(.233)
		    until not AutoKit.Enabled
		end,
		falconer = function()
			local canRecall = true
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 32 or 100,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health,
					WallCheck = Legit.Enabled
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if plr.RootPart:FindFirstChild("BillboardGui") then continue end
					if bedwars.AbilityController:canUseAbility('SEND_FALCON') then
						canRecall = true
						bedwars.AbilityController:useAbility('SEND_FALCON',newproxy(true),{
							target = plr.RootPart.Position
						})
					end
				else
					if bedwars.AbilityController:canUseAbility('RECALL_FALCON') and canRecall then
						canRecall = false
						bedwars.AbilityController:useAbility('RECALL_FALCON')
					end													
		        end
				
				task.wait(.233)
		    until not AutoKit.Enabled
		end,
		styx = function()
			local r = 0
			if Legit.Enabled then
				r = 6
			else
				r = 12
			end
			local uuid  = ""
			bedwars.Client:Get("StyxOpenExitPortalFromServer"):Connect(function(v1)
				uuid = v1.exitPortalData.connectedEntrancePortalUUID
			end)
			kitCollection(lplr.Name..":styx_entrance_portal", function(v)
				bedwars.Client:Get("UseStyxPortalFromClient"):SendToServer({
					entrancePortalData = {
						proximityPrompt = v:WaitForChild('ProximityPrompt'),
						uuid = uuid,
						blockPosition = bedwars.BlockController:getBlockPosition(v.Position),
						whirpoolSpinHeartbeatConnection = (nil --[[ RBXScriptConnection | IsConnected: true ]]),
						blockUUID = v:GetAttribute("BlockUUID"),
						beam = workspace:WaitForChild("StyxPortalBeam"),
						worldPosition = bedwars.BlockController:getWorldPosition(v.Position),
						teamId = entitylib.character:GetAttribute("Team")					
					}
				})
			end, r, false)
			AutoKit:Clean(workspace.ChildAdded:Connect(function(obj)
				if obj.Name == "StyxPortal" then
					local MaxStuds = Legit.Enabled and 8 or 16
					local NewDis = (obj.Pivot.Position - entitylib.character.RootPart.Position).Magnitude
					if NewDis <= MaxStuds then
						local args = {uuid}
						replicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("StyxTryOpenExitPortalFromClient"):InvokeServer(unpack(args))
					end
				end
			end))
		end,
		elektra = function()
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 5 or 10,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if bedwars.AbilityController:canUseAbility('ELECTRIC_DASH') then
						bedwars.AbilityController:useAbility('ELECTRIC_DASH')
					end																		
		        end
				
				task.wait(.833)
		    until not AutoKit.Enabled
		end,
		taliyah = function()
			local r = 0
			if Legit.Enabled then
				r = 5
			else
				r = 10
			end
			kitCollection('entity', function(v)
				if bedwars.Client:Get('CropHarvest'):CallServer({position = bedwars.BlockController:getBlockPosition(v.Position)}) then
					if Legit.Enabled then
						bedwars.GameAnimationUtil:playAnimation(lplr.Character, bedwars.AnimationType.PUNCH)
						bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
					end
				end
			end, r, false)
		end,
		black_market_trader = function()
			local r = 0
			if Legit.Enabled then
				r = 8
			else
				r = 16
			end
			kitCollection('shadow_coin', function(v)
			    bedwars.Client:Get("CollectCollectableEntity"):SendToServer({id = v:GetAttribute("Id"),collectableName = 'shadow_coin'})
			end, r, false)
		end,
		oasis = function()
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 8 or 18,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if bedwars.AbilityController:canUseAbility('oasis_swap_staff') then
						local str = "oasis"
						local fullstr = ""
						for i, v in replicatedStorage.Inventories[lplr.Name]:GetChildren() do
							if string.find(v.Name, str) then
								fullstr = v.Name
							end
						end
						local slot = getObjSlot(fullstr)
						local ogslot = GetOriginalSlot()
						switchHotbar(slot)
						bedwars.AbilityController:useAbility('oasis_swap_staff')
						task.wait(0.225)
						switchHotbar(ogslot)
					end																		
		        end

				if lplr.Character:GetAttribute('Health') <= Legit.Enabled and 32 or 50 then
					if bedwars.AbilityController:canUseAbility('oasis_heal_veil') then
						bedwars.AbilityController:useAbility('oasis_heal_veil')
					end
				end
				
				task.wait(.223)
		    until not AutoKit.Enabled
		end,
		spirit_summoner = function()
			local projectileRemote = {InvokeServer = function() end}
			task.spawn(function()
				projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
			end)
			local function fireStaff(pos, spot, item,slot)
				if item then
					local staff = 'spirit_staff'	
					local originalSlot = store.inventory.hotbarSlot
					switchHotbar(slot)
					local meta = bedwars.ProjectileMeta[staff]
					local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
					if calc then
						local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
						bedwars.ProjectileController:createLocalProjectile(meta, staff, staff, pos, nil, dir, {drawDurationSeconds = 1})
						projectileRemote:InvokeServer(item.tool, staff, staff, pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
					end
				end
			end
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local stone = getItem("summon_stone")
				local staff = getItem("spirit_staff")
				if not stone or not staff then task.wait(0.1) continue end
				local gen = GetNearGen(Legit.Enabled,entitylib.character.RootPart.Position)
				local pos = gen
				if gen then
					if bedwars.AbilityController:canUseAbility('summon_attack_spirit') then
						bedwars.AbilityController:useAbility('summon_attack_spirit')
					end
					task.wait(0.1)
					fireStaff(pos,entitylib.character.RootPart.Velocity,staff,getObjSlot('spirit_staff'))
				end
				if lplr.Character:GetAttribute('Health') <= Legit.Enabled and 40 or 56 then
					if bedwars.AbilityController:canUseAbility('summon_heal_spirit') then
						bedwars.AbilityController:useAbility('summon_heal_spirit')
					end
				end
				task.wait(.45)
		    until not AutoKit.Enabled
		end,
		rebellion_leader = function()
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 15 or 25,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if bedwars.AbilityController:canUseAbility('rebellion_aura_swap') then
						bedwars.AbilityController:useAbility('rebellion_aura_swap')
					end																		
		        end
				local t = 0
				t = Legit.Enabled and 45 or 65
				if lplr.Character:GetAttribute('Health') <= t then
					if bedwars.AbilityController:canUseAbility('rebellion_shield') then
						bedwars.AbilityController:useAbility('rebellion_shield')
					end
				end
				
				task.wait(.45)
		    until not AutoKit.Enabled
		end,
		ninja = function()
			local projectileRemote = {InvokeServer = function() end}
			task.spawn(function()
				projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
			end)
			local function fireUmeko(pos, spot, item,slot,charm)
				if item then		
					local originalSlot = store.inventory.hotbarSlot
					switchHotbar(slot)
					local meta = bedwars.ProjectileMeta[charm]
					local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
					if calc then
						local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
						bedwars.ProjectileController:createLocalProjectile(meta, charm, charm, pos, nil, dir, {drawDurationSeconds = 1})
						projectileRemote:InvokeServer(item.tool, charm, charm, pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
					end
				end
			end
			local function getCharm()
				local items = inv or store.inventory.inventory.items
				if not items then return end

				for _, item in pairs(items) do
					if item.itemType and item.itemType:lower():find("chakram") then
						return item.itemType
					end
				end
			end
			local function getCharmSlot(charmType)
				if not charmType then return end
				return getObjSlot(charmType)
			end
			repeat
				if not entitylib.isAlive then
					task.wait(0.1)
					continue
				end

				local charm = getCharm()
				local charmSlot = getCharmSlot(charm)

				if not charm then
					task.wait(0.1)
					continue
				end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 23 or 32,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					fireUmeko(plr.RootPart.Position,plr.RootPart.Velocity,item,charmSlot,charm)
				end

				task.wait(0.025)
			until not AutoKit.Enabled
		end,
		frosty = function()
			local function fireball(pos, spot, item)
				local projectileRemote = {InvokeServer = function() end}
				task.spawn(function()
					projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
				end)
				if item then		
					local snowball = getObjSlot('frosted_snowball')
					local originalSlot = store.inventory.hotbarSlot
					switchHotbar(snowball)
					local meta = bedwars.ProjectileMeta.frosted_snowball
					local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
					if calc then
						local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
						bedwars.ProjectileController:createLocalProjectile(meta, 'frosted_snowball', 'frosted_snowball', pos, nil, dir, {drawDurationSeconds = 1})
						projectileRemote:InvokeServer(item.tool, 'frosted_snowball', 'frosted_snowball', pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
					end
				end
			end
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local SnowBallTool = getItem("frosted_snowball")


				if not SnowBallTool then task.wait(0.1) continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 10 or 15,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					local pos = plr.RootPart.Position
					local spot = plr.RootPart.Velocity
					if SnowBallTool then
						fireball(pos,spot,SnowBallTool)
					end
		        end
				
				task.wait(.025)
		    until not AutoKit.Enabled
		end,
		cowgirl = function()
			local projectileRemote = {InvokeServer = function() end}
			task.spawn(function()
				projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
			end)
			local function fireLasso(pos, spot, item)
				if item then		
					local lasso = getObjSlot('lasso')
					local originalSlot = store.inventory.hotbarSlot
					switchHotbar(lasso)
					local meta = bedwars.ProjectileMeta.lasso
					local calc = prediction.SolveTrajectory(pos, meta.launchVelocity, meta.gravitationalAcceleration, spot, Vector3.zero, workspace.Gravity, 0, 0)
					if calc then
						local dir = CFrame.lookAt(pos, calc).LookVector * meta.launchVelocity
						bedwars.ProjectileController:createLocalProjectile(meta, 'lasso', 'lasso', pos, nil, dir, {drawDurationSeconds = 1})
						projectileRemote:InvokeServer(item.tool, 'lasso', 'lasso', pos, pos, dir, httpService:GenerateGUID(true), {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)     
					end
				end
			end
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local lassoTool = getItem("lasso")


				if not lassoTool then task.wait(0.1) continue end

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 15 or 25,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					local pos = plr.RootPart.Position
					local spot = plr.RootPart.Velocity
					if lassoTool then
						fireLasso(pos,spot,lassoTool)
					end
		        end
				
				task.wait(.45)
		    until not AutoKit.Enabled
		end,
		sheep_herder = function()
			local r = 0
			if Legit.Enabled then
				r = 8
			else
				r = 16
			end
			kitCollection('sheep', function(v)
				local args = {[1] = v}
				replicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild('@rbxts'):WaitForChild('net'):WaitForChild('out'):WaitForChild('_NetManaged'):WaitForChild('SheepHerder/TameSheep'):FireServer(unpack(args))
			end, r, false)
		end,
		regent = function()
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local axe = getItem("void_axe")

				if not axe then task.wait(0.1) continue end

				local Sword = getSwordSlot()
				local Axe = getObjSlot('void_axe')
				local originalSlot = store.inventory.hotbarSlot

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 15 or 25,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if bedwars.AbilityController:canUseAbility('void_axe_jump') then
						switchHotbar(Axe)
						bedwars.AbilityController:useAbility('void_axe_jump')
						task.wait(0.23)
						switchHotbar(originalSlot)
					end																		
		        end
				
				task.wait(.45)
		    until not AutoKit.Enabled
		end,
		jade = function()

			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local ham = getItem("jade_hammer")
				local originalSlot = store.inventory.hotbarSlot
				if not ham then task.wait(0.1) continue end

				local Sword = getSwordSlot()
				local Ham = getObjSlot('jade_hammer')

				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 13 or 18,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if bedwars.AbilityController:canUseAbility('jade_hammer_jump') then
						switchHotbar(Ham)
						bedwars.AbilityController:useAbility('jade_hammer_jump')
						task.wait(0.23)
						switchHotbar(originalSlot)
					end																		
		        end
				
				task.wait(.45)
		    until not AutoKit.Enabled
		end,
		yeti = function()
			local function getBedNear()
				local localPosition = entitylib.isAlive and entitylib.character.RootPart.Position or Vector3.zero
				for _, v in collectionService:GetTagged("bed") do
					if (localPosition - v.Position).Magnitude < Legit.Enabled and (15/1.95) or 15 then
						if v:GetAttribute("Team" .. (lplr:GetAttribute("Team") or -1) .. "NoBreak") then 
							return nil 
						end
						return v
					end
				end
			end
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local bed = getBedNear()

				if bed then
					if bedwars.AbilityController:canUseAbility('yeti_glacial_roar') then
						bedwars.AbilityController:useAbility('yeti_glacial_roar')
					end	
				end
				task.wait(.45)
		    until not AutoKit.Enabled
		end,
		dragon_sword = function()
		    repeat
			    if not entitylib.isAlive then task.wait(0.1); continue end
				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 5 or 10,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
				local plr2 = entitylib.EntityPosition({
					Range = Legit.Enabled and 15 or 30,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
				if plr and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if bedwars.AbilityController:canUseAbility('dragon_sword') then
						bedwars.AbilityController:useAbility('dragon_sword')
					end																		
		        end
				
				if plr2 and (lplr.Character:GetAttribute("Health") or 0) > 0 then
					if bedwars.AbilityController:canUseAbility('dragon_sword_ult') then
						bedwars.AbilityController:useAbility('dragon_sword_ult')
					end																		
		        end
		        task.wait(.45)
		    until not AutoKit.Enabled
		end,
		defender = function()
		    repeat
			    if not entitylib.isAlive then task.wait(0.1); continue end
				local handItem = lplr.Character:FindFirstChild('HandInvItem')
				local hasScanner = false
				if handItem and handItem.Value then
					local itemType = handItem.Value.Name
					hasScanner = itemType:find('defense_scanner')
				end
				
				if not hasScanner then
					task.wait(0.1)
					continue
				end

				for i, v in workspace:GetChildren() do
					if v:IsA("BasePart") then
						if v.Name == "DefenderSchematicBlock" then
							v.Transparency = 0.85
							v.Grid.Transparency = 1
							local BP = bedwars.BlockController:getBlockPosition(v.Position)
							bedwars.Client:Get("DefenderRequestPlaceBlock"):CallServer({["blockPos"] = BP})
							pcall(function()
								local sounds = {
									bedwars.SoundList.DEFENDER_UPGRADE_DEFENSE_04,
									bedwars.SoundList.DEFENDER_UPGRADE_DEFENSE_03,
									bedwars.SoundList.DEFENDER_UPGRADE_DEFENSE_02,
									bedwars.SoundList.DEFENDER_UPGRADE_DEFENSE_01
								}

								for i = 4, 1, -1 do
									bedwars.SoundManager:playSound(sounds[i], {
										position = BP,
										playbackSpeedMultiplier = 0.8
									})
									task.wait(0.082)
								end
							end)
							
							task.wait(Legit.Enabled and math.random(1,2) - math.random() or (0.5 - math.random()))
						end
					end
				end

				AutoKit:Clean(workspace.ChildAdded:Connect(function(v)
					if v:IsA("BasePart") then
						if v.Name == "DefenderSchematicBlock" then
							v.Transparency = 0.85
							v.Grid.Transparency = 1
							local BP = bedwars.BlockController:getBlockPosition(v.Position)
							bedwars.Client:Get("DefenderRequestPlaceBlock"):SendToServer({["blockPos"] = BP})
							pcall(function()
								local sounds = {
									bedwars.SoundList.DEFENDER_UPGRADE_DEFENSE_04,
									bedwars.SoundList.DEFENDER_UPGRADE_DEFENSE_03,
									bedwars.SoundList.DEFENDER_UPGRADE_DEFENSE_02,
									bedwars.SoundList.DEFENDER_UPGRADE_DEFENSE_01
								}

								for i = 4, 1, -1 do
									bedwars.SoundManager:playSound(sounds[i], {
										position = BP,
										playbackSpeedMultiplier = 0.8
									})
									task.wait(0.082)
								end
							end)
							
							task.wait(math.random(1,2) - math.random())
						end
					end
				end))
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		shielder = function()
			local Distance = 0
			if Legit.Enabled then
				Distance = 32 / 2
			else
				Distance = 32
			end
			AutoKit:Clean(workspace.DescendantAdded:Connect(function(arrow)
				if not AutoKit.Enabled then return end
				if (arrow.Name == "crossbow_arrow" or arrow.Name == "arrow" or arrow.Name == "headhunter_arrow") and arrow:IsA("Model") then
					if arrow:GetAttribute("ProjectileShooter") == lplr.UserId then return end
					local root = arrow:FindFirstChildWhichIsA("BasePart")
					if not root then return end
					local NewDis = (lplr.Character.HumanoidRootPart.Position - root.Position).Magnitude
					while root and root.Parent do
						NewDis = (lplr.Character.HumanoidRootPart.Position - root.Position).Magnitude
						if NewDis <= Distance then
							local shield = getObjSlot('infernal_shield')
							local originalSlot = store.inventory.hotbarSlot
							switchHotbar(shield)
							task.wait(0.125)
							switchHotbar(originalSlot)
						end
						task.wait(0.05)
					end
				end
			end))
		end,
        alchemist = function()
			local r= 0
						if Legit.Enabled then
				r = 8
			else
				r = 16
			end
			kitCollection('alchemist_ingedients', function(v)
			    bedwars.Client:Get("CollectCollectableEntity"):SendToServer({id = v:GetAttribute("Id"),collectableName = v.Name})
			end, r, false)
        end,
        midnight = function()
			local old = nil
		    repeat
			    if not entitylib.isAlive then task.wait(0.1); continue end
				local root = entitylib.character.RootPart
				if not root then continue end
				
				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and (18/(1.995 + math.random())) or 18,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
				if plr and (not Legit.Enabled or (lplr.Character:GetAttribute("Health") or 0) > 0) then
					if bedwars.AbilityController:canUseAbility('midnight') then
						bedwars.AbilityController:useAbility('midnight')
						old = bedwars.SwordController.isClickingTooFast
						bedwars.SwordController.isClickingTooFast = function(self)
							self.lastSwing = 45.812 / 1.25
							return false
						end
						local T = Legit.Enabled and 4.5 or 6.45
                        Speed:Toggle(true)
                        task.wait(T)
                        Speed:Toggle(false)
						task.wait(11)
						bedwars.SwordController.isClickingTooFast = old
						old = nil
					end																		
		        end
		
		        task.wait(.45)
		    until not AutoKit.Enabled
        end,
		sorcerer = function()
			local r = 0
						if Legit.Enabled then
				r = 8
			else
				r = 16
			end
			kitCollection('alchemy_crystal', function(v)
			    bedwars.Client:Get("CollectCollectableEntity"):SendToServer({id = v:GetAttribute("Id"),collectableName = v.Name})
			end, r, false)
		end,
		berserker = function()
			local mapCFrames = workspace:FindFirstChild("MapCFrames")
			local teamid = lplr.Character:GetAttribute("Team")
		
			if mapCFrames then
					for _, obj in pairs(mapCFrames:GetChildren()) do
						if obj:IsA("CFrameValue") and string.match(obj.Name, "_bed") then
							if not string.match(obj.Name, teamid .. "_bed") then
								local part = Instance.new("Part")
								part.Transparency = 1
								part.CanCollide = false
								part.Anchored = true
								part.Size = Legit.Enabled and Vector3.new(48, 48, 48) or Vector3.new(72, 72, 72)
								part.CFrame = obj.Value
								part.Parent = workspace
								part.Name = "AutoKitRagnarPart"
								part.Touched:Connect(function(v)
									if v.Parent.Name == lplr.Name then
										if bedwars.AbilityController:canUseAbility('berserker_rage') then
											bedwars.AbilityController:useAbility('berserker_rage')
											if not Legit.Enabled and not FastBreak.Enabled then
												repeat
													bedwars.BlockBreakController.blockBreaker:setCooldown(0.185)
													task.wait(0.1)
												until not bedwars.AbilityController:canUseAbility('berserker_rage')
												task.wait(0.0125)
												bedwars.BlockBreakController.blockBreaker:setCooldown(0.3)
											end
										end																																
									end
								end)
							end
						end
					end
			end

			AutoKit:Clean(function()
				for i,v in workspace:GetChildren() do
					if v:IsA("BasePart") and v.Name == "AutoKitRagnarPart" then
					v:Destory()
					end
				end
			end)
		
		end,																																																								
		glacial_skater = function()
		    repeat
			    if not entitylib.isAlive then task.wait(0.1); continue end
				if Legit.Enabled then
					bedwars.Client:Get("MomentumUpdate"):SendToServer({['momentumValue'] = 100})
				else
					bedwars.Client:Get("MomentumUpdate"):SendToServer({['momentumValue'] = 9e9})
				end
		        task.wait(0.1)
		    until not AutoKit.Enabled
		end,
		cactus = function()
		    repeat
			    if not entitylib.isAlive then task.wait(0.1); continue end
				local root = entitylib.character.RootPart
				if not root then continue end
				
				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and (16/1.54) or 16,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
				if plr then
					if bedwars.AbilityController:canUseAbility('cactus_fire') then
						bedwars.AbilityController:useAbility('cactus_fire')
					end																		
		        end
		
		        task.wait(1)
		    until not AutoKit.Enabled
		end,
		card = function()
		    repeat
			    if not entitylib.isAlive then task.wait(0.1); continue end
				local root = entitylib.character.RootPart
				if not root then continue end
				
				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and (20/3.2) or 20,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
				if plr then
		          bedwars.Client:Get("AttemptCardThrow"):SendToServer({
		                ["targetEntityInstance"] = plr.Character
		            })
		        end
		
		        task.wait(0.5)
		    until not AutoKit.Enabled
		end,																																																					
		void_hunter = function()
		    repeat
			    if not entitylib.isAlive then task.wait(0.1); continue end
				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and (20/2.8) or 20,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
				
				if plr and (not Legit.Enabled or (lplr.Character:GetAttribute("Health") or 0) > 0) then
		        	bedwars.Client:Get("VoidHunter_MarkAbilityRequest"):SendToServer({
		            	["originPosition"] = lplr.Character.PrimaryPart.Position,
		            	["direction"] = workspace.CurrentCamera.CFrame.LookVector
		        	})
		        	Speed:Toggle(true)
					task.wait(3)
					Speed:Toggle(false)
			end
			task.wait(0.5)
			until not AutoKit.Enabled	
		end,																																																									
		skeleton = function()
		    repeat
			    if not entitylib.isAlive then task.wait(0.1); continue end
				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 5.235 or 10,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
			
				if plr and (not Legit.Enabled or (lplr.Character:GetAttribute("Health") or 0) > 0) then
						if bedwars.AbilityController:canUseAbility('skeleton_ability') then
							bedwars.AbilityController:useAbility('skeleton_ability')
						end																																
					Speed:Toggle(true)
					task.wait(3)
					Speed:Toggle(false)
				end
				task.wait(0.5)
	    	until not AutoKit.Enabled		
		end,
		drill = function()
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local root = entitylib.character.RootPart
				local drills = {}
				
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj.Name == "Drill" then
						table.insert(drills, obj)
					end
				end
			
				if #drills == 0 then
					continue
				end
			
				for _, drillObj in ipairs(drills) do
					if Legit.Enabled then
						if drillObj:FindFirstChild("RootPart") then
							local drillRoot = drillObj.RootPart
							if (drillRoot.Position - root.Position).Magnitude <= 15 then
								bedwars.Client:Get('ExtractFromDrill'):SendToServer({
									drill = drillObj
								})
							end
						end
					else
						bedwars.Client:Get('ExtractFromDrill'):SendToServer({
							drill = drillObj
						})
					end
				end
		
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		airbender = function()
			repeat
				if not entitylib.isAlive then task.wait(0.1); continue end
				local root = entitylib.character.RootPart
				if not root then continue end
			
					local plr = entitylib.EntityPosition({
						Range = Legit.Enabled and 14 and 25,
						Part = "RootPart",
						Players = true,
						Sort = sortmethods.Health
					})
			
					local plr2 = entitylib.EntityPosition({
						Range = Legit.Enabled and 23 and 31,
						Part = "RootPart",
						Players = true,
						Sort = sortmethods.Health
					})
			
					if plr and (not Legit.Enabled or (lplr.Character:GetAttribute("Health") or 0) > 0) then
						if bedwars.AbilityController:canUseAbility('airbender_tornado') then
							bedwars.AbilityController:useAbility('airbender_tornado')
						end
					end
			
					if plr2 and (not Legit.Enabled or (lplr.Character:GetAttribute("Health") or 0) > 0) then
						local direction = (plr2.RootPart.Position - root.Position).Unit
						if bedwars.AbilityController:canUseAbility('airbender_moving_tornado') then
							bedwars.AbilityController:useAbility('airbender_moving_tornado')
						end
					end
				task.wait(0.5)

				until not AutoKit.Enabled
		end,
		nazar = function()
			local empoweredMode = false
			local lastHitTime = 0
			local hitTimeout = 3
			local LowHealthThreshold = 0
			LowHealthThreshold = Legit.Enabled and 50 or 75
			AutoKit:Clean(vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
				if not entitylib.isAlive then return end
					
				local attacker = playersService:GetPlayerFromCharacter(damageTable.fromEntity)
				local victim = playersService:GetPlayerFromCharacter(damageTable.entityInstance)
					
				if attacker == lplr and victim and victim ~= lplr then
					lastHitTime = workspace:GetServerTimeNow()
					NazarController:request('enabled')
				end
			end))
				
			AutoKit:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
				if not entitylib.isAlive then return end
					
				local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
				local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
					
				if killer == lplr and killed and killed ~= lplr then
					NazarController:request('disabled')
				end
			end))
				
			repeat
				if entitylib.isAlive then
					local currentTime = workspace:GetServerTimeNow()
						
					if empoweredMode and (currentTime - lastHitTime) >= hitTimeout then
						NazarController:request('disabled')
					end
				else
					if empoweredMode then
						NazarController:request('disabled')
					end
				end

				if lplr.Character:GetAttribute('Health') <= LowHealthThreshold then
					NazarController:request('heal')
				end

				task.wait(0.1)
			until not AutoKit.Enabled
				
			AutoKit:Clean(function()
				if empoweredMode then
					NazarController:request('disabled')
				end
			end)
		end,
		void_knight = function()
			repeat
				if not entitylib.isAlive then
					task.wait(0.1)
					continue
				end
					
				local currentTier = lplr:GetAttribute('VoidKnightTier') or 0
				local currentProgress = lplr:GetAttribute('VoidKnightProgress') or 0
				local currentKills = lplr:GetAttribute('VoidKnightKills') or 0
				local haltedProgress = lplr:GetAttribute('VoidKnightHaltedProgress')
					
				if haltedProgress then
					task.wait(0.5)
					continue
				end
					
				if currentTier < 4 then
					if currentTier < 3 then
						local ironAmount = getItem('iron')
						ironAmount = ironAmount and ironAmount.amount or 0
							
						if ironAmount >= 10 and bedwars.AbilityController:canUseAbility('void_knight_consume_iron') then
							bedwars.AbilityController:useAbility('void_knight_consume_iron')
							task.wait(0.5)
						end
					end
						
					if currentTier >= 2 and currentTier < 4 then
						local emeraldAmount = getItem('emerald')
						emeraldAmount = emeraldAmount and emeraldAmount.amount or 0
							
						if emeraldAmount >= 1 and bedwars.AbilityController:canUseAbility('void_knight_consume_emerald') then
							bedwars.AbilityController:useAbility('void_knight_consume_emerald')
							task.wait(0.5)
						end
					end
				end
					
				if currentTier >= 4 and bedwars.AbilityController:canUseAbility('void_knight_ascend') then
					local shouldAscend = false
						
					local health = lplr.Character:GetAttribute('Health') or 100
					local maxHealth = lplr.Character:GetAttribute('MaxHealth') or 100
					if health < (maxHealth * 0.5) then
						shouldAscend = true
					end
						
					if not shouldAscend then
						local plr = entitylib.EntityPosition({
							Range = Legit.Enabled and 30 or 50,
							Part = 'RootPart',
							Players = true,
							Sort = sortmethods.Health
						})
						if plr then
							shouldAscend = true
						end
					end
						
					if shouldAscend then
						bedwars.AbilityController:useAbility('void_knight_ascend')
						task.wait(16)
					end
				end
					
					task.wait(0.5)
				until not AutoKit.Enabled
		end,
		hatter = function()
			repeat
				for _, text in pairs(lplr.PlayerGui.NotificationApp:GetDescendants()) do
					if text:IsA("TextLabel") then
						local txt = string.lower(text.Text)
						if string.find(txt, "teleport") then
							if bedwars.AbilityController:canUseAbility('HATTER_TELEPORT') then
								bedwars.AbilityController:useAbility('HATTER_TELEPORT')
							end																																		
						end
					end
				end
				task.wait(0.34)
			until not AutoKit.Enabled
		end,
		mage = function()
			local r = 0
			if Legit.Enabled then
				r = 10
			else
				r = math.huge or (2^1024-1)
			end
			kitCollection('ElementTome', function(v)
				if Legit.Enabled then bedwars.GameAnimationUtil:playAnimation(lplr, bedwars.AnimationType.PUNCH); bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM) end
				bedwars.Client:Get("LearnElementTome"):SendToServer({secret = v:GetAttribute('TomeSecret')})
				v:Destroy()
				task.wait(0.5)
			end, r, false)
		end,
		pyro = function()
			repeat																																																										
				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 10 or 25,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})

				if plr and (not Legit.Enabled or (lplr.Character:GetAttribute("Health") or 0) > 0) then
					game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.UseFlamethrower:InvokeServer()
					Speed:Toggle(true)
					task.wait(1.85)
					Speed:Toggle(false)
				end
				task.wait(0.1)
			until not AutoKit.Enabled																																																						
		end,
		frost_hammer_kit = function()
			repeat																																																		
				local frost, slot = getItem('frost_crystal')
				local UFH = game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.UpgradeFrostyHammer

				local attributes = { "shield", "strength", "speed" }
				local slots = { [0] = 2, [1] = 5, [2] = 12 }

				for _, attr in ipairs(attributes) do
					local value = lplr:GetAttribute(attr)
					if slots[value] == slot then
						UFH:InvokeServer(attr)
					end
				end
				task.wait(0.1)
			until not AutoKit.Enabled																																																						
		end,
		battery = function()
			repeat
				if entitylib.isAlive then
					local localPosition = entitylib.character.RootPart.Position
					for i, v in bedwars.BatteryEffectsController.liveBatteries do
						if (v.position - localPosition).Magnitude <= Legit.Enabled and 4 or 10 then
							local BatteryInfo = bedwars.BatteryEffectsController:getBatteryInfo(i)
							if not BatteryInfo or BatteryInfo.activateTime >= workspace:GetServerTimeNow() or BatteryInfo.consumeTime + 0.1 >= workspace:GetServerTimeNow() then continue end
							BatteryInfo.consumeTime = workspace:GetServerTimeNow()
							bedwars.Client:Get(remotes.ConsumeBattery):SendToServer({batteryId = i})
						end
					end
				end
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		beekeeper = function()
			local r =  0
						if Legit.Enabled then
				r = 8
			else
				r = 16
			end
			kitCollection('bee', function(v)
				bedwars.Client:Get(remotes.BeePickup):SendToServer({beeId = v:GetAttribute('BeeId')})
			end,r, false)
		end,
		bigman = function()
			local r = 0
						if Legit.Enabled then
				r = 8
			else
				r = 12
			end
			kitCollection('treeOrb', function(v)
				if Legit.Enabled then
					if bedwars.Client:Get(remotes.ConsumeTreeOrb):CallServer({treeOrbSecret = v:GetAttribute('TreeOrbSecret')}) then
						bedwars.GameAnimationUtil:playAnimation(lplr.Character, bedwars.AnimationType.PUNCH)
						bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
						v:Destroy()
					end
				else
					if bedwars.Client:Get(remotes.ConsumeTreeOrb):CallServer({treeOrbSecret = v:GetAttribute('TreeOrbSecret')}) then
						v:Destroy()
					end
				end
			end, r, false)
		end,
		block_kicker = function()
			local old = bedwars.BlockKickerKitController.getKickBlockProjectileOriginPosition
			bedwars.BlockKickerKitController.getKickBlockProjectileOriginPosition = function(...)
				local origin, dir = select(2, ...)
				local plr = entitylib.EntityMouse({
					Part = 'RootPart',
					Range = Legit.Enabled and 50 or 250,
					Origin = origin,
					Players = true,
					Wallcheck = Legit.Enabled
				})
		
				if plr then
					local calc = prediction.SolveTrajectory(origin, 100, 20, plr.RootPart.Position, plr.RootPart.Velocity, workspace.Gravity, plr.HipHeight, plr.Jumping and 42.6 or nil)
		
					if calc then
						for i, v in debug.getstack(2) do
							if v == dir then
								debug.setstack(2, i, CFrame.lookAt(origin, calc).LookVector)
							end
						end
					end
				end
		
				return old(...)
			end
		
			AutoKit:Clean(function()
				bedwars.BlockKickerKitController.getKickBlockProjectileOriginPosition = old
			end)
		end,
		cat = function()
			local old = bedwars.CatController.leap
			bedwars.CatController.leap = function(...)
				vapeEvents.CatPounce:Fire()
				return old(...)
			end
		
			AutoKit:Clean(function()
				bedwars.CatController.leap = old
			end)
		end,
		davey = function()
			local old = bedwars.CannonHandController.launchSelf
			bedwars.CannonHandController.launchSelf = function(...)
				local res = {old(...)}
				local self, block = ...
		
				if block:GetAttribute('PlacedByUserId') == lplr.UserId and (block.Position - entitylib.character.RootPart.Position).Magnitude < 30 then
					if Legit.Enabled then
						local str = "pickaxe"
						local fullstr = ""
						for i, v in replicatedStorage.Inventories[lplr.Name]:GetChildren() do
							if string.find(v.Name, str) then
								fullstr = v.Name
							end
						end
						local pickaxe = getObjSlot(fullstr)
						local OgSlot = GetOriginalSlot()
						switchHotbar(pickaxe)
						task.spawn(bedwars.breakBlock, block, false, nil, true)
						task.spawn(bedwars.breakBlock, block, false, nil, true)
						task.wait(0.15)
						switchHotbar(OgSlot)
					else
						task.spawn(bedwars.breakBlock, block, false, nil, true)
						task.spawn(bedwars.breakBlock, block, false, nil, true)
					end
				end
		
				return unpack(res)
			end
		
			AutoKit:Clean(function()
				bedwars.CannonHandController.launchSelf = old
			end)
		end,
		dragon_slayer = function()
			local r = 0
						if Legit.Enabled then
				r = 18 / 2
			else
				r = 18
			end
			kitCollection('KaliyahPunchInteraction', function(v)
				if Legit.Enabled then
					bedwars.DragonSlayerController:deleteEmblem(v)
					bedwars.DragonSlayerController:playPunchAnimation(Vector3.zero)
					bedwars.Client:Get(remotes.KaliyahPunch):SendToServer({
						target = v
					})
				else
					bedwars.Client:Get(remotes.KaliyahPunch):SendToServer({
						target = v
					})
				end
			end, r, true)
		end,
		farmer_cletus = function()
			local r = 0
					if Legit.Enabled then
				r = 5
			else
				r = 10
			end
			kitCollection('HarvestableCrop', function(v)
				bedwars.Client:Get('CropHarvest'):CallServer({position = bedwars.BlockController:getBlockPosition(v.Position)})
				if Legit.Enabled then
					bedwars.GameAnimationUtil:playAnimation(lplr.Character, bedwars.AnimationType.PUNCH)
					if lplr.Character:GetAttribute('CropKitSkin') == bedwars.BedwarsKitSkin.FARMER_CLETUS_VALETINE then
						bedwars.SoundManager:playSound(bedwars.SoundList.VALETINE_CROP_HARVEST)
					else
						bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
					end
				end
			end, r, false)
		end,
		fisherman = function()
			local old = bedwars.FishingMinigameController.startMinigame
			bedwars.FishingMinigameController.startMinigame = function(_, _, result)
				if Legit.Enabled then
					local Chance = 50
					local rng = (math.random((Chance/3),(Chance/2))) - math.random()
					if rng >= 20 then
						task.wait(math.random(4,6) - math.random())
						result({win = true})
					else
						result({win = false})
					end
				else
					result({win = true})
				end
			end
		
			AutoKit:Clean(function()
				bedwars.FishingMinigameController.startMinigame = old
			end)
		end,
		gingerbread_man = function()
			local old = bedwars.LaunchPadController.attemptLaunch
			bedwars.LaunchPadController.attemptLaunch = function(...)
				local res = {old(...)}
				local self, block = ...
		
				if (workspace:GetServerTimeNow() - self.lastLaunch) < 0.4 then
					if block:GetAttribute('PlacedByUserId') == lplr.UserId and (block.Position - entitylib.character.RootPart.Position).Magnitude < 30 then
						if Legit.Enabled then
							local str = "pickaxe"
							local fullstr = ""
							for i, v in replicatedStorage.Inventories[lplr.Name]:GetChildren() do
								if string.find(v.Name, str) then
									fullstr = v.Name
								end
							end
							local pickaxe = getObjSlot(fullstr)
							local OgSlot = GetOriginalSlot()
							switchHotbar(pickaxe)
							task.spawn(bedwars.breakBlock, block, false, nil, true)
							task.wait(0.15)
							switchHotbar(OgSlot)
						else
							task.spawn(bedwars.breakBlock, block, false, nil, true)
						end
					end
				end
		
				return unpack(res)
			end
		
			AutoKit:Clean(function()
				bedwars.LaunchPadController.attemptLaunch = old
			end)
		end,
		hannah = function()
			local r = 0
					if Legit.Enabled then
				r = 15
			else
				r = 30
			end
			kitCollection('HannahExecuteInteraction', function(v)
				local billboard = bedwars.Client:Get(remotes.HannahKill):CallServer({
					user = lplr,
					victimEntity = v
				}) and v:FindFirstChild('Hannah Execution Icon')
		
				if billboard then
					billboard:Destroy()
				end
			end, r, true)
		end,
		jailor = function()
			local r = 0
			if Legit.Enabled then
				r = 9
			else
				r = 20
			end
			kitCollection('jailor_soul', function(v)
				bedwars.JailorController:collectEntity(lplr, v, 'JailorSoul')
			end, r, false)
		end,
		grim_reaper = function()
			local r = 0
			if Legit.Enabled then
				r = 35
			else
				r = 120
			end
			kitCollection(bedwars.GrimReaperController.soulsByPosition, function(v)
				if entitylib.isAlive and lplr.Character:GetAttribute('Health') <= (lplr.Character:GetAttribute('MaxHealth') / 4) and (not lplr.Character:GetAttribute('GrimReaperChannel')) then
					bedwars.Client:Get(remotes.ConsumeSoul):CallServer({
						secret = v:GetAttribute('GrimReaperSoulSecret')
					})
				end
			end,  r, false)
		end,
		melody = function()
				local r = 0
			if Legit.Enabled then
				r = 15
			else
				r = 45
			end
			repeat

				local mag, hp, ent = r, math.huge
				if entitylib.isAlive then
					local localPosition = entitylib.character.RootPart.Position
					for _, v in entitylib.List do
						if v.Player and v.Player:GetAttribute('Team') == lplr:GetAttribute('Team') then
							local newmag = (localPosition - v.RootPart.Position).Magnitude
							if newmag <= mag and v.Health < hp and v.Health < v.MaxHealth then
								mag, hp, ent = newmag, v.Health, v
							end
						end
					end
				end
		
				if ent and getItem('guitar') then
					bedwars.Client:Get(remotes.GuitarHeal):SendToServer({
						healTarget = ent.Character
					})
				end
		
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		metal_detector = function()
			local r = 0
					if Legit.Enabled then
				r = 8
			else
				r = 10
			end
			kitCollection('hidden-metal', function(v)
				if Legit.Enabled then
					bedwars.GameAnimationUtil:playAnimation(lplr,bedwars.AnimationType.SHOVEL_DIG)
					bedwars.SoundManager:playSound(bedwars.SoundList.SNAP_TRAP_CONSUME_MARK)
					bedwars.Client:Get('CollectCollectableEntity'):SendToServer({
						id = v:GetAttribute('Id')
					})
				else
					bedwars.Client:Get('CollectCollectableEntity'):SendToServer({
						id = v:GetAttribute('Id')
					})
				end
			end, r, false)
		end,
		miner = function()
			local r = 0
						if Legit.Enabled then
				r = 8
			else
				r = 16
			end
			kitCollection('petrified-player', function(v)
				bedwars.Client:Get(remotes.MinerDig):SendToServer({
					petrifyId = v:GetAttribute('PetrifyId')
				})
			end, r, true)
		end,
		pinata = function()
			local r = 0
					if Legit.Enabled then
				r = 8
			else
				r =18
			end
			kitCollection(lplr.Name..':pinata', function(v)
				if getItem('candy') then
					bedwars.Client:Get('DepositCoins'):CallServer(v)
				end
			end,  r, true)
		end,
		spirit_assassin = function()
			local r = Legit.Enabled and 35 or 120
					if Legit.Enabled then
				r = 35
			else
				r = 120
			end
			kitCollection('EvelynnSoul', function(v)
				bedwars.SpiritAssassinController:useSpirit(lplr, v)
			end, r , true)
		end,
		star_collector = function()
			local r =  Legit.Enabled and 10 or 20
					if Legit.Enabled then
				r = 10
			else
				r = 20
			end
			kitCollection('stars', function(v)
				bedwars.StarCollectorController:collectEntity(lplr, v, v.Name)
			end, r, false)
		end,
		summoner = function()
			local lastAttackTime = 0
			local attackCooldown = 0.65
				
			repeat
				if not entitylib.isAlive then
					task.wait(0.1)
					continue
				end
					
				local isCasting = false
				if Legit.Enabled then
					if lplr.Character:GetAttribute("Casting") or 
					lplr.Character:GetAttribute("UsingAbility") or
					lplr.Character:GetAttribute("SummonerCasting") then
						isCasting = true
					end
						
					local humanoid = lplr.Character:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
						isCasting = true
					end
				end
					
				if Legit.Enabled and isCasting then
					task.wait(0.1)
					continue
				end
					
				if (workspace:GetServerTimeNow() - lastAttackTime) < attackCooldown then
					task.wait(0.1)
					continue
				end
					
				local handItem = lplr.Character:FindFirstChild('HandInvItem')
				local hasClaw = false
				if handItem and handItem.Value then
					local itemType = handItem.Value.Name
					hasClaw = itemType:find('summoner_claw')
				end
					
				if not hasClaw then
					task.wait(0.1)
					continue
				end
					
				local range = Legit.Enabled and 23 or 35
				local plr = entitylib.EntityPosition({
					Range = range, 
					Part = 'RootPart',
					Players = true,
					NPCs = true,
					Sort = sortmethods.Health
				})

				if plr then
					local distance = (entitylib.character.RootPart.Position - plr.RootPart.Position).Magnitude
					if Legit.Enabled and distance > 23 then
						plr = nil 
					end
				end

				if plr and (not Legit.Enabled or (lplr.Character:GetAttribute('Health') or 0) > 0) then
					local localPosition = entitylib.character.RootPart.Position
					local shootDir = CFrame.lookAt(localPosition, plr.RootPart.Position).LookVector
					localPosition += shootDir * math.max((localPosition - plr.RootPart.Position).Magnitude - 16, 0)

					lastAttackTime = workspace:GetServerTimeNow()

					pcall(function()
						bedwars.AnimationUtil:playAnimation(lplr, bedwars.GameAnimationUtil:getAssetId(bedwars.AnimationType.SUMMONER_CHARACTER_SWIPE), {
							looped = false
						})
					end)

					task.spawn(function()
						pcall(function()
							local clawModel = replicatedStorage.Assets.Misc.Kaida.Summoner_DragonClaw:Clone()
									
							clawModel.Parent = workspace
								
							if gameCamera.CFrame.Position and (gameCamera.CFrame.Position - entitylib.character.RootPart.Position).Magnitude < 1 then
								for _, part in clawModel:GetDescendants() do
									if part:IsA('MeshPart') then
										part.Transparency = 0.6
									end
								end
							end
								
							local rootPart = entitylib.character.RootPart
							local Unit = Vector3.new(shootDir.X, 0, shootDir.Z).Unit
							local startPos = rootPart.Position + Unit:Cross(Vector3.new(0, 1, 0)).Unit * -1 * 5 + Unit * 6
							local direction = (startPos + shootDir * 13 - startPos).Unit
							local cframe = CFrame.new(startPos, startPos + direction)
							
							clawModel:PivotTo(cframe)
							clawModel.PrimaryPart.Anchored = true
							
							if clawModel:FindFirstChild('AnimationController') then
								local animator = clawModel.AnimationController:FindFirstChildOfClass('Animator')
								if animator then
									bedwars.AnimationUtil:playAnimation(animator, bedwars.GameAnimationUtil:getAssetId(bedwars.AnimationType.SUMMONER_CLAW_ATTACK), {
										looped = false,
										speed = 1
									})
								end
							end
								
							pcall(function()
								local sounds = {
									bedwars.SoundList.SUMMONER_CLAW_ATTACK_1,
									bedwars.SoundList.SUMMONER_CLAW_ATTACK_2,
									bedwars.SoundList.SUMMONER_CLAW_ATTACK_3,
									bedwars.SoundList.SUMMONER_CLAW_ATTACK_4
								}
								bedwars.SoundManager:playSound(sounds[math.random(1, #sounds)], {
									position = rootPart.Position
								})
							end)
								
							task.wait(0.75)
							clawModel:Destroy()
						end)
					end)

					bedwars.Client:Get(remotes.SummonerClawAttack):SendToServer({
						position = localPosition,
						direction = shootDir,
						clientTime = workspace:GetServerTimeNow()
					})
				end

				task.wait(0.1)
				until not AutoKit.Enabled
		end,
		void_dragon = function()
			local oldflap = bedwars.VoidDragonController.flapWings
			local flapped
		
			bedwars.VoidDragonController.flapWings = function(self)
				if not flapped and bedwars.Client:Get(remotes.DragonFly):CallServer() then
					local modifier = bedwars.SprintController:getMovementStatusModifier():addModifier({
						blockSprint = true,
						constantSpeedMultiplier = 2
					})
					self.SpeedMaid:GiveTask(modifier)
					self.SpeedMaid:GiveTask(function()
						flapped = false
					end)
					flapped = true
				end
			end
		
			AutoKit:Clean(function()
				bedwars.VoidDragonController.flapWings = oldflap
			end)
		
			repeat
				if bedwars.VoidDragonController.inDragonForm then
					local plr = entitylib.EntityPosition({
						Range =  Legit.Enabled and 15 or 30,
						Part = 'RootPart',
						Players = true
					})
		
					if plr then
						bedwars.Client:Get(remotes.DragonBreath):SendToServer({
							player = lplr,
							targetPoint = plr.RootPart.Position
						})
					end
				end
				task.wait(0.1)
				until not AutoKit.Enabled
		end,
		warlock = function()
				local lastTarget
				repeat
					if store.hand.tool and store.hand.tool.Name == 'warlock_staff' then
						local plr = entitylib.EntityPosition({
							Range =  Legit.Enabled and (30/2.245) or 30,
							Part = 'RootPart',
							Players = true,
							NPCs = true
						})
		
						if plr and plr.Character ~= lastTarget then
							if not bedwars.Client:Get(remotes.WarlockTarget):CallServer({
								target = plr.Character
							}) then
								plr = nil
							end
						end
		
						lastTarget = plr and plr.Character
					else
						lastTarget = nil
					end
		
					task.wait(0.1)
				until not AutoKit.Enabled
		end,
		spider_queen = function()
				local isAiming = false
				local aimingTarget = nil
				
				repeat
					if entitylib.isAlive and bedwars.AbilityController then
						local plr = entitylib.EntityPosition({
							Range = not Legit.Enabled and 80 or 50,
							Part = 'RootPart',
							Players = true,
							Sort = sortmethods.Health
						})
						
						if plr and not isAiming and bedwars.AbilityController:canUseAbility('spider_queen_web_bridge_aim') then
							bedwars.AbilityController:useAbility('spider_queen_web_bridge_aim')
							isAiming = true
							aimingTarget = plr
							task.wait(0.1)
						end
						
						if isAiming and aimingTarget and aimingTarget.RootPart then
							local localPosition = entitylib.character.RootPart.Position
							local targetPosition = aimingTarget.RootPart.Position
							
							local direction
							if Legit.Enabled then
								direction = (targetPosition - localPosition).Unit
							else
								direction = (targetPosition - localPosition).Unit
							end
							
							if bedwars.AbilityController:canUseAbility('spider_queen_web_bridge_fire') then
								bedwars.AbilityController:useAbility('spider_queen_web_bridge_fire', newproxy(true), {
									direction = direction
								})
								isAiming = false
								aimingTarget = nil
								task.wait(0.3)
							end
						end
						
						if isAiming and (not aimingTarget or not aimingTarget.RootPart) then
							isAiming = false
							aimingTarget = nil
						end
						
						local summonAbility = 'spider_queen_summon_spiders'
						if bedwars.AbilityController:canUseAbility(summonAbility) then
							bedwars.AbilityController:useAbility(summonAbility)
						end
					end
					
					task.wait(0.05)
				until not AutoKit.Enabled
		end,
		blood_assassin = function()
				local hitPlayers = {} 
				
				AutoKit:Clean(vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if not entitylib.isAlive then return end
					
					local attacker = playersService:GetPlayerFromCharacter(damageTable.fromEntity)
					local victim = playersService:GetPlayerFromCharacter(damageTable.entityInstance)
				
					if attacker == lplr and victim and victim ~= lplr then
						hitPlayers[victim] = true
						
						local storeState = bedwars.Store:getState()
						local activeContract = storeState.Kit.activeContract
						local availableContracts = storeState.Kit.availableContracts or {}
						
						if not activeContract then
							for _, contract in availableContracts do
								if contract.target == victim then
									bedwars.Client:Get('BloodAssassinSelectContract'):SendToServer({
										contractId = contract.id
									})
									break
								end
							end
						end
					end
				end))
				
				repeat
					if entitylib.isAlive then
						local storeState = bedwars.Store:getState()
						local activeContract = storeState.Kit.activeContract
						local availableContracts = storeState.Kit.availableContracts or {}
						
						if not activeContract and #availableContracts > 0 then
							local bestContract = nil
							local highestDifficulty = 0
							
							for _, contract in availableContracts do
								if hitPlayers[contract.target] then
									if contract.difficulty > highestDifficulty then
										bestContract = contract
										highestDifficulty = contract.difficulty
									end
								end
							end
							
							if bestContract then
								bedwars.Client:Get('BloodAssassinSelectContract'):SendToServer({
									contractId = bestContract.id
								})
								task.wait(0.5)
							end
						end
					end
					task.wait(1)
				until not AutoKit.Enabled
				
				table.clear(hitPlayers)
		end,
		mimic = function()
			repeat
				if not entitylib.isAlive then
					task.wait(0.1)
						continue
					end
					
					local localPosition = entitylib.character.RootPart.Position
					for _, v in entitylib.List do
						if v.Targetable and v.Character and v.Player then
							local distance = (v.RootPart.Position - localPosition).Magnitude
							if distance <= (Legit.Enabled and 12 or 30) then
								if collectionService:HasTag(v.Character, "MimicBLockPickPocketPlayer") then
									pcall(function()
										local success = replicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("MimicBlockPickPocketPlayer"):InvokeServer(v.Player)
									end)
									task.wait(0.5)
								end
							end
						end
					end
					
					task.wait(0.1)
				until not AutoKit.Enabled
		end,
		gun_blade = function()
			repeat
				if bedwars.AbilityController:canUseAbility('hand_gun') then
					local plr = entitylib.EntityPosition({
						Range = Legit.Enabled and 10 or 20,
						Part = 'RootPart',
						Players = true,
						Sort = sortmethods.Health
					})
			
					if plr then
						bedwars.AbilityController:useAbility('hand_gun')
					end
				end
			
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		wizard = function()
			math.randomseed(os.clock() * 1e6)
			local roll = math.random(100)
			repeat
				local ability = lplr:GetAttribute("WizardAbility")
				if not ability then
					task.wait(0.85)
					continue
				end
				local plr = entitylib.EntityPosition({
					Range = Legit.Enabled and 32 or 50,
					Part = "RootPart",
					Players = true,
					Sort = sortmethods.Health
				})
				if not plr or not store.hand.tool then
					task.wait(0.85)
					continue
				end
				local itemType = store.hand.tool.Name.itemType
				local targetPos = plr.RootPart.Position
				if bedwars.AbilityController:canUseAbility(ability) then
					bedwars.AbilityController:useAbility(ability,newproxy(true),{target = targetPos})
				end
				if itemType == "wizard_staff_2" or itemType == "wizard_staff_3" then
					local plr2 = entitylib.EntityPosition({
						Range = Legit.Enabled and 13 or 20,
						Part = "RootPart",
						Players = true,
						Sort = sortmethods.Health
					})

					if plr2 then
						if roll <= 50 then
							if bedwars.AbilityController:canUseAbility("SHOCKWAVE") then
								bedwars.AbilityController:useAbility("SHOCKWAVE",newproxy(true),{target = Vector3.zero})
							end
						else
							if bedwars.AbilityController:canUseAbility(ability) then
								bedwars.AbilityController:useAbility(ability,newproxy(true),{target = targetPos})
							end
						end
					end
				end
				if itemType == "wizard_staff_3" then
					local plr3 = entitylib.EntityPosition({
						Range = Legit.Enabled and 12 or 18,
						Part = "RootPart",
						Players = true,
						Sort = sortmethods.Health
					})
					if plr3 then
						if roll <= 40 then
							if bedwars.AbilityController:canUseAbility(ability) then
								bedwars.AbilityController:useAbility(ability,newproxy(true),{target = targetPos})
							end
						elseif roll <= 70 then
							if bedwars.AbilityController:canUseAbility("SHOCKWAVE") then
								bedwars.AbilityController:useAbility("SHOCKWAVE",newproxy(true),{target = Vector3.zero})
							end
						else
							if bedwars.AbilityController:canUseAbility("LIGHTNING_STORM") then
								bedwars.AbilityController:useAbility("LIGHTNING_STORM",newproxy(true),{target = targetPos})
							end
						end
					end
				end
				task.wait(0.85)
			until not AutoKit.Enabled
		end,
		--[[wizard = function()
			repeat
				local ability = lplr:GetAttribute('WizardAbility')
				if ability and bedwars.AbilityController:canUseAbility(ability) then
					local plr = entitylib.EntityPosition({
						Range = Legit.Enabled and 32 or 50,
						Part = 'RootPart',
						Players = true,
						Sort = sortmethods.Health
					})
		
					if plr then
						bedwars.AbilityController:useAbility(ability, newproxy(true), {target = plr.RootPart.Position})
					end
				end
		
				task.wait(0.1)
			until not AutoKit.Enabled
		end,--]]
	}
	
	AutoKit = vape.Categories.Support:CreateModule({
		Name = 'AutoKit',
		Function = function(callback)
			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user"then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end  
			if callback then
				repeat task.wait(0.1) until store.equippedKit ~= '' and store.matchState ~= 0 or (not AutoKit.Enabled)
				if AutoKit.Enabled and AutoKitFunctions[store.equippedKit] then
					AutoKitFunctions[store.equippedKit]()
				else
					vape:CreateNotification("AutoKit", "Your current kit is not supported yet!", 4, "warning")
					return
				end
			end
		end,
		Tooltip = 'Automatically uses kit abilities.'
	})
	Legit = AutoKit:CreateToggle({Name = 'Legit'})
end)

run(function()
    local OGTags
    local function create(Name,Values)
        local Obj = Instance.new(Name)
        for i, v in Values do
            Obj[i] = v
        end
        return Obj
    end
    local function CreateNameTag(plr)
		if plr.Character.Head:FindFirstChild("OldNameTags") then return end
			local OppositeTeamColor = Color3.fromRGB(255, 82, 82)
			local SameTeamColor = Color3.fromRGB(111, 255, 101)
			local billui = create("BillboardGui",{Name='OldNameTags',AlwaysOnTop=true,MaxDistance=150,Parent=plr.Character.Head,ResetOnSpawn=false,Size=UDim2.fromScale(5,0.65),StudsOffsetWorldSpace=Vector3.new(0,1.6,0),ZIndexBehavior='Global',Adornee=plr.Character.Head})
			local MainContainer = create("Frame",{Parent=billui,BackgroundTransparency=1,Position=UDim2.fromScale(-0.005,0),Size=UDim2.fromScale(1,1),Name='1'})
			local TeamCircle = create("Frame",{Name='2',Parent=MainContainer,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.15,BorderSizePixel=0,Position=UDim2.fromScale(0.11,0.16),Size=UDim2.fromScale(0.09,0.7)})
			create("UICorner",{Name='1',Parent=TeamCircle,CornerRadius=UDim.new(0, 25555)})
			local NameBG = create("Frame",{Name='1',Parent=MainContainer,BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.7,Position=UDim2.fromScale(0.25,0.1),Size=UDim2.fromScale(0.7,0.8)})
			local stroke = create('UIStroke',{Name='1',Parent=NameBG,Color=Color3.new(1,1,1),Thickness=1.5})
			local Txt = create("TextLabel",{Name='2',Parent=NameBG,BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(0.95,0.9),FontFace=Font.new('rbxasset://fonts/families/Arimo.json',Enum.FontWeight.SemiBold),Text='',TextColor3=Color3.new(1,1,1),TextScaled=true,TextWrapped=true})
			local NewName = ""
			if plr.DisplayName == "" or plr.DisplayName == plr.Name then
				NewName = plr.Name
			else
				NewName = plr.DisplayName
			end
			Txt.Text = NewName
			if plr.Character:GetAttribute('Team') == lplr.Character:GetAttribute('Team') then
				stroke.Color = SameTeamColor
				Txt.TextColor3 = SameTeamColor
			else
				stroke.Color = OppositeTeamColor
				Txt.TextColor3 = OppositeTeamColor
			end
			TeamCircle.BackgroundColor3 = Color3.new(plr.TeamColor.r,plr.TeamColor.g,plr.TeamColor.b)
		

    end
	local function RemoveTag(plr)
		if plr.Character.Head:FindFirstChild("OldNameTags") then
			plr.Character.Head:FindFirstChild("OldNameTags"):Destroy()
		else
			return
		end
	end
	local old = nil
	local old2 = nil
    OGTags = vape.Categories.Render:CreateModule({
        Name = "OgNameTags",
        Tooltip = 'changes everyones nametag to the OG(season 7 and before)(ty kolifyz for the idea)\nCLIENT ONLY',
        Function = function(callback)
            if callback then
				old = bedwars.NametagController.addGameNametag
				old2 = bedwars.NametagController.removeGameNametag
				for _, v in bedwars.AppController:getOpenApps() do
					if tostring(v):find('Nametag') then
						bedwars.AppController:closeApp(tostring(v))
					end
				end
				for i, v in playersService:GetPlayers() do
					CreateNameTag(v)
				end
				bedwars.NametagController.addGameNametag = function(v1,plr)
				for _, v in bedwars.AppController:getOpenApps() do
					if tostring(v):find('Nametag') then
						bedwars.AppController:closeApp(tostring(v))
					end
				end
					CreateNameTag(plr)
				end
				bedwars.NametagController.removeGameNametag = function(v1,plr)
					RemoveTag(plr)
				end
            else
				vape:CreateNotification("OgNameTags","Disabled next game!",5,"warning")
            end
        end
    })
end)


run(function()
    local RVSB
    RVSB = vape.Categories.Render:CreateModule({
        Name = "RedVsBlue",
        Tooltip = 'changes orange to red(mainly used for 5v5s)(ty kolifyz for the idea)\nCLIENT ONLY',
        Function = function(callback)
            if callback then
				local NewMaterial = Instance.new('MaterialVariant')
				NewMaterial.Parent = cloneref(game:GetService('MaterialService'))
				NewMaterial.Name = 'rbxassetid://16991768606'
				NewMaterial.ColorMap  = 'rbxassetid://16991768606'
				NewMaterial.StudsPerTile = 3
				NewMaterial.RoughnessMap = 'rbxassetid://16991768606'
				NewMaterial.BaseMaterial = 'Fabric'
				RVSB:Clean(blocks.ChildAdded:Connect(function(obj)
					if obj.Name == "wool_orange" then
						OldMaterial = obj.MaterialVariant
						oldColorBlock = obj.Color
						obj.MaterialVariant = "rbxassetid://16991768606"
						obj.Color = Color3.fromRGB(196, 40, 28) 
					end
				end))
				RVSB:Clean(workspace.ChildAdded:Connect(function(obj)
                    if obj.Name == "wool_orange" then
						OldMaterial = obj.MaterialVariant
						oldColorBlock = obj.Color
						obj.MaterialVariant = "rbxassetid://16991768606"
                        obj.Color = Color3.fromRGB(196, 40, 28) 
					end
				end))
            else
				for i, obj in workspace:GetDescendants() do
					if obj.Name == "wool_orange" then
						obj.MaterialVariant = OldMaterial
						obj.Color = oldColorBlock
						OldMaterial = nil
						oldColor = nil
					end
				end
            end
        end
    })
end)

run(function()
	local WoolChanger
	local oldTexture
	local oldColor
	local OldMaterial
	local oldColorBlock
	local oldColorBlockColor
	local oldWoolHotBar
	local color
	local Color = Color3.new(1,1,1)
	local GUIEdit 
	WoolChanger = vape.Categories.Blatant:CreateModule({
		Name = 'WoolChanger',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
				local function getWorldFolder()
					local Map = workspace:WaitForChild("Map", math.huge)
					local Worlds = Map:WaitForChild("Worlds", math.huge)
					if not Worlds then return nil end

					return Worlds:GetChildren()[1] 
				end
				local worldFolder = getWorldFolder()
				if not worldFolder then return end
				local blocks = worldFolder:WaitForChild("Blocks")
				local NewMaterial = Instance.new('MaterialVariant')
				NewMaterial.Parent = cloneref(game:GetService('MaterialService'))
				NewMaterial.Name = 'rbxassetid://16991768606'
				NewMaterial.ColorMap  = 'rbxassetid://16991768606'
				NewMaterial.StudsPerTile = 3
				NewMaterial.RoughnessMap = 'rbxassetid://16991768606'
				NewMaterial.BaseMaterial = 'Fabric'
				task.spawn(function()
					if not GUIEdit.Enabled then return end
					repeat 
						for i, v in lplr.PlayerGui.hotbar:GetDescendants() do
							if v:IsA("ImageLabel") then
								if v.Name == "1" then
									if v.Image == "rbxassetid://7923577182" or v.Image == "rbxassetid://7923577311" or v.Image == "rbxassetid://7923578297" or v.Image == "rbxassetid://7923578297" or v.Image == "rbxassetid://6765309820" or v.Image == "rbxassetid://7923579098" or v.Image == "rbxassetid://7923577655" or v.Image == "rbxassetid://7923579263" or v.Image == "rbxassetid://7923579520" or v.Image == "rbxassetid://7923578762" or v.Image == "rbxassetid://7923578533" or v.Image == "rbxassetid://15380238075" then
										oldColorBlock = v.Image
										oldColorBlockColor = v.ImageColor3
										v.Image = "rbxassetid://7923579263"
										v.ImageColor3 = Color
									end
								end
							end
						end
						task.wait(0.01)
					until not WoolChanger.Enabled or not GUIEdit.Enabled
				end)
				WoolChanger:Clean(gameCamera:FindFirstChild("Viewmodel").ChildAdded:Connect(function(obj)
					if string.find(obj.Name, "wool") then
						for i, texture in obj:FindFirstChild('Handle'):GetChildren() do
							if texture:IsA('Texture') then
								oldTexture = texture.Texture
								texture.Texture = "rbxassetid://16991768606"
								oldColor = texture.Color3
								texture.Color3 = Color
							end
						end
					end
				end))
				WoolChanger:Clean(blocks.ChildAdded:Connect(function(obj)
					if string.find(obj.Name, "wool") then
						if obj:GetAttribute("PlacedByUserId") == lplr.UserId then
							OldMaterial = obj.MaterialVariant
							oldColorBlock = obj.Color
							obj.MaterialVariant = "rbxassetid://16991768606"
							obj.Color = Color
						end
					end
				end))
				WoolChanger:Clean(workspace.ChildAdded:Connect(function(obj)
					if string.find(obj.Name, "wool") then
						if obj:GetAttribute("PlacedByUserId") == lplr.UserId then
							OldMaterial = obj.MaterialVariant
							oldColorBlock = obj.Color
							obj.MaterialVariant = "rbxassetid://16991768606"
							obj.Color = Color
						end
					end
				end))
				WoolChanger:Clean(lplr.Character.ChildAdded:Connect(function(obj)
					if string.find(obj.Name, "wool") then
						for i, texture in obj:FindFirstChild('Handle'):GetChildren() do
							if texture:IsA('Texture') then
								oldTexture = texture.Texture
								texture.Texture = "rbxassetid://16991768606"
								oldColor = texture.Color3
								texture.Color3 = Color
							end
						end
					end
				end))
            else
				for i, v in lplr.PlayerGui.hotbar:GetDescendants() do
					if v:IsA("ImageLabel") then
						if v.Name == "1" then
							if v.Image == "rbxassetid://7923579263" then
								v.Image = oldColorBlock
								v.ImageColor3 = oldColorBlockColor
								oldColorBlock = nil
								oldColorBlockColor = nil
							end
						end
					end
				end
				for i, obj in workspace:GetDescendants() do
					if string.find(obj.Name, "wool") then
						if obj:GetAttribute("PlacedByUserId") == lplr.UserId then
							obj.MaterialVariant = OldMaterial
							obj.Color = oldColorBlock
							OldMaterial = nil
							oldColor = nil
						end
					end
				end
			end
		end,
		Tooltip = 'Changes your blocks from a custom color(client only)'
	})
	color = WoolChanger:CreateColorSlider({
		Name = "Wool Color",
		Function = function(hue,sat,val)
			if WoolChanger.Enabled then
				local v1 = Color3.fromHSV(hue,sat,val)
				local R = math.floor(v1.R * 255)
				local G = math.floor(v1.G * 255)
				local B = math.floor(v1.B * 255)
				Color = Color3.fromRGB(R,G,B)
			end
		end
	})
	GUIEdit = WoolChanger:CreateToggle({
		Name = "Hotbar Edit",
		Tooltip = 'changer effects the hotbar lol',
		Default = false,
		Function = function(v)
			repeat 
				for i, v in lplr.PlayerGui.hotbar:GetDescendants() do
					if v:IsA("ImageLabel") then
						if v.Name == "1" then
							if v.Image == "rbxassetid://7923577182" or v.Image == "rbxassetid://7923577311" or v.Image == "rbxassetid://7923578297" or v.Image == "rbxassetid://7923578297" or v.Image == "rbxassetid://6765309820" or v.Image == "rbxassetid://7923579098" or v.Image == "rbxassetid://7923577655" or v.Image == "rbxassetid://7923579263" or v.Image == "rbxassetid://7923579520" or v.Image == "rbxassetid://7923578762" or v.Image == "rbxassetid://7923578533" or v.Image == "rbxassetid://15380238075" then
								oldColorBlock = v.Image
								oldColorBlockColor = v.ImageColor3
								v.Image = "rbxassetid://7923579263"
								v.ImageColor3 = Color
							end
						end
					end
				end
				task.wait(0.01)
			until not WoolChanger.Enabled or not v
		end
	})
end)

run(function()
	local RS 
	RS = vape.Categories.Legit:CreateModule({
		Name = "Stream Remover",
		Tooltip = 'this is client only, disables everyones streamer mode',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			if callback then
	
				old = bedwars.GamePlayer.canSeeThroughDisguise
				bedwars.GamePlayer.canSeeThroughDisguise = function()
					return true
				end
			else
				bedwars.GamePlayer.canSeeThroughDisguise = old
				old = nil	
			end
		end
	})
end)

run(function()
	local SynPA
	local SynPATargetPart
	local SynPATargets
	local SynPAFOV
	local SynPARange
	local SynPAOtherProjectiles
	local SynPABlacklist
	local SynPATargetVisualiser
	local SynPAHideCursor
	local SynPACursorViewMode
	local SynPACursorLimitBow
	local SynPACursorShowGUI
	local SynPAWorkMode
	local SynRayCheck = RaycastParams.new()
	SynRayCheck.FilterType = Enum.RaycastFilterType.Include
	SynRayCheck.FilterDescendantsInstances = {workspace:FindFirstChild('Map') or workspace}
	local SynOldFunction
	local SynSelectedTarget = nil
	local SynTargetOutline = nil
	local SynHovering = false
	local SynCoreConnections = {}
	local UserInputService = game:GetService("UserInputService")
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local cursorRenderConnection
	local lastGUIState = false
	
	local function isFirstPerson()
		if not (lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")) then 
			return false 
		end
		
		local characterPos = lplr.Character.HumanoidRootPart.Position
		local cameraPos = gameCamera.CFrame.Position
		local distance = (characterPos - cameraPos).Magnitude
		
		return distance < 5 
	end
	
	local function shouldPAWork()
		local inFirstPerson = isFirstPerson()
		
		if SynPAWorkMode.Value == 'First Person' then
			return inFirstPerson
		elseif SynPAWorkMode.Value == 'Third Person' then
			return not inFirstPerson
		elseif SynPAWorkMode.Value == 'Both' then
			return true
		end
		
		return true
	end
	
	local function isGUIOpen()
		local guiLayers = {
			bedwars.UILayers.MAIN or 'Main',
			bedwars.UILayers.DIALOG or 'Dialog',
			bedwars.UILayers.POPUP or 'Popup'
		}
		
		for _, layerName in pairs(guiLayers) do
			if bedwars.AppController:isLayerOpen(layerName) then
				return true
			end
		end
		
		if bedwars.AppController:isAppOpen('BedwarsItemShopApp') then
			return true
		end
		
		if bedwars.Store:getState().Inventory and bedwars.Store:getState().Inventory.open then
			return true
		end
		
		return false
	end
	
	local function hasBowEquipped()
		if not store.hand or not store.hand.toolType then
			return false
		end
		
		local toolType = store.hand.toolType
		return toolType == 'bow' or toolType == 'crossbow'
	end
	
	local function shouldHideCursor()
		if not SynPAHideCursor.Enabled then return false end
		
		if SynPACursorShowGUI.Enabled and isGUIOpen() then
			return false
		end
		
		if SynPACursorLimitBow.Enabled then
			if not hasBowEquipped() then
				return false
			end
		end
		
		local inFirstPerson = isFirstPerson()
		
		if SynPACursorViewMode.Value == 'First Person' then
			return inFirstPerson
		elseif SynPACursorViewMode.Value == 'Third Person' then
			return not inFirstPerson
		elseif SynPACursorViewMode.Value == 'Both' then
			return true
		end
		
		return false
	end
	
	local function updateCursor()
		if shouldHideCursor() then
			pcall(function()
				inputService.MouseIconEnabled = false
			end)
		else
			pcall(function()
				inputService.MouseIconEnabled = true
			end)
		end
	end
	
	local function checkGUIState()
		local currentGUIState = isGUIOpen()
		if lastGUIState ~= currentGUIState then
			updateCursor()
			lastGUIState = currentGUIState
		end
	end

	local function SynUpdateOutline(target)
		if SynTargetOutline then
			SynTargetOutline:Destroy()
			SynTargetOutline = nil
		end
		if target and SynPATargetVisualiser.Enabled then
			SynTargetOutline = Instance.new("Highlight")
			SynTargetOutline.FillTransparency = 1
			SynTargetOutline.OutlineColor = Color3.fromRGB(255, 0, 0)
			SynTargetOutline.OutlineTransparency = 0
			SynTargetOutline.Adornee = target.Character
			SynTargetOutline.Parent = target.Character
		end
	end

	local function SynHandlePlayerSelection()
		local function selectSynTarget(target)
			if not target then return end
			if target and target.Parent then
				local plr = playersService:GetPlayerFromCharacter(target.Parent)
				if plr then
					if SynSelectedTarget == plr then
						SynSelectedTarget = nil
						SynUpdateOutline(nil)
					else
						SynSelectedTarget = plr
						SynUpdateOutline(plr)
					end
				end
			end
		end
		
		local con
		if isMobile then
			con = UserInputService.TouchTapInWorld:Connect(function(touchPos)
				if not SynHovering then SynUpdateOutline(nil); return end
				if not SynPA.Enabled then pcall(function() con:Disconnect() end); SynUpdateOutline(nil); return end
				local ray = workspace.CurrentCamera:ScreenPointToRay(touchPos.X, touchPos.Y)
				local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
				if result and result.Instance then
					selectSynTarget(result.Instance)
				end
			end)
			table.insert(SynCoreConnections, con)
		end
	end
	if role ~= "owner" and  role ~= "coowner" and user ~= 'synioxzz'  then
		return 
	end
	SynPA = vape.Categories.Combat:CreateModule({
		Name = 'SynPA',
		Tooltip = "Thanks for Syn for giving me this script",
		Function = function(callback)
			if callback then
				if SynPAHideCursor.Enabled and not cursorRenderConnection then
					cursorRenderConnection = runService.RenderStepped:Connect(function()
						checkGUIState()
						updateCursor()
					end)
				end

				SynHandlePlayerSelection()
				
				SynOldFunction = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(...)
					SynHovering = true
					local self, projmeta, worldmeta, origin, shootpos = ...
					local originPos = entitylib.isAlive and (shootpos or entitylib.character.RootPart.Position) or Vector3.zero
					
					local plr
					if SynSelectedTarget and SynSelectedTarget.Character and SynSelectedTarget.Character.PrimaryPart and (SynSelectedTarget.Character.PrimaryPart.Position - originPos).Magnitude <= SynPARange.Value then
						plr = SynSelectedTarget
					else
						plr = entitylib.EntityMouse({
							Part = SynPATargetPart.Value,
							Range = SynPAFOV.Value,
							Players = SynPATargets.Players.Enabled,
							NPCs = SynPATargets.NPCs.Enabled,
							Wallcheck = SynPATargets.Walls.Enabled,
							Origin = originPos
						})
					end
					
					SynUpdateOutline(plr)
					
					if not shouldPAWork() then
						SynHovering = false
						return SynOldFunction(...)
					end
	
					if plr and plr.Character and plr[SynPATargetPart.Value] and (plr[SynPATargetPart.Value].Position - originPos).Magnitude <= SynPARange.Value then
						local pos = shootpos or self:getLaunchPosition(origin)
						if not pos then
							SynHovering = false
							return SynOldFunction(...)
						end
	
						if (not SynPAOtherProjectiles.Enabled) and not projmeta.projectile:find('arrow') then
							SynHovering = false
							return SynOldFunction(...)
						end

						if table.find(SynPABlacklist.ListEnabled, projmeta.projectile) then
							SynHovering = false
							return SynOldFunction(...)
						end
	
						local meta = projmeta:getProjectileMeta()
						local lifetime = (worldmeta and meta.predictionLifetimeSec or meta.lifetimeSec or 3)
						local gravity = (meta.gravitationalAcceleration or 196.2) * projmeta.gravityMultiplier
						local projSpeed = (meta.launchVelocity or 100)
						local offsetpos = pos + (projmeta.projectile == 'owl_projectile' and Vector3.zero or projmeta.fromPositionOffset)
						local balloons = plr.Character:GetAttribute('InflatedBalloons')
						local playerGravity = workspace.Gravity
	
						if balloons and balloons > 0 then
							playerGravity = workspace.Gravity * (1 - (balloons * 0.05))
						end
	
						if plr.Character and plr.Character.PrimaryPart and plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then
							playerGravity = 6
						end

						if plr.Player and plr.Player:GetAttribute('IsOwlTarget') then
							for _, owl in collectionService:GetTagged('Owl') do
								if owl:GetAttribute('Target') == plr.Player.UserId and owl:GetAttribute('Status') == 2 then
									playerGravity = 0
									break
								end
							end
						end

						local predictedPosition = prediction.predictStrafingMovement(
							plr.Player, 
							plr[SynPATargetPart.Value], 
							projSpeed, 
							gravity,
							offsetpos
						)
						
						local distance = (plr[SynPATargetPart.Value].Position - offsetpos).Magnitude
						local rawLook = CFrame.new(offsetpos, plr[SynPATargetPart.Value].Position)
						
						local smoothnessFactor = 0.85
						if distance > 70 then
							smoothnessFactor = 0.75
						elseif distance > 40 then
							smoothnessFactor = 0.80
						elseif distance < 20 then
							smoothnessFactor = 0.92
						end
						
						local smoothLook = rawLook:Lerp(CFrame.new(rawLook.Position, predictedPosition), smoothnessFactor)
						
						if projmeta.projectile ~= 'owl_projectile' then
							smoothLook = smoothLook * CFrame.new(
								bedwars.BowConstantsTable.RelX or 0,
								bedwars.BowConstantsTable.RelY or 0,
								bedwars.BowConstantsTable.RelZ or 0
							)
						end

						local targetVelocity = projmeta.projectile == 'telepearl' and Vector3.zero or plr[SynPATargetPart.Value].Velocity
						
						local calc = prediction.SolveTrajectory(
							smoothLook.p, 
							projSpeed, 
							gravity, 
							predictedPosition, 
							targetVelocity, 
							playerGravity, 
							plr.HipHeight, 
							plr.Jumping and 50 or nil,
							SynRayCheck
						)
						
						if calc then
							local finalDirection = (calc - smoothLook.p).Unit
							local angleFromHorizontal = math.acos(math.clamp(finalDirection:Dot(Vector3.new(0, 1, 0)), -1, 1))
							
							local minAngle = math.rad(1)
							local maxAngle = math.rad(179)
							
							if angleFromHorizontal > minAngle and angleFromHorizontal < maxAngle then
								targetinfo.Targets[plr] = tick() + 1
								SynHovering = false
								return {
									initialVelocity = finalDirection * projSpeed,
									positionFrom = offsetpos,
									deltaT = lifetime,
									gravitationalAcceleration = gravity,
									drawDurationSeconds = 5
								}
							end
						end
					end
	
					SynHovering = false
					return SynOldFunction(...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = SynOldFunction
				if SynTargetOutline then
					SynTargetOutline:Destroy()
					SynTargetOutline = nil
				end
				SynSelectedTarget = nil
				for i,v in pairs(SynCoreConnections) do
					pcall(function() v:Disconnect() end)
				end
				table.clear(SynCoreConnections)
				
				if cursorRenderConnection then
					cursorRenderConnection:Disconnect()
					cursorRenderConnection = nil
				end
				
				pcall(function()
					inputService.MouseIconEnabled = true
				end)
			end
		end,
	})
	
	SynPATargets = SynPA:CreateTargets({
		Players = true,
		Walls = true
	})
	SynPATargetPart = SynPA:CreateDropdown({
		Name = 'Part',
		List = {'RootPart', 'Head'}
	})
	SynPAFOV = SynPA:CreateSlider({
		Name = 'FOV',
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	SynPARange = SynPA:CreateSlider({
		Name = 'Range',
		Min = 10,
		Max = 500,
		Default = 100
	})
	SynPAWorkMode = SynPA:CreateDropdown({
		Name = 'PA Work Mode',
		List = {'First Person', 'Third Person', 'Both'},
		Default = 'Both'
	})
	SynPATargetVisualiser = SynPA:CreateToggle({
		Name = "Target Visualiser", 
		Default = true
	})
	SynPAOtherProjectiles = SynPA:CreateToggle({
		Name = 'Other Projectiles',
		Default = true,
		Function = function(call)
			if SynPABlacklist then
				SynPABlacklist.Object.Visible = call
			end
		end
	})
	SynPABlacklist = SynPA:CreateTextList({
		Name = 'Blacklist',
		Darker = true,
		Default = {'telepearl'}
	})
	
	SynPAHideCursor = SynPA:CreateToggle({
		Name = 'Hide Cursor',
		Default = false,
		Function = function(callback)
			if callback and SynPA.Enabled then
				if not cursorRenderConnection then
					cursorRenderConnection = runService.RenderStepped:Connect(function()
						checkGUIState()
						updateCursor()
					end)
				end
				updateCursor()
			else
				if cursorRenderConnection then
					cursorRenderConnection:Disconnect()
					cursorRenderConnection = nil
				end
				pcall(function()
					inputService.MouseIconEnabled = true
				end)
			end
		end
	})
	
	SynPACursorViewMode = SynPA:CreateDropdown({
		Name = 'Cursor View Mode',
		List = {'First Person', 'Third Person', 'Both'},
		Default = 'First Person',
		Darker = true,
		Function = function()
			if SynPA.Enabled and SynPAHideCursor.Enabled then
				updateCursor()
			end
		end
	})
	
	SynPACursorLimitBow = SynPA:CreateToggle({
		Name = 'Limit to Bow',
		Darker = true,
		Function = function()
			if SynPA.Enabled and SynPAHideCursor.Enabled then
				updateCursor()
			end
		end
	})
	
	SynPACursorShowGUI = SynPA:CreateToggle({
		Name = 'Show on GUI',
		Darker = true,
		Function = function()
			if SynPA.Enabled and SynPAHideCursor.Enabled then
				updateCursor()
			end
		end
	})
	
	vape:Clean(vapeEvents.InventoryChanged.Event:Connect(function()
		if SynPA.Enabled and SynPAHideCursor.Enabled then
			updateCursor()
		end
	end))
end)

run(function()
	local CyanPA
	local CyanPATargetPart
	local CyanPATargets
	local CyanPAFOV
	local CyanPARange
	local CyanPAOtherProjectiles
	local CyanPABlacklist
	local CyanPATargetVisualiser
	local CyanPAWorkMode
	local CyanRayCheck = RaycastParams.new()
	CyanRayCheck.FilterType = Enum.RaycastFilterType.Include
	CyanRayCheck.FilterDescendantsInstances = {workspace:FindFirstChild('Map') or workspace}
	local CyanOldFunction
	local CyanSelectedTarget = nil
	local CyanTargetOutline = nil
	local CyanHovering = false
	local CyanCoreConnections = {}
	local UserInputService = game:GetService("UserInputService")
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	local function isFirstPerson()
		if not (lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")) then 
			return false 
		end
		return (lplr.Character.HumanoidRootPart.Position - gameCamera.CFrame.Position).Magnitude < 5
	end
	
	local function shouldPAWork()
		local fp = isFirstPerson()
		if CyanPAWorkMode.Value == 'First Person' then
			return fp
		elseif CyanPAWorkMode.Value == 'Third Person' then
			return not fp
		end
		return true
	end

	local function CyanUpdateOutline(target)
		if CyanTargetOutline then
			CyanTargetOutline:Destroy()
			CyanTargetOutline = nil
		end
		if target and CyanPATargetVisualiser.Enabled then
			CyanTargetOutline = Instance.new("Highlight")
			CyanTargetOutline.FillTransparency = 1
			CyanTargetOutline.OutlineColor = Color3.fromRGB(255, 0, 0)
			CyanTargetOutline.OutlineTransparency = 0
			CyanTargetOutline.Adornee = target.Character
			CyanTargetOutline.Parent = target.Character
		end
	end

	local function CyanHandlePlayerSelection()
		if not isMobile then return end

		local con
		con = UserInputService.TouchTapInWorld:Connect(function(touchPos)
			if not CyanHovering then CyanUpdateOutline(nil); return end
			if not CyanPA.Enabled then pcall(function() con:Disconnect() end); CyanUpdateOutline(nil); return end

			local ray = workspace.CurrentCamera:ScreenPointToRay(touchPos.X, touchPos.Y)
			local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
			if result and result.Instance then
				local plr = playersService:GetPlayerFromCharacter(result.Instance.Parent)
				if plr then
					CyanSelectedTarget = (CyanSelectedTarget == plr and nil or plr)
					CyanUpdateOutline(CyanSelectedTarget)
				end
			end
		end)

		table.insert(CyanCoreConnections, con)
	end

	if role ~= "owner" and role ~= "coowner" and user ~= 'generalcyan' then
		return 
	end

	CyanPA = vape.Categories.Combat:CreateModule({
		Name = 'CyanPA',
		Tooltip = "Cyan PA from syn",
		Function = function(callback)
			if callback then
				CyanHandlePlayerSelection()

				CyanOldFunction = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(...)
					CyanHovering = true
					local self, projmeta, worldmeta, origin, shootpos = ...
					local originPos = entitylib.isAlive and (shootpos or entitylib.character.RootPart.Position) or Vector3.zero

					local plr
					if CyanSelectedTarget
						and CyanSelectedTarget.Character
						and CyanSelectedTarget.Character.PrimaryPart
						and (CyanSelectedTarget.Character.PrimaryPart.Position - originPos).Magnitude <= CyanPARange.Value then
						plr = CyanSelectedTarget
					else
						plr = entitylib.EntityMouse({
							Part = CyanPATargetPart.Value,
							Range = CyanPAFOV.Value,
							Players = CyanPATargets.Players.Enabled,
							NPCs = CyanPATargets.NPCs.Enabled,
							Walls = CyanPATargets.Walls.Enabled,
							Origin = originPos
						})
					end

					CyanUpdateOutline(plr)

					if not shouldPAWork() then
						CyanHovering = false
						return CyanOldFunction(...)
					end

					if plr and plr.Character and plr[CyanPATargetPart.Value]
						and (plr[CyanPATargetPart.Value].Position - originPos).Magnitude <= CyanPARange.Value then

						if not CyanPAOtherProjectiles.Enabled and not projmeta.projectile:find('arrow') then
							CyanHovering = false
							return CyanOldFunction(...)
						end

						if table.find(CyanPABlacklist.ListEnabled, projmeta.projectile) then
							CyanHovering = false
							return CyanOldFunction(...)
						end

						local meta = projmeta:getProjectileMeta()
						local gravity = (meta.gravitationalAcceleration or 196.2) * projmeta.gravityMultiplier
						local speed = meta.launchVelocity or 100
						local from = shootpos or self:getLaunchPosition(origin)

						local predicted = prediction.predictStrafingMovement(
							plr.Player,
							plr[CyanPATargetPart.Value],
							speed,
							gravity,
							from
						)

						local calc = prediction.SolveTrajectory(
							from,
							speed,
							gravity,
							predicted,
							plr[CyanPATargetPart.Value].Velocity,
							workspace.Gravity,
							plr.HipHeight,
							nil,
							CyanRayCheck
						)

						if calc then
							local dir = (calc - from).Unit
							CyanHovering = false
							return {
								initialVelocity = dir * speed,
								positionFrom = from,
								deltaT = meta.lifetimeSec or 3,
								gravitationalAcceleration = gravity,
								drawDurationSeconds = 5
							}
						end
					end

					CyanHovering = false
					return CyanOldFunction(...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = CyanOldFunction
				CyanUpdateOutline(nil)
				CyanSelectedTarget = nil

				for _, v in pairs(CyanCoreConnections) do
					pcall(function() v:Disconnect() end)
				end
				table.clear(CyanCoreConnections)
			end
		end,
	})

	CyanPATargets = CyanPA:CreateTargets({
		Players = true,
		Walls = true
	})

	CyanPATargetPart = CyanPA:CreateDropdown({
		Name = 'Part',
		List = {'RootPart', 'Head'}
	})

	CyanPAFOV = CyanPA:CreateSlider({
		Name = 'FOV',
		Min = 1,
		Max = 1000,
		Default = 1000
	})

	CyanPARange = CyanPA:CreateSlider({
		Name = 'Range',
		Min = 10,
		Max = 500,
		Default = 100
	})

	CyanPAWorkMode = CyanPA:CreateDropdown({
		Name = 'PA Work Mode',
		List = {'First Person', 'Third Person', 'Both'},
		Default = 'Both'
	})

	CyanPATargetVisualiser = CyanPA:CreateToggle({
		Name = "Target Visualiser",
		Default = true
	})

	CyanPAOtherProjectiles = CyanPA:CreateToggle({
		Name = 'Other Projectiles',
		Default = true
	})

	CyanPABlacklist = CyanPA:CreateTextList({
		Name = 'Blacklist',
		Darker = true,
		Default = {'telepearl'}
	})
end)

run(function()
    local VanessaCharger    
    local old
	local old2
    local lastChargeTime = 0
    
    VanessaCharger = vape.Categories.Blatant:CreateModule({
        Name = 'VanessaCharger',
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
            if callback then
                old = bedwars.TripleShotProjectileController.getChargeTime
                bedwars.TripleShotProjectileController.getChargeTime = function(self)
                	local OldNow = tick()
                    local delayAmount = 0
                    if OldNow - lastChargeTime < delayAmount then
                        return oldGetChargeTime(self)
                    end
                            
                    lastChargeTime = currentTime
                    return 0
                end
				old2 = bedwars.TripleShotProjectileController.overchargeStartTime
                bedwars.TripleShotProjectileController.overchargeStartTime = tick()
            else
				bedwars.TripleShotProjectileController.overchargeStartTime = old2
                bedwars.TripleShotProjectileController.getChargeTime = old
                lastChargeTime = 0
				old = nil
				old2 = nil
            end
        end,
        Tooltip = 'Auto charges Vanessa to triple shot instantly'
    })
    
end)

run(function()
	local BetterMetal
	local Delay
	local Animation
	local Distance
	local Limits
	local Legit
	BetterMetal = vape.Categories.Support:CreateModule({
		Name = "BetterMetal",
		Tooltip = 'makes you play like bobcat at metal or any1 whos good(js naming sm1 i know who mains metal)',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end 
			task.spawn(function()
				while BetterMetal.Enabled do
					if not entitylib.isAlive then task.wait(0.1); continue end
					local character = entitylib.character
					if not character or not character.RootPart then task.wait(0.1); continue end
					local tool = (store and store.hand and store.hand.tool) and store.hand.tool or nil
					if not tool or tool.Name ~= "metal_detector" then task.wait(0.5); continue end
					local localPos = character.RootPart.Position
					local metals = collectionService:GetTagged("hidden-metal")
					for _, obj in pairs(metals) do
						if obj:IsA("Model") and obj.PrimaryPart then
							local metalPos = obj.PrimaryPart.Position
							local distance = (localPos - metalPos).Magnitude
							local range = Legit.Enabled and 10 or (Distance.Value or 8)
							if distance <= range then
								local waitTime = Legit.Enabled and .854 or (1 / (Delay.GetRandomValue and Delay:GetRandomValue() or 1))
								task.wait(waitTime)
								if Legit.Enabled or Animation.Enabled then
									bedwars.GameAnimationUtil:playAnimation(lplr, bedwars.AnimationType.SHOVEL_DIG)
									bedwars.SoundManager:playSound(bedwars.SoundList.SNAP_TRAP_CONSUME_MARK)
								end
								pcall(function()
									bedwars.Client:Get('CollectCollectableEntity'):SendToServer({id = obj:GetAttribute("Id")})
								end)
								task.wait(0.1)
							end
						end
					end
					task.wait(0.1)
				end
			end)
		end
	})
	Limits = BetterMetal:CreateToggle({Name='Limit To Item',Default=false})
	Distance = BetterMetal:CreateSlider({Name='Range',Min=6,Max=12,Default=8})
	Delay = BetterMetal:CreateTwoSlider({
		Name = "Delay",
		Min = 0,
		Max = 2,
		DefaultMin = 0.4,
		DefaultMax = 1,
		Suffix = 's',
        Decimal = 10,	
	})
	Animation = BetterMetal:CreateToggle({Name='Animations',Default=true})
	Legit = BetterMetal:CreateToggle({
		Name='Legit',
		Default=true,
		Darker=true,
		Function = function(v)
			Animation.Object.Visible = (not v)
			Delay.Object.Visible = (not v)
			Distance.Object.Visible = (not v)
			Limits.Object.Visible = (not v)
		end
	})

end)

run(function()
	local BetterRamil
	local Distance
	local Sorts
	local Angle
	local MaxTargets
	local Targets
	local MovingTornadoDistance
	local UseTornandos
	BetterRamil = vape.Categories.Support:CreateModule({
		Name = "BetterRamil",
		Tooltip = 'makes you play like me at ramil(i like ramil)',
		Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" and role ~= "premium" and role ~= "user" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end
			if callback then
				repeat
		            local plrs = entitylib.AllPosition({
		                Range = AttackRange.Value,
		                Wallcheck = Targets.Walls.Enabled,
		                Part = "RootPart",
		                Players = Targets.Players.Enabled,
		                NPCs = Targets.NPCs.Enabled,
		                Limit = MaxTargets.Value,
		                Sort = sortmethods[Sorts.Value]
		            })
					local castplrs = nil

					if UseTornandos.Enabled then
						castplrs = entitylib.AllPosition({
							Range = MovingTornadoDistance.Value,
							Wallcheck = Targets.Walls.Enabled,
							Part = "RootPart",
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = MaxTargets.Value,
							Sort = sortmethods[Sorts.Value]
		            	})
					end
		
		            local char = entitylib.character
		            local root = char.RootPart
		
		            if plrs then
		                local ent = plrs[1]
		                if ent and ent.RootPart then
		                    local delta = ent.RootPart.Position - root.Position
		                    local localFacing = root.CFrame.LookVector * Vector3.new(1, 0, 1)
		                    local angle = math.acos(localFacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
		                    if angle > (math.rad(Angle.Value) / 2) then continue end
							if bedwars.AbilityController:canUseAbility('airbender_tornado') then
								bedwars.AbilityController:useAbility('airbender_tornado')
							end
		                end
		            end
					if castplrs then
		                local ent = plrs[1]
		                if ent and ent.RootPart then
							if UseTornandos.Enabled then
								if bedwars.AbilityController:canUseAbility('airbender_moving_tornado') then
									bedwars.AbilityController:useAbility('airbender_moving_tornado')
								end
							end
						end
					end
					task.wait(0.2)
				until not BetterRamil.Enabled
			end


		end
	})
	Targets = BetterRamil:CreateTargets({Players = true,NPCs = false,Walls = true})
    Angle = BetterRamil:CreateSlider({
        Name = "Angle",
        Min = 0,
        Max = 360,
        Default = 180
    })
	Sorts = BetterRamil:CreateDropdown({
		Name = "Sorts",
		List = {'Damage','Threat','Kit','Health','Angle'}
	})
	MaxTargets = BetterRamil:CreateSlider({
		Name = "Max Targets",
		Min = 1,
		Max = 3,
		Default = 2
	})
	Distance = BetterRamil:CreateSlider({
		Name = "Distance",
		Min = 1,
		Max = 25,
		Default = 18,
		Suffix = function(v)
			if v <= 1 then
				return 'stud'
			else
				return 'studs'
			end
		end
	})
	MovingTornadoDistance = BetterRamil:CreateSlider({
		Name = "Tornado Distance",
		Min = 1,
		Max = 31,
		Default = 18,
		Suffix = function(v)
			if v <= 1 then
				return 'stud'
			else
				return 'studs'
			end
		end
	})
	UseTornandos = BetterRamil:CreateToggle({Name='Use Moving Tornado\'s',Default=false,Function=function(v) MovingTornadoDistance.Object.Visible = v end})
end)

run(function()
    local PositionRaper
    local Delay = {Value = 1250}
    local TransmissionOffset = {Value = 25}
    local originalRemotes = {}
    local queuedCalls = {}
    local isProcessing = false
    local callInterception = {}
    
    local function backupRemoteMethods()
        if not bedwars or not bedwars.Client then return end
        
        local oldGet = bedwars.Client.Get
        callInterception.oldGet = oldGet
        
        for name, path in pairs(remotes) do
            local remote = oldGet(bedwars.Client, path)
            if remote and remote.SendToServer then
                originalRemotes[path] = remote.SendToServer
            end
        end
    end
    
    local function processDelayedCalls()
        if isProcessing then return end
        isProcessing = true
        
        task.spawn(function()
            while PositionRaper.Enabled and #queuedCalls > 0 do
                local currentTime = tick()
                local toExecute = {}
                
                for i = #queuedCalls, 1, -1 do
                    local call = queuedCalls[i]
                    if currentTime >= call.executeTime then
                        table.insert(toExecute, 1, call)
                        table.remove(queuedCalls, i)
                    end
                end
                
                for _, call in ipairs(toExecute) do
                    pcall(function()
                        if call.remote and call.method == "FireServer" then
                            call.remote:FireServer(unpack(call.args))
                        elseif call.remote and call.method == "InvokeServer" then
                            call.remote:InvokeServer(unpack(call.args))
                        elseif call.originalFunc then
                            call.originalFunc(call.remote, unpack(call.args))
                        end
                    end)
                end
                
                task.wait(0.001)
            end
            isProcessing = false
        end)
    end
    
    local function queueRemoteCall(remote, method, originalFunc, ...)
        local currentDelay = Delay.Value
            if entitylib.isAlive then
                local nearestDist = math.huge
                for _, entity in ipairs(entitylib.List) do
                    if entity.Targetable and entity.Player and entity.Player ~= lplr then
                        local dist = (entity.RootPart.Position - entitylib.character.RootPart.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                        end
                    end
                end
                
                if nearestDist < 15 then
                    local repelFactor = (15 - nearestDist) / 15
                    currentDelay = currentDelay * (1 + (repelFactor * 2))
                end
            end
        
        if TransmissionOffset.Value > 0 then
            local jitter = math.random(-TransmissionOffset.Value, TransmissionOffset.Value)
            currentDelay = math.max(0, currentDelay + jitter)
        end
        
        table.insert(queuedCalls, {
            remote = remote,
            method = method,
            originalFunc = originalFunc,
            args = {...},
            executeTime = tick() + (currentDelay / 1000)
        })
        
        processDelayedCalls()
    end
    
    local function interceptRemotes()
        if not bedwars or not bedwars.Client then return end
        
        local oldGet = callInterception.oldGet
        bedwars.Client.Get = function(self, remotePath)
            local remote = oldGet(self, remotePath)
            
            if remote and remote.SendToServer then
                local originalSend = remote.SendToServer
                remote.SendToServer = function(self, ...)
                    if PositionRaper.Enabled and Delay.Value > 0 then
                        queueRemoteCall(self, "SendToServer", originalSend, ...)
                        return
                    end
                    return originalSend(self, ...)
                end
            end
            
            return remote
        end
        
        local function interceptSpecificRemote(path)
            local remote = oldGet(bedwars.Client, path)
            if remote and remote.FireServer then
                local originalFire = remote.FireServer
                remote.FireServer = function(self, ...)
                    if PositionRaper.Enabled and Delay.Value > 0 then
                        queueRemoteCall(self, "FireServer", originalFire, ...)
                        return
                    end
                    return originalFire(self, ...)
                end
            end
        end
        
        if remotes.AttackEntity then interceptSpecificRemote(remotes.AttackEntity) end
        if remotes.PlaceBlockEvent then interceptSpecificRemote(remotes.PlaceBlockEvent) end
        if remotes.BreakBlockEvent then interceptSpecificRemote(remotes.BreakBlockEvent) end
    end
    
    PositionRaper = vape.Categories.World:CreateModule({
        Name = 'PositionRaper',
        Function = function(callback)
   			if role ~= "owner" and role ~= "coowner" and role ~= "admin" and role ~= "friend" then
				vape:CreateNotification("Onyx", "You do not have permission to use this", 10, "alert")
				return
			end
            if callback then
                backupRemoteMethods()
                interceptRemotes()
                
            else
                if bedwars and bedwars.Client and callInterception.oldGet then
                    bedwars.Client.Get = callInterception.oldGet
                end
                
                for _, call in ipairs(queuedCalls) do
                    pcall(function()
                        if call.originalFunc then
                            call.originalFunc(call.remote, unpack(call.args))
                        end
                    end)
                end
                table.clear(queuedCalls)
            end
        end,
        Tooltip = 'real position raper!?'

    })
end)

run(function()
	local LLPinger
	local T
	local old
	local old2
	local inf = math.huge or 9e9
	task.spawn(function()
		math.randomseed(os.time() * 1e9)
		local num = math.floor(math.random(0,50) - math.random(1,5) - math.random())
		if num < 0 then
			num = 0
		end
	end)
	LLPinger = vape.Categories.Exploits:CreateModule({
		Name = "LifelessPinger",
		Tooltip = 'changes how long a ping will be',
		Function = function(callback)
			if callback then
				old = bedwars.SharedConstants.PingConstants.PING_LIFETIME
				bedwars.SharedConstants.PingConstants.PING_LIFETIME = T.Value == 0 and inf or T.Value
			else
				bedwars.SharedConstants.PingConstants.PING_LIFETIME = old
				old = nil
			end
		end
	})
	T = LLPinger:CreateSlider({
		Name = "Time",
		Tooltip = "0 = infinity, this changes how long a ping should last",
		Min = 0,
		Max = 50,
		Default = num
	})
end)

run(function()
	local PingCDRemover
	local T
	local old
	local old2
	local inf = math.huge or 9e9
	task.spawn(function()
		math.randomseed(os.time() * 1e6)
		local num = math.floor(math.random(0,15) - math.random(1,2) - math.random())
		if num < 0 then
			num = 0
		end
	end)
	PingCDRemover = vape.Categories.Exploits:CreateModule({
		Name = "PingCDRemover",
		Tooltip = 'changes the cooldown of a ping',
		Function = function(callback)
			if callback then
				old = bedwars.SharedConstants.PingConstants.PING_COOLDOWN
				bedwars.SharedConstants.PingConstants.PING_COOLDOWN = T.Value == 0 and inf or T.Value
			else
				bedwars.SharedConstants.PingConstants.PING_COOLDOWN = old
				old = nil
			end
		end
	})
	T = PingCDRemover:CreateSlider({
		Name = "CD",
		Min = 0,
		Max = 15,
		Default = num
	})
end)
run(function()
	local ClientEffects
	local Victorious
	local old
	local old2
	ClientEffects = vape.Categories.Render:CreateModule({
		Name = "ClientEffects",
		Tooltip = "allows you to use victorious sound sfx for some kits",
		Function = function(callback)
			if callback then
				if store.equippedKit == "davey" then
					task.spawn(function()
						if Victorious.Value == "Gold" then
							Sound = 'CANNON_FIRE_VICTORIOUS_GOLD'
						end
						if Victorious.Value == "Platinum" then
							Sound = 'CANNON_FIRE_VICTORIOUS_PLATINUM'
						end
						if Victorious.Value == "Diamond" then
							Sound = 'CANNON_FIRE_VICTORIOUS_DIAMOND'
						end
						if Victorious.Value == "Emerald" then
							Sound = 'CANNON_FIRE_VICTORIOUS_EMERALD'
						end
						if Victorious.Value == "Nightmare" then
							Sound = 'CANNON_FIRE_VICTORIOUS_NIGHTMARE'
						end
						old = bedwars.CannonHandController.launchSelf
						old2 = bedwars.CannonHandController.fireCannon
					end)
					bedwars.CannonHandController.fireCannon = function(...)
						for _, v in workspace:FindFirstChild('SoundPool'):GetChildren() do
							if v:IsA('Sound') then
								if v.SoundId == "rbxassetid://7121064180" then
									v:Destroy()
								end
							end
						end
						bedwars.SoundManager:playSound(bedwars.SoundList[Sound])
						return old2(...)
					end
					bedwars.CannonHandController.launchSelf = function(...)
						for _, v in workspace:FindFirstChild('SoundPool'):GetChildren() do
							if v:IsA('Sound') then
								if v.SoundId == "rbxassetid://7121064180" then
									v:Destroy()
								end
							end
						end
						bedwars.SoundManager:playSound(bedwars.SoundList[Sound])
						return old(...)
					end
				end
			else
				if store.equippedKit == "davey" then
					bedwars.CannonHandController.launchSelf = old
					bedwars.CannonHandController.fireCannon = old2
					old = nil
					old2 = nil
				end

			end
		end
	})
	Victorious = ClientEffects:CreateDropdown({
		Name = "Victorious",
		List = {'Nightmare','Emerald','Diamond','Platinum','Gold'}
	})
end)
