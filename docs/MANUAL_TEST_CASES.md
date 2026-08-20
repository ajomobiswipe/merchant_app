# ANET Merchants Manual Test Cases

## Scope

This document covers the primary manual validation scenarios for:

- Authentication
- Session persistence
- Home, POS, QR/VPA, settlements, dashboard, support, and profile flows
- Localization, theme, connectivity, update prompts, and logout handling
- Invoice, email, contact launcher, and Android release sanity

## Test Data Notes

- Keep at least these user profiles available:
  - Single-terminal user
  - Multi-terminal / multi-merchant user
  - User with OTP required
  - User with password reset required (`responseCode == "04"`)
  - User with dashboard enabled
  - User with dashboard disabled
- Keep one account with real POS data, one with QR/VPA data, and one with settlements data.
- Keep one expired / invalid token case ready to validate forced logout on `401`.

## Legend

- `Priority`: `P0` critical, `P1` major, `P2` nice-to-have
- Expected results should be true in light theme, dark theme, English, Hindi, Malayalam, and Tamil unless a case says otherwise.

---

## 1. Application Launch & Splash

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| APP-001 | P0 | Splash screen branding | Launch app from closed state | Native splash shows ANET icon, then Flutter splash shows ANET branding without layout issues |
| APP-002 | P0 | Logged-out launch | Clear app data, launch app | User lands on login screen |
| APP-003 | P0 | Logged-in launch | Login successfully, close app, reopen app | Splash checks saved login flag and lands on home screen |
| APP-004 | P1 | Portrait lock | Rotate device on login, home, invoices, filters | App stays portrait-up only |

## 2. Login

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| AUTH-001 | P0 | Valid login without OTP | Enter valid credentials for a non-OTP user | Login succeeds and navigates to home |
| AUTH-002 | P0 | Valid login with OTP | Enter valid credentials for OTP-required user | App navigates to OTP validation screen |
| AUTH-003 | P0 | Login with reset password response | Login with account returning inner response code `04` | Reset password required alert is shown and user is navigated to reset password screen |
| AUTH-004 | P0 | Invalid credentials | Enter invalid username/password | Error alert/message shown, no navigation |
| AUTH-005 | P1 | Empty username | Tap sign in with username blank | Validation shown |
| AUTH-006 | P1 | Empty password | Tap sign in with password blank | Validation shown |
| AUTH-007 | P1 | Remember me enabled | Enable remember me, login, logout, return to login | Username/password remain filled |
| AUTH-008 | P1 | Remember me disabled | Disable remember me, login, logout | Credentials are cleared |
| AUTH-009 | P1 | Password visibility toggle | Toggle eye icon | Password obscured/visible state changes correctly |
| AUTH-010 | P1 | Login language popup | Open language selector on login and change language | Login screen strings update immediately |
| AUTH-011 | P1 | Forgot password launch | Tap forgot password | Forgot password screen opens |

## 3. Forgot Password / OTP / Reset Password

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| AUTH-020 | P0 | Forgot password success | Enter valid username and submit | Success alert shown with response message |
| AUTH-021 | P1 | Forgot password invalid user | Submit unknown username | Error alert shown |
| AUTH-022 | P0 | OTP success | Enter correct OTP and submit | OTP validated and login flow completes |
| AUTH-023 | P0 | OTP invalid | Enter wrong OTP | Failure shown, user remains on OTP screen |
| AUTH-024 | P1 | OTP timer text | Open OTP screen for a user with timer value | Timer / resend behavior matches API rules |
| AUTH-025 | P0 | Reset password success | Enter valid new password and confirm | Success flow completes |
| AUTH-026 | P1 | Reset password validation | Enter mismatched / weak passwords | Validation shown |

## 4. Session, Logout, and Unauthorized Handling

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| SES-001 | P0 | Logout confirm | Tap logout | Confirmation dialog shown |
| SES-002 | P0 | Logout success | Confirm logout | Logout API called with username, session cleared, app returns to login |
| SES-003 | P1 | Logout cancel | Cancel logout dialog | User stays on current screen |
| SES-004 | P0 | 401 handling | Force any API to return `401` | Session clears and app returns to login automatically |
| SES-005 | P1 | Language reset on logout | Change app language, logout, reopen login | Login returns to default language / cleared selection as implemented |

## 5. Home Screen

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| HOME-001 | P0 | Home for single-terminal user | Login with single-terminal account | Home loads correct merchant/shop info |
| HOME-002 | P0 | Home for multi-merchant user | Login with multi-merchant account | Merchant dropdown is shown |
| HOME-003 | P0 | Single terminal hides unnecessary merchant switching behavior | Login with only one terminal/merchant | No broken or redundant selection behavior |
| HOME-004 | P0 | Merchant dropdown “All” selection | Select `All` in merchant dropdown | POS tab becomes active automatically and aggregated POS data is shown |
| HOME-005 | P1 | Merchant switching persistence | Change selected merchant, kill app, reopen | Selected merchant/shop remains active |
| HOME-006 | P1 | Refresh action | Tap refresh on each tab | Current tab reloads latest data and loading state is visible |
| HOME-007 | P1 | Summary card responsive layout | Test narrow device widths | Amount/count text remains readable and does not overflow |

