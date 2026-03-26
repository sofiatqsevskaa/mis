import 'package:flutter/material.dart';
import '../../../models/cafe_event.dart';
import '../../../services/event_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/cafe_calendar.dart';

class CalendarTab extends StatefulWidget {
  final EventService eventService;
  final VoidCallback? onEventStatusChanged;

  const CalendarTab({
    super.key,
    required this.eventService,
    this.onEventStatusChanged,
  });

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CafeEvent>> _eventsByDay = {};
  bool _loading = true;
  String? _error;

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _loadMonth(_focusedDay);
  }

  Future<void> _loadMonth(DateTime month) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final events = await widget.eventService.getCalendarEvents(
        month.month,
        month.year,
      );

      final Map<DateTime, List<CafeEvent>> mapped = {};

      for (final event in events) {
        final key = _normalize(event.eventDate); // <--- fixed
        mapped.putIfAbsent(key, () => []).add(event);
      }

      setState(() {
        _eventsByDay = mapped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.charcoal,
          ),
        ),
      );
    }

    return CafeCalendar(
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      eventsByDay: _eventsByDay,
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) {
        _focusedDay = focused;
        _loadMonth(focused);
      },
    );
  }
}
