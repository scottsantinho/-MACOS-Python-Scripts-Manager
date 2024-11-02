// MARK: - Services/ScriptStorageService.swift
import Foundation

class ScriptStorageService: ScriptStorable {
    private let saveKey = "savedScripts"
    
    func loadScripts() -> [Script] {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Script].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func saveScripts(_ scripts: [Script]) {
        let scriptsToSave = scripts.map { script -> Script in
            Script(
                id: script.id,
                path: script.path,
                name: script.name,
                lastRun: script.lastRun,
                schedule: script.schedule
            )
        }
        
        if let encoded = try? JSONEncoder().encode(scriptsToSave) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func addScript(path: String) -> Script {
        return Script(path: path)
    }
    
    func removeScript(_ script: Script) {
        // No-op as actual removal happens in ScriptManager
        // This is just a protocol conformance
    }
}
