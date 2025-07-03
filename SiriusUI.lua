--[[
	SiriusUI - Complete UI Library
	Advanced Cheat Menu Library with Modern Design
	Version 4.0 - Mobile Enhanced Edition with Galaxy Graphics
]]

--// Services & Core Setup
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if not game:IsLoaded() then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded)
end

--// Library Configuration
local Config = {
	Keybind = Enum.KeyCode.RightShift,
	Transparency = 0.1,
	ThemeMode = "Dark",
	Size = UDim2.new(0, 580, 0, 460),
	BlurIntensity = 8,
}

--// Galaxy Theme (Based on source file)
local Theme = {
	--// Main Colors
	Background = Color3.fromRGB(15, 15, 25),
	Surface = Color3.fromRGB(20, 20, 35),
	Card = Color3.fromRGB(25, 25, 40),
	Elevated = Color3.fromRGB(30, 30, 50),
	
	--// Interactive Elements
	Primary = Color3.fromRGB(138, 43, 226),
	PrimaryHover = Color3.fromRGB(148, 53, 236),
	Secondary = Color3.fromRGB(60, 60, 100),
	Success = Color3.fromRGB(67, 181, 129),
	Warning = Color3.fromRGB(250, 166, 26),
	Error = Color3.fromRGB(237, 66, 69),
	
	--// Text Colors
	TextPrimary = Color3.fromRGB(220, 220, 255),
	TextSecondary = Color3.fromRGB(180, 180, 220),
	TextMuted = Color3.fromRGB(142, 146, 151),
	TextDisabled = Color3.fromRGB(96, 100, 108),
	
	--// Borders & Outlines
	Border = Color3.fromRGB(60, 60, 100),
	BorderHover = Color3.fromRGB(70, 70, 110),
	Accent = Color3.fromRGB(114, 137, 218),
	
	--// Galaxy Colors
	GalaxyPurple = Color3.fromRGB(138, 43, 226),
	GalaxyBlue = Color3.fromRGB(72, 61, 139),
	GalaxyCyan = Color3.fromRGB(0, 191, 255),
	GalaxyPink = Color3.fromRGB(255, 20, 147),
	StarColor = Color3.fromRGB(255, 255, 255),
	
	--// Special Effects
	Shadow = Color3.fromRGB(0, 0, 0),
	Glow = Color3.fromRGB(88, 101, 242),
}

--// Services
local Services = {
	Players = GetService(game, "Players"),
	TweenService = GetService(game, "TweenService"),
	RunService = GetService(game, "RunService"),
	UserInputService = GetService(game, "UserInputService"),
	CoreGui = GetService(game, "CoreGui"),
}

local Player = Services.Players.LocalPlayer
local Mouse = Player:GetMouse()

--// Utility Functions
local function Tween(object, duration, properties, easingStyle, easingDirection)
	local info = TweenInfo.new(
		duration or 0.3,
		easingStyle or Enum.EasingStyle.Quart,
		easingDirection or Enum.EasingDirection.Out
	)
	return Services.TweenService:Create(object, info, properties):Play()
end

local function SetProperties(object, properties)
	for property, value in pairs(properties) do
		object[property] = value
	end
	return object
end

local function CreateElement(className, properties, parent)
	local element = Instance.new(className)
	if properties then
		SetProperties(element, properties)
	end
	if parent then
		element.Parent = parent
	end
	return element
end

local function AddCorner(element, radius)
	return CreateElement("UICorner", {
		CornerRadius = UDim.new(0, radius or 8)
	}, element)
end

local function AddStroke(element, color, thickness)
	return CreateElement("UIStroke", {
		Color = color or Theme.Border,
		Thickness = thickness or 1
	}, element)
end

local function AddPadding(element, padding)
	return CreateElement("UIPadding", {
		PaddingTop = UDim.new(0, padding),
		PaddingBottom = UDim.new(0, padding),
		PaddingLeft = UDim.new(0, padding),
		PaddingRight = UDim.new(0, padding)
	}, element)
end

local function AddListLayout(element, direction, padding)
	return CreateElement("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padding or 8)
	}, element)
end

