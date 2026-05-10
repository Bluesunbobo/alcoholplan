import re

with open("AlcoholPlan/ContentView.swift", "r") as f:
    text = f.read()

# SettingsView revert
text = text.replace("struct SettingsHeaderView: View {\n    var body: some View", "private var header: some View")
text = text.replace("SettingsHeaderView()\n", "header\n")

text = text.replace("struct SettingsPersonaSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain\n\n    var body: some View", "private var personaSection: some View")
text = text.replace("SettingsPersonaSection(userSettings: userSettings, brain: brain)\n", "personaSection\n")

text = text.replace("struct SettingsAnatomySection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain\n\n    var body: some View", "private var anatomySection: some View")
text = text.replace("SettingsAnatomySection(userSettings: userSettings, brain: brain)\n", "anatomySection\n")

text = text.replace("struct SettingsJurisdictionSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain\n\n    var body: some View", "private var jurisdictionSection: some View")
text = text.replace("SettingsJurisdictionSection(userSettings: userSettings, brain: brain)\n", "jurisdictionSection\n")

text = text.replace("struct SettingsMetabolismSection: View {\n    @ObservedObject var userSettings: UserSettings\n    @ObservedObject var brain: AlcoholBrain\n\n    var body: some View", "private var metabolismSection: some View")
text = text.replace("SettingsMetabolismSection(userSettings: userSettings, brain: brain)\n", "metabolismSection\n")

text = text.replace("struct SettingsFooterView: View {\n    var body: some View", "private var footer: some View")
text = text.replace("SettingsFooterView()\n", "footer\n")


# HistoryView revert
text = text.replace("struct HistoryHeatMapGrid: View {\n    var sessionsCount: Int\n    var body: some View", "private var heatMapGrid: some View")
text = text.replace("HistoryHeatMapGrid(sessionsCount: sessions.count)\n", "heatMapGrid\n")
text = text.replace(r"\(\(sessionsCount\)", r"\(\(sessions\.count\)")

text = text.replace("struct HistoryTimelineView: View {\n    var sessions: FetchedResults<DrinkSession>\n    var body: some View", "private var timelineView: some View")
text = text.replace("HistoryTimelineView(sessions: sessions)\n", "timelineView\n")

text = text.replace("struct HistorySessionCard: View {\n    var session: DrinkSession\n    var body: some View", "private func sessionCard(session: DrinkSession) -> some View")
text = text.replace("HistorySessionCard(session: session)", "sessionCard(session: session)")

# CurveView revert
text = text.replace("struct CurveChartCard: View {\n    @ObservedObject var brain: AlcoholBrain\n    var body: some View", "private var chartCard: some View")
text = text.replace("CurveChartCard(brain: brain)\n", "chartCard\n")

with open("AlcoholPlan/ContentView.swift", "w") as f:
    f.write(text)
