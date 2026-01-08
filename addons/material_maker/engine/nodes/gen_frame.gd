extends MMGenBase
class_name MMGenFrame

# GraphFrame

var title : String = "Frame"
var size : Vector2 = Vector2(300, 200)
var color : Color = Color("5f425bbf")
var text : String = ""

func _ready() -> void:
	pass

func get_type() -> String:
	return "frame"

func get_type_name() -> String:
	return "Frame"

func get_parameter_defs() -> Array:
	return []

func get_input_defs() -> Array:
	return []

func get_output_defs(_show_hidden : bool = false) -> Array:
	return []

func is_editable() -> bool:
	return false

func _serialize(data: Dictionary) -> Dictionary:
	data.type = "frame"
	data.size = { x=size.x, y=size.y }
	data.color = MMType.serialize_value(color)
	data.title = title
	data.text = text
	return data

func _deserialize(data : Dictionary) -> void:
	if data.has("title"):
		title = data.title
	if data.has("text"):
		text = data.text
	if data.has("title"):
		color = MMType.deserialize_value(data.color)
	if data.has("size"):
		size = Vector2(data.size.x, data.size.y)
