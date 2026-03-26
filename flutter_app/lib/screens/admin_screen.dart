import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/whitelist_entry.dart';
import '../models/cafe_event.dart';
import '../models/cafe_user.dart';
import '../models/event_note.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  final VoidCallback? onEventStatusChanged;
  const AdminScreen({super.key, this.onEventStatusChanged});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.burgundy,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.gray,
            indicatorColor: AppTheme.accent,
            tabs: const [
              Tab(text: 'Events & Notes'),
              Tab(text: 'Users & Access'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _EventsNotesTab(
                onEventStatusChanged: widget.onEventStatusChanged,
              ),
              const _UsersTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventsNotesTab extends StatefulWidget {
  final VoidCallback? onEventStatusChanged;
  const _EventsNotesTab({this.onEventStatusChanged});

  @override
  State<_EventsNotesTab> createState() => _EventsNotesTabState();
}

class _EventsNotesTabState extends State<_EventsNotesTab> {
  final ApiService _api = ApiService();
  List<CafeEvent> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final events = await _api.getAdminEvents();
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return const Center(child: Text('No events to manage'));
    }

    final pending = _events.where((e) => e.status == 'pending').toList();
    final approved = _events.where((e) => e.status == 'approved').toList();
    final rejected = _events.where((e) => e.status == 'rejected').toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            Text(
              'Pending (${pending.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...pending.map(
              (e) => _AdminEventCard(
                event: e,
                onAction: () {
                  _load();
                  if (widget.onEventStatusChanged != null) {
                    widget.onEventStatusChanged!();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (approved.isNotEmpty) ...[
            Text('Approved', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...approved.map(
              (e) => _AdminEventCard(
                event: e,
                onAction: () {
                  _load();
                  if (widget.onEventStatusChanged != null) {
                    widget.onEventStatusChanged!();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (rejected.isNotEmpty) ...[
            Text('Rejected', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...rejected.map(
              (e) => _AdminEventCard(
                event: e,
                onAction: () {
                  _load();
                  if (widget.onEventStatusChanged != null) {
                    widget.onEventStatusChanged!();
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdminEventCard extends StatelessWidget {
  final CafeEvent event;
  final VoidCallback onAction;

  const _AdminEventCard({required this.event, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE d MMM').format(event.eventDate);
    final time = event.startTime.substring(0, 5);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(event.title),
        subtitle: Text(
          '$dateStr · $time · ${event.creatorName ?? "Unknown"} · ${event.visibility}',
        ),
        children: [_AdminEventActions(event: event, onAction: onAction)],
      ),
    );
  }
}

class _AdminEventActions extends StatefulWidget {
  final CafeEvent event;
  final VoidCallback onAction;

  const _AdminEventActions({required this.event, required this.onAction});

  @override
  State<_AdminEventActions> createState() => _AdminEventActionsState();
}

class _AdminEventActionsState extends State<_AdminEventActions> {
  final ApiService _api = ApiService();
  List<EventNote> _notes = [];
  bool _loadingNotes = true;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _api.getNotes(widget.event.id);
      setState(() {
        _notes = notes;
        _loadingNotes = false;
      });
    } catch (_) {
      setState(() => _loadingNotes = false);
    }
  }

  Future<void> _addNote() async {
    if (_noteCtrl.text.trim().isEmpty) return;

    await _api.addNote(widget.event.id, _noteCtrl.text.trim());
    _noteCtrl.clear();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.event.description != null) Text(widget.event.description!),
          const SizedBox(height: 12),
          if (widget.event.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _api.approveEvent(widget.event.id, 'approved');
                      widget.onAction();
                    },
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _api.approveEvent(widget.event.id, 'rejected');
                      widget.onAction();
                    },
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Staff Notes'),
          const SizedBox(height: 8),
          if (_loadingNotes)
            const CircularProgressIndicator()
          else if (_notes.isEmpty)
            const Text('No notes yet.')
          else
            ..._notes.map((n) => _NoteItem(note: n)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(hintText: 'Add note...'),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _addNote),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final EventNote note;

  const _NoteItem({required this.note});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(note.authorName ?? 'Staff'),
      subtitle: Text(note.note),
      trailing: Text(DateFormat('d MMM HH:mm').format(note.createdAt)),
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final ApiService _api = ApiService();
  List<CafeUser> _users = [];
  List<WhitelistEntry> _whitelist = [];
  bool _loading = true;
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await _api.getUsers();
      final wl = await _api.getWhitelist();
      setState(() {
        _users = users;
        _whitelist = wl;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addToWhitelist() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;

    await _api.addToWhitelist(email);
    _emailCtrl.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Whitelist'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    hintText: 'email@example.com',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addToWhitelist,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._whitelist.map(
            (w) => ListTile(
              title: Text(w.email),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await _api.removeFromWhitelist(w.id);
                  _load();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
