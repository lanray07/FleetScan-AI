# FleetScan AI App Store Submission Pack

This folder contains the local assets and draft form answers for App Store Connect.

## Generated Assets

- `Assets/AppStoreIcon-1024.png`
- `Screenshots/en-GB/iPhone-6.9/*.png`
- `Screenshots/en-GB/iPad-13/*.png`
- `InAppPurchase/subscription-review-screenshot.png`

The Xcode app icon set was generated at:

- `FleetScanAI/Resources/Assets.xcassets/AppIcon.appiconset`

## App Store Connect Form Pack

- `metadata-en-GB.md`: product page copy and listing fields
- `app-store-connect-fields.json`: structured values for app record, listing, pricing, and review
- `privacy-form-draft.md`: privacy nutrition label draft and answers needing owner confirmation
- `subscriptions.md`: subscription group and product setup
- `export-compliance.md`: encryption/export compliance draft
- `review-notes.md`: App Review notes and safety disclaimers

## Account-Only Tasks

These steps require your Apple Developer account and cannot be completed from this workspace:

1. Register bundle ID `com.fleetscanai.app` in Certificates, Identifiers & Profiles.
2. Create the App Store Connect app record for FleetScan AI.
3. Accept any paid app / banking / tax agreements required for subscriptions.
4. Create the three auto-renewable subscription products.
5. Upload a signed build from Xcode or Xcode Cloud.
6. Publish the privacy answers only after confirming the real backend/data practices.
7. Provide live Privacy Policy and Support URLs.
8. Complete regional compliance forms such as DSA trader status using legal business details.

## Apple References Checked

- Screenshot formats and sizes: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- App privacy requirements and publishing flow: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- Privacy label guidance: https://developer.apple.com/app-store/app-privacy-details/
