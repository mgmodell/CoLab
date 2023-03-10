import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import BingoBoard from "./BingoBoard";
import ConceptChips from "../ConceptChips";
import ScoredGameDataTable from "../ScoredGameDataTable";
import PropTypes from "prop-types";
import Link from "@mui/material/Link";
import Paper from "@mui/material/Paper";
import Tab from "@mui/material/Tab";
import Typography from "@mui/material/Typography";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { TabContext, TabList, TabPanel } from "@mui/lab";

export default function BingoBuilder(props) {
  const endpointSet = "candidate_results";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { bingoGameId } = useParams();
  const { t, i18n } = useTranslation();

  const dispatch = useDispatch();

  const [curTab, setCurTab] = useState("builder");

  const [saveStatus, setSaveStatus] = useState("");

  const [concepts, setConcepts] = useState([]);
  const [candidateList, setCandidateList] = useState();
  const [candidates, setCandidates] = useState([]);
  const [board, setBoard] = useState({
    initialised: false,
    bingo_cells: [],
    iteration: 0,
    bingo_game: {
      size: 5,
      topic: "no game"
    }
  });

  useEffect(() => {
    if (endpointStatus) {
      getConcepts();
      getMyResults();
      getBoard();
    }
  }, [endpointStatus]);

  const randomizeTiles = () => {
    var selectedConcepts = {};
    var iteration = board.iteration + 1;
    var counter = 0;
    while (
      Object.keys(selectedConcepts).length < board.bingo_cells.length &&
      counter < 100
    ) {
      counter++;
      var sample = concepts[Math.floor(Math.random() * concepts.length)];

      selectedConcepts[sample.id] = sample;
    }
    //Repurpose localConcepts
    var localConcepts = Object.values(selectedConcepts);
    var size = board.bingo_game.size;
    var cells = board.bingo_cells;
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        var i = row * 5 + col;
        var concept = localConcepts[i];

        var mid = Math.round(size / 2) - 1;
        var midSquare = row == mid && col == mid && mid != size / 2;

        concept = midSquare ? { id: 0, name: "*" } : concept;

        cells[i].row = row;
        cells[i].column = col;
        cells[i].selected = midSquare ? true : false;
        cells[i].concept_id = concept.id;
        cells[i].concept = concept;
      }
    }
    board.bingo_cells = cells;
    board.iteration = iteration;
    board.initialised = true;
    setBoard(board);
  };

  const getConcepts = () => {
    dispatch(startTask());

    const url =
      props.rootPath === undefined
        ? `${endpoints.conceptsUrl}${bingoGameId}.json`
        : `/${props.rootPath}${endpoints.conceptsUrl}${bingoGameId}.json`;

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setConcepts(data);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error");
        return [{ id: -1, name: "no data" }];
      });
  };

  const getMyResults = () => {
    dispatch(startTask());
    const url =
      props.rootPath === undefined
        ? `${endpoints.baseUrl}${bingoGameId}.json`
        : `/${props.rootPath}${endpoints.baseUrl}${bingoGameId}.json`;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setCandidateList(data.candidate_list);
        setCandidates(data.candidates);
        //}, this.randomizeTiles );
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error");
        return [{ id: -1, name: "no data" }];
      });
  };
  const getBoard = () => {
    dispatch(startTask());
    const url =
      props.rootPath === undefined
        ? `${endpoints.boardUrl}${bingoGameId}.json`
        : `/${props.rootPath}${endpoints.boardUrl}${bingoGameId}.json`;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        data.initialised = data.id != null;
        data.iteration = 0;
        setBoard(data);
        //}, this.randomizeTiles );
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error");
        return [{ id: -1, name: "no data" }];
      });
  };

  const saveBoard = () => {
    dispatch(startTask("saving"));
    board.bingo_cells_attributes = board.bingo_cells;
    delete board.bingo_cells;
    const url = `${endpoints.boardUrl}${bingoGameId}.json`;
    axios
      .patch(url, {
        bingo_board: board
      })
      .then(response => {
        const data = response.data;
        data.initialised = true;
        data.iteration = 0;
        if (data.id > 0) {
          setSaveStatus("Your board has been saved");
          setBoard(data);
        } else if ((data.id = -42)) {
          board.bingo_cells = board.bingo_cells_attributes;
          board.id = -42;
          board.iteration = 0;
          setSaveStatus("DEMO: Your board would have been saved");
          setBoard(board);
        } else {
          board.bingo_cells = board.bingo_cells_attributes;
          setSaveStatus("Save failed. Please try again or contact support");
          setBoard(board);
        }
        dispatch(endTask("saving"));
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  const getWorksheet = () => {
    open(`${endpoints.worksheetUrl}${bingoGameId}.pdf`);
  };
  const getPrintableBoard = () => {
    open(`${endpoints.boardUrl}${bingoGameId}.pdf`);
  };

  //This nested ternary operator is ugly, but it works. At some point
  // I need to figure out the right way to do it.
  const saveBtn =
    null !== board.bingo_game.end_date &&
    new Date(board.bingo_game.end_date) < new Date() ? (
      <em>
        This game has already been played, so you cannot save a new board.
      </em>
    ) : board.initialised &&
      board.iteration > 0 &&
      null !== board.bingo_game.end_date &&
      new Date(board.bingo_game.endDate) > new Date() ? (
      <React.Fragment>
        <Link onClick={() => saveBoard()}>Save</Link> the board you
        generated&hellip;
      </React.Fragment>
    ) : (
      <em>If you generate a new board, you will be able to save it here.</em>
    );

  const printBtn =
    (board.id != null && board.iteration == 0) ||
    (null !== board.bingo_game.end_date &&
      new Date(board.bingo_game.end_date) < new Date()) ? (
      <React.Fragment>
        <Link onClick={() => getPrintableBoard()}>
          Download your Bingo Board
        </Link>{" "}
        and play along in class!
      </React.Fragment>
    ) : (
      "Save your board before this step"
    );

  const workSheetInstr = board.practicable ? (
    <li>
      Print and complete this&nbsp;
      <Link onClick={() => getWorksheet()}>Practice Bingo Board</Link> then turn
      it in before class begins.
    </li>
  ) : (
    <li>
      Not enough usable entries for a practice sheet. Encourage your classmates
      to complete their assignments.
    </li>
  );

  const playableInstr = board.playable ? (
    <React.Fragment>
      <li>
        <Link onClick={() => randomizeTiles()}>
          (Re)Generate your playable board
        </Link>{" "}
        until you get one you like and then&hellip;
      </li>
      <li>{saveBtn}</li>
      <li>{printBtn}</li>
    </React.Fragment>
  ) : (
    <li>
      Not enough usable entries to generate a playble Bingo board &mdash;
      encourage your classmates to complete their assignments.
    </li>
  );

  const builder = board.playable ? (
    <div id="bingoBoard" className="mt4">
      <BingoBoard board={board} />
    </div>
  ) : null;

  return (
    <Paper>
      <Typography>
        <strong>Topic:</strong> {board.bingo_game.topic}
      </Typography>
      <div>
        <strong>Description:</strong>{" "}
        <p
          dangerouslySetInnerHTML={{
            __html: board.bingo_game.description
          }}
        />
      </div>
      {null != candidateList && (
        <Typography>
          <strong>Performance:</strong>
          <span id="performance">{candidateList.performance}</span>
        </Typography>
      )}
      <hr />
      <TabContext value={curTab}>
        <TabList
          value={curTab}
          onChange={(event, value) => setCurTab(value)}
          centered
        >
          <Tab value="builder" label="Bingo game builder" />
          <Tab value="results" label="Your performance" />
          <Tab
            value="worksheet"
            label="Worksheet result"
            disabled={
              !board.practicable ||
              null == board.worksheet ||
              (null == board.worksheet.performance &&
                null == board.worksheet.result_img)
            }
          />
          <Tab value="concepts" label="Concepts found by class" />
        </TabList>
        <TabPanel value="worksheet">
          {null != board.worksheet ? (
            <Paper square={false}>
              <Typography>
                <strong>Score:</strong>&nbsp;
                {board.worksheet.performance || 0}
                <br />
              </Typography>
              {null != board.worksheet.result_img &&
              "" != board.worksheet.result_img ? (
                <img src={board.worksheet.result_img} />
              ) : null}
            </Paper>
          ) : (
            "No Worksheet"
          )}
        </TabPanel>
        <TabPanel value="builder">
          <Paper square={false}>
            <br />
            <ol>
              {workSheetInstr}
              {playableInstr}
            </ol>
            {builder}
          </Paper>
        </TabPanel>
        <TabPanel value="results">
          <ScoredGameDataTable candidates={candidates} />
        </TabPanel>
        <TabPanel value="concepts">
          <ConceptChips concepts={concepts} />
        </TabPanel>
      </TabContext>
    </Paper>
  );
}
BingoBuilder.propTypes = {
  rootPath: PropTypes.string
};
