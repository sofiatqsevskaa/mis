import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BookEventForm extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime? selectedDate) onEventCreated;
  final ApiService apiService;

  const BookEventForm({
    super.key,
    this.selectedDate,
    required this.onEventCreated,
    required this.apiService,
  });

  @override
  State<BookEventForm> createState() => _BookEventFormState();
}

class _BookEventFormState extends State<BookEventForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _visibility = 'public';
  bool _loading = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(BookEventForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate &&
        widget.selectedDate != null) {
      setState(() => _selectedDate = widget.selectedDate);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatDateForApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year, now.month + 3, now.day),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _startTime == null) {
      setState(() => _error = 'Please select a date and start time');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.apiService.createEvent(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate!,
        startTime: _formatTime(_startTime!),
        endTime: _endTime != null ? _formatTime(_endTime!) : null,
        visibility: _visibility,
      );

      setState(() {
        _submitted = true;
        _loading = false;
      });

      widget.onEventCreated(_selectedDate);
    } catch (e) {
      debugPrint('CREATE EVENT ERROR: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _reset() {
    _titleCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _submitted = false;
      _selectedDate = widget.selectedDate;
      _startTime = null;
      _endTime = null;
      _visibility = 'public';
      _error = null;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.burgundy,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Event Submitted!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.burgundy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your event is pending approval.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _reset,
              child: const Text('Submit Another Event'),
            ),
          ),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date *',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                _selectedDate != null
                    ? _formatDate(_selectedDate!)
                    : 'Select a date',
                style: TextStyle(
                  color: _selectedDate != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : AppTheme.gray,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimePickerField(
                  label: 'Start Time *',
                  value: _startTime?.format(context),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime:
                          _startTime ?? const TimeOfDay(hour: 18, minute: 0),
                    );
                    if (picked != null) setState(() => _startTime = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerField(
                  label: 'End Time',
                  value: _endTime?.format(context),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime:
                          _endTime ?? const TimeOfDay(hour: 20, minute: 0),
                    );
                    if (picked != null) setState(() => _endTime = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _TimePickerField({
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
            color: selected ? AppTheme.burgundy : AppTheme.gray,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.burgundy : AppTheme.gray,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? AppTheme.burgundy : AppTheme.gray,
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
