# ANET Merchants Web Production Deployment

## Ownership boundary

The Flutter repository produces a static release bundle. The deployment team
owns the separate runtime image, HTTPS endpoint, DNS, server configuration,
monitoring, and rollback. A particular static server such as Nginx is not a
Flutter requirement.

## Required deployment inputs

Confirm these values before creating a release:

1. Production origin, for example `https://merchants.example.com`.
2. Hosting path: `/` for a dedicated domain, or a trailing-slash path such as
   `/merchant/` when hosted below another site.
3. Release identifier, preferably the Git commit SHA.
4. Backend CORS approval for the exact production origin.

## Public configuration and secrets

Flutter web assets are delivered to every browser. The tracked `.env` file and
all files declared below `flutter.assets` are therefore public in the compiled
bundle.

- Keep only public API URLs and non-secret version configuration in `.env`.
- Never add passwords, private keys, API secrets, client secrets, or database
  credentials to `.env` or Flutter assets.
- `assets/certificates/certificate.pem` is not used to override browser TLS;
  browsers validate the API through their own trust store.

## Create the verified release bundle

Run PowerShell from the repository root.

Dedicated production domain:

```powershell
.\tool\build_web_release.ps1
```

Subpath deployment:

```powershell
.\tool\build_web_release.ps1 -BaseHref '/merchant/'
```

The script performs formatting checks, static analysis, automated tests, and a
release build. It produces:

```text
dist/anet-merchants-web.zip
dist/anet-merchants-web.zip.sha256
```

The deployment team can verify the artifact with:

```powershell
Get-FileHash .\dist\anet-merchants-web.zip -Algorithm SHA256
```

Do not deploy a debug build or source-map files publicly.

## Runtime-image contract

The separate frontend image must:

1. Extract the artifact into its static document root.
2. Serve `index.html` as the default document.
3. Listen on the port expected by the platform.
4. Return correct MIME types for JavaScript, JSON, Wasm, images, and fonts.
5. Route unknown paths to `index.html`. The current application uses hash
   routes, but this fallback keeps hosting behavior safe if routing evolves.
6. Avoid long-lived caching for `index.html`, `flutter_bootstrap.js`, and
   `version.json`. Versioned immutable assets may use long-lived caching.
7. Expose a health check that returns HTTP 200 for `/`.
8. Run as a non-root user when supported by the approved base image.

The image should be tagged with an immutable release identifier such as the
Git commit SHA. Do not deploy only a mutable `latest` tag.

## HTTPS and backend CORS

The public application must use HTTPS. The backend must allow the exact
frontend origin and handle `OPTIONS` preflight requests for the API methods in
use.

Required request headers include:

```text
Authorization
Content-Type
Accept
Accept-Language
x-client-unique-id
```

CORS headers must also be present on error responses such as HTTP 401 and 403;
otherwise the browser hides the actual API response behind a generic network
error.

## Production smoke test

After deployment, use a private browser window and verify:

1. `/` opens the splash screen and reaches Login.
2. Login success, failure, OTP, and forced-password-reset flows.
3. POS, QR, and settlement loading, empty, error, pagination, and refresh
   states.
4. Filtered transaction and settlement views.
5. POS, QR, and settlement invoice download.
6. POS and settlement email-report alerts.
7. Support request submission and contact links.
8. Browser refresh and Back behavior on authenticated screens.
9. Responsive desktop, tablet, and compact-width layouts.
10. Logout clears the session and returns to Login.

Use browser DevTools to confirm that there are no mixed-content, CORS, failed
asset, or JavaScript errors.

## Rollback

Keep the previously approved immutable image tag. If the smoke test fails,
restore that image tag through the deployment platform, then investigate the
failed release without rebuilding the previous artifact.
