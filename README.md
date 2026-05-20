# FleetScan AI

FleetScan AI is a SwiftUI iOS app for AI-assisted vehicle inspections, defect reporting, maintenance reminders, fleet visibility, PDF reports, and StoreKit subscriptions.

## Requirements

- Xcode 16 or newer
- iOS 17.0+
- SwiftData
- StoreKit 2

## Open in Xcode

Open `FleetScanAI.xcodeproj`, select the `FleetScanAI` scheme, and run on an iOS 17+ simulator.

Mock AI mode is enabled by default. The remote backend endpoint is a placeholder and no API keys are stored in the iOS app.

## GitHub Actions

The workflow at `.github/workflows/ios-xcode-build.yml` builds the app on a macOS runner with Xcode:

```sh
xcodebuild \
  -project FleetScanAI.xcodeproj \
  -scheme FleetScanAI \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Push this repository to GitHub and open the Actions tab to run the workflow.

## App Store Submission

Submission assets and form drafts are in `AppStoreSubmission/`. Privacy and terms drafts are in `Legal/`.
