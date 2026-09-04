local Version = "1.6.66"
local success, windUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()
end)

if not success or not windUI then
    warn("⚠️ UI failed to load!")
    return
else
    print("✓ UI loaded successfully!")
end

local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playersService.LocalPlayer
local virtualUserService = game:GetService("VirtualUser")
local replicatedStorage = game:GetService("ReplicatedStorage")
local lightingService = game:GetService("Lighting")
local tweenService = game:GetService("TweenService")

local remotesRoot = replicatedStorage:WaitForChild("Remote")
local clickRemote = remotesRoot.Event.Level:WaitForChild("[C-S]Click")
local rebirthRemote = remotesRoot.Event.Rebirth:WaitForChild("[C - S]TryRebirth")
local buyCashPumpRemote = remotesRoot.Event.Pump:WaitForChild("[C-S]BuyCashPump")
local buyCashUpgradeRemote = remotesRoot.Event.Upgrade:WaitForChild("[C-S]BuyCashUpgrade")
local sellAllFishRemote = remotesRoot.Function.Fish:WaitForChild("[C-S]SellAllFish")
local sellFishRemote = remotesRoot.Function.Fish:WaitForChild("[C-S]SellFish")
local getFishDataRemote = remotesRoot.Function.Fish:WaitForChild("[C-S]GetFishData")
local equipBestPetRemote = remotesRoot.Event.Pet:WaitForChild("EquipBest")
local getStageStateRemote = remotesRoot.Function.Stage:WaitForChild("[C-S]GetStageState")
local requestCashTeleportRemote = remotesRoot.Event.Teleport:WaitForChild("[C-S]RequestCashTeleport")
local openEggRemote = remotesRoot.Function.Egg:WaitForChild("[C-S]OpenEgg")

local pumpHelper = require(replicatedStorage.Config.PumpHelper)
local upgradeHelper = require(replicatedStorage.Config.UpgradeHelper)
local eggHelper = require(replicatedStorage.Config.EggHelper)

local Window = windUI:CreateWindow({
	Title = "Yolk Hub",
	Icon = "rbxassetid://102847073936864",
	Author = "By Shoyo",
	Folder = "YolkHub",
	Size = UDim2.fromOffset(280, 320),
	Transparent = false,
	Theme = "Mellowsi",
	SideBarWidth = 170,
	ScrollBarEnabled = true,
	HideSearchBar = false,
	NewElements = true,
	Resizable = true,
	Acrylic = false,
	HidePanelBackground = false,
	Radius = 16,
	ElementsRadius = 12,
	ShadowTransparency = 1,
	BackgroundImageTransparency = 1,
    User = {
        Enabled = true,
    },
	Topbar = {
		Height = 40,
		ButtonsType = "Mac",
	},
})

Window:Tag({
	Title = "+1 Drain Water",
	Color = Color3.fromHex("#F5C76A"),
})

local Tabs = {
	Main = Window:Tab({
		Title = "Main",
		Icon = "house",
		IconColor = Color3.fromHex("#7CF3D0"),
		Border = true,
		Opened = true,
	}),
	Player = Window:Tab({
		Title = "Player",
		Icon = "footprints",
		IconColor = Color3.fromHex("#9ED4FF"),
		Border = true,
	}),
	Farm = Window:Tab({
		Title = "Farm",
		Icon = "trophy",
		IconColor = Color3.fromHex("#F8C97A"),
		Border = true,
	}),
	Pets = Window:Tab({
		Title = "Pets",
		Icon = "paw-print",
		IconColor = Color3.fromHex("#D4C4F9"),
		Border = true,
	}),
	Fisch = Window:Tab({
		Title = "Fisch",
		Icon = "fish",
		IconColor = Color3.fromHex("#8FE8D8"),
		Border = true,
	}),
	Shop = Window:Tab({
		Title = "Shop",
		Icon = "shopping-cart",
		IconColor = Color3.fromHex("#A9F5B3"),
		Border = true,
	}),
	Settings = Window:Tab({
		Title = "Settings",
		Icon = "settings",
		IconColor = Color3.fromHex("#D9C6FF"),
		Border = true,
	}),
}

