import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../injection/injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/feature_icon.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSetting();
  }

  Future<void> _loadBiometricSetting() async {
    final enabled = await sl<AuthRepository>().isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (enable) {
      // Verifikasi biometrik terlebih dahulu sebelum mengaktifkan
      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        await sl<AuthRepository>().saveBiometricEnabled(true);
        setState(() {
          _biometricEnabled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login biometrik berhasil diaktifkan.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Autentikasi biometrik gagal atau dibatalkan.')),
          );
        }
      }
    } else {
      await sl<AuthRepository>().saveBiometricEnabled(false);
      setState(() {
        _biometricEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login biometrik dinonaktifkan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        }
      },
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).padding.top + 12, 20, 24),
                  child: Row(
                    children: [
                      AppAvatar(name: user?.name ?? 'User', size: 60, bg: Colors.white.withValues(alpha: 0.25)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'Pengguna',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                )),
                            Text(user?.email ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  color: Colors.white70,
                                )),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, size: 14, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Terverifikasi',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Keamanan',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate400,
                            )),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppColors.shadowSoft,
                        ),
                        child: Column(
                          children: [
                            _Row(
                              icon: Icons.verified_user_outlined,
                              tone: 'green',
                              title: 'Verifikasi 2 langkah (2FA)',
                              subtitle: 'Aktif · Email OTP',
                              onTap: () => context.go('/setup-2fa'),
                              right: const AppBadge(label: 'Aktif', tone: 'green'),
                            ),
                            const Divider(height: 1, indent: 56, color: AppColors.line2),
                            _Row(
                              icon: Icons.lock_outline_rounded,
                              tone: 'blue',
                              title: 'Ubah PIN keamanan',
                              subtitle: 'Terakhir diubah 2 bln lalu',
                              onTap: () {},
                            ),
                            const Divider(height: 1, indent: 56, color: AppColors.line2),
                            _Row(
                              icon: Icons.fingerprint_rounded,
                              tone: 'violet',
                              title: 'Login biometrik',
                              subtitle: 'Sidik jari',
                              onTap: () => _toggleBiometric(!_biometricEnabled),
                              right: _Toggle(
                                value: _biometricEnabled,
                                onChanged: _toggleBiometric,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Akun',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate400,
                            )),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppColors.shadowSoft,
                        ),
                        child: Column(
                          children: [
                            _Row(icon: Icons.person_outline_rounded, tone: 'blue', title: 'Data pribadi', onTap: () {}),
                            const Divider(height: 1, indent: 56, color: AppColors.line2),
                            _Row(icon: Icons.account_balance_outlined, tone: 'green', title: 'Rekening & kartu tersimpan', onTap: () {}),
                            const Divider(height: 1, indent: 56, color: AppColors.line2),
                            _Row(icon: Icons.settings_outlined, tone: 'slate', title: 'Pengaturan aplikasi', onTap: () {}),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.shadowSoft,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, size: 20, color: AppColors.red),
                              SizedBox(width: 9),
                              Text('Keluar',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text('Kantong Ku · v1.0.0',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: AppColors.slate400,
                            )),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String tone;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? right;

  const _Row({
    required this.icon,
    required this.tone,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            FeatureIcon(icon: icon, tone: tone, size: 42, iconSize: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                          color: AppColors.slate400,
                        )),
                  ],
                ],
              ),
            ),
            right ?? const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.green : AppColors.line,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}
