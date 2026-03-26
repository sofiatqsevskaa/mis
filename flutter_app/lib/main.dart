import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/events/event_screen.dart';
import 'screens/booking/book_event_screen.dart';
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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
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
        screen: const EventScreen(),
      ),
      if (auth.isApproved)
        _NavItem(
          icon: Icons.calendar_month_outlined,
          label: 'Book',
          screen: const BookEventScreen(),
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
    _tabController.addListener(_handleTabSelection);
    setState(() {
      _currentIndex = clampedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final navItems = _buildNavItems(auth);

    _syncController(navItems.length);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo_lab.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Spacer(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < navItems.length; i++) ...[
                    InkWell(
                      onTap: () {
                        _tabController.animateTo(i);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              navItems[i].icon,
                              size: 20,
                              color: i == _currentIndex
                                  ? AppTheme.accent
                                  : AppTheme.gray,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              navItems[i].label,
                              style: TextStyle(
                                color: i == _currentIndex
                                    ? AppTheme.accent
                                    : AppTheme.gray,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 16,
        actions: [
          if (auth.isLoggedIn) ...[
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      auth.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      size: 16,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      auth.user?.name.split(' ').first ?? '',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined, size: 22),
              onPressed: auth.logout,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                icon: const Icon(
                  Icons.person_outline,
                  color: AppTheme.offWhite,
                  size: 18,
                ),
                label: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppTheme.offWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
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
