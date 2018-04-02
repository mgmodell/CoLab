import React from "react"
import BingoBoard from './BingoBoard'
import PropTypes from "prop-types"
import { withTheme } from 'material-ui/styles';
import {createMuiTheme} from 'material-ui/styles';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import Chip from 'material-ui/Chip';
import Paper from 'material-ui/Paper';
import Button from 'material-ui/Button';
import GridList, {GridListTile} from 'material-ui/GridList'

const styles = createMuiTheme( );

class BingoBuilder extends React.Component {

  constructor( props ){
    super( props );
    this.state = {
      iteration: 0,
      concepts: [ ],
      board: {
        bingo_cells: [ ],
        iteration: 0,
        bingo_game: {
          size: 5,
          topic: 'no game',
        },
      }
    }
  }

  randomizeTiles( ){
    var localConcepts = this.state.concepts;
    var selectedConcepts = {};
    var size = this.state.board.bingo_game.size;
    var tileCount = ( size * size ) - 1;
    var midpoint = 0;

    var counter = 0
    while(
        Object.keys( selectedConcepts ).length < tileCount
        && counter < 75 ){
      counter++;
      var sample = localConcepts[
        Math.floor( Math.random( ) * localConcepts.length ) ];
      selectedConcepts[ sample.id ] = sample;

    }
    //Repurpose localConcepts
    localConcepts = Object.values( selectedConcepts );
    midpoint = localConcepts.length / 2;
    localConcepts.splice( midpoint, 0, {
      id: 0,
      name: '*',
    } );
    var cells = [ ]
    for( var row = 0; row < size; row++ ){
      for( var col = 0; col < size; col++ ){
        var i = ( row * 5 ) + col;
        var concept = localConcepts[ i ];
        cells[ i ] = {
          row: row,
          column: col,
          selected: ('*' == concept.name ? true : false ),
          concept: concept,
        }
      }
    }
    var board = this.state.board;
    board.bingo_cells = cells;
    this.setState( {
      iteration: this.state.iteration ++,
      board: board,
    } );

  }

  getConcepts(){
    fetch( this.props.conceptsUrl + '.json', {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'Accepts': 'application/json',
        'X-CSRF-Token': this.props.token } })
      .then( (response) => {
        if( response.ok ){
          return response.json( );
        } else {
          console.log( 'error' );
          return [
            { id: -1, name: 'no data' }
          ];
        }
      } )
      .then( (data) => {
        this.setState( {
          concepts: data
        });
      } );

  }

  componentDidMount( ){
    this.getConcepts();
    //Let's retrieve any existing board
    fetch( this.props.boardUrl + '.json', {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'Accepts': 'application/json',
        'X-CSRF-Token': this.props.token }
      } )
      .then( (response) => {
        if( response.ok ){
          return response.json( );
        } else {
          console.log( 'error' );
          return [
            { id: -1, name: 'no data' }
          ];
        }
      } )
      .then( (data) => {
        this.setState( {
          board: data,
        })
        if( data.bingo_cells.length < 1 ){
          this.randomizeTiles( );
        }
      } );
  }

  render () {
    return (
      <MuiThemeProvider theme={styles}>
        <Paper square={false}>
          <Paper>
            {this.state.concepts.map( chip => {
              return (
                <Chip
                  key={chip.id}
                  label={chip.name}
                />
              );
            })}
          </Paper>
          <br/>
          <Button
            variant="raised"
            onClick={() => this.randomizeTiles()}>
            Refresh
          </Button>&nbsp;
          <Button
            variant="raised"
            onClick={() => this.saveBoard()}>
            Save
          </Button>
          <BingoBoard board={this.state.board} />
        </Paper>
      </MuiThemeProvider>
    );
  }
}

BingoBuilder.propTypes = {
  token: PropTypes.string,
  boardUrl: PropTypes.string,
  conceptsUrl: PropTypes.string
};
export default withTheme()(BingoBuilder);
