from flask import Flask, render_template, request
from prolog import ai_move, win, draw
import json

app = Flask(
    __name__,
    static_folder="../build/static",
    template_folder="../build"
)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/play", methods=['POST'])
def play():
    if request.method == 'POST':
        data = json.loads(request.data)
        player = data.get('player')
        board = data.get('board')
        next_board, state = ai_move(player, board)

        winner = None
        if state == 'win':
            winner = player

        for i in range(len(next_board)):
            for j in range(len(next_board[0])):
                if board[i][j] != next_board[i][j]:
                    row = i
                    column = j
                    break

        return json.dumps({
            'row': row,
            'column': column,
            'nextBoard': next_board,
            'winner': winner
        })


@app.route("/win", methods=['POST'])
def wins():
    if request.method == 'POST':
        data = json.loads(request.data)
        player = data.get('player')
        board = data.get('board')
        winner = win(player, board)

        return json.dumps({
            'winner': winner
        })


@app.route("/draw", methods=['POST'])
def draws():
    if request.method == 'POST':
        data = json.loads(request.data)
        board = data.get('board')
        is_draw = draw(board)

        return json.dumps({
            'draw': is_draw
        })


if __name__ == "__main__":
    app.run(port=8000)
