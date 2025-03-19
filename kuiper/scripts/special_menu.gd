extends PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_submenu_node_item("Language", $LangSubmenu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_lang_submenu_id_pressed(id: int) -> void:
	if id == 0:
		var new_script = load("res://scripts/code_edit_c.gd")
		$"../../../../CodeEdit".language = "C"
		$"../../../../CodeEdit".set_script(new_script)
		$"../../../../CodeEdit"._ready()
	if id == 1: 
		var new_script = load("res://scripts/code_edit_6502.gd")
		$"../../../../CodeEdit".language = "6502"
		$"../../../../CodeEdit".set_script(new_script)
		$"../../../../CodeEdit"._ready()
	if id == 2:
		var new_script = load("res://scripts/code_edit_fortran.gd")
		$"../../../../CodeEdit".language = "Fortran"
		$"../../../../CodeEdit".set_script(new_script)
		$"../../../../CodeEdit"._ready()
	if id == 3:
		var new_script = load("res://scripts/code_edit_glsl.gd")
		$"../../../../CodeEdit".language = "GLSL"
		$"../../../../CodeEdit".set_script(new_script)
		$"../../../../CodeEdit"._ready()
