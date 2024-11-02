// MARK: - Views/Main/TerminalView.swift
import SwiftUI

struct TerminalView: View {
    @ObservedObject var viewModel: TerminalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TerminalTabBar(
                terminals: $viewModel.terminals,
                selectedIndex: $viewModel.selectedTerminalIndex,
                onClose: viewModel.closeTerminal,
                onAdd: viewModel.addNewTerminal
            )
            
            if viewModel.currentTerminal != nil {
                VStack(spacing: 0) {
                    TerminalOutputView(text: viewModel.currentTerminal?.outputText ?? "")
                    TerminalInputView(
                        terminal: Binding(
                            get: { viewModel.terminals[viewModel.selectedTerminalIndex] },
                            set: { viewModel.terminals[viewModel.selectedTerminalIndex] = $0 }
                        ),
                        onSubmit: viewModel.handleTerminalInput
                    )
                }
            }
        }
    }
}
