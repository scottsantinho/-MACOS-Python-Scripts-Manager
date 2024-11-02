// MARK: - Protocols/ScriptStorable.swift
import Foundation

protocol ScriptStorable {
    func loadScripts() -> [Script]
    func saveScripts(_ scripts: [Script])
    func addScript(path: String) -> Script
    func removeScript(_ script: Script)
}
