/* eslint-disable no-console */

import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { withStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import InputBase from '@material-ui/core/InputBase'
import SearchIcon from '@material-ui/icons/Search'
import Toolbar from '@material-ui/core/Toolbar'
import Typography from '@material-ui/core/Typography'
import { AutoSizer, Column, SortDirection, Table } from 'react-virtualized';
import WrappedVirtualizedTable from '../components/WrappedVirtualizedTable';

const styles = theme => ({
  table: {
    fontFamily: theme.typography.fontFamily,
  },
  flexContainer: {
    display: 'flex',
    alignItems: 'center',
    boxSizing: 'border-box',
  },
  tableRow: {
    cursor: 'pointer',
  },
  tableRowHover: {
    '&:hover': {
      backgroundColor: theme.palette.grey[200],
    },
  },
  tableCell: {
    flex: 1,
  },
  noClick: {
    cursor: 'initial',
  },
});



class ConceptsTable extends React.Component {

  constructor( props ){
    super( props );
    this.state = {
      concepts_raw: [ ],
      concepts: [],
      search: '',
      columns: 
            [{
              width: 200,
              flexGrow: 1.0,
              label: 'Name',
              dataKey: 'name',
              numeric: false,
              visible: true,
            },
            {
              width: 120,
              label: 'Times Suggested',
              dataKey: 'times',
              numeric: true,
              visible: true,
            },
            {
              width: 120,
              label: 'Course Appearances',
              dataKey: 'courses',
              numeric: true,
              visible: true,
            },
            {
              width: 120,
              label: 'Bingo! Appearances',
              dataKey: 'bingos',
              numeric: true,
              visible: true,
            },
          ]
    }
    this.filter = this.filter.bind(this)
  }
      
  componentDidMount( ){
    //Retrieve concepts
    this.getConcepts( );
  }

  getConcepts( ){
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
        concepts: data,
        concepts_raw: data
      })
    } )
  }
        

  filter = function( event ){
    var filtered = this.state.concepts_raw.filter(
      concept => concept.cap_name.includes (
        event.target.value.toUpperCase() )
    )
    this.setState( { concepts: filtered } )
  }

  render() {
    return (
      <Paper style={{ height: 450, width: '100%' }}>
        <Toolbar>
        <InputBase placeholder="Search concepts" onChange={this.filter} />
        <SearchIcon />
        <Typography variant="h6" color="inherit" >
        Showing {this.state.concepts.length} of {this.state.concepts_raw.length}
        </Typography>
        </Toolbar>
        <WrappedVirtualizedTable
          rowCount={this.state.concepts.length}
          rowGetter={({ index }) => this.state.concepts[index]}
          onRowClick={event => 
            window.open( this.props.conceptsUrl + '/' +event.rowData.id, '_self' )
          }
          columns={this.state.columns}
        />
      </Paper>
    );
  }
}

export default ConceptsTable;

