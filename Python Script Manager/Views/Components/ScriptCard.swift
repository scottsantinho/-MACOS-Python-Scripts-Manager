// ScriptCard.swift
import SwiftUI

struct ScriptCard: View {
    @ObservedObject var script: Script
    @EnvironmentObject private var appState: AppState
    
    let onRun: (Script) -> Void
    let onStop: (Script) -> Void
    let onRemove: (Script) -> Void
    let onSchedule: (Script) -> Void
    
    @State private var showingDeleteAlert = false
    @State private var showingSchedulePopup = false
    
    var body: some View {
        HStack {
            deleteButton
            scriptInfo
            Spacer()
            controlButtons
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .alert("Remove Script", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                onRemove(script)
            }
        } message: {
            Text("Are you sure you want to remove '\(script.name)' from the list?\nThis will not delete the file from disk.")
        }
        .sheet(isPresented: $showingSchedulePopup) {
            ScriptScheduleView(script: script)
                .environmentObject(appState)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            showingDeleteAlert = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
                .opacity(script.isRunning ? 0.3 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(script.isRunning)
        .help(script.isRunning ? "Stop the script before removing" : "Remove script")
        .padding(.trailing, 8)
    }
    
    private var scriptInfo: some View {
            VStack(alignment: .leading, spacing: 8) {  // Added spacing
                Text(script.name)
                    .font(.system(.headline, design: .monospaced))
                
                Text(formatPath(script.path))
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Last run: \(script.lastRun?.formatted() ?? "Never")")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    if script.schedule.isEnabled,
                       let nextRun = script.schedule.nextRun {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("Next run: \(nextRun.formatted())")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    
    private func formatPath(_ path: String) -> String {
        let components = path.components(separatedBy: "/")
        let filteredComponents = components.filter { !$0.isEmpty }
        return filteredComponents.joined(separator: " > ")
        
    }
    
    private var controlButtons: some View {
        HStack {
            Button(action: {
                if script.isRunning {
                    onStop(script)
                } else {
                    onRun(script)
                }
            }) {
                Image(systemName: script.isRunning ? "stop.fill" : "play.fill")
                    .foregroundColor(script.isRunning ? .red : .green)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                showingSchedulePopup = true
            }) {
                Image(systemName: "clock.fill")
                    .foregroundColor(script.schedule.isEnabled ? .blue : .gray)
                    .if(script.schedule.isEnabled) { view in
                        view.symbolEffect(.pulse, options: .repeating)
                    }
            }
            .buttonStyle(.plain)
            .help(script.schedule.isEnabled ? "Modify schedule" : "Add schedule")
            .disabled(script.isRunning)
        }
    }
}
