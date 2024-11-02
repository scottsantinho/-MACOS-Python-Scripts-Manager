// MARK: - Utils/Helpers/ProcessHelper.swift
import Foundation

enum ProcessHelper {
    static func getPythonPath() -> String {
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
    
    static func setupEnvironment() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        env["PYTHONUNBUFFERED"] = "1"
        env["PYTHONIOENCODING"] = "utf-8"
        return env
    }
    
    static func forceKillProcess(_ process: Process) {
        if process.isRunning {
            kill(process.processIdentifier, SIGKILL)
        }
    }
}
