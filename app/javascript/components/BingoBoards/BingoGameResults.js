import React from "react";
import Draggable from "react-draggable";
import PropTypes from "prop-types";
import Button from "@mui/material/Button";
import Dialog from "@mui/material/Dialog";
import DialogActions from "@mui/material/DialogActions";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import DialogTitle from "@mui/material/DialogTitle";
import Paper from "@mui/material/Paper";
import Tabs from "@mui/material/Tabs";
import Tab from "@mui/material/Tab";
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import TableCell from "@mui/material/TableCell";
import TableRow from "@mui/material/TableRow";
import Typography from "@mui/material/Typography";

import ScoredGameDataTable from "../ScoredGameDataTable";

function PaperComponent(props) {
  return (
    <Draggable>
      <Paper {...props} />
    </Draggable>
  );
}

class BingoGameResults extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      curTab: "key"
    };
    this.changeTab = this.changeTab.bind(this);
  }

  renderBoard(board) {
    if (board == null || board.length == 0) {
      return <p>No board available</p>;
    } else {
      return (
        <React.Fragment>
          <Typography>
            <b>Score: </b>
            {null == this.props.score ? "unscored" : this.props.score}
            <br />
          </Typography>
          <Table>
            <TableBody>
              {this.props.board.map((row, r_ind) => (
                <TableRow key={r_ind}>
                  {row.map((col, c_ind) => (
                    <TableCell key={r_ind + "_" + c_ind}>{col}</TableCell>
                  ))}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </React.Fragment>
      );
    }
  }

  changeTab(event, name) {
    this.setState({
      curTab: name
    });
  }

  render() {
    return (
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
          <Tabs value={this.state.curTab} onChange={this.changeTab} centered>
            <Tab value="results" label="Scored Results" />
            <Tab value="key" label="Answer Key" />
          </Tabs>
          {"key" == this.state.curTab && this.renderBoard(this.props.board)}
          {"results" == this.state.curTab && (
            <ScoredGameDataTable candidates={this.props.candidates} />
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={this.props.close}>Done</Button>
        </DialogActions>
      </Dialog>
    );
  }
}

BingoGameResults.propTypes = {
  open: PropTypes.bool.isRequired,
  student: PropTypes.string,
  board: PropTypes.array,
  score: PropTypes.number,
  close: PropTypes.func,
  candidates: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      concept: PropTypes.string,
      definition: PropTypes.string,
      term: PropTypes.string,
      feedback: PropTypes.string,
      feedback_id: PropTypes.number
    })
  )
};

export default BingoGameResults;
