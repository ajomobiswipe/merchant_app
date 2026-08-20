part of 'login.dart';

/// Web-only merchant sign-in page.  Mobile continues to use [Login]'s
/// original compact layout.
class WebLoginPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isSubmitting;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const WebLoginPage({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onRememberMeChanged,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFBFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            return Stack(
              children: [
                Center(
                  child: wide
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 52,
                            vertical: 28,
                          ),
                          child: SizedBox(
                            height: (constraints.maxHeight - 56)
                                .clamp(620, 900)
                                .toDouble(),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1280),
                              child: _DesktopWebLoginContent(
                                page: this,
                                maxHeight: (constraints.maxHeight - 56)
                                    .clamp(620, 900)
                                    .toDouble(),
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 590),
                            child: _CompactWebLoginContent(page: this),
                          ),
                        ),
                ),
                const Positioned(
                  top: 20,
                  right: 28,
                  child: _LoginLanguageButton(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DesktopWebLoginContent extends StatelessWidget {
  final WebLoginPage page;
  final double maxHeight;

  const _DesktopWebLoginContent({
    required this.page,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: maxHeight,
            child: const FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: SizedBox(width: 560, child: _WelcomePanel()),
            ),
          ),
        ),
        const SizedBox(width: 64),
        SizedBox(
          width: 590,
          height: maxHeight,
          child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            child: SizedBox(width: 590, child: _WebSignInCard(page: page)),
          ),
        ),
      ],
    );
  }
}

class _CompactWebLoginContent extends StatelessWidget {
  final WebLoginPage page;

  const _CompactWebLoginContent({required this.page});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 590),
        child: Column(
          children: [
            Image.asset(
              AppAssets.anetIcon,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              semanticLabel: 'ANET Merchants',
            ),
            const SizedBox(height: 12),
            _WebSignInCard(page: page, compact: true),
          ],
        ),
      );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppAssets.anetLogoForBrightness(
              isDark ? Brightness.dark : Brightness.light,
            ),
            width: 330,
          ),
          const SizedBox(height: 62),
          Text(
            'Welcome Back!',
            style: AppTextStyle.h2.copyWith(
              color: const Color(0xff202331),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to access your merchant dashboard\nand manage your business securely.',
            style: AppTextStyle.h4.copyWith(
              color: const Color(0xff65708E),
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          const _WebPromoCarousel(),
        ],
      ),
    );
  }
}

class _WebPromoCarousel extends StatefulWidget {
  const _WebPromoCarousel();

  @override
  State<_WebPromoCarousel> createState() => _WebPromoCarouselState();
}

class _WebPromoCarouselState extends State<_WebPromoCarousel> {
  static const _slides = [
    _WebPromoSlide(
      image: AppAssets.webPromoSecurity,
      title: 'Fintech Security',
      caption:
          'End-to-end security helps protect every digital financial transaction.',
    ),
    _WebPromoSlide(
      image: AppAssets.webPromoDashboard,
      title: 'Manage your business securely online',
      caption:
          'Track payments, settlements and business performance from one place.',
    ),
  ];

  final PageController _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemBuilder: (context, index) => Image.asset(
              _slides[index].image,
              fit: BoxFit.contain,
              semanticLabel: _slides[index].title,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: Column(
            key: ValueKey(_currentPage),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _slides[_currentPage].title,
                style: AppTextStyle.h3.copyWith(
                  color: const Color(0xff202331),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _slides[_currentPage].caption,
                style: AppTextStyle.h4.copyWith(
                  color: const Color(0xff65708E),
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(
            _slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: _currentPage == index ? 28 : 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primaryPurple
                    : AppColors.primaryPurple.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WebPromoSlide {
  final String image;
  final String title;
  final String caption;

  const _WebPromoSlide({
    required this.image,
    required this.title,
    required this.caption,
  });
}

class _WebSignInCard extends StatelessWidget {
  final WebLoginPage page;
  final bool compact;

  const _WebSignInCard({required this.page, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 20 : 30,
        compact ? 22 : 34,
        compact ? 20 : 30,
        compact ? 20 : 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x160E0A2B), blurRadius: 36, offset: Offset(0, 14)),
        ],
      ),
      child: Form(
        key: page.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MerchantSignInTitle(compact: compact),
            SizedBox(height: compact ? 20 : 32),
            _FieldLabel(context.tr('username_label'), compact: compact),
            SizedBox(height: compact ? 8 : 9),
            _LoginTextField(
              controller: page.usernameController,
              icon: Icons.person_rounded,
              hintText: context.tr('username_hint'),
              compact: compact,
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.tr('username_required')
                  : null,
            ),
            SizedBox(height: compact ? 18 : 22),
            _FieldLabel(context.tr('password_label'), compact: compact),
            SizedBox(height: compact ? 8 : 9),
            _LoginTextField(
              controller: page.passwordController,
              icon: Icons.lock_rounded,
              hintText: context.tr('password_hint'),
              obscureText: page.obscurePassword,
              compact: compact,
              suffixIcon: IconButton(
                onPressed: page.onTogglePassword,
                icon: Icon(
                  page.obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.primaryPurple,
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? context.tr('password_required')
                  : null,
            ),
            SizedBox(height: compact ? 12 : 16),
            _RememberMeRow(
              value: page.rememberMe,
              onChanged: page.onRememberMeChanged,
              compact: compact,
            ),
            SizedBox(height: compact ? 20 : 24),
            _SignInButton(
              onPressed: page.onSubmit,
              compact: compact,
              isLoading: page.isSubmitting,
            ),
            SizedBox(height: compact ? 10 : 14),
            Center(
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: Text(
                  context.tr('forgot_password'),
                  style: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 8 : 10),
            _OrDivider(compact: compact),
            SizedBox(height: compact ? 16 : 22),
            _ConnectCard(compact: compact),
          ],
        ),
      ),
    );
  }
}
