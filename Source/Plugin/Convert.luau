local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Reflection = require("../Lib/Reflection")

local module = {}

local function convert(from: Instance, to: string): Instance
	local new: Instance = Instance.new(to)

	for _, v in Reflection.GetPropertiesOfClass(from.ClassName) do
		pcall(function()
			(new :: any)[v.Name] = (from :: any)[v.Name]
		end)
	end

	for _, v in from:GetChildren() do
		v.Parent = new
	end

	for i, v in from:GetAttributes() do
		new:SetAttribute(i, v)
	end

	for _, v in from:GetTags() do
		new:AddTag(v)
	end

	new.Parent = from.Parent
	from.Parent = nil -- :Destroy() locks the parent property, which means that undo does not work!

	return new
end

function module.ConvertMany(from: {Instance}, to: string): {Instance}?
	if #from < 1 then
		warn("No selection, conversions will not be made.")
		return nil
	end

	local recording = ChangeHistoryService:TryBeginRecording(`Convert classes of selection to {to}`)
	if not recording then
		warn("Unable to create undo waypoint, possibly due to another conversion already taking place. Conversion aborted.")
		return nil
	end

	local newInstances: {Instance} = {}
	local success, err = pcall(function() -- In case anything errors we NEED undo to be possible, best not take chances
		for _, instance in from do
			table.insert(newInstances, convert(instance, to))
		end
		return nil :: string?
	end)

	if not success then
		warn("Conversion failed: " .. (err or "unknown error"))
	end

	ChangeHistoryService:FinishRecording(recording, if success then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel)
	return if success then newInstances else from
end

return module