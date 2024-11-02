// ScriptScheduleViewModel.swift
import Foundation

class ScriptScheduleViewModel: ObservableObject {
    @Published var schedule: ScriptSchedule
    private let script: Script
    private weak var coordinator: ScriptCoordinatorService?
    
    init(script: Script) {
        self.script = script
        self.schedule = script.schedule
    }
    
    func setCoordinator(_ coordinator: ScriptCoordinatorService) {
        self.coordinator = coordinator
    }
    
    func saveSchedule() {
        schedule.nextRun = schedule.calculateNextRun()
        script.schedule = schedule
        coordinator?.scheduleScript(script)
    }
}
