part of 'reset_password_page.dart';

/// Browser-only reset-password presentation. The reset request, validation,
/// loading state, and navigation remain owned by [ResetPasswordPage].
class WebResetPasswordPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool isSubmitting;
  final bool obscureCurrent;
  final bool obscureNew;
  final bool obscureConfirm;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final ValueChanged<String> onNewPasswordChanged;
  final FormFieldValidator<String> validateCurrentPassword;
  final FormFieldValidator<String> validateNewPassword;
  final FormFieldValidator<String> validateConfirmPassword;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  const WebResetPasswordPage({
    super.key,
    required this.formKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.isSubmitting,
    required this.obscureCurrent,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onNewPasswordChanged,
    required this.validateCurrentPassword,
    required this.validateNewPassword,
    required this.validateConfirmPassword,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFAFE),
      body: SafeArea(
        child: Column(
          children: [
            _ResetWebTopBar(onBackToLogin: onBackToLogin),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 960;
                  final horizontalPadding = constraints.maxWidth >= 1280
                      ? 40.0
                      : constraints.maxWidth >= 700
                          ? 28.0
                          : 16.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isDesktop ? 30 : 18,
                      horizontalPadding,
                      30,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1420),
                        child: _ResetWebCard(
                          page: this,
                          isDesktop: isDesktop,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetWebTopBar extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const _ResetWebTopBar({required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffE8E2F1))),
      ),
      child: Row(
        children: [
          Image.asset(
            AppAssets.anetIcon,
            width: 38,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'ANET Merchants',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.h3.copyWith(
                color: const Color(0xff15131B),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onBackToLogin,
            icon: const Icon(Icons.arrow_forward_rounded, size: 19),
            label: Text(context.tr('back_to_login')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: BorderSide(
                color: AppColors.primaryPurple.withValues(alpha: .30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetWebCard extends StatelessWidget {
  final WebResetPasswordPage page;
  final bool isDesktop;

  const _ResetWebCard({required this.page, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final form = _ResetWebForm(page: page, isDesktop: isDesktop);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffEDE8F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160C0623),
            blurRadius: 34,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(flex: 9, child: _ResetWebHero()),
                  Expanded(flex: 11, child: form),
                ],
              ),
            )
          : form,
    );
  }
}

class _ResetWebHero extends StatelessWidget {
  const _ResetWebHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 690),
      padding: const EdgeInsets.fromLTRB(50, 54, 50, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffFCFBFF), Color(0xffF4EFFF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('login_welcome_title'),
            style: AppTextStyle.h4.copyWith(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${context.tr('secure_your')}\n'),
                TextSpan(
                  text: context.tr('merchant_account'),
                  style: TextStyle(color: AppColors.primaryPurple),
                ),
              ],
            ),
            style: AppTextStyle.h2.copyWith(
              color: const Color(0xff171936),
              fontSize: 35,
              height: 1.22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Text(
              context.tr('reset_password_hero_message'),
              style: AppTextStyle.h4.copyWith(
                color: const Color(0xff66708B),
                fontSize: 16,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Image.asset(
              AppAssets.webResetPasswordIllustration,
              height: 350,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetWebForm extends StatelessWidget {
  final WebResetPasswordPage page;
  final bool isDesktop;

  const _ResetWebForm({required this.page, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final password = page.newPasswordController.text;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 58 : 22,
        vertical: isDesktop ? 50 : 30,
      ),
      child: Form(
        key: page.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('reset_password_title'),
              style: AppTextStyle.h2.copyWith(
                color: const Color(0xff171936),
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('reset_password_instruction'),
              style: AppTextStyle.h4.copyWith(
                color: const Color(0xff66708B),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isDesktop ? 32 : 26),
            _ResetWebPasswordField(
              label: context.tr('current_password'),
              hint: context.tr('current_password_hint'),
              controller: page.currentPasswordController,
              obscureText: page.obscureCurrent,
              onToggle: page.onToggleCurrent,
              validator: page.validateCurrentPassword,
            ),
            const SizedBox(height: 20),
            _ResetWebPasswordField(
              label: context.tr('new_password'),
              hint: context.tr('new_password_hint'),
              controller: page.newPasswordController,
              obscureText: page.obscureNew,
              onToggle: page.onToggleNew,
              onChanged: page.onNewPasswordChanged,
              validator: page.validateNewPassword,
            ),
            const SizedBox(height: 20),
            _ResetWebPasswordField(
              label: context.tr('confirm_password'),
              hint: context.tr('confirm_password_hint'),
              controller: page.confirmPasswordController,
              obscureText: page.obscureConfirm,
              onToggle: page.onToggleConfirm,
              validator: page.validateConfirmPassword,
              onFieldSubmitted: (_) {
                if (!page.isSubmitting) page.onSubmit();
              },
            ),
            const SizedBox(height: 26),
            _PasswordRequirements(password: password),
            const SizedBox(height: 26),
            SizedBox(
              height: 58,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple,
                      const Color(0xff8B18EE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: .20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: page.isSubmitting ? null : page.onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyle.h3.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: page.isSubmitting
                      ? LoadingActionContent(
                          label: context.tr('resetting_password'),
                          color: Colors.white,
                          textStyle: AppTextStyle.h3.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded),
                            const SizedBox(width: 12),
                            Text(context.tr('reset_password_submit')),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetWebPasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const _ResetWebPasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscureText,
    required this.onToggle,
    required this.validator,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.h5.copyWith(
            color: const Color(0xff171936),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: onFieldSubmitted == null
              ? TextInputAction.next
              : TextInputAction.done,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: AppTextStyle.h4.copyWith(
            color: const Color(0xff171936),
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyle.h4.copyWith(
              color: const Color(0xff9298A9),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primaryPurple,
              size: 22,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.primaryPurple,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffDED7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.primaryPurple,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  final String password;

  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    final requirements = [
      (context.tr('password_minimum_characters'), password.length >= 8),
      (
        context.tr('password_uppercase_letter'),
        RegExp('[A-Z]').hasMatch(password)
      ),
      (context.tr('password_number'), RegExp('[0-9]').hasMatch(password)),
      (
        context.tr('password_special_character'),
        RegExp(r'[^A-Za-z0-9\s]').hasMatch(password),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xffF8F5FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('password_must_contain'),
                  style: AppTextStyle.h5.copyWith(
                    color: const Color(0xff171936),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 11,
                  children: requirements
                      .map(
                        (requirement) => SizedBox(
                          width: 190,
                          child: Row(
                            children: [
                              Icon(
                                requirement.$2
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: requirement.$2
                                    ? AppColors.successGreen
                                    : const Color(0xffA8ADBA),
                                size: 17,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  requirement.$1,
                                  style: AppTextStyle.h5.copyWith(
                                    color: const Color(0xff66708B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
