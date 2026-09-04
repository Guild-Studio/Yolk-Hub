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

local remotesFolder = replicatedStorage:WaitForChild("RemoteEvent")
local giveItemRemote = remotesFolder:WaitForChild("GiveItem")
local sellAllRemote = remotesFolder:WaitForChild("SellAllFunction")
local sellAllPetsRemote = remotesFolder:WaitForChild("SellAllPetsFunction")
local rebirthRemote = remotesFolder:WaitForChild("Rebirth")
local buyEggRemote = remotesFolder:WaitForChild("BuyEgg")
local purchaseRopeRemote = remotesFolder:WaitForChild("PurchaseRope")
local ropeCheckerRemote = remotesFolder:WaitForChild("RopeChecker")

local itemsModule = require(replicatedStorage.Modules.ItemsModule)
local eggsModule = require(replicatedStorage.Modules.EggsModule)
local ropesModule = require(replicatedStorage.Modules.RopesModule)

windUI:AddTheme({
	Name = "Yolk",
	Accent = "#D9A066",
	Dialog = "#1B1C25",
	Outline = "#2B2C38",
	Text = "#F2F0EA",
	Placeholder = "#8A8B99",
	Background = "#14151D",
	Button = "#20212C",
	Icon = "#D9A066",
})

local Window = windUI:CreateWindow({
	Title = "Yolk Hub",
	Icon = "rbxassetid://102847073936864",
	Author = "By Shoyo",
	Folder = "YolkHub",
	Size = UDim2.fromOffset(280, 320),
	Transparent = true,
	Theme = "Yolk",
	SideBarWidth = 200,
	ScrollBarEnabled = true,
	HideSearchBar = false,
	NewElements = true,
	Resizable = true,
	User = {
		Enabled = true,
		Anonymous = false,
	},
	Topbar = {
		Height = 45,
		ButtonsType = "Mac",
	},
})

Window:EditOpenButton({
	Title = "Yolk Hub",
	Icon = "rbxassetid://102847073936864",
	CornerRadius = UDim.new(0, 12),
	StrokeThickness = 1,
	Color = ColorSequence.new(Color3.fromHex("2B2C38"), Color3.fromHex("8A8B99")),
	OnlyMobile = false,
	Enabled = true,
	Draggable = true,
})

Window:Tag({
	Title = "Deep Pull Dev",
	Icon = "egg",
	Color = Color3.fromHex("#D9A066"),
})

