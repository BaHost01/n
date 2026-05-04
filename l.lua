local SCRIPT_NAME = "UNIVERSAL"

-- [ API CONFIGURATION ]
local J = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
J.service = "Universal"
J.identifier = "1092079"
J.provider = "Universal"

-- [ SERVICES ]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- [ STATE VARIABLES ]
local validated, closed, minimized = false, false, false
local attempts, maxAttempts = 0, 5
local thumb = "rbxthumb://type=PlaceId&id=" .. game.PlaceId .. "&w=768&h=432"

-- [ CLEANUP OLD UI ]
if CoreGui:FindFirstChild("PremiumKeyUI_Rework") then
	CoreGui.PremiumKeyUI_Rework:Destroy()
end

-- [ UI CONSTRUCTION ]
local G = Instance.new("ScreenGui")
G.Name = "PremiumKeyUI_Rework"
G.ResetOnSpawn = false
G.IgnoreGuiInset = true
G.Parent = CoreGui

-- Sound Effects
local function CreateSound(id, volume)
	local s = Instance.new("Sound", G)
	s.SoundId = "rbxassetid://" .. id
	s.Volume = volume
	return s
end
local HoverSound = CreateSound("140404505414006", 0.35)
local ClickSound = CreateSound("140387697208266", 0.45)
local SuccessSound = CreateSound("140072726814802", 0.55)

-- Main Containers
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 650, 0, 380) -- More compact and modern
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = G

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Transparency = 0.8
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Parent = Main

-- Top Bar
local Top = Instance.new("Frame")
Top.Name = "Top"
Top.Size = UDim2.new(1, 0, 0, 45)
Top.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Top.BorderSizePixel = 0
Top.Parent = Main

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Size = UDim2.new(0.5, 0, 1, 0)
ScriptTitle.Position = UDim2.new(0, 15, 0, 0)
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Text = SCRIPT_NAME .. " <font color='rgb(150,150,150)'>| " .. game.Name .. "</font>"
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.TextSize = 14
ScriptTitle.RichText = true
ScriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
ScriptTitle.Parent = Top

-- Split Main Layout
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0.45, 0, 1, -45)
LeftPanel.Position = UDim2.new(0, 0, 0, 45)
LeftPanel.BackgroundTransparency = 1
LeftPanel.Parent = Main

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0.55, 0, 1, -45)
RightPanel.Position = UDim2.new(0.45, 0, 0, 45)
RightPanel.BackgroundTransparency = 1
RightPanel.Parent = Main

local Thumbnail = Instance.new("ImageLabel")
Thumbnail.Size = UDim2.new(1, -30, 1, -30)
Thumbnail.Position = UDim2.new(0, 15, 0, 15)
Thumbnail.Image = thumb
Thumbnail.ScaleType = Enum.ScaleType.Crop
Thumbnail.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", Thumbnail).CornerRadius = UDim.new(0, 8)
Thumbnail.Parent = RightPanel

-- Left Panel Components
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -30, 0, 20)
StatusText.Position = UDim2.new(0, 15, 0, 15)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Status: Waiting..."
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 13
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = LeftPanel

local AttemptsText = StatusText:Clone()
AttemptsText.Position = UDim2.new(0, 15, 0, 35)
AttemptsText.Text = "Attempts: 0/" .. maxAttempts
AttemptsText.TextColor3 = Color3.fromRGB(150, 150, 150)
AttemptsText.Parent = LeftPanel

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -30, 0, 40)
KeyInput.Position = UDim2.new(0, 15, 0, 80)
KeyInput.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
KeyInput.PlaceholderText = "Paste your key here..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
local KeyStroke = Instance.new("UIStroke", KeyInput)
KeyStroke.Transparency = 0.8
KeyStroke.Color = Color3.fromRGB(255, 255, 255)
KeyInput.Parent = LeftPanel

-- UI Helper Functions
local function CreateButton(parent, text, yPos, bgColor, txtColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -30, 0, 40)
	btn.Position = UDim2.new(0, 15, 0, yPos)
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.TextColor3 = txtColor
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = parent
	return btn
end

local BtnGetKey = CreateButton(LeftPanel, "GET KEY", 135, Color3.fromRGB(255, 255, 255), Color3.fromRGB(15, 15, 15))
local BtnValidate = CreateButton(LeftPanel, "VALIDATE", 185, Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255))
local ValidateStroke = Instance.new("UIStroke", BtnValidate)
ValidateStroke.Transparency = 0.7
ValidateStroke.Color = Color3.fromRGB(255, 255, 255)

local BtnDiscord = Instance.new("ImageButton")
BtnDiscord.Size = UDim2.new(0, 40, 0, 40)
BtnDiscord.Position = UDim2.new(0, 15, 0, 240)
BtnDiscord.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Official Discord Color
BtnDiscord.Image = "rbxassetid://18505728250"
Instance.new("UICorner", BtnDiscord).CornerRadius = UDim.new(0, 6)
BtnDiscord.Parent = LeftPanel

