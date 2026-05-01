from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from models.schemas import AskRequest
from services.pdf_service import extract_text_from_pdf
from services.rag_service import create_document, answer_question

app = FastAPI(title="PDF Chatbot API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def health_check():
    return {"message": "PDF Chatbot API is running"}


@app.post("/upload-pdf")
async def upload_pdf(file: UploadFile = File(...)):
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed")

    file_bytes = await file.read()
    text = extract_text_from_pdf(file_bytes)

    if not text.strip():
        raise HTTPException(status_code=400, detail="No text found in PDF")

    document_id = create_document(
        filename=file.filename,
        text=text,
    )

    return {
        "document_id": document_id,
        "filename": file.filename,
        "message": "PDF uploaded successfully",
    }


@app.post("/ask")
async def ask(request: AskRequest):
    try:
        answer = answer_question(
            document_id=request.document_id,
            question=request.question,
        )
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    return {"answer": answer}
