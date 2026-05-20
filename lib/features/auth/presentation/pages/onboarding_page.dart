import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart' show AppSpacing, AppRadius;
import '../../../../core/theme/app_typography.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      headline: 'Split the bill.\nNot the friendship.',
      body: 'Add expenses as they happen. Everyone in the group sees the tally in real time.',
    ),
    _SlideData(
      headline: 'Everyone sees who owes what.',
      body: 'No awkward reminders. Ledger keeps the numbers honest so you don\'t have to.',
    ),
    _SlideData(
      headline: 'Settle with one tap.',
      body: 'Mark a balance as settled and move on. Done.',
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  return _SlidePage(data: _slides[index]);
                },
              ),
            ),
            _DotsIndicator(count: _slides.length, current: _currentPage),
            const SizedBox(height: AppSpacing.s6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
              child: _currentPage < _slides.length - 1
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _next,
                            child: const Text('Next'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.signIn),
                          child: const Text('Sign in'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.register),
                          child: const Text('Get started'),
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.signIn),
                          child: const Text('Sign in instead'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.data});

  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s12,
        AppSpacing.s6,
        AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IllustrationPlaceholder(),
          const SizedBox(height: AppSpacing.s10),
          Text(
            data.headline,
            style: AppTypography.xxl(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 68 * 8.0),
            child: Text(
              data.body,
              style: AppTypography.base(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// Abstract geometry placeholder — three overlapping circles, no clipart.
class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(painter: _CirclesPainter()),
    );
  }
}

class _CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDim
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final r = size.height * 0.42;
    final y = size.height * 0.5;
    final spacing = r * 0.9;

    for (var i = 0; i < 3; i++) {
      final cx = size.width * 0.25 + i * spacing;
      canvas.drawCircle(Offset(cx, y), r, paint);
      canvas.drawCircle(Offset(cx, y), r, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_CirclesPainter oldDelegate) => false;
}

// Dot indicator using scaleX transform as per DESIGN.md.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
      child: Row(
        children: List.generate(count, (i) {
          final isActive = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(right: AppSpacing.s2),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          );
        }),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({required this.headline, required this.body});

  final String headline;
  final String body;
}
