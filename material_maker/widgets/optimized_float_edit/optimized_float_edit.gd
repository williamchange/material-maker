class_name  OptimizedFloatEdit

extends Control

var normal_stylebox : StyleBoxFlat
var progress_fill : StyleBoxFlat

var ci := get_canvas_item()

var is_focused : bool = false

var value : float:
	set(v):
		value = v
		queue_redraw()


func _init() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


@export var min_value : float = 0.0:
	set(v):
		min_value = v
		queue_redraw()

@export var max_value : float = 1.0:
	set(v):
		max_value = v
		queue_redraw()

@export var step: float = 0.0 :
	set(v):
		step = v
		_step_decimals = get_decimal_places(v)
		queue_redraw()

# For display. Will always show at least this many decimal places as step.
var _step_decimals := 2

func get_decimal_places(v: float) -> int:
	return (str(v)+".").split(".")[1].length()

func _ready() -> void:
	normal_stylebox = get_theme_stylebox("normal","MM_NodeFloatEdit")
	progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = Color(0.302, 0.302, 0.302, 1.0)
	progress_fill.set_corner_radius_all(normal_stylebox.corner_radius_bottom_left)
	queue_redraw()


func _draw() -> void:
	normal_stylebox.draw(ci, Rect2(Vector2.ZERO, size))
	progress_fill.draw(ci, Rect2(Vector2.ZERO, Vector2(size.x*inverse_lerp(min_value, max_value, value), size.y)))
	draw_string(get_theme_font("font"), Vector2(size.x-get_theme_font("font").get_string_size(str(value).pad_decimals(_step_decimals)).x, size.y - 5), str(value).pad_decimals(_step_decimals), HORIZONTAL_ALIGNMENT_LEFT, size.x, 14, Color.WHITE)
	if is_focused:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1,1,1,0.2))


func _on_mouse_entered() -> void:
	is_focused = true
	queue_redraw()


func _on_mouse_exited() -> void:
	is_focused = false
	queue_redraw()
