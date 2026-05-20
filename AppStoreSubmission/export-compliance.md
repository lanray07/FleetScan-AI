# Export Compliance Draft

FleetScan AI uses standard Apple platform networking and HTTPS/TLS for the optional remote AI endpoint placeholder.

Draft App Store Connect answers, subject to owner confirmation:

- Does your app use encryption? `Yes`
- Is the encryption limited to standard HTTPS/TLS, Apple-provided APIs, authentication, or data protection? `Yes`
- Does the app contain proprietary or non-standard cryptographic algorithms? `No`
- Does the app provide encryption as a primary feature? `No`
- Does the app implement end-to-end encryption? `No`
- Does the app require export compliance documentation? Usually `No` for standard exempt HTTPS/TLS use, but confirm in App Store Connect based on the final build and distribution regions.

Owner confirmation needed:

- Final backend endpoint and hosting country
- Whether custom cryptography is added later
- Whether encrypted file/report export or account-to-account encrypted messaging is added later

This is not legal advice.
