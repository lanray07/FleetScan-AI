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

## App Store Upload

The manual workflow at `.github/workflows/appstore-upload.yml` can upload metadata, screenshots, the app icon, and a signed IPA to App Store Connect once these GitHub secrets/variables are configured:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_P8_BASE64` preferred, or `APP_STORE_CONNECT_API_KEY_P8` fallback
- `APPLE_TEAM_ID`
- `APP_SUPPORT_URL`
- `APP_MARKETING_URL`
- `APP_PRIVACY_URL`

For this repository, the current public GitHub URLs are:

- Support: `https://github.com/lanray07/FleetScan-AI/issues`
- Marketing: `https://github.com/lanray07/FleetScan-AI`

The App Store Connect app record and bundle ID must already exist before uploading a build.

Optional App Review submission is guarded. To enable the `submit_for_review` workflow input, the Apple account holder must also set:

- `CONFIRM_SUBMIT_FOR_REVIEW=true`
- `OWNER_CONFIRMED_PRIVACY=true`
- `OWNER_CONFIRMED_DSA=true`
- `OWNER_CONFIRMED_EXPORT=true`
- `OWNER_CONFIRMED_CONTENT_RIGHTS=true`

The first release is configured for manual release after approval.

## App Store Submission

Submission assets and form drafts are in `AppStoreSubmission/`. Privacy and terms drafts are in `Legal/`.
