// TerminalViewModel.swift
import Foundation
import Combine

class TerminalViewModel: ObservableObject {
    @Published var terminals: [TerminalTab] = [TerminalTab.createDefault()]
    @Published var selectedTerminalIndex = 0
    private var coordinator: ScriptCoordinatorService?
    private var cancellables = Set<AnyCancellable>()
    
    var currentTerminal: TerminalTab? {
        guard terminals.indices.contains(selectedTerminalIndex) else { return nil }
        return terminals[selectedTerminalIndex]
    }
    
    func updateScriptCoordinator(_ coordinator: ScriptCoordinatorService) {
        self.coordinator = coordinator
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: NSNotification.Name("ScriptDidStart"))
            .sink { [weak self] notification in
                guard let self = self,
                      let scriptId = notification.userInfo?["scriptId"] as? UUID else { return }
                
                if self.terminals.firstIndex(where: { $0.scriptId == scriptId }) == nil {
                    let newTerminal = TerminalTab(
                        id: UUID(),
                        scriptId: scriptId,
                        outputText: "Starting script...\n",
                        terminalInput: "",
                        isWaitingForInput: false
                    )
                    self.terminals.append(newTerminal)
                    self.selectedTerminalIndex = self.terminals.count - 1
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("ScriptOutputUpdated"))
            .sink { [weak self] notification in
                guard let self = self,
                      let scriptId = notification.userInfo?["scriptId"] as? UUID,
                      let output = notification.userInfo?["output"] as? String else { return }
                
                if let terminalIndex = self.terminals.firstIndex(where: { $0.scriptId == scriptId }) {
                    self.terminals[terminalIndex].outputText += output
                    self.terminals[terminalIndex].isWaitingForInput =
                        self.coordinator?.isWaitingForInput(scriptId: scriptId) ?? false
                } else {
                    let newTerminal = TerminalTab(
                        id: UUID(),
                        scriptId: scriptId,
                        outputText: output,
                        terminalInput: "",
                        isWaitingForInput: false
                    )
                    self.terminals.append(newTerminal)
                    self.selectedTerminalIndex = self.terminals.count - 1
                }
            }
            .store(in: &cancellables)
    }
    
    func addNewTerminal() {
        let newTerminal = TerminalTab.createDefault()
        terminals.append(newTerminal)
        selectedTerminalIndex = terminals.count - 1
    }
    
    func closeTerminal(at index: Int) {
        guard terminals.indices.contains(index) else { return }
        let terminal = terminals[index]
        
        if let scriptId = terminal.scriptId,
           let script = coordinator?.scripts.first(where: { $0.id == scriptId }) {
            coordinator?.stopScript(script)
        }
        
        terminals.remove(at: index)
        
        if terminals.isEmpty {
            addNewTerminal()
        }
        
        selectedTerminalIndex = min(selectedTerminalIndex, terminals.count - 1)
    }
    
    func handleTerminalInput() {
        guard terminals.indices.contains(selectedTerminalIndex) else { return }
        let terminal = terminals[selectedTerminalIndex]
        
        guard let scriptId = terminal.scriptId else {
            handleGeneralCommand(terminalInput: terminal.terminalInput)
            return
        }
        
        if coordinator?.isWaitingForInput(scriptId: scriptId) ?? false {
            coordinator?.sendInput(scriptId, terminal.terminalInput)
            terminals[selectedTerminalIndex].terminalInput = ""
        } else {
            handleGeneralCommand(terminalInput: terminal.terminalInput)
        }
    }
    
    private func handleGeneralCommand(terminalInput: String) {
        let command = terminalInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedCommand = command.lowercased()
        let components = command.split(separator: " ", maxSplits: 1).map(String.init)
        
        switch lowercasedCommand {
        case "help":
            appendOutput("""
                
                Available Commands:
                - help: Show this help message
                - clear: Clear the terminal output
                - list: List all scripts
                - run [script_name]: Run the specified script
                - stop: Stop the currently running script
                
                """)
        case "clear":
            terminals[selectedTerminalIndex].outputText = ""
        case "list":
            let scriptList = coordinator?.scripts.map(\.name).joined(separator: "\n") ?? ""
            appendOutput("\nScripts:\n\(scriptList)\n")
        case "stop":
            handleStopCommand()
        default:
            if lowercasedCommand.starts(with: "run ") && components.count == 2 {
                handleRunCommand(scriptName: components[1])
            } else {
                appendOutput("\nUnknown command: \(terminalInput)\n")
            }
        }
        
        terminals[selectedTerminalIndex].terminalInput = ""
    }
    
    private func handleStopCommand() {
        guard terminals.indices.contains(selectedTerminalIndex) else { return }
        let terminal = terminals[selectedTerminalIndex]
        
        guard let scriptId = terminal.scriptId,
              let script = coordinator?.scripts.first(where: { $0.id == scriptId }),
              script.isRunning else {
            appendOutput("\nNo running script to stop.\n")
            return
        }
        
        coordinator?.stopScript(script)
        appendOutput("\nStopping script: \(script.name)\n")
    }
    
    private func handleRunCommand(scriptName: String) {
        guard let script = coordinator?.scripts.first(where: {
            $0.name.lowercased() == scriptName.lowercased()
        }) else {
            appendOutput("\nScript '\(scriptName)' not found.\n")
            return
        }
        
        if script.isRunning {
            appendOutput("\nScript '\(script.name)' is already running.\n")
            return
        }
        
        terminals[selectedTerminalIndex].scriptId = script.id
        appendOutput("Starting script: \(script.name)\n")
        
        do {
            let process = coordinator?.runScript(script)
            try process?.run()
            appendOutput("Script '\(script.name)' is now running.\n")
        } catch {
            appendOutput("Error running script: \(error.localizedDescription)\n")
        }
    }
    
    private func appendOutput(_ text: String) {
        terminals[selectedTerminalIndex].outputText += text
    }
}
