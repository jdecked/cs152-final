import React, { Component } from 'react';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import './App.css';
import { red500, yellow500 } from 'material-ui/styles/colors';

import PlayerSelect from './PlayerSelect';
import Board from './Board';

const BOARD_HEIGHT = 6;
const BOARD_WIDTH = 7;
const DEFAULT_COLOR = 'white';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      humanPlayer: null,
      restart: false
    }
  }

  handleSelectHumanPlayer = (e, player) => {
    this.setState({
      humanPlayer: player,
      restart: false
    })
  }

  handleRestart = (e) => {
    this.setState({
      restart: true
    })
  }

  render() {
    const colors = {
      player1: red500,
      player2: yellow500,
      default: DEFAULT_COLOR
    }

    return (
      <MuiThemeProvider>
        {
          this.state.humanPlayer && !this.state.restart ?
          <Board
            height={BOARD_HEIGHT}
            width={BOARD_WIDTH}
            colors={colors}
            humanPlayer={this.state.humanPlayer}
            handleRestart={this.handleRestart}
          /> :
          <PlayerSelect
            colors={colors}
            handleSelectHumanPlayer={this.handleSelectHumanPlayer}
          />
        }
      </MuiThemeProvider>
    );
  }
}

export default App;
