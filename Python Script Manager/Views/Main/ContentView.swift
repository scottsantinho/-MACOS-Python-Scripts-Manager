// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var scriptListVM = ScriptListViewModel()
    @StateObject private var terminalVM = TerminalViewModel()
    // Make appState accessible to the AppDelegate
    var appState: AppState
    
    @State private var keyboardMonitor: Any?
    @State private var isAddScriptSheetPresented = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(isAddScriptSheetPresented: $isAddScriptSheetPresented)
            ScriptListView(viewModel: scriptListVM)
            TerminalView(viewModel: terminalVM)
        }
        .frame(minWidth: 600, minHeight: 400)
        .sheet(isPresented: $isAddScriptSheetPresented) {
            AddScriptView(coordinator: appState.scriptCoordinator)
        }
        .onAppear {
            scriptListVM.updateScriptCoordinator(appState.scriptCoordinator)
            terminalVM.updateScriptCoordinator(appState.scriptCoordinator)
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
    }
    
    private func setupKeyboardMonitor() {
        keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == Constants.Keystrokes.controlC.keyCode &&
               event.modifierFlags.contains(Constants.Keystrokes.controlC.modifierFlags) {
                if let terminal = terminalVM.currentTerminal,
                   let scriptId = terminal.scriptId,
                   let script = scriptListVM.scripts.first(where: { $0.id == scriptId }) {
                    scriptListVM.stopScript(script)
                    return nil
                }
            }
            return event
        }
    }
    
    private func removeKeyboardMonitor() {
        if let monitor = keyboardMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
