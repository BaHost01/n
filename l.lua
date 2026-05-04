local UniversalLib = {}

-- [ LIBRARY CONFIGURATION ]
UniversalLib.Config = {
	Service = "Universal",
	Identifier = "1092079",
	Provider = "Universal",
	UseJnkie = false
}

-- [ CONFIGURATION FUNCTIONS ]
function UniversalLib.SetService(name) UniversalLib.Config.Service = name end
function UniversalLib.SetIdentifier(id) UniversalLib.Config.Identifier = tostring(id) end
function UniversalLib.SetProvider(name) UniversalLib.Config.Provider = name end
function UniversalLib.IsUsingJnkie(bool) UniversalLib.Config.UseJnkie = bool end


-- [ SERVICES ]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- [ DEVICE DETECTION & UTILS ]
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
local deviceIcon = isMobile and "📱 Mobile" or "💻 PC"

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
-- KEY SYSTEM GATEWAY (JNKIE API)
-- ==========================================
function UniversalLib.StartUserScript(callback)
	if not UniversalLib.Config.UseJnkie then
		-- Bypass Key System completely
		if callback then callback() end
		return
	end

	-- Load SDK
	local ok, J = pcall(function() return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
	if not ok or not J then
		warn("Failed to load Jnkie SDK. Check your internet or API status.")
		return
	end
	
	J.service = UniversalLib.Config.Service
	J.identifier = UniversalLib.Config.Identifier
	J.provider = UniversalLib.Config.Provider

	-- Build Key UI
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

	local MainCanvas = Instance.new("Frame", G)
	MainCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
	MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainCanvas.Size = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 650, 0, 380)
	MainCanvas.BackgroundTransparency = 1

	local Main = Instance.new("Frame", MainCanvas)
	Main.Size = UDim2.new(1, 0, 1, 0)
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	ApplyGradient(Main, Color3.fromRGB(25, 25, 30), Color3.fromRGB(12, 12, 15))
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Transparency = 0.7
	MainStroke.Color = Color3.fromRGB(255, 255, 255)

	local Top = Instance.new("Frame", Main)
	Top.Size = UDim2.new(1, 0, 0, isMobile and 35 or 45)
	Top.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	Top.BorderSizePixel = 0
	ApplyGradient(Top, Color3.fromRGB(35, 35, 40), Color3.fromRGB(18, 18, 22))

	local TitleText = Instance.new("TextLabel", Top)
	TitleText.Size = UDim2.new(0.8, 0, 1, 0)
	TitleText.Position = UDim2.new(0, 15, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Text = "KEY SYSTEM <font color='rgb(150,150,150)'>| Authentication</font>"
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextSize = isMobile and 11 or 13
	TitleText.RichText = true
	TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left

	local LeftPanel = Instance.new("Frame", Main)
	LeftPanel.Size = UDim2.new(0.45, 0, 1, -Top.Size.Y.Offset)
	LeftPanel.Position = UDim2.new(0, 0, 0, Top.Size.Y.Offset)
	LeftPanel.BackgroundTransparency = 1
	
	local LeftList = Instance.new("UIListLayout", LeftPanel)
	LeftList.Padding = UDim.new(0, 10)
	LeftList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	LeftList.VerticalAlignment = Enum.VerticalAlignment.Center

	local RightPanel = Instance.new("Frame", Main)
	RightPanel.Size = UDim2.new(0.55, 0, 1, -Top.Size.Y.Offset)
	RightPanel.Position = UDim2.new(0.45, 0, 0, Top.Size.Y.Offset)
	RightPanel.BackgroundTransparency = 1

	local Thumbnail = Instance.new("ImageLabel", RightPanel)
	Thumbnail.Size = UDim2.new(1, -30, 1, -30)
	Thumbnail.Position = UDim2.new(0, 15, 0, 15)
	Thumbnail.Image = "rbxthumb://type=Asset&id=" .. game.PlaceId .. "&w=768&h=432"
	Thumbnail.ScaleType = Enum.ScaleType.Crop
	Thumbnail.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Instance.new("UICorner", Thumbnail).CornerRadius = UDim.new(0, 8)

	local StatusText = Instance.new("TextLabel", LeftPanel)
	StatusText.Size = UDim2.new(1, -30, 0, 20)
	StatusText.BackgroundTransparency = 1
	StatusText.Text = "Status: Waiting for Key..."
	StatusText.Font = Enum.Font.GothamMedium
	StatusText.TextSize = 12
	StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
	StatusText.TextXAlignment = Enum.TextXAlignment.Left

	local InputWrapper = Instance.new("Frame", LeftPanel)
	InputWrapper.Size = UDim2.new(1, -30, 0, isMobile and 35 or 40)
	InputWrapper.BackgroundTransparency = 1

	local KeyInput = Instance.new("TextBox", InputWrapper)
	KeyInput.Size = UDim2.new(1, 0, 1, 0)
	KeyInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	KeyInput.PlaceholderText = "Paste your key here..."
	KeyInput.Text = ""
	KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeyInput.Font = Enum.Font.Gotham
	KeyInput.TextSize = 13
	Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
	local KeyStroke = Instance.new("UIStroke", KeyInput)
	KeyStroke.Transparency = 0.8
	KeyStroke.Color = Color3.fromRGB(255, 255, 255)

	local function CreateButton(text, bgColor, txtColor)
		local btn = Instance.new("TextButton", LeftPanel)
		btn.Size = UDim2.new(1, -30, 0, isMobile and 35 or 40)
		btn.BackgroundColor3 = bgColor
		btn.Text = text
		btn.TextColor3 = txtColor
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 13
		btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		
		btn.MouseButton1Down:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -34, 0, isMobile and 31 or 36)}):Play() end)
		btn.MouseButton1Up:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(1, -30, 0, isMobile and 35 or 40)}):Play() end)
		return btn
	end

	local BtnGetKey = CreateButton("GET KEY", Color3.fromRGB(255, 255, 255), Color3.fromRGB(15, 15, 15))
	local BtnValidate = CreateButton("VALIDATE", Color3.fromRGB(40, 40, 45), Color3.fromRGB(255, 255, 255))
	Instance.new("UIStroke", BtnValidate).Color = Color3.fromRGB(150, 150, 150)

	-- Dragging
	local dragging, dragInput, dragStart, startPos
	Top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, input.Position, MainCanvas.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	Top.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainCanvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Logic
	local function ShakeUI()
		local origY = InputWrapper.Position.Y.Offset
		for i = 1, 5 do
			InputWrapper.Position = UDim2.new(InputWrapper.Position.X.Scale, InputWrapper.Position.X.Offset + math.random(-4, 4), InputWrapper.Position.Y.Scale, origY)
			task.wait(0.04)
		end
		InputWrapper.Position = UDim2.new(InputWrapper.Position.X.Scale, 0, InputWrapper.Position.Y.Scale, origY)
	end

	BtnGetKey.MouseButton1Click:Connect(function()
		ClickSound:Play()
		local _, link = pcall(function() return J.get_key_link() end)
		if link and setclipboard then
			setclipboard(link)
			StatusText.Text = "Status: Key Link Copied!"
			StatusText.TextColor3 = Color3.fromRGB(85, 255, 127)
		end
	end)

	BtnValidate.MouseButton1Click:Connect(function()
		ClickSound:Play()
		local key = KeyInput.Text
		if key == "" then ShakeUI() return end

		StatusText.Text = "Status: Checking Key..."
		StatusText.TextColor3 = Color3.fromRGB(255, 255, 127)

		local _, res = pcall(function() return J.check_key(key) end)

		if res and res.valid then
			SuccessSound:Play()
			StatusText.Text = "Status: Validated!"
			StatusText.TextColor3 = Color3.fromRGB(85, 255, 127)
			KeyStroke.Color = Color3.fromRGB(85, 255, 127)
			
			task.wait(0.5)
			TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
			task.wait(0.4)
			G:Destroy()
			
			-- START THE USER'S ACTUAL SCRIPT / UI HERE
			if callback then callback() end
		else
			StatusText.Text = "Status: Invalid Key."
			StatusText.TextColor3 = Color3.fromRGB(255, 85, 85)
			KeyStroke.Color = Color3.fromRGB(255, 85, 85)
			ShakeUI()
		end
	end)
