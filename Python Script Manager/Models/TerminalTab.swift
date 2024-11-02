// MARK: - Models/TerminalTab.swift
import Foundation

struct TerminalTab: Identifiable {
    let id: UUID
    var scriptId: UUID?
    var outputText: String
    var terminalInput: String
    var isWaitingForInput: Bool
    
    static func createDefault() -> TerminalTab {
        TerminalTab(
            id: UUID(),
            scriptId: nil,
            outputText: """
            Welcome to Python Script Manager
            Type 'help' for available commands
            
            """,
            terminalInput: "",
            isWaitingForInput: false
        )
    }
}
