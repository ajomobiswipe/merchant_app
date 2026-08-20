part of 'forgot_password_page.dart';

/// Responsive browser-only forgotten-password screen.
class WebForgotPasswordPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onPhoneTap;
  final VoidCallback onEmailTap;

  const WebForgotPasswordPage({
    super.key,
    required this.formKey,
    required this.identifierController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onPhoneTap,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFBFF),
      body: SafeArea(
        child: Column(
          children: [
            const _WebForgotTopBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
                  final content = wide
                      ? _WebForgotDesktopContent(page: this)
                      : _WebForgotCompactContent(page: this);
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(wide ? 36 : 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1300),
                        child: content,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text('© 2026 Alliance Network™. All rights reserved.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebForgotTopBar extends StatelessWidget {
  const _WebForgotTopBar();

  @override
  Widget build(BuildContext context) => Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 34),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xffE8E2F1))),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => NavigationHelper.backOrGo(
                context,
                AppRoutes.login,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              color: const Color(0xff201D27),
              tooltip: context.tr('back'),
            ),
            const SizedBox(width: 8),
            Image.asset(AppAssets.anetLogo, height: 58, fit: BoxFit.contain),
            const Spacer(),
            const _WebLanguageMenu(),
          ],
        ),
      );
}

class _WebLanguageMenu extends StatelessWidget {
  const _WebLanguageMenu();

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        icon: const Icon(Icons.language_rounded, size: 20),
        label: Text(languageLabel(appLanguageController.language)),
        onPressed: () async {
          final language = await showMenu<AppLanguage>(
            context: context,
            position: const RelativeRect.fromLTRB(1000, 70, 24, 0),
            items: AppLanguage.values
                .map(
                  (language) => PopupMenuItem(
                    value: language,
                    child: Text(languageLabel(language)),
                  ),
                )
                .toList(),
          );
          if (language != null) appLanguageController.setLanguage(language);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side:
              BorderSide(color: AppColors.primaryPurple.withValues(alpha: .5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
}

class _WebForgotDesktopContent extends StatelessWidget {
  final WebForgotPasswordPage page;
  const _WebForgotDesktopContent({required this.page});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(child: _WebForgotWelcome()),
          const SizedBox(width: 70),
          SizedBox(width: 610, child: _WebForgotRequestColumn(page: page)),
        ],
      );
}

class _WebForgotCompactContent extends StatelessWidget {
  final WebForgotPasswordPage page;
  const _WebForgotCompactContent({required this.page});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 610),
        child: Column(
          children: [
            Image.asset(AppAssets.anetIcon, width: 72),
            const SizedBox(height: 20),
            _WebForgotRequestColumn(page: page),
          ],
        ),
      );
}

class _WebForgotWelcome extends StatelessWidget {
  const _WebForgotWelcome();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            Image.asset(
              AppAssets.webForgotPasswordIllustration,
              width: 560,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('forgot_password_title'),
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
                color: const Color(0xff65708E),
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

class _WebForgotRequestColumn extends StatelessWidget {
  final WebForgotPasswordPage page;
  const _WebForgotRequestColumn({required this.page});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: _webCardDecoration(),
            child: Form(
              key: page.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _webIcon(Icons.manage_accounts_rounded),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Your Details',
                              style: AppTextStyle.h2.copyWith(
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              context.tr('forgot_password_instruction'),
                              style: AppTextStyle.h5.copyWith(
                                  color: const Color(0xff65708E),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  _FieldLabel(context.tr('forgot_password_identifier_label')),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: page.identifierController,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => page.onSubmit(),
                    decoration: _webInputDecoration(context),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.tr('forgot_password_identifier_required')
                        : null,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 62,
                    child: ElevatedButton(
                      onPressed: page.isSubmitting ? null : page.onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              page.isSubmitting
                                  ? context.tr('loading')
                                  : context.tr('forgot_password_submit'),
                              style: AppTextStyle.h4.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900)),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_rounded, size: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          _ContactCard(
              onPhoneTap: page.onPhoneTap, onEmailTap: page.onEmailTap),
        ],
      );
}

BoxDecoration _webCardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
            color: Color(0x180E0A2B), blurRadius: 30, offset: Offset(0, 12))
      ],
    );

Widget _webIcon(IconData icon) => Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
          color: AppColors.primaryPurple.withValues(alpha: .12),
          shape: BoxShape.circle),
      child: Icon(icon, color: AppColors.primaryPurple, size: 28),
    );

InputDecoration _webInputDecoration(BuildContext context) => InputDecoration(
      hintText: context.tr('forgot_password_identifier_hint'),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(10),
        child: _webIcon(Icons.person_search_rounded),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 74, minHeight: 58),
      contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 16),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffDED8E8))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primaryPurple, width: 1.4)),
    );
