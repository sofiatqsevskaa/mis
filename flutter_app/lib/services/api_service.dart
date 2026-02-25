import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CafeEvent>> getUpcomingEvents() async {
    final res = await http.get(
      Uri.parse('$baseUrl/events/upcoming'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => CafeEvent.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> getCafeInfo() async {
    final url = Uri.parse('$baseUrl/cafe-info');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch cafe info');
    }
  }

  Future<List<CafeEvent>> getCalendarEvents(int month, int year) async {
    final res = await http.get(
      Uri.parse('$baseUrl/events/calendar?month=$month&year=$year'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => CafeEvent.fromJson(e)).toList();
  }

  Future<List<CafeEvent>> getAdminEvents() async {
    final res = await http.get(
      Uri.parse('$baseUrl/events/admin'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => CafeEvent.fromJson(e)).toList();
  }

  Future<CafeEvent> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String startTime,
    String? endTime,
    String visibility = 'public',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'event_date': date.toIso8601String(),
        'start_time': startTime,
        'end_time': endTime,
        'visibility': visibility,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }

    return CafeEvent.fromJson(jsonDecode(res.body));
  }

  Future<void> approveEvent(int eventId, String status) async {
    final res = await http.put(
      Uri.parse('$baseUrl/events/$eventId/status'),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }
  }

  Future<List<EventNote>> getNotes(int eventId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/events/$eventId/notes'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => EventNote.fromJson(e)).toList();
  }

  Future<void> addNote(int eventId, String note) async {
    final res = await http.post(
      Uri.parse('$baseUrl/events/$eventId/notes'),
      headers: await _headers(),
      body: jsonEncode({'note': note}),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }
  }

  Future<List<CafeUser>> getUsers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => CafeUser.fromJson(e)).toList();
  }

  Future<void> updateUserRole(int userId, String role) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/role'),
      headers: await _headers(),
      body: jsonEncode({'role': role}),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }
  }

  Future<List<WhitelistEntry>> getWhitelist() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/whitelist'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => WhitelistEntry.fromJson(e)).toList();
  }

  Future<void> addToWhitelist(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/whitelist'),
      headers: await _headers(),
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }
  }

  Future<void> removeFromWhitelist(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/whitelist/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error']);
    }
  }
}
