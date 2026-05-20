# GitHub Secrets Required for App Store Upload

Add these at:

`https://github.com/lanray07/FleetScan-AI/settings/secrets/actions`

## Required Secrets

`APP_STORE_CONNECT_API_KEY_ID`

The Key ID from App Store Connect API key settings.

`APP_STORE_CONNECT_ISSUER_ID`

The Issuer ID from App Store Connect API access.

`APP_STORE_CONNECT_API_KEY_P8`

The full private key content from the downloaded `AuthKey_XXXX.p8` file. Paste the entire file including:

```text
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
```

`APPLE_TEAM_ID`

Your Apple Developer Team ID.

`CONFIRM_SUBMIT_FOR_REVIEW`

Set to `true` only when you want the GitHub workflow to submit the app version to App Review.

`OWNER_CONFIRMED_PRIVACY`

Set to `true` after confirming the App Privacy answers in App Store Connect.

`OWNER_CONFIRMED_DSA`

Set to `true` after confirming Digital Services Act trader details in App Store Connect.

`OWNER_CONFIRMED_EXPORT`

Set to `true` after confirming the app does not use non-exempt encryption. The app Info.plist contains `ITSAppUsesNonExemptEncryption = false`.

`OWNER_CONFIRMED_CONTENT_RIGHTS`

Set to `true` after confirming the app does not contain, show, or access third-party content.

`APP_SUPPORT_URL`

Live HTTPS support URL, for example `https://yourdomain.com/support`.

`APP_MARKETING_URL`

Live HTTPS marketing URL, for example `https://yourdomain.com/fleetscan-ai`.

`APP_PRIVACY_URL`

Live HTTPS privacy policy URL, for example `https://yourdomain.com/privacy`.

## Optional Repository Variables

Add these under repository variables if you want to override defaults:

`APP_IDENTIFIER`

Default: `com.fleetscanai.app`

`APP_VERSION`

Default: `1.0`

`APP_NAME`

Default: `FleetScan AI`

`APP_SUBTITLE`

Default: `AI vehicle checks for fleets`

## Manual Workflow

After adding secrets:

1. Open `https://github.com/lanray07/FleetScan-AI/actions/workflows/appstore-upload.yml`
2. Click `Run workflow`
3. Keep `upload_metadata` enabled
4. Keep `upload_build` enabled
5. Run

The workflow uploads metadata/screenshots/icon, builds a signed IPA, and uploads it to App Store Connect/TestFlight.

## Tag Trigger

You can also trigger the same workflow from Git:

```bash
git tag appstore-upload-YYYYMMDD-HHMM
git push origin appstore-upload-YYYYMMDD-HHMM
```

To upload and then submit for review, use:

```bash
git tag appstore-submit-YYYYMMDD-HHMM
git push origin appstore-submit-YYYYMMDD-HHMM
```

The submit tag still requires the confirmation secrets above.
