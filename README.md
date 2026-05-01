# Flutter PDF AI Chatbot

A Flutter app for uploading a PDF and asking questions about its content. The mobile app sends the PDF to a local FastAPI backend, the backend extracts text from the PDF, builds a simple in-memory document context, and uses Gemini with Groq fallback to generate grounded answers.

## Features

- Upload PDF files from the device.
- Chat with the uploaded document.
- FastAPI backend with PDF text extraction using PyMuPDF.
- Gemini primary AI provider and Groq fallback provider.
- Android emulator support with local backend networking.
- Clean chat UI with loading, empty, and error states.

## Project Structure

```text
lib/
  core/constants/             API URL configuration
  features/pdf_chat/
    data/                     API service and models
    presentation/             Screens, controller, and widgets

backend/
  main.py                     FastAPI routes
  services/pdf_service.py     PDF text extraction
  services/rag_service.py     Document storage and prompt building
  services/ai_service.py      Gemini and Groq API calls
  run.sh                      Backend startup script
```

## Requirements

- Flutter SDK
- Dart SDK, included with Flutter
- Python 3.9 or newer
- Android Studio or Xcode for running on a device/simulator
- Gemini API key and/or Groq API key

## Backend Setup

Go to the backend folder:

```bash
cd backend
```

Create and activate a virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Create `backend/.env`:

```env
GEMINI_API_KEY=your_gemini_api_key
GROQ_API_KEY=your_groq_api_key
GEMINI_MODEL=gemini-1.5-flash
GROQ_MODEL=llama-3.1-8b-instant
```

Start the backend:

```bash
./run.sh
```

The API should be available at:

```text
http://127.0.0.1:8000
```

Health check:

```bash
curl http://127.0.0.1:8000/
```

Expected response:

```json
{"message":"PDF Chatbot API is running"}
```

## Flutter Setup

From the project root:

```bash
flutter pub get
```

Run on Android emulator:

```bash
flutter run -d emulator-5554
```

Or run on the currently selected device:

```bash
flutter run
```

## API URL Notes

The app uses different backend URLs depending on platform:

- Android emulator: `http://10.0.2.2:8000`
- iOS simulator, macOS, and local desktop: `http://127.0.0.1:8000`

This is configured in:

```text
lib/core/constants/api_constants.dart
```

Android cleartext HTTP is enabled for local development in:

```text
android/app/src/main/AndroidManifest.xml
```

## Useful Commands

Analyze Flutter code:

```bash
flutter analyze
```

Run Flutter tests:

```bash
flutter test
```

Run backend on another port:

```bash
PORT=8001 ./backend/run.sh
```

Stop an existing backend process if port `8000` is busy:

```bash
lsof -tiTCP:8000 -sTCP:LISTEN | xargs kill
```

## Troubleshooting

### Backend port is already in use

If `./backend/run.sh` says port `8000` is already in use, the backend may already be running. You can keep using it, stop it, or start another backend on a different port.

### Android app cannot connect to backend

Make sure:

- The backend is running on port `8000`.
- You are using an Android emulator, not macOS desktop target.
- The app URL for Android is `10.0.2.2`, not `127.0.0.1`.

### Groq model decommissioned error

Use:

```env
GROQ_MODEL=llama-3.1-8b-instant
```

Older model IDs like `llama3-8b-8192` are no longer supported by Groq.

### Missing `fitz` module

Install backend dependencies inside the active virtual environment:

```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
```

## Current Limitations

- Uploaded PDF content is stored in memory, so documents disappear when the backend restarts.
- The app is intended for local development.
- Answers depend on the configured AI provider keys and quota.

## License

This project is for learning and local development. Add a license before publishing or distributing it.
