// MARK: - Utils/Constants.swift
import Foundation
import AppKit

enum Constants {
    enum NotificationNames {
        static let scriptDidStart = "ScriptDidStart"
        static let scriptOutputUpdated = "ScriptOutputUpdated"
        static let addScript = "AddScript"
    }
    
    enum UserDefaults {
        static let savedScriptsKey = "savedScripts"
    }
    
    enum Keystrokes {
        static let controlC = (keyCode: 8, modifierFlags: NSEvent.ModifierFlags.control)
    }
}
