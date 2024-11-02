// MARK: - Views/Main/HeaderView.swift
import SwiftUI

struct HeaderView: View {
    @Binding var isAddScriptSheetPresented: Bool
    
    // Custom monospaced font for the coding vibe
    private let coderFont = Font.system(.body, design: .monospaced)
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Created by Scott Santinho")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.secondary)
            
            HStack {
                Spacer()
                Text("Python Script Manager")
                    .font(.system(size: 28, design: .monospaced))
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack {
                Spacer()
                Button(action: {
                    isAddScriptSheetPresented = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Script")
                            .font(coderFont)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
