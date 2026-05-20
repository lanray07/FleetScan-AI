import Foundation
import SwiftData

@Model
final class Vehicle {
    @Attribute(.unique) var id: UUID
    var name: String
    var registrationNumber: String
    var vehicleType: VehicleType
    var mileage: Int
    var motExpiryDate: Date?
    var insuranceExpiryDate: Date?
    var serviceDueDate: Date?
    var notes: String
    var isRoadworthy: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        registrationNumber: String,
        vehicleType: VehicleType,
        mileage: Int = 0,
        motExpiryDate: Date? = nil,
        insuranceExpiryDate: Date? = nil,
        serviceDueDate: Date? = nil,
        notes: String = "",
        isRoadworthy: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.registrationNumber = registrationNumber
        self.vehicleType = vehicleType
        self.mileage = mileage
        self.motExpiryDate = motExpiryDate
        self.insuranceExpiryDate = insuranceExpiryDate
        self.serviceDueDate = serviceDueDate
        self.notes = notes
        self.isRoadworthy = isRoadworthy
        self.createdAt = createdAt
    }
}

@Model
final class VehicleInspection {
    @Attribute(.unique) var id: UUID
    var vehicleId: UUID
    var inspectionType: InspectionType
    var date: Date
    var status: InspectionStatus
    var mileage: Int
    var driverName: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        inspectionType: InspectionType = .dailyWalkaround,
        date: Date = Date(),
        status: InspectionStatus = .draft,
        mileage: Int = 0,
        driverName: String = "",
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.inspectionType = inspectionType
        self.date = date
        self.status = status
        self.mileage = mileage
        self.driverName = driverName
        self.notes = notes
        self.createdAt = createdAt
    }
}

@Model
final class ChecklistItem {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    var title: String
    var category: ChecklistCategory
    var passed: Bool?
    var notes: String
    var severity: Severity

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        title: String,
        category: ChecklistCategory,
        passed: Bool? = nil,
        notes: String = "",
        severity: Severity = .none
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.title = title
        self.category = category
        self.passed = passed
        self.notes = notes
        self.severity = severity
    }
}

@Model
final class VehiclePhoto {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    var checklistItemId: UUID?
    @Attribute(.externalStorage) var imageData: Data?
    var localImageURL: String?
    var caption: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        checklistItemId: UUID? = nil,
        imageData: Data? = nil,
        localImageURL: String? = nil,
        caption: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.checklistItemId = checklistItemId
        self.imageData = imageData
        self.localImageURL = localImageURL
        self.caption = caption
        self.createdAt = createdAt
    }
}

@Model
final class Defect {
    @Attribute(.unique) var id: UUID
    var vehicleId: UUID
    var inspectionId: UUID?
    var photoId: UUID?
    var title: String
    var defectDescription: String
    var category: DefectCategory
    var severity: Severity
    var confidence: Double
    var suggestedAction: String
    var status: DefectStatus
    var userApproved: Bool
    var repairPriority: Severity
    var repairNotes: String
    @Attribute(.externalStorage) var beforeRepairPhotoData: Data?
    @Attribute(.externalStorage) var afterRepairPhotoData: Data?
    var createdAt: Date
    var resolvedAt: Date?

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        inspectionId: UUID? = nil,
        photoId: UUID? = nil,
        title: String,
        description: String,
        category: DefectCategory,
        severity: Severity,
        confidence: Double = 0,
        suggestedAction: String = "",
        status: DefectStatus = .open,
        userApproved: Bool = false,
        repairPriority: Severity? = nil,
        repairNotes: String = "",
        beforeRepairPhotoData: Data? = nil,
        afterRepairPhotoData: Data? = nil,
        createdAt: Date = Date(),
        resolvedAt: Date? = nil
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.inspectionId = inspectionId
        self.photoId = photoId
        self.title = title
        self.defectDescription = description
        self.category = category
        self.severity = severity
        self.confidence = confidence
        self.suggestedAction = suggestedAction
        self.status = status
        self.userApproved = userApproved
        self.repairPriority = repairPriority ?? severity
        self.repairNotes = repairNotes
        self.beforeRepairPhotoData = beforeRepairPhotoData
        self.afterRepairPhotoData = afterRepairPhotoData
        self.createdAt = createdAt
        self.resolvedAt = resolvedAt
    }
}

@Model
final class MaintenanceReminder {
    @Attribute(.unique) var id: UUID
    var vehicleId: UUID
    var title: String
    var category: MaintenanceCategory
    var dueDate: Date
    var completed: Bool

    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        title: String,
        category: MaintenanceCategory,
        dueDate: Date,
        completed: Bool = false
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.title = title
        self.category = category
        self.dueDate = dueDate
        self.completed = completed
    }
}

@Model
final class InspectionReport {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    var title: String
    var summary: String
    var pdfLocalURL: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        title: String,
        summary: String,
        pdfLocalURL: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.title = title
        self.summary = summary
        self.pdfLocalURL = pdfLocalURL
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var plan: SubscriptionPlan
    var isActive: Bool
    var renewsAt: Date?

    init(
        id: UUID = UUID(),
        plan: SubscriptionPlan = .free,
        isActive: Bool = false,
        renewsAt: Date? = nil
    ) {
        self.id = id
        self.plan = plan
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}
