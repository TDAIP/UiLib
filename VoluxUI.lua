--[[
	User Interface Library
	Made by VoluxUI V2.1 - Galaxy Edition
]]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
}

local Theme = { --// Galaxy Theme
	--// Frames:
	Primary = Color3.fromRGB(15, 15, 25),
	Secondary = Color3.fromRGB(20, 20, 35),
	Component = Color3.fromRGB(25, 25, 40),
	Interactables = Color3.fromRGB(30, 30, 50),

	--// Text:
	Tab = Color3.fromRGB(220, 220, 255),
	Title = Color3.fromRGB(255, 255, 255),
	Description = Color3.fromRGB(180, 180, 220),

	--// Outlines:
	Shadow = Color3.fromRGB(0, 0, 0),
	Outline = Color3.fromRGB(60, 60, 100),

	--// Image:
	Icon = Color3.fromRGB(220, 220, 255),
	
	--// Galaxy Colors:
	GalaxyPurple = Color3.fromRGB(138, 43, 226),
	GalaxyBlue = Color3.fromRGB(72, 61, 139),
	GalaxyCyan = Color3.fromRGB(0, 191, 255),
	GalaxyPink = Color3.fromRGB(255, 20, 147),
	StarColor = Color3.fromRGB(255, 255, 255),
}

--// Services & Functions
local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

local Tween = function(Object : Instance, Speed : number, Properties : {},  Info : { EasingStyle: Enum?, EasingDirection: Enum? })
	local Style, Direction

	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end

	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = (Property);
	end

	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}

	return UDim2.new(unpack(New))
end

local Color = function(Color, Factor, Mode)
	Mode = Mode or Setup.ThemeMode

	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;

		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		-- Create larger drag area for mobile
		local DragArea = Instance.new("Frame")
		DragArea.Name = "DragArea"
		DragArea.Size = UDim2.new(1, 0, 0, 60) -- Larger drag area
		DragArea.Position = UDim2.new(0, 0, 0, 0)
		DragArea.BackgroundTransparency = 1
		DragArea.ZIndex = 100
		DragArea.Parent = Canvas

		Connect(DragArea.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position

				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		Connect(DragArea.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				DragInput = Input
			end
		end)

		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end
end

Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}

Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")

			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)

				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))

				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)

				local NewPosition = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
			end
		end

		Connect(Player.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Setup [UI]
if (identifyexecutor) then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
	Blur = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))();
else
	Screen = (script.Parent);
	Blur = require(script.Blur)
end

Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function() 
	Screen.Parent = Player.GUI
end)

--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};

--// Function to create galaxy background with animated stars
local function CreateGalaxyBackground(Window)
	-- Main galaxy gradient background
	local GalaxyFrame = Instance.new("Frame")
	GalaxyFrame.Name = "GalaxyBackground"
	GalaxyFrame.Size = UDim2.new(1, 0, 1, 0)
	GalaxyFrame.Position = UDim2.new(0, 0, 0, 0)
	GalaxyFrame.BackgroundColor3 = Theme.Primary
	GalaxyFrame.BackgroundTransparency = 0
	GalaxyFrame.ZIndex = 1
	GalaxyFrame.Parent = Window
	
	-- Galaxy gradient
	local UIGradient = Instance.new("UIGradient")
	UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.GalaxyPurple),
		ColorSequenceKeypoint.new(0.3, Theme.GalaxyBlue),
		ColorSequenceKeypoint.new(0.7, Theme.GalaxyCyan),
		ColorSequenceKeypoint.new(1, Theme.GalaxyPink)
	})
	UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 0.9)
	})
	UIGradient.Rotation = 135
	UIGradient.Parent = GalaxyFrame
	
	-- Create animated stars
	for i = 1, 15 do
		local Star = Instance.new("Frame")
		Star.Name = "Star" .. i
		Star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
		Star.Position = UDim2.new(0, math.random(0, Window.AbsoluteSize.X), 0, math.random(0, Window.AbsoluteSize.Y))
		Star.BackgroundColor3 = Theme.StarColor
		Star.BackgroundTransparency = math.random(0, 50) / 100
		Star.ZIndex = 2
		Star.Parent = GalaxyFrame
		
		-- Make stars circular
		local StarCorner = Instance.new("UICorner")
		StarCorner.CornerRadius = UDim.new(1, 0)
		StarCorner.Parent = Star
		
		-- Animate star twinkling
		task.spawn(function()
			while Star.Parent do
				Tween(Star, math.random(1, 3), { BackgroundTransparency = math.random(0, 80) / 100 })
				task.wait(math.random(1, 3))
			end
		end)
	end
	
	return GalaxyFrame
