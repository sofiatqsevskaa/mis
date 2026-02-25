import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/app_theme.dart';
import 'book_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CafeEvent>> _eventsByDay = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadMonth(_focusedDay);
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _loadMonth(DateTime month) async {
    setState(() => _loading = true);
    try {
      final api = ApiService();
      final events = await api.getCalendarEvents(month.month, month.year);

      final map = <DateTime, List<CafeEvent>>{};
      for (final e in events) {
        final key = _normalize(e.eventDate);
        map.putIfAbsent(key, () => []).add(e);
      }

      setState(() {
        _eventsByDay = map;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<CafeEvent> _eventsForDay(DateTime day) =>
      _eventsByDay[_normalize(day)] ?? [];

  bool _isInAllowedRange(DateTime day) {
    final now = DateTime.now();
    final limit = DateTime(now.year, now.month + 3, now.day);
    return !day.isBefore(DateTime(now.year, now.month, now.day)) &&
        !day.isAfter(limit);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final selectedEvents = _selectedDay != null
        ? _eventsForDay(_selectedDay!)
        : [];

    return Column(
      children: [
        // Calendar
        Container(
          color: AppTheme.white,
          child: TableCalendar<CafeEvent>(
            firstDay: DateTime.now(),
            lastDay: DateTime(
              DateTime.now().year,
              DateTime.now().month + 3,
              DateTime.now().day,
            ),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            eventLoader: _eventsForDay,
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
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppTheme.lightBrown,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.darkBrown,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: AppTheme.cream,
                fontWeight: FontWeight.bold,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
              disabledTextStyle: const TextStyle(color: AppTheme.lightBrown),
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: AppTheme.darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppTheme.darkBrown,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppTheme.darkBrown,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: AppTheme.warmBrown,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: AppTheme.lightBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (_loading)
          const LinearProgressIndicator(
            color: AppTheme.accent,
            backgroundColor: AppTheme.lightGray,
          ),

        // Events for selected day
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_selectedDay != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM').format(_selectedDay!),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (auth.isApproved && _isInAllowedRange(_selectedDay!))
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Book'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookEventScreen(preselectedDate: _selectedDay!),
                          ),
                        ).then((_) => _loadMonth(_focusedDay)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.darkBrown,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (selectedEvents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            size: 40,
                            color: AppTheme.lightBrown,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No events on this day',
                            style: TextStyle(color: AppTheme.lightBrown),
                          ),
                          if (auth.isApproved &&
                              _isInAllowedRange(_selectedDay!)) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Request an Event'),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookEventScreen(
                                    preselectedDate: _selectedDay!,
                                  ),
                                ),
                              ).then((_) => _loadMonth(_focusedDay)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  ...selectedEvents.map((e) => _CalendarEventTile(event: e)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarEventTile extends StatelessWidget {
  final CafeEvent event;
  const _CalendarEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final time = event.endTime != null
        ? '${event.startTime.substring(0, 5)} – ${event.endTime!.substring(0, 5)}'
        : event.startTime.substring(0, 5);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: event.visibility == 'public'
                    ? AppTheme.darkBrown
                    : AppTheme.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.lightBrown,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppTheme.lightBrown,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (event.visibility != 'public') ...[
                        Icon(
                          Icons.lock_outline,
                          size: 13,
                          color: AppTheme.accent,
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'Private',
                          style: TextStyle(
                            color: AppTheme.lightBrown,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
