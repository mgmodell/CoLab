import React from "react"
import PropTypes from "prop-types"
import { withTheme } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import GridList, {GridListTile} from '@material-ui/core/GridList'

class BingoBoard extends React.Component {

  constructor( props ){
    super( props );
  }

  componentDidMount( ){
  }

  render () {
    const grid = this.props.board.initialised ? (
          this.props.board.bingo_cells.map( cell => {
            return(
              <GridListTile
                key={cell.row + '-' + cell.column + '-' + cell.concept_id}>
                <center>
                <br/><br/>
                {cell.concept.name}
                <br/><br/>
                </center>
              </GridListTile>
            );
          } ) 
    ) : (
      <GridListTile></GridListTile>
    );
      
      
    const gameDate = new Date( this.props.board.bingo_game.end_date );
    return (
      <Paper>
        <hr/>
        <center>
          {this.props.board.bingo_game.topic}&nbsp; 
          ({gameDate.toDateString( )})
        </center>
        <hr/>
        <GridList
          cols={this.props.board.bingo_game.size}
          cellHeight="auto">
          {grid}
        </GridList>
        <hr/>
      </Paper>
    );
  }
}

BingoBoard.propTypes = {
  board: PropTypes.object,
};
export default withTheme()(BingoBoard);
