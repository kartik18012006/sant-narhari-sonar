import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../app_theme.dart';
import '../services/language_service.dart';
import '../widgets/responsive_wrapper.dart';
import 'about_tab_screen.dart';
import 'explore_tab_screen.dart';
import 'home_tab_screen.dart';
import 'profile_tab_screen.dart';

/// Main app shell after login: bottom nav with Home, Explore, About, Profile.
/// Nav bar and drawer labels follow app language (toggle in Settings).
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home),
    _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore),
    _NavItem(icon: Icons.info_outline, activeIcon: Icons.info),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  void _onDrawerNavTap(int index) {
    setState(() => _currentIndex = index);
    Navigator.of(context).pop(); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final lang = LanguageService.instance;
        final labels = [
          lang.pick('Home', 'होम'),
          lang.pick('Explore', 'एक्सप्लोर'),
          lang.pick('About', 'बद्दल'),
          lang.pick('Profile', 'प्रोफाइल'),
        ];
        return Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      children: [
                        Icon(Icons.people, color: AppTheme.gold, size: 32),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Sant Narhari Sonar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.home_outlined, color: AppTheme.gold),
                    title: Text(labels[0]),
                    onTap: () => _onDrawerNavTap(0),
                  ),
                  ListTile(
                    leading: Icon(Icons.explore_outlined, color: AppTheme.gold),
                    title: Text(labels[1]),
                    onTap: () => _onDrawerNavTap(1),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: AppTheme.gold),
                    title: Text(labels[2]),
                    onTap: () => _onDrawerNavTap(2),
                  ),
                  ListTile(
                    leading: Icon(Icons.person_outline, color: AppTheme.gold),
                    title: Text(labels[3]),
                    onTap: () => _onDrawerNavTap(3),
                  ),
                ],
              ),
            ),
          ),
          body: ResponsiveWrapper(
            maxWidth: kIsWeb ? 1200 : double.infinity,
            padding: EdgeInsets.zero,
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                HomeTabScreen(),
                ExploreTabScreen(),
                AboutTabScreen(),
                ProfileTabScreen(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.gold,
            unselectedItemColor: Colors.grey,
            items: _navItems
                .asMap()
                .entries
                .map((e) => BottomNavigationBarItem(
                      icon: Icon(e.value.icon, size: 26),
                      activeIcon: Icon(e.value.activeIcon, size: 26),
                      label: labels[e.key],
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.activeIcon});
  final IconData icon;
  final IconData activeIcon;
}
