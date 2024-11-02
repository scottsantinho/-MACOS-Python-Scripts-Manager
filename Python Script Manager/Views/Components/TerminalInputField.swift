// MARK: - Views/Components/TerminalInputField.swift
import SwiftUI
import AppKit

struct TerminalInputField: NSViewRepresentable {
    @Binding var text: String
    var onSubmit: () -> Void
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.placeholderString = "Enter command..."
        textField.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textField.focusRingType = .none
        textField.isBordered = false
        textField.drawsBackground = false
        textField.stringValue = text
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if text != nsView.stringValue {
            nsView.stringValue = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: TerminalInputField
        
        init(_ parent: TerminalInputField) {
            self.parent = parent
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                parent.text = control.stringValue
                parent.onSubmit()
                control.stringValue = ""
                return true
            }
            return false
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            parent.text = textField.stringValue
        }
    }
}
