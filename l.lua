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
	CustomAnimations = nil
}

-- ==========================================
-- [ UTILITIES ]
-- ==========================================
local function Log(message)
	if UniversalLib.Config.DebugLogging then
		print("[UniversalLib Debug] " .. tostring(message))
	end
end

function UniversalLib.SetService(name) UniversalLib.Config.Service = name; Log("Service set to: " .. tostring(name)) end
function UniversalLib.SetIdentifier(id) UniversalLib.Config.Identifier = tostring(id); Log("Identifier set to: " .. tostring(id)) end
function UniversalLib.SetProvider(name) UniversalLib.Config.Provider = name; Log("Provider set to: " .. tostring(name)) end
function UniversalLib.IsUsingJnkie(bool) UniversalLib.Config.UseJnkie = bool; Log("UseJnkie set to: " .. tostring(bool)) end
function UniversalLib.DebugLogging(bool) UniversalLib.Config.DebugLogging = bool end
function UniversalLib.SaveKey(bool) UniversalLib.Config.AutoSaveKey = (bool == nil) and true or bool end
function UniversalLib.LoadKey(bool) UniversalLib.Config.AutoLoadKey = (bool == nil) and true or bool end
function UniversalLib.SetCustomAnimation(animTable) UniversalLib.Config.CustomAnimations = animTable end

local function GetKeyFileName()
	return (UniversalLib.Config.Service or "Universal") .. "_" .. (UniversalLib.Config.Identifier or "Default") .. "_Key.txt"
end

local function WriteKeyToFile(key)
	if UniversalLib.Config.AutoSaveKey and writefile then
		local fileName = GetKeyFileName()
		pcall(function() writefile(fileName, key) end)
	end
end

-- ==========================================
-- [ SERVICES & DEVICE INFO ]
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
local realUsername = LocalPlayer and LocalPlayer.Name or "Unknown"
local realUserId = LocalPlayer and tostring(LocalPlayer.UserId) or "0000000"

local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local fakeUsername = ""
for i = 1, 10 do
	local rand = math.random(1, #charset)
	fakeUsername = fakeUsername .. string.sub(charset, rand, rand)
end
local fakeUserId = tostring(math.random(100000000, 999999999))

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

local function CreateCircleShadow(parent, sizeMulti, transparency)
	local glow = Instance.new("Frame", parent)
	glow.Size = UDim2.new(sizeMulti, 0, sizeMulti, 0)
	glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundColor3 = Color3.new(0, 0, 0)
	glow.BackgroundTransparency = transparency
	glow.ZIndex = parent.ZIndex - 1
	Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
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
			local success, savedKey = pcall(function() return readfile(fileName) end)
			if success and savedKey ~= "" then
				local checkOk, res = pcall(function() return J.check_key(savedKey) end)
				if checkOk and res and res.valid then
					if callback then callback() end
					return 
				end
			end
		end
	end

	local guiName = "PremiumKeyUI_Gateway"
	if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end

	local G = Instance.new("ScreenGui")
	G.Name = guiName
	G.ResetOnSpawn = false
	G.IgnoreGuiInset = true
	local success, result = pcall(function() return gethui() end)
	G.Parent = success and result or CoreGui

	local ClickSound = CreateSound(G, "140387697208266", 0.45)
	local SuccessSound = CreateSound(G, "140072726814802", 0.55)

	local GatewayState = { Minimized = false, SettingsOpen = false, StreamerMode = false, isWindowFocused = true, RGBConnection = nil }

	local FloatingBall = Instance.new("TextButton", G)
	FloatingBall.Size = UDim2.new(0, 50, 0, 50)
	FloatingBall.Position = UDim2.new(0.5, -25, 0.1, 0)
	FloatingBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FloatingBall.Text = "🔑"
	FloatingBall.TextSize = 20
	FloatingBall.Visible = false
	Instance.new("UICorner", FloatingBall).CornerRadius = UDim.new(1, 0)
	ApplyGradient(FloatingBall, Color3.fromRGB(114, 137, 218), Color3.fromRGB(180, 130, 255))
	CreateCircleShadow(FloatingBall, 1.2, 0.7)

	local MainCanvas = Instance.new("Frame", G)
	MainCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
	MainCanvas.Size = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 650, 0, 380)
	MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainCanvas.BackgroundTransparency = 1

	local Main = Instance.new("Frame", MainCanvas)
	Main.Size = UDim2.new(1, 0, 1, 0)
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Main.ClipsDescendants = true
	ApplyGradient(Main, Color3.fromRGB(25, 25, 30), Color3.fromRGB(12, 12, 15))
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Transparency = 0.7
	MainStroke.Color = Color3.fromRGB(255, 255, 255)

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
	TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left

	local function CreateCtrlButton(text, xPos)
		local btn = Instance.new("TextButton", Top)
		btn.Size = UDim2.new(0, 25, 0, 25)
		btn.Position = UDim2.new(1, xPos, 0, (Top.Size.Y.Offset - 25) / 2)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
		return btn
	end

	local BtnClose = CreateCtrlButton("X", -35)
	local BtnMin = CreateCtrlButton("-", -65)

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
	StatusText.TextSize = 12
	StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)

	local KeyInput = Instance.new("TextBox", LeftPanel)
	KeyInput.Size = UDim2.new(1, -30, 0, 40)
	KeyInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	KeyInput.PlaceholderText = "Enter Key..."
	KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeyInput.Font = Enum.Font.Gotham
	KeyInput.TextSize = 13
	Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
	local KeyStroke = Instance.new("UIStroke", KeyInput)
	KeyStroke.Color = Color3.fromRGB(255, 255, 255)
	KeyStroke.Transparency = 0.8

	local BtnValidate = Instance.new("TextButton", LeftPanel)
	BtnValidate.Size = UDim2.new(1, -30, 0, 40)
	BtnValidate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

	BtnClose.MouseButton1Click:Connect(function() G:Destroy() end)
