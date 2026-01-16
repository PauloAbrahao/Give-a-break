import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../screens/app_list/app_list_screen.dart';
import '../screens/routines/routines_screen.dart';

class FloatingMenu extends StatefulWidget {
  final String currentScreen;

  const FloatingMenu({
    super.key,
    required this.currentScreen,
  });

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu items
        ScaleTransition(
          scale: _expandAnimation,
          alignment: Alignment.bottomRight,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Apps button
                if (widget.currentScreen != 'apps')
                  _buildMenuItem(
                    icon: Icons.apps,
                    label: 'Apps',
                    onTap: () {
                      _toggle();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AppListScreen(),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                // Routines button
                if (widget.currentScreen != 'routines')
                  _buildMenuItem(
                    icon: Icons.schedule,
                    label: 'Routines',
                    onTap: () {
                      _toggle();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RoutinesScreen(),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.primary,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.getSurface(context),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextPrimary(context),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: 'fab_$label',
          onPressed: onTap,
          backgroundColor: AppColors.primary,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}
