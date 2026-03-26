import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/event_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/upcoming_events_tab.dart';
import '../../widgets/calendar_tab.dart';

class EventsMobileLayout extends StatefulWidget {
  final VoidCallback? onEventStatusChanged;
  const EventsMobileLayout({super.key, this.onEventStatusChanged});

  @override
  State<EventsMobileLayout> createState() => _EventsMobileLayoutState();
}

class _EventsMobileLayoutState extends State<EventsMobileLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final EventService _eventService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _eventService = EventService(ApiService());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppTheme.charcoal,
            border: Border(bottom: BorderSide(color: AppTheme.white, width: 2)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.white, width: 4),
              ),
            ),
            labelColor: AppTheme.white,
            unselectedLabelColor: AppTheme.gray,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'UPCOMING'),
              Tab(text: 'CALENDAR'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              UpcomingEventsTab(
                eventService: _eventService,
                onEventStatusChanged: widget.onEventStatusChanged,
              ),
              CalendarTab(
                eventService: _eventService,
                onEventStatusChanged: widget.onEventStatusChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
