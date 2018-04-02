import React from "react"
import PropTypes from "prop-types"
import { withTheme } from 'material-ui/styles';
import Paper from 'material-ui/Paper';
import GridList, {GridListTile} from 'material-ui/GridList'

class BingoBoard extends React.Component {

  constructor( props ){
    super( props );
  }

  componentDidMount( ){
  }

  render () {
    return (
      <Paper>
        <hr/>
        <center>{this.props.board.bingo_game.topic}</center>
        <hr/>
        <GridList
          cols={this.props.board.bingo_game.size}
          cellHeight="auto">
          {this.props.board.bingo_cells.map( cell => {
            return(
              <GridListTile key={cell.concept.id}>
                <center>
                <br/><br/>
                {cell.concept.name}
                <br/><br/>
                </center>
              </GridListTile>
            );
          } ) }
        </GridList>
      </Paper>
    );
  }
}

BingoBoard.propTypes = {
  board: PropTypes.object,
};
export default withTheme()(BingoBoard);
