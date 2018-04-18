import React from "react"
import PropTypes from "prop-types"
import { withTheme } from 'material-ui/styles';
import {createMuiTheme} from 'material-ui/styles';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import Chip from 'material-ui/Chip';
import Paper from 'material-ui/Paper';

const styles = createMuiTheme( );

class ConceptChips extends React.Component {

  constructor( props ){
    super( props );
    this.state = {
      concepts: [ ],
    }
  }

  getConcepts(){
    fetch( this.props.url + '.json' , {
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
        });
      } );

  }

  componentDidMount( ){
    this.getConcepts();
  }
  render () {
    var c = [ { id: 1, name: 'nothing' } ];

    return (
      <MuiThemeProvider theme={styles}>
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
      </MuiThemeProvider>
    );
  }
}

ConceptChips.propTypes = {
  token: PropTypes.string,
  utl: PropTypes.string
};
export default withTheme()(ConceptChips);
