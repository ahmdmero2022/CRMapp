import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/fade_slide_in.dart';

/// Shared centered-card layout for login/register: a brand panel on wide
/// screens, collapsing to a single column on narrow/mobile widths.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 900;

    final formPanel = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: FadeSlideIn(
            offset: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isWide) ...[
                  Icon(Icons.hub_rounded, color: scheme.primary, size: 40),
                  const SizedBox(height: 16),
                ],
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    );

    if (!isWide) {
      return Scaffold(body: formPanel);
    }

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient(Theme.of(context).brightness),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -80,
                    right: -60,
                    child: _GlowCircle(
                      size: 320,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -60,
                    child: _GlowCircle(
                      size: 280,
                      color: AppTheme.blue300.withOpacity(0.18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.hub_rounded,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          l10n.appTitle,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.authTagline,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white.withOpacity(0.85)),
                        ),
                        const SizedBox(height: 40),
                        const _HeroMockupCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: formPanel),
        ],
      ),
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

/// A stylized, hand-drawn stand-in for a product screenshot: a bar chart plus
/// a pipeline-stage row, echoing the dashboard and deals kanban so the hero
/// panel visually hints at what the app does without shipping a real image.
class _HeroMockupCard extends StatelessWidget {
  const _HeroMockupCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              _bar(width: 76, height: 8, opacity: 0.45),
              const Spacer(),
              _bar(width: 36, height: 8, opacity: 0.25),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final h in [22.0, 40.0, 28.0, 52.0, 34.0])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: _bar(width: 16, height: h, opacity: 0.55, radius: 5),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _stageDot(opacity: 0.95),
              _connector(),
              _stageDot(opacity: 0.95),
              _connector(),
              _stageDot(opacity: 0.55),
              _connector(faded: true),
              _stageDot(opacity: 0.3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar({
    required double width,
    required double height,
    required double opacity,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _stageDot({required double opacity}) => Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );

  Widget _connector({bool faded = false}) => Expanded(
        child: Container(
          height: 2,
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
          color: Colors.white.withOpacity(faded ? 0.15 : 0.3),
        ),
      );
}
