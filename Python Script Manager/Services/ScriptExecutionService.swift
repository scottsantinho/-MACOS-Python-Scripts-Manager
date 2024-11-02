// MARK: - Services/ScriptExecutionService.swift
import Foundation
import Combine

class ScriptExecutionService: ScriptExecutable {
    private var processes: [UUID: Process] = [:]
    private var outputPipes: [UUID: Pipe] = [:]
    private var inputPipes: [UUID: Pipe] = [:]
    private var errorPipes: [UUID: Pipe] = [:]
    private var scriptOutputs: [UUID: String] = [:]
    private var scriptIsWaitingForInput: [UUID: Bool] = [:]
    private let outputQueue = DispatchQueue(label: "com.scriptmanager.output", qos: .userInteractive)
    
    private func getPythonPath() -> String {
        let possiblePaths = [
            "/opt/homebrew/bin/python3",
            "/usr/local/bin/python3",
            "/usr/bin/python3",
            "/usr/bin/python"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return "python3"
    }
    
    func runScript(_ script: Script) -> Process {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let inputPipe = Pipe()
        
        outputPipes[script.id] = outputPipe
        errorPipes[script.id] = errorPipe
        inputPipes[script.id] = inputPipe
        
        DispatchQueue.main.async {
            if !script.schedule.isEnabled {
                self.scriptOutputs[script.id] = ""
            }
            self.scriptIsWaitingForInput[script.id] = false
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: getPythonPath())
        process.arguments = ["-u", script.path]
        
        var env = ProcessInfo.processInfo.environment
        env["PYTHONUNBUFFERED"] = "1"
        env["PYTHONIOENCODING"] = "utf-8"
        process.environment = env
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.standardInput = inputPipe
        
        setupOutputHandling(script: script, outputPipe: outputPipe, errorPipe: errorPipe)
        
        DispatchQueue.main.async {
            script.isRunning = true
        }
        
        processes[script.id] = process
        
        process.terminationHandler = { [weak self] process in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                script.isRunning = false
                script.lastRun = Date()
                self.cleanup(scriptId: script.id)
                
                let terminationMessage = process.terminationStatus != 0
                    ? "\n[Script terminated with error status: \(process.terminationStatus)]\n"
                    : "\n[Script completed successfully]\n"
                
                self.scriptOutputs[script.id] = (self.scriptOutputs[script.id] ?? "") + terminationMessage
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("ScriptOutputUpdated"),
                    object: nil,
                    userInfo: ["scriptId": script.id, "output": terminationMessage]
                )
            }
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("ScriptDidStart"),
            object: nil,
            userInfo: ["scriptId": script.id]
        )
        
        return process
    }
    
    func stopScript(_ script: Script) {
        guard let process = processes[script.id] else { return }
        
        DispatchQueue.main.async {
            script.isRunning = false
            script.lastRun = Date()
        }
        
        process.terminate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if process.isRunning {
                kill(process.processIdentifier, SIGKILL)
            }
            
            self?.cleanup(scriptId: script.id)
            
            let terminationMessage = "\n[Script terminated]\n"
            self?.scriptOutputs[script.id] = (self?.scriptOutputs[script.id] ?? "") + terminationMessage
            
            NotificationCenter.default.post(
                name: NSNotification.Name("ScriptOutputUpdated"),
                object: nil,
                userInfo: ["scriptId": script.id, "output": terminationMessage]
            )
        }
    }
    
    private func cleanup(scriptId: UUID) {
        outputPipes[scriptId]?.fileHandleForReading.readabilityHandler = nil
        errorPipes[scriptId]?.fileHandleForReading.readabilityHandler = nil
        inputPipes[scriptId]?.fileHandleForWriting.closeFile()
        
        processes.removeValue(forKey: scriptId)
        outputPipes.removeValue(forKey: scriptId)
        inputPipes.removeValue(forKey: scriptId)
        errorPipes.removeValue(forKey: scriptId)
    }
    
    private func setupOutputHandling(script: Script, outputPipe: Pipe, errorPipe: Pipe) {
        outputQueue.async { [weak self] in
            guard let self = self else { return }
            let outputHandle = outputPipe.fileHandleForReading
            let errorHandle = errorPipe.fileHandleForReading
            
            outputHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if data.isEmpty { return }
                self.processOutput(scriptId: script.id, data)
            }
            
            errorHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if data.isEmpty { return }
                self.processOutput(scriptId: script.id, data)
            }
        }
    }
    
    private func processOutput(scriptId: UUID, _ data: Data) {
        guard let output = String(data: data, encoding: .utf8) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.scriptOutputs[scriptId] == nil {
                self.scriptOutputs[scriptId] = ""
            }
            
            let promptPatterns = [
                "input(",
                "Enter",
                "? ",
                ": ",
                ">",
                "Input:",
                "duration in minutes"
            ]
            
            let containsPrompt = promptPatterns.contains { pattern in
                output.contains(pattern)
            }
            
            if containsPrompt {
                self.scriptIsWaitingForInput[scriptId] = true
            }
            
            self.scriptOutputs[scriptId] = (self.scriptOutputs[scriptId] ?? "") + output
            
            NotificationCenter.default.post(
                name: NSNotification.Name("ScriptOutputUpdated"),
                object: nil,
                userInfo: ["scriptId": scriptId, "output": output]
            )
        }
    }
    
    func sendInput(_ scriptId: UUID, _ input: String) {
        guard let inputPipe = inputPipes[scriptId] else { return }
        
        let inputWithNewline = input + "\n"
        
        if let data = inputWithNewline.data(using: .utf8) {
            do {
                try inputPipe.fileHandleForWriting.write(contentsOf: data)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if var output = self.scriptOutputs[scriptId] {
                        output += "> \(input)\n"
                        self.scriptOutputs[scriptId] = output
                        
                        NotificationCenter.default.post(
                            name: NSNotification.Name("ScriptOutputUpdated"),
                            object: nil,
                            userInfo: ["scriptId": scriptId, "output": "> \(input)\n"]
                        )
                    }
                    self.scriptIsWaitingForInput[scriptId] = false
                }
            } catch {
                print("Error writing to pipe: \(error)")
            }
        }
    }
    
    func isWaitingForInput(scriptId: UUID) -> Bool {
        return scriptIsWaitingForInput[scriptId] ?? false
    }
    
    func getOutput(for scriptId: UUID) -> String {
        return scriptOutputs[scriptId] ?? ""
    }
    
    func observeScriptOutput(_ scriptId: UUID) -> AsyncStream<String> {
        AsyncStream { continuation in
            if self.scriptOutputs[scriptId] == nil {
                self.scriptOutputs[scriptId] = ""
            }
            
            let task = Task {
                while self.processes[scriptId] != nil {
                    continuation.yield(self.scriptOutputs[scriptId] ?? "")
                    try await Task.sleep(nanoseconds: 100_000_000)
                }
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    func cleanupAllProcesses() {
        for (scriptId, process) in processes {
            process.terminate()
            cleanup(scriptId: scriptId)
        }
        
        scriptOutputs.removeAll()
        scriptIsWaitingForInput.removeAll()
    }
}
