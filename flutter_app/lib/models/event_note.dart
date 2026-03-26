class EventNote {
  final int id;
  final int eventId;
  final String note;
  final DateTime createdAt;
  final String? authorName;

  EventNote({
    required this.id,
    required this.eventId,
    required this.note,
    required this.createdAt,
    this.authorName,
  });

  factory EventNote.fromJson(Map<String, dynamic> json) {
    return EventNote(
      id: json['id'],
      eventId: json['event_id'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      authorName: json['author_name'],
    );
  }
}