-- Control Buttons (Close/Minimize)
local function CreateCtrlButton(text, xPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 25, 0, 25)
	btn.Position = UDim2.new(1, xPos, 0, 10)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	btn.Parent = Top
	return btn
end

local BtnMin = CreateCtrlButton("-", -65)
local BtnClose = CreateCtrlButton("X", -35)
BtnClose.HoverImage = "" -- Fallback prevent

-- [ ANIMATIONS AND FEATURES ]

local function SetStatus(text, color)
	StatusText.Text = "Status: " .. text
	if color then
		TweenService:Create(StatusText, TweenInfo.new(0.3), {TextColor3 = color}):Play()
	else
		TweenService:Create(StatusText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
	end
end

local function ShakeUI(obj)
	local origX = obj.Position.X.Offset
	local origY = obj.Position.Y.Offset
	for i = 1, 5 do
		local offset = math.random(-4, 4)
		obj.Position = UDim2.new(obj.Position.X.Scale, origX + offset, obj.Position.Y.Scale, origY)
		task.wait(0.04)
	end
	obj.Position = UDim2.new(obj.Position.X.Scale, origX, obj.Position.Y.Scale, origY)
end

local function ApplyHover(btn)
	local originalColor = btn.BackgroundColor3
	local targetColor
	local h, s, v = Color3.toHSV(originalColor)
	
	if v > 0.5 then targetColor = Color3.fromHSV(h, s, v - 0.15) -- Darken if it's light
	else targetColor = Color3.fromHSV(h, s, v + 0.15) end -- Lighten if it's dark

	btn.MouseEnter:Connect(function()
		HoverSound:Play()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		ClickSound:Play()
		TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 4, btn.Size.Y.Scale, btn.Size.Y.Offset - 4)}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 4, btn.Size.Y.Scale, btn.Size.Y.Offset + 4)}):Play()
	end)
end

local buttons = {BtnGetKey, BtnValidate, BtnDiscord, BtnMin, BtnClose}
for _, btn in pairs(buttons) do ApplyHover(btn) end

-- Drag Logic (Draggable)
local function MakeDraggable(topbar, object)
	local dragging, dragInput, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end
MakeDraggable(Top, Main)

-- [ BUTTON EVENTS ]

BtnDiscord.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard("https://discord.gg/gJaG8ngsN2")
		SetStatus("Discord link copied!", Color3.fromRGB(88, 101, 242))
	end
end)

BtnGetKey.MouseButton1Click:Connect(function()
	local ok, link = pcall(function() return J.get_key_link() end)
	if ok and link and setclipboard then
		setclipboard(link)
		SetStatus("Key link copied to clipboard!", Color3.fromRGB(85, 255, 127))
	else
		SetStatus("Failed to get key link.", Color3.fromRGB(255, 85, 85))
	end
end)

BtnValidate.MouseButton1Click:Connect(function()
	if closed or validated then return end

	local key = KeyInput.Text
	if key == "" then
		SetStatus("Please enter a key.", Color3.fromRGB(255, 170, 0))
		ShakeUI(KeyInput)
		return
	end

	attempts += 1
	AttemptsText.Text = "Attempts: " .. attempts .. "/" .. maxAttempts
	SetStatus("Validating...", Color3.fromRGB(255, 255, 127))

	local ok, res = pcall(function() return J.check_key(key) end)

	if ok and res and res.valid then
		SuccessSound:Play()
		validated = true
		getgenv().SCRIPT_KEY = key
		SetStatus("Access Granted!", Color3.fromRGB(85, 255, 127))
		KeyStroke.Color = Color3.fromRGB(85, 255, 127)
		
		task.wait(0.8)
		
		TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 650, 0, 0)}):Play()
		task.wait(0.5)
		G:Destroy()
		return
	end

	SetStatus(res and res.message or "Invalid Key.", Color3.fromRGB(255, 85, 85))
	KeyStroke.Color = Color3.fromRGB(255, 85, 85)
	ShakeUI(KeyInput)

	if attempts >= maxAttempts then
		SetStatus("Max attempts reached.", Color3.fromRGB(255, 85, 85))
		task.wait(1)
		closed = true
		G:Destroy()
	end
end)

BtnMin.MouseButton1Click:Connect(function()
	minimized = not minimized
	local targetSize = minimized and UDim2.new(0, 650, 0, 45) or UDim2.new(0, 650, 0, 380)
	TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

BtnClose.MouseButton1Click:Connect(function()
	TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0, 650, 0, 0)}):Play()
	task.wait(0.2)
	closed = true
	G:Destroy()
end)

-- [ WAIT LOOP ]
repeat task.wait() until validated or closed

if closed or not validated then
	return
end

-- ==========================================
-- MAIN SCRIPT STARTS HERE
-- ==========================================
print("Hi! Script fully loaded.")
