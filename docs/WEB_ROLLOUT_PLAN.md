# Web Rollout Plan

## Current status

The responsive web experience, QR and settlement dashboard views, and browser-compatible invoice downloads are implemented in commit `6512160`.

## Next moves

1. **Push the completed commit**
   - Obtain explicit approval to push commit `6512160` to `origin/main`.
   - Keep the unrelated `android/gradle.properties` migration change unstaged.

2. **Verify the complete browser flow**
   - Sign in through the web login page.
   - Verify POS, QR, and settlement views load data, show loading and empty states, and paginate correctly.
   - Open POS, QR, and settlement invoices.
   - Confirm PDF downloads start and produce usable files in the browser.

3. **Responsive and accessibility pass**
   - Test desktop, tablet, and compact browser widths.
   - Confirm sidebar-to-single-column transitions, table overflow handling, keyboard navigation, and readable contrast.

4. **Mobile regression pass**
   - Run the Android app on the emulator.
   - Verify login, Home, QR, settlements, invoices, and native PDF opening remain unchanged.

5. **Release readiness**
   - Produce a release web bundle with `flutter build web`.
   - Resolve remaining build diagnostics.
   - Publish the generated bundle through the selected hosting workflow.
