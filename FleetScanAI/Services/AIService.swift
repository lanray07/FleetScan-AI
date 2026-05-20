import Foundation
import SwiftUI

struct AIScanRequest: Codable {
    var vehicleType: String
    var inspectionType: String
    var checklistItem: String
    var userNotes: String
    var imageBase64: String
}

struct AIDefectSuggestion: Codable, Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let category: DefectCategory
    let severity: Severity
    let confidence: Double
    let suggestedAction: String

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case category
        case severity
        case confidence
        case suggestedAction
    }
}

struct AIScanResponse: Codable {
    let defects: [AIDefectSuggestion]
    let summary: String
}

protocol AIService {
    func scanVehiclePhoto(request: AIScanRequest) async throws -> AIScanResponse
    func generateInspectionSummary(
        vehicle: Vehicle,
        inspection: VehicleInspection,
        items: [ChecklistItem],
        defects: [Defect]
    ) async throws -> String
    func generateDefectPriorityList(defects: [Defect]) async throws -> [Defect]
    func generateReportText(
        vehicle: Vehicle,
        inspection: VehicleInspection,
        items: [ChecklistItem],
        defects: [Defect]
    ) async throws -> String
}

struct MockAIService: AIService {
    func scanVehiclePhoto(request: AIScanRequest) async throws -> AIScanResponse {
        try await Task.sleep(for: .milliseconds(450))

        let lowerNotes = request.userNotes.lowercased()
        let lowerItem = request.checklistItem.lowercased()
        let severity: Severity = lowerNotes.contains("crack") || lowerNotes.contains("leak") || lowerNotes.contains("warning") ? .high : .medium
        let category = categoryFor(checklistItem: lowerItem, notes: lowerNotes)
        let title = titleFor(category: category, checklistItem: request.checklistItem)

        let suggestion = AIDefectSuggestion(
            title: title,
            description: "Possible visible issue around \(request.checklistItem.lowercased()). Review the photo and notes before recording this as a confirmed defect.",
            category: category,
            severity: severity,
            confidence: lowerNotes.isEmpty ? 0.62 : 0.78,
            suggestedAction: actionFor(severity: severity)
        )

        return AIScanResponse(
            defects: [suggestion],
            summary: "Mock AI reviewed the submitted photo and produced cautious, non-diagnostic suggestions for manager review."
        )
    }

    func generateInspectionSummary(
        vehicle: Vehicle,
        inspection: VehicleInspection,
        items: [ChecklistItem],
        defects: [Defect]
    ) async throws -> String {
        let failedCount = items.filter { $0.passed == false }.count
        let openDefects = defects.filter { $0.status != .resolved }.count
        let topSeverity = defects.map(\.severity).max() ?? .none
        return "\(vehicle.name) inspection completed with \(failedCount) failed checklist item(s), \(openDefects) open defect(s), and highest severity \(topSeverity.displayName.lowercased()). AI findings are suggestions only and require review."
    }

    func generateDefectPriorityList(defects: [Defect]) async throws -> [Defect] {
        defects.sorted {
            if $0.severity == $1.severity {
                return $0.createdAt < $1.createdAt
            }
            return $0.severity > $1.severity
        }
    }

    func generateReportText(
        vehicle: Vehicle,
        inspection: VehicleInspection,
        items: [ChecklistItem],
        defects: [Defect]
    ) async throws -> String {
        try await generateInspectionSummary(vehicle: vehicle, inspection: inspection, items: items, defects: defects)
    }

    private func categoryFor(checklistItem: String, notes: String) -> DefectCategory {
        if checklistItem.contains("tyre") { return .tyreDamage }
        if checklistItem.contains("light") { return .lightDamage }
        if checklistItem.contains("windscreen") || notes.contains("crack") { return .windscreenCrack }
        if checklistItem.contains("mirror") { return .mirrorDamage }
        if checklistItem.contains("leak") || notes.contains("fluid") { return .fluidLeak }
        if checklistItem.contains("brake") { return .brakeWarning }
        if checklistItem.contains("dashboard") || notes.contains("warning") { return .dashboardWarning }
        if checklistItem.contains("load") { return .loadSecurityIssue }
        if checklistItem.contains("trailer") { return .trailerIssue }
        if checklistItem.contains("body") { return .bodyDamage }
        return .generalWear
    }

    private func titleFor(category: DefectCategory, checklistItem: String) -> String {
        switch category {
        case .tyreDamage: "Possible tyre damage"
        case .lightDamage: "Possible light damage"
        case .bodyDamage: "Possible body damage"
        case .windscreenCrack: "Possible windscreen crack"
        case .mirrorDamage: "Possible mirror damage"
        case .fluidLeak: "Possible fluid leak"
        case .brakeWarning: "Possible brake warning"
        case .dashboardWarning: "Possible dashboard warning"
        case .loadSecurityIssue: "Possible load security issue"
        case .trailerIssue: "Possible trailer issue"
        case .generalWear: "Possible general wear"
        }
    }

    private func actionFor(severity: Severity) -> String {
        switch severity {
        case .critical:
            "Do not drive until reviewed by a qualified professional."
        case .high:
            "Escalate for immediate review before the next route."
        case .medium:
            "Schedule repair review and monitor before use."
        case .low:
            "Record and monitor at the next inspection."
        case .none:
            "No immediate action suggested by mock AI."
        }
    }
}

struct RemoteAIService: AIService {
    var endpoint: URL

    init(endpoint: URL = URL(string: AppConstants.backendEndpoint) ?? URL(string: "https://example.com/fleet-scan-ai")!) {
        self.endpoint = endpoint
    }

    func scanVehiclePhoto(request: AIScanRequest) async throws -> AIScanResponse {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw AIServiceError.invalidResponse
        }
        return try JSONDecoder().decode(AIScanResponse.self, from: data)
    }

    func generateInspectionSummary(
        vehicle: Vehicle,
        inspection: VehicleInspection,
        items: [ChecklistItem],
        defects: [Defect]
    ) async throws -> String {
        "Remote summary endpoint placeholder. Configure your secure backend to generate fleet inspection summaries."
    }

    func generateDefectPriorityList(defects: [Defect]) async throws -> [Defect] {
        defects.sorted { $0.severity > $1.severity }
    }

    func generateReportText(
        vehicle: Vehicle,
        inspection: VehicleInspection,
        items: [ChecklistItem],
        defects: [Defect]
    ) async throws -> String {
        try await generateInspectionSummary(vehicle: vehicle, inspection: inspection, items: items, defects: defects)
    }
}

enum AIServiceError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "The AI endpoint returned an invalid response."
        }
    }
}

private struct AIServiceKey: EnvironmentKey {
    static let defaultValue: any AIService = MockAIService()
}

extension EnvironmentValues {
    var aiService: any AIService {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}
