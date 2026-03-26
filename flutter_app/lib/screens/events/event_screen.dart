import 'package:flutter/material.dart';
import 'event_screen_mobile.dart';
import 'event_screen_desktop.dart';

class EventScreen extends StatelessWidget {
  final VoidCallback? onEventStatusChanged;
  const EventScreen({super.key, this.onEventStatusChanged});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return EventsDesktopLayout(onEventStatusChanged: onEventStatusChanged);
    }

    return EventsMobileLayout(onEventStatusChanged: onEventStatusChanged);
  }
}
