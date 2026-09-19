class_name MMTouch
extends Node

## basic touch handling and android utilities

var active_touch : int = -1
var active_touch_drag : int = -1

var touch_info : Dictionary[int, Vector2] = {}

var _display_corner_radii : PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
var _dispalay_cutout_margins : PackedInt32Array = PackedInt32Array([0, 0, 0, 0])

signal back_pressed()

func _ready() -> void:
	if OS.get_name() != "Android":
		set_process_input(false)
	else:
		_display_corner_radii = _get_corner_radius()
		_dispalay_cutout_margins = _get_cutout_margins()

var _touch_start : int = -1

## Time between touch down/up events in milliseconds.
var last_touch_duration_msec : int = -1

## Time since last touch down event in milliseconds.
var time_since_touch_down : int = -1:
	get: return Time.get_ticks_msec() - _touch_start

func _input(event : InputEvent) -> void:
	if event is InputEventScreenDrag:
		touch_info[event.index] = event.position
		active_touch_drag = event.index
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = Time.get_ticks_msec()
			active_touch = event.index
			touch_info[event.index] = event.position
		elif not event.pressed:
			last_touch_duration_msec = Time.get_ticks_msec() - _touch_start
			if touch_info.has(event.index):
				touch_info.erase(event.index)

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			back_pressed.emit()

			var main_window = get_node("/root/MainWindow")
			var exclude : PackedStringArray = PackedStringArray(["AddNodePopup"])
			var windows : Array[Window]

			if main_window:
				windows.append(_get_first_window_child(main_window, exclude))
				windows.append(_get_first_window_child(main_window.get_current_graph_edit(), exclude))

				# ask window to quit
				for window in windows:
					if window:
						window.close_requested.emit()
						return

				# quit only if there are no other dialogs left
				main_window.quit()

func _get_first_window_child(node : Node, exclude_list : PackedStringArray) -> Window:
	if node != null:
		for w in node.get_children():
			if w is Window and w.name not in exclude_list:
				return w
	return null

## Get display corner radius per corner.
func corner_radius(corner : Corner, scale : float = mm_globals.get_ui_scale()) -> int:
	return ceili(_display_corner_radii[corner] / scale)

## Get cutout margins per side.
func cutout_margins(side : Side, scale : float = mm_globals.get_ui_scale()) -> int:
	return ceili(_dispalay_cutout_margins[side] / scale)

func connect_input(control : Control) -> void:
	if not control.gui_input.is_connected(_input):
		control.gui_input.connect(_input)

func make_dialog_fullscreen(window : Window) -> void:
	var main_window : PanelContainer = get_node("/root/MainWindow")
	window.borderless = true
	window.size = main_window.size
	window.min_size = Vector2.ZERO
	window.position = Vector2.ZERO
	# offset by MM_MainBackground stylebox content margins
	window.position.x += calc_margins(Side.SIDE_LEFT) - 10
	window.size.x -= (window.position.x + cutout_margins(Side.SIDE_RIGHT))

func setup_dialog(window : Window) -> void:
	make_dialog_fullscreen(window)
	window.show()

## Get display safe margins accounting for cutouts and corner radii.
func calc_margins(side : Side) -> int:
	var top : int = cutout_margins(SIDE_TOP)
	var bottom : int = cutout_margins(SIDE_BOTTOM)
	match side:
		Side.SIDE_LEFT:
			var top_left : int = _inset(corner_radius(CORNER_TOP_LEFT), top)
			var bottom_left : int = _inset(corner_radius(CORNER_BOTTOM_LEFT), bottom)
			return maxi(maxi(top_left, bottom_left),  cutout_margins(SIDE_LEFT))
		Side.SIDE_RIGHT:
			var top_right : int = _inset(corner_radius(CORNER_TOP_RIGHT), top)
			var bottom_right : int = _inset(corner_radius(CORNER_BOTTOM_RIGHT), bottom)
			return maxi(maxi(top_right, bottom_right), cutout_margins(SIDE_RIGHT))
	return 0

func _inset(radius : int, y : int) -> int:
	return ceili(radius - sqrt(radius ** 2 - (y - radius) ** 2)) if y < radius else 0

func setup_margins(container : MarginContainer, margin_offset_left : int,
		margin_ofset_right : int = margin_offset_left) -> void:
	container.add_theme_constant_override("margin_left",
			maxi(0, calc_margins(Side.SIDE_LEFT) + margin_offset_left))
	container.add_theme_constant_override("margin_right",
			maxi(0, calc_margins(Side.SIDE_RIGHT) + margin_ofset_right))

func _get_corner_radius() -> PackedInt32Array:
	# github.com/godotengine/godot-proposals/issues/14056#issuecomment-3816832522
	var result : PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
	var android_runtime : JNISingleton = Engine.get_singleton("AndroidRuntime")
	if not android_runtime:
		return result
	var version : JavaClass = JavaClassWrapper.wrap("android.os.Build$VERSION")

	# Available only on Android 12 and later
	if version.SDK_INT < 31:
		return result

	var insets : JavaObject = android_runtime.getActivity().getWindow().getDecorView().getRootWindowInsets()
	var RoundedCorner : JavaClass = JavaClassWrapper.wrap("android.view.RoundedCorner")

	var topLeft : JavaObject = insets.getRoundedCorner(RoundedCorner.POSITION_TOP_LEFT)
	var topRight : JavaObject  = insets.getRoundedCorner(RoundedCorner.POSITION_TOP_RIGHT)
	var bottomRight : JavaObject  = insets.getRoundedCorner(RoundedCorner.POSITION_BOTTOM_RIGHT)
	var bottomLeft : JavaObject  = insets.getRoundedCorner(RoundedCorner.POSITION_BOTTOM_LEFT)

	if is_instance_valid(topLeft):
		result[Corner.CORNER_TOP_LEFT] = topLeft.getRadius()
	if is_instance_valid(topRight):
		result[Corner.CORNER_TOP_RIGHT] = topRight.getRadius()
	if is_instance_valid(bottomRight):
		result[Corner.CORNER_BOTTOM_RIGHT] = bottomRight.getRadius()
	if is_instance_valid(bottomLeft):
		result[Corner.CORNER_BOTTOM_LEFT] = bottomLeft.getRadius()
	return result

func _get_cutout_margins() -> PackedInt32Array:
	var result : PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
	var safe_area : Rect2i = DisplayServer.get_display_safe_area()
	var screen_size : Vector2i = DisplayServer.screen_get_size()
	result[SIDE_LEFT] = safe_area.position.x
	result[SIDE_TOP] = safe_area.position.y
	result[SIDE_RIGHT] = screen_size.x - safe_area.end.x
	result[SIDE_BOTTOM] = screen_size.y - safe_area.end.y
	return result

## Creates a toast message on Android.
## [param duration] set to 0 displays the message for a short period of time. 
func make_toast(message : String, duration : int = 0) -> void:
	var android_runtime : JNISingleton = Engine.get_singleton("AndroidRuntime")
	if android_runtime:
		var activity : JavaObject = android_runtime.getActivity()
		var toastCallable = func() -> void:
			var ToastClass : JavaClass = JavaClassWrapper.wrap("android.widget.Toast")
			ToastClass.makeText(activity, message, duration).show()

		activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(toastCallable))
	else:
		printerr("Unable to access android runtime")
