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
