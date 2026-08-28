import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/fade_slide_in.dart';

/// Public marketing landing page shown to signed-out visitors before they
/// reach /login or /register: a full-bleed hero (headline, subheadline,
/// primary/secondary CTAs, scroll hint) followed by a feature showcase and a
/// closing CTA band. Unlike [AuthScaffold] (the branded side panel on the
/// auth forms themselves) this is a standalone scrollable page.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _scrollController = ScrollController();
  final _featuresKey = GlobalKey();

  void _scrollToFeatures() {
    final ctx = _featuresKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _TopNav(isWide: isWide),
            _HeroSection(
              isWide: isWide,
              onScrollHint: _scrollToFeatures,
            ),
            _FeaturesSection(key: _featuresKey, isWide: isWide),
            _FinalCtaSection(isWide: isWide),
            _Footer(appTitle: l10n.appTitle),
          ],
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 56 : 20,
        vertical: 20,
      ),
      child: Row(
        children: [
          Icon(Icons.hub_rounded, color: scheme.primary, size: 26),
          const SizedBox(width: 10),
          Text(
            l10n.appTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(l10n.signIn),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => context.go('/register'),
            child: Text(l10n.welcomeNavCta),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isWide, required this.onScrollHint});

  final bool isWide;
  final VoidCallback onScrollHint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.86,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient(Theme.of(context).brightness),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _GlowCircle(size: 380, color: Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _GlowCircle(
                size: 320, color: AppTheme.blue300.withOpacity(0.18)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 56 : 24,
              vertical: 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: FadeSlideIn(
                  offset: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.welcomeEyebrow,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.welcomeHeroTitle,
                        textAlign: TextAlign.center,
                        style: (isWide
                                ? Theme.of(context).textTheme.displaySmall
                                : Theme.of(context).textTheme.headlineMedium)
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.welcomeHeroSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 36),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: scheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 18),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            onPressed: () => context.go('/register'),
                            child: Text(l10n.welcomeHeroCtaPrimary),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.6)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 18),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            onPressed: () => context.go('/login'),
                            child: Text(l10n.welcomeHeroCtaSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 56),
                      _ScrollHint(
                          label: l10n.welcomeScrollHint, onTap: onScrollHint),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollHint extends StatelessWidget {
  const _ScrollHint({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            _BouncingChevron(),
          ],
        ),
      ),
    );
  }
}

class _BouncingChevron extends StatefulWidget {
  @override
  State<_BouncingChevron> createState() => _BouncingChevronState();
}

class _BouncingChevronState extends State<_BouncingChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final Animation<double> _offset =
      Tween<double>(begin: 0, end: 8).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _offset.value),
        child: child,
      ),
      child: Icon(Icons.keyboard_arrow_down_rounded,
          color: Colors.white.withOpacity(0.85), size: 28),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = [
      (Icons.people_alt_rounded, l10n.welcomeFeature1Title, l10n.welcomeFeature1Body),
      (Icons.trending_up_rounded, l10n.welcomeFeature2Title, l10n.welcomeFeature2Body),
      (Icons.checklist_rounded, l10n.welcomeFeature3Title, l10n.welcomeFeature3Body),
      (Icons.insights_rounded, l10n.welcomeFeature4Title, l10n.welcomeFeature4Body),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 56 : 20,
        vertical: isWide ? 88 : 56,
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                Text(
                  l10n.welcomeFeaturesTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.welcomeFeaturesSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < features.length; i++)
                FadeSlideIn(
                  delay: FadeSlideIn.staggerDelay(i, stepMs: 60),
                  child: _FeatureCard(
                    icon: features[i].$1,
                    title: features[i].$2,
                    body: features[i].$3,
                    width: isWide ? 260 : 320,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.width,
  });

  final IconData icon;
  final String title;
  final String body;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.primary, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: isWide ? 56 : 20, vertical: isWide ? 24 : 12),
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 56 : 24, vertical: isWide ? 56 : 40),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            l10n.welcomeFinalCtaTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              l10n.welcomeFinalCtaSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: scheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            onPressed: () => context.go('/register'),
            child: Text(l10n.welcomeFinalCtaButton),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.appTitle});

  final String appTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        '© ${DateTime.now().year} $appTitle',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
