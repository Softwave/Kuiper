extends CodeEdit

var changed := false

var colors = {
	"keyword": to_color("#3387d8"),        # Keywords like program, if, do
	"control": to_color("#ff5555"),        # Control statements like return, stop
	"directive": to_color("#00ddff"),      # Fortran directives like use, implicit
	"type": to_color("#9e77ff"),           # Type names like integer, real, character
	"punctuation": to_color("#cccccc"),    # Symbols like commas, colons
	"function": to_color("#ffdd33"),       # Function/subroutine names
	"variable": to_color("#4af158"),       # Variable names
	"error": to_color("#ff0000"),          # Error indicators
	"number": to_color("#ff9241"),         # Numeric values
	"io": to_color("#6c47b1"),             # I/O related keywords
	"comment": to_color("#ff5555"),        # Comments
	"string": to_color("#0fd688"),         # String literals
	"operator": to_color("#cccccc"),       # Operators
	"module": to_color("#00ddff"),         # Module-related keywords
}

# Fortran language keywords and primitives
var keywords = {
	# Program structure
	"program": colors["keyword"],
	"end": colors["keyword"],
	"module": colors["module"],
	"submodule": colors["module"],
	"contains": colors["module"],
	"use": colors["module"],
	"only": colors["module"],
	"implicit": colors["directive"],
	"none": colors["directive"],
	"public": colors["directive"],
	"private": colors["directive"],
	"parameter": colors["directive"],
	"save": colors["directive"],
	"external": colors["directive"],
	"intrinsic": colors["directive"],
	
	# Procedures
	"function": colors["function"],
	"subroutine": colors["function"],
	"call": colors["function"],
	"return": colors["control"],
	"recursive": colors["directive"],
	"pure": colors["directive"],
	"elemental": colors["directive"],
	"result": colors["directive"],
	
	# Control flow
	"if": colors["keyword"],
	"then": colors["keyword"],
	"else": colors["keyword"],
	"elseif": colors["keyword"],
	"endif": colors["keyword"],
	"do": colors["keyword"],
	"enddo": colors["keyword"],
	"while": colors["keyword"],
	"cycle": colors["control"],
	"exit": colors["control"],
	"continue": colors["control"],
	"goto": colors["control"],
	"stop": colors["control"],
	"case": colors["keyword"],
	"select": colors["keyword"],
	"default": colors["keyword"],
	"pause": colors["control"],
	
	# Types
	"integer": colors["type"],
	"real": colors["type"],
	"double": colors["type"],
	"precision": colors["type"],
	"complex": colors["type"],
	"logical": colors["type"],
	"character": colors["type"],
	"type": colors["type"],
	"endtype": colors["type"],
	"dimension": colors["type"],
	"allocatable": colors["type"],
	"pointer": colors["type"],
	"target": colors["type"],
	"kind": colors["type"],
	"len": colors["type"],
	
	# I/O
	"print": colors["io"],
	"write": colors["io"],
	"read": colors["io"],
	"open": colors["io"],
	"close": colors["io"],
	"format": colors["io"],
	"unit": colors["io"],
	"iostat": colors["io"],
	"file": colors["io"],
	"status": colors["io"],
	"access": colors["io"],
	"form": colors["io"],
	"recl": colors["io"],
	"position": colors["io"],
	"action": colors["io"],
	"namelist": colors["io"],
	"backspace": colors["io"],
	"rewind": colors["io"],
	"inquire": colors["io"],
	"endfile": colors["io"],
	
	# Memory management
	"allocate": colors["keyword"],
	"deallocate": colors["keyword"],
	"nullify": colors["keyword"],
	"associated": colors["function"],
	
	# Operators and logical values
	"and": colors["operator"],
	"or": colors["operator"],
	"not": colors["operator"],
	"eqv": colors["operator"],
	"neqv": colors["operator"],
	"eq": colors["operator"],
	"ne": colors["operator"],
	"lt": colors["operator"],
	"le": colors["operator"],
	"gt": colors["operator"],
	"ge": colors["operator"],
	"true": colors["keyword"],
	"false": colors["keyword"],
	
	# Intrinsic procedures
	"abs": colors["function"],
	"sqrt": colors["function"],
	"exp": colors["function"],
	"log": colors["function"],
	"sin": colors["function"],
	"cos": colors["function"],
	"tan": colors["function"],
	"asin": colors["function"],
	"acos": colors["function"],
	"atan": colors["function"],
	"max": colors["function"],
	"min": colors["function"],
	"mod": colors["function"],
	"floor": colors["function"],
	"ceiling": colors["function"],
	"matmul": colors["function"],
	"transpose": colors["function"],
	"size": colors["function"],
	"shape": colors["function"],
	"lbound": colors["function"],
	"ubound": colors["function"],
	"present": colors["function"],
	"count": colors["function"],
	"sum": colors["function"],
	"product": colors["function"],
	"minval": colors["function"],
	"maxval": colors["function"],
	"all": colors["function"],
	"any": colors["function"],
}

