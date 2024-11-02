// MARK: - Views/Sheets/ScriptScheduleView.swift
import SwiftUI

struct ScriptScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var script: Script
    @StateObject private var viewModel: ScriptScheduleViewModel
    @EnvironmentObject private var appState: AppState
    
    // Add the weekDays array
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    init(script: Script) {
        self.script = script
        _viewModel = StateObject(wrappedValue: ScriptScheduleViewModel(script: script))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            contentArea
            
            Divider()
            
            actionButtons
        }
        .padding()
        .frame(width: 400)
    }
    
    private var contentArea: some View {
        VStack(spacing: 20) {
            Toggle("Enable Schedule", isOn: $viewModel.schedule.isEnabled)
                .padding(.horizontal)
            
            if viewModel.schedule.isEnabled {
                schedulingOptions
            } else {
                disabledScheduleView
            }
        }
        .frame(height: 300)
    }
    
    private var schedulingOptions: some View {
        VStack(spacing: 20) {
            frequencyPicker
            
            if viewModel.schedule.frequency == .weekly {
                weekDaysPicker
            }
            
            timePicker
            
            if let previewNextRun = viewModel.schedule.calculateNextRun() {
                Text("Next scheduled run will be: \(previewNextRun.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var disabledScheduleView: some View {
        VStack {
            Text("Schedule is currently disabled")
                .foregroundColor(.secondary)
            Text("Enable the schedule to set up automated script execution")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
    
    private var frequencyPicker: some View {
        Picker("Frequency", selection: $viewModel.schedule.frequency) {
            ForEach(ScriptSchedule.Frequency.allCases, id: \.self) { frequency in
                Text(frequency.rawValue).tag(frequency)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var weekDaysPicker: some View {
        VStack(alignment: .leading) {
            Text("Select Days")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(0..<7) { index in
                    let day = index + 1
                    dayToggleButton(day: day)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func dayToggleButton(day: Int) -> some View {
        let isSelected = viewModel.schedule.selectedDays.contains(day)
        return Button {
            if isSelected {
                viewModel.schedule.selectedDays.remove(day)
            } else {
                viewModel.schedule.selectedDays.insert(day)
            }
        } label: {
            Text(weekDays[day - 1])
                .font(.caption)
                .frame(minWidth: 30)
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .background(isSelected ? Color.accentColor : Color(.controlBackgroundColor))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
    
    private var timePicker: some View {
        HStack {
            Picker("Hour", selection: $viewModel.schedule.hour) {
                ForEach(0..<24) { hour in
                    Text("\(hour)").tag(hour)
                }
            }
            .labelsHidden()
            
            Text(":")
            
            Picker("Minute", selection: $viewModel.schedule.minute) {
                ForEach(0..<60) { minute in
                    Text(String(format: "%02d", minute)).tag(minute)
                }
            }
            .labelsHidden()
        }
    }
    
    private var actionButtons: some View {
        HStack {
            Button("Reset to Default") {
                viewModel.schedule = .defaultSchedule
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            
            Button("Save") {
                viewModel.setCoordinator(appState.scriptCoordinator)
                viewModel.saveSchedule()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }
}
