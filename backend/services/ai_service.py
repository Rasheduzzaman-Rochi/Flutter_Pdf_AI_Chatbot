import os
import requests
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-1.5-flash")
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama3-8b-8192")


def call_gemini(prompt: str) -> str:
    if not GEMINI_API_KEY:
        raise Exception("Gemini API key missing")

    url = (
        "https://generativelanguage.googleapis.com/v1beta/"
        f"models/{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}"
    )

    payload = {
        "contents": [
            {
                "parts": [
                    {"text": prompt}
                ]
            }
        ]
    }

    response = requests.post(url, json=payload, timeout=60)

    if response.status_code != 200:
        raise Exception(response.text)

    data = response.json()
    return data["candidates"][0]["content"]["parts"][0]["text"]


def call_groq(prompt: str) -> str:
    if not GROQ_API_KEY:
        raise Exception("Groq API key missing")

    url = "https://api.groq.com/openai/v1/chat/completions"

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": GROQ_MODEL,
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful PDF assistant.",
            },
            {
                "role": "user",
                "content": prompt,
            },
        ],
        "temperature": 0.2,
    }

    response = requests.post(url, headers=headers, json=payload, timeout=60)

    if response.status_code != 200:
        raise Exception(response.text)

    data = response.json()
    return data["choices"][0]["message"]["content"]


def generate_answer(prompt: str) -> str:
    try:
        return call_gemini(prompt)
    except Exception:
        return call_groq(prompt)