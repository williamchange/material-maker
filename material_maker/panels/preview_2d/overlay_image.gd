extends Control

var image_scale : float = 1.0
var offset : Vector2
var texture : Texture2D

func _draw() -> void:
	if texture:
		const half : Vector2 = Vector2.ONE * 0.5
		var aspect : float = float(texture.get_width()) / float(texture.get_height())
		var adjust : Vector2 = Vector2(aspect, 1.0)
		var isize : Vector2 = half * image_scale * adjust
		var from : Vector2 = get_parent().value_to_pos(-isize + offset)
		var to : Vector2 = get_parent().value_to_pos(isize + offset)
		draw_texture_rect(texture, Rect2(from, to - from), false, modulate)
