import SwiftUI

struct DemoScenarioSwitcher: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Perspective") {
                    Picker("Perspective", selection: $container.perspective) {
                        ForEach(AppContainer.Perspective.allCases) { perspective in
                            Text(perspective.rawValue).tag(perspective)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Scenario") {
                    ForEach(DemoScenario.allCases) { scenario in
                        Button {
                            container.scenario = scenario
                            dismiss()
                        } label: {
                            HStack {
                                Text(scenario.rawValue)
                                Spacer()
                                if scenario == container.scenario {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(ThemisColor.actionPrimary)
                                }
                            }
                        }
                        .foregroundStyle(ThemisColor.textPrimary)
                    }
                }
            }
            .navigationTitle("Demo controls")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
