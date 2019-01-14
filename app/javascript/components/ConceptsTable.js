/* eslint-disable no-console */

import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { withStyles } from '@material-ui/core/styles';
import TableCell from '@material-ui/core/TableCell';
import TableSortLabel from '@material-ui/core/TableSortLabel';
import Paper from '@material-ui/core/Paper';
import InputBase from '@material-ui/core/InputBase'
import SearchIcon from '@material-ui/icons/Search'
import Toolbar from '@material-ui/core/Toolbar'
import Typography from '@material-ui/core/Typography'
import { AutoSizer, Column, SortDirection, Table } from 'react-virtualized';

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

class MuiVirtualizedTable extends React.PureComponent {
  getRowClassName = ({ index }) => {
    const { classes, rowClassName, onRowClick } = this.props;

    return classNames(classes.tableRow, classes.flexContainer, rowClassName, {
      [classes.tableRowHover]: index !== -1 && onRowClick != null,
    });
  };

  cellRenderer = ({ cellData, columnIndex = null }) => {
    const { columns, classes, rowHeight, onRowClick } = this.props;
    return (
      <TableCell
        component="div"
        className={classNames(classes.tableCell, classes.flexContainer, {
          [classes.noClick]: onRowClick == null,
        })}
        variant="body"
        style={{ height: rowHeight }}
        align={(columnIndex != null && columns[columnIndex].numeric) || false ? 'right' : 'left'}
      >
        {cellData}
      </TableCell>
    );
  };

  headerRenderer = ({ label, columnIndex, dataKey, sortBy, sortDirection }) => {
    const { headerHeight, columns, classes, sort } = this.props;
    const direction = {
      [SortDirection.ASC]: 'asc',
      [SortDirection.DESC]: 'desc',
    };

    const inner =
      !columns[columnIndex].disableSort && sort != null ? (
        <TableSortLabel active={dataKey === sortBy} direction={direction[sortDirection]}>
          {label}
        </TableSortLabel>
      ) : (
        label
      );

    return (
      <TableCell
        component="div"
        className={classNames(classes.tableCell, classes.flexContainer, classes.noClick)}
        variant="head"
        style={{ height: headerHeight }}
        align={columns[columnIndex].numeric || false ? 'right' : 'left'}
      >
        {inner}
      </TableCell>
    );
  };

  render() {
    const { classes, columns, ...tableProps } = this.props;
    return (
      <AutoSizer>
        {({ height, width }) => (
          <Table
            className={classes.table}
            height={height}
            width={width}
            {...tableProps}
            rowClassName={this.getRowClassName}
          >
            {columns.map(({ cellContentRenderer = null, className, dataKey, ...other }, index) => {
              let renderer;
              if (cellContentRenderer != null) {
                renderer = cellRendererProps =>
                  this.cellRenderer({
                    cellData: cellContentRenderer(cellRendererProps),
                    columnIndex: index,
                  });
              } else {
                renderer = this.cellRenderer;
              }

              return (
                <Column
                  key={dataKey}
                  headerRenderer={headerProps =>
                    this.headerRenderer({
                      ...headerProps,
                      columnIndex: index,
                    })
                  }
                  className={classNames(classes.flexContainer, className)}
                  cellRenderer={renderer}
                  dataKey={dataKey}
                  {...other}
                />
              );
            })}
          </Table>
        )}
      </AutoSizer>
    );
  }
}

MuiVirtualizedTable.propTypes = {
  classes: PropTypes.object.isRequired,
  columns: PropTypes.arrayOf(
    PropTypes.shape({
      cellContentRenderer: PropTypes.func,
      dataKey: PropTypes.string.isRequired,
      width: PropTypes.number.isRequired,
    }),
  ).isRequired,
  headerHeight: PropTypes.number,
  onRowClick: PropTypes.func,
  rowClassName: PropTypes.string,
  rowHeight: PropTypes.oneOfType([PropTypes.number, PropTypes.func]),
  sort: PropTypes.func,
};

MuiVirtualizedTable.defaultProps = {
  headerHeight: 56,
  rowHeight: 56,
};

const WrappedVirtualizedTable = withStyles(styles)(MuiVirtualizedTable);


class ConceptsTable extends React.Component {

  constructor( props ){
    super( props );
    this.state = {
      concepts_raw: [ ],
      concepts: [],
      search: ''
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
        
  columns = [
        { title: 'Name', field: 'name' },
        { title: 'Times Suggested', field: 'times', sortable: false },
        { title: 'Course Appearances', field: 'courses', sortable: false },
        { title: 'Bingo! Appearances', field: 'bingos', sortable: false },
      ];

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
          columns={[
            {
              width: 200,
              flexGrow: 1.0,
              label: 'Name',
              dataKey: 'name',
            },
            {
              width: 120,
              label: 'Times Suggested',
              dataKey: 'times',
              numeric: true,
            },
            {
              width: 120,
              label: 'Course Appearances',
              dataKey: 'courses',
              numeric: true,
            },
            {
              width: 120,
              label: 'Bingo! Appearances',
              dataKey: 'bingos',
              numeric: true,
            },
          ]}
        />
      </Paper>
    );
  }
}

export default ConceptsTable;

