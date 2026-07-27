import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitDevotionScreen extends StatefulWidget {
  const SubmitDevotionScreen({super.key});

  @override
  State<SubmitDevotionScreen> createState() => _SubmitDevotionScreenState();
}

class _SubmitDevotionScreenState extends State<SubmitDevotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;
    
    // Check if gold
    final badge = auth.user?['verificationBadge'] ?? 'NONE';
    if (badge != 'GOLD' && auth.user?['role'] != 'ADMIN') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only Gold Badge members can submit devotions.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await ApiService.submitDevotion(
        auth.token!,
        _titleController.text,
        auth.user?['firstName'] ?? 'Author',
        _descriptionController.text,
        _coverUrlController.text.isNotEmpty ? _coverUrlController.text : 'https://example.com/cover.jpg',
        [], // Empty days for now, could add UI to construct days
      );

      if (mounted) {
        if (res['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${res['error']}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Devotion submitted for admin review.')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final badge = auth.user?['verificationBadge'] ?? 'NONE';
    final isAdmin = auth.user?['isAdmin'] == true;

    if (badge != 'GOLD' && !isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Submit Devotion')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Only Gold Badge members can submit devotions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textColor2),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Devotion'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Submit a new devotion plan for the community. An admin will review it before publishing.",
                style: GoogleFonts.inter(
                  color: AppTheme.textColor2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _coverUrlController,
                decoration: const InputDecoration(labelText: 'Cover Image URL (Optional)'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Devotion', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
