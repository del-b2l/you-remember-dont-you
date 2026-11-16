from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .schemas import DialogueRequest, DialogueResponse
from .fallback import fallback_dialogue

app = FastAPI(title="You Remember, Don't You? API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict this before production deployment.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/dialogue", response_model=DialogueResponse)
def dialogue(request: DialogueRequest):
    # Gemini integration is intentionally deferred. The endpoint is usable now.
    return fallback_dialogue(request)
