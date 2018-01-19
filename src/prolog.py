from pyswip.prolog import Prolog


def ai_move(Player, Board):
    prolog = Prolog()
    prolog.consult("KB.pl")

    query = "best_move([{}, play, {}], 6, [_, State, NextBoard]).".format(
        Player,
        str(Board)
        .replace('"', "")
        .replace("'", "")
        .replace("-", "0")
        .replace("u", "")
    )

    next_move = None
    state = None
    for ans in prolog.query(query, maxresult=1):
        next_move = ans['NextBoard']
        next_move = [
            ["{}".format(cell).replace("0", "-") for cell in row]
            for row in next_move
        ]
        state = ans['State']
    return next_move, state


def win(Player, Board):
    prolog = Prolog()
    prolog.consult("KB.pl")
    query = "win({}, {}).".format(
        Player,
        str(Board)
        .replace('"', "")
        .replace("'", "")
        .replace("-", "0")
        .replace("u", "")
    )

    # From the PySWIP docs, this returns {} for true and nothing for false
    result = prolog.query(query, maxresult=1)
    try:
        winner = result.next()
    except StopIteration:
        winner = None

    return Player if winner == {} else None


def draw(Board):
    prolog = Prolog()
    prolog.consult("KB.pl")
    query = "draw(_, {}).".format(
        str(Board)
        .replace('"', "")
        .replace("'", "")
        .replace("-", "0")
        .replace("u", "")
    )

    # From the PySWIP docs, this returns {} for true and nothing for false
    result = prolog.query(query, maxresult=1)
    try:
        is_draw = result.next()
    except StopIteration:
        is_draw = None

    return is_draw == {}
