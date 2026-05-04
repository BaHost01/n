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
local Lighting = game:GetService("Lighting")

-- [ DEVICE DETECTION ]
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
local MAIN_SIZE = isMobile and UDim2.new(0, 500, 0, 320) or UDim2.new(0, 650, 0, 380)
local TOPBAR_HEIGHT = isMobile and 35 or 45
local BTN_HEIGHT = isMobile and 35 or 40

-- [ STATE VARIABLES ]
local validated, closed, minimized, shaderEnabled = false, false, false, false
local attempts, maxAttempts = 0, 5
local thumb = "rbxthumb://type=Asset&id=" .. game.PlaceId .. "&w=768&h=432"

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

-- Utility function for Gradients
local function ApplyGradient(parent, color1, color2)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2)
	}
	grad.Rotation = 45
	grad.Parent = parent
	return grad
end

-- [ FLOATING BALL (MINIMIZED WIDGET) ]
local FloatingBall = Instance.new("TextButton")
FloatingBall.Name = "FloatingBall"
FloatingBall.Size = UDim2.new(0, 50, 0, 50)
FloatingBall.Position = UDim2.new(0.5, -25, 0.1, 0)
FloatingBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FloatingBall.Text = "🔑"
FloatingBall.TextSize = 20
FloatingBall.Visible = false
FloatingBall.AutoButtonColor = false
Instance.new("UICorner", FloatingBall).CornerRadius = UDim.new(1, 0)
ApplyGradient(FloatingBall, Color3.fromRGB(114, 137, 218), Color3.fromRGB(180, 130, 255))

local BallStroke = Instance.new("UIStroke", FloatingBall)
BallStroke.Thickness = 2
BallStroke.Transparency = 0.5
BallStroke.Color = Color3.fromRGB(255, 255, 255)

local BallShadow = Instance.new("ImageLabel", FloatingBall)
BallShadow.Size = UDim2.new(1.6, 0, 1.6, 0)
BallShadow.Position = UDim2.new(0.5, 0, 0.5, 2)
BallShadow.AnchorPoint = Vector2.new(0.5, 0.5)
BallShadow.BackgroundTransparency = 1
BallShadow.Image = "rbxassetid://6015897843"
BallShadow.ImageColor3 = Color3.new(0, 0, 0)
BallShadow.ImageTransparency = 0.4
BallShadow.ZIndex = -1
FloatingBall.Parent = G

-- Main Container Setup
local MainCanvas = Instance.new("Frame")
MainCanvas.Name = "MainCanvas"
MainCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
MainCanvas.Size = MAIN_SIZE 
MainCanvas.BackgroundTransparency = 1
MainCanvas.Parent = G

-- Main Drop Shadow
local MainShadow = Instance.new("ImageLabel", MainCanvas)
MainShadow.Size = UDim2.new(1.15, 0, 1.15, 0)
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 5)
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://6015897843"
MainShadow.ImageColor3 = Color3.new(0, 0, 0)
MainShadow.ImageTransparency = 0.4

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(1, 0, 1, 0)
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
ApplyGradient(Main, Color3.fromRGB(25, 25, 30), Color3.fromRGB(12, 12, 15))
Main.Parent = MainCanvas

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Transparency = 0.8
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Parent = Main

-- Top Bar
local Top = Instance.new("Frame")
Top.Name = "Top"
Top.Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT)
Top.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Top.BorderSizePixel = 0
ApplyGradient(Top, Color3.fromRGB(35, 35, 40), Color3.fromRGB(18, 18, 22))
Top.Parent = Main

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Size = UDim2.new(0.5, 0, 1, 0)
ScriptTitle.Position = UDim2.new(0, 15, 0, 0)
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Text = SCRIPT_NAME .. " <font color='rgb(150,150,150)'>| " .. game.Name .. "</font>"
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.TextSize = isMobile and 12 or 14
ScriptTitle.RichText = true
ScriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
ScriptTitle.Parent = Top

-- Split Main Layout
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0.45, 0, 1, -TOPBAR_HEIGHT)
LeftPanel.Position = UDim2.new(0, 0, 0, TOPBAR_HEIGHT)
LeftPanel.BackgroundTransparency = 1
LeftPanel.Parent = Main

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0.55, 0, 1, -TOPBAR_HEIGHT)
RightPanel.Position = UDim2.new(0.45, 0, 0, TOPBAR_HEIGHT)
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

local ThumbStroke = Instance.new("UIStroke", Thumbnail)
ThumbStroke.Transparency = 0.8
ThumbStroke.Color = Color3.fromRGB(255, 255, 255)

-- [ LEFT PANEL: Auto-Layout Setup ]
local LeftList = Instance.new("UIListLayout", LeftPanel)
LeftList.Padding = UDim.new(0, isMobile and 6 or 10)
LeftList.HorizontalAlignment = Enum.HorizontalAlignment.Center
LeftList.VerticalAlignment = Enum.VerticalAlignment.Center

-- Components
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -30, 0, 20)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Status: Waiting..."
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = isMobile and 11 or 13
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = LeftPanel

local AttemptsText = StatusText:Clone()
AttemptsText.Text = "Attempts: 0/" .. maxAttempts
AttemptsText.TextColor3 = Color3.fromRGB(150, 150, 150)
AttemptsText.Parent = LeftPanel

