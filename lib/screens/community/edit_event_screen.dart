import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/theme/theme.dart';
import 'dart:io';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditEventScreen extends StatefulWidget {
  final String communityId;
  final Map<String, dynamic> event;
  
  const EditEventScreen({super.key, required this.communityId, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _linkController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event['title']);
    _descriptionController = TextEditingController(text: widget.event['description']);
    _locationController = TextEditingController(text: widget.event['location']);
    _linkController = TextEditingController(text: widget.event['link']);
    try {
      _selectedDate = DateTime.parse(widget.event['date']);
    } catch (_) {}
    
    try {
      final timeParts = widget.event['time'].toString().split(RegExp(r'[: ]'));
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (widget.event['time'].toString().toLowerCase().contains('pm') && hour != 12) {
        hour += 12;
      } else if (widget.event['time'].toString().toLowerCase().contains('am') && hour == 12) {
        hour = 0;
      }
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _updateEvent() async {
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

    final success = await provider.updateEvent(
      auth.token!,
      widget.communityId,
      widget.event['id'],
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      dateStr,
      timeStr,
      _locationController.text.trim(),
      link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
      imagePath: _image?.path,
      existingImageUrl: widget.event['imageUrl'],
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.read<FeedProvider>().loadExploreData(auth.token!);
      Navigator.pop(context); // Close edit screen
      Navigator.pop(context); // Close event details bottom sheet
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update event')),
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
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
                  'Edit Event',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : (widget.event['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: widget.event['imageUrl'],
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(icon: HugeIcons.strokeRoundedImage01, color: AppTheme.textColor2, size: 40.0),
                                  const SizedBox(height: 10),
                                  Text('Upload Event Image', style: TextStyle(color: AppTheme.textColor2)),
                                ],
                              )),
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
                TextFormField(
                  controller: _linkController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Event Link (Optional)',
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
                    onPressed: _isLoading ? null : _updateEvent,
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
                            'Save Changes',
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
