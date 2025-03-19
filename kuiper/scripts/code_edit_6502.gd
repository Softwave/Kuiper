extends CodeEdit

var changed := false

var colors = {
	"instruction": to_color("#3387d8"),     # Instructions like LDA, STA, etc.
	"directive": to_color("#ff5555"),       # Assembler directives like .org, .byte
	"register": to_color("#9e77ff"),        # Register references like A, X, Y
	"addressing": to_color("#4af158"),      # Addressing modes indicators
	"punctuation": to_color("#cccccc"),     # Symbols like commas, colons
	"label": to_color("#ffdd33"),           # Jump labels
	"memory": to_color("#e682ff"),          # Memory addresses
	"error": to_color("#ff0000"),           # Error indicators
	"number": to_color("#ff9241"),          # Numeric values
	"hexnumber": to_color("#6c47b1"),       # Hexadecimal values
	"binarynumber": to_color("#0fd688"),    # Binary values
	"comment": to_color("#ff5555"),         # Comments
	"macro": to_color("#00ddff"),           # Macros
	"var": to_color("#4af158"),             # Variables
	"const": to_color("#ffdd33"),           # Constants
}

# 6502 assembly instructions and directives
var keywords = {
	# CPU Instructions (all lowercase to match the example)
	"adc": colors["instruction"],
	"and": colors["instruction"],
	"asl": colors["instruction"],
	"bcc": colors["instruction"],
	"bcs": colors["instruction"],
	"beq": colors["instruction"],
	"bit": colors["instruction"],
	"bmi": colors["instruction"],
	"bne": colors["instruction"],
	"bpl": colors["instruction"],
	"brk": colors["instruction"],
	"bvc": colors["instruction"],
	"bvs": colors["instruction"],
	"clc": colors["instruction"],
	"cld": colors["instruction"],
	"cli": colors["instruction"],
	"clv": colors["instruction"],
	"cmp": colors["instruction"],
	"cpx": colors["instruction"],
	"cpy": colors["instruction"],
	"dec": colors["instruction"],
	"dex": colors["instruction"],
	"dey": colors["instruction"],
	"eor": colors["instruction"],
	"inc": colors["instruction"],
	"inx": colors["instruction"],
	"iny": colors["instruction"],
	"jmp": colors["instruction"],
	"jsr": colors["instruction"],
	"lda": colors["instruction"],
	"ldx": colors["instruction"],
	"ldy": colors["instruction"],
	"lsr": colors["instruction"],
	"nop": colors["instruction"],
	"ora": colors["instruction"],
	"pha": colors["instruction"],
	"php": colors["instruction"],
	"pla": colors["instruction"],
	"plp": colors["instruction"],
	"rol": colors["instruction"],
	"ror": colors["instruction"],
	"rti": colors["instruction"],
	"rts": colors["instruction"],
	"sbc": colors["instruction"],
	"sec": colors["instruction"],
	"sed": colors["instruction"],
	"sei": colors["instruction"],
	"sta": colors["instruction"],
	"stx": colors["instruction"],
	"sty": colors["instruction"],
	"tax": colors["instruction"],
	"tay": colors["instruction"],
	"tsx": colors["instruction"],
	"txa": colors["instruction"],
	"txs": colors["instruction"],
	"tya": colors["instruction"],
	
	# Registers
	"a": colors["register"],
	"x": colors["register"],
	"y": colors["register"],
	"#": colors["addressing"],  # Immediate addressing
	
	# CA65 style directives
	".org": colors["directive"],
	".byte": colors["directive"],
	".word": colors["directive"],
	".text": colors["directive"],
	".data": colors["directive"],
	".segment": colors["directive"],
	".include": colors["directive"],
	".define": colors["directive"],
	".macro": colors["directive"],
	".endmacro": colors["directive"],
	".if": colors["directive"],
	".endif": colors["directive"],
	".proc": colors["directive"],
	".endproc": colors["directive"],
	".scope": colors["directive"],
	".endscope": colors["directive"],
	
	# Custom directives from the example
	"var": colors["var"],
	"const": colors["const"],
	"macro": colors["macro"],
	"range": colors["label"],
	"range1": colors["label"],
	"range2": colors["label"],
	"beamon": colors["label"],
	
	# Common word syntax from example
	"BasicUpstart2": colors["directive"],
	"LoadSid": colors["directive"],
	"CpwRange": colors["macro"],
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
	"color": colors["hexnumber"],
	"inline": true
},{
	"start": '%',
	"end": ' ',
	"color": colors["binarynumber"],
	"inline": true
}]

