extends CodeEdit

var last_search_pos_x: int = 0
var last_search_pos_y: int = 0

var changed := false

var colors = {
	"keyword": to_color("#3387d8"),        # Keywords like if, for, while
	"control": to_color("#ff5555"),        # Control statements like return, break
	"preprocessor": to_color("#00ddff"),   # Preprocessor directives like #version
	"type": to_color("#9e77ff"),           # Type names like vec4, mat4, sampler2D
	"punctuation": to_color("#cccccc"),    # Symbols like commas, semicolons
	"function": to_color("#3387d8"),       # Function names
	"variable": to_color("#4af158"),       # Variable names
	"error": to_color("#ff0000"),          # Error indicators
	"number": to_color("#ff9241"),         # Numeric values
	"qualifier": to_color("#6c47b1"),      # Qualifiers like uniform, varying
	"comment": to_color("#ff5555"),        # Comments
	"string": to_color("#0fd688"),         # String literals
	"builtin": to_color("#ffdd33"),        # Built-in GLSL functions
	"operator": to_color("#cccccc"),       # Operators
}

# GLSL language keywords and primitives
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
	"continue": colors["control"],
	"break": colors["control"],
	"return": colors["control"],
	"discard": colors["control"],
	
	# Type keywords
	"void": colors["type"],
	"bool": colors["type"],
	"int": colors["type"],
	"uint": colors["type"],
	"float": colors["type"],
	"double": colors["type"],
	"vec2": colors["type"],
	"vec3": colors["type"],
	"vec4": colors["type"],
	"dvec2": colors["type"],
	"dvec3": colors["type"],
	"dvec4": colors["type"],
	"bvec2": colors["type"],
	"bvec3": colors["type"],
	"bvec4": colors["type"],
	"ivec2": colors["type"],
	"ivec3": colors["type"],
	"ivec4": colors["type"],
	"uvec2": colors["type"],
	"uvec3": colors["type"],
	"uvec4": colors["type"],
	"mat2": colors["type"],
	"mat3": colors["type"],
	"mat4": colors["type"],
	"mat2x2": colors["type"],
	"mat2x3": colors["type"],
	"mat2x4": colors["type"],
	"mat3x2": colors["type"],
	"mat3x3": colors["type"],
	"mat3x4": colors["type"],
	"mat4x2": colors["type"],
	"mat4x3": colors["type"],
	"mat4x4": colors["type"],
	"sampler1D": colors["type"],
	"sampler2D": colors["type"],
	"sampler3D": colors["type"],
	"samplerCube": colors["type"],
	"sampler2DShadow": colors["type"],
	"samplerCubeShadow": colors["type"],
	"sampler1DArray": colors["type"],
	"sampler2DArray": colors["type"],
	"sampler1DArrayShadow": colors["type"],
	"sampler2DArrayShadow": colors["type"],
	"isampler1D": colors["type"],
	"isampler2D": colors["type"],
	"isampler3D": colors["type"],
	"isamplerCube": colors["type"],
	"usampler1D": colors["type"],
	"usampler2D": colors["type"],
	"usampler3D": colors["type"],
	"usamplerCube": colors["type"],
	
	# Qualifiers
	"attribute": colors["qualifier"],
	"const": colors["qualifier"],
	"uniform": colors["qualifier"],
	"varying": colors["qualifier"],
	"buffer": colors["qualifier"],
	"shared": colors["qualifier"],
	"coherent": colors["qualifier"],
	"volatile": colors["qualifier"],
	"restrict": colors["qualifier"],
	"readonly": colors["qualifier"],
	"writeonly": colors["qualifier"],
	"layout": colors["qualifier"],
	"centroid": colors["qualifier"],
	"flat": colors["qualifier"],
	"smooth": colors["qualifier"],
	"noperspective": colors["qualifier"],
	"patch": colors["qualifier"],
	"sample": colors["qualifier"],
	"in": colors["qualifier"],
	"out": colors["qualifier"],
	"inout": colors["qualifier"],
	"invariant": colors["qualifier"],
	"precise": colors["qualifier"],
	"highp": colors["qualifier"],
	"mediump": colors["qualifier"],
	"lowp": colors["qualifier"],
	
	# Preprocessor
	"#version": colors["preprocessor"],
	"#extension": colors["preprocessor"],
	"#define": colors["preprocessor"],
	"#undef": colors["preprocessor"],
	"#if": colors["preprocessor"],
	"#ifdef": colors["preprocessor"],
	"#ifndef": colors["preprocessor"],
	"#else": colors["preprocessor"],
	"#elif": colors["preprocessor"],
	"#endif": colors["preprocessor"],
	"#error": colors["preprocessor"],
	"#pragma": colors["preprocessor"],
	"#line": colors["preprocessor"],
	
	# Built-in variables
	"gl_Position": colors["builtin"],
	"gl_PointSize": colors["builtin"],
	"gl_ClipDistance": colors["builtin"],
	"gl_FragCoord": colors["builtin"],
	"gl_FrontFacing": colors["builtin"],
	"gl_FragDepth": colors["builtin"],
	"gl_PointCoord": colors["builtin"],
	"gl_VertexID": colors["builtin"],
	"gl_InstanceID": colors["builtin"],
	"gl_PrimitiveID": colors["builtin"],
	"gl_Layer": colors["builtin"],
	"gl_ViewportIndex": colors["builtin"],
	
	# Common GLSL functions
	"radians": colors["function"],
	"degrees": colors["function"],
	"sin": colors["function"],
	"cos": colors["function"],
	"tan": colors["function"],
	"asin": colors["function"],
	"acos": colors["function"],
	"atan": colors["function"],
	"pow": colors["function"],
	"exp": colors["function"],
	"log": colors["function"],
	"exp2": colors["function"],
	"log2": colors["function"],
	"sqrt": colors["function"],
	"inversesqrt": colors["function"],
	"abs": colors["function"],
	"sign": colors["function"],
	"floor": colors["function"],
	"ceil": colors["function"],
	"fract": colors["function"],
	"mod": colors["function"],
	"min": colors["function"],
	"max": colors["function"],
	"clamp": colors["function"],
	"mix": colors["function"],
	"step": colors["function"],
	"smoothstep": colors["function"],
	"length": colors["function"],
	"distance": colors["function"],
	"dot": colors["function"],
	"cross": colors["function"],
	"normalize": colors["function"],
	"reflect": colors["function"],
	"refract": colors["function"],
	"texture": colors["function"],
	"texture2D": colors["function"],
	"texture3D": colors["function"],
	"textureCube": colors["function"],
	"dFdx": colors["function"],
	"dFdy": colors["function"],
	"fwidth": colors["function"],
	
	# Constants
	"true": colors["qualifier"],
	"false": colors["qualifier"],
}