local InputWrapper = Instance.new("Frame")
InputWrapper.Size = UDim2.new(1, -30, 0, BTN_HEIGHT)
InputWrapper.BackgroundTransparency = 1
InputWrapper.Parent = LeftPanel

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, 0, 1, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
KeyInput.PlaceholderText = "Paste your key here..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = isMobile and 12 or 14
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
local KeyStroke = Instance.new("UIStroke", KeyInput)
KeyStroke.Transparency = 0.8
KeyStroke.Color = Color3.fromRGB(255, 255, 255)
KeyInput.Parent = InputWrapper

-- UI Helper Functions
local function CreateButton(parent, text, bgColor, txtColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -30, 0, BTN_HEIGHT)
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.TextColor3 = txtColor
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = isMobile and 12 or 14
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = parent
	return btn
end

local BtnGetKey = CreateButton(LeftPanel, "GET KEY", Color3.fromRGB(255, 255, 255), Color3.fromRGB(15, 15, 15))
local BtnValidate = CreateButton(LeftPanel, "VALIDATE", Color3.fromRGB(40, 40, 45), Color3.fromRGB(255, 255, 255))
local ValidateStroke = Instance.new("UIStroke", BtnValidate)
ValidateStroke.Transparency = 0.7
ValidateStroke.Color = Color3.fromRGB(255, 255, 255)

local BtnDiscord = CreateButton(LeftPanel, "JOIN DISCORD", Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
ApplyGradient(BtnDiscord, Color3.fromRGB(114, 137, 218), Color3.fromRGB(88, 101, 242))
local DiscordStroke = Instance.new("UIStroke", BtnDiscord)
DiscordStroke.Transparency = 0.5
DiscordStroke.Color = Color3.fromRGB(88, 101, 242)

-- Control Buttons
local function CreateCtrlButton(text, xPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 25, 0, 25)
	btn.Position = UDim2.new(1, xPos, 0, (TOPBAR_HEIGHT - 25) / 2)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	btn.Parent = Top
	return btn
end

local BtnClose = CreateCtrlButton("X", -35)
local BtnMin = CreateCtrlButton("-", -65)
local BtnShader = CreateCtrlButton("✨", -95)

-- [ TOGGLE LOGIC ]
local function ToggleMinimize()
	minimized = not minimized
	if minimized then
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
		TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = MAIN_SIZE}):Play()
	end
end

-- Input detection for RightShift (PC Toggle)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		ToggleMinimize()
	end
end)

FloatingBall.MouseButton1Click:Connect(function()
	ClickSound:Play()
	ToggleMinimize()
end)

BtnMin.MouseButton1Click:Connect(function()
	ClickSound:Play()
	ToggleMinimize()
end)

-- [ SHADER LOGIC ]
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = Lighting

BtnShader.MouseButton1Click:Connect(function()
	ClickSound:Play()
	shaderEnabled = not shaderEnabled
	
	if shaderEnabled then
		TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 15}):Play()
		TweenService:Create(MainStroke, TweenInfo.new(0.5), {
			Color = Color3.fromRGB(180, 130, 255), 
			Thickness = 2, 
			Transparency = 0
		}):Play()
	else
		TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 0}):Play()
		TweenService:Create(MainStroke, TweenInfo.new(0.5), {
			Color = Color3.fromRGB(255, 255, 255), 
			Thickness = 1, 
			Transparency = 0.8
		}):Play()
	end
end)


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
	if v > 0.5 then targetColor = Color3.fromHSV(h, s, v - 0.15)
	else targetColor = Color3.fromHSV(h, s, v + 0.15) end 

	btn.MouseEnter:Connect(function()
		HoverSound:Play()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 4, btn.Size.Y.Scale, btn.Size.Y.Offset - 4)}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 4, btn.Size.Y.Scale, btn.Size.Y.Offset + 4)}):Play()
	end)
end

local buttons = {BtnGetKey, BtnValidate, BtnDiscord, BtnMin, BtnClose, BtnShader}
for _, btn in pairs(buttons) do ApplyHover(btn) end

-- [ DRAG LOGIC ]
local function MakeDraggable(dragArea, object)
	local dragging, dragInput, dragStart, startPos
	dragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	dragArea.InputChanged:Connect(function(input)
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
MakeDraggable(Top, MainCanvas)
MakeDraggable(FloatingBall, FloatingBall)

-- [ BUTTON EVENTS ]
BtnDiscord.MouseButton1Click:Connect(function()
	ClickSound:Play()
	if setclipboard then
		setclipboard("https://discord.gg/gJaG8ngsN2")
		SetStatus("Discord link copied!", Color3.fromRGB(88, 101, 242))
	end
end)

BtnGetKey.MouseButton1Click:Connect(function()
	ClickSound:Play()
	local ok, link = pcall(function() return J.get_key_link() end)
	if ok and link and setclipboard then
		setclipboard(link)
		SetStatus("Key link copied!", Color3.fromRGB(85, 255, 127))
	else
		SetStatus("Failed to get key link.", Color3.fromRGB(255, 85, 85))
	end
end)

BtnValidate.MouseButton1Click:Connect(function()
	ClickSound:Play()
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
		
		-- Cleanup
		TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 0}):Play()
		TweenService:Create(MainCanvas, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(0.5)
		BlurEffect:Destroy()
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
		TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
		task.delay(0.3, function() BlurEffect:Destroy() end)
		G:Destroy()
	end
end)

BtnClose.MouseButton1Click:Connect(function()
	ClickSound:Play()
	TweenService:Create(MainCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
	TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
	task.wait(0.3)
	closed = true
	BlurEffect:Destroy()
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
