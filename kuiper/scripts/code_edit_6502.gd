extends CodeEdit

var changed := false

var colors = {
    "keyword": Color("#957FB8"),
    "special_keyword": Color("#FF5D62"),
    "builtin": Color("#7FB4CA"),
    "type": Color("#7AA89F"),
    "punctuation": Color("#9CABCA"),
    "function": Color("#7E9CD8"),
    "member": Color("#E6C384"),
    "error": Color("#E82424"),
    "number": Color("#D27E99"),
}

var keywords = {
    "ADC": colors["keyword"],
    "AND": colors["keyword"],
    "ASL": colors["keyword"],
    "BCC": colors["keyword"],
    "BCS": colors["keyword"],
    "BEQ": colors["keyword"],
    "BIT": colors["keyword"],
    "BMI": colors["keyword"],
    "BNE": colors["keyword"],
    "BPL": colors["keyword"],
    "BRK": colors["keyword"],
    "BVC": colors["keyword"],
    "BVS": colors["keyword"],
    "CLC": colors["keyword"],
    "CLD": colors["keyword"],
    "CLI": colors["keyword"],
    "CLV": colors["keyword"],
    "CMP": colors["keyword"],
    "CPX": colors["keyword"],
    "CPY": colors["keyword"],
    "DEC": colors["keyword"],
    "DEX": colors["keyword"],
    "DEY": colors["keyword"],
    "EOR": colors["keyword"],
    "INC": colors["keyword"],
    "INX": colors["keyword"],
    "INY": colors["keyword"],
    "JMP": colors["keyword"],
    "JSR": colors["keyword"],
    "LDA": colors["keyword"],
    "LDX": colors["keyword"],
    "LDY": colors["keyword"],
    "LSR": colors["keyword"],
    "NOP": colors["keyword"],
    "ORA": colors["keyword"],
    "PHA": colors["keyword"],
    "PHP": colors["keyword"],
    "PLA": colors["keyword"],
    "PLP": colors["keyword"],
    "ROL": colors["keyword"],
    "ROR": colors["keyword"],
    "RTI": colors["keyword"],
    "RTS": colors["keyword"],
    "SBC": colors["keyword"],
    "SEC": colors["keyword"],
    "SED": colors["keyword"],
    "SEI": colors["keyword"],
    "STA": colors["keyword"],
    "STX": colors["keyword"],
    "STY": colors["keyword"],
    "TAX": colors["keyword"],
    "TAY": colors["keyword"],
    "TSX": colors["keyword"],
    "TXA": colors["keyword"],
    "TXS": colors["keyword"],
    "TYA": colors["keyword"]
}

