import Foundation

enum UserType: String, Codable, CaseIterable, Identifiable {
    case driver
    case fleetManager
    case courierBusiness
    case contractor
    case logisticsCompany
    case fieldServiceBusiness

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .driver: "Driver"
        case .fleetManager: "Fleet manager"
        case .courierBusiness: "Courier business"
        case .contractor: "Contractor"
        case .logisticsCompany: "Logistics company"
        case .fieldServiceBusiness: "Field service business"
        }
    }
}

enum VehicleType: String, Codable, CaseIterable, Identifiable {
    case van
    case car
    case lorry
    case truck
    case pickup
    case motorcycle
    case trailer

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .van: "Van"
        case .car: "Car"
        case .lorry: "Lorry"
        case .truck: "Truck"
        case .pickup: "Pickup"
        case .motorcycle: "Motorcycle"
        case .trailer: "Trailer"
        }
    }

    var iconName: String {
        switch self {
        case .car: "car"
        case .motorcycle: "motorcycle"
        case .trailer: "rectangle.connected.to.line.below"
        default: "box.truck"
        }
    }
}

enum InspectionType: String, Codable, CaseIterable, Identifiable {
    case dailyWalkaround
    case maintenance
    case repairFollowUp

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dailyWalkaround: "Daily walkaround"
        case .maintenance: "Maintenance"
        case .repairFollowUp: "Repair follow-up"
        }
    }
}

enum InspectionStatus: String, Codable, CaseIterable, Identifiable {
    case draft
    case passed
    case failed
    case submitted

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .draft: "Draft"
        case .passed: "Passed"
        case .failed: "Failed"
        case .submitted: "Submitted"
        }
    }
}

enum ChecklistCategory: String, Codable, CaseIterable, Identifiable {
    case tyres
    case lights
    case brakes
    case mirrors
    case glass
    case body
    case fluids
    case controls
    case safety
    case load
    case dashboard
    case trailer

    var id: String { rawValue }

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

enum Severity: String, Codable, CaseIterable, Identifiable, Comparable {
    case none
    case low
    case medium
    case high
    case critical

    var id: String { rawValue }

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var rank: Int {
        switch self {
        case .none: 0
        case .low: 1
        case .medium: 2
        case .high: 3
        case .critical: 4
        }
    }

    static func < (lhs: Severity, rhs: Severity) -> Bool {
        lhs.rank < rhs.rank
    }
}

enum DefectCategory: String, Codable, CaseIterable, Identifiable {
    case tyreDamage
    case lightDamage
    case bodyDamage
    case windscreenCrack
    case mirrorDamage
    case fluidLeak
    case brakeWarning
    case dashboardWarning
    case loadSecurityIssue
    case trailerIssue
    case generalWear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tyreDamage: "Tyre damage"
        case .lightDamage: "Light damage"
        case .bodyDamage: "Body damage"
        case .windscreenCrack: "Windscreen crack"
        case .mirrorDamage: "Mirror damage"
        case .fluidLeak: "Fluid leak"
        case .brakeWarning: "Brake warning"
        case .dashboardWarning: "Dashboard warning"
        case .loadSecurityIssue: "Load/security issue"
        case .trailerIssue: "Trailer issue"
        case .generalWear: "General wear"
        }
    }
}

enum DefectStatus: String, Codable, CaseIterable, Identifiable {
    case open
    case inReview
    case scheduled
    case resolved

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .open: "Open"
        case .inReview: "In review"
        case .scheduled: "Scheduled"
        case .resolved: "Resolved"
        }
    }
}

enum MaintenanceCategory: String, Codable, CaseIterable, Identifiable {
    case motExpiry
    case insuranceRenewal
    case serviceDate
    case tyreReplacement
    case brakeInspection
    case oilChange
    case inspectionDue

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .motExpiry: "MOT expiry"
        case .insuranceRenewal: "Insurance renewal"
        case .serviceDate: "Service date"
        case .tyreReplacement: "Tyre replacement"
        case .brakeInspection: "Brake inspection"
        case .oilChange: "Oil change"
        case .inspectionDue: "Inspection due"
        }
    }
}

enum SubscriptionPlan: String, Codable, CaseIterable, Identifiable {
    case free
    case proMonthly
    case proYearly
    case businessMonthly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .proMonthly: "Pro Monthly"
        case .proYearly: "Pro Yearly"
        case .businessMonthly: "Business Monthly"
        }
    }

    var priceText: String {
        switch self {
        case .free: "£0"
        case .proMonthly: "£24.99 / month"
        case .proYearly: "£199.99 / year"
        case .businessMonthly: "£99.99 / month"
        }
    }

    var productID: String? {
        switch self {
        case .free: nil
        case .proMonthly: AppConstants.Store.productProMonthly
        case .proYearly: AppConstants.Store.productProYearly
        case .businessMonthly: AppConstants.Store.productBusinessMonthly
        }
    }
}

struct ChecklistTemplateItem: Identifiable {
    let id = UUID()
    let title: String
    let category: ChecklistCategory
    let trailerOnly: Bool
}

enum FleetScanChecklist {
    static let dailyWalkaround: [ChecklistTemplateItem] = [
        ChecklistTemplateItem(title: "Tyres", category: .tyres, trailerOnly: false),
        ChecklistTemplateItem(title: "Lights", category: .lights, trailerOnly: false),
        ChecklistTemplateItem(title: "Brakes", category: .brakes, trailerOnly: false),
        ChecklistTemplateItem(title: "Mirrors", category: .mirrors, trailerOnly: false),
        ChecklistTemplateItem(title: "Windscreen", category: .glass, trailerOnly: false),
        ChecklistTemplateItem(title: "Wipers", category: .glass, trailerOnly: false),
        ChecklistTemplateItem(title: "Body damage", category: .body, trailerOnly: false),
        ChecklistTemplateItem(title: "Oil/fluid leaks", category: .fluids, trailerOnly: false),
        ChecklistTemplateItem(title: "Horn", category: .controls, trailerOnly: false),
        ChecklistTemplateItem(title: "Seatbelt", category: .safety, trailerOnly: false),
        ChecklistTemplateItem(title: "Number plate", category: .body, trailerOnly: false),
        ChecklistTemplateItem(title: "Load security", category: .load, trailerOnly: false),
        ChecklistTemplateItem(title: "Dashboard warnings", category: .dashboard, trailerOnly: false),
        ChecklistTemplateItem(title: "Fuel/charge level", category: .dashboard, trailerOnly: false),
        ChecklistTemplateItem(title: "Trailer coupling", category: .trailer, trailerOnly: true)
    ]
}
