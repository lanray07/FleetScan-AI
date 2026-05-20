import SwiftUI
import UIKit

struct SeverityBadge: View {
    let severity: Severity

    var body: some View {
        Text(severity.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(foreground)
            .background(background, in: Capsule())
            .accessibilityLabel("Severity \(severity.displayName)")
    }

    private var background: Color {
        switch severity {
        case .none: Color(.systemGray5)
        case .low: Color.green.opacity(0.14)
        case .medium: Color.yellow.opacity(0.22)
        case .high: Color.orange.opacity(0.18)
        case .critical: Color.red.opacity(0.18)
        }
    }

    private var foreground: Color {
        switch severity {
        case .none: Color.secondary
        case .low: Color.green
        case .medium: Color.orange
        case .high: Color.orange
        case .critical: Color.red
        }
    }
}

struct VehicleCard: View {
    let vehicle: Vehicle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: vehicle.vehicleType.iconName)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 42, height: 42)
                    .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(vehicle.name)
                        .font(.headline)
                    Text(vehicle.registrationNumber.isEmpty ? "No registration" : vehicle.registrationNumber)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label(vehicle.isRoadworthy ? "Roadworthy" : "Not roadworthy", systemImage: vehicle.isRoadworthy ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(vehicle.isRoadworthy ? .green : .red)
                    .labelStyle(.iconOnly)
                    .accessibilityLabel(vehicle.isRoadworthy ? "Roadworthy" : "Not roadworthy")
            }

            HStack {
                Label(vehicle.vehicleType.displayName, systemImage: "tag")
                Spacer()
                Label("\(vehicle.mileage) mi", systemImage: "gauge.with.dots.needle.bottom.50percent")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct InspectionCard: View {
    let inspection: VehicleInspection
    let vehicleName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(vehicleName)
                        .font(.headline)
                    Text(inspection.inspectionType.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(inspection.status.displayName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .foregroundStyle(statusColor)
                    .background(statusColor.opacity(0.12), in: Capsule())
            }

            HStack {
                Label(FleetFormatters.shortDateTime.string(from: inspection.date), systemImage: "calendar")
                Spacer()
                Label("\(inspection.mileage) mi", systemImage: "gauge")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }

    private var statusColor: Color {
        switch inspection.status {
        case .draft: .secondary
        case .passed: .green
        case .failed: .red
        case .submitted: .blue
        }
    }
}

struct ChecklistRow: View {
    let item: ChecklistItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 34, height: 34)
                .background(iconColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.headline)
                Text(item.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            SeverityBadge(severity: item.severity)
        }
        .padding(.vertical, 4)
    }

    private var icon: String {
        if item.passed == true { return "checkmark.circle.fill" }
        if item.passed == false { return "xmark.octagon.fill" }
        return "circle.dashed"
    }

    private var iconColor: Color {
        if item.passed == true { return .green }
        if item.passed == false { return .red }
        return .secondary
    }
}

struct DefectCard: View {
    let defect: Defect

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(defect.title)
                        .font(.headline)
                    Text(defect.category.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                SeverityBadge(severity: defect.severity)
            }

            Text(defect.defectDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack {
                Label(defect.status.displayName, systemImage: defect.status == .resolved ? "checkmark.seal" : "wrench.and.screwdriver")
                Spacer()
                Text("AI \(Int(defect.confidence * 100))%")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct MaintenanceReminderCard: View {
    let reminder: MaintenanceReminder
    let vehicleName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.completed ? "checkmark.circle.fill" : reminder.dueDate.isOverdue ? "exclamationmark.triangle.fill" : "bell.badge")
                .font(.title3)
                .foregroundStyle(reminder.completed ? .green : reminder.dueDate.isOverdue ? .red : .blue)
                .frame(width: 36, height: 36)
                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(reminder.title)
                    .font(.headline)
                Text("\(vehicleName) - \(reminder.category.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(reminder.completed ? "Done" : FleetFormatters.dueText(for: reminder.dueDate))
                .font(.caption.weight(.semibold))
                .foregroundStyle(reminder.dueDate.isOverdue && !reminder.completed ? .red : .secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ReportPreviewView: View {
    let report: InspectionReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "doc.richtext")
                    .foregroundStyle(.blue)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.title)
                        .font(.headline)
                    Text(FleetFormatters.shortDateTime.string(from: report.createdAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: report.pdfLocalURL == nil ? "doc.badge.clock" : "square.and.arrow.up")
                    .foregroundStyle(.secondary)
            }

            Text(report.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct UpgradeBanner: View {
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 34, height: 34)
                .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 38))
                .foregroundStyle(.blue)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

struct PhotoThumbnail: View {
    let data: Data

    var body: some View {
        if let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(height: 150)
                .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
        }
    }
}
