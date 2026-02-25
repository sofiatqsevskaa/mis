import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final EventService _eventService;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _eventService = EventService(ApiService());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.darkBrown,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppTheme.gold,
            unselectedLabelColor: AppTheme.lightBrown,
            indicatorColor: AppTheme.gold,
            indicatorWeight: 2,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Calendar'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _UpcomingTab(eventService: _eventService),
              _CalendarTab(eventService: _eventService),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpcomingTab extends StatefulWidget {
  final EventService eventService;
  const _UpcomingTab({required this.eventService});
  @override
  State<_UpcomingTab> createState() => _UpcomingTabState();
}

class _UpcomingTabState extends State<_UpcomingTab>
    with AutomaticKeepAliveClientMixin {
  List<CafeEvent> _events = [];
  bool _loading = true;
  String? _error;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final events = await widget.eventService.getUpcomingEvents();
      setState(() {
        _events = events;
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
    super.build(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(error: _error!, onRetry: _load)
          : _events.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 8),
                    child: Text(
                      'Upcoming Events',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  );
                }
                return _EventCard(event: _events[i - 1]);
              },
            ),
    );
  }
}

class _CalendarTab extends StatefulWidget {
  final EventService eventService;
  const _CalendarTab({required this.eventService});
  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab>
    with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CafeEvent>> _eventsByDay = {};
  bool _loading = false;

  @override
  bool get wantKeepAlive => true;

  static DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime get _today => _norm(DateTime.now());
  static DateTime get _lastDay => DateTime(
    DateTime.now().year,
    DateTime.now().month + 3,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    _selectedDay = _today;
    _loadMonth(_focusedDay);
  }

  Future<void> _loadMonth(DateTime month) async {
    setState(() => _loading = true);
    try {
      final events = await widget.eventService.getCalendarEvents(
        month.month,
        month.year,
      );
      setState(() {
        _eventsByDay = EventService.groupByDay(events);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<CafeEvent> _eventsForDay(DateTime day) => _eventsByDay[_norm(day)] ?? [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectedEvents = _selectedDay != null
        ? _eventsForDay(_selectedDay!)
        : <CafeEvent>[];

    return Column(
      children: [
        // Calendar widget
        Container(
          color: AppTheme.white,
          child: TableCalendar<CafeEvent>(
            firstDay: _today,
            lastDay: _lastDay,
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
                color: AppTheme.lightBrown.withOpacity(0.35),
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
                color: AppTheme.gold,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: AppTheme.darkBrown,
                fontSize: 17,
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
            color: AppTheme.gold,
            backgroundColor: AppTheme.lightBrown,
            minHeight: 2,
          ),

        // Selected day label
        if (_selectedDay != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppTheme.white,
            child: Text(
              DateFormat('EEEE, d MMMM').format(_selectedDay!),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.darkBrown),
            ),
          ),

        // Events for selected day
        Expanded(
          child: selectedEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: selectedEvents.length,
                  itemBuilder: (_, i) =>
                      _CalendarEventTile(event: selectedEvents[i]),
                ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final CafeEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM yyyy').format(event.eventDate);
    final time = event.endTime != null
        ? '${event.startTime.substring(0, 5)} – ${event.endTime!.substring(0, 5)}'
        : event.startTime.substring(0, 5);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date chip
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkBrown,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('d').format(event.eventDate),
                      style: const TextStyle(
                        color: AppTheme.cream,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(event.eventDate).toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (!event.isPublic)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.gold),
                            ),
                            child: const Text(
                              'Private',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.warmBrown,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppTheme.warmBrown,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.warmBrown,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              color: AppTheme.warmBrown,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(event.eventDate);
    final time = event.endTime != null
        ? '${event.startTime.substring(0, 5)} – ${event.endTime!.substring(0, 5)}'
        : event.startTime.substring(0, 5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!event.isPublic)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.gold),
                  ),
                  child: const Text(
                    'Private Event',
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                event.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              _DetailRow(Icons.calendar_today_outlined, dateStr),
              const SizedBox(height: 8),
              _DetailRow(Icons.access_time_outlined, time),
              if (event.creatorName != null) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  Icons.person_outline,
                  'Organized by ${event.creatorName}',
                ),
              ],
              if (event.description != null &&
                  event.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  event.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
              height: 48,
              decoration: BoxDecoration(
                color: event.isPublic ? AppTheme.darkBrown : AppTheme.gold,
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
                      const Icon(
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
                      if (!event.isPublic) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.lock_outline,
                          size: 13,
                          color: AppTheme.gold,
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: AppTheme.gold),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.event_busy_outlined,
          size: 64,
          color: AppTheme.warmBrown,
        ),
        const SizedBox(height: 16),
        Text(
          'No upcoming events',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text('Check back soon!', style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.wifi_off_outlined,
          size: 48,
          color: AppTheme.warmBrown,
        ),
        const SizedBox(height: 12),
        Text(
          'Could not load events',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          error,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
