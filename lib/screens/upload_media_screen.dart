import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'paywall_screen.dart';

class UploadMediaScreen extends StatefulWidget {
  final String initialMediaType; // 'video' or 'audio'

  const UploadMediaScreen({super.key, required this.initialMediaType});

  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  String title = '';
  String category = 'Sermon';
  
  final List<String> _categories = [
    'Sermon',
    'Worship',
    'Podcast',
    'Teaching',
    'Testimony',
    'Other'
  ];
  
  File? _selectedMedia;
  String _duration = '00:00'; 
  
  File? _selectedThumbnail;
  bool _isUploading = false;

  Future<void> _pickMedia() async {
    if (widget.initialMediaType == 'video') {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedMedia = File(video.path);
        });
        await _extractVideoDuration(video.path);
        await _generateVideoThumbnail(video.path);
      }
    } else if (widget.initialMediaType == 'audio') {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedMedia = File(result.files.single.path!);
        });
        await _extractAudioDuration(result.files.single.path!);
      }
    }
  }

  Future<void> _extractVideoDuration(String path) async {
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    final duration = controller.value.duration;
    _setFormattedDuration(duration);
    controller.dispose();
  }

  Future<void> _generateVideoThumbnail(String path) async {
    final tempDir = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 400,
      quality: 75,
    );
    if (thumbnailPath != null) {
      setState(() {
        _selectedThumbnail = File(thumbnailPath);
      });
    }
  }

  Future<void> _extractAudioDuration(String path) async {
    final player = AudioPlayer();
    await player.setSourceDeviceFile(path);
    final duration = await player.getDuration();
    if (duration != null) {
      _setFormattedDuration(duration);
    }
    await player.dispose();
  }

  void _setFormattedDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = duration.inHours;
    setState(() {
      _duration = hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
    });
  }

  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedThumbnail = File(image.path);
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a media file')));
      return;
    }
    if (widget.initialMediaType == 'video' && _selectedThumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a thumbnail')));
      return;
    }
    
    _formKey.currentState!.save();
    setState(() => _isUploading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await ApiService.uploadMedia(token, _selectedMedia!.path, isReel: true);
      
      if (response.containsKey('error')) {
        final error = response['error'] as String;
        if (error.contains('limit reached')) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          );
          return;
        } else {
          throw Exception(error);
        }
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload successful')),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.initialMediaType == 'video';
    
    return Scaffold(
      appBar: AppBar(title: Text(isVideo ? 'Upload Video' : 'Upload Audio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => title = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: category,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => category = v!),
                onSaved: (v) => category = v!,
              ),
              const SizedBox(height: 32),
              
              // Media Picker
              GestureDetector(
                onTap: _pickMedia,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedMedia != null 
                              ? (isVideo ? Icons.video_library : Icons.audiotrack) 
                              : Icons.cloud_upload, 
                          size: 40, 
                          color: _selectedMedia != null ? AppTheme.buttonColor : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(_selectedMedia != null 
                            ? '${widget.initialMediaType} selected ($_duration)' 
                            : 'Tap to select ${widget.initialMediaType}'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Thumbnail Picker
              GestureDetector(
                onTap: _pickThumbnail,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    image: _selectedThumbnail != null 
                      ? DecorationImage(image: FileImage(_selectedThumbnail!), fit: BoxFit.cover) 
                      : null,
                  ),
                  child: _selectedThumbnail == null 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image, size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(isVideo ? 'Tap to change Thumbnail' : 'Tap to add Cover (Optional)'),
                          ],
                        ),
                      ) 
                    : null,
                ),
              ),
              
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isUploading ? null : _upload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
