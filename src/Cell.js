import React, {
  Component
} from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

export default class Cell extends Component {
  render() {
    let cellClasses = classNames({
      'cell': true,
      'cell--open': true
    })

    let cellHoleClasses = classNames({
      'cell-hole': true,
      [`cell-hole--player${this.props.player}`]: !(this.props.waiting || this.props.winner)
    })

    return (
      <div
        className={cellClasses}
        data-row={this.props.row}
        data-column={this.props.column}
      >
        <div
          className={cellHoleClasses}
          data-row={this.props.row}
          data-column={this.props.column}
        />
      </div>
    );
  }
}

Cell.propTypes = {
  column: PropTypes.number.isRequired,
  player: PropTypes.string.isRequired,
  waiting: PropTypes.bool.isRequired,
  winner: PropTypes.string.isRequired,
  row: PropTypes.number.isRequired
}
