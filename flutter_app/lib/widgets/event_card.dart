import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cafe_event.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final CafeEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM yyyy').format(event.eventDate);

    final time = event.endTime != null
        ? '${event.startTime.substring(0, 5)} – ${event.endTime!.substring(0, 5)}'
        : event.startTime.substring(0, 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(
          left: BorderSide(color: AppTheme.charcoal, width: 6),
          right: BorderSide(color: AppTheme.charcoal, width: 2),
          top: BorderSide(color: AppTheme.charcoal, width: 2),
          bottom: BorderSide(color: AppTheme.charcoal, width: 2),
        ),
      ),
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.charcoal,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dateStr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGray,
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          border: Border.fromBorderSide(
            BorderSide(color: AppTheme.charcoal, width: 3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.charcoal,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dateStr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGray,
                ),
              ),
              if (event.description != null &&
                  event.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: AppTheme.charcoal),
                const SizedBox(height: 16),
                Text(
                  event.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.darkGray,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
