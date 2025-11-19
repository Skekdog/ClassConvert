local RunService = game:GetService("RunService")

if not RunService:IsServer() and not RunService:IsEdit() then
	-- Read the docs! In team create, IsServer() returns false. So we also need to check IsEdit()
	return
end

local Toolbar = require("./Plugin/Toolbar")

Toolbar.OnClick = function()
	local Widget = require("./Plugin/Widget")
	Widget.PopulateClasses()
	Widget.ToggleWidget()
end