import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/theme/theme.dart';
import 'package:hugeicons/hugeicons.dart';

class EditPostScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post['text'] ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();

    final success = await communityProvider.updatePost(
      auth.token!,
      widget.post['id'],
      text,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update post.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: "Edit Post",
                leadingIconTap: () => Navigator.pop(context),
                trailingIcon: null,
                trailingIconTap: () {},
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Save Changes',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
