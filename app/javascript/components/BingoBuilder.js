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
import html2canvas from 'html2canvas';
import jsPDF from 'jspdf';

const styles = createMuiTheme( );

class BingoBuilder extends React.Component {

  constructor( props ){
    super( props );
    this.state = {
      saveStatus: '',
      concepts: [ ],
      board: {
        initialised: false,
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
    var selectedConcepts = {};
    var iteration = this.state.board.iteration + 1;
    var counter = 0;
    
    while( Object.keys( selectedConcepts ).length <
              this.state.board.bingo_cells.length &&
              counter < 100 ){
      counter ++;
      var sample = this.state.concepts[
        Math.floor( Math.random( ) * this.state.concepts.length ) ];

      selectedConcepts[ sample.id ] = sample;

    }
    //Repurpose localConcepts
    var localConcepts = Object.values( selectedConcepts );
    var size = this.state.board.bingo_game.size;
    var cells = this.state.board.bingo_cells;
    for( var row = 0; row < size; row++ ){
      for( var col = 0; col < size; col++ ){
        var i = ( row * 5 ) + col;
        var concept = localConcepts[ i ];

        var mid = Math.round( size / 2 ) - 1;
        var midSquare = row == mid &&
                        col == mid &&
                        mid != size / 2;

        concept = midSquare ? {id: 0, name: '*'} : concept;

        cells[ i ].row= row;
        cells[ i ].column =  col;
        cells[ i ].selected = midSquare ? true : false;
        cells[ i ].concept_id = concept.id;
        cells[ i ].concept = concept;
      }
    }
    var board = this.state.board;
    board.bingo_cells = cells;
    board.iteration = iteration;
    board.initialised = true;
    this.setState( {
      board: board,
    } );

  }

  getConcepts( callbackFunc ){
    fetch( this.props.conceptsUrl + '.json', {
      method: 'GET',
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
        }, callbackFunc );
      } );

  }

  getBoard( ){
    fetch( this.props.boardUrl + '.json', {
      method: 'GET',
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
        data.initialised = data.id != null;
        data.iteration = 0;
        this.setState( {
          board: data,
        } );
        //}, this.randomizeTiles );
      } );

  }

  saveBoard( ){
    var board = this.state.board;
    board.bingo_cells_attributes = board.bingo_cells;
    delete board.bingo_cells;
    fetch( this.props.boardSaveUrl + '.json', {
      method: 'PATCH',
      credentials: 'include',
      body: JSON.stringify( { bingo_board: this.state.board } ),
      headers: {
        'Content-Type': 'application/json',
        'Accepts': 'application/json',
        'X-CSRF-Token': this.props.token },
      } )
      .then( (response) => {
        if( response.ok ){
          return response.json( );
        } else {
          console.log( 'error' );
          return { };
        }
      } )
      .then( (data) => {
        data.initialised = true;
        data.iteration = 0;

        if( data.id != null ){
          this.setState( {
            saveStatus: 'Your board has been saved',
            board: data,
          } );
        } else {
          this.setState( {
            saveStatus: 'Save failed. Please try again or contact support',
          } );

        }
      } );
  }

  printBoard( ){

    const input = document.getElementById( 'bingoBoard' );
    html2canvas( input )
      .then( (canvas) => {
        const imgData = canvas.toDataURL( 'image/png' );
        const pdf = new jsPDF( );
        pdf.addImage( imgData, 'JPEG', 0, 0 );
        pdf.save( 'bingoBoard.pdf' );
      } )
    ;

  }

  componentDidMount( ){
    this.getConcepts( this.getBoard );
    //Let's retrieve any existing board
  }

  render () {
    const saveBtn = this.state.board.initialised &&
    (this.state.board.iteration > 0 ) ? (
          <Button
            variant="raised"
            onClick={() => this.saveBoard()}>
            Save
          </Button>
    ) : null;

    const printBtn = this.state.board.id != null &&
      (this.state.board.iteration == 0 )? (
          <Button
            variant="raised"
            onClick={() => this.printBoard()}>
            Print
          </Button>
    ) : null;

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
            Generate New Board
          </Button>&nbsp;
          {saveBtn}
          {printBtn}
          <div id='bingoBoard' className="mt4">
            <BingoBoard board={this.state.board} />
          </div>
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