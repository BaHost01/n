-- UNDER: GNU LESSER GENERAL PUBLIC LICENSE
--Version 2.1, February 1999

-- MAIN HOLDER: BaHost01 | #agente0981 (Discord) | cleasantos1994 (Roblox)
-- LICENSE LINK: https://raw.githubusercontent.com/BaHost01/n/refs/heads/main/LICENSE

local UniversalLib = {}

-- ==========================================
-- [ LIBRARY CONFIGURATION ]
-- ==========================================
UniversalLib.Config = {
	Service = nil,
	Identifier = nil,
	Provider = nil,
	UseJnkie = false,
	DebugLogging = false,
	AutoSaveKey = false,
	AutoLoadKey = false,
	StreamerMode = false, -- Nova Configuração
	CustomAnimations = nil
}

-- ==========================================
-- [ UTILITIES & SECURITY ]
-- ==========================================
local function Log(message)
	if UniversalLib.Config.DebugLogging then
		print("[UniversalLib Debug] " .. tostring(message))
	end
end

-- Base64 Utility for Key Obfuscation
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64encode(data)
	return ((data:gsub(".", function(x) 
		local r,b="",x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and "1" or "0") end
		return r;
	end).."0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
		if (#x < 6) then return "" end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=="1" and 2^(6-i) or 0) end
		return b64chars:sub(c+1,c+1)
	end)..({ "", "==", "=" })[#data%3+1])
end

local function b64decode(data)
	data = string.gsub(data, "[^" .. b64chars .. "=]", "")
	return (data:gsub(".", function(x)
		if (x == "=") then return "" end
		local r,f="",(b64chars:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and "1" or "0") end
		return r;
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if (#x < 8) then return "" end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=="1" and 2^(8-i) or 0) end
		return string.char(c)
	end))
end

-- Gerador de Identidade Realista
local realUsernames = {
    "ShadowSlayer_99", "CoolKitten2024", "EliteGamer_Pro", "MysticWolf", "DragonRider",
    "SwiftBlade", "FrostByte", "SolarFlare", "NeonNinja", "NightOwl",
    "BlazeRunner", "StormChaser", "VoidWalker", "LunarEclipse", "CrimsonViper",
    "IronKnight", "GhostHunter", "CyberPunk_01", "PixelWarrior", "AquaMarine"
}
local function GenerateRealisticIdentity()
    local name = realUsernames[math.random(1, #realUsernames)] .. tostring(math.random(10, 999))
    local id = tostring(math.random(10000000, 999999999))
    return name, id
end
local fakeUsername, fakeUserId = GenerateRealisticIdentity()

-- [ CONFIGURATION FUNCTIONS ]
function UniversalLib.SetService(name) UniversalLib.Config.Service = name; Log("Service set: " .. tostring(name)) end
function UniversalLib.SetIdentifier(id) UniversalLib.Config.Identifier = tostring(id); Log("ID set: " .. tostring(id)) end
function UniversalLib.SetProvider(name) UniversalLib.Config.Provider = name; Log("Provider set: " .. tostring(name)) end
function UniversalLib.IsUsingJnkie(bool) UniversalLib.Config.UseJnkie = bool end
function UniversalLib.DebugLogging(bool) UniversalLib.Config.DebugLogging = bool end
function UniversalLib.SaveKey(bool) UniversalLib.Config.AutoSaveKey = (bool == nil) and true or bool end
function UniversalLib.LoadKey(bool) UniversalLib.Config.AutoLoadKey = (bool == nil) and true or bool end
function UniversalLib.SetStreamerMode(bool) UniversalLib.Config.StreamerMode = bool; Log("Streamer Mode: " .. tostring(bool)) end
function UniversalLib.SetCustomAnimation(animTable) UniversalLib.Config.CustomAnimations = animTable end

local function GetKeyFileName()
	return (UniversalLib.Config.Service or "Universal") .. "_" .. (UniversalLib.Config.Identifier or "Default") .. "_Key.txt"
end

local function WriteKeyToFile(key)
	if UniversalLib.Config.AutoSaveKey and writefile then
		pcall(function() writefile(GetKeyFileName(), b64encode(key)) end)
	end
end

-- ==========================================
-- [ ROBLOX SERVICES & UTILS ]
-- ==========================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
local deviceIcon = isMobile and "📱 Mobile" or "💻 PC"
local LocalPlayer = Players.LocalPlayer

local function MakeDraggable(gui, dragPart)
	local dragging, dragInput, dragStart, startPos
	dragPart = dragPart or gui

	dragPart.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	dragPart.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function ApplyGradient(parent, color1, color2)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, color2)}
	grad.Rotation = 45
	grad.Parent = parent
	return grad
end

local function CreateSound(parent, id, volume)
	local s = Instance.new("Sound", parent)
	s.SoundId = "rbxassetid://" .. id
	s.Volume = volume
	return s
end

-- ==========================================
-- [ KEY SYSTEM GATEWAY ]
-- ==========================================
function UniversalLib.StartUserScript(callback)
	if not UniversalLib.Config.UseJnkie then
		if callback then callback() end
		return
	end

	local ok, J = pcall(function() return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
	if not ok or not J then warn("[UniversalLib Error] Failed to load Jnkie SDK.") return end
	
	J.service = UniversalLib.Config.Service
	J.identifier = UniversalLib.Config.Identifier
	J.provider = UniversalLib.Config.Provider

	if UniversalLib.Config.AutoLoadKey and isfile and readfile then
		local fileName = GetKeyFileName()
		if isfile(fileName) then
			local success, savedKey = pcall(function() 
				local raw = readfile(fileName)
				return b64decode(raw)
			end)
			if success and savedKey ~= "" then
				local checkOk, res = pcall(function() return J.check_key(savedKey) end)
				if checkOk and res and res.valid then
					if callback then callback() end
					return 
				end
			end
		end
	end

	local guiName = GenerateRandomString(15)
	if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end

	local G = Instance.new("ScreenGui", (pcall(gethui) and gethui() or CoreGui))
	G.Name = guiName
	G.ResetOnSpawn = false
	G.IgnoreGuiInset = true

	local SuccessSound = CreateSound(G, "140072726814802", 0.55)

	local MainCanvas = Instance.new("Frame", G)
	MainCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
	MainCanvas.Size = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 650, 0, 380)
	MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainCanvas.BackgroundTransparency = 1
	MakeDraggable(MainCanvas)


	local Main = Instance.new("Frame", MainCanvas)
	Main.Size = UDim2.new(1, 0, 1, 0)
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Main.ClipsDescendants = true
	ApplyGradient(Main, Color3.fromRGB(25, 25, 30), Color3.fromRGB(12, 12, 15))
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	Instance.new("UIStroke", Main).Transparency = 0.7
	Main.UIStroke.Color = Color3.new(1, 1, 1)

	local Top = Instance.new("Frame", Main)
	Top.Size = UDim2.new(1, 0, 0, isMobile and 35 or 45)
	Top.BackgroundTransparency = 1

	local TitleText = Instance.new("TextLabel", Top)
	TitleText.Size = UDim2.new(0.8, 0, 1, 0)
	TitleText.Position = UDim2.new(0, 15, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Text = "AUTHENTICATION <font color='rgb(150,150,150)'>| " .. deviceIcon .. "</font>"
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextSize = 12
	TitleText.RichText = true
	TitleText.TextColor3 = Color3.new(1, 1, 1)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left

	local LeftPanel = Instance.new("Frame", Main)
	LeftPanel.Size = UDim2.new(0.45, 0, 1, -Top.Size.Y.Offset)
	LeftPanel.Position = UDim2.new(0, 0, 0, Top.Size.Y.Offset)
	LeftPanel.BackgroundTransparency = 1
	Instance.new("UIListLayout", LeftPanel).Padding = UDim.new(0, 10)
	LeftPanel.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	LeftPanel.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local StatusText = Instance.new("TextLabel", LeftPanel)
	StatusText.Size = UDim2.new(1, -30, 0, 20)
	StatusText.BackgroundTransparency = 1
	StatusText.Text = "Status: Waiting..."
	StatusText.Font = Enum.Font.GothamMedium
	StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)

	local KeyInput = Instance.new("TextBox", LeftPanel)
	KeyInput.Size = UDim2.new(1, -30, 0, 40)
	KeyInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	KeyInput.PlaceholderText = "Enter Key..."
	KeyInput.TextColor3 = Color3.new(1, 1, 1)
	KeyInput.Font = Enum.Font.Gotham
	Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

	local BtnValidate = Instance.new("TextButton", LeftPanel)
	BtnValidate.Size = UDim2.new(1, -30, 0, 40)
	BtnValidate.BackgroundColor3 = Color3.new(1, 1, 1)
	BtnValidate.Text = "VALIDATE"
	BtnValidate.TextColor3 = Color3.fromRGB(20, 20, 25)
	BtnValidate.Font = Enum.Font.GothamBold
	Instance.new("UICorner", BtnValidate).CornerRadius = UDim.new(0, 6)

	BtnValidate.MouseButton1Click:Connect(function()
		local key = KeyInput.Text
		if key == "" then return end
		StatusText.Text = "Checking..."
		local _, res = pcall(function() return J.check_key(key) end)
		if res and res.valid then
			SuccessSound:Play()
			WriteKeyToFile(key)
			task.wait(0.5)
			G:Destroy()
			if callback then callback() end
		else
			StatusText.Text = "Invalid Key."
			StatusText.TextColor3 = Color3.fromRGB(255, 85, 85)
		end
	end)
end

-- ==========================================
-- [ MAIN UI HUB LIBRARY ]
-- ==========================================
function UniversalLib:CreateWindow(config)
	config = config or {}
	local title = config.Title or "HUB"
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

	local Window = { ActiveTab = nil, Tabs = {}, Minimized = false, SettingsOpen = false, RGBConnection = nil, isFocused = true }

	local G = Instance.new("ScreenGui", (pcall(gethui) and gethui() or CoreGui))
	G.Name = GenerateRandomString(15)
	G.ResetOnSpawn = false
	G.IgnoreGuiInset = true

	-- Basic Anti-Tamper
	G.AncestryChanged:Connect(function(_, parent)
		if not parent and G then
			warn("[UniversalLib] UI Tamper Detected.")
		end
	end)

	local ClickSound = CreateSound(G, "140387697208266", 0.45)

	local MainCanvas = Instance.new("Frame", G)
	MainCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
	MainCanvas.Size = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 650, 0, 380)
	MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainCanvas.BackgroundTransparency = 1
	MakeDraggable(MainCanvas)

	local Main = Instance.new("Frame", MainCanvas)
	Main.Size = UDim2.new(1, 0, 1, 0)
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Main.ClipsDescendants = true
	ApplyGradient(Main, Color3.fromRGB(25, 25, 30), Color3.fromRGB(12, 12, 15))
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Transparency = 0.7
	MainStroke.Color = Color3.new(1, 1, 1)

	local Top = Instance.new("Frame", Main)
	Top.Size = UDim2.new(1, 0, 0, isMobile and 35 or 45)
	Top.BackgroundTransparency = 1

	local TitleText = Instance.new("TextLabel", Top)
	TitleText.Size = UDim2.new(0.8, 0, 1, 0)
	TitleText.Position = UDim2.new(0, 15, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.RichText = true
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextSize = 13
	TitleText.TextColor3 = Color3.new(1, 1, 1)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left

	local function UpdateTitle()
		if UniversalLib.Config.StreamerMode or not Window.isFocused then
			TitleText.Text = title .. " <font color='rgb(150,150,150)'>| " .. fakeUsername .. " | " .. deviceIcon .. "</font>"
		else
			TitleText.Text = title .. " <font color='rgb(150,150,150)'>| " .. LocalPlayer.Name .. " | " .. deviceIcon .. "</font>"
		end
	end
	UpdateTitle()

	UIS.WindowFocused:Connect(function() Window.isFocused = true; UpdateTitle() end)
	UIS.WindowFocusReleased:Connect(function() Window.isFocused = false; UpdateTitle() end)

	local BtnSettings = Instance.new("TextButton", Top)
	BtnSettings.Size = UDim2.new(0, 25, 0, 25)
	BtnSettings.Position = UDim2.new(1, -35, 0.5, -12)
	BtnSettings.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	BtnSettings.Text = "⚙"
	BtnSettings.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", BtnSettings).CornerRadius = UDim.new(0, 4)

	local TabPanel = Instance.new("ScrollingFrame", Main)
	TabPanel.Size = UDim2.new(0.3, 0, 1, -Top.Size.Y.Offset)
	TabPanel.Position = UDim2.new(0, 0, 0, Top.Size.Y.Offset)
	TabPanel.BackgroundTransparency = 1
	TabPanel.ScrollBarThickness = 0
	local TabList = Instance.new("UIListLayout", TabPanel)
	TabList.Padding = UDim.new(0, 5)
	TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", TabPanel).PaddingTop = UDim.new(0, 10)

	local ContentPanel = Instance.new("Frame", Main)
	ContentPanel.Size = UDim2.new(0.7, 0, 1, -Top.Size.Y.Offset)
	ContentPanel.Position = UDim2.new(0.3, 0, 0, Top.Size.Y.Offset)
	ContentPanel.BackgroundTransparency = 1

	local SettingsOverlay = Instance.new("ScrollingFrame", Main)
	SettingsOverlay.Size = UDim2.new(0.7, -20, 1, -Top.Size.Y.Offset - 20)
	SettingsOverlay.Position = UDim2.new(1, 10, 0, Top.Size.Y.Offset + 10) 
	SettingsOverlay.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	SettingsOverlay.ZIndex = 500
	SettingsOverlay.ScrollBarThickness = 2
	Instance.new("UICorner", SettingsOverlay).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", SettingsOverlay).Color = Color3.fromRGB(60, 60, 70)
	local SetList = Instance.new("UIListLayout", SettingsOverlay)
	SetList.Padding = UDim.new(0, 8)
	SetList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", SettingsOverlay).PaddingTop = UDim.new(0, 10)

	function Window:AddSettingToggle(text, default, callback)
		local TglFrame = Instance.new("Frame", SettingsOverlay)
		TglFrame.Size = UDim2.new(1, -20, 0, 35)
		TglFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		TglFrame.ZIndex = SettingsOverlay.ZIndex + 1
		Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)
		
		local TglText = Instance.new("TextLabel", TglFrame)
		TglText.Size = UDim2.new(0.7, 0, 1, 0)
		TglText.Position = UDim2.new(0, 10, 0, 0)
		TglText.BackgroundTransparency = 1
		TglText.Text = text
		TglText.TextColor3 = Color3.fromRGB(200,200,200)
		TglText.Font = Enum.Font.GothamMedium
		TglText.TextSize = 12
		TglText.TextXAlignment = "Left"
		TglText.ZIndex = TglFrame.ZIndex

		local TglBtn = Instance.new("TextButton", TglFrame)
		TglBtn.Size = UDim2.new(0, 40, 0, 20)
		TglBtn.Position = UDim2.new(1, -50, 0.5, -10)
		TglBtn.BackgroundColor3 = default and Color3.fromRGB(114, 137, 218) or Color3.fromRGB(80, 80, 80)
		TglBtn.Text = ""
		TglBtn.ZIndex = TglFrame.ZIndex
		Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(1, 0)

		local Ind = Instance.new("Frame", TglBtn)
		Ind.Size = UDim2.new(0, 16, 0, 16)
		Ind.Position = UDim2.new(0, default and 22 or 2, 0.5, -8)
		Ind.BackgroundColor3 = Color3.new(1, 1, 1)
		Ind.ZIndex = TglBtn.ZIndex
		Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

		local state = default
		TglBtn.MouseButton1Click:Connect(function()
			ClickSound:Play()
			state = not state
			TweenService:Create(TglBtn, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(114, 137, 218) or Color3.fromRGB(80, 80, 80)}):Play()
			TweenService:Create(Ind, TweenInfo.new(0.3), {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}):Play()
			callback(state)
		end)
	end

	Window:AddSettingToggle("Streamer Mode", UniversalLib.Config.StreamerMode, function(s)
		UniversalLib.Config.StreamerMode = s
		UpdateTitle()
	end)

	Window:AddSettingToggle("RGB Mode", false, function(s)
		if s then
			local h = 0
			Window.RGBConnection = RunService.RenderStepped:Connect(function(dt)
				h = (h + dt * 0.1) % 1
				MainStroke.Color = Color3.fromHSV(h, 0.8, 1)
			end)
		else
			if Window.RGBConnection then Window.RGBConnection:Disconnect() end
			MainStroke.Color = Color3.new(1, 1, 1)
		end
	end)

	BtnSettings.MouseButton1Click:Connect(function()
		ClickSound:Play()
		Window.SettingsOpen = not Window.SettingsOpen
		local target = Window.SettingsOpen and UDim2.new(0.3, 10, 0, Top.Size.Y.Offset + 10) or UDim2.new(1, 10, 0, Top.Size.Y.Offset + 10)
		TweenService:Create(SettingsOverlay, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = target}):Play()
	end)

	function Window:CreateTab(tabName)
		local TabBtn = Instance.new("TextButton", TabPanel)
		TabBtn.Size = UDim2.new(1, -10, 0, 35)
		TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		TabBtn.Text = tabName
		TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		TabBtn.Font = Enum.Font.GothamMedium
		TabBtn.TextSize = 13
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

		local TabContainer = Instance.new("CanvasGroup", ContentPanel)
		TabContainer.Size = UDim2.new(1, -20, 1, -20)
		TabContainer.Position = UDim2.new(0, 10, 0, 10)
		TabContainer.BackgroundTransparency = 1
		TabContainer.Visible = false
		TabContainer.GroupTransparency = 1

		local Scroll = Instance.new("ScrollingFrame", TabContainer)
		Scroll.Size = UDim2.new(1, 0, 1, 0)
		Scroll.BackgroundTransparency = 1
		Scroll.ScrollBarThickness = 2
		local ContainerList = Instance.new("UIListLayout", Scroll)
		ContainerList.Padding = UDim.new(0, 8)
		ContainerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Scroll.CanvasSize = UDim2.new(0, 0, 0, ContainerList.AbsoluteContentSize.Y + 10)
		end)

		if not Window.ActiveTab then 
			Window.ActiveTab = TabContainer
			TabContainer.Visible = true
			TabContainer.GroupTransparency = 0
			TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45) 
			TabBtn.TextColor3 = Color3.new(1,1,1)
		end

		TabBtn.MouseButton1Click:Connect(function()
			if Window.ActiveTab == TabContainer then return end
			ClickSound:Play()
			
			if Window.ActiveTab then
				local oldTab = Window.ActiveTab
				TweenService:Create(oldTab, TweenInfo.new(0.3), {GroupTransparency = 1}):Play()
				task.delay(0.3, function() oldTab.Visible = false end)
			end

			for _, child in pairs(TabPanel:GetChildren()) do 
				if child:IsA("TextButton") then 
					TweenService:Create(child, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 25), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
				end 
			end

			Window.ActiveTab = TabContainer
			TabContainer.Visible = true
			TweenService:Create(TabContainer, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45), TextColor3 = Color3.new(1, 1, 1)}):Play()
		end)

		local TabElements = {}

		function TabElements:CreateButton(txt, cb)
			local b = Instance.new("TextButton", Scroll)
			b.Size = UDim2.new(1, -10, 0, 38)
			b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			
			b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play() end)
			b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play() end)
			b.MouseButton1Click:Connect(function() ClickSound:Play(); cb() end)
		end
		
		function TabElements:CreateToggle(text, default, callback)
			local TglFrame = Instance.new("Frame", Scroll)
			TglFrame.Size = UDim2.new(1, -10, 0, 35)
			TglFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
			Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)
			
			local TglText = Instance.new("TextLabel", TglFrame)
			TglText.Size = UDim2.new(0.7, 0, 1, 0); TglText.Position = UDim2.new(0, 10, 0, 0)
			TglText.BackgroundTransparency = 1; TglText.Text = text; TglText.TextColor3 = Color3.fromRGB(200,200,200)
			TglText.Font = Enum.Font.GothamMedium; TglText.TextSize = 12; TglText.TextXAlignment = "Left"

			local TglBtn = Instance.new("TextButton", TglFrame)
			TglBtn.Size = UDim2.new(0, 40, 0, 20); TglBtn.Position = UDim2.new(1, -50, 0.5, -10)
			TglBtn.BackgroundColor3 = default and Color3.fromRGB(114, 137, 218) or Color3.fromRGB(80, 80, 80)
			TglBtn.Text = ""; Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(1, 0)

			local Ind = Instance.new("Frame", TglBtn)
			Ind.Size = UDim2.new(0, 16, 0, 16); Ind.Position = UDim2.new(0, default and 22 or 2, 0.5, -8)
			Ind.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

			local state = default
			TglBtn.MouseButton1Click:Connect(function()
				ClickSound:Play(); state = not state
				TweenService:Create(TglBtn, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(114, 137, 218) or Color3.fromRGB(80, 80, 80)}):Play()
				TweenService:Create(Ind, TweenInfo.new(0.3), {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}):Play()
				callback(state)
			end)
		end

		function TabElements:CreateSlider(text, min, max, default, callback)
			local SFrame = Instance.new("Frame", Scroll)
			SFrame.Size = UDim2.new(1, -10, 0, 45)
			SFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
			Instance.new("UICorner", SFrame).CornerRadius = UDim.new(0, 6)

			local SText = Instance.new("TextLabel", SFrame)
			SText.Size = UDim2.new(1, -20, 0, 20); SText.Position = UDim2.new(0, 10, 0, 5)
			SText.BackgroundTransparency = 1; SText.Text = text .. ": " .. default; SText.TextColor3 = Color3.fromRGB(200, 200, 200)
			SText.Font = Enum.Font.GothamMedium; SText.TextSize = 12; SText.TextXAlignment = "Left"

			local SBar = Instance.new("Frame", SFrame)
			SBar.Size = UDim2.new(1, -20, 0, 6); SBar.Position = UDim2.new(0, 10, 0, 30)
			SBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			Instance.new("UICorner", SBar).CornerRadius = UDim.new(1, 0)

			local SFill = Instance.new("Frame", SBar)
			local percent = (default - min) / (max - min)
			SFill.Size = UDim2.new(percent, 0, 1, 0)
			SFill.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
			Instance.new("UICorner", SFill).CornerRadius = UDim.new(1, 0)

			local dragging = false
			local function UpdateSlider(input)
				local pos = math.clamp((input.Position.X - SBar.AbsolutePosition.X) / SBar.AbsoluteSize.X, 0, 1)
				local val = math.floor(min + (max - min) * pos)
				SFill.Size = UDim2.new(pos, 0, 1, 0)
				SText.Text = text .. ": " .. val
				callback(val)
			end

			SBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateSlider(input)
				end
			end)

			UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			UIS.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end)
		end

		function TabElements:CreateDropdown(text, options, default, callback)
			local DFrame = Instance.new("Frame", Scroll)
			DFrame.Size = UDim2.new(1, -10, 0, 35)
			DFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
			DFrame.ClipsDescendants = true
			Instance.new("UICorner", DFrame).CornerRadius = UDim.new(0, 6)

			local DBtn = Instance.new("TextButton", DFrame)
			DBtn.Size = UDim2.new(1, 0, 0, 35)
			DBtn.BackgroundTransparency = 1; DBtn.Text = text .. ": " .. (default or "None")
			DBtn.TextColor3 = Color3.fromRGB(200, 200, 200); DBtn.Font = Enum.Font.GothamMedium; DBtn.TextSize = 12

			local DScroll = Instance.new("ScrollingFrame", DFrame)
			DScroll.Size = UDim2.new(1, 0, 0, 100); DScroll.Position = UDim2.new(0, 0, 0, 35)
			DScroll.BackgroundTransparency = 1; DScroll.ScrollBarThickness = 2
			local DList = Instance.new("UIListLayout", DScroll)

			local open = false
			DBtn.MouseButton1Click:Connect(function()
				open = not open
				TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = open and UDim2.new(1, -10, 0, 140) or UDim2.new(1, -10, 0, 35)}):Play()
			end)

			for _, opt in pairs(options) do
				local o = Instance.new("TextButton", DScroll)
				o.Size = UDim2.new(1, 0, 0, 30); o.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
				o.Text = opt; o.TextColor3 = Color3.fromRGB(180, 180, 180); o.Font = Enum.Font.Gotham; o.TextSize = 12
				o.MouseButton1Click:Connect(function()
					DBtn.Text = text .. ": " .. opt
					callback(opt)
					open = false
					TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 35)}):Play()
				end)
			end
		end

		function TabElements:CreateKeybind(text, default, callback)
			local KFrame = Instance.new("Frame", Scroll)
			KFrame.Size = UDim2.new(1, -10, 0, 35)
			KFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
			Instance.new("UICorner", KFrame).CornerRadius = UDim.new(0, 6)

			local KText = Instance.new("TextLabel", KFrame)
			KText.Size = UDim2.new(0.7, 0, 1, 0); KText.Position = UDim2.new(0, 10, 0, 0)
			KText.BackgroundTransparency = 1; KText.Text = text; KText.TextColor3 = Color3.fromRGB(200, 200, 200)
			KText.Font = Enum.Font.GothamMedium; KText.TextSize = 12; KText.TextXAlignment = "Left"

			local KBtn = Instance.new("TextButton", KFrame)
			KBtn.Size = UDim2.new(0, 80, 0, 25); KBtn.Position = UDim2.new(1, -90, 0.5, -12)
			KBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
			KBtn.Text = default and default.Name or "None"
			KBtn.TextColor3 = Color3.new(1, 1, 1); KBtn.Font = Enum.Font.GothamBold; KBtn.TextSize = 11
			Instance.new("UICorner", KBtn).CornerRadius = UDim.new(0, 4)

			local binding = false
			KBtn.MouseButton1Click:Connect(function()
				binding = true
				KBtn.Text = "..."
			end)

			UIS.InputBegan:Connect(function(input)
				if binding and input.UserInputType == Enum.UserInputType.Keyboard then
					binding = false
					KBtn.Text = input.KeyCode.Name
					callback(input.KeyCode)
				end
			end)
		end

		function TabElements:CreateTextBox(placeholder, callback)
			local BoxFrame = Instance.new("Frame", Scroll)
			BoxFrame.Size = UDim2.new(1, -10, 0, 40)
			BoxFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
			Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)
			local Box = Instance.new("TextBox", BoxFrame)
			Box.Size = UDim2.new(1, -20, 1, 0); Box.Position = UDim2.new(0, 10, 0, 0)
			Box.BackgroundTransparency = 1; Box.PlaceholderText = placeholder; Box.TextColor3 = Color3.new(1,1,1)
			Box.Font = Enum.Font.Gotham; Box.TextSize = 13; Box.TextXAlignment = "Left"
			Box.FocusLost:Connect(function(enter) callback(Box.Text, enter) end)
		end

		function TabElements:CreateLabel(txt)
			local l = Instance.new("TextLabel", Scroll)
			l.Size = UDim2.new(1, -10, 0, 25); l.BackgroundTransparency = 1; l.Text = txt
			l.TextColor3 = Color3.fromRGB(200, 200, 200); l.Font = Enum.Font.GothamMedium; l.TextXAlignment = "Left"
		end
		return TabElements
	end

	return Window
end

return UniversalLib
