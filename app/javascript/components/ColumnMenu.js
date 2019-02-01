import React from 'react'
import FormControlLabel from '@material-ui/core/FormControlLabel'
import Checkbox from '@material-ui/core/Checkbox'
import IconButton from '@material-ui/core/IconButton'
import ListItemText from '@material-ui/core/ListItemText'
import Menu from '@material-ui/core/Menu'
import MenuItem from '@material-ui/core/MenuItem'
import PropTypes from 'prop-types'
import ViewColumnRounded from '@material-ui/icons/ViewColumnRounded'

class ColumnMenu extends React.Component {
  constructor( props ){
    super( props );
    this.state = {
      anchorEl: null,
      menuDisabled: true,
    };
    this.handleClick = this.handleClick.bind( this )
    this.handleClose = this.handleClose.bind( this )
  }


  handleClick = event => {
    this.setState({
      anchorEl: event.currentTarget,
      menuVisible: false,
    });
  };

  handleClose = () => {
    this.setState({
      anchorEl: null,
      menuVisible: true,
    });
  };

  menuClick = ( event, index ) => {
    this.props.selMethod( event, index )
    //this.handleClose( )
  }


  render() {
    const { anchorEl } = this.state;

    return (
      <React.Fragment>
        <IconButton
          aria-owns={anchorEl ? 'column-menu' : undefined}
          aria-haspopup="true"
          onClick={this.handleClick}
        >
          <ViewColumnRounded />
        </IconButton>
        <Menu
          id="column-menu"
          anchorEl={anchorEl}
          open={Boolean(anchorEl)}
          onClose={this.handleClose}
          disabled={this.state.menuVisible}
        >
        {this.props.columns.map( (column, index)=>{
        return(
          <MenuItem key={'col_'+index}
            value={'col_'+index}
            onClick={() => this.menuClick( event, index )}
          >
                <Checkbox checked={column.visible}
                  key={'chk_'+index}
                  value={"col_"+index}
                />
              <ListItemText primary={column.label} />
          </MenuItem>
          )
        } ) }
        </Menu>
      </React.Fragment>
    );
  }
}

ColumnMenu.propTypes = {
  selMethod: PropTypes.func,
  columns: PropTypes.arrayOf(
    PropTypes.shape( {
      width: PropTypes.number,
      flexGrow: PropTypes.number,
      label: PropTypes.string,
      dataKey: PropTypes.string,
      numeric: PropTypes.bool,
      visible: PropTypes.bool,
      sortable: PropTypes.bool,
      render_func: PropTypes.func

    } )
  )
}
export default ColumnMenu;
