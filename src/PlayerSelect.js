import React, {
  Component
} from 'react';
import Paper from 'material-ui/Paper';
import PropTypes from 'prop-types';

export default class PlayerSelect extends Component {
  handleMouseOver = (e, player) => {
    e.target.style.backgroundColor = this.props.colors[player];
  }

  handleMouseLeave = (e) => {
    e.target.style.backgroundColor = this.props.colors['default'];
  }

  render() {
    return (
      <div className='container'>
        <h1>Are you ready to rumble?</h1>
        <div>
          <Paper
            style={{color: this.props.colors['default']}}
            className='playingPiece'
            onMouseOver={(e) => this.handleMouseOver(e, 'player1')}
            onMouseLeave={this.handleMouseLeave}
            onClick={(e) => this.props.handleSelectHumanPlayer(e, '1')}
            zDepth={2}
            circle={true}
          >
            &#9654;
          </Paper>
        </div>
      </div>
    );
  }
}

PlayerSelect.propTypes = {
  colors: PropTypes.object.isRequired,
  handleSelectHumanPlayer: PropTypes.func.isRequired
}
