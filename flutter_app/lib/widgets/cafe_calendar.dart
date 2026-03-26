import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/cafe_event.dart';
import '../theme/app_theme.dart';

class CafeCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<CafeEvent>> eventsByDay;
  final Function(DateTime selected, DateTime focused) onDaySelected;
  final Function(DateTime focused) onPageChanged;

  const CafeCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.eventsByDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  static DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

  List<CafeEvent> _eventsForDay(DateTime day) => eventsByDay[_norm(day)] ?? [];

  static DateTime get _today => DateTime.now();

  static DateTime get _lastDay => DateTime(
    DateTime.now().year,
    DateTime.now().month + 3,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.charcoal, width: 2)),
      ),
      child: TableCalendar<CafeEvent>(
        firstDay: _today,
        lastDay: _lastDay,
        focusedDay: focusedDay,
        selectedDayPredicate: (d) => isSameDay(d, selectedDay),
        eventLoader: _eventsForDay,
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.burgundy, width: 2),
              ),
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  color: AppTheme.burgundy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.burgundy, width: 2),
              ),
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  color: AppTheme.burgundy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        calendarStyle: const CalendarStyle(
          isTodayHighlighted: false,
          outsideDaysVisible: false,
        ),
      ),
    );
  }
}
