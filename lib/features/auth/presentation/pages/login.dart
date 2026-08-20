import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/responsive_layout.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/services/alert_service.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/browser_history.dart';
import 'package:anet_merchants/core/utils/contact_launcher.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/core/widgets/loading_action_content.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anet_merchants/features/auth/presentation/bloc/login/bloc/auth_bloc.dart';

part 'web_login_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static const _rememberMeKey = 'remember_me';
  static const _savedUsernameKey = 'saved_username';
  static const _savedPasswordKey = 'saved_password';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SessionStorage _sessionStorage = SessionStorage();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoginSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldRemember = prefs.getBool(_rememberMeKey) ?? false;

    if (!mounted) return;

    setState(() {
      _rememberMe = shouldRemember;
      if (shouldRemember) {
        _usernameController.text = prefs.getString(_savedUsernameKey) ?? '';
        _passwordController.text = prefs.getString(_savedPasswordKey) ?? '';
      }
    });
  }

  Future<void> _persistCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_savedUsernameKey, _usernameController.text.trim());
      await prefs.setString(_savedPasswordKey, _passwordController.text);
      return;
    }

    await prefs.setBool(_rememberMeKey, false);
    await prefs.remove(_savedUsernameKey);
    await prefs.remove(_savedPasswordKey);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(
    BuildContext context,
    AuthState state,
  ) async {
    if (state is AuthLoading) {
      return;
    }

    if (_isLoginSubmitting && mounted) {
      setState(() => _isLoginSubmitting = false);
    }

    if (state is AuthSuccess) {
      try {
        await _sessionStorage.saveLoginResponse(state.userinfo!);
      } catch (_) {
        if (!context.mounted) return;
        await AlertService.error(
          context,
          title: context.tr('login_failed'),
          message: context.tr('secure_session_unavailable'),
        );
        return;
      }

      if (!context.mounted) return;
      setAuthenticatedHistoryGuard(true);
      NavigationHelper.goToRoot(context, AppRoutes.home);
      return;
    }

    if (state is AuthOtpRequired) {
      if (!context.mounted) return;

      await AlertService.success(
        context,
        title: context.tr('success'),
        message: state.userinfo!.responseMessage.trim().isEmpty
            ? context.tr('otp_sent')
            : state.userinfo!.responseMessage,
      );

      if (!context.mounted) return;
      context.push(AppRoutes.otpValidation, extra: state.userinfo);
      return;
    }

    if (state is AuthPasswordResetRequired) {
      if (!context.mounted) return;

      await AlertService.warning(
        context,
        title: context.tr('reset_password_required'),
        message: state.message.isEmpty
            ? context.tr('reset_password_required_message')
            : state.message,
      );

      if (!context.mounted) return;
      context.push(AppRoutes.resetPassword, extra: state.username);
      return;
    }

    if (state is AuthFailure) {
      final errorMessage = state.error?.message ?? context.tr('unknown_error');
      await AlertService.error(
        context,
        title: context.tr('login_failed'),
        message: errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return BlocListener<AuthBloc, AuthState>(
        listener: _onAuthStateChanged,
        child: WebLoginPage(
          formKey: _formKey,
          usernameController: _usernameController,
          passwordController: _passwordController,
          rememberMe: _rememberMe,
          obscurePassword: _obscurePassword,
          isSubmitting: _isLoginSubmitting,
          onRememberMeChanged: (value) => setState(() => _rememberMe = value),
          onTogglePassword: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          onSubmit: _submitLogin,
        ),
      );
    }

    final isDesktop = AppBreakpoints.isDesktop(context);
    final compact = !isDesktop;

    return Scaffold(
      backgroundColor: context.appBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: _onAuthStateChanged,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 520 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 20 : 26,
                      isDesktop ? 56 : 20,
                      compact ? 20 : 26,
                      compact ? 24 : 34,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (compact) ...[
                            const _MobileLoginHero(),
                            const SizedBox(height: 14),
                          ] else ...[
                            const _LoginLogo(),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                context.tr('login_subtitle'),
                                style: AppTextStyle.h4.copyWith(
                                  color: const Color(0xff667085),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                          Container(
                            padding: compact
                                ? const EdgeInsets.fromLTRB(20, 24, 20, 20)
                                : EdgeInsets.zero,
                            decoration: compact
                                ? BoxDecoration(
                                    color: context.appSurface,
                                    borderRadius: BorderRadius.circular(28),
                                    border:
                                        Border.all(color: context.appBorder),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.appShadow,
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _MerchantSignInTitle(compact: compact),
                                SizedBox(height: compact ? 22 : 34),
                                _FieldLabel(
                                  context.tr('username_label'),
                                  compact: compact,
                                ),
                                SizedBox(height: compact ? 8 : 10),
                                _LoginTextField(
                                  controller: _usernameController,
                                  icon: Icons.person_rounded,
                                  hintText: context.tr('username_hint'),
                                  compact: compact,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return context.tr('username_required');
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: compact ? 18 : 24),
                                _FieldLabel(
                                  context.tr('password_label'),
                                  compact: compact,
                                ),
                                SizedBox(height: compact ? 8 : 10),
                                _LoginTextField(
                                  controller: _passwordController,
                                  icon: Icons.lock_rounded,
                                  hintText: context.tr('password_hint'),
                                  obscureText: _obscurePassword,
                                  compact: compact,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: AppColors.primaryPurple,
                                    ),
                                    tooltip: _obscurePassword
                                        ? context.tr('show_password')
                                        : context.tr('hide_password'),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return context.tr('password_required');
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: compact ? 12 : 18),
                                _RememberMeRow(
                                  value: _rememberMe,
                                  compact: compact,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value;
                                    });
                                  },
                                ),
                                SizedBox(height: compact ? 20 : 28),
                                _SignInButton(
                                  onPressed: _submitLogin,
                                  compact: compact,
                                  isLoading: _isLoginSubmitting,
                                ),
                                SizedBox(height: compact ? 14 : 24),
                                Center(
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push(AppRoutes.forgotPassword),
                                    child: Text(
                                      context.tr('forgot_password'),
                                      style: (compact
                                              ? AppTextStyle.h5
                                              : AppTextStyle.h4)
                                          .copyWith(
                                        color: AppColors.primaryPurple,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 16 : 26),
                                _OrDivider(compact: compact),
                                SizedBox(height: compact ? 18 : 28),
                                _ConnectCard(compact: compact),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: compact ? 8 : 24,
                right: compact ? 20 : 26,
                child: const _LoginLanguageButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (_isLoginSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoginSubmitting = true);

    try {
      await _persistCredentials();
      if (!mounted) return;

      context.read<AuthBloc>().add(
            LoginPressed(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    } catch (_) {
      if (mounted) {
        setState(() => _isLoginSubmitting = false);
      }
      rethrow;
    }
  }
}

class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    const logoWidth = 300.0;

    return Center(
      child: SizedBox(
        // Enforce the wordmark's 3:1 area. This prevents a parent layout from
        // expanding the asset on high-density mobile screens.
        width: logoWidth,
        height: logoWidth / 3,
        child: Image.asset(
          AppAssets.anetLogoForBrightness(Theme.of(context).brightness),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _MobileLoginHero extends StatelessWidget {
  const _MobileLoginHero();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoWidth = (screenWidth * .40).clamp(132.0, 180.0);

    return SizedBox(
      height: 315,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: .11),
                    context.appBackground,
                    context.appBackground,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 0,
            child: SizedBox(
              width: logoWidth,
              height: logoWidth / 3,
              child: Image.asset(
                AppAssets.anetLogoForBrightness(
                  Theme.of(context).brightness,
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 104,
            left: 0,
            width: screenWidth * .48,
            child: Text(
              context.tr('login_welcome_title'),
              style: AppTextStyle.h2.copyWith(
                color: context.appTextPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.08,
              ),
            ),
          ),
          Positioned(
            top: 190,
            left: 0,
            width: screenWidth * .50,
            child: Text(
              context.tr('login_subtitle'),
              style: AppTextStyle.h4.copyWith(
                color: context.appTextSecondary,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          Positioned(
            top: 64,
            right: -84,
            child: IgnorePointer(
              child: Image.asset(
                AppAssets.loginMerchantHero,
                width: screenWidth * .92,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginLanguageButton extends StatelessWidget {
  const _LoginLanguageButton();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLanguageController,
      builder: (context, _) {
        return Tooltip(
          message: languageLabel(appLanguageController.language),
          child: OutlinedButton.icon(
            onPressed: () => _showLanguageDialog(context),
            icon: const Icon(Icons.language_rounded, size: 20),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appLanguageController.language.name
                      .substring(0, 3)
                      .toUpperCase(),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ],
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: BorderSide(
                color: AppColors.primaryPurple.withValues(alpha: .5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AnimatedBuilder(
          animation: appLanguageController,
          builder: (context, _) {
            return AlertDialog(
              title: Text(dialogContext.tr('select_language')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppLanguage.values.map((language) {
                  final selected = appLanguageController.language == language;

                  return ListTile(
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected
                          ? AppColors.primaryPurple
                          : dialogContext.appTextSecondary,
                    ),
                    title: Text(languageLabel(language)),
                    onTap: () {
                      appLanguageController.setLanguage(language);
                      Navigator.of(dialogContext).pop();
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class _MerchantSignInTitle extends StatelessWidget {
  final bool compact;

  const _MerchantSignInTitle({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(color: Color(0xffE3D4FA), thickness: 1.5)),
        SizedBox(width: compact ? 10 : 16),
        Container(
          width: compact ? 40 : 48,
          height: compact ? 40 : 48,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shield_rounded,
            color: AppColors.primaryPurple,
            size: compact ? 22 : 26,
          ),
        ),
        SizedBox(width: compact ? 9 : 12),
        Text(
          context.tr('login_title'),
          style: (compact ? AppTextStyle.h3 : AppTextStyle.h2).copyWith(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(width: compact ? 10 : 16),
        const Expanded(
            child: Divider(color: Color(0xffE3D4FA), thickness: 1.5)),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool compact;

  const _FieldLabel(this.label, {this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
        color: context.appTextPrimary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final bool compact;
  final Widget? suffixIcon;
  final String? Function(String?) validator;

  const _LoginTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    required this.validator,
    this.obscureText = false,
    this.compact = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
        color: context.appTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
          color: context.appTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: context.appSurface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: compact ? 14 : 20,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 14 : 18,
            compact ? 8 : 10,
            compact ? 12 : 16,
            compact ? 8 : 10,
          ),
          child: Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(compact ? 12 : 14),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryPurple,
              size: compact ? 23 : 26,
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: compact ? 64 : 78,
          minHeight: compact ? 54 : 64,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 16 : 18),
          borderSide: BorderSide(color: context.appBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 16 : 18),
          borderSide: BorderSide(
            color: AppColors.primaryPurple,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 16 : 18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 16 : 18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: validator,
    );
  }
}

class _RememberMeRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool compact;

  const _RememberMeRow({
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          SizedBox(
            width: compact ? 24 : 28,
            height: compact ? 24 : 28,
            child: Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked ?? false),
              activeColor: AppColors.primaryPurple,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Text(
            context.tr('remember_me'),
            style: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool compact;
  final bool isLoading;

  const _SignInButton({
    required this.onPressed,
    required this.isLoading,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 54 : 64,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          disabledBackgroundColor:
              AppColors.primaryPurple.withValues(alpha: .82),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 10,
          shadowColor: AppColors.primaryPurple.withValues(alpha: .35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? LoadingActionContent(
                label: context.tr('login_logging_in'),
                color: Colors.white,
                textStyle: (compact ? AppTextStyle.h4 : AppTextStyle.h3)
                    .copyWith(fontWeight: FontWeight.w900),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    context.tr('sign_in'),
                    style:
                        (compact ? AppTextStyle.h4 : AppTextStyle.h3).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: compact ? 26 : 30,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  final bool compact;

  const _OrDivider({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(color: Color(0xffE3D4FA), thickness: 1.5)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
          child: Text(
            context.tr('or'),
            style: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Expanded(
            child: Divider(color: Color(0xffE3D4FA), thickness: 1.5)),
      ],
    );
  }
}

class _ConnectCard extends StatelessWidget {
  final bool compact;

  const _ConnectCard({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 24,
        compact ? 16 : 22,
        compact ? 18 : 24,
        compact ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: .08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _ConnectHeader(compact: compact),
          SizedBox(height: compact ? 10 : 16),
          Divider(color: context.appBorder),
          _ContactRow(
            icon: Icons.phone_rounded,
            text: '+911203129301',
            type: _ContactType.phone,
            compact: compact,
          ),
          Divider(color: context.appBorder),
          _ContactRow(
            icon: Icons.mail_rounded,
            text: 'customer.support@alliancenetworkglobal.com',
            type: _ContactType.email,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _ConnectHeader extends StatelessWidget {
  final bool compact;

  const _ConnectHeader({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compact ? 42 : 48,
          height: compact ? 42 : 48,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.groups_rounded,
            color: AppColors.primaryPurple,
            size: compact ? 24 : 28,
          ),
        ),
        SizedBox(width: compact ? 12 : 18),
        Expanded(
          child: Text(
            context.tr('connect_with_us'),
            style: (compact ? AppTextStyle.h4 : AppTextStyle.h3).copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final _ContactType type;
  final bool compact;

  const _ContactRow({
    required this.icon,
    required this.text,
    required this.type,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchContact(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 8 : 12),
        child: Row(
          children: [
            Container(
              width: compact ? 42 : 48,
              height: compact ? 42 : 48,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: compact ? 23 : 26,
              ),
            ),
            SizedBox(width: compact ? 12 : 18),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryPurple,
              size: compact ? 28 : 32,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchContact(BuildContext context) async {
    final launched = type == _ContactType.phone
        ? await ContactLauncher.callPhone(text)
        : await ContactLauncher.sendEmail(text);

    if (!context.mounted || launched) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('open_contact_failed'))),
    );
  }
}

enum _ContactType { phone, email }
