from pydantic import BaseModel, Field
from typing import Literal


class DialogueRequest(BaseModel):
    player_message: str = Field(default="...", max_length=1000)
    recent_events: list[str] = Field(default_factory=list, max_length=5)
    discovered_clues: list[str] = Field(default_factory=list)
    suspicion_level: int = Field(default=0, ge=0, le=100)
    attachment_level: int = Field(default=0, ge=0, le=100)
    medication_taken: bool = False


class DialogueResponse(BaseModel):
    dialogue: str
    emotion: Literal["calm", "concerned", "defensive", "angry", "sad"] = "calm"
    response_type: Literal["reassurance", "deflection", "warning", "ordinary"] = "ordinary"
