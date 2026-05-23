import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      icon: Icons.search_rounded,
      gradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      title: 'Discover Services',
      subtitle:
          'Browse thousands of trusted event professionals — photographers, caterers, DJs and more.',
      imagePath: 'discover',
    ),
    _OnboardPage(
      icon: Icons.calendar_month_rounded,
      gradient: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
      title: 'Book Instantly',
      subtitle:
          'Check availability, compare prices, and confirm bookings in seconds. Pay just 25% upfront.',
      imagePath: 'book',
    ),
    _OnboardPage(
      icon: Icons.star_rounded,
      gradient: [Color(0xFF10B981), Color(0xFF0EA5E9)],
      title: 'Your Event, Perfect',
      subtitle:
          'Chat with your service provider, track progress, and rate the experience after your event.',
      imagePath: 'celebrate',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B0F1A), Color(0xFF111827)],
              ),
            ),
          ),

          // Animated background orb that follows page
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: -size.height * 0.15,
            right: _page == 0
                ? -size.width * 0.2
                : _page == 1
                    ? size.width * 0.1
                    : size.width * 0.3,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(_pages[_page].gradient[0].value)
                        .withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Skip button
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () => context.go('/login?role=customer'),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _PageContent(page: _pages[i]),
                ),
              ),

              // Dots + button
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Page dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _page == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _page == i
                                  ? AppColors.electricBlue
                                  : Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Action button
                      GestureDetector(
                        onTap: () {
                          if (_page < _pages.length - 1) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            context.go('/login?role=customer');
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _pages[_page].gradient,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Color(_pages[_page].gradient[0].value)
                                    .withValues(alpha: 0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _page < _pages.length - 1
                                  ? 'Continue'
                                  : 'Get Started',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String imagePath;

  const _OnboardPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration area
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  page.gradient[0].withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: page.gradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: page.gradient[0].withValues(alpha: 0.4),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(page.icon, color: Colors.white, size: 56),
              ),
            ),
          )
              .animate()
              .scale(
                duration: 500.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
              )
              .fadeIn(duration: 300.ms),

          const SizedBox(height: 48),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
