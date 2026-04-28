class_name FontManager
extends RefCounted

static var main_font : FontVariation = preload("res://material_maker/theme/fonts/ui/main_font.tres")
static var medium_font : FontVariation = preload("res://material_maker/theme/fonts/ui/medium_font.tres")
static var bold_font : FontVariation = preload("res://material_maker/theme/fonts/ui/bold_font.tres")
static var code_font : FontVariation = preload("res://material_maker/theme/fonts/ui/code_font.tres")

static var classic_font : FontVariation = preload("res://material_maker/theme/fonts/ui/classic_font.tres")

static var ui_font_size : int
static var ui_code_font_size : int

static func has_font_config(config : String) -> bool:
	return (mm_globals.has_config(config)
			and not mm_globals.get_config(config).is_empty())

static func rebuild_fonts() -> void:
	if mm_globals.has_config("ui_font_size"):
		ui_font_size = mm_globals.get_config("ui_font_size")

	if mm_globals.has_config("ui_code_font_size"):
		ui_code_font_size = mm_globals.get_config("ui_code_font_size")

	if mm_globals.get_config("ui_use_system_font"):
		main_font = preload("res://material_maker/theme/fonts/system/system_main_font.tres")
		medium_font = preload("res://material_maker/theme/fonts/system/system_medium_font.tres")
		bold_font = preload("res://material_maker/theme/fonts/system/system_bold_font.tres")
		code_font = preload("res://material_maker/theme/fonts/system/system_code_font.tres")
		return
	
	var fonts : Dictionary[String, FontVariation] = {
		"main_font": main_font,
		"medium_font": medium_font,
		"bold_font": bold_font,
		"code_font": code_font
	}

	for font : String in fonts:
		var font_variation : FontVariation = fonts[font]
		font_variation.base_font = FontFile.new()
		if has_font_config(font):
			font_variation.base_font.load_dynamic_font(mm_globals.get_config(font))
			font_variation.base_font.msdf_pixel_range = 32
			font_variation.base_font.msdf_size = 48
			font_variation.base_font.multichannel_signed_distance_field = true
