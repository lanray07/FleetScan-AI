import Foundation

enum FleetFormatters {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static func dueText(for date: Date) -> String {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let dueDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startOfToday, to: dueDay).day ?? 0

        if days < 0 { return "Overdue by \(abs(days))d" }
        if days == 0 { return "Due today" }
        if days == 1 { return "Due tomorrow" }
        return "Due in \(days)d"
    }

    static func monthKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)"
    }
}

extension Date {
    var isWithinNextThirtyDays: Bool {
        let now = Date()
        let limit = Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now
        return self >= now && self <= limit
    }

    var isOverdue: Bool {
        self < Calendar.current.startOfDay(for: Date())
    }
}
