import uuid
from fastapi import HTTPException

from services.ai_service import generate_answer


documents = {}


def chunk_text(text: str, chunk_size: int = 2500, overlap: int = 300):
    chunks = []
    start = 0

    while start < len(text):
        end = start + chunk_size
        chunks.append(text[start:end])
        start += chunk_size - overlap

    return chunks


def create_document(filename: str, text: str) -> str:
    document_id = str(uuid.uuid4())

    documents[document_id] = {
        "filename": filename,
        "chunks": chunk_text(text),
    }

    return document_id


def answer_question(document_id: str, question: str) -> str:
    document = documents.get(document_id)

    if document is None:
        raise HTTPException(status_code=404, detail="Document not found")

    context = "\n\n".join(document["chunks"][:6])

    prompt = f"""
You are a helpful PDF assistant.

Rules:
- Answer only from the PDF context.
- If the answer is not found, say: "I could not find this in the PDF."
- Keep the answer clear and concise.

PDF Context:
{context}

Question:
{question}
"""

    return generate_answer(prompt)