/* ===============================================================
| Project : SIFR
| Page    : ROUTES.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sifr_latest/components/secure_screen.dart';
import 'package:sifr_latest/pages/device_deployment/device_deployment.dart';
import 'package:sifr_latest/pages/location_demo.dart';
import 'package:sifr_latest/pages/merchant_regn_type/merchant_otp_verify_screen.dart';
import 'package:sifr_latest/pages/user_types/user_type_selection.dart';
import 'package:sifr_latest/pages/users/forgot_password.dart';

import '../pages/account_card_page/my_account_page.dart';
import '../pages/customer_scan/customer_scan.dart';
import '../pages/help/help.dart';
import '../pages/merchant_pay/merchant.dart';
import '../pages/my_account_menu/my_account_menu.dart';
import '../pages/my_applications/my_applications.dart';
import '../pages/pages.dart';
import '../pages/payment/payment_page.dart';
import '../pages/payment/payment_success_page.dart';
import '../pages/transactions/qr_transaction_list.dart';
import '../pages/transactions/transaction_list.dart';
import '../pages/users/profile/profile.dart';
import '../pages/users/profile/profile_new_page.dart';
import '../pages/users/signup/customer/signup_success_screen.dart';
import '../pages/users/users.dart';
import '../pages/wallet/wallet.dart';
import '../providers/providers.dart';
import '../widgets/customer_withdraw/withdraw_success_reciept_for_demo.dart';
import '../widgets/widget.dart';

// Custom route Class
class CustomRoute {
  static Route<dynamic> allRoutes(RouteSettings settings) {

    var args=settings.arguments;

    return CupertinoPageRoute(builder: (context) {
      final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
      if (!isOnline) {
        return const NoInternetPage();
      }
      switch (settings.name) {
        // --- USERS ---
        // case "/":
        //   return const LoginPage();
        case "login":
          return const LoginPage();
        case "userType":
          return const UserTypeSelection();
        case "MerchantNumVerify":
          return const MerchantOTPVerifyScreen();
        // case "merchantOnboarding":
        //   return const MerchantSignup();
        case "myApplications":
          return const MyApplications();
        case "LocationPage":
          return const LocationPage();
        case "DeviceDeploymentScreen":
          return const DeviceDeploymentScreen();
        case "forgotPassword":
          return const ForgotPassword();

        case "PaymentPage":
          return  PaymentPage(merchantDetails: args as Map<String,dynamic>?,);

        case "PaymentSuccessPage":
          return const PaymentSuccessPage();
        case "SignUpSucessScreen":
          return const SignUpSucessScreen();

        case "settings":
          return const SettingsPage();

        case "forgotPage":
          String code = settings.arguments as String;
          return Forgot(type: code);

        case "loginAuthOtp":
          Map args = settings.arguments as Map;
          return LoginAuthOTP(userDetails: args['userDetails']);
        case "loginWithPin":
          return const LoginPinNew();
        case "forgotUserName":
          return const ForgotUserName();
        case "OTPVerification":
          Map args = settings.arguments as Map;
          return OTPVerification(
            type: args['type'],
            userName: args['userName'],
          );

        case "changePassword":
          String type = settings.arguments as String;
          return ChangePassword(type: type);
        case "emailOrMobileChange":
          Map args = settings.arguments as Map;
          return ChangeEmail(type: args['type'], list: args['list']);

        case "home":
          return const HomePage();
        case "splash":
          return const SplashScreen();

        // case "merchantSignUp":
        //   return const MerchantSignup();

        case "checkYourMail":
          return const CheckYourMail();

        case "nearByLocation":
          return const NearByLocations();
        case "congratulations":
          Map args = settings.arguments as Map;
          return Congratulations(receipt: args['receipt']);
        case "failure":
          Map args = settings.arguments as Map;
          return Failure(receipt: args['receipt']);

        case "statements":
          Map args = settings.arguments as Map;
          return Statements(params: args['params']);

        case "transactionDetails":
          Map args = settings.arguments as Map;
          return TransactionDetails(receipt: args['receipt']);

        case "receiptSuccess":
          Map args = settings.arguments as Map;
          return SuccessReceipt(receipt: args['receipt']);
        case "security":
          return const SecureScreen();

        case "receiptSuccessForDemo":
          return const SuccessReceiptForDemo();

        case "userCheckPage":
          Map args = settings.arguments as Map;
          return UserNameAvailability(type: args['type'], page: args['page']);

        case "Security":
          Map args = settings.arguments as Map;
          return Security(
            type: args['type'],
            userName: args['userName'],
          );

        case "transactionListing":
          return const TransactionList();

        case "QRTransactionListing":
          return const QRTransactionList();
        // return const TransactionPage();
        case "role":
          return const RolePage();

        /// WALLET PAGE
        case "wallet":
          return const Wallet();
        case "addNewMpin":
          return const AddNewMpin();
        case "addMoneyToWallet":
          return const AddMoneyToWallet();
        case "addMoney":
          Map args = settings.arguments as Map;
          return AddBalance(params: args['params']);

        /// USERS UPDATE PAGE
        case "profile":
          return const ProfilePage();

        case "profileNewScreen":
          return const ProfileNewScreen();


        case "updatePersonalInfo":
          Map args = settings.arguments as Map;
          return UpdatePersonalInfo(
            params: args['params'],
            role: args['role'],
          );
        case "updateKycInfo":
          Map args = settings.arguments as Map;
          return UpdateKycInfo(params: args['params']);
        case "reUploadKyc":
          Map args = settings.arguments as Map;
          return ReUploadKyc(params: args['params']);
        case "updateMerchantInfo":
          Map args = settings.arguments as Map;
          return UpdateMerchantInfo(params: args['params']);
        case "documentUploads":
          Map args = settings.arguments as Map;
          return UploadDocumentInfo(params: args['params']);
        case "documentReUploads":
          Map args = settings.arguments as Map;
          return DocumentReUploads(params: args['params']);
        case "emiratesUpload":
          Map args = settings.arguments as Map;
          return EmiratesUpload(params: args['params']);
        case "tradeUpload":
          Map args = settings.arguments as Map;
          return TradeLicenseUploads(params: args['params']);
        case "cancelChequeUpload":
          Map args = settings.arguments as Map;
          return CancelledChequeUpload(params: args['params']);
        case "updateLocation":
          Map args = settings.arguments as Map;
          return LocationUpdate(params: args['params']);

        case "notificationListing":
          return const NotificationPage();
        case "userProfile":
          return const UserProfilePage();
        case "license":
          return const LicenseList();
        case "complaintTypeDetails":
          Map args = settings.arguments as Map;
          return ComplaintPage2(receipt: args['receipt'], type: args['type']);

        // ---------- HELP NAVIGATION -----------
        case "help":
          return const HelpPage();
        case "faq":
          return const FaqPage();
        case "complaint":
          return const ComplaintPage();
        case "raiseComplaint":
          return const Complaint();
        case "trackRequest":
          Map args = settings.arguments as Map;
          return TrackRequestPage(list: args);

        // --- CUSTOMER SCAN NAVIGATION ---
        case "withdrawConfirmation":
          Map args = settings.arguments as Map;
          return WithdrawConfirmation(scanData: args['scanData']);
        case "mPinVerification":
          Map args = settings.arguments as Map;
          return MPinVerification(payment: args['payment']);

        // --- MERCHANT PAY ---
        case "merchantPay":
          return const MerchantPay();
        case "merchantQrCode":
          Map args = settings.arguments as Map;
          return MerchantQRCode(params: args['params']);

        // --- MY ACCOUNT MENU
        case "settings":
          return const SettingsPage();
        case "myAccount":
          return const MyAccountPage();
        case "securitySettings":
          Map args = settings.arguments as Map;
          return SecuritySettings(list: args);
        case "aboutUs":
          return const AboutUsPage();

        // --- MY ACCOUNT PAGE
        case "addNewAccount":
          return const AddNewAccount();
        case "card":
          Map args = settings.arguments as Map;
          return CardPage(type: args['type']);
        case "accounts":
          return const ViewMyAccount();
        case "cards":
          return const ViewMyCard();
        case "addNewCard":
          return const AddNewCard();
      }
      return const SettingsPage();
    });
  }
}
