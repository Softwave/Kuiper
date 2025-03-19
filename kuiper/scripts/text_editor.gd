extends Control

# The editor config file
var config_file:ConfigFile = ConfigFile.new()
var config_path:String = "user://editor.cfg"
# Settings
var current_lang:String
var crt_setting:bool = true 
var search_setting:bool = false


var last_caret_pos_x:int = 0
var last_caret_pos_y:int = 0

func _ready():
	# Connect the file_selected signal to the method
	$FileDialog.connect("file_selected", Callable(self, "_on_file_dialog_file_selected"))
	set("emoji_menu_enabled", true)

	# Load the config file
	if config_file.load(config_path) == OK:
		if config_file.has_section_key("settings", "lang"):
			print(config_file.get_value("settings", "lang"))
			current_lang = config_file.get_value("settings", "lang")
		else:
			current_lang = "C"  # Default only if not in config
		if config_file.has_section_key("settings", "crt"):
			crt_setting = config_file.get_value("settings", "crt")
		if config_file.has_section_key("settings", "search"):
			search_setting = config_file.get_value("settings", "search")
	else:
		current_lang = "C"  # Default if config file doesn't exist
	
	# Apply the settings
	$Panel/CodeEdit.language = current_lang
	$Panel/ColorRect.visible = crt_setting
	match current_lang:
		"C":
			$Panel/CodeEdit.set_script(load("res://scripts/code_edit_c.gd"))
		"6502":
			$Panel/CodeEdit.set_script(load("res://scripts/code_edit_6502.gd"))
		"Fortran":
			$Panel/CodeEdit.set_script(load("res://scripts/code_edit_fortran.gd"))
		"GLSL":
			$Panel/CodeEdit.set_script(load("res://scripts/code_edit_glsl.gd"))
		_:
			$Panel/CodeEdit.set_script(load("res://scripts/code_edit_c.gd"))
	
	$Panel/CodeEdit._ready()
	# Show the search bar if it was visible before
	$Panel/MainMenu/MarginContainer/MenuBar/LineEdit.visible = search_setting
	$Panel/MainMenu/MarginContainer/MenuBar/ButtonSearch.visible = search_setting
	

func _process(delta):
	$Panel/MainMenu/MarginContainer2/Clock.text = Time.get_time_string_from_system(false)

func _on_file_id_pressed(id):
	if id == 0:  # New
		$Panel/CodeEdit.text = ""
		$FileDialog.current_path = ""

	if id == 1:  # Assuming 1 is the ID for "Open"
		$FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		$FileDialog.popup_centered()

	if id == 2:  # Save
		var path = $FileDialog.current_path
		if path == "":
			$FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			$FileDialog.popup_centered()
		else:
			_save_file(path)

	if id == 3:  # Save As
		$FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		$FileDialog.current_path = ""
		$FileDialog.popup_centered()

	if id == 4:  # Quit Program
		get_tree().quit()

func _save_file(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string($Panel/CodeEdit.text)
		file.close()

func _load_file(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		$Panel/CodeEdit.text = text

func _on_file_dialog_file_selected(path):
	if $FileDialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		_load_file(path)
	elif $FileDialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		_save_file(path)

func _on_edit_id_pressed(id:int):
	if id == 0:  # Cut
		$Panel/CodeEdit.cut()
	
	if id == 1:  # Copy
		$Panel/CodeEdit.copy()

	if id == 2:  # Paste
		$Panel/CodeEdit.paste()
	
	if id == 4: # Undo
		$Panel/CodeEdit.undo()

	if id == 5: # Redo
		$Panel/CodeEdit.redo()

func _on_special_id_pressed(id:int):
	if id == 0: # item 1
		$Panel/ColorRect.visible = !$Panel/ColorRect.visible 
	if id == 1:
		# Save the settings
		config_file.set_value("settings", "lang", $Panel/CodeEdit.language)
		config_file.set_value("settings", "crt", $Panel/ColorRect.visible)
		config_file.set_value("settings", "search", $Panel/MainMenu/MarginContainer/MenuBar/LineEdit.visible)
		config_file.save(config_path)
		# Reload the settings
	if id == 2:
		# Toggle showing search bar and button
		$Panel/MainMenu/MarginContainer/MenuBar/LineEdit.visible = !$Panel/MainMenu/MarginContainer/MenuBar/LineEdit.visible
		$Panel/MainMenu/MarginContainer/MenuBar/ButtonSearch.visible = !$Panel/MainMenu/MarginContainer/MenuBar/ButtonSearch.visible
		

func _on_help_id_pressed(id:int):
	if id == 0:
		$AboutWindow.visible = true 
	

func _on_quit_about_button_pressed() -> void:
	$AboutWindow.visible = false 


func _on_about_window_close_requested() -> void:
	$AboutWindow.visible = false


func _on_code_edit_caret_changed() -> void:
	var cEdit:CodeEdit = $Panel/CodeEdit
	last_caret_pos_x = cEdit.get_caret_column()
	last_caret_pos_y = cEdit.get_caret_line()
	#print("Line: %d, Column: %d" % [last_caret_pos_y, last_caret_pos_x])


# Search function :)
func _on_button_search_pressed() -> void:
	var lEdit = get_node("Panel/MainMenu/MarginContainer/MenuBar/LineEdit")
	var cEdit:CodeEdit = get_node("Panel/CodeEdit")
	var search_text = lEdit.text 
	if search_text == "":
		return
	
	# First search from the current caret pos
	var result = cEdit.search(search_text, 0, last_caret_pos_y, last_caret_pos_x)
	
	# Wrap around if we don't find anything
	if result.x == -1:
		result = cEdit.search(search_text, 0, 0, 0)
	
	if result.x != -1:
		# Select the text we've found
		cEdit.select(result.y, result.x, result.y, result.x + search_text.length())
		# Reset caret for next search
		last_caret_pos_x = result.x + search_text.length()
		last_caret_pos_y = result.y
	else:
		# We found nothing in our search
		print("Text not found: ", search_text)
