import React from "react"
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
      concepts: [ ],
      selectedConcepts: [ ],
      boardSize: 5,
    }
  }

  randomizeTiles( ){
    var localConcepts = this.state.concepts;
    var selectedConcepts = {};
    var tileCount = ( this.state.boardSize * this.state.boardSize ) - 1
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
    this.setState( {
      selectedConcepts: localConcepts,
    } );

  }

  getConcepts(){
    fetch( this.props.url + '.json' , {
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
        this.randomizeTiles( );
      } );

  }

  componentDidMount( ){
    this.getConcepts();
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
          <Button
            variant="raised"
            onClick={() => this.randomizeTiles()}>
            Refresh
          </Button>
          <Paper>
            <GridList cols={this.state.boardSize}>
              {this.state.selectedConcepts.map( concept => {
                return(
                  <GridListTile key={concept.id}>
                    {concept.name}
                  </GridListTile>
                );
              } ) }
            </GridList>
          </Paper>
        </Paper>
      </MuiThemeProvider>
    );
  }
}

BingoBuilder.propTypes = {
  token: PropTypes.string,
  utl: PropTypes.string
};
export default withTheme()(BingoBuilder);
