// MARK: - App/AppDelegate.swift
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup any required initial configuration
        setupMenuBar()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up any resources before termination
        if let window = NSApplication.shared.windows.first,
           let contentView = window.contentView,
           let hostingView = contentView.window?.windowController?.contentViewController as? NSHostingController<ContentView> {
            // Access the coordinator directly
            let coordinator = hostingView.rootView.appState.scriptCoordinator
            coordinator.executionService.cleanupAllProcesses()
            coordinator.schedulerService.cancelAllSchedules()
        }
    }
    
    private func setupMenuBar() {
        // Create Edit menu for text editing support in terminal
        let editMenu = NSMenuItem()
        editMenu.submenu = NSMenu(title: "Edit")
        
        let cutItem = NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        let copyItem = NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        let pasteItem = NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        let selectAllItem = NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        
        editMenu.submenu?.addItem(cutItem)
        editMenu.submenu?.addItem(copyItem)
        editMenu.submenu?.addItem(pasteItem)
        editMenu.submenu?.addItem(NSMenuItem.separator())
        editMenu.submenu?.addItem(selectAllItem)
        
        NSApplication.shared.mainMenu?.addItem(editMenu)
    }
}