end

--// Function to create branding text
local function CreateBrandingText(Window)
	local BrandingLabel = Instance.new("TextLabel")
	BrandingLabel.Name = "BrandingText"
	BrandingLabel.Size = UDim2.new(0, 200, 0, 20)
	BrandingLabel.Position = UDim2.new(0, 10, 1, -25)
	BrandingLabel.BackgroundTransparency = 1
	BrandingLabel.Text = "VoluxUI Galaxy Edition"
	BrandingLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
	BrandingLabel.TextSize = 10
	BrandingLabel.TextXAlignment = Enum.TextXAlignment.Left
	BrandingLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	BrandingLabel.Font = Enum.Font.Gotham
	BrandingLabel.ZIndex = 10
	BrandingLabel.Parent = Window
	
	return BrandingLabel
end

--// Function to create improved close button (smaller, transparent, better positioned)
local function CreateImprovedCloseButton(Window, CloseFunction)
	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "ImprovedClose"
	CloseButton.Size = UDim2.new(0, 20, 0, 20) -- Smaller size
	CloseButton.Position = UDim2.new(1, -28, 0, 8) -- Closer to top-left
	CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
	CloseButton.BackgroundTransparency = 1 -- 100% transparent
	CloseButton.Text = "×"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextSize = 14
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.ZIndex = 102
	CloseButton.Parent = Window
	
	-- Add corner radius
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 4)
	UICorner.Parent = CloseButton
	
	-- Hover animations
	Connect(CloseButton.MouseEnter, function()
		Tween(CloseButton, 0.2, { BackgroundTransparency = 0.2 })
		Tween(CloseButton, 0.2, { Size = UDim2.new(0, 22, 0, 22) })
	end)
	
	Connect(CloseButton.MouseLeave, function()
		Tween(CloseButton, 0.2, { BackgroundTransparency = 1 })
		Tween(CloseButton, 0.2, { Size = UDim2.new(0, 20, 0, 20) })
	end)
	
	Connect(CloseButton.MouseButton1Click, CloseFunction)
	
	return CloseButton
end

--// Function to create floating open button
local function CreateFloatingOpenButton(OpenFunction)
	local FloatingButton = Instance.new("TextButton")
	FloatingButton.Name = "FloatingOpenButton"
	FloatingButton.Size = UDim2.new(0, 160, 0, 40)
	FloatingButton.Position = UDim2.new(0.5, -80, 0, 10)
	FloatingButton.BackgroundColor3 = Theme.Primary
	FloatingButton.BackgroundTransparency = 0.1
	FloatingButton.Text = "Open VoluxUI Galaxy"
	FloatingButton.TextColor3 = Theme.Title
	FloatingButton.TextSize = 12
	FloatingButton.Font = Enum.Font.GothamBold
	FloatingButton.ZIndex = 1000
	FloatingButton.Visible = false
	
	-- Add corner radius
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 20)
	UICorner.Parent = FloatingButton
	
	-- Add galaxy gradient
	local UIGradient = Instance.new("UIGradient")
	UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.GalaxyPurple),
		ColorSequenceKeypoint.new(0.5, Theme.GalaxyBlue),
		ColorSequenceKeypoint.new(1, Theme.GalaxyCyan)
	})
	UIGradient.Rotation = 45
	UIGradient.Parent = FloatingButton
	
	-- Add animated stroke
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Theme.GalaxyCyan
	UIStroke.Thickness = 2
	UIStroke.Parent = FloatingButton
	
	-- Parent to screen
	FloatingButton.Parent = Screen
	
	-- Hover animations
	Connect(FloatingButton.MouseEnter, function()
		Tween(FloatingButton, 0.3, { Size = UDim2.new(0, 170, 0, 45) })
		Tween(UIStroke, 0.3, { Color = Theme.GalaxyPink })
	end)
	
	Connect(FloatingButton.MouseLeave, function()
		Tween(FloatingButton, 0.3, { Size = UDim2.new(0, 160, 0, 40) })
		Tween(UIStroke, 0.3, { Color = Theme.GalaxyCyan })
	end)
	
	Connect(FloatingButton.MouseButton1Click, OpenFunction)
	
	return FloatingButton
