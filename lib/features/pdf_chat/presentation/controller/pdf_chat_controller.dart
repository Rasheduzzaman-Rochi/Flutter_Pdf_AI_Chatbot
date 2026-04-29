import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/models/chat_message.dart';
import '../../data/services/pdf_chat_api_service.dart';

class PdfChatController extends ChangeNotifier {
  final PdfChatApiService _apiService = PdfChatApiService();

  String? documentId;
  String? pdfName;

  bool isUploading = false;
  bool isThinking = false;

  final List<ChatMessage> messages = [];

  Future<void> uploadPdf(File file) async {
    isUploading = true;
    pdfName = file.path.split('/').last;
    notifyListeners();

    try {
      documentId = await _apiService.uploadPdf(file);

      messages.add(
        ChatMessage(
          text: 'PDF uploaded successfully. Ask me anything from this document.',
          isUser: false,
        ),
      );
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<void> askQuestion(String question) async {
    if (question.trim().isEmpty || documentId == null) return;

    messages.add(ChatMessage(text: question, isUser: true));
    isThinking = true;
    notifyListeners();

    try {
      final answer = await _apiService.askQuestion(
        documentId: documentId!,
        question: question,
      );

      messages.add(ChatMessage(text: answer, isUser: false));
    } catch (_) {
      messages.add(
        ChatMessage(
          text: 'Sorry, something went wrong. Please try again.',
          isUser: false,
        ),
      );
    } finally {
      isThinking = false;
      notifyListeners();
    }
  }
}