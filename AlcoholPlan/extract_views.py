import re

with open("AlcoholPlan/ContentView.swift", "r") as f:
    text = f.read()

def extract_block(text, target):
    start_idx = text.find(target)
    if start_idx == -1: return None, None
    scope = 0
    in_str = False
    in_char = False
    body_start_idx = text.find('{', start_idx)
    for i in range(body_start_idx, len(text)):
        c = text[i]
        if c == '"' and text[i-1] != '\\': in_str = not in_str
        elif c == "'" and text[i-1] != '\\': in_char = not in_char
        elif not in_str and not in_char:
            if c == '{': scope += 1
            elif c == '}':
                scope -= 1
                if scope == 0:
                    return start_idx, i + 1
    return None, None

def refactor_block(text, target, new_struct, new_instantiation):
    s, e = extract_block(text, target)
    if s is None: return text
    
    # The block code
    block_code = text[s:e]
    # Replace declaration inside the block code
    body_decl = block_code.replace(target, "var body: some View {", 1)
    
    # Construct struct
    struct_code = f"{new_struct}\n    {body_decl}\n}}\n"
    
    # Append struct to end of file
    text = text + "\n" + struct_code
    
    # Replace original block with instantiation
    text = text[:s] + new_instantiation + text[e:]
    return text

text = refactor_block(text, "private var header: some View {", 
                      "struct SettingsHeaderView: View {", 
                      "SettingsHeaderView()")

text = refactor_block(text, "private var personaSection: some View {", 
                      "struct SettingsPersonaSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain", 
                      "SettingsPersonaSection(userSettings: userSettings, brain: brain)")

text = refactor_block(text, "private var anatomySection: some View {", 
                      "struct SettingsAnatomySection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain", 
                      "SettingsAnatomySection(userSettings: userSettings, brain: brain)")

text = refactor_block(text, "private var jurisdictionSection: some View {", 
                      "struct SettingsJurisdictionSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain", 
                      "SettingsJurisdictionSection(userSettings: userSettings, brain: brain)")

text = refactor_block(text, "private var metabolismSection: some View {", 
                      "struct SettingsMetabolismSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain", 
                      "SettingsMetabolismSection(userSettings: userSettings, brain: brain)")

text = refactor_block(text, "private var footer: some View {", 
                      "struct SettingsFooterView: View {", 
                      "SettingsFooterView()")

with open("AlcoholPlan/ContentView.swift", "w") as f:
    f.write(text)
