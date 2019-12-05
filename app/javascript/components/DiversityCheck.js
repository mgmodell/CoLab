import React from "react"
import PropTypes from "prop-types"
import Button from '@material-ui/core/Button';
import Table from '@material-ui/core/Table'
import TableHead from '@material-ui/core/TableHead'
import TableBody from '@material-ui/core/TableBody'
import TableCell from '@material-ui/core/TableCell'
import TableRow from '@material-ui/core/TableRow'
import TableSortLabel from '@material-ui/core/TableSortLabel'
import TextField from '@material-ui/core/TextField';

import get_i18n from './i18n';

import CompareIcon from '@material-ui/icons/Compare';

import Popup from "reactjs-popup";

const t = get_i18n( 'base' );

class DiversityCheck extends React.Component {

  constructor( props ){
    super( props );
    this.state = {
      emails: '',
      diversity_score: null,
      found_users: [ ]
    }
    this.handleChange = this.handleChange.bind( this );
    this.handleClear = this.handleClear.bind( this );
    this.calcDiversity = this.calcDiversity.bind( this );
  }
  calcDiversity( ){
    fetch( this.props.diversityScoreFor + '.json', {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        Accepts: 'application/json',
        'X-CSRF-Token': this.props.token
      },
      body: JSON.stringify({
        emails: this.state.emails
      })
    } )
      .then(response =>{
        if( response.ok ){
          return response.json( );
        } else {
          console.log( 'error' );
          return[{ id: -1, name: 'no data'}];
        }
      })
      .then(data => {
          this.setState({
            diversity_score: data.diversity_score,
            found_users: data.found_users
          })
      })

  }
  handleClear( event ){
          this.setState({
            emails: '',
            diversity_score: null,
            found_users: [],
          })
  }
  handleChange( event ){
    this.setState({
      emails: event.target.value

    })
  }

  render () {
    return (
      <Popup trigger={
        <Button variant='contained' size='small'>
          <CompareIcon />
          {t("calc_diversity")}
        </Button>
        } position='top left'>
        <div>
        <h1>{t('calc_it')}</h1>
        {t('ds_emails_lbl')}
        <TextField
          value={this.state.emails}
          onChange={()=>this.handleChange( event )} />
        <Button variant='contained' onClick={()=>this.calcDiversity( )}>
          {t('calc_diversity_sub')}
        </Button>
        <Button variant='contained' onClick={()=>this.handleClear( )}>
          Clear
        </Button>

        {this.state.found_users.length > 0 ? (
        <Table>
          <TableBody>
            <TableRow>
              <TableCell>
                {this.state.found_users.map( (user)=>{
                  return (
                    <a key={user.email} href={'mailto:' + user.email}>
                      {user.name}
                      <br/>
                    </a>
                  )
                } ) }
              </TableCell>
              <TableCell valign='middle' align='center'>
                {this.state.diversity_score}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table> )
        : null }

        </div>
      </Popup>
    );
  }
}

DiversityCheck.propTypes = {
  token: PropTypes.string.isRequired,
  diversityScoreFor: PropTypes.string.isRequired
};
export default DiversityCheck