end

-- ==========================================
-- [ MAIN UI HUB LIBRARY ]
-- ==========================================
function UniversalLib:CreateWindow(config)
	config = config or {}
	local title = config.Title or "HUB"
	local subtitle = config.Subtitle or "Universal"
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

	local Window = { ActiveTab = nil, Minimized = false, SettingsOpen = false, RGBConnection = nil }

	local G = Instance.new("ScreenGui")
	G.Name = "UniversalLib_Hub_" .. title
	G.ResetOnSpawn = false
	G.IgnoreGuiInset = true
	local success, result = pcall(function() return gethui() end)
	G.Parent = success and result or CoreGui

	local HoverSound = CreateSound(G, "140404505414006", 0.35)
	local ClickSound = CreateSound(G, "140387697208266", 0.45)

	-- Floating Ball
	local FloatingBall = Instance.new("TextButton", G)
	FloatingBall.Size = UDim2.new(0, 50, 0, 50)
	FloatingBall.Position = UDim2.new(0.5, -25, 0.1, 0)
	FloatingBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FloatingBall.Text = "✨"
	FloatingBall.TextSize = 20
	FloatingBall.Visible = false
	Instance.new("UICorner", FloatingBall).CornerRadius = UDim.new(1, 0)
	ApplyGradient(FloatingBall, Color3.fromRGB(114, 137, 218), Color3.fromRGB(180, 130, 255))
	CreateCircleShadow(FloatingBall, 1.2, 0.7)

	local MainCanvas = Instance.new("Frame", G)
	MainCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
	MainCanvas.Size = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 650, 0, 380)
	MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainCanvas.BackgroundTransparency = 1

	local Main = Instance.new("Frame", MainCanvas)
	Main.Size = UDim2.new(1, 0, 1, 0)
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Main.ClipsDescendants = true
	ApplyGradient(Main, Color3.fromRGB(25, 25, 30), Color3.fromRGB(12, 12, 15))
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Transparency = 0.7
	MainStroke.Color = Color3.fromRGB(255, 255, 255)

	local Top = Instance.new("Frame", Main)
	Top.Size = UDim2.new(1, 0, 0, isMobile and 35 or 45)
	Top.BackgroundTransparency = 1

	local TitleText = Instance.new("TextLabel", Top)
	TitleText.Size = UDim2.new(0.8, 0, 1, 0)
	TitleText.Position = UDim2.new(0, 15, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Text = title .. " <font color='rgb(150,150,150)'>| " .. subtitle .. "</font>"
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextSize = 13
	TitleText.RichText = true
	TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left

	local function CreateCtrlButton(text, xPos)
		local btn = Instance.new("TextButton", Top)
		btn.Size = UDim2.new(0, 25, 0, 25)
		btn.Position = UDim2.new(1, xPos, 0, (Top.Size.Y.Offset - 25) / 2)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		btn.Font = Enum.Font.GothamBold
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
		return btn
	end

	local BtnClose = CreateCtrlButton("X", -35)
	local BtnMin = CreateCtrlButton("-", -65)
	local BtnSettings = CreateCtrlButton("⚙", -95)

	local TabPanel = Instance.new("ScrollingFrame", Main)
	TabPanel.Size = UDim2.new(0.3, 0, 1, -Top.Size.Y.Offset)
	TabPanel.Position = UDim2.new(0, 0, 0, Top.Size.Y.Offset)
	TabPanel.BackgroundTransparency = 1
	TabPanel.ScrollBarThickness = 0
	Instance.new("UIListLayout", TabPanel).Padding = UDim.new(0, 5)
	TabPanel.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", TabPanel).PaddingTop = UDim.new(0, 10)

	local ContentPanel = Instance.new("Frame", Main)
	ContentPanel.Size = UDim2.new(0.7, 0, 1, -Top.Size.Y.Offset)
	ContentPanel.Position = UDim2.new(0.3, 0, 0, Top.Size.Y.Offset)
	ContentPanel.BackgroundTransparency = 1

	-- FIXED SETTINGS AREA: Higher ZIndex and parenting to cover Tab contents
	local SettingsOverlay = Instance.new("ScrollingFrame", Main)
	SettingsOverlay.Size = UDim2.new(0.7, -20, 1, -Top.Size.Y.Offset - 20)
	SettingsOverlay.Position = UDim2.new(1, 10, 0, Top.Size.Y.Offset + 10) 
	SettingsOverlay.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	SettingsOverlay.ZIndex = 100 -- STAY ON TOP
	SettingsOverlay.ScrollBarThickness = 2
	Instance.new("UICorner", SettingsOverlay).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", SettingsOverlay).Color = Color3.fromRGB(60, 60, 70)
	
	local SetList = Instance.new("UIListLayout", SettingsOverlay)
	SetList.Padding = UDim.new(0, 8)
	SetList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", SettingsOverlay).PaddingTop = UDim.new(0, 10)

	local function CreateInternalToggle(parent, text, defaultState, callback)
		local TglFrame = Instance.new("Frame", parent)
		TglFrame.Size = UDim2.new(1, -20, 0, 35)
		TglFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		TglFrame.ZIndex = parent.ZIndex + 1
		Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)

		local TglText = Instance.new("TextLabel", TglFrame)
		TglText.Size = UDim2.new(0.7, 0, 1, 0)
		TglText.Position = UDim2.new(0, 10, 0, 0)
		TglText.BackgroundTransparency = 1
		TglText.Text = text
		TglText.Font = Enum.Font.GothamMedium
		TglText.TextSize = 12
		TglText.TextColor3 = Color3.fromRGB(200, 200, 200)
		TglText.TextXAlignment = Enum.TextXAlignment.Left
		TglText.ZIndex = TglFrame.ZIndex

		local TglBtn = Instance.new("TextButton", TglFrame)
		TglBtn.Size = UDim2.new(0, 40, 0, 20)
		TglBtn.Position = UDim2.new(1, -50, 0.5, -10)
		TglBtn.BackgroundColor3 = defaultState and Color3.fromRGB(114, 137, 218) or Color3.fromRGB(80, 80, 80)
		TglBtn.Text = ""
		TglBtn.ZIndex = TglFrame.ZIndex
		Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(1, 0)

		local Indicator = Instance.new("Frame", TglBtn)
		Indicator.Size = UDim2.new(0, 16, 0, 16)
		Indicator.Position = UDim2.new(0, defaultState and 22 or 2, 0.5, -8)
		Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Indicator.ZIndex = TglBtn.ZIndex
		Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

		local state = defaultState
		TglBtn.MouseButton1Click:Connect(function()
			ClickSound:Play()
			state = not state
			TweenService:Create(TglBtn, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(114, 137, 218) or Color3.fromRGB(80, 80, 80)}):Play()
			TweenService:Create(Indicator, TweenInfo.new(0.3), {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}):Play()
			callback(state)
		end)
	end

	-- PUBLIC SETTINGS API
	function Window:AddSettingToggle(text, default, callback)
		CreateInternalToggle(SettingsOverlay, text, default, callback)
	end

	function Window:AddSettingButton(text, callback)
		local Btn = Instance.new("TextButton", SettingsOverlay)
		Btn.Size = UDim2.new(1, -20, 0, 35)
		Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		Btn.Text = text
		Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		Btn.Font = Enum.Font.GothamBold
		Btn.TextSize = 12
		Btn.ZIndex = SettingsOverlay.ZIndex + 1
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		Btn.MouseButton1Click:Connect(function() ClickSound:Play(); callback() end)
	end

	-- Default Toggles
	Window:AddSettingToggle("RGB Mode", false, function(s)
		if s then
			local hue = 0
			Window.RGBConnection = RunService.RenderStepped:Connect(function(dt)
				hue = (hue + dt * 0.1) % 1
				MainStroke.Color = Color3.fromHSV(hue, 0.8, 1)
			end)
		else
			if Window.RGBConnection then Window.RGBConnection:Disconnect() end
			MainStroke.Color = Color3.fromRGB(255, 255, 255)
		end
	end)

	BtnSettings.MouseButton1Click:Connect(function()
		ClickSound:Play()
		Window.SettingsOpen = not Window.SettingsOpen
		local targetPos = Window.SettingsOpen and UDim2.new(0.3, 10, 0, Top.Size.Y.Offset + 10) or UDim2.new(1, 10, 0, Top.Size.Y.Offset + 10)
		TweenService:Create(SettingsOverlay, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = targetPos}):Play()
	end)

	-- Tab & Drag Setup (Simplified for syntax verification)
	local function MakeDraggable(dragArea, object)
		local dragging, dragInput, dragStart, startPos
		dragArea.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging, dragStart, startPos = true, input.Position, object.Position
				input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging then
				local delta = input.Position - dragStart
				object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end
	MakeDraggable(Top, MainCanvas)

	function Window:CreateTab(tabName)
		local TabBtn = Instance.new("TextButton", TabPanel)
		TabBtn.Size = UDim2.new(1, -10, 0, 35)
		TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		TabBtn.Text = tabName
		TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		TabBtn.Font = Enum.Font.GothamMedium
		TabBtn.TextSize = 13
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

		local TabContainer = Instance.new("ScrollingFrame", ContentPanel)
		TabContainer.Size = UDim2.new(1, -20, 1, -20)
		TabContainer.Position = UDim2.new(0, 10, 0, 10)
		TabContainer.BackgroundTransparency = 1
		TabContainer.ScrollBarThickness = 2
		TabContainer.Visible = false
		local ContainerList = Instance.new("UIListLayout", TabContainer)
		ContainerList.Padding = UDim.new(0, 8)
		ContainerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabContainer.CanvasSize = UDim2.new(0, 0, 0, ContainerList.AbsoluteContentSize.Y + 10)
		end)

		if not Window.ActiveTab then Window.ActiveTab = TabContainer; TabContainer.Visible = true; TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end

		TabBtn.MouseButton1Click:Connect(function()
			ClickSound:Play()
			for _, child in pairs(ContentPanel:GetChildren()) do if child:IsA("ScrollingFrame") then child.Visible = false end end
			TabContainer.Visible = true
		end)

		local TabElements = {}
		function TabElements:CreateButton(txt, cb)
			local b = Instance.new("TextButton", TabContainer)
			b.Size = UDim2.new(1, -10, 0, 38)
			b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			b.Text = txt
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.GothamBold
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			b.MouseButton1Click:Connect(function() ClickSound:Play(); cb() end)
		end
		function TabElements:CreateToggle(txt, def, cb) CreateInternalToggle(TabContainer, txt, def, cb) end
		function TabElements:CreateLabel(txt)
			local l = Instance.new("TextLabel", TabContainer)
			l.Size = UDim2.new(1, -10, 0, 25)
			l.BackgroundTransparency = 1
			l.Text = txt
			l.TextColor3 = Color3.fromRGB(200, 200, 200)
			l.Font = Enum.Font.GothamMedium
			l.TextXAlignment = Enum.TextXAlignment.Left
		end
		return TabElements
	end

	BtnClose.MouseButton1Click:Connect(function() G:Destroy() end)
	return Window
end

return UniversalLib
