local ReflectionService = game:GetService("ReflectionService")

type ClassPermits = {
	GetService: number?,
	New: number?,
}

type PropertyPermits = {
	Read: number?,
	Write: number?,
}

-- [EngineType]: ScriptType
type Types = {
	BinaryString: nil,
	Enum: "EnumItem",
	RefType: "Instance",
	SecurityCapabilities: "SecurityCapabilities",
	UniqueId: nil,
	Vector3: "Vector3",
	bool: "boolean",
	float: "number",
	int64: "number",
	string: "string",
	BrickColor: "BrickColor",
	Color3: "Color3",
	Color3uint8: "Color3",
	CoordinateFrame: "CFrame",
	Faces: "Faces",
	PhysicalProperties: "PhysicalProperties",
	Region3int16: "Region3int16",
	ReplicationPV: nil,
	SystemAddress: nil,
	Vector2: "Vector2",
	Rect2D: "Rect",
	UDim2: "UDim2",
	Content: "Content",
	ContentId: "string",
	SharedString: nil,
	double: "number",
	OptionalCoordinateFrame: "CFrame",
	NumberRange: "NumberRange",
	NumberSequence: "NumberSequence",
	ColorSequence: "ColorSequence",
}

type EngineType = keyof<Types>
type ScriptType = index<Types, EngineType>

type Display = {
	Category: string,
	LayoutOrder: number,
}

export type ClassProperty = {
	Name: string,
	Permits: PropertyPermits,
	Display: Display,
	Serialized: boolean,
	Type: {
		EngineType: EngineType,
		ScriptType: ScriptType,
	}
}

export type Class = {
	Name: string,
	Display: Display,
	Permits: ClassPermits,
	Superclass: string?, -- Only nil for the Object class
	Subclasses: {string}?, -- Only classes that inherit directly from Object have this property
}

export type GetClassesResult = {Class}
export type GetPropertiesOfClassResult = {ClassProperty}

local module = {}

function module.GetClasses(): GetClassesResult
	return ReflectionService:GetClasses()
end

module.GetClass = module.GetClass

function module.GetPropertiesOfClass(className: string): GetPropertiesOfClassResult
	return ReflectionService:GetPropertiesOfClass(className)
end

function module.GetClass(className: string): Class
	return ReflectionService:GetClass(className) or error("Class not found: " .. className)
end

return module