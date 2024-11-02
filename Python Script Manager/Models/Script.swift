// MARK: - Models/Script.swift
import Foundation
import Combine

class Script: Codable, Identifiable, ObservableObject {
    let id: UUID
    var path: String
    var name: String
    @Published var isRunning: Bool = false
    var lastRun: Date?
    @Published var schedule: ScriptSchedule
    
    private var cancellables = Set<AnyCancellable>()
    
    enum CodingKeys: String, CodingKey {
        case id, path, name, lastRun, schedule
    }
    
    init(id: UUID = UUID(), path: String, name: String? = nil, lastRun: Date? = nil, schedule: ScriptSchedule = .defaultSchedule) {
        self.id = id
        self.path = path
        self.name = name ?? (URL(fileURLWithPath: path).lastPathComponent)
        self.lastRun = lastRun
        self.schedule = schedule
        
        schedule.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        path = try container.decode(String.self, forKey: .path)
        name = try container.decode(String.self, forKey: .name)
        lastRun = try container.decodeIfPresent(Date.self, forKey: .lastRun)
        schedule = try container.decode(ScriptSchedule.self, forKey: .schedule)
        
        schedule.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(path, forKey: .path)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(lastRun, forKey: .lastRun)
        try container.encode(schedule, forKey: .schedule)
    }
}
