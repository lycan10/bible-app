import 'package:flutter/material.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class EditContentScreen extends StatefulWidget {
  final String token;
  final String type;
  final Map<String, dynamic> item;

  const EditContentScreen({Key? key, required this.token, required this.type, required this.item}) : super(key: key);

  @override
  _EditContentScreenState createState() => _EditContentScreenState();
}

class _EditContentScreenState extends State<EditContentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item['title'] ?? widget.item['text'] ?? '');
    _descriptionController = TextEditingController(text: widget.item['description'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'title': _titleController.text,
        if (widget.type == 'devotions' || widget.type == 'books') 'description': _descriptionController.text,
        if (widget.type == 'posts') 'text': _titleController.text, // For posts, text is the main content
      };

      Map<String, dynamic> res = {};
      switch (widget.type) {
        case 'devotions':
          res = await ApiService.editDevotionPlan(widget.token, widget.item['id'], data);
          break;
        case 'books':
          res = await ApiService.editBook(widget.token, widget.item['id'], data);
          break;
        case 'media':
          res = await ApiService.editUserMedia(widget.token, widget.item['id'], data);
          break;
        case 'posts':
          // We do not have a dedicated edit post api integrated in api_service yet, if it fails gracefully
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit post is not fully supported yet.')));
          break;
      }

      if (mounted) {
        if (res['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${res['error']}')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated successfully.')));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.type.capitalize()}', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Updating your content might require admin review before being published again.",
                style: GoogleFonts.inter(color: AppTheme.textColor2, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: widget.type == 'posts' ? 'Text' : 'Title'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              if (widget.type == 'devotions' || widget.type == 'books') ...[
                const SizedBox(height: 15),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "\${this[0].toUpperCase()}\${substring(1)}";
  }
}
