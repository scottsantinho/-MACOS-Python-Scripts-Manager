// MARK: - Views/Components/TerminalInputView.swift
import SwiftUI

struct TerminalInputView: View {
    @Binding var terminal: TerminalTab
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            if terminal.isWaitingForInput {
                Image(systemName: "arrow.right")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "terminal")
                    .foregroundColor(.secondary)
            }
            
            TerminalInputField(
                text: Binding(
                    get: { terminal.terminalInput },
                    set: { terminal.terminalInput = $0 }
                ),
                onSubmit: onSubmit
            )
            .frame(height: 24)
        }
        .padding()
        .background(Color(.textBackgroundColor))
    }
}
