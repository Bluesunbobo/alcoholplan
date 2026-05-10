import re

with open("AlcoholPlan/ContentView.swift", "r") as f:
    text = f.read()

# SettingsView rewrite
text = text.replace("private var header: some View", "struct SettingsHeaderView: View {\n    var body: some View")
text = text.replace("header\n", "SettingsHeaderView()\n")

text = text.replace("private var personaSection: some View", "struct SettingsPersonaSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain\n\n    var body: some View")
text = text.replace("personaSection\n", "SettingsPersonaSection(userSettings: userSettings, brain: brain)\n")

text = text.replace("private var anatomySection: some View", "struct SettingsAnatomySection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain\n\n    var body: some View")
text = text.replace("anatomySection\n", "SettingsAnatomySection(userSettings: userSettings, brain: brain)\n")

text = text.replace("private var jurisdictionSection: some View", "struct SettingsJurisdictionSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain\n\n    var body: some View")
text = text.replace("jurisdictionSection\n", "SettingsJurisdictionSection(userSettings: userSettings, brain: brain)\n")

text = text.replace("private var metabolismSection: some View", "struct SettingsMetabolismSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain\n\n    var body: some View")
text = text.replace("metabolismSection\n", "SettingsMetabolismSection(userSettings: userSettings, brain: brain)\n")

text = text.replace("private var footer: some View", "struct SettingsFooterView: View {\n    var body: some View")
text = text.replace("footer\n", "SettingsFooterView()\n")


# HistoryView rewrite
text = text.replace("private var heatMapGrid: some View", "struct HistoryHeatMapGrid: View {\n    var sessionsCount: Int\n    var body: some View")
text = text.replace("heatMapGrid\n", "HistoryHeatMapGrid(sessionsCount: sessions.count)\n")
text = text.replace(r"\(\(sessions\.count\)", r"\(\(sessionsCount\)")

text = text.replace("private var timelineView: some View", "struct HistoryTimelineView: View {\n    var sessions: FetchedResults<DrinkSession>\n    var body: some View")
text = text.replace("timelineView\n", "HistoryTimelineView(sessions: sessions)\n")

text = text.replace("private func sessionCard(session: DrinkSession) -> some View", "struct HistorySessionCard: View {\n    var session: DrinkSession\n    var body: some View")
text = text.replace("sessionCard(session: session)", "HistorySessionCard(session: session)")

# CurveView rewrite
text = text.replace("private var chartCard: some View", "struct CurveChartCard: View {\n    @ObservedObject var brain: AlcoholBrain\n    var body: some View")
text = text.replace("chartCard\n", "CurveChartCard(brain: brain)\n")


with open("AlcoholPlan/ContentView.swift", "w") as f:
    f.write(text)
