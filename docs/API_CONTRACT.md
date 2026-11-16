# Dialogue API contract

Base URL (local): `http://127.0.0.1:8000`

## `GET /health`

Returns:

```json
{"status": "ok"}
```

## `POST /dialogue`

Request:

```json
{
  "player_message": "What is in this letter?",
  "recent_events": ["Inspected photo", "Spoke to the woman"],
  "discovered_clues": ["photo", "letter"],
  "suspicion_level": 1,
  "attachment_level": 0,
  "medication_taken": false
}
```

Response:

```json
{
  "dialogue": "You shouldn't go through other people's things.",
  "emotion": "defensive",
  "response_type": "deflection"
}
```

The current implementation returns deterministic fallback dialogue. Gemini
integration is intentionally not included in this skeleton.
