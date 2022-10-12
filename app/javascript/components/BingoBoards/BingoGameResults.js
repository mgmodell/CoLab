import React, {useState} from "react";
import Draggable from "react-draggable";
import PropTypes from "prop-types";
import Button from "@mui/material/Button";
import Dialog from "@mui/material/Dialog";
import DialogActions from "@mui/material/DialogActions";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import DialogTitle from "@mui/material/DialogTitle";
import Paper from "@mui/material/Paper";
import Tab from "@mui/material/Tab";
import {
  TabList,
  TabContext,
  TabPanel
} from '@mui/lab';
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import TableCell from "@mui/material/TableCell";
import TableRow from "@mui/material/TableRow";
import Typography from "@mui/material/Typography";

import ScoredGameDataTable from "../ScoredGameDataTable";
import { Box } from "@mui/material";

function PaperComponent(props) {
  return (
    <Draggable>
      <Paper {...props} />
    </Draggable>
  );
}

export default function BingoGameResults (props){

  const [curTab, setCurTab] = useState( 'key' );

  const renderBoard = (board) => {
    if (board == null || board.length == 0) {
      return <p>No board available</p>;
    } else {
      return (
        <React.Fragment>
          <Typography>
            <b>Score: </b>
            {null == props.score ? "unscored" : props.score}
            <br />
          </Typography>
          <Table>
            <TableBody>
              {props.board.map((row, r_ind) => (
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


    return (
      <Dialog
        open={props.open}
        onClose={props.close}
        PaperComponent={PaperComponent}
        aria-labelledby="draggable-dialog-title"
      >
        <DialogTitle id="draggable-dialog-title">
          Results for {props.student}
        </DialogTitle>
        <DialogContent>
          <TabContext value={curTab}>
            <Box>
              <TabList value={curTab} onChange={setCurTab} centered>
                <Tab value="results" label="Scored Results" />
                <Tab value="key" label="Answer Key" />
              </TabList>

            </Box>
            <TabPanel value='key'>
              {renderBoard(props.board)}
            </TabPanel>
            <TabPanel value='results'>
              <ScoredGameDataTable candidates={props.candidates} />
            </TabPanel>
          </TabContext>
        </DialogContent>
        <DialogActions>
          <Button onClick={props.close}>Done</Button>
        </DialogActions>
      </Dialog>
    );
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