var regions = [{
    "start": '"',
    "end": '"',
    "color": Color("#98BB6C"),
    "inline": false
},{
    "start": ';',
    "end": '\n',
    "color": Color("#727169"),
    "inline": true
}]

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
            "ADC": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ADC ", "image": FUNCTION},
            "AND": {"kind": CodeEdit.KIND_FUNCTION, "insert": "AND ", "image": FUNCTION},
            "ASL": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ASL ", "image": FUNCTION},
            "BCC": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BCC ", "image": FUNCTION},
            "BCS": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BCS ", "image": FUNCTION},
            "BEQ": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BEQ ", "image": FUNCTION},
            "BIT": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BIT ", "image": FUNCTION},
            "BMI": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BMI ", "image": FUNCTION},
            "BNE": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BNE ", "image": FUNCTION},
            "BPL": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BPL ", "image": FUNCTION},
            "BRK": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BRK ", "image": FUNCTION},
            "BVC": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BVC ", "image": FUNCTION},
            "BVS": {"kind": CodeEdit.KIND_FUNCTION, "insert": "BVS ", "image": FUNCTION},
            "CLC": {"kind": CodeEdit.KIND_FUNCTION, "insert": "CLC ", "image": FUNCTION},
            "CLD": {"kind": CodeEdit.KIND_FUNCTION, "insert": "CLD ", "image": FUNCTION},
            "CLI": {"kind": CodeEdit.KIND_FUNCTION, "insert": "CLI ", "image": FUNCTION},
            "CLV": {"kind": CodeEdit.KIND_FUNCTION, "insert": "CLV ", "image": FUNCTION},
            "CMP": {"kind": CodeEdit.KIND_FUNCTION, "insert": "CMP ", "image": FUNCTION},
            "CPX": {"kind": CodeEdit.KIND_FUNCTION, "insert": "CPX ", "image": FUNCTION},
            "CPY": {"kind": CodeEdit.KIND_FUNCTION, "insert": "CPY ", "image": FUNCTION},
            "DEC": {"kind": CodeEdit.KIND_FUNCTION, "insert": "DEC ", "image": FUNCTION},
            "DEX": {"kind": CodeEdit.KIND_FUNCTION, "insert": "DEX ", "image": FUNCTION},
            "DEY": {"kind": CodeEdit.KIND_FUNCTION, "insert": "DEY ", "image": FUNCTION},
            "EOR": {"kind": CodeEdit.KIND_FUNCTION, "insert": "EOR ", "image": FUNCTION},
            "INC": {"kind": CodeEdit.KIND_FUNCTION, "insert": "INC ", "image": FUNCTION},
            "INX": {"kind": CodeEdit.KIND_FUNCTION, "insert": "INX ", "image": FUNCTION},
            "INY": {"kind": CodeEdit.KIND_FUNCTION, "insert": "INY ", "image": FUNCTION},
            "JMP": {"kind": CodeEdit.KIND_FUNCTION, "insert": "JMP ", "image": FUNCTION},
            "JSR": {"kind": CodeEdit.KIND_FUNCTION, "insert": "JSR ", "image": FUNCTION},
            "LDA": {"kind": CodeEdit.KIND_FUNCTION, "insert": "LDA ", "image": FUNCTION},
            "LDX": {"kind": CodeEdit.KIND_FUNCTION, "insert": "LDX ", "image": FUNCTION},
            "LDY": {"kind": CodeEdit.KIND_FUNCTION, "insert": "LDY ", "image": FUNCTION},
            "LSR": {"kind": CodeEdit.KIND_FUNCTION, "insert": "LSR ", "image": FUNCTION},
            "NOP": {"kind": CodeEdit.KIND_FUNCTION, "insert": "NOP ", "image": FUNCTION},
            "ORA": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ORA ", "image": FUNCTION},
            "PHA": {"kind": CodeEdit.KIND_FUNCTION, "insert": "PHA ", "image": FUNCTION},
            "PHP": {"kind": CodeEdit.KIND_FUNCTION, "insert": "PHP ", "image": FUNCTION},
            "PLA": {"kind": CodeEdit.KIND_FUNCTION, "insert": "PLA ", "image": FUNCTION},
            "PLP": {"kind": CodeEdit.KIND_FUNCTION, "insert": "PLP ", "image": FUNCTION},
            "ROL": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ROL ", "image": FUNCTION},
            "ROR": {"kind": CodeEdit.KIND_FUNCTION, "insert": "ROR ", "image": FUNCTION},
            "RTI": {"kind": CodeEdit.KIND_FUNCTION, "insert": "RTI ", "image": FUNCTION},
            "RTS": {"kind": CodeEdit.KIND_FUNCTION, "insert": "RTS ", "image": FUNCTION},
            "SBC": {"kind": CodeEdit.KIND_FUNCTION, "insert": "SBC ", "image": FUNCTION},
            "SEC": {"kind": CodeEdit.KIND_FUNCTION, "insert": "SEC ", "image": FUNCTION},
            "SED": {"kind": CodeEdit.KIND_FUNCTION, "insert": "SED ", "image": FUNCTION},
            "SEI": {"kind": CodeEdit.KIND_FUNCTION, "insert": "SEI ", "image": FUNCTION},
            "STA": {"kind": CodeEdit.KIND_FUNCTION, "insert": "STA ", "image": FUNCTION},
            "STX": {"kind": CodeEdit.KIND_FUNCTION, "insert": "STX ", "image": FUNCTION},
            "STY": {"kind": CodeEdit.KIND_FUNCTION, "insert": "STY ", "image": FUNCTION},
            "TAX": {"kind": CodeEdit.KIND_FUNCTION, "insert": "TAX ", "image": FUNCTION},
            "TAY": {"kind": CodeEdit.KIND_FUNCTION, "insert": "TAY ", "image": FUNCTION},
            "TSX": {"kind": CodeEdit.KIND_FUNCTION, "insert": "TSX ", "image": FUNCTION},
            "TXA": {"kind": CodeEdit.KIND_FUNCTION, "insert": "TXA ", "image": FUNCTION},
            "TXS": {"kind": CodeEdit.KIND_FUNCTION, "insert": "TXS ", "image": FUNCTION},
            "TYA": {"kind": CodeEdit.KIND_FUNCTION, "insert": "TYA ", "image": FUNCTION}
        }
        
        for completion_word in completions:
            if word.begins_with(completion_word) and word.is_subsequence_of(completion_word): 
                if completion_word in completions:
                    add_code_completion_option(completions[completion_word]["kind"], completion_word, completions[completion_word]["insert"], Color("#dcd7ba"), completions[completion_word]["image"])
        update_code_completion_options(false)
    )

func _ready():
    code_completion()
    var code_highlighter: CodeHighlighter = CodeHighlighter.new()
    code_highlighter.number_color = colors.number
    code_highlighter.function_color = colors.function
    code_highlighter.member_variable_color = colors.member
    syntax_highlighter = code_highlighter
    code_highlighter.symbol_color = colors.punctuation
    for keyword in keywords:
        code_highlighter.add_keyword_color(keyword, keywords[keyword])
    for region in regions:
        code_highlighter.add_color_region(region["start"], region["end"], region["color"], region["inline"])