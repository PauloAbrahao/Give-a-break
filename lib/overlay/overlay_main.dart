import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

// This is the entry point for the overlay window
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayWarningScreen(),
  ));
}

class OverlayWarningScreen extends StatefulWidget {
  const OverlayWarningScreen({super.key});

  @override
  State<OverlayWarningScreen> createState() => _OverlayWarningScreenState();
}

class _OverlayWarningScreenState extends State<OverlayWarningScreen> {
  String? _appName;
  String? _usedTime;
  String? _limitTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _appName = prefs.getString('overlay_app_name') ?? 'App';
        _usedTime = prefs.getString('overlay_used_time') ?? '--';
        _limitTime = prefs.getString('overlay_limit_time') ?? '--';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _appName = 'App';
        _usedTime = '--';
        _limitTime = '--';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlayBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.timer_off,
                  size: 50,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                AppStrings.timeIsUp,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                '${AppStrings.limitReached} $_appName',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Usage Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.overlayCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.usedToday,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          _usedTime ?? '--',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.dailyLimitLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          _limitTime ?? '--',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Primary Button - Take a Break
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _closeAppAndOverlay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    AppStrings.takeABreak,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary Button - Continue Anyway
              TextButton(
                onPressed: _dismissOverlay,
                child: Text(
                  AppStrings.continueAnyway,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _closeAppAndOverlay() async {
    // Close the overlay
    await FlutterOverlayWindow.closeOverlay();
  }

  void _dismissOverlay() async {
    // Just close the overlay, let user continue
    await FlutterOverlayWindow.closeOverlay();
  }
}
