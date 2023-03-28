import React from "react";
import PropTypes from "prop-types";
import withTheme from "@mui/styles/withTheme";
import Paper from "@mui/material/Paper";
import ImageList from "@mui/material/ImageList";
import ImageListItem from "@mui/material/ImageListItem";
class BingoBoard extends React.Component {
  constructor(props) {
    super(props);
  }
  componentDidMount() {}
  render() {
    const grid = this.props.board.initialised ? (
      this.props.board.bingo_cells.map(cell => {
        return (
          <ImageListItem
            key={cell.row + "-" + cell.column + "-" + cell.concept_id}
          >
            <center>
              <br />
              <br />
              {cell.concept.name}
              <br />
              <br />
            </center>
          </ImageListItem>
        );
      })
    ) : (
      <ImageListItem />
    );
    const gameDate = new Date(this.props.board.bingo_game.end_date);
    return (
      <Paper>
        <hr />
        <center>
          {this.props.board.bingo_game.topic}&nbsp; ({gameDate.toDateString()})
        </center>
        <hr />
        <ImageList cols={this.props.board.bingo_game.size} rowHeight="auto">
          {grid}
        </ImageList>
        <hr />
      </Paper>
    );
  }
}
BingoBoard.propTypes = {
  board: PropTypes.object
};
export default withTheme(BingoBoard);
