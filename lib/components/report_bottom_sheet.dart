import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/theme/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ReportBottomSheet extends StatefulWidget {
  final String itemType;
  final String itemId;
  final String? reportedUserId;
  final List<dynamic>? attachedMessages;

  const ReportBottomSheet({
    Key? key,
    required this.itemType,
    required this.itemId,
    this.reportedUserId,
    this.attachedMessages,
  }) : super(key: key);

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final List<String> reasons = [
    'Spam or misleading',
    'Harassment or bullying',
    'Inappropriate or explicit content',
    'Hate speech',
    'Scam or fraud',
    'Other',
  ];

  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  void _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a reason.')));
      return;
    }

    if (_selectedReason == 'Other' && _detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please specify a reason.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = context.read<AuthProvider>().token;
      if (token == null) return;

      final reportData = {
        'itemType': widget.itemType,
        'itemId': widget.itemId,
        'reportedUserId': widget.reportedUserId,
        'reason': _selectedReason,
        'details':
            _selectedReason == 'Other' ? _detailsController.text.trim() : null,
        'attachedMessages': widget.attachedMessages,
      };

      await ApiService.submitReport(token, reportData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit report: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report',
                style: TextStyle(
                  color: AppTheme.textColor2,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppTheme.textColor2),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Why are you reporting this?',
            style: TextStyle(color: AppTheme.textColor2, fontSize: 14),
          ),
          const SizedBox(height: 15),
          ...reasons.map(
            (reason) => RadioListTile<String>(
              title: Text(
                reason,
                style: const TextStyle(color: AppTheme.textColor2),
              ),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              activeColor: AppTheme.primaryBlue,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (_selectedReason == 'Other') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _detailsController,
              style: const TextStyle(color: AppTheme.textColor2),
              decoration: InputDecoration(
                hintText: 'Please specify...',
                hintStyle: const TextStyle(color: AppTheme.textColor2),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.textColor2),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryBlue),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text('Submit Report'),
            ),
          ),
        ],
      ),
    );
  }
}
