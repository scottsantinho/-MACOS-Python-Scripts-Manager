// MARK: - Views/Components/TerminalOutputView.swift
import SwiftUI

struct TerminalOutputView: View {
    let text: String
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .id("output")
                    .onChange(of: text) { _, _ in
                        withAnimation {
                            proxy.scrollTo("output", anchor: .bottom)
                        }
                    }
            }
        }
        .background(Color(.textBackgroundColor))
    }
}
