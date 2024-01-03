import React, { useState } from "react";
import Draggable from "react-draggable";

import Button from "@mui/material/Button";
import Dialog from "@mui/material/Dialog";
import DialogActions from "@mui/material/DialogActions";
import DialogContent from "@mui/material/DialogContent";
import DialogTitle from "@mui/material/DialogTitle";
import Paper from "@mui/material/Paper";
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import TableCell from "@mui/material/TableCell";
import TableRow from "@mui/material/TableRow";
import Typography from "@mui/material/Typography";
import { TabView, TabPanel } from "primereact/tabview";

const ScoredGameDataTable = React.lazy(() => import("./ScoredGameDataTable"));

type Candidate = {
  id: number;
  concept: string;
  definition: string;
  term: string;
  feedback: string;
  feedback_id: number;
};

type Props = {
  open: boolean;
  student: string;
  board: Array<Array<string>>;
  score: number;
  close: Function;
  candidates: Array<Candidate>;
};

function PaperComponent(props) {
  return (
    <Draggable>
      <Paper {...props} />
    </Draggable>
  );
}

export default function BingoGameResults(props : Props) {
  const [curTab, setCurTab] = useState(0);

  const renderBoard = board => {
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
  };

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
        <TabView activeIndex={curTab} onTabChange={setCurTab}>
          <TabPanel header={"Scored Results"}>
            {renderBoard(props.board)}
          </TabPanel>
          <TabPanel header={'Answer Key'}>
            <ScoredGameDataTable candidates={props.candidates} />
          </TabPanel>
        </TabView>
      </DialogContent>
      <DialogActions>
        <Button onClick={props.close}>Done</Button>
      </DialogActions>
    </Dialog>
  );
}