end

-- ==========================================
-- MAIN UI HUB LIBRARY 
-- ==========================================
function UniversalLib:CreateWindow(config)
	config = config or {}
	local title = config.Title or "UNIVERSAL"
	local subtitle = config.Subtitle or game.Name
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

	local guiName = "UniversalLib_" .. title
	if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end

	local Window = { ActiveTab = nil, Minimized = false, SettingsOpen = false, StreamerMode = false, RGBConnection = nil }

	local G = Instance.new("ScreenGui")
	G.Name = guiName
	G.ResetOnSpawn = false
	G.IgnoreGuiInset = true
	local success, result = pcall(function() return gethui() end)
	G.Parent = success and result or CoreGui

	local HoverSound = CreateSound(G, "140404505414006", 0.35)
	local ClickSound = CreateSound(G, "140387697208266", 0.45)

	-- Floating Ball (Minimized)
	local FloatingBall = Instance.new("TextButton", G)
	FloatingBall.Size = UDim2.new(0, 50, 0, 50)
	FloatingBall.Position = UDim2.new(0.5, -25, 0.1, 0)
	FloatingBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FloatingBall.Text = "✨"
	FloatingBall.TextSize = 20
	FloatingBall.Visible = false
	FloatingBall.AutoButtonColor = false
	Instance.new("UICorner", FloatingBall).CornerRadius = UDim.new(1, 0)
	ApplyGradient(FloatingBall, Color3.fromRGB(114, 137, 218), Color3.fromRGB(180, 130, 255))
	
	local function CreateCircleShadow(parent, sizeMulti, transparency)
		local glow = Instance.new("Frame", parent)
		glow.Size = UDim2.new(sizeMulti, 0, sizeMulti, 0)
		glow.Position = UDim2.new(0.5, 0, 0.5, 0)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.BackgroundColor3 = Color3.new(0, 0, 0)
		glow.BackgroundTransparency = transparency
		glow.ZIndex = -1
		Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
	end
	CreateCircleShadow(FloatingBall, 1.2, 0.7)
	CreateCircleShadow(FloatingBall, 1.4, 0.85)

	-- Main UI
	local MainCanvas = Instance.new("Frame", G)
	MainCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
	MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainCanvas.Size = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 650, 0, 380)
	MainCanvas.BackgroundTransparency = 1

	local Main = Instance.new("Frame", MainCanvas)
	Main.Size = UDim2.new(1, 0, 1, 0)
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	ApplyGradient(Main, Color3.fromRGB(25, 25, 30), Color3.fromRGB(12, 12, 15))
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Transparency = 0.7
	MainStroke.Color = Color3.fromRGB(255, 255, 255)

	local Top = Instance.new("Frame", Main)
	Top.Size = UDim2.new(1, 0, 0, isMobile and 35 or 45)
	Top.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	Top.BorderSizePixel = 0
	ApplyGradient(Top, Color3.fromRGB(35, 35, 40), Color3.fromRGB(18, 18, 22))

	local TitleText = Instance.new("TextLabel", Top)
	TitleText.Size = UDim2.new(0.8, 0, 1, 0)
	TitleText.Position = UDim2.new(0, 15, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Text = title .. " <font color='rgb(150,150,150)'>| " .. subtitle .. " | " .. deviceIcon .. "</font>"
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextSize = isMobile and 11 or 13
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
		btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
		return btn
	end

	local BtnClose = CreateCtrlButton("X", -35)
	local BtnMin = CreateCtrlButton("-", -65)

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
	ContentPanel.ClipsDescendants = true

	-- Toggles & Min/Max Logic
	local function ToggleMinimize()
		Window.Minimized = not Window.Minimized
		if Window.Minimized then
			TweenService:Create(MainCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
			task.wait(0.2)
			MainCanvas.Visible = false
			FloatingBall.Visible = true
			FloatingBall.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(FloatingBall, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
		else
			TweenService:Create(FloatingBall, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
			task.wait(0.2)
			FloatingBall.Visible = false
			MainCanvas.Visible = true
			TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 650, 0, 380)}):Play()
		end
	end

	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == toggleKey then ToggleMinimize() end
	end)
	BtnMin.MouseButton1Click:Connect(function() ClickSound:Play() ToggleMinimize() end)
	FloatingBall.MouseButton1Click:Connect(function() ClickSound:Play() ToggleMinimize() end)

	BtnClose.MouseButton1Click:Connect(function()
		ClickSound:Play()
		TweenService:Create(MainCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(0.3)
		G:Destroy()
	end)

	-- Drag Logic for Main Hub
	local dragging, dragInput, dragStart, startPos
	Top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, input.Position, MainCanvas.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	Top.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainCanvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	local bDrag, bInput, bStart, bPos
	FloatingBall.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bDrag, bStart, bPos = true, input.Position, FloatingBall.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then bDrag = false end end)
		end
	end)
	FloatingBall.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then bInput = input end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == bInput and bDrag then
			local delta = input.Position - bStart
			FloatingBall.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + delta.X, bPos.Y.Scale, bPos.Y.Offset + delta.Y)
		end
	end)


	function Window:CreateTab(tabName)
		local TabBtn = Instance.new("TextButton", TabPanel)
		TabBtn.Size = UDim2.new(1, -10, 0, 35)
		TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		TabBtn.Text = tabName
		TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		TabBtn.Font = Enum.Font.GothamMedium
		TabBtn.TextSize = 13
		TabBtn.AutoButtonColor = false
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
		local TabStroke = Instance.new("UIStroke", TabBtn)
		TabStroke.Color = Color3.fromRGB(114, 137, 218)
		TabStroke.Transparency = 1

		local TabContainer = Instance.new("ScrollingFrame", ContentPanel)
		TabContainer.Size = UDim2.new(1, -20, 1, -20)
		TabContainer.Position = UDim2.new(0, 10, 0, 10)
		TabContainer.BackgroundTransparency = 1
		TabContainer.ScrollBarThickness = 2
		TabContainer.Visible = false

		local ContainerList = Instance.new("UIListLayout", TabContainer)
		ContainerList.Padding = UDim.new(0, 8)
		ContainerList.SortOrder = Enum.SortOrder.LayoutOrder

		ContainerList.GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabContainer.CanvasSize = UDim2.new(0, 0, 0, ContainerList.AbsoluteContentSize.Y + 10)
		end)

		if not Window.ActiveTab then
			Window.ActiveTab = TabContainer
			TabContainer.Visible = true
			TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
			TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			TabStroke.Transparency = 0
		end

		TabBtn.MouseButton1Click:Connect(function()
			ClickSound:Play()
			for _, child in pairs(TabPanel:GetChildren()) do
				if child:IsA("TextButton") then
					TweenService:Create(child, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 25), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
					TweenService:Create(child.UIStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
				end
			end
			for _, child in pairs(ContentPanel:GetChildren()) do
				if child:IsA("ScrollingFrame") then child.Visible = false end
			end
			
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			TweenService:Create(TabStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
			TabContainer.Visible = true
			Window.ActiveTab = TabContainer
		end)

		local TabElements = {}

		function TabElements:CreateButton(btnText, callback)
			local Btn = Instance.new("TextButton", TabContainer)
			Btn.Size = UDim2.new(1, -10, 0, 38)
			Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			Btn.Text = btnText
			Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			Btn.Font = Enum.Font.GothamBold
			Btn.TextSize = 13
			Btn.AutoButtonColor = false
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			
			Btn.MouseEnter:Connect(function() HoverSound:Play() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play() end)
			Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play() end)
			Btn.MouseButton1Down:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -14, 0, 34)}):Play() end)
			Btn.MouseButton1Up:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(1, -10, 0, 38)}):Play() end)

			Btn.MouseButton1Click:Connect(function()
				ClickSound:Play()
				callback()
			end)
		end

		function TabElements:CreateToggle(text, defaultState, callback)
			local TglFrame = Instance.new("Frame", TabContainer)
			TglFrame.Size = UDim2.new(1, -10, 0, 35)
			TglFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
			Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)

			local TglText = Instance.new("TextLabel", TglFrame)
			TglText.Size = UDim2.new(0.7, 0, 1, 0)
			TglText.Position = UDim2.new(0, 10, 0, 0)
			TglText.BackgroundTransparency = 1
			TglText.Text = text
			TglText.Font = Enum.Font.GothamMedium
			TglText.TextSize = 13
			TglText.TextColor3 = Color3.fromRGB(200, 200, 200)
			TglText.TextXAlignment = Enum.TextXAlignment.Left

			local TglBtn = Instance.new("TextButton", TglFrame)
			TglBtn.Size = UDim2.new(0, 40, 0, 20)
			TglBtn.Position = UDim2.new(1, -50, 0.5, -10)
			TglBtn.BackgroundColor3 = defaultState and Color3.fromRGB(114, 137, 218) or Color3.fromRGB(80, 80, 80)
			TglBtn.Text = ""
			TglBtn.AutoButtonColor = false
			Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(1, 0)

			local Indicator = Instance.new("Frame", TglBtn)
			Indicator.Size = UDim2.new(0, 16, 0, 16)
			Indicator.Position = UDim2.new(0, defaultState and 22 or 2, 0.5, -8)
			Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

		return TabElements
	end

	return Window
end

return UniversalLib
