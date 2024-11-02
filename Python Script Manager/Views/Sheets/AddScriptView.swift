// AddScriptView.swift
import SwiftUI
import UniformTypeIdentifiers

struct AddScriptView: View {
    @Environment(\.dismiss) private var dismiss
    let coordinator: ScriptCoordinatorService  // Updated from scriptManager
    
    @State private var selectedPath: String = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Script")
                .font(.headline)
            
            Button("Choose Script File") {
                showFilePicker()
            }
            
            if !selectedPath.isEmpty {
                Text("Selected: \(selectedPath)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Add") {
                    addScript()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: 200)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func showFilePicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.pythonScript]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                selectedPath = url.path
            }
        }
    }
    
    private func addScript() {
            if selectedPath.isEmpty {
                errorMessage = "Please select a script file."
                showErrorAlert = true
            } else {
                coordinator.addScript(path: selectedPath)  // Updated from scriptManager
                dismiss()
        }
    }
}