func to_color(color: String) -> Color:
	return Color.from_string(color, "#ff0000");

const INSTRUCTION = preload("res://function.png")
const LABEL = preload("res://variable.png")

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
			# CPU Instructions with common patterns
			"lda": {"kind": CodeEdit.KIND_FUNCTION, "insert": "lda #$00", "image": INSTRUCTION},
			"sta": {"kind": CodeEdit.KIND_FUNCTION, "insert": "sta $0000", "image": INSTRUCTION},
			"ldx": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ldx #$00", "image": INSTRUCTION},
			"ldy": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ldy #$00", "image": INSTRUCTION},
			"stx": {"kind": CodeEdit.KIND_FUNCTION, "insert": "stx $0000", "image": INSTRUCTION},
			"sty": {"kind": CodeEdit.KIND_FUNCTION, "insert": "sty $0000", "image": INSTRUCTION},
			"jmp": {"kind": CodeEdit.KIND_FUNCTION, "insert": "jmp $0000", "image": INSTRUCTION},
			"jsr": {"kind": CodeEdit.KIND_FUNCTION, "insert": "jsr $0000", "image": INSTRUCTION},
			"rts": {"kind": CodeEdit.KIND_FUNCTION, "insert": "rts", "image": INSTRUCTION},
			"inc": {"kind": CodeEdit.KIND_FUNCTION, "insert": "inc $0000", "image": INSTRUCTION},
			"dec": {"kind": CodeEdit.KIND_FUNCTION, "insert": "dec $0000", "image": INSTRUCTION},
			"inx": {"kind": CodeEdit.KIND_FUNCTION, "insert": "inx", "image": INSTRUCTION},
			"dex": {"kind": CodeEdit.KIND_FUNCTION, "insert": "dex", "image": INSTRUCTION},
			"iny": {"kind": CodeEdit.KIND_FUNCTION, "insert": "iny", "image": INSTRUCTION},
			"dey": {"kind": CodeEdit.KIND_FUNCTION, "insert": "dey", "image": INSTRUCTION},
			"tax": {"kind": CodeEdit.KIND_FUNCTION, "insert": "tax", "image": INSTRUCTION},
			"tay": {"kind": CodeEdit.KIND_FUNCTION, "insert": "tay", "image": INSTRUCTION},
			"txa": {"kind": CodeEdit.KIND_FUNCTION, "insert": "txa", "image": INSTRUCTION},
			"tya": {"kind": CodeEdit.KIND_FUNCTION, "insert": "tya", "image": INSTRUCTION},
			"txs": {"kind": CodeEdit.KIND_FUNCTION, "insert": "txs", "image": INSTRUCTION},
			"tsx": {"kind": CodeEdit.KIND_FUNCTION, "insert": "tsx", "image": INSTRUCTION},
			"pha": {"kind": CodeEdit.KIND_FUNCTION, "insert": "pha", "image": INSTRUCTION},
			"pla": {"kind": CodeEdit.KIND_FUNCTION, "insert": "pla", "image": INSTRUCTION},
			"php": {"kind": CodeEdit.KIND_FUNCTION, "insert": "php", "image": INSTRUCTION},
			"plp": {"kind": CodeEdit.KIND_FUNCTION, "insert": "plp", "image": INSTRUCTION},
			"and": {"kind": CodeEdit.KIND_FUNCTION, "insert": "and #$00", "image": INSTRUCTION},
			"ora": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ora #$00", "image": INSTRUCTION},
			"eor": {"kind": CodeEdit.KIND_FUNCTION, "insert": "eor #$00", "image": INSTRUCTION},
			"adc": {"kind": CodeEdit.KIND_FUNCTION, "insert": "adc #$00", "image": INSTRUCTION},
			"sbc": {"kind": CodeEdit.KIND_FUNCTION, "insert": "sbc #$00", "image": INSTRUCTION},
			"cmp": {"kind": CodeEdit.KIND_FUNCTION, "insert": "cmp #$00", "image": INSTRUCTION},
			"cpx": {"kind": CodeEdit.KIND_FUNCTION, "insert": "cpx #$00", "image": INSTRUCTION},
			"cpy": {"kind": CodeEdit.KIND_FUNCTION, "insert": "cpy #$00", "image": INSTRUCTION},
			"asl": {"kind": CodeEdit.KIND_FUNCTION, "insert": "asl", "image": INSTRUCTION},
			"lsr": {"kind": CodeEdit.KIND_FUNCTION, "insert": "lsr", "image": INSTRUCTION},
			"rol": {"kind": CodeEdit.KIND_FUNCTION, "insert": "rol", "image": INSTRUCTION},
			"ror": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ror", "image": INSTRUCTION},
			"bcc": {"kind": CodeEdit.KIND_FUNCTION, "insert": "bcc label", "image": INSTRUCTION},
			"bcs": {"kind": CodeEdit.KIND_FUNCTION, "insert": "bcs label", "image": INSTRUCTION},
			"beq": {"kind": CodeEdit.KIND_FUNCTION, "insert": "beq label", "image": INSTRUCTION},
			"bne": {"kind": CodeEdit.KIND_FUNCTION, "insert": "bne label", "image": INSTRUCTION},
			"bmi": {"kind": CodeEdit.KIND_FUNCTION, "insert": "bmi label", "image": INSTRUCTION},
			"bpl": {"kind": CodeEdit.KIND_FUNCTION, "insert": "bpl label", "image": INSTRUCTION},
			"bvc": {"kind": CodeEdit.KIND_FUNCTION, "insert": "bvc label", "image": INSTRUCTION},
			"bvs": {"kind": CodeEdit.KIND_FUNCTION, "insert": "bvs label", "image": INSTRUCTION},
			"bit": {"kind": CodeEdit.KIND_FUNCTION, "insert": "bit $0000", "image": INSTRUCTION},
			"brk": {"kind": CodeEdit.KIND_FUNCTION, "insert": "brk", "image": INSTRUCTION},
			"nop": {"kind": CodeEdit.KIND_FUNCTION, "insert": "nop", "image": INSTRUCTION},
			"clc": {"kind": CodeEdit.KIND_FUNCTION, "insert": "clc", "image": INSTRUCTION},
			"sec": {"kind": CodeEdit.KIND_FUNCTION, "insert": "sec", "image": INSTRUCTION},
			"cli": {"kind": CodeEdit.KIND_FUNCTION, "insert": "cli", "image": INSTRUCTION},
			"sei": {"kind": CodeEdit.KIND_FUNCTION, "insert": "sei", "image": INSTRUCTION},
			"cld": {"kind": CodeEdit.KIND_FUNCTION, "insert": "cld", "image": INSTRUCTION},
			"sed": {"kind": CodeEdit.KIND_FUNCTION, "insert": "sed", "image": INSTRUCTION},
			"clv": {"kind": CodeEdit.KIND_FUNCTION, "insert": "clv", "image": INSTRUCTION},
			
			# Assembler directives
			".org": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": ".org $0000", "image": LABEL},
			".byte": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": ".byte $00", "image": LABEL},
			".word": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": ".word $0000", "image": LABEL},
			".text": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": ".text \"\"", "image": LABEL},
			".proc": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": ".proc name\n\n.endproc", "image": LABEL},
			".macro": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": ".macro name\n\n.endmacro", "image": LABEL},
			
			# Common 6502 patterns
			"init": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "  ldx #$ff\n  txs\n  cld", "image": LABEL},
			"zeropage": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "  lda #$00\n  ldx #$00\nzero_loop:\n  sta $0000,x\n  inx\n  bne zero_loop", "image": LABEL},
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
	code_highlighter.function_color = colors.label
	code_highlighter.member_variable_color = colors.memory
	syntax_highlighter = code_highlighter
	code_highlighter.symbol_color = colors.punctuation
	
	# Add all keywords for syntax highlighting
	for keyword in keywords:
		code_highlighter.add_keyword_color(keyword, keywords[keyword])
	
	# Add color regions
	for region in regions:
		code_highlighter.add_color_region(region.start, region.end, region.color, region.inline)
	
	# Enable line number gutter to help with assembly programming
	gutters_draw_line_numbers = true
	gutters_draw_executing_lines = true
	line_folding = true
	
	# Set tab size to 8 spaces which is common in assembly programming
	indent_size = 8
	indent_automatic = true
	indent_use_spaces = true
	auto_brace_completion_enabled = false

#func to_color(color: String) -> Color:
#	return Color.from_string(color, "#ff0000");
