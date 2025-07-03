--[[
	SiriusUI - Complete UI Library
	Advanced Cheat Menu Library with Modern Design
	Version 3.0 - Enhanced Edition
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

--// Modern Dark Theme
local Theme = {
	--// Main Colors
	Background = Color3.fromRGB(16, 16, 20),
	Surface = Color3.fromRGB(22, 22, 28),
	Card = Color3.fromRGB(28, 28, 35),
	Elevated = Color3.fromRGB(35, 35, 42),
	
	--// Interactive Elements
	Primary = Color3.fromRGB(88, 101, 242),
	PrimaryHover = Color3.fromRGB(78, 91, 232),
	Secondary = Color3.fromRGB(64, 68, 75),
	Success = Color3.fromRGB(67, 181, 129),
	Warning = Color3.fromRGB(250, 166, 26),
	Error = Color3.fromRGB(237, 66, 69),
	
	--// Text Colors
	TextPrimary = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(185, 187, 190),
	TextMuted = Color3.fromRGB(142, 146, 151),
	TextDisabled = Color3.fromRGB(96, 100, 108),
	
	--// Borders & Outlines
	Border = Color3.fromRGB(45, 45, 52),
	BorderHover = Color3.fromRGB(55, 55, 62),
	Accent = Color3.fromRGB(114, 137, 218),
	
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

--// Drag System
local function MakeDraggable(element, dragHandle)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	dragHandle = dragHandle or element
	
	Connect(dragHandle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = element.Position
		end
	end)
	
	Connect(dragHandle.InputChanged, function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			element.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	Connect(dragHandle.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
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
	
	--// Main Window Frame
	local Window = CreateElement("Frame", {
		Name = "SiriusWindow",
		Size = windowSize,
		Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false
	}, ScreenGui)
	
	AddCorner(Window, 12)
	AddStroke(Window, Theme.Border, 1)
	
	--// Window Shadow
	local Shadow = CreateElement("ImageLabel", {
		Name = "Shadow",
		Size = UDim2.new(1, 20, 1, 20),
		Position = UDim2.new(0, -10, 0, -10),
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		ImageColor3 = Theme.Shadow,
		ImageTransparency = 0.8,
		ZIndex = -1
	}, Window)
	
	--// Title Bar
	local TitleBar = CreateElement("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0
	}, Window)
	
	AddCorner(TitleBar, 12)
	
	--// Title Bar Bottom Border
	local TitleBorder = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0
	}, TitleBar)
	
	--// Window Title
	local Title = CreateElement("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		Text = windowTitle,
		TextColor3 = Theme.TextPrimary,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold
	}, TitleBar)
	
	--// Close Button
	local CloseButton = CreateElement("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = Theme.Error,
		BackgroundTransparency = 0.9,
		Text = "×",
		TextColor3 = Theme.TextPrimary,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0
	}, TitleBar)
	
	AddCorner(CloseButton, 6)
	
	--// Minimize Button
	local MinimizeButton = CreateElement("TextButton", {
		Name = "MinimizeButton",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -70, 0, 5),
		BackgroundColor3 = Theme.Secondary,
		BackgroundTransparency = 0.9,
		Text = "−",
		TextColor3 = Theme.TextPrimary,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0
	}, TitleBar)
	
	AddCorner(MinimizeButton, 6)
	
	--// Sidebar
	local Sidebar = CreateElement("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 160, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0
	}, Window)
	
	local SidebarBorder = CreateElement("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0
	}, Sidebar)
	
	--// Tab Container
	local TabContainer = CreateElement("ScrollingFrame", {
		Name = "TabContainer",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Border,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	}, Sidebar)
	
	AddPadding(TabContainer, 8)
	AddListLayout(TabContainer, Enum.FillDirection.Vertical, 4)
	
	--// Content Area
	local ContentArea = CreateElement("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -160, 1, -40),
		Position = UDim2.new(0, 160, 0, 40),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0
	}, Window)
	
	--// Tab Content Container
	local TabContentContainer = CreateElement("Frame", {
		Name = "TabContentContainer",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	}, ContentArea)
	
	--// Make window draggable
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
			Tween(Window, 0.3, {Size = UDim2.new(0, windowSize.X.Offset, 0, 40)})
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
	
	--// Button Animations
	Animations:Hover(CloseButton, {BackgroundTransparency = 0.7}, {BackgroundTransparency = 0.9})
	Animations:Hover(MinimizeButton, {BackgroundTransparency = 0.7}, {BackgroundTransparency = 0.9})
	
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
		
		--// Tab Button
		local TabButton = CreateElement("TextButton", {
			Name = tabName,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Card,
			BackgroundTransparency = 1,
			Text = "",
			BorderSizePixel = 0
		}, TabContainer)
		
		AddCorner(TabButton, 6)
		
		--// Tab Icon
		local TabIcon = CreateElement("ImageLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 12, 0.5, -10),
			BackgroundTransparency = 1,
			Image = tabIcon,
			ImageColor3 = Theme.TextSecondary
		}, TabButton)
		
		--// Tab Label
		local TabLabel = CreateElement("TextLabel", {
			Size = UDim2.new(1, -44, 1, 0),
			Position = UDim2.new(0, 40, 0, 0),
			BackgroundTransparency = 1,
			Text = tabName,
			TextColor3 = Theme.TextSecondary,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham
		}, TabButton)
		
		--// Tab Content
		local TabContent = CreateElement("ScrollingFrame", {
			Name = tabName .. "Content",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = Theme.Border,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false
		}, TabContentContainer)
		
		AddPadding(TabContent, 16)
		AddListLayout(TabContent, Enum.FillDirection.Vertical, 12)
		
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
			TabButton.BackgroundTransparency = 0
			TabIcon.ImageColor3 = Theme.Primary
			TabLabel.TextColor3 = Theme.TextPrimary
			TabContent.Visible = true
			WindowObject.CurrentTab = tabName
		end
		
		Connect(TabButton.MouseButton1Click, SelectTab)
		
		--// Tab Animations
		Animations:Hover(TabButton, 
			{BackgroundTransparency = 0.8}, 
			{BackgroundTransparency = WindowObject.CurrentTab == tabName and 0 or 1}
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
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Text = sectionName,
				TextColor3 = Theme.TextPrimary,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.GothamBold
			}, TabContent)
			
			return Section
		end
		
		function TabObject:CreateButton(settings)
			settings = settings or {}
			local buttonText = settings.Text or "Button"
			local callback = settings.Callback or function() end
			
			local Button = CreateElement("TextButton", {
				Name = buttonText,
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.Primary,
				Text = buttonText,
				TextColor3 = Theme.TextPrimary,
				TextSize = 14,
				Font = Enum.Font.GothamSemibold,
				BorderSizePixel = 0
			}, TabContent)
			
			AddCorner(Button, 6)
			
			Connect(Button.MouseButton1Click, callback)
			
			Animations:Hover(Button, {BackgroundColor3 = Theme.PrimaryHover}, {BackgroundColor3 = Theme.Primary})
			Animations:Click(Button, {Size = UDim2.new(1, -4, 0, 34)}, {Size = UDim2.new(1, 0, 0, 36)})
			
			return Button
		end
		
		function TabObject:CreateToggle(settings)
			settings = settings or {}
			local toggleText = settings.Text or "Toggle"
			local defaultValue = settings.Default or false
			local callback = settings.Callback or function() end
			
			local ToggleFrame = CreateElement("Frame", {
				Name = toggleText,
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0
			}, TabContent)
			
			AddCorner(ToggleFrame, 6)
			AddStroke(ToggleFrame, Theme.Border)
			
			local ToggleLabel = CreateElement("TextLabel", {
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text = toggleText,
				TextColor3 = Theme.TextPrimary,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham
			}, ToggleFrame)
			
			local ToggleButton = CreateElement("Frame", {
				Size = UDim2.new(0, 44, 0, 24),
				Position = UDim2.new(1, -52, 0.5, -12),
				BackgroundColor3 = defaultValue and Theme.Primary or Theme.Secondary,
				BorderSizePixel = 0
			}, ToggleFrame)
			
			AddCorner(ToggleButton, 12)
			
			local ToggleCircle = CreateElement("Frame", {
				Size = UDim2.new(0, 18, 0, 18),
				Position = defaultValue and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
				BackgroundColor3 = Theme.TextPrimary,
				BorderSizePixel = 0
			}, ToggleButton)
			
			AddCorner(ToggleCircle, 9)
			
			local isToggled = defaultValue
			
			local function UpdateToggle()
				Tween(ToggleButton, 0.2, {
					BackgroundColor3 = isToggled and Theme.Primary or Theme.Secondary
				})
				Tween(ToggleCircle, 0.2, {
					Position = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
				})
				callback(isToggled)
			end
			
			local ToggleClick = CreateElement("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = ""
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
				Size = UDim2.new(1, 0, 0, 56),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0
			}, TabContent)
			
			AddCorner(SliderFrame, 6)
			AddStroke(SliderFrame, Theme.Border)
			
			local SliderLabel = CreateElement("TextLabel", {
				Size = UDim2.new(1, -60, 0, 20),
				Position = UDim2.new(0, 12, 0, 8),
				BackgroundTransparency = 1,
				Text = sliderText,
				TextColor3 = Theme.TextPrimary,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham
			}, SliderFrame)
			
			local SliderValue = CreateElement("TextLabel", {
				Size = UDim2.new(0, 48, 0, 20),
				Position = UDim2.new(1, -60, 0, 8),
				BackgroundTransparency = 1,
				Text = tostring(defaultValue),
				TextColor3 = Theme.TextSecondary,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				Font = Enum.Font.Gotham
			}, SliderFrame)
			
			local SliderTrack = CreateElement("Frame", {
				Size = UDim2.new(1, -24, 0, 4),
				Position = UDim2.new(0, 12, 1, -16),
				BackgroundColor3 = Theme.Secondary,
				BorderSizePixel = 0
			}, SliderFrame)
			
			AddCorner(SliderTrack, 2)
			
			local SliderFill = CreateElement("Frame", {
				Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = Theme.Primary,
				BorderSizePixel = 0
			}, SliderTrack)
			
			AddCorner(SliderFill, 2)
			
			local SliderHandle = CreateElement("Frame", {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -6, 0.5, -6),
				BackgroundColor3 = Theme.TextPrimary,
				BorderSizePixel = 0
			}, SliderTrack)
			
			AddCorner(SliderHandle, 6)
			
			local currentValue = defaultValue
			local dragging = false
			
			local function UpdateSlider(value)
				currentValue = math.clamp(value, minValue, maxValue)
				local percentage = (currentValue - minValue) / (maxValue - minValue)
				
				SliderValue.Text = tostring(math.floor(currentValue))
				Tween(SliderFill, 0.1, {Size = UDim2.new(percentage, 0, 1, 0)})
				Tween(SliderHandle, 0.1, {Position = UDim2.new(percentage, -6, 0.5, -6)})
				
				callback(currentValue)
			end
			
			Connect(SliderTrack.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local percentage = math.clamp((Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
					local value = minValue + (maxValue - minValue) * percentage
					UpdateSlider(value)
				end
			end)
			
			Connect(Services.UserInputService.InputChanged, function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local percentage = math.clamp((Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
					local value = minValue + (maxValue - minValue) * percentage
					UpdateSlider(value)
				end
			end)
			
			Connect(Services.UserInputService.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,
				ClipsDescendants = false
			}, TabContent)
			
			AddCorner(DropdownFrame, 6)
			AddStroke(DropdownFrame, Theme.Border)
			
			local DropdownButton = CreateElement("TextButton", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Text = "",
				BorderSizePixel = 0
			}, DropdownFrame)
			
			local DropdownLabel = CreateElement("TextLabel", {
				Size = UDim2.new(1, -40, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text = dropdownText,
				TextColor3 = Theme.TextPrimary,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham
			}, DropdownFrame)
			
			local DropdownArrow = CreateElement("TextLabel", {
				Size = UDim2.new(0, 20, 1, 0),
				Position = UDim2.new(1, -32, 0, 0),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = Theme.TextSecondary,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.Gotham
			}, DropdownFrame)
			
			local DropdownList = CreateElement("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 4),
				BackgroundColor3 = Theme.Surface,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 10
			}, DropdownFrame)
			
			AddCorner(DropdownList, 6)
			AddStroke(DropdownList, Theme.Border)
			
			local DropdownScroll = CreateElement("ScrollingFrame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ScrollBarThickness = 4,
				ScrollBarImageColor3 = Theme.Border,
				BorderSizePixel = 0,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y
			}, DropdownList)
			
			AddPadding(DropdownScroll, 4)
			AddListLayout(DropdownScroll, Enum.FillDirection.Vertical, 2)
			
			local isOpen = false
			local selectedOptions = multiSelect and {} or nil
			local selectedSingle = nil
			
			local function UpdateDropdownText()
				if multiSelect then
					if #selectedOptions == 0 then
						DropdownLabel.Text = dropdownText
					elseif #selectedOptions == 1 then
						DropdownLabel.Text = selectedOptions[1]
					else
						DropdownLabel.Text = selectedOptions[1] .. " (+" .. (#selectedOptions - 1) .. ")"
					end
				else
					DropdownLabel.Text = selectedSingle or dropdownText
				end
			end
			
			local function ToggleDropdown()
				isOpen = not isOpen
				
				if isOpen then
					local listHeight = math.min(#options * 32 + 8, 200)
					DropdownList.Size = UDim2.new(1, 0, 0, listHeight)
					DropdownList.Visible = true
					Tween(DropdownArrow, 0.2, {Rotation = 180})
					Animations:FadeIn(DropdownList, 0.2)
				else
					Tween(DropdownList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
					Tween(DropdownArrow, 0.2, {Rotation = 0})
					task.wait(0.2)
					DropdownList.Visible = false
				end
			end
			
			Connect(DropdownButton.MouseButton1Click, ToggleDropdown)
			
			-- Create option buttons
			for _, option in ipairs(options) do
				local OptionButton = CreateElement("TextButton", {
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = Theme.Card,
					BackgroundTransparency = 1,
					Text = option,
					TextColor3 = Theme.TextPrimary,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham,
					BorderSizePixel = 0
				}, DropdownScroll)
				
				AddCorner(OptionButton, 4)
				AddPadding(OptionButton, 8)
				
				if multiSelect then
					local CheckBox = CreateElement("Frame", {
						Size = UDim2.new(0, 16, 0, 16),
						Position = UDim2.new(1, -24, 0.5, -8),
						BackgroundColor3 = Theme.Secondary,
						BorderSizePixel = 0
					}, OptionButton)
					
					AddCorner(CheckBox, 3)
					AddStroke(CheckBox, Theme.Border)
					
					local CheckMark = CreateElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "✓",
						TextColor3 = Theme.TextPrimary,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Center,
						Font = Enum.Font.GothamBold,
						Visible = false
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
				
				Animations:Hover(OptionButton, {BackgroundTransparency = 0.9}, {BackgroundTransparency = 1})
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