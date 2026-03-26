import 'package:flutter/material.dart';
import '../../models/cafe_event.dart';
import '../../services/event_service.dart';
import '../../theme/app_theme.dart';
import 'event_card.dart';

class UpcomingEventsTab extends StatefulWidget {
  final EventService eventService;
  final VoidCallback? onEventStatusChanged;

  const UpcomingEventsTab({
    super.key,
    required this.eventService,
    this.onEventStatusChanged,
  });

  @override
  State<UpcomingEventsTab> createState() => _UpcomingEventsTabState();
}

class _UpcomingEventsTabState extends State<UpcomingEventsTab>
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
    widget.onEventStatusChanged?.call();
  }

  @override
  void didUpdateWidget(UpcomingEventsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onEventStatusChanged != oldWidget.onEventStatusChanged) {
      _load();
    }
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

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    if (_events.isEmpty) {
      return const Center(
        child: Text(
          'NO UPCOMING EVENTS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppTheme.charcoal,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 24, top: 8),
              child: Text(
                'UPCOMING EVENTS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppTheme.charcoal,
                ),
              ),
            );
          }

          return EventCard(event: _events[i - 1]);
        },
      ),
    );
  }
}
