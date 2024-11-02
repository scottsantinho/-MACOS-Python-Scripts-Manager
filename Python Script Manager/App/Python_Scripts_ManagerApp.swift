// MARK: - App/Python_Scripts_ManagerApp.swift
import SwiftUI
import AppKit
import UniformTypeIdentifiers

@main
struct Python_Scripts_ManagerApp: App {
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .environmentObject(appState)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add Script Reference") {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    panel.allowedContentTypes = [UTType.pythonScript]
                    
                    panel.begin { response in
                        if response == .OK, let url = panel.url {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("AddScript"),
                                object: nil,
                                userInfo: ["path": url.path]
                            )
                        }
                    }
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
