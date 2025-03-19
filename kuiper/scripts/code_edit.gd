
extends CodeEdit

var changed := false

var colors = {
	"keyword": to_color("#3387d8"),        # Keywords like if, for, while
	"control": to_color("#ff5555"),        # Control statements like return, break
	"preprocessor": to_color("#00ddff"),   # Preprocessor directives like #include
	"type": to_color("#9e77ff"),           # Type names like int, char, struct
	"punctuation": to_color("#cccccc"),    # Symbols like commas, semicolons
	"function": to_color("#3387d8"),       # Function names
	"variable": to_color("#4af158"),       # Variable names
	"error": to_color("#ff0000"),          # Error indicators
	"number": to_color("#ff9241"),         # Numeric values
	"macros": to_color("#6c47b1"),         # Macro definitions
	"comment": to_color("#ff5555"),        # Comments
	"string": to_color("#0fd688"),         # String literals
	"char": to_color("#0fd688"),           # Character literals
}

# C language keywords and primitives
var keywords = {
	# Control flow keywords
	"if": colors["keyword"],
	"else": colors["keyword"],
	"switch": colors["keyword"],
	"case": colors["keyword"],
	"default": colors["keyword"],
	"for": colors["keyword"],
	"while": colors["keyword"],
	"do": colors["keyword"],
	"goto": colors["keyword"],
	"continue": colors["control"],
	"break": colors["control"],
	"return": colors["control"],
	
	# Type keywords
	"int": colors["type"],
	"char": colors["type"],
	"float": colors["type"],
	"double": colors["type"],
	"void": colors["type"],
	"long": colors["type"],
	"short": colors["type"],
	"signed": colors["type"],
	"unsigned": colors["type"],
	"size_t": colors["type"],
	"bool": colors["type"],
	"struct": colors["type"],
	"union": colors["type"],
	"enum": colors["type"],
	"typedef": colors["type"],
	"const": colors["type"],
	"static": colors["type"],
	"extern": colors["type"],
	"volatile": colors["type"],
	"register": colors["type"],
	"auto": colors["type"],
	
	# Preprocessor
	"#include": colors["preprocessor"],
	"#define": colors["preprocessor"],
	"#ifdef": colors["preprocessor"],
	"#ifndef": colors["preprocessor"],
	"#endif": colors["preprocessor"],
	"#if": colors["preprocessor"],
	"#else": colors["preprocessor"],
	"#elif": colors["preprocessor"],
	"#pragma": colors["preprocessor"],
	"#undef": colors["preprocessor"],
	
	# Common library functions
	"printf": colors["function"],
	"scanf": colors["function"],
	"malloc": colors["function"],
	"free": colors["function"],
	"calloc": colors["function"],
	"realloc": colors["function"],
	"memcpy": colors["function"],
	"memset": colors["function"],
	"strcpy": colors["function"],
	"strcat": colors["function"],
	"strlen": colors["function"],
	"strcmp": colors["function"],
	"fopen": colors["function"],
	"fclose": colors["function"],
	"fread": colors["function"],
	"fwrite": colors["function"],
	"fprintf": colors["function"],
	"fscanf": colors["function"],
	"exit": colors["function"],
	
	# Common standard library macros/constants
	"NULL": colors["macros"],
	"EOF": colors["macros"],
	"FILE": colors["type"],
	"true": colors["macros"],
	"false": colors["macros"],
	"BUFSIZ": colors["macros"],
	"FILENAME_MAX": colors["macros"],
	"__LINE__": colors["macros"],
	"__FILE__": colors["macros"],
	"__DATE__": colors["macros"],
	"__TIME__": colors["macros"],
	"__func__": colors["macros"],
}

