import React from 'react'
import Draggable from 'react-draggable'
import PropTypes from "prop-types";
import Button from '@material-ui/core/Button'
import Dialog from '@material-ui/core/Dialog'
import DialogActions from '@material-ui/core/DialogActions'
import DialogContent from '@material-ui/core/DialogContent'
import DialogContentText from '@material-ui/core/DialogContentText'
import DialogTitle from '@material-ui/core/DialogTitle'
import Paper from '@material-ui/core/Paper'
import Grid from '@material-ui/core/Grid'
import Table from '@material-ui/core/Table'
import TableBody from '@material-ui/core/TableBody'
import TableCell from '@material-ui/core/TableCell'
import TableRow from '@material-ui/core/TableRow'

function PaperComponent(props){
  return(
    <Draggable>
      <Paper {...props} />
    </Draggable>
  )
}

class BingoGameResults extends React.Component{
  constructor(props){
    super(props)
  }

  renderBoard( board ){
    if( board == null || board.length == 0){
      return (
        <p>No board available</p>
      )
    } else {
      return(
        <Table>
          <TableBody>
            {this.props.board.map((row, r_ind) => (
            <TableRow key={r_ind}>
              {row.map((col,c_ind) => (
                <TableCell key={r_ind + '_' + c_ind} >{col}</TableCell>
              ) ) }
            </TableRow>
            ) ) }
          </TableBody>
        </Table>
      )
    }
  }

  render(){
    return(
      <Dialog
        open={this.props.open}
        onClose={this.props.close}
        PaperComponent={PaperComponent}
        aria-labelledby="draggable-dialog-title"
      >
        <DialogTitle id="draggable-dialog-title">
          Results for {this.props.student}
        </DialogTitle>
        <DialogContent>
          <Grid container spacing={8}>
            <Grid item xs={5}>
              {this.renderBoard( this.props.board )}
            </Grid>
            <Grid item xs={5}>
              Candidates will go here
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={this.props.close}>
            Done
          </Button>

        </DialogActions>

      </Dialog>
    )
  }

}


BingoGameResults.propTypes = {
  open: PropTypes.bool.isRequired,
  student: PropTypes.string,
  board: PropTypes.array,
  close: PropTypes.func,
  candidates: PropTypes.arrayOf(
    PropTypes.shape( {
      concept: PropTypes.string,
      definition: PropTypes.string,
      term: PropTypes.string,
      feedback: PropTypes.string,
      feedback_id: PropTypes.number,
    } )
  )
}

export default BingoGameResults
