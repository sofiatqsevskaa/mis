import 'package:flutter/material.dart';
import '../../../models/cafe_event.dart';
import '../../../services/api_service.dart';
import '../../../services/event_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/cafe_calendar.dart';
import '../../../widgets/event_card.dart';

class EventsDesktopLayout extends StatefulWidget {
  final VoidCallback? onEventStatusChanged;

  const EventsDesktopLayout({super.key, this.onEventStatusChanged});

  @override
  State<EventsDesktopLayout> createState() => _EventsDesktopLayoutState();
}

class _EventsDesktopLayoutState extends State<EventsDesktopLayout> {
  late final EventService _eventService;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<CafeEvent>> _eventsByDay = {};
  List<CafeEvent> _selectedDayEvents = [];
  List<CafeEvent> _upcomingEvents = [];

  bool _loadingCalendar = true;
  bool _loadingUpcoming = true;

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _eventService = EventService(ApiService());
    _loadMonth(_focusedDay);
    _loadUpcoming();
  }

  Future<void> _loadMonth(DateTime month) async {
    setState(() => _loadingCalendar = true);

    final events = await _eventService.getCalendarEvents(
      month.month,
      month.year,
    );

    final mapped = EventService.groupByDay(events);

    setState(() {
      _eventsByDay = mapped;
      _selectedDayEvents = _selectedDay != null
          ? mapped[_normalize(_selectedDay!)] ?? []
          : [];
      _loadingCalendar = false;
    });
  }

  Future<void> _loadUpcoming() async {
    setState(() => _loadingUpcoming = true);

    final events = await _eventService.getUpcomingEvents();

    setState(() {
      _upcomingEvents = events;
      _loadingUpcoming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _loadingCalendar
                ? const Center(child: CircularProgressIndicator())
                : CafeCalendar(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    eventsByDay: _eventsByDay,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                        _selectedDayEvents =
                            _eventsByDay[_normalize(selected)] ?? [];
                      });
                    },
                    onPageChanged: (focused) {
                      _focusedDay = focused;
                      _loadMonth(focused);
                    },
                  ),
          ),
        ),
        Container(width: 2, color: AppTheme.charcoal),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                const Text(
                  'SELECTED DAY',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedDay == null)
                  const Text(
                    'SELECT A DATE',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                if (_selectedDay != null && _selectedDayEvents.isEmpty)
                  const Text(
                    'NO EVENTS FOR THIS DAY',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ..._selectedDayEvents.map((e) => EventCard(event: e)),
                const SizedBox(height: 40),
                const Text(
                  'UPCOMING EVENTS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                if (_loadingUpcoming)
                  const Center(child: CircularProgressIndicator()),
                if (!_loadingUpcoming && _upcomingEvents.isEmpty)
                  const Text(
                    'NO UPCOMING EVENTS',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ..._upcomingEvents.map((e) => EventCard(event: e)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