var regions = [{
	"start": '"',
	"end": '"',
	"color": colors["string"],
	"inline": false
},{
	"start": "'",
	"end": "'",
	"color": colors["char"],
	"inline": false
},{
	"start": "//",
	"end": '',
	"color": colors["comment"],
	"inline": true
},{
	"start": "/*",
	"end": "*/",
	"color": colors["comment"],
	"inline": false
},{
	"start": "#",
	"end": "\n",
	"color": colors["preprocessor"],
	"inline": true
},{
	"start": "0x",
	"end": " ",
	"color": colors["number"],
	"inline": true
},
{
	"start": "<",
	"end": ">",
	"color": colors["type"],
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
			# Control structures
			"if": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "if (condition) {\n\t\n}", "image": VARIABLE},
			"else": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "else {\n\t\n}", "image": VARIABLE},
			"for": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "for (int i = 0; i < n; i++) {\n\t\n}", "image": VARIABLE},
			"while": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "while (condition) {\n\t\n}", "image": VARIABLE},
			"switch": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "switch (expression) {\n\tcase value:\n\t\t\n\t\tbreak;\n\tdefault:\n\t\t\n\t\tbreak;\n}", "image": VARIABLE},
			"do": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "do {\n\t\n} while (condition);", "image": VARIABLE},
			
			# Type declarations
			"int": {"kind": CodeEdit.KIND_CLASS, "insert": "int ", "image": VARIABLE},
			"char": {"kind": CodeEdit.KIND_CLASS, "insert": "char ", "image": VARIABLE},
			"float": {"kind": CodeEdit.KIND_CLASS, "insert": "float ", "image": VARIABLE},
			"double": {"kind": CodeEdit.KIND_CLASS, "insert": "double ", "image": VARIABLE},
			"void": {"kind": CodeEdit.KIND_CLASS, "insert": "void ", "image": VARIABLE},
			"struct": {"kind": CodeEdit.KIND_CLASS, "insert": "struct Name {\n\t\n};", "image": VARIABLE},
			"typedef": {"kind": CodeEdit.KIND_CLASS, "insert": "typedef ", "image": VARIABLE},
			
			# Preprocessor directives
			"include": {"kind": CodeEdit.KIND_MEMBER, "insert": "#include <stdio.h>", "image": VARIABLE},
			"define": {"kind": CodeEdit.KIND_MEMBER, "insert": "#define ", "image": VARIABLE},
			"ifdef": {"kind": CodeEdit.KIND_MEMBER, "insert": "#ifdef SYMBOL\n\n#endif", "image": VARIABLE},
			
			# Common functions
			"main": {"kind": CodeEdit.KIND_FUNCTION, "insert": "int main(int argc, char *argv[]) {\n\t\n\treturn 0;\n}", "image": FUNCTION},
			"printf": {"kind": CodeEdit.KIND_FUNCTION, "insert": "printf(\"%d\\n\", value);", "image": FUNCTION},
			"scanf": {"kind": CodeEdit.KIND_FUNCTION, "insert": "scanf(\"%d\", &value);", "image": FUNCTION},
			"malloc": {"kind": CodeEdit.KIND_FUNCTION, "insert": "malloc(sizeof(type) * size)", "image": FUNCTION},
			"free": {"kind": CodeEdit.KIND_FUNCTION, "insert": "free(pointer);", "image": FUNCTION},
			"strlen": {"kind": CodeEdit.KIND_FUNCTION, "insert": "strlen(string)", "image": FUNCTION},
			"strcpy": {"kind": CodeEdit.KIND_FUNCTION, "insert": "strcpy(dest, src);", "image": FUNCTION},
			"strcmp": {"kind": CodeEdit.KIND_FUNCTION, "insert": "strcmp(str1, str2)", "image": FUNCTION},
			"fopen": {"kind": CodeEdit.KIND_FUNCTION, "insert": "fopen(\"filename.txt\", \"r\")", "image": FUNCTION},
			"fclose": {"kind": CodeEdit.KIND_FUNCTION, "insert": "fclose(file);", "image": FUNCTION},
			
			# Common snippets
			"header": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "#ifndef HEADER_H\n#define HEADER_H\n\n// declarations here\n\n#endif /* HEADER_H */", "image": VARIABLE},
			"forloop": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "for (int i = 0; i < n; i++) {\n\t\n}", "image": VARIABLE},
			"func": {"kind": CodeEdit.KIND_FUNCTION, "insert": "void function_name(int param) {\n\t\n}", "image": FUNCTION},
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
	
	# Set indent settings
	indent_size = 4
	indent_automatic = true
	indent_use_spaces = true
	auto_brace_completion_enabled = true
	auto_brace_completion_highlight_matching = true
	
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
