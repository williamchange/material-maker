@tool
extends MMGenTexture
class_name MMGenNinePatch


# Texture generator from NinePatchRect

var updating : bool = false
var update_again : bool = false

func _ready() -> void:
	update_buffer()

func get_type() -> String:
	return "ninepatch"

func get_type_name() -> String:
	return "NinePatch"

func get_description() -> String:
	var desc_list : PackedStringArray = PackedStringArray()
	desc_list.push_back(TranslationServer.translate("Nine Slice"))
	desc_list.push_back(TranslationServer.translate("Nine sliced panel as an image"))
	return "\n".join(desc_list)

func get_parameter_defs() -> Array:
	return [
		{ name="image", type="image_path", label="", default="" },
		{ name="axis_stretch_horizontal", label="Horizontal", default=1, type="enum", values=[
				{ "name": "Stetch", "value": "0" },
				{ "name": "Tile", "value": "1" },
				{ "name": "Tile Fit", "value": "2" }
				]},
		{ name="axis_stretch_vertical", label="Vertical", default=1, type="enum", values=[
				{ "name": "Stetch", "value": "0" },
				{ "name": "Tile", "value": "1" },
				{ "name": "Tile Fit", "value": "2" }
				]},
		{ name="draw_center", label="Draw Center", type="boolean", default=true },
		{ name="size_x", label="Size X", type="float", min=0.0, max=1.0, step=0.01, default=0.15 },
		{ name="size_y", label="SIze Y", type="float", min=0.0, max=1.0, step=0.01, default=0.15 },
		{ name="left", label="Margin Left", type="float", min=0.0, max=512.0, step=1, default=0 },
		{ name="top", label="Margin Top", type="float", min=0.0, max=512.0, step=1, default=0 },
		{ name="right", label="Margin Right", type="float", min=0.0, max=512.0, step=1, default=0 },
		{ name="bottom", label="Margin Bottom", type="float", min=0.0, max=512.0, step=1, default=0 }
	]

func set_parameter(n : String, v) -> void:
	super.set_parameter(n, v)
	if is_inside_tree():
		update_buffer()

func calculate_float_param(n : String, default_value : float = 0.0) -> float:
	var param_value = get_parameter(n)
	if param_value is int:
		return float(param_value)
	elif param_value is float:
		return param_value
	elif param_value is String:
		var expression = Expression.new()
		var error = expression.parse(param_value, [])
		if error == OK:
			var result = expression.execute([], null, true)
			if not expression.has_execute_failed():
				if result is int:
					return float(result)
				elif result is float:
					return result
	return default_value

func update_buffer() -> void:
	update_again = true
	if !updating:
		updating = true
		var renderer = await mm_renderer.request(self)
		while update_again:
			update_again = false
			renderer = await renderer.render_nine_patch(self,
					get_parameter("image"),
					Vector4(get_parameter("left"), get_parameter("top"),
					get_parameter("right"), get_parameter("bottom")),
					calculate_float_param("size_x"), calculate_float_param("size_y"),
					get_parameter("draw_center"),
					get_parameter("axis_stretch_horizontal"),
					get_parameter("axis_stretch_vertical"))
		var image_texture : ImageTexture = ImageTexture.new()
		renderer.copy_to_texture(image_texture)
		renderer.release(self)
		texture.set_texture(image_texture)
		mm_deps.dependency_update("o%d_tex" % get_instance_id(), texture)
		mm_deps.update()
		updating = false

func _serialize(data: Dictionary) -> Dictionary:
	return data
