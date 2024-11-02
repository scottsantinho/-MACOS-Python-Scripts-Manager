// MARK: - Views/Components/TerminalTabBar.swift
import SwiftUI

struct TerminalTabBar: View {
    @Binding var terminals: [TerminalTab]
    @Binding var selectedIndex: Int
    let onClose: (Int) -> Void
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(terminals.indices, id: \.self) { index in
                tabView(for: terminals[index], at: index)
            }
            
            addButton
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
        .background(Color(.windowBackgroundColor))
    }
    
    private func tabView(for terminal: TerminalTab, at index: Int) -> some View {
        HStack {
            if let scriptId = terminal.scriptId,
               let script = getScript(for: scriptId) {
                Text(script.name)
                    .font(.system(.body, design: .monospaced))
            } else {
                Text("Terminal \(index + 1)")
                    .font(.system(.body, design: .monospaced))
            }
            
            if terminals.count > 1 {
                Button(action: {
                    onClose(index)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                }
                .buttonStyle(.plain)
                .opacity(index == 0 ? 0 : 1)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(selectedIndex == index ? Color(.selectedTextBackgroundColor) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onTapGesture {
            selectedIndex = index
        }
    }
    
    private var addButton: some View {
        Button(action: onAdd) {
            Image(systemName: "plus")
                .font(.system(size: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }
    
    private func getScript(for id: UUID) -> Script? {
        // This should be provided by a ViewModel in practice
        return nil
    }
}
