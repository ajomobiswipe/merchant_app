import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/services/alert_service.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/core/widgets/loading_action_content.dart';
import 'package:anet_merchants/features/auth/data/models/password_reset_response_model.dart';
import 'package:anet_merchants/features/auth/domain/usecases/reset_password.dart';

part 'web_reset_password_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String username;

  const ResetPasswordPage({
    super.key,
    required this.username,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSubmitting = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await sl<ResetPassword>()(
      params: ResetPasswordParams(
        username: widget.username,
        currentPassword: _currentPasswordController.text,
        password: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result is DataSuccess<PasswordResetResponseModel> &&
        result.data!.isSuccess) {
      await AlertService.success(
        context,
        title: context.tr('success'),
        message: result.data!.responseMessage.isEmpty
            ? context.tr('reset_password_success')
            : result.data!.responseMessage,
      );

      if (!mounted) return;
      NavigationHelper.goToRoot(context, AppRoutes.login);
      return;
    }

    await AlertService.error(
      context,
      title: context.tr('error'),
      message: result is DataSuccess<PasswordResetResponseModel> &&
              result.data!.responseMessage.isNotEmpty
          ? result.data!.responseMessage
          : result.error?.message ?? context.tr('reset_password_failed'),
    );
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr('current_password_required');
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr('new_password_required');
    }

    if (value == _currentPasswordController.text) {
      return context.tr('new_password_same_as_current');
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr('confirm_password_required');
    }

    if (value != _newPasswordController.text) {
      return context.tr('passwords_do_not_match');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebResetPasswordPage(
        formKey: _formKey,
        currentPasswordController: _currentPasswordController,
        newPasswordController: _newPasswordController,
        confirmPasswordController: _confirmPasswordController,
        isSubmitting: _isSubmitting,
        obscureCurrent: _obscureCurrent,
        obscureNew: _obscureNew,
        obscureConfirm: _obscureConfirm,
        onToggleCurrent: () {
          setState(() => _obscureCurrent = !_obscureCurrent);
        },
        onToggleNew: () {
          setState(() => _obscureNew = !_obscureNew);
        },
        onToggleConfirm: () {
          setState(() => _obscureConfirm = !_obscureConfirm);
        },
        onNewPasswordChanged: (_) => setState(() {}),
        validateCurrentPassword: _validateCurrentPassword,
        validateNewPassword: _validateNewPassword,
        validateConfirmPassword: _validateConfirmPassword,
        onSubmit: _submit,
        onBackToLogin: () => NavigationHelper.goToRoot(
          context,
          AppRoutes.login,
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 18, 26, 34),
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
                    iconSize: 32,
                    tooltip: context.tr('back'),
                  ),
                ),
                const SizedBox(height: 12),
                Image.asset(
                  AppAssets.anetLogoForBrightness(Theme.of(context).brightness),
                  width: 260,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  context.tr('reset_password_title'),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.h2.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('reset_password_instruction'),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.h4.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 34),
                _PasswordField(
                  label: context.tr('current_password'),
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  onToggle: () {
                    setState(() {
                      _obscureCurrent = !_obscureCurrent;
                    });
                  },
                  validator: (value) {
                    return _validateCurrentPassword(value);
                  },
                ),
                const SizedBox(height: 22),
                _PasswordField(
                  label: context.tr('new_password'),
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onToggle: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                  validator: (value) {
                    return _validateNewPassword(value);
                  },
                ),
                const SizedBox(height: 22),
                _PasswordField(
                  label: context.tr('confirm_password'),
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  onToggle: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                  validator: (value) {
                    return _validateConfirmPassword(value);
                  },
                ),
                const SizedBox(height: 34),
                SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? LoadingActionContent(
                            label: context.tr('resetting_password'),
                            color: Colors.white,
                            textStyle: AppTextStyle.h3.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : Text(
                            context.tr('reset_password_submit'),
                            style: AppTextStyle.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
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

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.h4.copyWith(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: AppTextStyle.h4.copyWith(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTextStyle.h4.copyWith(
              color: context.appTextSecondary,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: context.appSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            prefixIcon: Icon(
              Icons.lock_rounded,
              color: AppColors.primaryPurple,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.primaryPurple,
              ),
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
