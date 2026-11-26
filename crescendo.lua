local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local VALID_KEY = "FREE-k8R2-mP9v-X4nQ-z5T7"
local KEY_LINK = "https://mozartcrescendo.github.io/crescendo-key/"
local KEY_FILE = "CrescendoHub_SavedKey.txt"

local function LoadCrescendoHub()
	Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

	local Window = Rayfield:CreateWindow({
		Name = "Crescendo Hub",
		Icon = 0,
		LoadingTitle = "Crescendo Hub",
		LoadingSubtitle = "Access Granted",
		Theme = "Default",
		ConfigurationSaving = {
			Enabled = true,
			FolderName = "CrescendoHub",
			FileName = "Config"
		}
	})

	local PlayerTab = Window:CreateTab("Player", 4483362458)

	-- Shared state & enforcement settings
	local State = {
		SpeedEnabled = false,
		WalkSpeed = 16,

		JumpPowerEnabled = false,
		JumpPower = 50,

		InfJump = false,
		NoClip = false,

		FlyEnabled = false,
		FlySpeed = 60,

		VehicleFlyEnabled = false,
		VehicleFlySpeed = 80,

		GravityEnabled = false,
		Gravity = Workspace.Gravity,

		MaxZoomEnabled = false,
		MaxZoom = LocalPlayer.CameraMaxZoomDistance,

		InstantPrompt = false,
		AntiAFK = false,
		AntiPaused = false,
		ESPEnabled = false,
		BoostFPS = false,
		Fullbright = false
	}

	local SavedDefaults = {
		Gravity = Workspace.Gravity,
		MaxZoom = LocalPlayer.CameraMaxZoomDistance,
		GlobalShadows = Lighting.GlobalShadows,
		FogEnd = Lighting.FogEnd,
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient
	}

	local ESPFolder = Instance.new("Folder")
	ESPFolder.Name = "CrescendoHub_ESP"
	ESPFolder.Parent = game:GetService("CoreGui")

	local function ClearESP()
		for _, child in ipairs(ESPFolder:GetChildren()) do
			child:Destroy()
		end
	end

	local function UpdateESP()
		ClearESP()
		if not State.ESPEnabled then return end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local root = plr.Character:FindFirstChild("HumanoidRootPart")
				if root then
					local highlight = Instance.new("Highlight")
					highlight.Name = plr.Name .. "_Highlight"
					highlight.Adornee = plr.Character
					highlight.FillColor = Color3.fromRGB(56, 189, 248)
					highlight.OutlineColor = Color3.fromRGB(248, 250, 252)
					highlight.FillTransparency = 0.55
					highlight.OutlineTransparency = 0
					highlight.Parent = ESPFolder

					local billboard = Instance.new("BillboardGui")
					billboard.Name = plr.Name .. "_Tag"
					billboard.Adornee = root
					billboard.Size = UDim2.new(0, 140, 0, 24)
					billboard.StudsOffset = Vector3.new(0, 3.2, 0)
					billboard.AlwaysOnTop = true
					billboard.Parent = ESPFolder

					local label = Instance.new("TextLabel")
					label.Size = UDim2.new(1, 0, 1, 0)
					label.BackgroundTransparency = 1
					label.TextColor3 = Color3.fromRGB(248, 250, 252)
					label.TextStrokeTransparency = 0.35
					label.Font = Enum.Font.GothamBold
					label.TextSize = 13
					local hum = plr.Character:FindFirstChildOfClass("Humanoid")
					local hp = hum and math.floor(hum.Health) or 0
					label.Text = string.format("%s [%d HP]", plr.DisplayName, hp)
					label.Parent = billboard
				end
			end
		end
	end

	local function ApplyFPSBoost()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e9
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") or v:IsA("Atmosphere") then
				v.Enabled = false
			end
		end
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.Material = Enum.Material.SmoothPlastic
				obj.Reflectance = 0
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 1
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				obj.Enabled = false
			end
		end
	end

	local function ApplyFullbright()
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(200, 200, 200)
		Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		Lighting.FogEnd = 1e9
	end

	local function RestoreLightingIfDisabled()
		if not State.Fullbright then
			Lighting.Brightness = SavedDefaults.Brightness
			Lighting.Ambient = SavedDefaults.Ambient
			Lighting.OutdoorAmbient = SavedDefaults.OutdoorAmbient
		end
		if not State.BoostFPS then
			Lighting.GlobalShadows = SavedDefaults.GlobalShadows
			if not State.Fullbright then
				Lighting.FogEnd = SavedDefaults.FogEnd
			end
		end
	end

	local function PatchPrompts()
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if desc:IsA("ProximityPrompt") then
				desc.HoldDuration = 0
			end
		end
	end

	-- 1. WalkSpeed
	PlayerTab:CreateSection("Movement")

	PlayerTab:CreateToggle({
		Name = "WalkSpeed Loop",
		CurrentValue = false,
		Flag = "WalkSpeedToggle",
		Callback = function(Value)
			State.SpeedEnabled = Value
		end
	})

	PlayerTab:CreateSlider({
		Name = "WalkSpeed",
		Range = {16, 250},
		Increment = 1,
		Suffix = " SPS",
		CurrentValue = 16,
		Flag = "WalkSpeedSlider",
		Callback = function(Value)
			State.WalkSpeed = Value
		end
	})

	-- 2. JumpPower
	PlayerTab:CreateToggle({
		Name = "JumpPower Loop",
		CurrentValue = false,
		Flag = "JumpPowerToggle",
		Callback = function(Value)
			State.JumpPowerEnabled = Value
		end
	})

	PlayerTab:CreateSlider({
		Name = "JumpPower",
		Range = {50, 350},
		Increment = 1,
		Suffix = " JP",
		CurrentValue = 50,
		Flag = "JumpPowerSlider",
		Callback = function(Value)
			State.JumpPower = Value
		end
	})

	-- 3. Infinite Jump
	PlayerTab:CreateToggle({
		Name = "Infinite Jump",
		CurrentValue = false,
		Flag = "InfJumpToggle",
		Callback = function(Value)
			State.InfJump = Value
		end
	})

	-- 4. NoClip
	PlayerTab:CreateToggle({
		Name = "NoClip",
		CurrentValue = false,
		Flag = "NoClipToggle",
		Callback = function(Value)
			State.NoClip = Value
		end
	})

	-- 5. Fly
	PlayerTab:CreateSection("Flight")

	PlayerTab:CreateToggle({
		Name = "Fly",
		CurrentValue = false,
		Flag = "FlyToggle",
		Callback = function(Value)
			State.FlyEnabled = Value
		end
	})

	PlayerTab:CreateSlider({
		Name = "Fly Speed",
		Range = {16, 300},
		Increment = 1,
		Suffix = " SPD",
		CurrentValue = 60,
		Flag = "FlySpeedSlider",
		Callback = function(Value)
			State.FlySpeed = Value
		end
	})

	-- 6. Vehicle Fly
	PlayerTab:CreateToggle({
		Name = "Vehicle Fly",
		CurrentValue = false,
		Flag = "VehicleFlyToggle",
		Callback = function(Value)
			State.VehicleFlyEnabled = Value
		end
	})

	PlayerTab:CreateSlider({
		Name = "Vehicle Fly Speed",
		Range = {20, 400},
		Increment = 1,
		Suffix = " SPD",
		CurrentValue = 80,
		Flag = "VehicleFlySpeedSlider",
		Callback = function(Value)
			State.VehicleFlySpeed = Value
		end
	})

	-- 7. Gravity & 8. MaxZoom
	PlayerTab:CreateSection("World & Camera")

	PlayerTab:CreateToggle({
		Name = "Custom Gravity Loop",
		CurrentValue = false,
		Flag = "GravityToggle",
		Callback = function(Value)
			State.GravityEnabled = Value
			if not Value then
				Workspace.Gravity = SavedDefaults.Gravity
			end
		end
	})

	PlayerTab:CreateSlider({
		Name = "Gravity",
		Range = {0, 300},
		Increment = 1,
		Suffix = " G",
		CurrentValue = math.clamp(SavedDefaults.Gravity, 0, 300),
		Flag = "GravitySlider",
		Callback = function(Value)
			State.Gravity = Value
		end
	})

	PlayerTab:CreateToggle({
		Name = "MaxZoom Loop",
		CurrentValue = false,
		Flag = "MaxZoomToggle",
		Callback = function(Value)
			State.MaxZoomEnabled = Value
			if not Value then
				LocalPlayer.CameraMaxZoomDistance = SavedDefaults.MaxZoom
			end
		end
	})

	PlayerTab:CreateSlider({
		Name = "MaxZoom Distance",
		Range = {10, 5000},
		Increment = 10,
		Suffix = " Studs",
		CurrentValue = math.clamp(SavedDefaults.MaxZoom, 10, 5000),
		Flag = "MaxZoomSlider",
		Callback = function(Value)
			State.MaxZoom = Value
		end
	})

	-- 9. Instant Proximity Prompt, 10. Anti-AFK, 11. Anti-Gameplay Paused
	PlayerTab:CreateSection("Automation & Protection")

	PlayerTab:CreateToggle({
		Name = "Instant Proximity Prompt",
		CurrentValue = false,
		Flag = "InstantPromptToggle",
		Callback = function(Value)
			State.InstantPrompt = Value
			if Value then
				PatchPrompts()
			end
		end
	})

	PlayerTab:CreateToggle({
		Name = "Anti-AFK",
		CurrentValue = false,
		Flag = "AntiAFKToggle",
		Callback = function(Value)
			State.AntiAFK = Value
		end
	})

	PlayerTab:CreateToggle({
		Name = "Anti-Gameplay Paused",
		CurrentValue = false,
		Flag = "AntiPausedToggle",
		Callback = function(Value)
			State.AntiPaused = Value
		end
	})

	-- 12. ESP, 13. Boost FPS, 14. Fullbright
	PlayerTab:CreateSection("Visuals & Performance")

	PlayerTab:CreateToggle({
		Name = "Player ESP",
		CurrentValue = false,
		Flag = "ESPToggle",
		Callback = function(Value)
			State.ESPEnabled = Value
			UpdateESP()
		end
	})

	PlayerTab:CreateToggle({
		Name = "Boost FPS",
		CurrentValue = false,
		Flag = "BoostFPSToggle",
		Callback = function(Value)
			State.BoostFPS = Value
			if Value then
				ApplyFPSBoost()
			else
				RestoreLightingIfDisabled()
			end
		end
	})

	PlayerTab:CreateToggle({
		Name = "Fullbright",
		CurrentValue = false,
		Flag = "FullbrightToggle",
		Callback = function(Value)
			State.Fullbright = Value
			if Value then
				ApplyFullbright()
			else
				RestoreLightingIfDisabled()
			end
		end
	})

	PlayerTab:CreateSection("Quick Actions")

	PlayerTab:CreateButton({
		Name = "Respawn Character",
		Callback = function()
			if LocalPlayer.Character then
				LocalPlayer.Character:BreakJoints()
			end
		end
	})

	-- Infinite jump input listener
	UserInputService.JumpRequest:Connect(function()
		if State.InfJump and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)

	-- Anti-AFK idle handler
	LocalPlayer.Idled:Connect(function()
		if State.AntiAFK then
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end
	end)

	-- New proximity prompt listener
	ProximityPromptService.PromptShown:Connect(function(prompt)
		if State.InstantPrompt and prompt then
			prompt.HoldDuration = 0
		end
	end)

	-- Continuous enforcement loop (keeps values locked even if game resets/overrides them)
	local lastSlowTick = 0
	RunService.RenderStepped:Connect(function(dt)
		Camera = Workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")

		if hum then
			if State.SpeedEnabled and hum.WalkSpeed ~= State.WalkSpeed then
				hum.WalkSpeed = State.WalkSpeed
			end
			if State.JumpPowerEnabled then
				hum.UseJumpPower = true
				if hum.JumpPower ~= State.JumpPower then
					hum.JumpPower = State.JumpPower
				end
			end
		end

		if State.NoClip and char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end

		if State.FlyEnabled and root and hum and Camera then
			hum.PlatformStand = true
			local moveVec = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= Vector3.new(0, 1, 0) end

			if moveVec.Magnitude > 0 then
				moveVec = moveVec.Unit * State.FlySpeed
			end
			root.AssemblyLinearVelocity = moveVec
			root.AssemblyAngularVelocity = Vector3.zero
		elseif not State.FlyEnabled and hum and hum.PlatformStand and not State.VehicleFlyEnabled then
			hum.PlatformStand = false
		end

		if State.VehicleFlyEnabled and hum and hum.SeatPart and Camera then
			local seat = hum.SeatPart
			local assemblyRoot = seat.AssemblyRootPart or seat
			local moveVec = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= Vector3.new(0, 1, 0) end

			if moveVec.Magnitude > 0 then
				moveVec = moveVec.Unit * State.VehicleFlySpeed
			end
			assemblyRoot.AssemblyLinearVelocity = moveVec
			assemblyRoot.AssemblyAngularVelocity = Vector3.zero
		end

		if State.GravityEnabled and Workspace.Gravity ~= State.Gravity then
			Workspace.Gravity = State.Gravity
		end

		if State.MaxZoomEnabled and LocalPlayer.CameraMaxZoomDistance ~= State.MaxZoom then
			LocalPlayer.CameraMaxZoomDistance = State.MaxZoom
		end

		if State.AntiPaused then
			local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
			if playerGui then
				for _, gui in ipairs(playerGui:GetChildren()) do
					local lowerName = string.lower(gui.Name)
					if string.find(lowerName, "pause", 1, true) and gui:IsA("ScreenGui") then
						gui.Enabled = false
					end
				end
			end
		end

		-- Periodic tasks every ~0.5s so ESP, prompts, and FPS boost stay synced without heavy overhead
		lastSlowTick += dt
		if lastSlowTick >= 0.5 then
			lastSlowTick = 0
			if State.InstantPrompt then
				PatchPrompts()
			end
			if State.ESPEnabled then
				UpdateESP()
			end
			if State.BoostFPS then
				ApplyFPSBoost()
			elseif State.Fullbright then
				ApplyFullbright()
			end
		end
	end)
