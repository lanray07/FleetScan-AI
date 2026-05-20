# FleetScan AI Final App Store Connect Form Answers

These are the recommended values for the current local-first FleetScan AI build. Items marked `OWNER REQUIRED` must be supplied by the Apple Developer account holder before live submission.

## App Information

Name: FleetScan AI

Subtitle: AI vehicle checks for fleets

Bundle ID: `com.fleetscanai.app`

SKU: `fleetscan-ai-ios-001`

Primary language: English (UK)

Primary category: Business

Secondary category: Productivity

Content rights: `Yes, FleetScan AI owns or has licensed rights to all included content and generated marketing assets.`

Made for Kids: `No`

License agreement: `Apple Standard EULA`

Age rating recommendation: `4+`, assuming the app remains a business utility with no objectionable content, user-generated social content, gambling, unrestricted web access, medical treatment claims, or location sharing.

## Age Rating Questionnaire Draft

Set all content frequency answers to `None`, unless you later add features in that category:

- Cartoon or fantasy violence: None
- Realistic violence: None
- Prolonged graphic or sadistic realistic violence: None
- Profanity or crude humour: None
- Mature or suggestive themes: None
- Horror/fear themes: None
- Medical/treatment information: None
- Alcohol, tobacco, drug use or references: None
- Simulated gambling: None
- Sexual content or nudity: None
- Contests: No
- Gambling: No
- Unrestricted web access: No
- User-generated content: No

Important: Do not answer `Medical/Treatment Information` as present unless the app starts giving medical advice. Vehicle safety disclaimers are not medical content.

## Pricing and Availability

App price: Free

Countries/regions: `OWNER REQUIRED`

Recommended default if you do not have regional restrictions: All available App Store countries/regions.

## In-App Purchases / Subscriptions

Subscription group: FleetScan AI Plans

Products:

- `fleetscanai.pro.monthly` - Pro Monthly - £24.99/month
- `fleetscanai.pro.yearly` - Pro Yearly - £199.99/year
- `fleetscanai.business.monthly` - Business Monthly - £99.99/month

Paid Apps Agreement / banking / tax status: `OWNER REQUIRED`

App Store Server Notifications URL: Optional. Leave blank until you build a production backend.

## App Privacy

Recommended answer for the current mock/local-first build:

`No, we do not collect data from this app.`

Only use that answer if the release build:

- Uses mock AI by default
- Does not send inspection photos or notes to a backend
- Does not include analytics, ads, crash SDKs, attribution SDKs, or support chat SDKs
- Does not sync fleet/team/account data to a server

If production remote AI is enabled, answer `Yes, we collect data from this app` and disclose User Content at minimum, including vehicle photos, inspection notes, defect descriptions, repair notes, and report text. If accounts/subscription server validation/analytics are added, disclose those data types too.

Privacy Policy URL: `OWNER REQUIRED`

User Privacy Choices URL: Optional. Recommended if backend accounts/sync are added.

## Export Compliance

Recommended answers for the current app:

- Uses encryption: Yes
- Encryption limited to standard HTTPS/TLS and Apple APIs: Yes
- Proprietary or non-standard cryptography: No
- Encryption is primary app feature: No
- End-to-end encryption: No

This is not legal advice. Confirm based on the final backend and distribution regions.

## Digital Services Act

DSA trader status: `OWNER REQUIRED`

If distributing in the EU, Apple requires you to declare whether you are a trader. If you are a trader, provide the required legal contact/business information for display to EU consumers.

## Review Information

Sign-in required: No

Demo account: Not required for the current local-first build.

Review contact:

- First name: `OWNER REQUIRED`
- Last name: `OWNER REQUIRED`
- Phone: `OWNER REQUIRED`
- Email: `OWNER REQUIRED`

Notes:

Mock AI mode is enabled by default. The app is a vehicle inspection workflow tool. It does not claim legal roadworthiness, MOT compliance, mechanical certification, or safety certification. AI findings are suggestions only and must be reviewed by the user. No API keys are stored in the iOS app.

## Submission Release Option

Recommended first submission:

Manual release after approval.

Rationale: Gives you a final chance to verify the App Store product page, subscriptions, privacy labels, and build processing before customers can download it.

## Absolute Blockers Before Live Submit

- Apple Developer Program membership active
- Bundle ID `com.fleetscanai.app` registered
- App Store Connect app record created
- Paid apps/subscription agreements active
- Subscription products created and approved/ready
- Privacy Policy URL live
- Support URL live
- Marketing URL live or intentionally omitted
- App Store Connect API key added to GitHub secrets
- Apple Team ID added to GitHub secrets
- DSA trader status completed by account holder
- Privacy answers confirmed by account holder
