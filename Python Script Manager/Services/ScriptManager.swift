// ScriptManager.swift
import Foundation
import Combine

// First define the protocol with a different name
protocol ScriptManagerProtocol: AnyObject {
    var scripts: [Script] { get }
    var executionService: ScriptExecutionService { get }
    
    func runScript(_ script: Script) -> Process
    func stopScript(_ script: Script)
    func scheduleScript(_ script: Script)
    func removeScript(_ script: Script)
    func sendInput(_ scriptId: UUID, _ input: String)
    func isWaitingForInput(scriptId: UUID) -> Bool
    func getOutput(for scriptId: UUID) -> String
}

// Then implement the class
class ScriptManager: NSObject, ObservableObject, ScriptManagerProtocol {
    @Published var scripts: [Script] = []
    
    let executionService: ScriptExecutionService
    let storageService: ScriptStorageService
    private(set) var schedulerService: ScriptSchedulerService
    
    override init() {
        self.executionService = ScriptExecutionService()
        self.storageService = ScriptStorageService()
        
        // Create scheduler with self after super.init()
        self.schedulerService = ScriptSchedulerService(scriptManager: nil)
        
        super.init()
        
        // Load saved scripts
        self.scripts = storageService.loadScripts()
        
        // Now we can safely update the scheduler's manager reference
        self.schedulerService.updateScriptManager(self)
        
        // Schedule enabled scripts
        for script in scripts where script.schedule.isEnabled {
            script.schedule.nextRun = script.schedule.calculateNextRun()
            schedulerService.scheduleScript(script)
        }
        
        // Observe notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAddScript(_:)),
            name: NSNotification.Name("AddScript"),
            object: nil
        )
    }
    
    // MARK: - Script Management
    
    @objc private func handleAddScript(_ notification: Notification) {
        if let path = notification.userInfo?["path"] as? String {
            addScript(path: path)
        }
    }
    
    func addScript(path: String) {
        let script = storageService.addScript(path: path)
        DispatchQueue.main.async {
            self.scripts.append(script)
            self.saveScripts()
        }
    }
    
    func removeScript(_ script: Script) {
        guard !script.isRunning else { return }
        
        schedulerService.cancelSchedule(for: script.id)
        DispatchQueue.main.async {
            self.scripts.removeAll(where: { $0.id == script.id })
            self.saveScripts()
        }
    }
    
    // MARK: - Script Execution
    
    func runScript(_ script: Script) -> Process {
        let process = executionService.runScript(script)
        saveScripts()
        return process
    }
    
    func stopScript(_ script: Script) {
        executionService.stopScript(script)
        saveScripts()
    }
    
    func sendInput(_ scriptId: UUID, _ input: String) {
        executionService.sendInput(scriptId, input)
    }
    
    func isWaitingForInput(scriptId: UUID) -> Bool {
        executionService.isWaitingForInput(scriptId: scriptId)
    }
    
    func getOutput(for scriptId: UUID) -> String {
        executionService.getOutput(for: scriptId)
    }
    
    // MARK: - Scheduling
    
    func scheduleScript(_ script: Script) {
        if script.schedule.isEnabled {
            script.schedule.nextRun = script.schedule.calculateNextRun()
            schedulerService.scheduleScript(script)
        } else {
            schedulerService.cancelSchedule(for: script.id)
        }
        saveScripts()
    }
    
    // MARK: - Persistence
    
    private func saveScripts() {
        storageService.saveScripts(scripts)
    }
    
    // MARK: - Cleanup
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        schedulerService.cancelAllSchedules()
        executionService.cleanupAllProcesses()
    }
}


