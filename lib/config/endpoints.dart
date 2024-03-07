/* ===============================================================
| Project : SIFR
| Page    : END_POINTS.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/
// Dependencies or Plugins - Models - Services - Global Functions
import 'config.dart';

class EndPoints {
  //for merchant onboarding
  static const baseApiPublic = 'http://213.42.225.250:9508';
  // static const baseApiPublic = 'http://10.0.38.61:9508';
  // static const baseApiPublic = 'http://10.0.38.89:9508';
  /*
    * This End Points URL are based of development and production
  */
  static const baseApi9502 = 'http://sandboxdev.omaemirates.com:9502';
  static const baseApi9503 = 'http://sandboxdev.omaemirates.com:9503';
  static const baseApi8988 = 'https://softposreceipt.omaemirates.com:8988';
  static const serviceUrl =
      "https://sandboxdev.omaemirates.com:9506/customer/v1";

  /*
    * This Short apis used for code reduce.
  */
  static const nanoServiceUrl = '/NanoCustomerService/v1/customer';
  static const nanoBankService = '/NanoSmartBanking/v1/smartBanking';

  // SIFR logo api
  static const sifrLogo = '$baseApi8988/SoftPOS/SifrLogo/';

  // Slider image for dashboard
  static const slideUrl = "/SoftPOS/Sifr/AppSilderimages";

  /*
    * User Related APIs
  */
  static const loginAPI = "/NanoCustomerService/v1/login";
  static const registerAPI = "$nanoServiceUrl/userRegistration";
  static const userCheckAPI =
      "$nanoServiceUrl/getUserNameAvailabilityStatus/${Constants.instId}/";
  static const emailCheck = "$nanoServiceUrl/checkexistedCustomerDetails";
  static const updateDetailsAPI = "$nanoServiceUrl/addOrUpdateCustomerInfo/";
  static const updateMerchantStatus = "$nanoBankService/updateMerchantStatus";
  static const updateProfileImageAPI = "$nanoServiceUrl/updateProfile/SIFR";
  static const updateEmailOrMobileAPI = "$nanoServiceUrl/emailOrMobileChange/";
  static const getMCC = "$nanoServiceUrl/getMcc/${Constants.instId}";
  static const deviceRegister = "$nanoServiceUrl/reRegister";

  /*
    *  Local api development
    *  1. to load security question in register page
    *  2. load terms and conditions
    *  3. FAQ
    *  4. Country
  */
  static const getSecurityQuestions = "$serviceUrl/getSecurityQuestionDetails";
  static const getTermsAndCondition = "$serviceUrl/getContentDetails/";
  static const getFaq = "$serviceUrl/getFaqDetails";
  static const getCountry = "$serviceUrl/getCountryDetails";
  static const getState = "$serviceUrl/getStateDetails/";
  static const getCity = "$serviceUrl/getCityDetails/";

  /*
    * User Reset and Change Password and PIN
  */
  static const mobileOtpAPI = "/NanoCustomerService/v1/mobileOtp";
  static const mobileOtpValidateAPI = "$nanoServiceUrl/validateOTP";
  static const resetChangeApi = "$nanoServiceUrl/passwordResetOrChange";
  static const changeMpinAPI = "$resetChangeApi/changeMpin";
  static const changePasswordAPI = "$resetChangeApi/changePwd";
  static const resetPasscodeAPI = "$resetChangeApi/pwdReset";

  static const forgetUserNameAPI = "$nanoServiceUrl/forgotUserName/";
  static const securityQuestionAPI = "$nanoServiceUrl/getSecurityQuestion/";
  static const securityQuestionVerificationAPI =
      "$nanoServiceUrl/verifySecurityAnswers";

  /*
    * App Based Other apis
    * 1. Notification api for listing the notification.
    * 2. Get Customer info api
    * 3. Transaction List api
    * 4. Nearest Location api to show merchant location.
  */
  static const notificationListing = "$nanoBankService/getNotifications/";
  static const notificationStatus = "$nanoBankService/viewNotification/SIFR";
  static const getCustomerDetails = "$nanoServiceUrl/getCustomerInfo/";
  static const transactionListing = "$nanoBankService/transactionSearch";
  static const nearestLocation = "$nanoServiceUrl/nearestGeoLocation";
  static const updatePushToken =
      "$nanoServiceUrl/addOrUpdateCustomerInfo/${Constants.instId}/";

  /*
    * Merchant & Customer Amount Transactions
    * 1. Generate QR Code apis
    * 2. CashOut api for withdraw amount.
  */
  static const generateQrCode = "/NanoCustomerService/v1/generateQRCode";
  static const cashOut = "/NanoSmartBanking/v1/smartBanking/cashOut";
  static const mPin = "$nanoServiceUrl/addOrVerifyMpin/${Constants.instId}";

  /*
    * All Account & Card related Apis Only
  */
  static const accountCardList =
      "$nanoServiceUrl/getActiveAccounts/${Constants.instId}/";
  static const accountCardApi = "$nanoServiceUrl/addOrUpdateAccount";
  static const saveAccountCard = "$accountCardApi/addaccount";
  static const verifyAccountCard = "$accountCardApi/verifyaccount";
  static const deLinkAccountCard = "$accountCardApi/delink";
  static const linkAccountCard = "$accountCardApi/link";
  static const primarySwap = "$nanoServiceUrl/primaryaccountswap";
  static const cardToCard = "$primarySwap/cardtocard";
  static const cardToAccount = "$primarySwap/cardtoaccount";
  static const accountToAccount = "$primarySwap/accounttoaccount";
  static const accountToCard = "$primarySwap/accounttocard";
  static const viewBalance = "$nanoBankService/balanceCheck";
  static const addMoney = "$nanoBankService/loadBalance";

  /*
    * KYC Apis
  */
  static const verifyKycInfo = "$nanoServiceUrl/updateKYCStatus/SIFR/";
  static const addOrUpdateKYCInfo = "$nanoServiceUrl/addOrUpdateKYCInfo/SIFR";

  /*
    * Raise complaint Apis
  */
  static const searchComplaintAPI = "$nanoServiceUrl/searchCustomerComplaints/";
  static const addComplaintAPI = "$nanoServiceUrl/raiseComplaint/add/";
  static const processFlowAPI = "$nanoServiceUrl/getAppProcessFlow/SIFR/";

  static const getQrCodeIdApi =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/getQrPaymentID/";
  static const getQrCodeStatusApi =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/checkQRCodeStatus/$terminalId";
  static const getBankApi =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/getbankData/";

  static const terminalId = "10000001";
  static const bankUserId = "AA1234567890";
  static const merchantTag = "UB776WH";
  static const merchantId = "10001";

  static const generateQrCodeAPI =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/registerQRCode";

  static const deleteQrCodeAPI =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/deleteQRCode/$terminalId";
  static const verifyReversalAPI =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/verifyReversal";
  static const confirmReversalAPI =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/confirmReversal";

  static const finalizePaymentApi =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/finalizePaymentChannel";

  static const getTransactionList =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/smartBanking/transactionSearch?page=0&size=8&sortDir=DESC";

  static const getRefundStatus =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/checkRefundStatus";

  static const refundApi =
      "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/refund";
}