local Tabs = {
	Status = Window:Tab({ Title = "Status", Icon = "activity", Opened = true }),
	Farming = Window:Tab({ Title = "Farming", Icon = "egg" }),
	Automation = Window:Tab({ Title = "Automation", Icon = "cog" }),
	Shop = Window:Tab({ Title = "Shop", Icon = "shopping-cart" }),
	Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

--------------------------------------------------------------------------------
-- Status tab.
--------------------------------------------------------------------------------

Tabs.Status:Paragraph({
	Title = "Yolk Hub",
	Desc = "Script para Tirón Profundo. Versión 1.0.0",
	Image = "egg",
	ImageSize = 20,
	Color = Color3.fromHex("#D9A066"),
})

Tabs.Status:Paragraph({
	Title = "Créditos",
	Desc = "Desarrollado por Potent para la comunidad de Yolk Hub.",
	Image = "code",
	ImageSize = 20,
	Color = Color3.fromHex("#D9A066"),
})

local linksSection = Tabs.Status:Section({ Title = "Soporte", Opened = true })

linksSection:Button({
	Title = "Discord",
	Desc = "Únete a nuestro servidor de soporte",
	Icon = "message-circle",
	Callback = function()
		setclipboard("https://discord.gg/tu-invite")
		windUI:Notify({ Title = "Yolk Hub", Content = "Link de Discord copiado", Duration = 3 })
	end,
})

local statusSection = Tabs.Status:Section({ Title = "Status", Opened = true })

statusSection:Paragraph({
	Title = "Auto Farm - cómo funciona",
	Desc = "GiveItem no valida el Gamepass de Auto Pull server-side (confirmado en vivo) - el hub llama ese remote directo con items de alto valor, sin necesidad de pararte en la cuerda.",
	Image = "info",
	ImageSize = 18,
	Color = Color3.fromHex("#8A8B99"),
})

local function getHumanoid()
	local character = localPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

--------------------------------------------------------------------------------
-- Farming tab.
--------------------------------------------------------------------------------

local farmSection = Tabs.Farming:Section({ Title = "Auto Farm Items", Opened = true })
local RARITY_OPTIONS = { "Common", "Rare", "Epic", "Legendary", "Mythical", "Mythic", "Godly", "Secret", "Limited" }

local function getItemsByRarities(selectedRarities)
	local list = {}
	for name, data in pairs(itemsModule) do
		if selectedRarities[data.rarity] then
			table.insert(list, {
				name = name,
				rarity = data.rarity,
				weight = data.MaxWeight or data.MinWeight or 1,
				price = data.baseSellPrice or 0,
			})
		end
	end
	table.sort(list, function(a, b)
		return a.price > b.price
	end)
	return list
end

local selectedRarities = {}
for _, rarity in ipairs(RARITY_OPTIONS) do
	selectedRarities[rarity] = true
end

farmSection:Dropdown({
	Title = "Rarezas a farmear",
	Values = RARITY_OPTIONS,
	Multi = true,
	Value = RARITY_OPTIONS,
	Callback = function(values)
		selectedRarities = {}
		for _, rarity in ipairs(values) do
			selectedRarities[rarity] = true
		end
	end,
})

local autoFarmEnabled = false
local farmIntervalSeconds = 0.5

task.spawn(function()
	local itemIndex = 1
	while true do
		task.wait(farmIntervalSeconds)
		if autoFarmEnabled then
			local items = getItemsByRarities(selectedRarities)
			if #items > 0 then
				itemIndex = (itemIndex % #items) + 1
				local item = items[itemIndex]
				pcall(function()
					giveItemRemote:FireServer(item.name, item.rarity, nil, item.weight, "perfect")
				end)
			end
		end
	end
end)

farmSection:Toggle({
	Title = "Auto Farm Items",
	Desc = "OP !",
	Icon = "sparkles",
	Flag = "AutoFarmToggle",
	Value = false,
	Callback = function(state)
		autoFarmEnabled = state
	end,
})

farmSection:Slider({
	Title = "Intervalo entre items",
	Icon = "timer",
	Value = { Min = 0.2, Max = 3, Default = 0.5 },
	Callback = function(value)
		farmIntervalSeconds = value
	end,
})

local sellSection = Tabs.Farming:Section({ Title = "Auto Sell", Opened = true })

local autoSellEnabled = false
local sellIntervalSeconds = 5

task.spawn(function()
	while true do
		task.wait(sellIntervalSeconds)
		if autoSellEnabled then
			pcall(function()
				sellAllRemote:InvokeServer()
			end)
		end
	end
end)

sellSection:Toggle({
	Title = "Auto Sell Items",
	Icon = "banknote",
	Flag = "AutoSellToggle",
	Value = false,
	Callback = function(state)
		autoSellEnabled = state
	end,
})

sellSection:Slider({
	Title = "Intervalo de venta",
	Icon = "timer",
	Value = { Min = 1, Max = 30, Default = 5 },
	Callback = function(value)
		sellIntervalSeconds = value
	end,
})

sellSection:Button({
	Title = "Vender inventario ahora",
	Icon = "coins",
	Callback = function()
		local ok, result = pcall(function()
			return sellAllRemote:InvokeServer()
		end)
		windUI:Notify({
			Title = "Auto Sell",
			Content = ok and ("Vendido por $" .. tostring(result)) or "No se pudo vender",
			Duration = 3,
		})
	end,
})

sellSection:Button({
	Title = "Vender todas las mascotas",
	Icon = "paw-print",
	Callback = function()
		pcall(function()
			sellAllPetsRemote:InvokeServer()
		end)
		windUI:Notify({ Title = "Mascotas", Content = "Inventario de mascotas vendido", Duration = 2 })
	end,
})

--------------------------------------------------------------------------------
-- Automation tab.
--------------------------------------------------------------------------------

local rebirthSection = Tabs.Automation:Section({ Title = "Rebirth", Opened = true })

local autoRebirthEnabled = false
local autoRebirthInterval = 5

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
	Title = "Intervalo de Rebirth",
	Icon = "timer",
	Value = { Min = 2, Max = 30, Default = 5 },
	Callback = function(value)
		autoRebirthInterval = value
	end,
})

