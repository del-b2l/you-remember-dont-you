from collections import deque
from dataclasses import dataclass, field


@dataclass
class EventMemory:
    """Small in-memory event ledger. Persistent clue facts are kept separately."""
    recent_events: deque[str] = field(default_factory=lambda: deque(maxlen=5))
    discovered_clues: set[str] = field(default_factory=set)

    def record(self, event: str) -> None:
        self.recent_events.append(event)

    def discover(self, clue_id: str) -> None:
        self.discovered_clues.add(clue_id)

    def context(self) -> dict:
        return {
            "recent_events": list(self.recent_events),
            "discovered_clues": sorted(self.discovered_clues),
        }
