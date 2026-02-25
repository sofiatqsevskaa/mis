import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/event_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const LaboratoriumApp(),
    ),
  );
}

class LaboratoriumApp extends StatelessWidget {
  const LaboratoriumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laboratorium',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_NavItem> _buildNavItems(AuthProvider auth) {
    return [
      _NavItem(
        icon: Icons.coffee_outlined,
        label: 'About',
        screen: const HomeScreen(),
      ),
      _NavItem(
        icon: Icons.event_outlined,
        label: 'Events',
        screen: const EventsScreen(),
      ),
      if (auth.isApproved)
        _NavItem(
          icon: Icons.calendar_month_outlined,
          label: 'Book',
          screen: const CalendarScreen(),
        ),
      if (auth.isAdmin)
        _NavItem(
          icon: Icons.admin_panel_settings_outlined,
          label: 'Manage',
          screen: const AdminScreen(),
        ),
    ];
  }

  void _syncController(int newCount) {
    if (_tabController.length == newCount) return;
    final clampedIndex = _tabController.index.clamp(0, newCount - 1);
    _tabController.dispose();
    _tabController = TabController(
      length: newCount,
      vsync: this,
      initialIndex: clampedIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final navItems = _buildNavItems(auth);

    _syncController(navItems.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LABORATORIUM'),
        // ─── Navigation tabs sit inside the AppBar ────────────────────────
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.lightBrown,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          tabs: navItems
              .map(
                (item) => Tab(
                  icon: Icon(item.icon, size: 20),
                  text: item.label,
                  iconMargin: const EdgeInsets.only(bottom: 2),
                ),
              )
              .toList(),
        ),
        actions: [
          if (auth.isLoggedIn) ...[
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      auth.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      size: 14,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      auth.user?.name.split(' ').first ?? '',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Sign out',
              onPressed: auth.logout,
            ),
          ] else
            TextButton.icon(
              icon: const Icon(
                Icons.person_outline,
                color: AppTheme.cream,
                size: 20,
              ),
              label: const Text(
                'Sign In',
                style: TextStyle(color: AppTheme.cream),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: navItems.map((item) => item.screen).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
