/* ===============================================================
| Project : SIFR
| Page    : CONSTANTS.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

class Constants {
  // GLOBAL MESSAGE IN APIS
  static const unauthorized =
      'You have logged into Sifr from another device with the same credentials.';
  static const instId = 'SIFR';
  static const deviceType = 'MOBILE';
  static const pwdResetType = 'pwdReset';
  static const custStatus = 'ACTIVE';
  static const userNameSuccessMessage = 'Username is available to use';
  static const userNameFailureMessage =
      'This username is already taken, try with another username';
  static const passwordError =
      "Use 8 or more characters with a mix of letters, numbers & symbols";
  static const passwordMissMatch = 'Password & Confirm Password do not match';
  static const card = 'Card';
  static const account = 'Account';
  // Wallets
  static const wallet = 'WALLET';
  static const balanceCheck = 'BALANCECHECK';
  static const emailError =
      "Please enter a valid email. Example: you@example.com";
  static const passwordUsernameError = "Password cannot be username";
  static const dobError = "DOB should be 18 years old to register";
  static const dobMessage = "Minimum age 18 years!";
  static const mobileNoFailureMessage =
      'This Number is already taken, try with another number';
  static const emailIdFailureMessage =
      'This Email is already taken, try with another email';
  static const emailIdSuccessMessage = 'Email is available.';
  static const mobileNoSuccessMessage = 'Mobile number available to use';
  static const pinMessage = 'Maximum 4 digits';
  static const mPinMessage = 'Maximum 6 digits';
  static const oneMbErrorMessage = 'File size must be < 1 MB.';
  static const twoMbErrorMessage = 'File size must be < 2 MB.';
  static const reviewNotes =
      'To update Mobile Number or Email ID, visit Security settings under My Account';
  static const somethingWrong = 'Something went to wrong';
  static const answerMesage =
      'Answers should not match with your other questions';

  /* Global Image Locations */
  static const sifrLogo = 'assets/logo/logo1.png';
  static const noDataFoundImage = 'assets/app/no-data.png';
  static const loginImage = 'assets/screen/login-3.png';
  static const forgotUserNameImage = 'assets/screen/forgot-username.png';
  static const forgotPasswordImage = 'assets/screen/forgot-password.png';
  static const forgotOTPImage = 'assets/screen/forget-otp.png';
  static const noInternetImage = 'assets/screen/no-internet.jpg';
  static const payCashImage = 'assets/screen/pay_cash_new.png';
  static const emptyProfileImage = 'assets/screen/profile.png';
  static const verifyMPIN = 'assets/screen/verify_mpin.png';
  static const verifyKYC = 'assets/screen/kyc.png';
}