end

--// Function to create Galaxy Key System UI
local function CreateKeySystemUI(Settings, OnSuccess)
	local KeyFrame = Instance.new("CanvasGroup")
	KeyFrame.Name = "KeySystem"
	KeyFrame.Size = UDim2.new(0, 450, 0, 300)
	KeyFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
	KeyFrame.BackgroundColor3 = Theme.Primary
	KeyFrame.GroupTransparency = 1
	KeyFrame.ZIndex = 1000
	KeyFrame.Parent = Screen
	
	-- Add corner radius
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 15)
	UICorner.Parent = KeyFrame
	
	-- Add galaxy background
	CreateGalaxyBackground(KeyFrame)
	
	-- Add stroke
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Theme.GalaxyCyan
	UIStroke.Thickness = 2
	UIStroke.Parent = KeyFrame
	
	-- Title with galaxy emoji
	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, -40, 0, 60)
	Title.Position = UDim2.new(0, 20, 0, 20)
	Title.BackgroundTransparency = 1
	Title.Text = "🌌 Galaxy Key System - " .. (Settings.Title or "VoluxUI")
	Title.TextColor3 = Theme.Title
	Title.TextSize = 20
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Center
	Title.ZIndex = 1001
	Title.Parent = KeyFrame
	
	-- Description
	local Description = Instance.new("TextLabel")
	Description.Name = "Description"
	Description.Size = UDim2.new(1, -40, 0, 40)
	Description.Position = UDim2.new(0, 20, 0, 80)
	Description.BackgroundTransparency = 1
	Description.Text = "✨ Enter the cosmic key to access the galaxy interface ✨"
	Description.TextColor3 = Theme.Description
	Description.TextSize = 14
	Description.Font = Enum.Font.Gotham
	Description.TextXAlignment = Enum.TextXAlignment.Center
	Description.ZIndex = 1001
	Description.Parent = KeyFrame
	
	-- Key Input
	local KeyInput = Instance.new("TextBox")
	KeyInput.Name = "KeyInput"
	KeyInput.Size = UDim2.new(1, -60, 0, 45)
	KeyInput.Position = UDim2.new(0, 30, 0, 130)
	KeyInput.BackgroundColor3 = Theme.Component
	KeyInput.Text = ""
	KeyInput.PlaceholderText = "🔑 Enter your galaxy key..."
	KeyInput.TextColor3 = Theme.Title
	KeyInput.PlaceholderColor3 = Theme.Description
	KeyInput.TextSize = 16
	KeyInput.Font = Enum.Font.Gotham
	KeyInput.ZIndex = 1001
	KeyInput.Parent = KeyFrame
	
	-- Key Input corner radius
	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 10)
	InputCorner.Parent = KeyInput
	
	-- Key Input stroke
	local InputStroke = Instance.new("UIStroke")
	InputStroke.Color = Theme.GalaxyBlue
	InputStroke.Thickness = 2
	InputStroke.Parent = KeyInput
	
	-- Submit Button
	local SubmitButton = Instance.new("TextButton")
	SubmitButton.Name = "SubmitButton"
	SubmitButton.Size = UDim2.new(0, 120, 0, 40)
	SubmitButton.Position = UDim2.new(0, 30, 0, 190)
	SubmitButton.BackgroundColor3 = Theme.GalaxyPurple
	SubmitButton.Text = "🚀 Launch"
	SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SubmitButton.TextSize = 16
	SubmitButton.Font = Enum.Font.GothamBold
	SubmitButton.ZIndex = 1001
	SubmitButton.Parent = KeyFrame
	
	-- Submit Button corner radius
	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 10)
	ButtonCorner.Parent = SubmitButton
	
	-- Get Key Button (if KeyUrl is provided)
	local GetKeyButton
	if Settings.KeyUrl then
		GetKeyButton = Instance.new("TextButton")
		GetKeyButton.Name = "GetKeyButton"
		GetKeyButton.Size = UDim2.new(0, 120, 0, 40)
		GetKeyButton.Position = UDim2.new(0, 160, 0, 190)
		GetKeyButton.BackgroundColor3 = Theme.GalaxyCyan
		GetKeyButton.Text = "🔗 Get Key"
		GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		GetKeyButton.TextSize = 16
		GetKeyButton.Font = Enum.Font.GothamBold
		GetKeyButton.ZIndex = 1001
		GetKeyButton.Parent = KeyFrame
		
		-- Get Key Button corner radius
		local GetKeyCorner = Instance.new("UICorner")
		GetKeyCorner.CornerRadius = UDim.new(0, 10)
		GetKeyCorner.Parent = GetKeyButton
		
		Connect(GetKeyButton.MouseButton1Click, function()
			if setclipboard then
				setclipboard(Settings.KeyUrl)
				GetKeyButton.Text = "📋 Copied!"
				task.wait(2)
				GetKeyButton.Text = "🔗 Get Key"
			end
		end)
	end
	
	-- Status Label
	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "StatusLabel"
	StatusLabel.Size = UDim2.new(1, -40, 0, 30)
	StatusLabel.Position = UDim2.new(0, 20, 0, 250)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Text = ""
	StatusLabel.TextColor3 = Color3.fromRGB(220, 53, 69)
	StatusLabel.TextSize = 12
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
	StatusLabel.ZIndex = 1001
	StatusLabel.Parent = KeyFrame
	
	-- Validation function
	local function ValidateKey()
		local inputKey = KeyInput.Text
		local correctKey
		
		if Settings.KeyUrl then
			correctKey = Settings.Key or "testkey"
		else
			correctKey = Settings.Key
		end
		
		if inputKey == correctKey then
			StatusLabel.Text = "✅ Galaxy key accepted! Launching interface..."
			StatusLabel.TextColor3 = Color3.fromRGB(40, 167, 69)
			
			task.wait(1)
			
			-- Close key system
			Tween(KeyFrame, 0.3, { GroupTransparency = 1 })
			task.wait(0.3)
			KeyFrame:Destroy()
			
			-- Call success callback
			OnSuccess()
		else
			StatusLabel.Text = "❌ Invalid galaxy key. Please try again."
			StatusLabel.TextColor3 = Color3.fromRGB(220, 53, 69)
			
			-- Shake animation
			local originalPos = KeyInput.Position
			for i = 1, 3 do
				Tween(KeyInput, 0.1, { Position = originalPos + UDim2.new(0, 5, 0, 0) })
				task.wait(0.1)
				Tween(KeyInput, 0.1, { Position = originalPos + UDim2.new(0, -5, 0, 0) })
				task.wait(0.1)
			end
			Tween(KeyInput, 0.1, { Position = originalPos })
		end
	end
	
	-- Connect events
	Connect(SubmitButton.MouseButton1Click, ValidateKey)
	Connect(KeyInput.FocusLost, function(enterPressed)
		if enterPressed then
			ValidateKey()
		end
	end)
	
	-- Show key system with animation
	Animations:Open(KeyFrame, 0, true)
	
	return KeyFrame
