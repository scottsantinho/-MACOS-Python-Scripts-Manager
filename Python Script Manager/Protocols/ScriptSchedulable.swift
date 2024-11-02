// MARK: - Protocols/ScriptSchedulable.swift
import Foundation

protocol ScriptSchedulable {
    func scheduleScript(_ script: Script)
    func cancelSchedule(for scriptId: UUID)
    func cancelAllSchedules()
}
