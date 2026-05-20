# App Review Notes

FleetScan AI is a local-first SwiftUI app for vehicle inspection workflow support.

Important reviewer notes:

- Mock AI mode is enabled by default.
- The remote AI endpoint is a placeholder: `https://YOUR_BACKEND_URL.com/fleet-scan-ai`.
- No API keys are stored in the iOS app.
- The app does not claim legal roadworthiness, MOT compliance, mechanical certification, or safety certification.
- AI findings are suggestions only and must be reviewed by the user.
- Unsafe vehicles should not be driven.
- Critical defects should be checked by qualified professionals immediately.

Sign-in:

No sign-in is required for the current build.

Subscriptions:

The paywall contains Free, Pro Monthly, Pro Yearly, and Business Monthly options. Product IDs are documented in `AppStoreSubmission/subscriptions.md`.

Testing the workflow:

1. Complete onboarding and accept the safety disclaimer.
2. Add a vehicle.
3. Start a daily vehicle check.
4. Open checklist items, mark pass/fail, add notes, and attach photos.
5. Run the mock AI scan.
6. Review/edit/approve defects.
7. Finalize the inspection and generate a PDF report.

Safety disclaimer shown in app:

- Not a legal roadworthiness certificate
- Not MOT certification
- Not mechanical certification
- Not legal advice
- AI findings must be reviewed
- Unsafe vehicles should not be driven
- Critical defects should be checked by qualified professionals immediately
