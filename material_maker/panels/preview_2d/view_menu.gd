extends PanelContainer

const GUIDES_GRID := 3

func _open() -> void:
	%ViewMode.selected = owner.view_mode
	%PostProcessing.selected = owner.view_filter

	%Guides.selected = owner.get_node("Guides").style
	%CustomGridSize.visible = %Guides.selected == GUIDES_GRID
	%CustomGridSize.value = owner.get_node("Guides").grid_size
	#%CustomGridSizeLabel.visible = %Guides.selected == GUIDES_GRID

	%GuidesColor.color = owner.get_node("Guides").color
	
	%CheckerSize.selected = owner.checker_size
	%CheckerBrightness.selected = owner.checker_brightness

	size = Vector2()


func _on_view_mode_item_selected(index: int) -> void:
	owner.view_mode = index


func _on_post_processing_item_selected(index: int) -> void:
	owner.view_filter = index


func _on_guides_item_selected(index: int) -> void:
	%CustomGridSize.visible = index == GUIDES_GRID
	if index == GUIDES_GRID:
		%CustomGridSize.value = owner.get_node("Guides").grid_size
	owner.get_node("Guides").style = index
	size = Vector2()

func _on_guides_color_color_changed(color: Color) -> void:
	owner.get_node("Guides").color = color

func _on_custom_grid_size_value_changed(value: Variant) -> void:
	owner.get_node("Guides").grid_size = value


func _on_checker_size_item_selected(index: int) -> void:
	owner.checker_size = index


func _on_checker_brightness_item_selected(index: int) -> void:
	owner.checker_brightness = index

func _on_overlay_opacity_value_changed(value : Variant) -> void:
	%OverlayImage.modulate.a = clamp(value, 0.0,1.0)

func _on_overlay_offset_x_value_changed(value : Variant) -> void:
	%OverlayImage.offset.x = value
	%OverlayImage.queue_redraw()

func _on_overlay_offset_y_value_changed(value : Variant) -> void:
	%OverlayImage.offset.y = value
	%OverlayImage.queue_redraw()

func _on_overlay_scale_value_changed(value : Variant) -> void:
	%OverlayImage.image_scale = max(1e-5, value)
	%OverlayImage.queue_redraw()

func _on_overlay_load_pressed() -> void:
	if %OverlayImage.texture:
		%OverlayImage.texture = null
		%OverlayLoadUnload.text = "Load Image"
		%OverlayImage.queue_redraw()
		return
	var dialog : FileDialog = preload("res://material_maker/windows/file_dialog/file_dialog.tscn").instantiate()
	dialog.min_size = Vector2(500, 500)
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	mm_globals.add_image_file_filters(dialog)
	var files = await dialog.select_files()
	if files.size() == 1:
		%OverlayLoadUnload.text = "Unload Image"
		%OverlayImage.texture = ImageTexture.create_from_image(Image.load_from_file(files[0]))
	%OverlayImage.queue_redraw()
