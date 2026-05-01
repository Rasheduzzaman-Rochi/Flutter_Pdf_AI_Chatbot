import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/services/pdf_chat_api_service.dart';
import '../controller/pdf_chat_controller.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PdfChatController controller = PdfChatController();

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    try {
      await controller.uploadPdf(file);
    } on PdfChatApiException catch (error) {
      if (!mounted) return;
      _showUploadError(error.message);
      return;
    } on SocketException {
      if (!mounted) return;
      _showUploadError(
        'Could not connect to the API. Make sure the backend is running on port 8000.',
      );
      return;
    } catch (_) {
      if (!mounted) return;
      _showUploadError('Could not upload the PDF. Please try again.');
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(controller: controller)),
    );
  }

  void _showUploadError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    'Chat with your PDF',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload a PDF and ask questions from its content.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: controller.isUploading ? null : pickPdf,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 52,
                            color: Colors.indigo,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            controller.isUploading
                                ? 'Uploading PDF...'
                                : 'Upload PDF',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: controller.isUploading ? null : pickPdf,
                      child: Text(
                        controller.isUploading
                            ? 'Please wait...'
                            : 'Choose PDF',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