local movementSection = Tabs.Automation:Section({ Title = "Movimiento", Opened = true })

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

local noclipEnabled = false
movementSection:Toggle({
	Title = "Noclip",
	Icon = "shield-off",
	Flag = "NoclipToggle",
	Value = false,
	Callback = function(state)
		noclipEnabled = state
	end,
})

runService.Stepped:Connect(function()
	if not noclipEnabled then return end
	local character = localPlayer.Character
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			part.CanCollide = false
		end
	end
end)

--------------------------------------------------------------------------------
-- Shop tab.
--------------------------------------------------------------------------------

local eggShopSection = Tabs.Shop:Section({ Title = "Huevos", Opened = true })

local eggNames = {}
for name in pairs(eggsModule) do
	table.insert(eggNames, name)
end
table.sort(eggNames)

local selectedEgg = eggNames[1]
eggShopSection:Dropdown({
	Title = "Huevo",
	Values = eggNames,
	Value = selectedEgg,
	Callback = function(value)
		selectedEgg = value
	end,
})

eggShopSection:Button({
	Title = "Comprar huevo",
	Icon = "egg",
	Callback = function()
		pcall(function()
			buyEggRemote:FireServer(selectedEgg, "cash")
		end)
		windUI:Notify({ Title = "Tienda", Content = "Solicitada compra de " .. selectedEgg, Duration = 2 })
	end,
})

local ropeShopSection = Tabs.Shop:Section({ Title = "Cuerdas", Opened = true })

local ropeNames = {}
for name in pairs(ropesModule) do
	table.insert(ropeNames, name)
end
table.sort(ropeNames)

local selectedRope = ropeNames[1]
ropeShopSection:Dropdown({
	Title = "Cuerda",
	Values = ropeNames,
	Value = selectedRope,
	Callback = function(value)
		selectedRope = value
	end,
})

ropeShopSection:Button({
	Title = "Comprar y equipar cuerda",
	Icon = "link",
	Callback = function()
		pcall(function()
			purchaseRopeRemote:FireServer(selectedRope)
			ropeCheckerRemote:FireServer(selectedRope)
		end)
		windUI:Notify({ Title = "Tienda", Content = "Solicitada compra de " .. selectedRope, Duration = 2 })
	end,
})

--------------------------------------------------------------------------------
-- Settings tab.
--------------------------------------------------------------------------------

local generalSection = Tabs.Settings:Section({ Title = "General", Opened = true })

local antiAfkEnabled = false
generalSection:Toggle({
	Title = "Anti AFK",
	Icon = "shield",
	Flag = "AntiAfkToggle",
	Value = false,
	Callback = function(state)
		antiAfkEnabled = state
		windUI:Notify({ Title = "Anti AFK", Content = state and "Activado" or "Desactivado", Duration = 2 })
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

local configSection = Tabs.Settings:Section({ Title = "Configuración", Opened = true })
local configManager = Window.ConfigManager
local configName = "default"

local configNameInput = configSection:Input({
	Title = "Nombre de configuración",
	Icon = "file-cog",
	Value = configName,
	Callback = function(value)
		configName = value
	end,
})

local allConfigs = configManager:AllConfigs()
local configDropdown = configSection:Dropdown({
	Title = "Configuraciones guardadas",
	Values = allConfigs,
	Value = table.find(allConfigs, configName) and configName or nil,
	Callback = function(value)
		configName = value
		configNameInput:Set(value)
	end,
})

configSection:Button({
	Title = "Guardar configuración",
	Icon = "save",
	Callback = function()
		Window.CurrentConfig = configManager:Config(configName)
		if Window.CurrentConfig:Save() then
			windUI:Notify({ Title = "Configuración", Content = "Guardada como '" .. configName .. "'", Icon = "check", Duration = 3 })
		end
		configDropdown:Refresh(configManager:AllConfigs())
	end,
})

configSection:Button({
	Title = "Cargar configuración",
	Icon = "refresh-cw",
	Callback = function()
		Window.CurrentConfig = configManager:CreateConfig(configName)
		if Window.CurrentConfig:Load() then
			windUI:Notify({ Title = "Configuración", Content = "'" .. configName .. "' cargada", Icon = "check", Duration = 3 })
		end
	end,
})