--// Galaxy Background Creation
local function CreateGalaxyBackground(parent)
	local GalaxyFrame = CreateElement("Frame", {
		Name = "GalaxyBackground",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Theme.Background,
		ZIndex = 1
	}, parent)
	
	-- Galaxy gradient
	local UIGradient = CreateElement("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.GalaxyPurple),
			ColorSequenceKeypoint.new(0.3, Theme.GalaxyBlue),
			ColorSequenceKeypoint.new(0.7, Theme.GalaxyCyan),
			ColorSequenceKeypoint.new(1, Theme.GalaxyPink)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 0.6),
			NumberSequenceKeypoint.new(1, 0.9)
		}),
		Rotation = 135
	}, GalaxyFrame)
	
	-- Animated stars
	for i = 1, 20 do
		local Star = CreateElement("Frame", {
			Name = "Star" .. i,
			Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4)),
			Position = UDim2.new(math.random(0, 100)/100, 0, math.random(0, 100)/100, 0),
			BackgroundColor3 = Theme.StarColor,
			BackgroundTransparency = math.random(0, 50) / 100,
			ZIndex = 2
		}, GalaxyFrame)
		
		AddCorner(Star, 50)
		
		-- Twinkling animation
		task.spawn(function()
			while Star.Parent do
				Tween(Star, math.random(1, 3), { BackgroundTransparency = math.random(0, 80) / 100 })
				task.wait(math.random(1, 3))
			end
		end)
	end
	
	return GalaxyFrame
end

--// Animation System
local Animations = {}

function Animations:Hover(element, hoverProps, normalProps)
	Connect(element.MouseEnter, function()
		Tween(element, 0.2, hoverProps)
	end)
	
	Connect(element.MouseLeave, function()
		Tween(element, 0.2, normalProps)
	end)
end

function Animations:Click(element, clickProps, normalProps)
	Connect(element.MouseButton1Down, function()
		Tween(element, 0.1, clickProps)
	end)
	
	Connect(element.MouseButton1Up, function()
		Tween(element, 0.1, normalProps)
	end)
end

function Animations:FadeIn(element, duration)
	element.Transparency = 1
	Tween(element, duration or 0.3, {Transparency = 0})
end

function Animations:SlideIn(element, direction, duration)
	local originalPos = element.Position
	local offset = direction == "left" and UDim2.new(-1, 0, 0, 0) or 
				   direction == "right" and UDim2.new(1, 0, 0, 0) or
				   direction == "up" and UDim2.new(0, 0, -1, 0) or
				   UDim2.new(0, 0, 1, 0)
	
	element.Position = originalPos + offset
	Tween(element, duration or 0.4, {Position = originalPos})
end

