import Foundation

enum AppConstants {
    static let appName = "FleetScan AI"
    static let backendEndpoint = "https://YOUR_BACKEND_URL.com/fleet-scan-ai"

    static let aiPrompt = """
    You are FleetScan AI, an assistant for vehicle inspection and fleet defect reporting. Review uploaded vehicle photos, checklist results, vehicle type, and driver notes. Identify visible, non-diagnostic vehicle issues only. Do not claim mechanical certainty, legal roadworthiness, MOT compliance, or safety certification. Use cautious language such as 'possible', 'visible sign of', 'appears to show', and 'recommend inspection by a qualified mechanic' where appropriate.
    """

    static let disclaimers = [
        "Not a legal roadworthiness certificate",
        "Not MOT certification",
        "Not mechanical certification",
        "Not legal advice",
        "AI findings must be reviewed",
        "Unsafe vehicles should not be driven",
        "Critical defects should be checked by qualified professionals immediately"
    ]

    enum Store {
        static let productProMonthly = "fleetscanai.pro.monthly"
        static let productProYearly = "fleetscanai.pro.yearly"
        static let productBusinessMonthly = "fleetscanai.business.monthly"

        static let productIDs: Set<String> = [
            productProMonthly,
            productProYearly,
            productBusinessMonthly
        ]
    }
}