end

-- Check if a valid key was already saved locally
if isfile and readfile and isfile(KEY_FILE) then
	if readfile(KEY_FILE) == VALID_KEY then
		LoadCrescendoHub()
		return
	end
end

-- Key System Window (with Copy Key Link button)
local EnteredKey = ""

local KeyWindow = Rayfield:CreateWindow({
	Name = "Crescendo Hub | Key System",
	Icon = 0,
	LoadingTitle = "Crescendo Hub",
	LoadingSubtitle = "Key Required",
	Theme = "Default",
	DisableRayfieldPrompts = true,
	ConfigurationSaving = {
		Enabled = false
	}
})

local KeyTab = KeyWindow:CreateTab("Key Verification", 4483362458)

KeyTab:CreateSection("Step 1: Get Your Key")

KeyTab:CreateButton({
	Name = "Copy Key Link",
	Callback = function()
		if setclipboard then
			setclipboard(KEY_LINK)
			Rayfield:Notify({
				Title = "Link Copied",
				Content = "Paste the link in your browser to complete the 3 checkpoints.",
				Duration = 5
			})
		else
			Rayfield:Notify({
				Title = "Clipboard Unsupported",
				Content = "Open: " .. KEY_LINK,
				Duration = 6
			})
		end
	end
})

KeyTab:CreateSection("Step 2: Enter Key")

KeyTab:CreateInput({
	Name = "Access Key",
	CurrentValue = "",
	PlaceholderText = "FREE-XXXX-XXXX-XXXX-XXXX",
	RemoveTextAfterFocusLost = false,
	Flag = "KeyInput",
	Callback = function(Text)
		EnteredKey = Text
	end
})

KeyTab:CreateButton({
	Name = "Check Key",
	Callback = function()
		if EnteredKey == VALID_KEY then
			if writefile then
				writefile(KEY_FILE, EnteredKey)
			end
			Rayfield:Notify({
				Title = "Key Accepted",
				Content = "Loading Crescendo Hub...",
				Duration = 3
			})
			task.wait(0.8)
			Rayfield:Destroy()
			task.wait(0.2)
			LoadCrescendoHub()
		else
			Rayfield:Notify({
				Title = "Invalid Key",
				Content = "Click 'Copy Key Link' and complete all 3 checkpoints to get your key.",
				Duration = 5
			})
		end
	end
})
