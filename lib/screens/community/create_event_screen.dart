import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/theme/theme.dart';
import 'package:hugeicons/hugeicons.dart';

class CreateEventScreen extends StatefulWidget {
  final String communityId;
  const CreateEventScreen({super.key, required this.communityId});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  void _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final provider = context.read<CommunityProvider>();

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr = _selectedTime!.format(context);

    final success = await provider.createEvent(
      auth.token!,
      widget.communityId,
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      dateStr,
      timeStr,
      _locationController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create event')),
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.textColor2.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Create Event',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    labelStyle: TextStyle(color: AppTheme.textColor2),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppTheme.textColor2),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Description required' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _locationController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: AppTheme.textColor2),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Location required' : null,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null ? AppTheme.textColor2 : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _selectedTime == null
                                ? 'Select Time'
                                : _selectedTime!.format(context),
                            style: TextStyle(
                              color: _selectedTime == null ? AppTheme.textColor2 : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: theme.colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.surface,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Create Event',
                            style: TextStyle(
                              color: theme.colorScheme.surface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
