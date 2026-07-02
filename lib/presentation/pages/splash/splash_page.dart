import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../injection/injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showBiometricRetry = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  Future<void> _authenticateBiometrics(AuthState state) async {
    final enabled = await sl<AuthRepository>().isBiometricEnabled();
    if (enabled) {
      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        _proceedToApp(state);
      } else {
        setState(() {
          _showBiometricRetry = true;
        });
      }
    } else {
      _proceedToApp(state);
    }
  }

  void _proceedToApp(AuthState state) {
    if (state is AuthAuthenticated) {
      final pending = DeeplinkService.consumePending();
      if (pending != null) {
        context.go('/pay', extra: pending);
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _authenticateBiometrics(state);
        } else if (state is AuthUnauthenticated) {
          // Stay on splash to show welcome
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -120,
                  right: -90,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: -100,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(),
                      const AppLogo(size: 92, light: true),
                      const SizedBox(height: 20),
                      const Text(
                        'Kantong Ku',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bayar, transfer, dan kelola uang kuliah\ndalam satu aplikasi yang aman.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthUnauthenticated) {
                            return Column(
                              children: [
                                AppButton(
                                  label: 'Buat Akun Baru',
                                  variant: AppButtonVariant.white,
                                  onPressed: () => context.push('/register'),
                                ),
                                const SizedBox(height: 11),
                                AppButton(
                                  label: 'Masuk ke Akun',
                                  variant: AppButtonVariant.outlineWhite,
                                  onPressed: () => context.push('/login'),
                                ),
                              ],
                            );
                          } else if (state is AuthAuthenticated && _showBiometricRetry) {
                            return Column(
                              children: [
                                const Text(
                                  'Autentikasi Diperlukan',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Gunakan sidik jari Anda untuk masuk ke aplikasi.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: Colors.white70,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AppButton(
                                  label: 'Gunakan Sidik Jari',
                                  variant: AppButtonVariant.white,
                                  onPressed: () => _authenticateBiometrics(state),
                                ),
                              ],
                            );
                          } else {
                            // Tampilkan loading spinner saat check status atau sedang meminta sidik jari
                            return const SizedBox(
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
