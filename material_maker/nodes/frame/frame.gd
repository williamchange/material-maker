extends GraphFrame
class_name MMGraphFrame

var disable_undoredo_for_offset : bool = false
var title_edit : LineEdit
var title_label : Label

var generator : MMGenFrame:
	set(g):
		generator = g
		size = generator.size
		title = generator.title
		tint_color = generator.color
		position_offset = generator.position
		%TextEdit.text = generator.text
		resizable = true
		resize_to_selection()
		await get_tree().process_frame
		autoshrink_enabled = true
		autoshrink_enabled = false


func resize_to_selection() -> void:
	autoshrink_enabled = true
	var graph : MMGraphEdit = get_parent()
	if graph:
		var selected_nodes : Array = graph.get_selected_nodes()
		if selected_nodes.is_empty():
			return
		for node in selected_nodes:
			graph.attach_graph_element_to_frame(node.name, name)
	autoshrink_enabled = false

func _ready() -> void:
	title_label = get_titlebar_hbox().get_child(0)

	title_edit = LineEdit.new()
	title_edit.hide()
	title_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_edit.text_submitted.connect(title_edit_text_submitted)
	title_edit.focus_exited.connect(on_title_edit_focus_exited)
	title_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_override("font",
			preload("res://material_maker/theme/font_rubik/Rubik-416.ttf"))
	
	get_titlebar_hbox().add_child(title_edit)

func title_edit_text_submitted(new_text : String) -> void:
	title_label.text = new_text
	title_label.show()
	title_edit.hide()

func on_title_edit_focus_exited():
	title = title_edit.text
	generator.title = title_edit.text
	title_label.show()
	title_edit.hide()

func set_color(c: Color) -> void:
	if c == generator.color:
		return
	var undo_action = { type="frame_color_change", node=generator.get_hier_name(), color=generator.color }
	var redo_action = { type="frame_color_change", node=generator.get_hier_name(), color=c }
	get_parent().undoredo.add("Change frame color", [undo_action], [redo_action], true)
	tint_color = c
	generator.color = c
	get_parent().send_changed_signal()

func update_node() -> void:
	size = generator.size
	tint_color = generator.color

func do_set_position(o: Vector2) -> void:
	disable_undoredo_for_offset = true
	position_offset = o
	generator.position = o
	disable_undoredo_for_offset = false

func get_output_port_count() -> int:
	return 0

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
		if title_label.get_rect().has_point(get_local_mouse_position()):
			title_label.hide()
			title_edit.show()
			title_edit.text = title_label.text
			title_edit.select_all()
			title_edit.grab_focus()
			accept_event()
		elif %TextEdit.get_rect().has_point(get_local_mouse_position()):
			%TextEdit.editable = true
			%TextEdit.text = generator.text
			%TextEdit.mouse_filter = MOUSE_FILTER_STOP
			%TextEdit.mouse_default_cursor_shape = CURSOR_IBEAM
			%TextEdit.focus_mode = FOCUS_ALL
			%TextEdit.selecting_enabled = true
			%TextEdit.grab_focus()
			%TextEdit.select_all()
			accept_event()
	elif event is InputEventMouseButton:
		if event.shift_pressed and event.button_index == MOUSE_BUTTON_LEFT:
			autoshrink_enabled = true
			autoshrink_enabled = false
			accept_event()

func _on_node_selected() -> void:
	%TextEdit.placeholder_text = tr("Double click to enter something...")

func _on_node_deselected() -> void:
	%TextEdit.placeholder_text = ""


func _on_text_edit_focus_exited() -> void:
	generator.text = %TextEdit.text
	%TextEdit.editable = false
	%TextEdit.focus_mode = FOCUS_NONE
	%TextEdit.selecting_enabled = false
	%TextEdit.mouse_filter = MOUSE_FILTER_IGNORE
	%TextEdit.mouse_default_cursor_shape = CURSOR_ARROW
