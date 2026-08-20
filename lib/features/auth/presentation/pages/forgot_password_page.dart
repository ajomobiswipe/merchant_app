import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/utils/contact_launcher.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/features/auth/data/models/forgot_password_response_model.dart';
import 'package:anet_merchants/features/auth/domain/usecases/request_forgot_password.dart';

part 'web_forgot_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const _supportPhone = '+911203129301';
  static const _supportEmail = 'customer.support@alliancenetworkglobal.com';

  final TextEditingController _identifierController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await sl<RequestForgotPassword>()(
      params: RequestForgotPasswordParams(
        username: _identifierController.text.trim(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);

    if (result is! DataSuccess<ForgotPasswordResponseModel> ||
        result.data?.isSuccess != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('forgot_password_failed'))),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('forgot_password_submitted')),
          content: Text(context.tr('forgot_password_submitted_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openContact(Future<bool> Function() launcher) async {
    final opened = await launcher();
    if (!mounted || opened) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('open_contact_failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebForgotPasswordPage(
        formKey: _formKey,
        identifierController: _identifierController,
        isSubmitting: _isSubmitting,
        onSubmit: _submitRequest,
        onPhoneTap: () => _openContact(
          () => ContactLauncher.callPhone(_supportPhone),
        ),
        onEmailTap: () => _openContact(
          () => ContactLauncher.sendEmail(_supportEmail),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
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
                const SizedBox(height: 18),
                Image.asset(
                  AppAssets.anetLogoForBrightness(Theme.of(context).brightness),
                  height: 96,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                Text(
                  context.tr('forgot_password_title'),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.h2.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('forgot_password_instruction'),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.h4.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 34),
                _FieldLabel(context.tr('forgot_password_identifier_label')),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _identifierController,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyle.h4.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: _inputDecoration(
                    context,
                    hintText: context.tr('forgot_password_identifier_hint'),
                    icon: Icons.person_search_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr('forgot_password_identifier_required');
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitRequest(),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isSubmitting
                        ? context.tr('loading')
                        : context.tr('forgot_password_submit'),
                    style: AppTextStyle.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _ContactCard(
                  onPhoneTap: () => _openContact(
                    () => ContactLauncher.callPhone(_supportPhone),
                  ),
                  onEmailTap: () => _openContact(
                    () => ContactLauncher.sendEmail(_supportEmail),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyle.h4.copyWith(
        color: context.appTextSecondary,
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryPurple),
        ),
      ),
      filled: true,
      fillColor: context.appSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: context.appBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primaryPurple, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyle.h4.copyWith(
        color: context.appTextPrimary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final VoidCallback onPhoneTap;
  final VoidCallback onEmailTap;

  const _ContactCard({
    required this.onPhoneTap,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: context.appShadow,
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('connect_with_us'),
            style: AppTextStyle.h3.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _ContactRow(
            icon: Icons.phone_rounded,
            value: _ForgotPasswordPageState._supportPhone,
            onTap: onPhoneTap,
          ),
          Divider(height: 24, color: context.appBorder),
          _ContactRow(
            icon: Icons.email_rounded,
            value: _ForgotPasswordPageState._supportEmail,
            onTap: onEmailTap,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryPurple, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.h5.copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.appTextSecondary,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
