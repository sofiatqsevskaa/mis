class CafeUser {
  final int id;
  final String email;
  final String name;
  final String role;
  final bool isWhitelisted;

  CafeUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isWhitelisted,
  });

  bool get isAdmin => role == 'admin';
  bool get isApproved => role == 'approved';
  bool get isPending => role == 'pending';

  factory CafeUser.fromJson(Map<String, dynamic> json) {
    return CafeUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      isWhitelisted: json['is_whitelisted'] ?? false,
    );
  }
}

class CafeEvent {
  final int id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String startTime;
  final String? endTime;
  final String visibility;
  final String status;
  final int createdBy;
  final String? creatorName;

  CafeEvent({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    required this.startTime,
    this.endTime,
    required this.visibility,
    required this.status,
    required this.createdBy,
    this.creatorName,
  });

  bool get isPublic => visibility == 'public';

  factory CafeEvent.fromJson(Map<String, dynamic> json) {
    return CafeEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime.parse(json['event_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      visibility: json['visibility'],
      status: json['status'],
      createdBy: json['created_by'],
      creatorName: json['creator_name'],
    );
  }
}

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

class WhitelistEntry {
  final int id;
  final String email;
  final DateTime createdAt;
  final String? addedByName;

  WhitelistEntry({
    required this.id,
    required this.email,
    required this.createdAt,
    this.addedByName,
  });

  factory WhitelistEntry.fromJson(Map<String, dynamic> json) {
    return WhitelistEntry(
      id: json['id'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      addedByName: json['added_by_name'],
    );
  }
}
