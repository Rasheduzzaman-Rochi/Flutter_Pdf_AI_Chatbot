import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class PdfChatApiException implements Exception {
  const PdfChatApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PdfChatApiService {
  static const Duration _timeout = Duration(seconds: 30);

  Future<String> uploadPdf(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.uploadPdf),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send().timeout(_timeout);
    final body = await response.stream.bytesToString();
    final data = _decodeBody(body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PdfChatApiException(_errorMessage(data, response.statusCode));
    }

    final documentId = data['document_id'];
    if (documentId is! String || documentId.isEmpty) {
      throw const PdfChatApiException(
        'The server did not return a document ID.',
      );
    }

    return documentId;
  }

  Future<String> askQuestion({
    required String documentId,
    required String question,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiConstants.askQuestion),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'document_id': documentId, 'question': question}),
        )
        .timeout(_timeout);

    final data = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PdfChatApiException(_errorMessage(data, response.statusCode));
    }

    final answer = data['answer'];
    if (answer is! String) {
      throw const PdfChatApiException('The server did not return an answer.');
    }

    return answer;
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      // The API should return JSON, but connection/proxy errors sometimes do not.
    }

    throw const PdfChatApiException('The server returned an invalid response.');
  }

  String _errorMessage(Map<String, dynamic> data, int statusCode) {
    final detail = data['detail'] ?? data['message'];
    if (detail is String && detail.isNotEmpty) {
      return detail;
    }

    return 'Request failed with status code $statusCode.';
  }
}
