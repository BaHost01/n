-- Sample Testing Script for UniversalLib Overhaul
-- Using raw GitHub URL for library loading as per standard usage
local UniversalLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaHost01/n/refs/heads/main/l.lua"))()

-- [ CONFIGURATION ]
UniversalLib.SetService("TestingHub")
UniversalLib.SetIdentifier("DevTest")
UniversalLib.SetProvider("Local")
UniversalLib.IsUsingJnkie(false) -- Disable Jnkie for local testing
UniversalLib.DebugLogging(true)
UniversalLib.SaveKey(true)
UniversalLib.LoadKey(true)

-- [ START SCRIPT ]
UniversalLib.StartUserScript(function()
	print("Authenticated! Starting Hub...")

	local Window = UniversalLib:CreateWindow({
		Title = "DEVELOPER HUB",
		ToggleKey = Enum.KeyCode.RightShift
	})

	-- [ MAIN TAB ]
	local MainTab = Window:CreateTab("Main")
	MainTab:CreateLabel("Welcome to the Overhauled Library!")
	
	MainTab:CreateButton("Print Hello", function()
		print("Hello from UniversalLib!")
	end)

	MainTab:CreateToggle("Auto Farm", false, function(state)
		print("Auto Farm is now: " .. tostring(state))
	end)

	MainTab:CreateSlider("WalkSpeed", 16, 100, 16, function(val)
		local character = game.Players.LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") then
			character.Humanoid.WalkSpeed = val
		end
	end)

	-- [ VISUALS TAB ]
	local VisualsTab = Window:CreateTab("Visuals")
	VisualsTab:CreateDropdown("ESP Mode", {"Boxes", "Tracers", "Skeleton", "Off"}, "Off", function(opt)
		print("ESP Mode set to: " .. opt)
	end)

	VisualsTab:CreateToggle("Full Bright", false, function(state)
		game:GetService("Lighting").Brightness = state and 2 or 1
	end)

	-- [ SETTINGS TAB ]
	local SettingsTab = Window:CreateTab("Settings")
	SettingsTab:CreateKeybind("Toggle UI Key", Enum.KeyCode.RightShift, function(key)
		print("New toggle key: " .. key.Name)
	end)

	SettingsTab:CreateTextBox("Custom Prefix", function(text, enter)
		if enter then
			print("New prefix set to: " .. text)
		end
	end)

	SettingsTab:CreateButton("Destroy UI", function()
		print("UI Destruction requested.")
	end)

end)
