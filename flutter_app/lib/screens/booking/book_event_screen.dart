import 'package:flutter/material.dart';
import '../../widgets/cafe_calendar.dart';
import '../../widgets/book_event_form.dart';
import '../../models/cafe_event.dart';
import '../../services/event_service.dart';
import '../../services/api_service.dart';

class BookEventScreen extends StatefulWidget {
  final DateTime? preselectedDate;
  const BookEventScreen({super.key, this.preselectedDate});

  @override
  State<BookEventScreen> createState() => _BookEventScreenState();
}

class _BookEventScreenState extends State<BookEventScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CafeEvent>> _eventsByDay = {};
  bool _loading = true;
  String? _error;

  late final ApiService _apiService = ApiService();
  late final EventService _eventService = EventService(_apiService);

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.preselectedDate;
    _loadMonth(_focusedDay);
  }

  Future<void> _loadMonth(DateTime month, {bool silent = false}) async {
    setState(() {
      if (!silent) _loading = true;
      _error = null;
    });
    try {
      final events = await _eventService.getCalendarEvents(
        month.month,
        month.year,
      );
      final Map<DateTime, List<CafeEvent>> mapped = {};
      for (final event in events) {
        final key = _normalize(event.eventDate);
        mapped.putIfAbsent(key, () => []).add(event);
      }
      setState(() {
        _eventsByDay = mapped;
        _loading = false;
      });
    } catch (e, stack) {
      debugPrint('LOAD MONTH ERROR: $e\n$stack');
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
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }

    final isWide = MediaQuery.of(context).size.width > 800;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CafeCalendar(
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
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: BookEventForm(
                selectedDate: _selectedDay,
                apiService: _apiService,
                onEventCreated: (_) => _loadMonth(_focusedDay, silent: true),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CafeCalendar(
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
          ),
          const SizedBox(height: 20),
          BookEventForm(
            selectedDate: _selectedDay,
            apiService: _apiService,
            onEventCreated: (_) => _loadMonth(_focusedDay, silent: true),
          ),
        ],
      ),
    );
  }
}
