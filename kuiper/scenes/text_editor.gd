extends Control

func _on_file_id_pressed(id):
	if id == 0: # This is the ID for "New"
		$Panel/CodeEdit.text = ""

	
	if id == 1:  # Assuming 1 is the ID for "Open"
		$FileDialog.file_mode = $FileDialog.FILE_MODE_OPEN_FILE 
		$FileDialog.popup_centered()

	if id == 2: # Save file
		$FileDialog.file_mode = $FileDialog.FILE_MODE_SAVE_FILE
		var path = $FileDialog.current_path
		if path == "":
			$FileDialog.popup_centered()
		else:
			_save_file(path)

	if id == 3: # Save As
		$FileDialog.file_mode = $FileDialog.FILE_MODE_SAVE_FILE
		# Clear the current path
		$FileDialog.current_path = ""
		$FileDialog.popup_centered()
		

	if id == 4: # Quit Program
		get_tree().quit()


func _save_file(path):
	var file = FileAccess.open(path, FileAccess.WRITE)	
	file.open(path, FileAccess.WRITE)
	file.store_string($Panel/CodeEdit.text)
	file.close()
	
func _load_file(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		$Panel/CodeEdit.text = text

func _on_file_dialog_file_selected(path):
	print("Selected file path: ", path)  # Debugging print statement
	if $FileDialog.file_mode == $FileDialog.FILE_MODE_OPEN_FILE:
		_load_file(path)
	elif $FileDialog.file_mode == $FileDialog.FILE_MODE_SAVE_FILE:
		_save_file(path)
	var text = _get_file_as_text(path)
	print("File content: ", text)  # Debugging print statement
	$Panel/CodeEdit.text = text

# Function to read file content as text
func _get_file_as_text(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		return text
	return ""


func _on_help_id_pressed(id):
	if id == 0: # About
		$AcceptDialog.popup_centered()


func _on_edit_id_pressed(id):
	if id == 1: # Copy
		$Panel/CodeEdit.copy()
	elif id == 2: # Paste
		$Panel/CodeEdit.paste()
	elif id == 3: # Cut
		$Panel/CodeEdit.cut()