end

--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	local Original = (UseCurrentSize and Window.Size) or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")


	SetProperty(Shadow, { Transparency = 1 })
	SetProperty(Window, {
		Size = Multiplied,
		GroupTransparency = 1,
		Visible = true,
	})

	Tween(Shadow, .25, { Transparency = 0.5 })
	Tween(Window, .25, {
		Size = Original,
		GroupTransparency = Transparency or 0,
	})
end

function Animations:Close(Window: CanvasGroup)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, {
		Size = Original,
	})

	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, {
		Size = Multiplied,
		GroupTransparency = 1,
	})

	task.wait(.25)
	Window.Size = Original
	Window.Visible = false
end


function Animations:Component(Component: any, Custom: boolean)	
	Connect(Component.InputBegan, function() 
		if Custom then
			Tween(Component, .25, { Transparency = .85 });
		else
			Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
		end
	end)

	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .25, { Transparency = 1 });
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component });
		end
	end)
end

--// Library [Window]

function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string, KeySystem: boolean?, Key: string?, KeyUrl: string? })
	-- Key System Check
	if Settings.KeySystem then
		local KeySystemCompleted = false
		
		CreateKeySystemUI(Settings, function()
			KeySystemCompleted = true
		end)
		
		-- Wait for key system completion
		repeat task.wait() until KeySystemCompleted
	end
	
	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");

	local Options = {};
	local Examples = {};
	local Opened = true;
	local Maximized = false;
	local BlurEnabled = false
	local FloatingButton

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	--// UI Blur & More
	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = Settings.Size
	Setup.ThemeMode = Settings.Theme or "Dark"

	--// Add galaxy background and branding
	CreateGalaxyBackground(Window)
	CreateBrandingText(Window)

	if Settings.Blurring then
		Blurs[Settings.Title] = Blur.new(Window, 5)
		BlurEnabled = true
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	--// Animate
	local Close = function()
		if Opened then
			if BlurEnabled then
				Blurs[Settings.Title].root.Parent = nil
			end

			Opened = false
			Animations:Close(Window)
			Window.Visible = false
			
			-- Show floating button
			if FloatingButton then
				FloatingButton.Visible = true
				Tween(FloatingButton, 0.3, { BackgroundTransparency = 0.1 })
			end
		else
			Animations:Open(Window, Setup.Transparency)
			Opened = true
			
			-- Hide floating button
			if FloatingButton then
				Tween(FloatingButton, 0.3, { BackgroundTransparency = 1 })
				task.wait(0.3)
				FloatingButton.Visible = false
			end

			if BlurEnabled then
				Blurs[Settings.Title].root.Parent = workspace.CurrentCamera
			end
		end
	end

	-- Create floating open button
	FloatingButton = CreateFloatingOpenButton(Close)

	-- Add improved close button (smaller, transparent, better positioned)
	CreateImprovedCloseButton(Window, Close)

	-- REMOVED: Mobile minimize button (the ugly "-" button)

	for Index, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") then
			local Name = Button.Name
			Animations:Component(Button, true)

			Connect(Button.MouseButton1Click, function() 
				if Name == "Close" then
					Close()
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size });
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
					end
				elseif Name == "Minimize" then
					Opened = false
					Window.Visible = false
					if BlurEnabled then
						Blurs[Settings.Title].root.Parent = nil
					end
					
					-- Show floating button
					if FloatingButton then
						FloatingButton.Visible = true
						Tween(FloatingButton, 0.3, { BackgroundTransparency = 0.1 })
					end
				end
			end)
		end
	end

	Services.Input.InputBegan:Connect(function(Input, Focused) 
		if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
			Close()
		end
	end)

	--// Tab Functions

	function Options:SetTab(Name: string)
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");

				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) });
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(Opened, { Value = true });
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) });
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(Opened, { Value = false });
				end
			end
		end

		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true

					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });

				elseif not SameName and Opened.Value then
					Opened.Value = false

					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });	

					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Example = Examples["SectionExample"];
		local Section = Clone(Example);

		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo["Tabs"][Settings.Title] then 
			error("[UI LIB]: A tab with the same name has already been created") 
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local Tab = Clone(Example);

		if not Settings.Icon then
			Destroy(Tab["ICO"]);
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon });
		end

		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title });

		SetProperty(Main, { 
			Parent = MainExample.Parent,
			Name = Settings.Title;
		});

		SetProperty(Tab, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title;
			Visible = true;
		});

		Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name);
		end)

		return Main.ScrollingFrame
	end
	
	--// Notifications
	
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, {
			Parent = Screen["Frame"],
		})
		
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			local Wait = task.wait;
			
			Animations:Open(Notification, Setup.Transparency, true); Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end

	--// Component Functions

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")

		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings: { Name: string, Tab: Instance }) 
		local Section = Clone(Components["Section"]);
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);

		Connect(Button.MouseButton1Click, Settings.Callback)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];

		Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)

		Connect(TextBox.FocusLost, function() 
			Settings.Callback(TextBox.Text)
		end)

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		
		local Set = function(Value)
			if Value then
				Tween(Main,   .2, { BackgroundColor3 = Theme.GalaxyCyan });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			
			On.Value = Value
		end 

		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value

			Set(Value)
			Settings.Callback(Value)
		end)

		Animations:Component(Toggle);
		Set(Settings.Default);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddKeybind(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Keybind"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Bind = Dropdown["Main"].Options;
		
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }; 
		local Types = { 
			["Mouse"] = "Enum.UserInputType.MouseButton", 
			["Key"] = "Enum.KeyCode." 
		}
		
		Connect(Dropdown.MouseButton1Click, function()
			local Time = tick();
			local Detect, Finished
			
			SetProperty(Bind, { Text = "..." });
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
				local InputType = (Key.UserInputType);
				
				if not Finished and not Focused then
					Finished = (true)
					
					if table.find(Mouse, InputType) then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(InputType):gsub(Types.Mouse, "MB")
						})
					elseif InputType == Enum.UserInputType.Keyboard then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(Key.KeyCode):gsub(Types.Key, "")
						})
					end
				end 
			end)
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown["Main"].Options;

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example["Top"]["Buttons"];

			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window });
			Animations:Open(Example, 0, true)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)

					Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 });
						Animations:Close(Example);
						task.wait(2)
						Destroy(Example);
					end)
				end
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local Title, Description = Options:GetLabels(Button);
				local Selected = Button["Value"];

				Animations:Component(Button);
				SetProperty(Title, { Text = Index });
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				Destroy(Description);

				Connect(Button.MouseButton1Click, function() 
					local NewValue = not Selected.Value 

					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						Settings.Callback(Option)
						Text.Text = Index

						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component });
					end

					Selected.Value = NewValue
					Tween(BG, .25, { BackgroundTransparency = 1 });
					Animations:Close(Example);
					task.wait(2)
					Destroy(Example);
				end)
			end
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);

		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];

		local Active = false
		local Value = 0
		
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X			
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			
			if Number then
				Number = (Number > Settings.MaxValue and Settings.MaxValue) or (Number < 0 and 0) or Number
			end
			
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / Settings.MaxValue) or Scale, 1)
			Settings.Callback(Value)
		end

		local Activate = function()
			Active = true

			repeat task.wait()
				Update()
			until not Active
		end
		
		Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or 0)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(Value, 1);
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance }) 
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);

		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, {
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	local Themes = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark");
				end
			end,
			
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
				end
			end,
			
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color = Theme.Outline
				end
			end,

			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
				end
			end,

			["Main"] = function(Label)
				if Label:IsA("Frame") then

					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value 
						local Circle = Label:FindFirstChild("Circle")
						
						if not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
							Label.Circle.BackgroundColor3 = Theme.Primary
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Amount"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Slide"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Input"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") then
					Stroke.Color = Theme.Outline
				end
			end,

			["DropdownExample"] = function(Label)
				Label.BackgroundColor3 = Theme.Secondary
			end,

			["Underline"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
		},

		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" then
					Label.ImageColor3 = Theme.Icon
				end
			end,

			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				end
			end,

			["ScrollingFrame"] = function(Label)
				Label.ScrollBarImageColor3 = Theme.Component
			end,
		},
	}

	function Options:SetTheme(Info)
		Theme = Info or Theme

		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow

		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class =  Themes.Names[Descendant.Name],  Themes.Classes[Descendant.ClassName]

			if Name then
				Name(Descendant);
			elseif Class then
				Class(Descendant);
			end
		end
	end

	--// Changing Settings

	function Options:SetSetting(Setting, Value) --// Available settings - Size, Transparency, Blur, Theme
		if Setting == "Size" then
			
			Window.Size = Value
			Setup.Size = Value
			
		elseif Setting == "Transparency" then
			
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			
			for Index, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				end
			end
			
		elseif Setting == "Blur" then
			
			local AlreadyBlurred, Root = Blurs[Settings.Title], nil
			
			if AlreadyBlurred then
				Root = Blurs[Settings.Title]["root"]
			end
			
			if Value then
				BlurEnabled = true

				if not AlreadyBlurred or not Root then
					Blurs[Settings.Title] = Blur.new(Window, 5)
				elseif Root and not Root.Parent then
					Root.Parent = workspace.CurrentCamera
				end
			elseif not Value and (AlreadyBlurred and Root and Root.Parent) then
				Root.Parent = nil
				BlurEnabled = false
			end
			
		elseif Setting == "Theme" and typeof(Value) == "table" then
			
			Options:SetTheme(Value)
			
		elseif Setting == "Keybind" then
			
			Setup.Keybind = Value
			
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library