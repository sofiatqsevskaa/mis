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