## 6. POS Transactions on Home

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| POS-001 | P0 | POS home list load | Open POS tab on home | Transactions load using home logic |
| POS-002 | P0 | POS home range logic | Inspect data returned on home | Home uses the intended default date range logic configured for current build |
| POS-003 | P1 | POS refresh | Tap refresh from POS tab | Loader appears and list refreshes |
| POS-004 | P1 | View all POS | Tap `View All Transactions` from POS tab | POS filter/list flow opens |
| POS-005 | P1 | POS invoice navigation | Tap info icon on a POS row | POS invoice screen opens with correct transaction data |

## 7. QR / VPA Transactions on Home

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| QR-001 | P0 | VPA device list load | Open QR tab | Available VPAs load |
| QR-002 | P0 | VPA selection | Change VPA from selector | QR transaction list reloads for selected VPA |
| QR-003 | P1 | QR refresh button | Tap refresh on QR tab | Loader is shown, stale list is not briefly shown as final result |
| QR-004 | P1 | QR invoice navigation | Tap info icon on QR row | VPA invoice screen opens with matching data |
| QR-005 | P1 | QR empty state | Use account/date/VPA with no transactions | Clean empty state shown |

## 8. Transaction Filters & List Pages

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| FLT-001 | P0 | POS filter by date | Open POS filter, choose date range, apply | POS list loads filtered records |
| FLT-002 | P0 | POS filter by terminal | Select terminal and apply | POS list filtered by selected terminal |
| FLT-003 | P0 | POS filter by RRN | Choose RRN mode, enter RRN, apply | Results filtered by RRN |
| FLT-004 | P0 | POS filter by app code | Choose app code mode, enter app code, apply | Results filtered by auth/app code |
| FLT-005 | P1 | POS filter validation | Apply with no date and no terminal / rrn / app code | Alert shown telling user to select valid criteria |
| FLT-006 | P0 | QR filter by date range | Open QR filter, select required date range, apply | QR list loads filtered records |
| FLT-007 | P1 | QR filter validation | Try apply without required QR date range | Alert shown |
| FLT-008 | P1 | Filter reset | Tap reset in POS/QR filter | Controls clear and return to defaults |
| FLT-009 | P1 | Pagination next/prev | Navigate transaction pages | Page indicator and records change correctly |
| FLT-010 | P1 | Send by email from POS list | Tap send by email | API is called with `sendTxnReportToMail=true` and success alert shown |
| FLT-011 | P1 | Send by email from QR list | Tap send by email | API / flow completes and success alert shown instead of snackbar-only feedback |

## 9. Settlements

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| SET-001 | P0 | Home settlement summary | Open settlements tab on home | Settled amount, deductions, and pending settlements populate |
| SET-002 | P0 | View all settlements | Tap `View All Settlements` | Settlement filter/dashboard flow opens |
| SET-003 | P0 | Settlement filter by preset range | Choose today / yesterday / last 7 days / last month | Dashboard loads matching settlements |
| SET-004 | P0 | Settlement filter custom range | Choose custom from/to dates and apply | Dashboard loads matching settlements |
| SET-005 | P1 | Settlement pagination | Tap next/previous page | Page changes and remains stable after response |
| SET-006 | P0 | Settlement detail | Open a settlement item | Detail page shows breakdown and transaction activity |
| SET-007 | P1 | Settlement transaction activity info | Tap info icon in settlement activity row | Correct invoice/detail screen opens |
| SET-008 | P1 | Settlement send by email | Tap send by email | Success/failure alert shown appropriately |

## 10. Dashboard

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| DSH-001 | P0 | Dashboard enabled user | Login with `dashboardEnabled = true` | Dashboard entry is visible and usable |
| DSH-002 | P0 | Dashboard disabled user | Login with `dashboardEnabled = false` | Dashboard entry is hidden or blocked according to implementation |
| DSH-003 | P1 | Default dashboard date range | Open dashboard | Default last 3 months range is selected |
| DSH-004 | P1 | Dashboard custom range | Change from/to dates within 6 months | Chart and values update |
| DSH-005 | P1 | Dashboard max range validation | Select a range over 6 months | Validation/alert shown |
| DSH-006 | P1 | Month vs transaction chart | Load dataset with monthly values | X/Y chart reflects API monthly data correctly |

