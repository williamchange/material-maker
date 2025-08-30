extends MMGenBase

class_name MMGenAlcubierre

# Alcubierre Link

var editable = false


func get_type() -> String:
	return "alcubierre"


func get_type_name() -> String:
	return "Alcubierre Dest."


func is_editable() -> bool:
	return editable


func get_output_defs(_show_hidden : bool = false) -> Array:
	return [ { type="any" } ]


func get_parameter_defs() -> Array:
	return [
			{ name="node_id", label="Source", type="string", default="" },
			{ name="port_id", label="Port", type="string", default="0" }
		]


func _update(p, v) -> void:
	notify_output_change(0)


func get_description() -> String:
	var desc_list : PackedStringArray = PackedStringArray()
	desc_list.push_back(TranslationServer.translate("Alcubierre Destination"))
	desc_list.push_back(TranslationServer.translate("Some sort of warp drive"))
	return "\n".join(desc_list)


func _get_shader_code(uv : String, output_index : int, context : MMGenContext) -> ShaderCode:
	var generator
	var graph = get_parent().get_parent()
	if graph is GraphEdit:
		if graph.has_node("node_" + parameters.node_id):
			var node = graph.get_node("node_" + parameters.node_id)
			if node is GraphNode:
				generator = node.generator
				if not generator.is_connected("parameter_changed", _update):
					generator.parameter_changed.connect(_update)
	if generator != null:
		return generator.get_shader_code(uv, int(parameters.port_id), context)
	return get_default_generated_shader()


func _serialize(data: Dictionary) -> Dictionary:
	return data
