// MARK: - Models/ScriptSchedule.swift
import Foundation

class ScriptSchedule: Codable, ObservableObject {
    enum Frequency: String, Codable, CaseIterable {
        case once = "Once"
        case daily = "Daily"
        case weekly = "Weekly"
    }
    
    @Published var isEnabled: Bool
    @Published var frequency: Frequency
    @Published var selectedDays: Set<Int>
    @Published var hour: Int
    @Published var minute: Int
    @Published var nextRun: Date?
    
    static let defaultSchedule = ScriptSchedule(
        isEnabled: false,
        frequency: .daily,
        selectedDays: Set<Int>(),
        hour: 0,
        minute: 0,
        nextRun: nil
    )
    
    enum CodingKeys: String, CodingKey {
        case isEnabled, frequency, selectedDays, hour, minute, nextRun
    }
    
    init(isEnabled: Bool, frequency: Frequency, selectedDays: Set<Int>, hour: Int, minute: Int, nextRun: Date?) {
        self.isEnabled = isEnabled
        self.frequency = frequency
        self.selectedDays = selectedDays
        self.hour = hour
        self.minute = minute
        self.nextRun = nextRun
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        frequency = try container.decode(Frequency.self, forKey: .frequency)
        selectedDays = try container.decode(Set<Int>.self, forKey: .selectedDays)
        hour = try container.decode(Int.self, forKey: .hour)
        minute = try container.decode(Int.self, forKey: .minute)
        nextRun = try container.decodeIfPresent(Date.self, forKey: .nextRun)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(selectedDays, forKey: .selectedDays)
        try container.encode(hour, forKey: .hour)
        try container.encode(minute, forKey: .minute)
        try container.encodeIfPresent(nextRun, forKey: .nextRun)
    }
    
    func calculateNextRun(from date: Date = Date()) -> Date? {
        guard isEnabled else { return nil }
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        guard var nextDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) else { return nil }
        
        if nextDate <= date {
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: nextDate) else { return nil }
            nextDate = tomorrow
        }
        
        switch frequency {
        case .once:
            return nextDate
            
        case .daily:
            return nextDate
            
        case .weekly:
            var attempts = 0
            let maxAttempts = 7
            
            while !selectedDays.contains(calendar.component(.weekday, from: nextDate)) {
                attempts += 1
                if attempts > maxAttempts { return nil }
                
                guard let newDate = calendar.date(byAdding: .day, value: 1, to: nextDate) else { return nil }
                nextDate = newDate
            }
            return nextDate
        }
    }
}