var regions = [{
	"start": '"',
	"end": '"',
	"color": to_color("#0fd688"),
	"inline": false
},{
	"start": "'",
	"end": "'",
	"color": to_color("#0fd688"),
	"inline": false
},
{
	"start": "/*",
	"end": "*/",
	"color": colors["comment"],
	"inline": false
},{
	"start": '//',
	"end": '',
	"color": colors["comment"],
	"inline": true
},{
	"start": ';',
	"end": '',
	"color": colors["comment"],
	"inline": true
},{
	"start": '$',
	"end": ' ',
	"color": colors["number"],
	"inline": true
},{
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
			
			# Type declarations
			"vec2": {"kind": CodeEdit.KIND_CLASS, "insert": "vec2", "image": VARIABLE},
			"vec3": {"kind": CodeEdit.KIND_CLASS, "insert": "vec3", "image": VARIABLE},
			"vec4": {"kind": CodeEdit.KIND_CLASS, "insert": "vec4", "image": VARIABLE},
			"mat2": {"kind": CodeEdit.KIND_CLASS, "insert": "mat2", "image": VARIABLE},
			"mat3": {"kind": CodeEdit.KIND_CLASS, "insert": "mat3", "image": VARIABLE},
			"mat4": {"kind": CodeEdit.KIND_CLASS, "insert": "mat4", "image": VARIABLE},
			"sampler2D": {"kind": CodeEdit.KIND_CLASS, "insert": "sampler2D", "image": VARIABLE},
			"float": {"kind": CodeEdit.KIND_CLASS, "insert": "float", "image": VARIABLE},
			"int": {"kind": CodeEdit.KIND_CLASS, "insert": "int", "image": VARIABLE},
			"bool": {"kind": CodeEdit.KIND_CLASS, "insert": "bool", "image": VARIABLE},
			
			# Qualifiers
			"uniform": {"kind": CodeEdit.KIND_MEMBER, "insert": "uniform ", "image": VARIABLE},
			"varying": {"kind": CodeEdit.KIND_MEMBER, "insert": "varying ", "image": VARIABLE},
			"attribute": {"kind": CodeEdit.KIND_MEMBER, "insert": "attribute ", "image": VARIABLE},
			"in": {"kind": CodeEdit.KIND_MEMBER, "insert": "in ", "image": VARIABLE},
			"out": {"kind": CodeEdit.KIND_MEMBER, "insert": "out ", "image": VARIABLE},
			"inout": {"kind": CodeEdit.KIND_MEMBER, "insert": "inout ", "image": VARIABLE},
			
			# Preprocessor
			"version": {"kind": CodeEdit.KIND_MEMBER, "insert": "#version 330 core", "image": VARIABLE},
			"define": {"kind": CodeEdit.KIND_MEMBER, "insert": "#define ", "image": VARIABLE},
			"ifdef": {"kind": CodeEdit.KIND_MEMBER, "insert": "#ifdef SYMBOL\n\n#endif", "image": VARIABLE},
			
			# Common functions
			"main": {"kind": CodeEdit.KIND_FUNCTION, "insert": "void main() {\n\t\n}", "image": FUNCTION},
			"texture": {"kind": CodeEdit.KIND_FUNCTION, "insert": "texture(sampler, texCoord)", "image": FUNCTION},
			"normalize": {"kind": CodeEdit.KIND_FUNCTION, "insert": "normalize(vector)", "image": FUNCTION},
			"mix": {"kind": CodeEdit.KIND_FUNCTION, "insert": "mix(x, y, a)", "image": FUNCTION},
			"clamp": {"kind": CodeEdit.KIND_FUNCTION, "insert": "clamp(x, minVal, maxVal)", "image": FUNCTION},
			"dot": {"kind": CodeEdit.KIND_FUNCTION, "insert": "dot(x, y)", "image": FUNCTION},
			"cross": {"kind": CodeEdit.KIND_FUNCTION, "insert": "cross(x, y)", "image": FUNCTION},
			"length": {"kind": CodeEdit.KIND_FUNCTION, "insert": "length(x)", "image": FUNCTION},
			
			# Common GLSL snippets
			"vertexShader": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "#version 330 core\n\nlayout (location = 0) in vec3 aPos;\nlayout (location = 1) in vec2 aTexCoord;\n\nout vec2 texCoord;\nuniform mat4 model;\nuniform mat4 view;\nuniform mat4 projection;\n\nvoid main() {\n\tgl_Position = projection * view * model * vec4(aPos, 1.0);\n\ttexCoord = aTexCoord;\n}", "image": VARIABLE},
			"fragmentShader": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "#version 330 core\n\nout vec4 FragColor;\nin vec2 texCoord;\n\nuniform sampler2D texture1;\n\nvoid main() {\n\tFragColor = texture(texture1, texCoord);\n}", "image": VARIABLE},
			"lightCalc": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "// Calculate diffuse lighting\nvec3 norm = normalize(Normal);\nvec3 lightDir = normalize(lightPos - FragPos);\nfloat diff = max(dot(norm, lightDir), 0.0);\nvec3 diffuse = diff * lightColor;", "image": VARIABLE},
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


	# Add color regions that work
	# code_highlighter.add_color_region("/*", "*/", colors["comment"], false)
	
	# Connect to text_changed to handle preprocessor directives
	text_changed.connect(func():
		_highlight_preprocessor_directives()
	)


	
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
	
	# SpaceWorm theme 
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

func _highlight_preprocessor_directives():
	var line_count = get_line_count()
	
	for i in range(line_count):
		var line = get_line(i)
		if line.strip_edges().begins_with("#"):
			# Apply custom background for preprocessor lines
			set_line_background_color(i, Color("#111111"))
		else:
			# Clear background for non-preprocessor lines
			set_line_background_color(i, Color(0, 0, 0, 0))
