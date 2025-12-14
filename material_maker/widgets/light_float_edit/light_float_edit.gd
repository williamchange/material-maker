class_name  LightFloatEdit

extends PanelContainer

var has_focus : bool = false

var value : float:
	set(v):
		value = v
		queue_redraw()

var min_value : float:
	set(v):
		min_value = v
		queue_redraw()

var max_value : float:
	set(v):
		max_value = v
		queue_redraw()

func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y)), Color(0.169, 0.176, 0.192, 1.0))
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x*inverse_lerp(min_value, max_value, value), size.y)), Color(0.302, 0.302, 0.302, 1.0))
	draw_string(get_theme_font("font"), Vector2(size.x-get_theme_font("font").get_string_size(str(value).pad_decimals(3)).x, size.y - 5), str(value).pad_decimals(3), 0, size.x, 14, Color.WHITE)
	if has_focus:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1,1,1,0.2))
