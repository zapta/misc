"""A simple utility to string '//' comments from a json file.
It allows to add comments in apio resource files.

Inspired by the state machine in 
https://github.com/xitop/jsonstrip/blob/main/jsonstrip.py
"""

from enum import Enum
from dataclasses import dataclass
import time


class _State(Enum):
    """Represents the parsing state."""
    IDLE = 1
    IN_STRING = 2
    IN_STRING_ESCAPE = 3
    IN_FIRST_SLASH = 4
    IN_COMMENT = 5


class _Action(Enum):
    """Actions that are performed on the finite state transitions """
    NO_ACTION = 1
    COPY_TO_COMMENT = 2
    SKIP_TO_CURRENT_LOCATION = 3


@dataclass(frozen=True)
class _Transition:
    new_state: _State
    action: _Action


# A key for any other char.
ELSE = "ELSE"


# -- A dict from a state to state transitions. Each state transition is a 
# -- dict from an input char to a transition, with ELSE is the transition to
# -- all other chars.
STATES_TRANSITIONS = {
    _State.IDLE: {
        "/": _Transition(_State.IN_FIRST_SLASH, _Action.NO_ACTION),
        '"': _Transition(_State.IN_STRING, _Action.NO_ACTION),
    },
    _State.IN_STRING: {
        "\\": _Transition(_State.IN_STRING_ESCAPE, _Action.NO_ACTION),
        '"': _Transition(_State.IDLE, _Action.NO_ACTION),
    },
    _State.IN_STRING_ESCAPE: {
        ELSE: _Transition(_State.IN_STRING, _Action.NO_ACTION),
    },
    _State.IN_FIRST_SLASH: {
        "/": _Transition(_State.IN_COMMENT, _Action.COPY_TO_COMMENT),
        ELSE: _Transition(_State.IDLE, _Action.NO_ACTION),
    },
    _State.IN_COMMENT: {
        "\r": _Transition(_State.IDLE, _Action.SKIP_TO_CURRENT_LOCATION),
        "\n": _Transition(_State.IDLE, _Action.SKIP_TO_CURRENT_LOCATION),
    },
}


def convert(input: str) -> str:
    """ """
    output = []

    # -- Indicates the input position that is aleardy covered by the content
    # -- in output. It can be larger than the size of the text in output since
    # -- we drop comment text.
    output_pos = 0

    # -- The current state of the state machine.
    state = _State.IDLE
    state_transitions = STATES_TRANSITIONS[state]

    # -- Iterate and process the input chars.
    for input_pos, ch in enumerate(input):

        if ch in state_transitions:
            # -- Found a transition for this char.
            transition: _Transition = state_transitions[ch]

        elif ELSE in state_transitions:
            # -- Use the default transition if any.
            transition: _Transition = state_transitions[ELSE]

        else:
            # -- Otherwise, do nothing. All of our actions are in transitions.
            continue

        # -- We found a transition. Apply it.

        # -- Set the state.
        state = transition.new_state
        state_transitions = STATES_TRANSITIONS[state]

        # -- Perform action, if any.
        if transition.action is _Action.SKIP_TO_CURRENT_LOCATION:
            # -- Move output pos to input pos. This is how we skip over
            # -- comments.
            output_pos = input_pos
            continue

        if transition.action is _Action.COPY_TO_COMMENT:
            # -- We just entered a comment, copy any pending text from
            # -- before the '//'.
            output.append(input[output_pos : input_pos - 1])
            output_pos = input_pos - 1
            continue

        # -- Here when the transition doesn't have an action. Do nothing.
        assert transition.action is _Action.NO_ACTION

    # -- Here we reached the end of the input. Copy pending non comment text
    # -- if any.
    if state != _State.IN_COMMENT:
        output.append(input[output_pos:])

    # -- Concatanate the text pieces into a string.
    return "".join(output)


if __name__ == "__main__":
    with open("test.jsonc") as f:
        text = f.read()
    t0 = time.time()
    output = convert(text)
    t1 = time.time()
    print(output)

    print(t1 - t0)
