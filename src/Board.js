import React, {
  Component
} from 'react';
import PropTypes from 'prop-types';
import IconButton from 'material-ui/IconButton';
import AvReplay from 'material-ui/svg-icons/av/replay';
import Cell from './Cell';

export default class Board extends Component {
  populateBoard() {
    let board = [];
    for (let row = 0; row < this.props.height; row++) {
      let emptyRow = [];
      for (let column = 0; column < this.props.width; column++) {
        emptyRow.push('-');
      }
      board.push(emptyRow)
    }

    return board;
  }

  constructor(props) {
    super(props);
    this.state = {
      player: '1',
      board: this.populateBoard(),
      waiting: this.props.humanPlayer !== '1',
      winner: null,
      draw: false
    }
  }

  handleAIMove = (board) => {
    fetch('/play', {
      method: 'post',
      body: JSON.stringify({
        'player': this.props.humanPlayer === '1' ? '2' : '1',
        'board': board
      })
    })
    .then((response) => response.json())
    .then((responseJson) => {
      this.setState({
        'player': this.props.humanPlayer,
        'board': responseJson.nextBoard,
        'waiting': false,
        'winner': responseJson.winner
      });

      let cell = document.querySelector(`.cell[data-row="${responseJson.row}"][data-column="${responseJson.column}"]`);
      cell.classList.remove('cell--open');  // cell no longer open

      let cellHole = document.querySelector(`.cell-hole[data-row="${responseJson.row}"][data-column="${responseJson.column}"]`);
      cellHole.style.backgroundColor = this.props.colors[`player${this.props.humanPlayer === '1' ? '2' : '1'}`];
    })
    .catch((error) => {
      console.error(error);
    });
  }

  checkWin = (board, player) => {
    fetch('/win', {
      method: 'post',
      body: JSON.stringify({
        'player': player,
        'board': board
      })
    })
    .then((response) => response.json())
    .then((responseJson) => {
      if (responseJson.winner) {
        this.setState({
          'winner': responseJson.winner
        });
      } else {
        this.checkDraw(board, player);
      }
    })
    .catch((error) => {
      console.error(error);
    })
  }

  checkDraw = (board) => {
    fetch('/draw', {
      method: 'post',
      body: JSON.stringify({
        'board': board
      })
    })
    .then((response) => response.json())
    .then((responseJson) => {
      if (responseJson.draw) {
        this.setState({
          'draw': true
        });
      } else {
        this.setState({
          'waiting': true
        });
        this.handleAIMove(board);
      }
    })
    .catch((error) => {
      console.error(error);
    })
  }

  handleHumanMove = (e, newBoard, player) => {
    this.setState(prevState => ({
      // TODO: Allow more than 2 players by using circular buffer to update
      //       player numbers
      player: prevState.player === '1' ? '2' : '1',
      board: newBoard
    }));

    this.checkWin(newBoard, player);
  }

  handleRequestHumanMove = (e) => {
    let newBoard = [...this.state.board];
    let column = e.target.getAttribute('data-column');
    let row = 0;
    while (this.state.board[row][column] !== '-' && row < this.props.height - 1) {
      row++;
    }

    if (newBoard[row][column] === '-' && !this.state.waiting) {
      newBoard[row][column] = this.state.player;

      let cell = document.querySelector(`.cell[data-row="${row}"][data-column="${column}"]`);
      cell.classList.remove('cell--open');  // cell no longer open

      let cellHole = document.querySelector(`.cell-hole[data-row="${row}"][data-column="${column}"]`);
      cellHole.style.backgroundColor = this.props.colors[`player${this.state.player}`];

      this.handleHumanMove(e, newBoard, this.state.player);
    }
  }

  render() {
    let restartButton = (
      <IconButton
        tooltip="Replay"
        tooltipPosition="top-center"
        iconStyle={{width: 32, height: 32}}
        style={{width: 48, height: 48, lineHeight: '32px', display: 'flex', justifyContent: 'center'}}
        onClick={(e) => {this.props.handleRestart(e)}}
      >
        <AvReplay />
      </IconButton>
    );
    let headerText = this.state.winner || this.state.draw ?
      this.state.draw ? 'You drew. Try again.' :
      this.state.winner === this.props.humanPlayer ? 'You win this time.' : 'The AI crushed you.' :
      this.state.player === this.props.humanPlayer ? 'Your turn.' : 'The AI is thinking';

    return (
      <div className='container'>
        <div className='header'>
          <h1 className={this.state.waiting ? 'waiting' : ''}>{headerText}</h1>
          {this.state.winner || this.state.draw ? restartButton : null}
        </div>
        <div className='board'>
          {[...Array(this.props.width).keys()].map((column) => {
            return (
              <div
                className='column'
                key={`column-${column}`}
                onClick={this.handleRequestHumanMove.bind(this)}
              >
                {
                  [...Array(this.props.height).keys()].map((row) => {
                  return (
                      <Cell
                        colors={this.props.colors}
                        key={`cell-${row}-${column}`}
                        player={this.state.player}
                        waiting={this.state.waiting}
                        winner={this.state.winner}
                        row={row}
                        column={column}
                      />
                    );
                  })
                }
              </div>
            );
          })}
        </div>
      </div>
    );
  }
}

Board.propTypes = {
  height: PropTypes.number.isRequired,
  width: PropTypes.number.isRequired,
  colors: PropTypes.object.isRequired,
  humanPlayer: PropTypes.string.isRequired,
  handleRestart: PropTypes.func.isRequired,
}