--// Enhanced Mobile-Friendly Drag System
local function MakeDraggable(element, dragHandle)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	dragHandle = dragHandle or element
	
	-- Enhanced drag area for mobile
	local DragArea = CreateElement("Frame", {
		Name = "DragArea",
		Size = UDim2.new(1, 0, 0, 60), -- Larger drag area for mobile
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 100
	}, dragHandle)
	
	local function startDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = element.Position
		end
	end
	
	local function updateDrag(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			element.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end
	
	local function endDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end
	
	Connect(DragArea.InputBegan, startDrag)
	Connect(DragArea.InputChanged, updateDrag)
	Connect(DragArea.InputEnded, endDrag)
	Connect(Services.UserInputService.InputChanged, updateDrag)
	Connect(Services.UserInputService.InputEnded, endDrag)
end

--// Screen Setup
local ScreenGui = CreateElement("ScreenGui", {
	Name = "SiriusUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true
})

pcall(function()
	ScreenGui.Parent = Services.CoreGui
end)

if not ScreenGui.Parent then
	ScreenGui.Parent = Player.PlayerGui
end

--// Main Library
local SiriusUI = {}
local Windows = {}

function SiriusUI:CreateWindow(settings)
	settings = settings or {}
	local windowTitle = settings.Title or "SiriusUI"
	local windowSize = settings.Size or Config.Size
	
	--// Main Window Frame (Centered on screen)
	local Window = CreateElement("Frame", {
		Name = "SiriusWindow",
		Size = windowSize,
		Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false
	}, ScreenGui)
	
	AddCorner(Window, 15)
	AddStroke(Window, Theme.Border, 2)
	
	-- Galaxy background
	CreateGalaxyBackground(Window)
	
	--// Enhanced Window Shadow with Galaxy Effect
	local Shadow = CreateElement("ImageLabel", {
		Name = "Shadow",
		Size = UDim2.new(1, 30, 1, 30),
		Position = UDim2.new(0, -15, 0, -15),
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		ImageColor3 = Theme.GalaxyPurple,
		ImageTransparency = 0.7,
		ZIndex = -1
	}, Window)
	
	--// Title Bar with Galaxy Gradient
	local TitleBar = CreateElement("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 45),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 10
	}, Window)
	
	AddCorner(TitleBar, 15)
	
	-- Title bar galaxy gradient
	local TitleGradient = CreateElement("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.GalaxyPurple),
			ColorSequenceKeypoint.new(0.5, Theme.GalaxyBlue),
			ColorSequenceKeypoint.new(1, Theme.GalaxyCyan)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(1, 0.9)
		}),
		Rotation = 90
	}, TitleBar)
	
	--// Title Bar Bottom Border
	local TitleBorder = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		ZIndex = 11
	}, TitleBar)
	
	--// Window Title
	local Title = CreateElement("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
		BackgroundTransparency = 1,
		Text = windowTitle,
		TextColor3 = Theme.TextPrimary,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		ZIndex = 12
	}, TitleBar)
	
	--// Close Button (Enhanced)
	local CloseButton = CreateElement("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(1, -35, 0, 10),
		BackgroundColor3 = Theme.Error,
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Theme.TextPrimary,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
		ZIndex = 12
	}, TitleBar)
	
	AddCorner(CloseButton, 6)
	
	--// Minimize Button (Enhanced)
	local MinimizeButton = CreateElement("TextButton", {
		Name = "MinimizeButton",
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(1, -65, 0, 10),
		BackgroundColor3 = Theme.Secondary,
		BackgroundTransparency = 1,
		Text = "−",
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
		ZIndex = 12
	}, TitleBar)
	
	AddCorner(MinimizeButton, 6)
	
	--// Sidebar with Galaxy Theme
	local Sidebar = CreateElement("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 170, 1, -45),
		Position = UDim2.new(0, 0, 0, 45),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 5
	}, Window)
	
	-- Sidebar galaxy gradient
	local SidebarGradient = CreateElement("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.Surface),
			ColorSequenceKeypoint.new(1, Theme.Card)
		}),
		Rotation = 180
	}, Sidebar)
	
	local SidebarBorder = CreateElement("Frame", {
		Size = UDim2.new(0, 2, 1, 0),
		Position = UDim2.new(1, -2, 0, 0),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		ZIndex = 6
	}, Sidebar)
	
	--// Tab Container
	local TabContainer = CreateElement("ScrollingFrame", {
		Name = "TabContainer",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Theme.Border,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 6
	}, Sidebar)
	
	AddPadding(TabContainer, 10)
	AddListLayout(TabContainer, Enum.FillDirection.Vertical, 6)
	
	--// Content Area
	local ContentArea = CreateElement("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -170, 1, -45),
		Position = UDim2.new(0, 170, 0, 45),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ZIndex = 5
	}, Window)
	
	--// Tab Content Container
	local TabContentContainer = CreateElement("Frame", {
		Name = "TabContentContainer",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 5
	}, ContentArea)
	
	--// Make window draggable (Mobile-friendly)
	MakeDraggable(Window, TitleBar)
	
	--// Window Controls
	local isVisible = false
	local isMinimized = false
	
	local function ToggleWindow()
		isVisible = not isVisible
		if isVisible then
			Window.Visible = true
			Animations:FadeIn(Window, 0.3)
			Animations:SlideIn(Window, "up", 0.4)
		else
			Tween(Window, 0.3, {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0)
			})
			task.wait(0.3)
			Window.Visible = false
			Window.Size = windowSize
			Window.Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)
		end
	end
	
	local function MinimizeWindow()
		isMinimized = not isMinimized
		if isMinimized then
			Tween(Window, 0.3, {Size = UDim2.new(0, windowSize.X.Offset, 0, 45)})
			ContentArea.Visible = false
			Sidebar.Visible = false
		else
			Tween(Window, 0.3, {Size = windowSize})
			ContentArea.Visible = true
			Sidebar.Visible = true
		end
	end
	
	Connect(CloseButton.MouseButton1Click, ToggleWindow)
	Connect(MinimizeButton.MouseButton1Click, MinimizeWindow)
	
	--// Enhanced Button Animations
	Animations:Hover(CloseButton, {BackgroundTransparency = 0.2}, {BackgroundTransparency = 1})
	Animations:Hover(MinimizeButton, {BackgroundTransparency = 0.2}, {BackgroundTransparency = 1})
	
	--// Keybind Toggle
	Connect(Services.UserInputService.InputBegan, function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Config.Keybind then
			ToggleWindow()
		end
	end)
	
	--// Window Object
	local WindowObject = {
		Window = Window,
		TabContainer = TabContainer,
		TabContentContainer = TabContentContainer,
		Tabs = {},
		CurrentTab = nil
	}
	
	function WindowObject:Show()
		if not isVisible then
			ToggleWindow()
		end
	end
	
	function WindowObject:Hide()
		if isVisible then
			ToggleWindow()
		end
	end
	
	function WindowObject:CreateTab(settings)
		settings = settings or {}
		local tabName = settings.Name or "Tab"
		local tabIcon = settings.Icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
		
		--// Tab Button with Galaxy Theme
		local TabButton = CreateElement("TextButton", {
			Name = tabName,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = Theme.Card,
			BackgroundTransparency = 1,
			Text = "",
			BorderSizePixel = 0,
			ZIndex = 7
		}, TabContainer)
		
		AddCorner(TabButton, 8)
		
		--// Tab Icon
		local TabIcon = CreateElement("ImageLabel", {
			Size = UDim2.new(0, 22, 0, 22),
			Position = UDim2.new(0, 15, 0.5, -11),
			BackgroundTransparency = 1,
			Image = tabIcon,
			ImageColor3 = Theme.TextSecondary,
			ZIndex = 8
		}, TabButton)
		
		--// Tab Label
		local TabLabel = CreateElement("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 45, 0, 0),
			BackgroundTransparency = 1,
			Text = tabName,
			TextColor3 = Theme.TextSecondary,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.GothamSemibold,
			ZIndex = 8
		}, TabButton)
		
		--// Tab Content
		local TabContent = CreateElement("ScrollingFrame", {
			Name = tabName .. "Content",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 8,
			ScrollBarImageColor3 = Theme.Border,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = 6
		}, TabContentContainer)
		
		AddPadding(TabContent, 20)
		AddListLayout(TabContent, Enum.FillDirection.Vertical, 15)
		
		--// Tab Selection
		local function SelectTab()
			-- Deselect all tabs
			for _, tab in pairs(WindowObject.Tabs) do
				tab.Button.BackgroundTransparency = 1
				tab.Icon.ImageColor3 = Theme.TextSecondary
				tab.Label.TextColor3 = Theme.TextSecondary
				tab.Content.Visible = false
			end
			
			-- Select this tab
			TabButton.BackgroundTransparency = 0.1
			TabIcon.ImageColor3 = Theme.Primary
			TabLabel.TextColor3 = Theme.TextPrimary
			TabContent.Visible = true
			WindowObject.CurrentTab = tabName
		end
		
		Connect(TabButton.MouseButton1Click, SelectTab)
		
		--// Tab Animations
		Animations:Hover(TabButton, 
			{BackgroundTransparency = 0.05}, 
			{BackgroundTransparency = WindowObject.CurrentTab == tabName and 0.1 or 1}
		)
		
		--// Tab Object
		local TabObject = {
			Name = tabName,
			Button = TabButton,
			Icon = TabIcon,
			Label = TabLabel,
			Content = TabContent,
			Components = {}
		}
		
		WindowObject.Tabs[tabName] = TabObject
		
		-- Select first tab automatically
		if #WindowObject.Tabs == 1 then
			SelectTab()
		end
		
		--// Component Creation Functions
		function TabObject:CreateSection(settings)
			settings = settings or {}
			local sectionName = settings.Name or "Section"
			
			local Section = CreateElement("TextLabel", {
				Name = sectionName,
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Text = sectionName,
				TextColor3 = Theme.TextPrimary,
				TextSize = 18,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.GothamBold,
				ZIndex = 7
			}, TabContent)
			
			return Section
		end
		
		function TabObject:CreateButton(settings)
			settings = settings or {}
			local buttonText = settings.Text or "Button"
			local callback = settings.Callback or function() end
			
			local Button = CreateElement("TextButton", {
				Name = buttonText,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Theme.Primary,
				Text = buttonText,
				TextColor3 = Theme.TextPrimary,
				TextSize = 15,
				Font = Enum.Font.GothamSemibold,
				BorderSizePixel = 0,
				ZIndex = 7
			}, TabContent)
			
			AddCorner(Button, 8)
			
			-- Galaxy gradient for button
			local ButtonGradient = CreateElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Theme.GalaxyPurple),
					ColorSequenceKeypoint.new(1, Theme.GalaxyBlue)
				}),
				Rotation = 45
			}, Button)
			
			Connect(Button.MouseButton1Click, callback)
			
			Animations:Hover(Button, {BackgroundColor3 = Theme.PrimaryHover}, {BackgroundColor3 = Theme.Primary})
			Animations:Click(Button, {Size = UDim2.new(1, -4, 0, 38)}, {Size = UDim2.new(1, 0, 0, 40)})
			
			return Button
		end
		
		function TabObject:CreateToggle(settings)
			settings = settings or {}
			local toggleText = settings.Text or "Toggle"
			local defaultValue = settings.Default or false
			local callback = settings.Callback or function() end
			
			local ToggleFrame = CreateElement("Frame", {
				Name = toggleText,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,
				ZIndex = 7
			}, TabContent)
			
			AddCorner(ToggleFrame, 8)
			AddStroke(ToggleFrame, Theme.Border)
			
			local ToggleLabel = CreateElement("TextLabel", {
				Size = UDim2.new(1, -70, 1, 0),
				Position = UDim2.new(0, 15, 0, 0),
				BackgroundTransparency = 1,
				Text = toggleText,
				TextColor3 = Theme.TextPrimary,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				ZIndex = 8
			}, ToggleFrame)
			
			local ToggleButton = CreateElement("Frame", {
				Size = UDim2.new(0, 50, 0, 26),
				Position = UDim2.new(1, -60, 0.5, -13),
				BackgroundColor3 = defaultValue and Theme.Primary or Theme.Secondary,
				BorderSizePixel = 0,
				ZIndex = 8
			}, ToggleFrame)
			
			AddCorner(ToggleButton, 13)
			
			local ToggleCircle = CreateElement("Frame", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = defaultValue and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
				BackgroundColor3 = Theme.TextPrimary,
				BorderSizePixel = 0,
				ZIndex = 9
			}, ToggleButton)
			
			AddCorner(ToggleCircle, 10)
			
			local isToggled = defaultValue
			
			local function UpdateToggle()
				Tween(ToggleButton, 0.2, {
					BackgroundColor3 = isToggled and Theme.Primary or Theme.Secondary
				})
				Tween(ToggleCircle, 0.2, {
					Position = isToggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
				})
				callback(isToggled)
			end
			
			local ToggleClick = CreateElement("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 8
			}, ToggleFrame)
			
			Connect(ToggleClick.MouseButton1Click, function()
				isToggled = not isToggled
				UpdateToggle()
			end)
			
			Animations:Hover(ToggleFrame, {BackgroundColor3 = Theme.Elevated}, {BackgroundColor3 = Theme.Card})
			
			return ToggleFrame
		end
		
		function TabObject:CreateSlider(settings)
			settings = settings or {}
			local sliderText = settings.Text or "Slider"
			local minValue = settings.Min or 0
			local maxValue = settings.Max or 100
			local defaultValue = settings.Default or minValue
			local callback = settings.Callback or function() end
			
			local SliderFrame = CreateElement("Frame", {
				Name = sliderText,
				Size = UDim2.new(1, 0, 0, 65),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,
				ZIndex = 7
			}, TabContent)
			
			AddCorner(SliderFrame, 8)
			AddStroke(SliderFrame, Theme.Border)
			
			local SliderLabel = CreateElement("TextLabel", {
				Size = UDim2.new(1, -70, 0, 25),
				Position = UDim2.new(0, 15, 0, 10),
				BackgroundTransparency = 1,
				Text = sliderText,
				TextColor3 = Theme.TextPrimary,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				ZIndex = 8
			}, SliderFrame)
			
			local SliderValue = CreateElement("TextLabel", {
				Size = UDim2.new(0, 55, 0, 25),
				Position = UDim2.new(1, -70, 0, 10),
				BackgroundTransparency = 1,
				Text = tostring(defaultValue),
				TextColor3 = Theme.TextSecondary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
				Font = Enum.Font.Gotham,
				ZIndex = 8
			}, SliderFrame)
			
			local SliderTrack = CreateElement("Frame", {
				Size = UDim2.new(1, -30, 0, 6),
				Position = UDim2.new(0, 15, 1, -20),
				BackgroundColor3 = Theme.Secondary,
				BorderSizePixel = 0,
				ZIndex = 8
			}, SliderFrame)
			
			AddCorner(SliderTrack, 3)
			
			local SliderFill = CreateElement("Frame", {
				Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = Theme.Primary,
				BorderSizePixel = 0,
				ZIndex = 9
			}, SliderTrack)
			
			AddCorner(SliderFill, 3)
			
			-- Galaxy gradient for slider fill
			local SliderGradient = CreateElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Theme.GalaxyPurple),
					ColorSequenceKeypoint.new(1, Theme.GalaxyCyan)
				}),
				Rotation = 90
			}, SliderFill)
			
			local SliderHandle = CreateElement("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -7, 0.5, -7),
				BackgroundColor3 = Theme.TextPrimary,
				BorderSizePixel = 0,
				ZIndex = 10
			}, SliderTrack)
			
			AddCorner(SliderHandle, 7)
			
			local currentValue = defaultValue
			local dragging = false
			
			local function UpdateSlider(value)
				currentValue = math.clamp(value, minValue, maxValue)
				local percentage = (currentValue - minValue) / (maxValue - minValue)
				
				SliderValue.Text = tostring(math.floor(currentValue))
				Tween(SliderFill, 0.1, {Size = UDim2.new(percentage, 0, 1, 0)})
				Tween(SliderHandle, 0.1, {Position = UDim2.new(percentage, -7, 0.5, -7)})
				
				callback(currentValue)
			end
			
			Connect(SliderTrack.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					local percentage = math.clamp((Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
					local value = minValue + (maxValue - minValue) * percentage
					UpdateSlider(value)
				end
			end)
			
			Connect(Services.UserInputService.InputChanged, function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local percentage = math.clamp((Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
					local value = minValue + (maxValue - minValue) * percentage
					UpdateSlider(value)
				end
			end)
			
			Connect(Services.UserInputService.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			
			Animations:Hover(SliderFrame, {BackgroundColor3 = Theme.Elevated}, {BackgroundColor3 = Theme.Card})
			
			return SliderFrame
		end
		
		function TabObject:CreateDropdown(settings)
			settings = settings or {}
			local dropdownText = settings.Text or "Dropdown"
			local options = settings.Options or {"Option 1", "Option 2"}
			local multiSelect = settings.Multi or false
			local callback = settings.Callback or function() end
			
			local DropdownFrame = CreateElement("Frame", {
				Name = dropdownText,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,
				ClipsDescendants = false,
				ZIndex = 7
			}, TabContent)
			
			AddCorner(DropdownFrame, 8)
			AddStroke(DropdownFrame, Theme.Border)
			
			local DropdownButton = CreateElement("TextButton", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				Text = "",
				BorderSizePixel = 0,
				ZIndex = 8
			}, DropdownFrame)
			
			local DropdownLabel = CreateElement("TextLabel", {
				Size = UDim2.new(1, -50, 1, 0),
				Position = UDim2.new(0, 15, 0, 0),
				BackgroundTransparency = 1,
				Text = dropdownText,
				TextColor3 = Theme.TextPrimary,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				ZIndex = 9
			}, DropdownFrame)
			
			local DropdownArrow = CreateElement("TextLabel", {
				Size = UDim2.new(0, 25, 1, 0),
				Position = UDim2.new(1, -40, 0, 0),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = Theme.TextSecondary,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.Gotham,
				ZIndex = 9
			}, DropdownFrame)
			
			local DropdownList = CreateElement("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 5),
				BackgroundColor3 = Theme.Surface,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 15
			}, DropdownFrame)
			
			AddCorner(DropdownList, 8)
			AddStroke(DropdownList, Theme.Border)
			
			-- Galaxy gradient for dropdown list
			local ListGradient = CreateElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Theme.Surface),
					ColorSequenceKeypoint.new(1, Theme.Card)
				}),
				Rotation = 180
			}, DropdownList)
			
			local DropdownScroll = CreateElement("ScrollingFrame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ScrollBarThickness = 6,
				ScrollBarImageColor3 = Theme.Border,
				BorderSizePixel = 0,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ZIndex = 16
			}, DropdownList)
			
			AddPadding(DropdownScroll, 5)
			AddListLayout(DropdownScroll, Enum.FillDirection.Vertical, 3)
			
			local isOpen = false
			local selectedOptions = multiSelect and {} or nil
			local selectedSingle = nil
			
			-- Enhanced text display function
			local function UpdateDropdownText()
				if multiSelect then
					if #selectedOptions == 0 then
						DropdownLabel.Text = dropdownText
					else
						local displayText = ""
						for i, option in ipairs(selectedOptions) do
							if i == 1 then
								displayText = option
							else
								displayText = displayText .. "," .. option
							end
						end
						
						-- Truncate if too long
						if #displayText > 25 then
							displayText = string.sub(displayText, 1, 22) .. "..."
						end
						
						DropdownLabel.Text = displayText
					end
				else
					DropdownLabel.Text = selectedSingle or dropdownText
				end
			end
			
			local function ToggleDropdown()
				isOpen = not isOpen
				
				if isOpen then
					local listHeight = math.min(#options * 35 + 10, 200)
					DropdownList.Size = UDim2.new(1, 0, 0, listHeight)
					DropdownList.Visible = true
					Tween(DropdownArrow, 0.2, {Rotation = 180})
					Animations:FadeIn(DropdownList, 0.2)
				else
					Tween(DropdownList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
					Tween(DropdownArrow, 0.2, {Rotation = 0})
					task.wait(0.2)
					if DropdownList then
						DropdownList.Visible = false
					end
				end
			end
			
			Connect(DropdownButton.MouseButton1Click, ToggleDropdown)
			
			-- Create option buttons
			for _, option in ipairs(options) do
				local OptionButton = CreateElement("TextButton", {
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = Theme.Card,
					BackgroundTransparency = 1,
					Text = option,
					TextColor3 = Theme.TextPrimary,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham,
					BorderSizePixel = 0,
					ZIndex = 17
				}, DropdownScroll)
				
				AddCorner(OptionButton, 6)
				AddPadding(OptionButton, 10)
				
				if multiSelect then
					local CheckBox = CreateElement("Frame", {
						Size = UDim2.new(0, 18, 0, 18),
						Position = UDim2.new(1, -28, 0.5, -9),
						BackgroundColor3 = Theme.Secondary,
						BorderSizePixel = 0,
						ZIndex = 18
					}, OptionButton)
					
					AddCorner(CheckBox, 4)
					AddStroke(CheckBox, Theme.Border)
					
					local CheckMark = CreateElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "✓",
						TextColor3 = Theme.TextPrimary,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Center,
						Font = Enum.Font.GothamBold,
						Visible = false,
						ZIndex = 19
					}, CheckBox)
					
					Connect(OptionButton.MouseButton1Click, function()
						local isSelected = table.find(selectedOptions, option)
						
						if isSelected then
							table.remove(selectedOptions, isSelected)
							CheckMark.Visible = false
							CheckBox.BackgroundColor3 = Theme.Secondary
						else
							table.insert(selectedOptions, option)
							CheckMark.Visible = true
							CheckBox.BackgroundColor3 = Theme.Primary
						end
						
						UpdateDropdownText()
						callback(selectedOptions)
					end)
				else
					Connect(OptionButton.MouseButton1Click, function()
						selectedSingle = option
						UpdateDropdownText()
						ToggleDropdown()
						callback(option)
					end)
				end
				
				Animations:Hover(OptionButton, {BackgroundTransparency = 0.1}, {BackgroundTransparency = 1})
			end
			
			Animations:Hover(DropdownFrame, {BackgroundColor3 = Theme.Elevated}, {BackgroundColor3 = Theme.Card})
			
			return DropdownFrame
		end
		
		return TabObject
	end
	
	Windows[windowTitle] = WindowObject
	return WindowObject
end

function SiriusUI:GetWindow(name)
	return Windows[name]
end

function SiriusUI:SetKeybind(keybind)
	Config.Keybind = keybind
end

return SiriusUI