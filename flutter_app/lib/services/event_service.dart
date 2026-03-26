import '../models/cafe_event.dart';
import '../models/event_note.dart';
import 'api_service.dart';

class EventService {
  final ApiService _api;
  EventService(this._api);

  Future<List<CafeEvent>> getUpcomingEvents() => _api.getUpcomingEvents();

  Future<List<CafeEvent>> getCalendarEvents(int month, int year) =>
      _api.getCalendarEvents(month, year);

  Future<List<CafeEvent>> getAdminEvents() => _api.getAdminEvents();

  Future<CafeEvent> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String startTime,
    String? endTime,
    String visibility = 'public',
  }) => _api.createEvent(
    title: title,
    description: description,
    date: date,
    startTime: startTime,
    endTime: endTime,
    visibility: visibility,
  );

  Future<void> updateStatus(int eventId, String status) =>
      _api.approveEvent(eventId, status);

  Future<List<EventNote>> getNotes(int eventId) => _api.getNotes(eventId);

  Future<void> addNote(int eventId, String note) => _api.addNote(eventId, note);

  static Map<DateTime, List<CafeEvent>> groupByDay(List<CafeEvent> events) {
    final map = <DateTime, List<CafeEvent>>{};
    for (final e in events) {
      final key = DateTime(
        e.eventDate.year,
        e.eventDate.month,
        e.eventDate.day,
      );
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }
}
