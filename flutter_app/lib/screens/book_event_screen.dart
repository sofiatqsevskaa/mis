import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/app_theme.dart';

class BookEventScreen extends StatefulWidget {
  final DateTime? preselectedDate;

  const BookEventScreen({super.key, this.preselectedDate});

  @override
  State<BookEventScreen> createState() => _BookEventScreenState();
}

class _BookEventScreenState extends State<BookEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final ApiService _api = ApiService();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _visibility = 'public';
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preselectedDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _startTime == null) {
      setState(() => _error = 'Please select date and start time');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.createEvent(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? '' : _descCtrl.text.trim(),
        date: _selectedDate!,
        startTime: _formatTime(_startTime!),
        endTime: _endTime != null ? _formatTime(_endTime!) : null,
        visibility: _visibility,
      );

      if (!mounted) return;

      final auth = context.read<AuthProvider>();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.isAdmin
                ? 'Event created successfully.'
                : 'Event submitted for approval.',
          ),
          backgroundColor: AppTheme.darkBrown,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Book an Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auth.isAdmin
                    ? 'Create an event. It will be published immediately.'
                    : 'Submit your event request. An admin will review it before publishing.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Event Title *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              _DatePickerField(
                label: 'Event Date *',
                value: _selectedDate != null
                    ? DateFormat('d MMMM yyyy').format(_selectedDate!)
                    : null,
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? now,
                    firstDate: now,
                    lastDate: DateTime(now.year, now.month + 3),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Start Time *',
                      value: _startTime?.format(context),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              _startTime ??
                              const TimeOfDay(hour: 18, minute: 0),
                        );
                        if (picked != null) {
                          setState(() => _startTime = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'End Time',
                      value: _endTime?.format(context),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              _endTime ?? const TimeOfDay(hour: 20, minute: 0),
                        );
                        if (picked != null) {
                          setState(() => _endTime = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('Visibility', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _VisibilityOption(
                      selected: _visibility == 'public',
                      icon: Icons.public,
                      label: 'Public',
                      description: 'Visible to everyone',
                      onTap: () => setState(() => _visibility = 'public'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VisibilityOption(
                      selected: _visibility == 'private',
                      icon: Icons.lock_outline,
                      label: 'Private',
                      description: 'Only approved users',
                      onTap: () => setState(() => _visibility = 'private'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.error),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(value ?? 'Select...'),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.darkBrown : AppTheme.lightGray,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.darkBrown : AppTheme.lightBrown,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? AppTheme.darkBrown : AppTheme.lightBrown,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
