import React from "react"
import PropTypes from "prop-types"
import getURL from "../util.js"

class Quote extends React.Component {

  constructor( props ){
    super( props );
    this.state = {
      quote: {
        text: '',
        attribution: '...'
      }
    }
  }

  updateQuote(){
    fetch( getURL( 'quote' ), {
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
        }
      } )
      .then( (data) => {
        return this.setState ({
          quote: {
            text: data.text_en,
            attribution: data.attribution
          }
        } );
      } );

  }

  componentDidMount( ){
    this.updateQuote();
  }

  render () {
    return (
      <p onClick={() => this.updateQuote()} className='quotes'>
        {this.state.quote.text} ({this.state.quote.attribution})
      </p>
    );
  }
}

Quote.propTypes = {
  url: PropTypes.string,
  token: PropTypes.string
};

export default Quote
