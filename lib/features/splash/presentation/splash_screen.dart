import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../provider/adaptive_app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final provider = context.read<AdaptiveAppProvider>();
    if (provider.hasCompletedOnboarding) {
      context.go('/dashboard');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(100),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .shimmer(delay: 800.ms, duration: 1000.ms),

            const SizedBox(height: 32),

            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            Text(
              AppConstants.tagline,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 48),

            const CircularProgressIndicator(
              color: AppColors.progress,
              strokeWidth: 2,
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
