from .schemas import DialogueRequest, DialogueResponse


def fallback_dialogue(request: DialogueRequest) -> DialogueResponse:
    clues = set(request.discovered_clues)

    if "letter" in clues:
        return DialogueResponse(
            dialogue="You shouldn't go through other people's things. That letter is old. It doesn't mean what you think.",
            emotion="defensive",
            response_type="deflection",
        )
    if "photo" in clues:
        return DialogueResponse(
            dialogue="That's a lovely picture, isn't it? You were so small. You remember, don't you?",
            emotion="calm",
            response_type="reassurance",
        )
    if "medication" in clues:
        return DialogueResponse(
            dialogue="It's just your schedule. You know how difficult things get when you miss a dose.",
            emotion="concerned",
            response_type="warning",
        )
    if request.suspicion_level >= 2:
        return DialogueResponse(
            dialogue="Why are you looking at me like that? I'm only trying to take care of you.",
            emotion="defensive",
            response_type="deflection",
        )
    return DialogueResponse(
        dialogue="Come away from the door, sweetheart. You're making yourself anxious.",
        emotion="concerned",
        response_type="reassurance",
    )
