// ScriptListView.swift
import SwiftUI

struct ScriptListView: View {
    @ObservedObject var viewModel: ScriptListViewModel
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.scripts) { script in
                    ScriptCard(
                        script: script,
                        onRun: { viewModel.runScript($0) },
                        onStop: { viewModel.stopScript($0) },
                        onRemove: { viewModel.removeScript($0) },
                        onSchedule: { viewModel.scheduleScript($0) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}
