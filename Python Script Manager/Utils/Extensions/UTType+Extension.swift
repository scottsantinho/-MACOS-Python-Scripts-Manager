// MARK: - Utils/Extensions/UTType+Extension.swift
import UniformTypeIdentifiers

extension UTType {
    static var pythonScript: UTType {
        UTType(tag: "py",
               tagClass: .filenameExtension,
               conformingTo: .sourceCode) ?? .plainText
    }
}
