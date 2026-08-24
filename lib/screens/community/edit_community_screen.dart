import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../services/api_service.dart';
import '../../theme/theme.dart';
import '../../utils/media_helper.dart';

class EditCommunityScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditCommunityScreen({super.key, required this.initialData});

  @override
  State<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends State<EditCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late bool _isPrivate;
  final TextEditingController _guidelinesController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialData['name'] ?? '';
    _description = widget.initialData['description'] ?? '';
    _isPrivate = widget.initialData['isPrivate'] ?? false;
    _guidelinesController.text = widget.initialData['guidelines'] ?? '';
  }

  @override
  void dispose() {
    _guidelinesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await MediaHelper.pickAndCompressImage(cropToSquare: true);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    setState(() => _isLoading = true);

    try {
      String? newAvatarUrl;

      // Upload new avatar if selected
      if (_selectedImage != null) {
        final avatarRes = await ApiService.uploadMedia(
          token,
          _selectedImage!.path,
        );
        if (avatarRes['fileUrl'] != null || avatarRes['url'] != null) {
          newAvatarUrl = avatarRes['fileUrl'] ?? avatarRes['url'];
        }
      }

      final dataToUpdate = {
        'name': _name,
        'description': _description,
        'isPrivate': _isPrivate,
        'guidelines': _guidelinesController.text,
      };

      if (newAvatarUrl != null) {
        dataToUpdate['avatarUrl'] = newAvatarUrl;
      }

      await Provider.of<CommunityProvider>(
        context,
        listen: false,
      ).updateCommunityDetails(token, widget.initialData['id'], dataToUpdate);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update community: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.initialData['avatarUrl'];
    final formattedAvatarUrl =
        avatarUrl != null
            ? ApiService.getFullImageUrl(avatarUrl)
            : 'assets/images/test.jpg';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Community')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xff00d4ff),
                                      Color(0xff4a3aff),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child:
                                      _selectedImage != null
                                          ? Image.file(
                                            _selectedImage!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                          : formattedAvatarUrl.startsWith(
                                            'http',
                                          )
                                          ? CachedNetworkImage(
                                            imageUrl: formattedAvatarUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                          : Image.asset(
                                            formattedAvatarUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedCamera01,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          initialValue: _name,
                          decoration: const InputDecoration(
                            labelText: 'Community Name',
                          ),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Required'
                                      : null,
                          onSaved: (val) => _name = val!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _description,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Required'
                                      : null,
                          onSaved: (val) => _description = val!,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Private Community'),
                          subtitle: const Text(
                            'Users must request to join and be approved by an admin.',
                          ),
                          value: _isPrivate,
                          activeThumbColor: AppTheme.buttonColor,
                          onChanged: (val) {
                            setState(() {
                              _isPrivate = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Community Guidelines',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _guidelinesController,
                          decoration: const InputDecoration(
                            hintText:
                                'Enter rules and guidelines for your community here...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.buttonColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
