# App Privacy Draft

Apple requires a Privacy Policy URL for iOS apps and privacy responses in App Store Connect. The answers below are conservative drafts for FleetScan AI and must be confirmed against the actual production backend before publishing.

## Recommended Current Answer for Local-Only/MOCK Build

If the released App Store build keeps mock AI enabled by default, has no account system, no analytics SDK, no advertising SDK, and does not send inspection data/photos off device:

Data collection answer: `No, we do not collect data from this app.`

Rationale:

- SwiftData stores vehicles, inspections, photos, defects, reminders, reports, business profile, and settings locally on the user device.
- StoreKit subscriptions are handled by Apple.
- The placeholder backend URL is not a real service unless you configure it.

Only select this if the shipped production build truly does not transmit user data to your servers or third-party services.

## Conservative Future Answer for Production Remote AI

If you enable the secure backend AI endpoint, store uploads, create accounts, or sync team/fleet data, use `Yes, we collect data from this app` and configure at least these data types as applicable:

### User Content

Examples:

- Vehicle photos
- Inspection notes
- Defect descriptions
- Repair notes
- PDF report content
- Business profile / branding text

Purpose: App Functionality.

Linked to user: `Yes` if you use accounts, teams, businesses, backend user IDs, or sync.

Tracking: `No`, unless used with data from other companies for advertising or tracking.

### Identifiers

Use only if production backend has accounts, team membership, device identifiers, user IDs, or server-side subscription/customer IDs.

Purpose: App Functionality, Account Management.

Linked to user: usually `Yes`.

Tracking: `No`.

### Purchases

Use only if your backend receives StoreKit transaction IDs, subscription status, or server notifications tied to users.

Purpose: App Functionality.

Linked to user: `Yes` if tied to accounts.

Tracking: `No`.

### Diagnostics / Usage Data

Use only if you add crash reporting, analytics, logging, or telemetry SDKs.

Purpose: App Functionality, Analytics.

Linked to user: depends on SDK configuration.

Tracking: `No`, unless combined for tracking.

## Privacy Policy URL

App Store Connect field:

`https://YOUR_DOMAIN.com/privacy`

Host the draft at `Legal/privacy-policy-draft.md` as a public webpage before submission.

## User Privacy Choices URL

Optional field:

`https://YOUR_DOMAIN.com/privacy/choices`

Use this if you provide account deletion, data export, or backend data-management options.

## Owner Confirmation Needed

- Will production AI uploads leave the device?
- Will photos or reports be stored on your backend?
- Will the app have user accounts, team accounts, or admin dashboards?
- Will subscriptions be validated server-side?
- Will analytics, crash reporting, support chat, attribution, or advertising SDKs be included?
- Will any data be shared with OpenAI or another AI provider through your backend?
- What is the live Privacy Policy URL?

Do not publish privacy responses until those answers are final.
