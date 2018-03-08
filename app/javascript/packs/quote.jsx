// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

class Quote extends React.Component{
  constructor( ){
    super( );
    this.state = {
      quoteText:'no quote retrieved',
    };
  }

  componentDidMount( ) {
    updateQuote( );

  }

  updateQuote( ){
    this.setState( (prevState, props) => {
      return { quoteText: 'still working on it' }
    });
  }

  render( ){
    return (<p onClick={() => this.updateQuote()} className='quotes'>{this.state.quoteText}!</p>);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render( 
    <Quote />,
    document.getElementById("quote")
  );

})
