local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")
local GetPlugin = require("../Lib/GetPlugin")
local Levenshtein = require("../Lib/Levenshtein")
local Reflection = require("../Lib/Reflection")
local Convert = require("./Convert")

local plugin = GetPlugin

local module = {}

local colourSyncTargets: {GuiObject} = {}

local widget = plugin:CreateDockWidgetPluginGui("ClassConvert", DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	true,
	600,
	400,
	600,
	400
	)
)

widget.Name = "Class Convert"
widget.Title = "Class Convert"
widget.ResetOnSpawn = false
widget.Enabled = false

local frame = Instance.new("Frame")
frame.Transparency = 1
frame.Size = UDim2.fromScale(1, 1)

do
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0.025, 0)
	padding.PaddingRight = UDim.new(0.025, 0)
	padding.PaddingTop = UDim.new(0.025, 0)
	padding.Parent = frame
	
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 10)
	list.FillDirection = Enum.FillDirection.Vertical
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = frame
	
	local separator = Instance.new("Frame")
	separator.BackgroundColor3 = Color3.new(0, 0, 0)
	separator.Size = UDim2.fromScale(1, 0.01)
	separator.Name = "Separator"
	separator.LayoutOrder = 3
	separator.Parent = frame
	table.insert(colourSyncTargets, separator)
end

local searchBar = Instance.new("TextBox")
searchBar.Font = Enum.Font.SourceSans
searchBar.AnchorPoint = Vector2.new(0.5, 0)
searchBar.Position = UDim2.fromScale(0.5, 0)
searchBar.Size = UDim2.fromScale(1, 0.1)
searchBar.Text = ""
searchBar.PlaceholderText = "Search..."
searchBar.TextScaled = true
searchBar.TextXAlignment = Enum.TextXAlignment.Left
searchBar.Name = "SearchBar"
searchBar.ClearTextOnFocus = false
searchBar.Parent = frame
table.insert(colourSyncTargets, searchBar)

do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.4, 0)
	corner.Parent = searchBar
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = searchBar
end

local resultsGrid = Instance.new("ScrollingFrame")
resultsGrid.BackgroundTransparency = 1
resultsGrid.Position = UDim2.new(0, 0, 0.11, 10)
resultsGrid.Size = UDim2.fromScale(1, 0.74)
resultsGrid.CanvasSize = UDim2.fromScale(0, 0)
resultsGrid.ScrollBarThickness = 6
resultsGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
resultsGrid.ScrollingDirection = Enum.ScrollingDirection.Y
resultsGrid.ScrollBarImageColor3 = Color3.new(0, 0, 0)
resultsGrid.BorderSizePixel = 4
resultsGrid.LayoutOrder = 4
resultsGrid.Name = "Results"
resultsGrid.Parent = frame
table.insert(colourSyncTargets, resultsGrid)

do
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromScale(1, 0.1)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = resultsGrid
end

local resultBase = Instance.new("TextButton")
resultBase.Text = ""
resultBase.Name = "Result"

do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.25)
	corner.Parent = resultBase
	
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0, 5)
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = resultBase
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = resultBase
	
	local label = Instance.new("TextLabel")
	label.Font = Enum.Font.SourceSans
	label.TextScaled = true
	label.Size = UDim2.fromScale(1, 1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Name = "Label"
	label.Parent = resultBase
	
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromScale(1, 0.9)
	icon.Image = ""
	icon.Parent = resultBase
	
	do
		local aspectRatio = Instance.new("UIAspectRatioConstraint")
		aspectRatio.DominantAxis = Enum.DominantAxis.Height
		aspectRatio.Parent = icon
	end
end

local function updateSearch()
	local text = searchBar.Text:lower()
	local visibleElements: {TextButton} = {}
	for _, v in resultsGrid:GetChildren() do
		if not v:IsA("TextButton") then
			continue
		end
		if v.Name:lower():match(text) then
			v.Visible = true
			table.insert(visibleElements, v)
		else
			v.Visible = false
		end
	end
	
	table.sort(visibleElements, function(a, b)
		return Levenshtein(a.Name:lower(), text) < Levenshtein(b.Name:lower(), text)
	end)
	
	for i, v in visibleElements do
		v.LayoutOrder = i
	end
end

searchBar:GetPropertyChangedSignal("Text"):Connect(updateSearch)

frame.Parent = widget

local function convert(to: string): ()
	local lastSelection = Selection:Get()
	local result = Convert.ConvertMany(lastSelection, to)
	Selection:Set(result or lastSelection)
end

local function setIcon(imageLabel: ImageLabel, class: Reflection.Class): ()
	local iconData = StudioService:GetClassIcon(class.Name)
	for k, v in iconData do
		(imageLabel :: any)[k] = v
	end
end

local function syncOne(v: GuiObject, theme: any)
	if v:IsA("ImageLabel") then
		setIcon(v, Reflection.GetClass((v.Parent or error("No parent")).Name))
	elseif v.Name == "Separator" and v.ClassName == "Frame" then
		v.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
	elseif v.Name == "Results" and v.ClassName == "ScrollingFrame" then
		v.BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
	else
		assert(v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox"));
		(v :: TextLabel).BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScriptEditorCurrentLine);
		(v :: TextLabel).TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
	end
end

local function addClass(class: Reflection.Class): ()
	local result = resultBase:Clone()
	local label = result:FindFirstChild("Label") :: TextLabel
	local icon = result:FindFirstChild("Icon") :: ImageLabel

	label.Text = class.Name
	result:SetAttribute("Deprecated", false)
	result:SetAttribute("NonBrowsable", false)
	result.Name = class.Name

	result.Parent = resultsGrid

	table.insert(colourSyncTargets, result)
	table.insert(colourSyncTargets, label)
	table.insert(colourSyncTargets, icon)

	syncOne(result, settings().Studio.Theme)
	syncOne(label, settings().Studio.Theme)
	syncOne(icon, settings().Studio.Theme)

	result.MouseButton1Click:Connect(function()
		convert(class.Name)
	end)
end

local function syncColours()
	local theme = settings().Studio.Theme
	for _, v in colourSyncTargets do
		syncOne(v, theme)
	end
end

syncColours()
settings().Studio.ThemeChanged:Connect(syncColours)

function module.PopulateClasses(): ()
	local classes = Reflection.GetClasses()
	for _, class in classes do
		if not class.Permits.New then
			continue
		end
		addClass(class)
	end
end

function module.ToggleWidget(enabled: boolean?): ()
	widget.Enabled = if typeof(enabled) == "boolean" then enabled else not widget.Enabled

	if widget.Enabled then
		searchBar:CaptureFocus()
	end
end

module.Widget = widget

return module