var regions = [{
	"start": "'",
	"end": "'",
	"color": colors["string"],
	"inline": false
},{
	"start": "\"",
	"end": "\"",
	"color": colors["string"],
	"inline": false
},{
	"start": "!",
	"end": '',
	"color": colors["comment"],
	"inline": true
},{
	"start": "@",  # Old-style Fortran comment (column 1)
	"end": "",
	"color": colors["comment"],
	"inline": true
},{
	"start": "*",  # Another old-style Fortran comment
	"end": "",
	"color": colors["comment"],
	"inline": true
}]


func to_color(color: String) -> Color:
	return Color.from_string(color, "#ff0000");

const FUNCTION = preload("res://function.png")
const VARIABLE = preload("res://variable.png")

func code_completion():
	code_completion_enabled = true
	text_changed.connect(func():
		request_code_completion()
	)
	code_completion_requested.connect(func():
		
			
		var text_for_completion = get_text_for_code_completion()
		var completion_index = text_for_completion.find(char(0xFFFF))
		var last_space = text_for_completion.rfind(" ", completion_index)
		var word = ""
		if last_space > -1:
			word = text_for_completion.substr(last_space + 1, completion_index - last_space - 1)
			var last_newline = word.rfind("\n")
			if last_newline > -1:
				word = word.substr(last_newline + 1)
		else:
			word = text_for_completion.substr(0, completion_index)
			var last_newline = word.rfind("\n")
			if last_newline > -1:
				word = word.substr(last_newline + 1)
		word = word.strip_edges()
		
		var completions = {
			# Program structure
			"program": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "program program_name\n\timplicit none\n\t\n\t! Main code here\n\t\nend program program_name", "image": VARIABLE},
			"module": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "module module_name\n\timplicit none\n\t\n\tcontains\n\t\n\t! Module procedures here\n\t\nend module module_name", "image": VARIABLE},
			"use": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "use module_name", "image": VARIABLE},
			"implicit": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "implicit none", "image": VARIABLE},
			
			# Procedures
			"function": {"kind": CodeEdit.KIND_FUNCTION, "insert": "function func_name(arg) result(res)\n\t! Function declarations\n\t\n\t! Function code\n\t\nend function func_name", "image": FUNCTION},
			"subroutine": {"kind": CodeEdit.KIND_FUNCTION, "insert": "subroutine sub_name(arg1, arg2)\n\t! Subroutine declarations\n\t\n\t! Subroutine code\n\t\nend subroutine sub_name", "image": FUNCTION},
			"call": {"kind": CodeEdit.KIND_FUNCTION, "insert": "call subroutine_name()", "image": FUNCTION},
			
			# Control flow
			"if": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "if (condition) then\n\t\n\telse\n\t\n\tendif", "image": VARIABLE},
			"do": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "do i = 1, n\n\t\n\tenddo", "image": VARIABLE},
			"dowhile": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "do while (condition)\n\t\n\tenddo", "image": VARIABLE},
			"selectcase": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "select case (expression)\n\tcase (value1)\n\t\t\n\tcase (value2)\n\t\t\n\tcase default\n\t\t\n\tend select", "image": VARIABLE},
			
			# Types
			"integer": {"kind": CodeEdit.KIND_CLASS, "insert": "integer :: ", "image": VARIABLE},
			"real": {"kind": CodeEdit.KIND_CLASS, "insert": "real :: ", "image": VARIABLE},
			"doubleprecision": {"kind": CodeEdit.KIND_CLASS, "insert": "double precision :: ", "image": VARIABLE},
			"complex": {"kind": CodeEdit.KIND_CLASS, "insert": "complex :: ", "image": VARIABLE},
			"logical": {"kind": CodeEdit.KIND_CLASS, "insert": "logical :: ", "image": VARIABLE},
			"character": {"kind": CodeEdit.KIND_CLASS, "insert": "character(len=*) :: ", "image": VARIABLE},
			"type": {"kind": CodeEdit.KIND_CLASS, "insert": "type :: type_name\n\t! Type components here\n\tend type type_name", "image": VARIABLE},
			"allocatable": {"kind": CodeEdit.KIND_CLASS, "insert": ", allocatable", "image": VARIABLE},
			
			# I/O
			"print": {"kind": CodeEdit.KIND_FUNCTION, "insert": "print *, \"\"", "image": FUNCTION},
			"write": {"kind": CodeEdit.KIND_FUNCTION, "insert": "write(unit, *) variable", "image": FUNCTION},
			"read": {"kind": CodeEdit.KIND_FUNCTION, "insert": "read(unit, *) variable", "image": FUNCTION},
			"open": {"kind": CodeEdit.KIND_FUNCTION, "insert": "open(unit=10, file=\"filename.txt\", status=\"unknown\")", "image": FUNCTION},
			"close": {"kind": CodeEdit.KIND_FUNCTION, "insert": "close(unit=10)", "image": FUNCTION},
			
			# Common snippets
			"matrixmult": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "! Matrix multiplication\nC = matmul(A, B)", "image": VARIABLE},
			"arrayops": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "! Common array operations\nvector_sum = sum(array)\nminimum = minval(array)\nmaximum = maxval(array)", "image": VARIABLE},
		}
		
		for words in completions:
			if word.begins_with(words[0]) and word.is_subsequence_of(words): 
				if words in completions:
					add_code_completion_option(completions[words]["kind"], words, completions[words]["insert"], to_color("#dcd7ba"), completions[words]["image"])
		update_code_completion_options(false)
	)

