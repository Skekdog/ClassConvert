if not settings():GetFFlag("NewReflectionService") then
	error("NewReflectionService is not enabled. Class Convert will not work.")
end

local RunService = game:GetService("RunService")
if not RunService:IsServer() and not RunService:IsEdit() then
	-- Read the docs! In team create, IsServer() returns false. So we also need to check IsEdit()
	return
end

local Toolbar = require("./Plugin/Toolbar")
local Widget = require("./Plugin/Widget")

Widget.PopulateClasses()

Toolbar.OnClick = function()
	Widget.ToggleWidget()
end