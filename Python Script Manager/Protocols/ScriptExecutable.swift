// MARK: - Protocols/ScriptExecutable.swift
import Foundation

protocol ScriptExecutable {
    func runScript(_ script: Script) -> Process
    func stopScript(_ script: Script)
    func sendInput(_ scriptId: UUID, _ input: String)
    func isWaitingForInput(scriptId: UUID) -> Bool
    func getOutput(for scriptId: UUID) -> String
    func observeScriptOutput(_ scriptId: UUID) -> AsyncStream<String>
}
