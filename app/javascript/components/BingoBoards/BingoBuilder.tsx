import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import BingoBoard from "./BingoBoard";
import ConceptChips from "./ConceptChips";
import ScoredGameDataTable from "./ScoredGameDataTable";
import PropTypes from "prop-types";
import Link from "@mui/material/Link";
import Paper from "@mui/material/Paper";
import Tab from "@mui/material/Tab";
import Typography from "@mui/material/Typography";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import parse from "html-react-parser";
import { TabContext, TabList, TabPanel } from "@mui/lab";

export default function BingoBuilder(props) {
  const category = "candidate_results";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { bingoGameId } = useParams();
  const { t, i18n } = useTranslation( category );

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
      topic: t('no_game_msg')
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
    const tmpBoard = Object.assign({}, board);
    tmpBoard.bingo_cells = cells;
    tmpBoard.iteration = iteration;
    tmpBoard.initialised = true;
    setBoard(tmpBoard);
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
        return [{ id: -1, name: t('no_data_list_item' ) }];
      });
  };

  const getMyResults = () => {
    dispatch(startTask());
    const url =
      props.rootPath === undefined
        ? `${endpoints.baseUrl}${bingoGameId}.json`
        : `/${props.rootPath}${endpoints.baseUrl}${bingoGameId}.json`;
    console.log( url );
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        console.log( data.candidate_list );
        setCandidateList(data.candidate_list);
        setCandidates(data.candidates);
        //}, this.randomizeTiles );
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error");
        return [{ id: -1, name: t('no_data_list_item' ) }];
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
        return [{ id: -1, name: t('no_data_list_item' ) }];
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

  const saveBtn = [];
  if (null === board.bingo_game.end_date) {
    //no op
  } else if (new Date(board.bingo_game.end_date) < new Date()) {
    saveBtn.push(
      <em key='played_btn'>{t('already_played_msg')}</em>
    );
  } else if (
    board.initialised &&
    board.iteration > 0 &&
    new Date(board.bingo_game.end_date) > new Date()
  ) {
    saveBtn.push(
      <React.Fragment>
        <Link onClick={() => saveBoard()}>{t('save_lnk')}</Link> {t('gen_board_msg')}&hellip;
      </React.Fragment>
    );
  } else {
    saveBtn.push(
      <em key='save_btn'>{t('gen_and_save_msg')}</em>
    );
  }

  const printBtn =
    (board.id != null && board.iteration == 0) ||
    (null !== board.bingo_game.end_date &&
      new Date(board.bingo_game.end_date) < new Date()) ? (
      <React.Fragment>
        <Link onClick={() => getPrintableBoard()}>
          {t('download_board_lnk')}
        </Link>{" "}
        {t('play_msg')}
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
    <li>{t('not_enough_entries_msg')}</li>
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
    <li>{t('not_enough_entries_msg')}</li>
  );

  return (
    <Paper>
      <Typography>
        <strong>{t('topic_lbl')}:</strong> {board.bingo_game.topic}
      </Typography>
      <div>
        <strong>{t('description_lbl')}:</strong>{" "}
        <p>{parse(board.bingo_game.description || "")}</p>
      </div>
      {null != candidateList && (
        <Typography>
          <strong>{t('performance_lbl')}:</strong>
          <span id="performance">{candidateList.cached_performance}</span>
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
            {board.playable ? (
              <div id="bingoBoard" className="mt4">
                <BingoBoard board={board} />
              </div>
            ) : null}
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
