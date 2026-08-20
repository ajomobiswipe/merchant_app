import 'package:flutter/material.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/browser_history.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/features/auth/data/models/otp_validation_response_model.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';
import 'package:anet_merchants/features/auth/domain/usecases/verify_email_otp.dart';

class OtpValidationPage extends StatefulWidget {
  final UserInfoModel userInfo;

  const OtpValidationPage({
    super.key,
    required this.userInfo,
  });

  @override
  State<OtpValidationPage> createState() => _OtpValidationPageState();
}

class _OtpValidationPageState extends State<OtpValidationPage> {
  final SessionStorage _sessionStorage = SessionStorage();
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await sl<VerifyEmailOtp>()(
      params: VerifyEmailOtpParams(
        username: widget.userInfo.userName,
        otp: _otpController.text.trim(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);

    if (result is! DataSuccess<OtpValidationResponseModel> ||
        result.data?.isSuccess != true) {
      final message = result.data?.displayMessage.trim().isNotEmpty == true
          ? result.data!.displayMessage
          : result.error?.message ?? context.tr('otp_validation_failed');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    await _sessionStorage.saveLoginResponse(widget.userInfo);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.data!.displayMessage.trim().isEmpty
              ? context.tr('otp_verified')
              : result.data!.displayMessage,
        ),
      ),
    );
    setAuthenticatedHistoryGuard(true);
    NavigationHelper.goToRoot(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => NavigationHelper.backOrGo(
                      context,
                      AppRoutes.login,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: context.appTextPrimary,
                    iconSize: 30,
                  ),
                ),
                const SizedBox(height: 28),
                Image.asset(
                  AppAssets.anetLogoForBrightness(Theme.of(context).brightness),
                  height: 92,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  context.tr('otp_validation_title'),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.h2.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.userInfo.responseMessage.isEmpty
                      ? context.tr('otp_validation_message')
                      : widget.userInfo.responseMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.h4.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: AppTextStyle.h3.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: context.tr('enter_otp'),
                    filled: true,
                    fillColor: context.appSurface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: context.appBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple,
                        width: 1.4,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr('otp_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isSubmitting
                        ? context.tr('loading')
                        : context.tr('verify_otp'),
                    style: AppTextStyle.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
