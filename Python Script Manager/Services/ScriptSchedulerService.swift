// ScriptSchedulerService.swift
import Foundation

class ScriptSchedulerService: ScriptSchedulable {
    private var timers: [UUID: Timer] = [:]
    private weak var scriptManager: ScriptManagerProtocol?
    
    init(scriptManager: ScriptManagerProtocol?) {
        self.scriptManager = scriptManager
    }
    
    func updateScriptManager(_ manager: ScriptManagerProtocol) {
        self.scriptManager = manager
    }
    
    func scheduleScript(_ script: Script) {
        cancelSchedule(for: script.id)
        
        guard script.schedule.isEnabled,
              let nextRun = script.schedule.nextRun else {
            return
        }
        
        guard nextRun > Date() else {
            script.schedule.nextRun = script.schedule.calculateNextRun(from: Date())
            if let newNextRun = script.schedule.nextRun {
                createTimer(for: script, fireDate: newNextRun)
            }
            return
        }
        
        createTimer(for: script, fireDate: nextRun)
    }
    
    private func createTimer(for script: Script, fireDate: Date) {
        let timer = Timer(fireAt: fireDate, interval: 0, target: self,
                         selector: #selector(handleTimerFire(_:)), userInfo: script.id, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        timers[script.id] = timer
    }
    
    @objc private func handleTimerFire(_ timer: Timer) {
        guard let scriptId = timer.userInfo as? UUID,
              let script = scriptManager?.scripts.first(where: { $0.id == scriptId }) else {
            return
        }
        
        let process = scriptManager?.executionService.runScript(script)
        do {
            try process?.run()
            
            if script.schedule.frequency != .once {
                script.schedule.nextRun = script.schedule.calculateNextRun(from: Date())
                if script.schedule.isEnabled {
                    scheduleScript(script)
                }
            } else {
                script.schedule.isEnabled = false
            }
        } catch {
            print("Failed to run scheduled script: \(error.localizedDescription)")
        }
    }
    
    func cancelSchedule(for scriptId: UUID) {
        timers[scriptId]?.invalidate()
        timers.removeValue(forKey: scriptId)
    }
    
    func cancelAllSchedules() {
        timers.values.forEach { $0.invalidate() }
        timers.removeAll()
    }
}