Tabs.Main:Paragraph({
	Title = "Yolk Hub Info",
	Desc = "The script is in its test phases, if you see any option that doesn't work well or isn't working, I recommend joining the script's support server to stay updated on new options and new scripts.",
	Image = "info",
	ImageSize = 20,
	Color = Color3.fromHex("#8FE8D8"),
})

Tabs.Main:Paragraph({
	Title = "Credits",
	Desc = "Developed by Potent for the Potent community.",
	Image = "code",
	ImageSize = 20,
	Color = Color3.fromHex("#F8D78A"),
})

local linksSection = Tabs.Main:Section({
	Title = "Support",
	Icon = "messages-square",
	IconColor = Color3.fromHex("#8FE8D8"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})

linksSection:Button({
	Title = "Discord",
	Desc = "Join our support server and report any errors to us",
	Icon = "message-circle",
	Callback = function()
		setclipboard("https://discord.gg/tu-invite")
		windUI:Notify({ Title = "Potassium", Content = "Discord link copied", Duration = 1 })
	end,
})

linksSection:Button({
	Title = "YouTube",
	Desc = "Showcases of all the scripts",
	Icon = "youtube",
	Callback = function()
		setclipboard("https://youtube.com/@tu-canal")
		windUI:Notify({ Title = "Potassium", Content = "YouTube link copied", Duration = 1 })
	end,
})

local function getHumanoid()
	local character = localPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function getHrp()
	local character = localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------------------------------------
-- Player tab.
--------------------------------------------------------------------------------

local movementSection = Tabs.Player:Section({
	Title = "Movement",
	Icon = "move-horizontal",
	IconColor = Color3.fromHex("#C7D2F2"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})

local walkSpeedValue = 16
movementSection:Slider({
	Title = "WalkSpeed",
	Icon = "gauge",
	Value = { Min = 16, Max = 200, Default = 16 },
	Callback = function(value)
		walkSpeedValue = value
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.WalkSpeed = value
		end
	end,
})

local jumpPowerValue = 50
movementSection:Slider({
	Title = "JumpPower",
	Desc = "Jump height",
	Icon = "arrow-up",
	Value = { Min = 50, Max = 300, Default = 50 },
	Callback = function(value)
		jumpPowerValue = value
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.JumpPower = value
		end
	end,
})

localPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = walkSpeedValue
	humanoid.JumpPower = jumpPowerValue
end)

--------------------------------------------------------------------------------
-- Farm tab.
--------------------------------------------------------------------------------

local clickSection = Tabs.Farm:Section({
	Title = "Auto Click",
	Icon = "mouse-pointer-click",
	IconColor = Color3.fromHex("#F0C768"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})
local autoClickEnabled = false
local clickIntervalSeconds = 0.2

task.spawn(function()
	while true do
		task.wait(clickIntervalSeconds)
		if autoClickEnabled then
			pcall(function()
				clickRemote:FireServer()
			end)
		end
	end
end)

clickSection:Toggle({
	Title = "Auto Click",
	Icon = "mouse-pointer-click",
	Flag = "AutoClickToggle",
	Value = false,
	Callback = function(state)
		autoClickEnabled = state
	end,
})

clickSection:Slider({
	Title = "Interval between clicks",
	Icon = "timer",
	Value = { Min = 0.1, Max = 1, Default = 0.2 },
	Callback = function(value)
		clickIntervalSeconds = value
	end,
})

local rebirthSection = Tabs.Farm:Section({
	Title = "Rebirth",
	Icon = "rotate-ccw",
	IconColor = Color3.fromHex("#F0C768"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})
local autoRebirthEnabled = false
local autoRebirthInterval = 3

task.spawn(function()
	while true do
		task.wait(autoRebirthInterval)
		if autoRebirthEnabled then
			pcall(function()
				rebirthRemote:FireServer()
			end)
		end
	end
end)

rebirthSection:Toggle({
	Title = "Auto Rebirth",
	Icon = "refresh-cw",
	Flag = "AutoRebirthToggle",
	Value = false,
	Callback = function(state)
		autoRebirthEnabled = state
	end,
})

rebirthSection:Slider({
	Title = "Rebirth Interval",
	Icon = "timer",
	Value = { Min = 2, Max = 30, Default = 3 },
	Callback = function(value)
		autoRebirthInterval = value
	end,
})

local stageSection = Tabs.Farm:Section({
	Title = "Auto Stage",
	Icon = "flag",
	IconColor = Color3.fromHex("#F0C768"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})
local verifyScene = workspace:FindFirstChild("主场景")
verifyScene = verifyScene and verifyScene:FindFirstChild("验证场景")

local TOTAL_STAGE_COUNT = 18

local function getStageStates()
	local ok, states = pcall(function()
		return getStageStateRemote:InvokeServer()
	end)
	if ok then return states end
	return nil
end

local function isStageCompleted(states, stageId)
	local entry = states and states[stageId]
	return entry ~= nil and entry.completed == true
end

local function getWaterPart(stageId)
	if not verifyScene then return nil end
	local stageFolder = verifyScene:FindFirstChild("关卡" .. stageId)
	return stageFolder and stageFolder:FindFirstChild("水面")
end

local stageDropdownValues = {}
for i = 1, TOTAL_STAGE_COUNT do
	table.insert(stageDropdownValues, "Stage " .. i)
end

local selectedTargetStage = TOTAL_STAGE_COUNT

stageSection:Dropdown({
	Title = "Target stage",
	Values = stageDropdownValues,
	Value = "Stage " .. TOTAL_STAGE_COUNT,
	Callback = function(value)
		selectedTargetStage = tonumber(value:match("%d+")) or TOTAL_STAGE_COUNT
	end,
})

local autoStageEnabled = false
local stageStatusText = ""

local function setStatus(text)
	stageStatusText = text
end

local function tweenTo(position)
	local hrp = getHrp()
	if not hrp then return false end

	local distance = (position - hrp.Position).Magnitude
	local duration = math.max(distance / 90, 0.3)

	local tween = tweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(position),
	})
	tween:Play()
	tween.Completed:Wait()
	return true
end

local function waitForWaterPart(stageId, attempts)
	for _ = 1, attempts do
		local water = getWaterPart(stageId)
		if water then return water end

		local hrp = getHrp()
		if hrp then
			pcall(function()
				localPlayer:RequestStreamAroundAsync(hrp.Position, 8)
			end)
		end
		task.wait(0.4)
	end
	return getWaterPart(stageId)
end

local function drainStage(stageId)
	setStatus("Going to the stage " .. stageId .. "...")

	local water = waitForWaterPart(stageId, 3)

	if water then
		local target = water.Position + Vector3.new(0, water.Size.Y / 2 + 3, 0)
		tweenTo(target)

		setStatus("Draining stage " .. stageId .. "...")

		local lastNotice = tick()
		while autoStageEnabled do
			local states = getStageStates()
			if isStageCompleted(states, stageId) then
				return true
			end

			if tick() - lastNotice > 20 then
				windUI:Notify({
					Title = "Auto Stage",
					Content = "The internship " .. stageId .. " it keeps draining, don't skip it.",
					Duration = 3,
				})
				lastNotice = tick()
			end

			task.wait(0.3)
		end
		return false
	end

	setStatus("No visible water on the stage " .. stageId .. ", testing paid teleport...")
	pcall(function()
		requestCashTeleportRemote:FireServer(stageId)
	end)
	task.wait(1)

	local states = getStageStates()
	return isStageCompleted(states, stageId)
end

local function runAutoStage()
	local states = getStageStates()
	if not states then
		setStatus("The status of the stages couldn't be read.")
		windUI:Notify({ Title = "Auto Stage", Content = "The status of the stages couldn't be checked", Duration = 3 })
		return
	end

	for stageId = 1, selectedTargetStage do
		if not autoStageEnabled then
			setStatus("Stopped.")
			return
		end

		states = getStageStates()
		if isStageCompleted(states, stageId) then
			setStatus("Stage " .. stageId .. " already completed, skipping.")
		else
			local success = drainStage(stageId)
			if not success then
				if not autoStageEnabled then
					setStatus("Stopped.")
					return
				end
				setStatus("Couldn’t complete the stage " .. stageId .. " - stopping.")
				windUI:Notify({
					Title = "Auto Stage",
					Content = "Couldn’t complete the stage " .. stageId .. " - stopping.",
					Duration = 3,
				})
				autoStageEnabled = false
				return
			end
		end
	end

	setStatus("Full route up to the stage " .. selectedTargetStage .. ".")
	windUI:Notify({ Title = "Auto Stage", Content = "Full route up to the stage " .. selectedTargetStage, Duration = 3 })
	autoStageEnabled = false
end

stageSection:Toggle({
	Title = "Auto Stage",
	Icon = "flag",
	Flag = "AutoStageToggle",
	Value = false,
	Callback = function(state)
		autoStageEnabled = state
		if state then
			task.spawn(runAutoStage)
		end
	end,
})


local fishCatchSection = Tabs.Farm:Section({
	Title = "Auto Catch Fish",
	Icon = "fish",
	IconColor = Color3.fromHex("#D7C39A"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})
local worldFishFolder = workspace:FindFirstChild("主场景")
worldFishFolder = worldFishFolder and worldFishFolder:FindFirstChild("验证场景")
worldFishFolder = worldFishFolder and worldFishFolder:FindFirstChild("WorldFish")

local autoCatchFishEnabled = false

local function getCatchableFish()
	local list = {}
	if not worldFishFolder then return list end

	for _, fishModel in ipairs(worldFishFolder:GetChildren()) do
		if fishModel:IsA("Model") and fishModel:GetAttribute("WorldFish") == true then
			local fishRoot = fishModel:FindFirstChild("FishRoot")
			local prompt = fishRoot and fishRoot:FindFirstChild("PickupPrompt")
			if prompt and prompt.Enabled then
				table.insert(list, {
					model = fishModel,
					root = fishRoot,
					prompt = prompt,
					price = fishModel:GetAttribute("Price") or 0,
				})
			end
		end
	end

	table.sort(list, function(a, b)
		return a.price > b.price
	end)

	return list
end

local function catchFish(entry)
	pcall(function()
		local hrp = getHrp()
		if not hrp then return end

		local target = entry.root.Position + Vector3.new(0, 2, 0)
		local distance = (target - hrp.Position).Magnitude
		local duration = math.max(distance / 90, 0.2)

		local tween = tweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			CFrame = CFrame.new(target),
		})
		tween:Play()
		tween.Completed:Wait()
		task.wait(0.2)

		if entry.model.Parent and entry.prompt.Enabled then
			fireproximityprompt(entry.prompt)
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(0.5)
		if not autoCatchFishEnabled then continue end

		local catchable = getCatchableFish()
		if #catchable == 0 then continue end

		catchFish(catchable[1])
	end
end)

fishCatchSection:Toggle({
	Title = "Auto Catch Fish",
	Icon = "fish",
	Flag = "AutoCatchFishToggle",
	Value = false,
	Callback = function(state)
		autoCatchFishEnabled = state
	end,
})

--------------------------------------------------------------------------------
-- Pets tab.
--------------------------------------------------------------------------------

local petsActionsSection = Tabs.Pets:Section({
	Title = "Pets",
	Icon = "paw-print",
	IconColor = Color3.fromHex("#D4C4F9"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})

petsActionsSection:Button({
	Title = "Equip better pet",
	Icon = "paw-print",
	Callback = function()
		pcall(function()
			equipBestPetRemote:FireServer()
		end)
		windUI:Notify({ Title = "Pets", Content = "Best equipped pet", Duration = 2 })
	end,
})

local eggRollSection = Tabs.Pets:Section({
	Title = "Auto Roll",
	Icon = "egg",
	IconColor = Color3.fromHex("#F8C97A"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})

local function buildCashEggOptions()
	local ok, allEggs = pcall(function()
		return eggHelper.GetAllEggConfig()
	end)
	if not ok or not allEggs then return {}, {} end

	local entries = {}
	for id, data in pairs(allEggs) do
		if data.cashPrice ~= nil then
			table.insert(entries, { id = id, name = data.name or ("Egg " .. tostring(id)), price = data.cashPrice })
		end
	end
	table.sort(entries, function(a, b)
		return a.id < b.id
	end)

	local labels = {}
	local labelToId = {}
	for _, entry in ipairs(entries) do
		local label = entry.name .. " - " .. tostring(entry.price)
		table.insert(labels, label)
		labelToId[label] = entry.id
	end

	return labels, labelToId
end

local eggLabels, eggLabelToId = buildCashEggOptions()

local selectedEggLabel = eggLabels[1]
local selectedEggId = selectedEggLabel and eggLabelToId[selectedEggLabel]

eggRollSection:Dropdown({
	Title = "Egg to roll",
	Values = eggLabels,
	Value = selectedEggLabel,
	Callback = function(value)
		selectedEggLabel = value
		selectedEggId = eggLabelToId[value]
	end,
})

eggRollSection:Button({
	Title = "Refresh egg list",
	Icon = "refresh-cw",
	Callback = function()
		eggLabels, eggLabelToId = buildCashEggOptions()
		windUI:Notify({ Title = "Auto Roll", Content = "Egg list refreshed", Duration = 2 })
	end,
})

local autoRollPetEnabled = false
local rollIntervalSeconds = 0.3

task.spawn(function()
	while true do
		task.wait(rollIntervalSeconds)
		if autoRollPetEnabled and selectedEggId then
			pcall(function()
				openEggRemote:InvokeServer(selectedEggId, 1, true, nil)
			end)
		end
	end
end)

eggRollSection:Slider({
	Title = "Roll interval",
	Icon = "timer",
	Value = { Min = 0.1, Max = 3, Default = 0.3 },
	Callback = function(value)
		rollIntervalSeconds = value
	end,
})

eggRollSection:Toggle({
	Title = "Auto Roll Pet",
	Icon = "egg",
	Flag = "AutoRollPetToggle",
	Value = false,
	Callback = function(state)
		autoRollPetEnabled = state
		if state and not selectedEggId then
			windUI:Notify({ Title = "Auto Roll", Content = "No cash-payable egg selected", Duration = 3 })
		end
	end,
})

--------------------------------------------------------------------------------
-- Fisch tab.
--------------------------------------------------------------------------------

local fishSellSection = Tabs.Fisch:Section({
	Title = "Fish",
	Icon = "fish",
	IconColor = Color3.fromHex("#D7C39A"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})
local keepBestFishCount = 5
local autoSellFishEnabled = false
local sellFishInterval = 10

local function sellExceptBestFish()
	local ok, fishData = pcall(function()
		return getFishDataRemote:InvokeServer()
	end)
	if not ok or not fishData or not fishData.Items then return end

	local entries = {}
	for key, fishEntry in pairs(fishData.Items) do
		table.insert(entries, {
			uid = fishEntry.uid or key,
			value = fishEntry.price or 0,
		})
	end

	table.sort(entries, function(a, b)
		return a.value > b.value
	end)

	for index, entry in ipairs(entries) do
		if index > keepBestFishCount then
			pcall(function()
				sellFishRemote:InvokeServer(entry.uid, nil, true)
			end)
			task.wait(0.1)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(sellFishInterval)
		if autoSellFishEnabled then
			pcall(sellExceptBestFish)
		end
	end
end)

fishSellSection:Slider({
	Title = "Fish to keep",
	Icon = "star",
	Value = { Min = 0, Max = 30, Default = 5 },
	Callback = function(value)
		keepBestFishCount = value
	end,
})

fishSellSection:Toggle({
	Title = "Auto Sell Fish",
	Icon = "fish",
	Flag = "AutoSellFishToggle",
	Value = false,
	Callback = function(state)
		autoSellFishEnabled = state
	end,
})

fishSellSection:Slider({
	Title = "Sales interval",
	Icon = "timer",
	Value = { Min = 5, Max = 60, Default = 10 },
	Callback = function(value)
		sellFishInterval = value
	end,
})

fishSellSection:Button({
	Title = "Sell ALL the fish",
	Icon = "banknote",
	Callback = function()
		pcall(function()
			sellAllFishRemote:InvokeServer(nil, true)
		end)
		windUI:Notify({ Title = "Peces", Content = "Inventory of fish sold", Duration = 2 })
	end,
})

--------------------------------------------------------------------------------
-- Shop tab.
--------------------------------------------------------------------------------

local pumpSection = Tabs.Shop:Section({
	Title = "Pumps",
	Icon = "shopping-bag",
	IconColor = Color3.fromHex("#A7D98A"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})
local autoBuyPumpsEnabled = false
local pumpBuyInterval = 5

local function buyAffordablePumps()
	local ok, allPumps = pcall(function()
		return pumpHelper.GetAllPumpConfig()
	end)
	if not ok or not allPumps then return end

	local sortedIds = {}
	for id, data in pairs(allPumps) do
		if data.cashPrice ~= nil then
			table.insert(sortedIds, id)
		end
	end
	table.sort(sortedIds, function(a, b)
		return a < b
	end)

	for _, id in ipairs(sortedIds) do
		pcall(function()
			buyCashPumpRemote:FireServer(id)
		end)
		task.wait(0.15)
	end
end

task.spawn(function()
	while true do
		task.wait(pumpBuyInterval)
		if autoBuyPumpsEnabled then
			pcall(buyAffordablePumps)
		end
	end
end)

pumpSection:Toggle({
	Title = "Auto Buy Pumps",
	Icon = "shopping-cart",
	Flag = "AutoBuyPumpsToggle",
	Value = false,
	Callback = function(state)
		autoBuyPumpsEnabled = state
	end,
})

pumpSection:Slider({
	Title = "Buying interval",
	Icon = "timer",
	Value = { Min = 2, Max = 30, Default = 5 },
	Callback = function(value)
		pumpBuyInterval = value
	end,
})

local upgradeSection = Tabs.Shop:Section({
	Title = "Upgrades",
	Icon = "trending-up",
	IconColor = Color3.fromHex("#F0C768"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})
local autoBuyUpgradesEnabled = false
local upgradeBuyInterval = 5

local function buyAllUpgrades()
	local ok, allUpgrades = pcall(function()
		return upgradeHelper.GetAllConfig()
	end)
	if not ok or not allUpgrades then return end

	for key in pairs(allUpgrades) do
		pcall(function()
			buyCashUpgradeRemote:FireServer(key)
		end)
		task.wait(0.15)
	end
end

task.spawn(function()
	while true do
		task.wait(upgradeBuyInterval)
		if autoBuyUpgradesEnabled then
			pcall(buyAllUpgrades)
		end
	end
end)

upgradeSection:Toggle({
	Title = "Auto Buy Upgrades",
	Icon = "trending-up",
	Flag = "AutoBuyUpgradesToggle",
	Value = false,
	Callback = function(state)
		autoBuyUpgradesEnabled = state
	end,
})

upgradeSection:Slider({
	Title = "Buying interval",
	Icon = "timer",
	Value = { Min = 2, Max = 30, Default = 5 },
	Callback = function(value)
		upgradeBuyInterval = value
	end,
})

--------------------------------------------------------------------------------
-- Settings tab.
--------------------------------------------------------------------------------

local generalSection = Tabs.Settings:Section({
	Title = "General",
	Icon = "shield",
	IconColor = Color3.fromHex("#C7D2F2"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})

local antiAfkEnabled = false
generalSection:Toggle({
	Title = "Anti AFK",
	Icon = "shield",
	Flag = "AntiAfkToggle",
	Value = false,
	Callback = function(state)
		antiAfkEnabled = state
		windUI:Notify({ Title = "Anti AFK", Content = state and "Activated" or "Disabled", Duration = 2 })
	end,
})

localPlayer.Idled:Connect(function()
	if antiAfkEnabled then
		virtualUserService:CaptureController()
		virtualUserService:ClickButton2(Vector2.new())
	end
end)

local fullbrightEnabled = false
local savedBrightness, savedClockTime, savedFogEnd = lightingService.Brightness, lightingService.ClockTime, lightingService.FogEnd

generalSection:Toggle({
	Title = "Fullbright",
	Icon = "sun",
	Flag = "FullbrightToggle",
	Value = false,
	Callback = function(state)
		fullbrightEnabled = state
		if state then
			savedBrightness, savedClockTime, savedFogEnd = lightingService.Brightness, lightingService.ClockTime, lightingService.FogEnd
			lightingService.Brightness = 2
			lightingService.ClockTime = 14
			lightingService.FogEnd = 100000
		else
			lightingService.Brightness = savedBrightness
			lightingService.ClockTime = savedClockTime
			lightingService.FogEnd = savedFogEnd
		end
	end,
})

local configSection = Tabs.Settings:Section({
	Title = "Settings",
	Icon = "file-cog",
	IconColor = Color3.fromHex("#D7C39A"),
	Opened = true,
	Box = true,
	BoxBorder = true,
	TextSize = 18,
})
local configManager = Window.ConfigManager
local configName = "default"

local configNameInput = configSection:Input({
	Title = "Configuration name",
	Icon = "file-cog",
	Value = configName,
	Callback = function(value)
		configName = value
	end,
})

local allConfigs = configManager:AllConfigs()
local configDropdown = configSection:Dropdown({
	Title = "Saved settings",
	Values = allConfigs,
	Value = table.find(allConfigs, configName) and configName or nil,
	Callback = function(value)
		configName = value
		configNameInput:Set(value)
	end,
})

configSection:Button({
	Title = "Saved settings",
	Icon = "save",
	Callback = function()
		Window.CurrentConfig = configManager:Config(configName)
		if Window.CurrentConfig:Save() then
			windUI:Notify({ Title = "Setting", Content = "Saved as '" .. configName .. "'", Icon = "check", Duration = 2 })
		end
		configDropdown:Refresh(configManager:AllConfigs())
	end,
})

configSection:Button({
	Title = "Load configuration",
	Icon = "refresh-cw",
	Callback = function()
		Window.CurrentConfig = configManager:CreateConfig(configName)
		if Window.CurrentConfig:Load() then
			windUI:Notify({ Title = "Settings", Content = "'" .. configName .. "' loaded", Icon = "check", Duration = 2 })
		end
	end,
})

Window:EditOpenButton({
	Title = "Yolk Hub",
	Icon = "rbxassetid://102847073936864",
	CornerRadius = UDim.new(0, 14),
	StrokeThickness = 1,
	Color = ColorSequence.new(Color3.fromHex("#F0C768"), Color3.fromHex("#D7C39A")),
	OnlyMobile = false,
	Enabled = true,
	Draggable = true,
})

--loadstring(game:HttpGet("https://raw.githubusercontent.com/Guild-Studio/BlitzHub-V1/refs/heads/main/Yolk%20Hub"))()