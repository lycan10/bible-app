import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/titles/title_one.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: widget.title,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SfPdfViewer.network(
                    widget.pdfUrl,
                    key: _pdfViewerKey,
                    canShowScrollHead: false,
                    canShowScrollStatus: false,
                    onDocumentLoaded: (details) {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    onDocumentLoadFailed: (details) {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff673aff),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