## 11. Support

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| SUP-001 | P0 | Support screen load | Open support tab | Quick actions load from API |
| SUP-002 | P1 | Quick action dropdown | Open quick action selector | All active support actions are listed |
| SUP-003 | P0 | Raise support request | Select action and submit | Request API succeeds and success alert shown |
| SUP-004 | P1 | Support phone launcher | Tap phone number | Dialer app opens |
| SUP-005 | P1 | Support email launcher | Tap email address | Email app opens |
| SUP-006 | P1 | Dark theme support visuals | Check icon backgrounds and cards | No unreadable white icon circles or broken contrasts |

## 12. Profile

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| PRO-001 | P0 | Profile info | Open profile | Basic login response info is shown |
| PRO-002 | P1 | Terminal list | Open profile for account with terminals | All available terminals are shown |
| PRO-003 | P1 | VPA list | Open profile for account with VPAs | All available VPAs are shown |
| PRO-004 | P1 | Device/app info | Open profile | App version, OS version, platform, and device model are shown |
| PRO-005 | P1 | Check for updates | Tap check for updates | Optional / force update flow behaves correctly |
| PRO-006 | P1 | Theme mode switch | Change light / dark / system | Entire app theme updates immediately |
| PRO-007 | P1 | Color palette switch | Change palette from dropdown | Accent colors update across the app consistently |
| PRO-008 | P0 | Language switch immediate | Change language from profile | Current screen and subsequent screens update immediately |

## 13. Localization

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| I18N-001 | P0 | English texts | Switch to English | All major screens display English copy |
| I18N-002 | P0 | Hindi texts | Switch to Hindi | All supported strings display Hindi |
| I18N-003 | P0 | Malayalam texts | Switch to Malayalam | All supported strings display Malayalam |
| I18N-004 | P0 | Tamil texts | Switch to Tamil | All supported strings display Tamil |
| I18N-005 | P1 | Latest feature translations | Check dashboard, profile additions, forgot password, update prompts, connectivity blocker | No new English-only strings remain where translations are expected |

## 14. Theme / UI / Responsiveness

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| UI-001 | P0 | Dark theme compatibility | Browse login, home, support, filters, invoices, profile | Contrast is readable and icons/backgrounds look intentional |
| UI-002 | P1 | Small screen responsiveness | Test narrow Android device | No clipped totals, buttons, dropdowns, or list badges |
| UI-003 | P1 | Large text / accessibility check | Increase system font size moderately | Layout remains usable |
| UI-004 | P1 | Bottom nav behavior | Tap each bottom item | Selection state and navigation update correctly |

## 15. Connectivity & Blocking

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| NET-001 | P0 | No internet on launch | Disable internet and open app | Connectivity warning shown and UI blocked |
| NET-002 | P0 | Internet loss mid-session | Turn off internet on home/profile/support | Warning shown and interaction blocked |
| NET-003 | P0 | Internet restored | Re-enable internet | Warning automatically disappears and UI is re-enabled |

## 16. Alerts & Feedback

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| ALT-001 | P1 | Success alert style | Trigger successful support request / email request | Green success styling shown |
| ALT-002 | P1 | Warning alert style | Trigger validation warning | Primary-colored title / warning layout shown |
| ALT-003 | P1 | Confirmation alert style | Trigger logout / destructive action | Confirm / cancel actions behave correctly |

## 17. Invoices & PDF

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| INV-001 | P0 | POS invoice UI | Open POS invoice screen | Invoice layout matches production-style reference closely |
| INV-002 | P0 | POS invoice PDF | Download POS invoice | PDF opens and matches screen layout |
| INV-003 | P0 | VPA invoice UI | Open VPA invoice screen | VPA invoice shows expected fields and branding |
| INV-004 | P0 | VPA invoice PDF | Download VPA invoice | PDF opens and matches screen layout |
| INV-005 | P1 | Logo rendering | Check invoice logo in screen and PDF | ANET image logo is visible and correctly sized |

## 18. Android Release Sanity

| ID | Priority | Scenario | Steps | Expected Result |
|---|---|---|---|---|
| REL-001 | P0 | Debug build | Run `flutter build apk --debug` | Build succeeds |
| REL-002 | P0 | Release build | Run `flutter build apk --release` | Signed release APK is generated |
| REL-003 | P1 | Launcher icon | Install app | Launcher icon is ANET icon |
| REL-004 | P1 | App label | Install app | App name appears as `ANET Merchants` |

---

## Suggested Regression Smoke Pack

Run these first on every build:

1. `APP-002`
2. `AUTH-001`
3. `SES-002`
4. `HOME-001`
5. `POS-004`
6. `QR-002`
7. `SET-002`
8. `SUP-003`
9. `PRO-006`
10. `NET-002`
11. `INV-002`
12. `REL-002`
