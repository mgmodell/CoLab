import React from "react"
import PropTypes from "prop-types"
import { withStyles } from 'material-ui/styles';
import Chip from 'material-ui/Chip';
import Paper from 'material-ui/Paper';

class ConceptChips extends React.Component {

  constructor( props ){
    super( props );
    this.state = {
      concepts: [ ],
    }
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
      } );

  }

  componentDidMount( ){
    this.getConcepts();
  }
  render () {
    var c = [ { id: 1, name: 'nothing' } ];

    return (
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
    );
  }
}

ConceptChips.propTypes = {
  token: PropTypes.string,
  utl: PropTypes.string
};
export default ConceptChips