func _ready():
	code_completion()
	var code_highlighter: CodeHighlighter = CodeHighlighter.new()
	code_highlighter.number_color = colors.number
	code_highlighter.function_color = colors.function
	code_highlighter.member_variable_color = colors.variable
	syntax_highlighter = code_highlighter
	code_highlighter.symbol_color = colors.punctuation
	
	# Add all keywords for syntax highlighting
	for keyword in keywords:
		code_highlighter.add_keyword_color(keyword, keywords[keyword])
		
	
	# Add color regions
	for region in regions:
		code_highlighter.add_color_region(region.start, region.end, region.color, region.inline)
	
	# Enable line number gutter
	gutters_draw_line_numbers = true
	gutters_draw_executing_lines = true
	line_folding = true
	
	# Set indent settings (Fortran typically uses 2-space indentation)
	indent_size = 2
	indent_automatic = true
	indent_use_spaces = true
	auto_brace_completion_enabled = false
	
	# Setting editor appearance to match the black theme
	add_theme_color_override("background_color", Color("#000000"))
	add_theme_color_override("current_line_color", Color("#141414"))
	add_theme_color_override("fold_gutter_color", Color("#4d4d4d"))
	add_theme_color_override("font_color", Color("#d4d4d4"))
	add_theme_color_override("font_selected_color", Color("#ffffff"))
	add_theme_color_override("function_color", Color("#ffdd33"))
	add_theme_color_override("line_number_color", Color("#707070"))
	add_theme_color_override("caret_color", Color("#ffffff"))
	add_theme_color_override("selection_color", Color("#264f78"))
	add_theme_color_override("brace_mismatch_color", Color("#ff0000"))
	add_theme_color_override("word_highlighted_color", Color("#3a3d41"))
	
	# Set line spacing for better readability
	add_theme_constant_override("line_spacing", 6)
	
	# Since Fortran is case-insensitive, make the editor properly handle this
	set_process_unhandled_key_input(true)
	
	
