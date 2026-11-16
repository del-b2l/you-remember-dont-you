# YOU REMEMBER, DON'T YOU?

A small Godot 4 + FastAPI skeleton for a PS1-inspired first-person psychological
horror game.

## Requirements
- Godot 4.x
- Python 3.10+

## Run the game
1. Open this folder in Godot using `project.godot`.
2. Press **F6** to run the current scene or **F5** to run the project.

Controls:
- WASD: move
- Mouse: look
- E: inspect an object / speak to the woman
- Esc: release mouse; click the game window to capture it again

The bedroom is assembled from primitive meshes at runtime. The three clue
objects are the photograph, handwritten letter, and medication schedule.

## Run the backend
From the repository root:

```bash
cd backend
python -m venv .venv
```

Activate the environment, then:

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Test:
- Health: `http://127.0.0.1:8000/health`
- Interactive API docs: `http://127.0.0.1:8000/docs`

Example request:

```bash
curl -X POST http://127.0.0.1:8000/dialogue \
  -H "Content-Type: application/json" \
  -d '{"player_message":"What is this letter?","discovered_clues":["letter"]}'
```

## Current limitations
- Dialogue in Godot is local placeholder dialogue; it is not connected to FastAPI yet.
- FastAPI currently returns fallback dialogue only.
- Gemini integration is not implemented.
- The mother is a primitive placeholder model with no animation.
- No ending or save system is implemented.

See `docs/GAME_DESIGN.md` and `docs/API_CONTRACT.md`.
