import Foundation

extension InspectionReport {
    var pdfURL: URL? {
        guard let pdfLocalURL else { return nil }
        return URL(fileURLWithPath: pdfLocalURL)
    }
}
