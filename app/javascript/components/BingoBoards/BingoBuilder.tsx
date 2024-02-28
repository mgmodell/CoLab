import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import BingoBoard from "./BingoBoard";
import ConceptChips from "./ConceptChips";
import ScoredGameDataTable from "./ScoredGameDataTable";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import parse from "html-react-parser";

import { Panel } from "primereact/panel";
import { TabView, TabPanel } from "primereact/tabview";

type Props = {
  rootPath?: string;
};

interface IBingoCell {
  id?: number;
  row: number;
  column: number;
  selected: boolean;
  concept_id: number;
  concept?: {
    id: number;
    name: string;
  };
};

interface IBingoGame {
  id?: number;
  topic: string;
  description?: string;
  size: number;
  end_date?: Date;
};

export interface IBingoBoard {
  initialised: boolean;
  bingo_cells: IBingoCell[];
  iteration: number;
  bingo_game: IBingoGame;
};

export default function BingoBuilder(props: Props) {
  const category = "candidate_results";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { bingoGameId } = useParams();
  const { t, i18n } = useTranslation(category);

  const dispatch = useDispatch();

  const [curTab, setCurTab] = useState(0);

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
      topic: t("no_game_msg")
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

  const prefix = props.rootPath === undefined ? "" : `/${props.rootPath}`;

  const getConcepts = () => {
    dispatch(startTask());

    const url = `${prefix}${endpoints.conceptsUrl}${bingoGameId}.json`;

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setConcepts(data);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error");
        return [{ id: -1, name: t("no_data_list_item") }];
      });
  };

  const getMyResults = () => {
    dispatch(startTask());
    const url = `${prefix}${endpoints.baseUrl}${bingoGameId}.json`;
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
        return [{ id: -1, name: t("no_data_list_item") }];
      });
  };
  const getBoard = () => {
    dispatch(startTask());
    const url = `${prefix}${endpoints.boardUrl}${bingoGameId}.json`;

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
        return [{ id: -1, name: t("no_data_list_item") }];
      });
  };

  const saveBoard = () => {
    dispatch(startTask("saving"));
    board.bingo_cells_attributes = board.bingo_cells;
    delete board.bingo_cells;
    const url = `${prefix}${endpoints.boardUrl}${bingoGameId}.json`;

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
    open(`${prefix}${endpoints.worksheetUrl}${bingoGameId}.pdf`);
  };
  const getPrintableBoard = () => {
    open(`${prefix}${endpoints.boardUrl}${bingoGameId}.pdf`);
  };

  const saveBtn = () => {
    if (null === board.bingo_game.end_date) {
      //no op
      return <></>;
    } else if (new Date(board.bingo_game.end_date) < new Date()) {
      return <em key="played_btn">{t("already_played_msg")}</em>;
    } else if (
      board.initialised &&
      board.iteration > 0 &&
      new Date(board.bingo_game.end_date) > new Date()
    ) {
      return (
        <React.Fragment>
          <a onClick={() => saveBoard()}>{t("save_lnk")}</a>{" "}
          {t("gen_board_msg")}&hellip;
        </React.Fragment>
      );
    } else {
      return <em key="save_btn">{t("gen_and_save_msg")}</em>;
    }
  };

  const printBtn =
    (board.id != null && board.iteration == 0) ||
      (null !== board.bingo_game.end_date &&
        new Date(board.bingo_game.end_date) < new Date()) ? (
      <React.Fragment>
        <a onClick={() => getPrintableBoard()}>{t("download_board_lnk")}</a>{" "}
        {t("play_msg")}
      </React.Fragment>
    ) : (
      "Save your board before this step"
    );

  const workSheetInstr = board.practicable ? (
    <li key={"practice"}>
      <a onClick={() => getWorksheet()}>
        {t('tabs.builder.print_step')}
      </a>
    </li>
  ) : (
    <li key={"practice"}>{t("not_enough_entries_msg")}</li>
  );

  const playableInstr = board.playable ? (
    <React.Fragment>
      <li key={"generate"}>
        <a onClick={() => randomizeTiles()}>{t('tabs.builder.regenerate')}</a>
      </li>
      <li key={"save_board"}>{saveBtn()}</li>
      <li key={"print_board"}>{printBtn}</li>
    </React.Fragment>
  ) : (
    <li>{t("not_enough_entries_msg")}</li>
  );

  return (
    <Panel>
      <h3>{t("topic_lbl")}:</h3> {board.bingo_game.topic}
      <div>
        <h3>{t("description_lbl")}:</h3>{" "}
        <p>{parse(board.bingo_game.description || "")}</p>
      </div>
      <hr />
      <TabView activeIndex={curTab} onTabChange={e => setCurTab(e.index)}>
        <TabPanel header={t('tabs.builder.builder_lbl')} >
          <Panel>
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
            <h3>{t('tabs.builder.words_found')}</h3>
            <hr></hr>
            <ConceptChips concepts={concepts} />
          </Panel>
        </TabPanel>
        <TabPanel header={t('tabs.performance')}>
          <Panel>
            {null != candidateList && (
              <>
                <h3>{t("performance_lbl")}:</h3>
                <span id="performance">{candidateList.cached_performance} / 100</span>
              </>
            )}
            <ScoredGameDataTable
              candidates={candidates}
            />
          </Panel>
        </TabPanel>
        <TabPanel
          header={t('tabs.worksheet')}
          disabled={
            !board.practicable ||
            null == board.worksheet ||
            (null == board.worksheet.performance &&
              null == board.worksheet.result_img)
          }
        >
          {null != board.worksheet ? (
            <Panel>
              <p>
                <strong>Score:</strong>&nbsp;
                {board.worksheet.performance || 0}
                <br />
              </p>
              {null != board.worksheet.result_img &&
                "" != board.worksheet.result_img ? (
                <img src={board.worksheet.result_img} />
              ) : null}
            </Panel>
          ) : (
            t("no_worksheet_msg")
          )}
        </TabPanel>
      </TabView>
    </Panel>
  );
}
