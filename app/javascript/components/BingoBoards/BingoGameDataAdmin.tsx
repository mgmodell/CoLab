import React, { Suspense, useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useDispatch } from "react-redux";

import { Skeleton } from "primereact/skeleton";
import { TabView, TabPanel } from "primereact/tabview";
import { Panel } from "primereact/panel";
import { Button } from "primereact/button";

import { useTranslation } from "react-i18next";

import ConceptChips from "./ConceptChips";
const BingoGameDataAdminTable = React.lazy(() =>
  import("./BingoGameDataAdminTable")
);

import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { Editor } from "primereact/editor";
import EditorToolbar from "../infrastructure/EditorToolbar";
import { Calendar } from "primereact/calendar";
import { Dropdown } from "primereact/dropdown";
import { InputSwitch } from "primereact/inputswitch";
import { InputText } from "primereact/inputtext";
import { InputNumber } from "primereact/inputnumber";
import { Container, Row, Col } from "react-grid-system";
import { C } from "@fullcalendar/core/internal-common";

export default function BingoGameDataAdmin(props) {

  const endpointSet = "bingo_game";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);
  const { courseIdParam, bingoGameIdParam } = useParams();
  const dispatch = useDispatch();

  const navigate = useNavigate();

  const { t, i18n } = useTranslation("bingo_games");

  const [dirty, setDirty] = useState(false);
  const [curTab, setCurTab] = useState(0);
  const [messages, setMessages] = useState({});
  const [gameProjects, setGameProjects] = useState([
    { id: -1, name: "None Selected" }
  ]);
  const [concepts, setConcepts] = useState([]);
  const [saveStatus, setSaveStatus] = useState("");
  const [resultData, setResultData] = useState(null);
  const [gameTopic, setGameTopic] = useState("");
  const [gameDescriptionEditor, setGameDescriptionEditor] = useState("");
  const [bingoGameId, setBingoGameId] = useState(
    "new" === bingoGameIdParam ? null : bingoGameIdParam
  );
  const [gameSource, setGameSource] = useState("");
  const [gameTimezone, setGameTimezone] = useState("UTC");
  const [gameActive, setGameActive] = useState(false);

  const now = new Date();
  const [gameStartDate, setGameStartDate] = useState(now);
  const [gameEndDate, setGameEndDate] = useState(
    () => {
      now.setMonth(now.getMonth() + 3);
      return now;
    }
  );
  const [gameIndividualCount, setGameIndividualCount] = useState(0);
  const [gameLeadTime, setGameLeadTime] = useState(0);
  //Group parameters
  const [gameGroupOption, setGameGroupOption] = useState(false);
  const [gameGroupDiscount, setGameGroupDiscount] = useState(0);
  const [gameGroupProjectId, setGameGroupProjectId] = useState(-1);

  useEffect(() => {
    if (endpointStatus) {
      getBingoGameData();
      initResultData();
    }
  }, [endpointStatus]);

  useEffect(() => {
    setDirty(true);
  }, [
    gameTopic,
    gameDescriptionEditor,
    gameSource,
    gameTimezone,
    gameActive,
    gameStartDate,
    gameEndDate,
    gameIndividualCount,
    gameLeadTime,
    gameGroupOption,
    gameGroupDiscount,
    gameGroupProjectId
  ]);

  const saveBingoGame = () => {
    const method = null === bingoGameId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null === bingoGameId ? courseIdParam : bingoGameId) +
      ".json";

    // Save
    setSaveStatus(t("save_status"));
    axios({
      url: url,
      method: method,
      data: {
        bingo_game: {
          course_id: courseIdParam,
          topic: gameTopic,
          description: gameDescriptionEditor,
          source: gameSource,
          active: gameActive,
          start_date: gameStartDate,
          end_date: gameEndDate,
          individual_count: gameIndividualCount,
          lead_time: gameLeadTime,
          group_option: gameGroupOption,
          group_discount: gameGroupDiscount,
          project_id: gameGroupProjectId
        }
      }
    })
      .then(response => {
        const data = response.data;
        //TODO: handle save errors
        setSaveStatus(data["notice"]);
        setDirty(false);
        setMessages(data["messages"]);

        getBingoGameData();
        navigate(`../${courseIdParam}/bingo_game/${bingoGameId}`, { replace: true });
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask("saving"));
      });
  };

  const initResultData = () => {
    if (bingoGameId > 0) {
      dispatch(startTask());
      const url = endpoints.gameResultsUrl + "/" + bingoGameId + ".json";
      axios
        .get(url, {})
        .then(response => {
          const data = response.data;
          setResultData(data);
          dispatch(endTask());
        })
        .catch(error => {
          console.log("error", error);
        });
    }
  };

  const getBingoGameData = () => {
    setDirty(true);
    dispatch(startTask());
    var url = endpoints.baseUrl + "/";
    if (null === bingoGameId) {
      url = url + "new/" + courseIdParam + ".json";
    } else {
      url = url + bingoGameId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const projects = new Array({ id: -1, name: "None Selected" }).concat(
          data.projects
        );

        setGameProjects(projects);
        setConcepts(data.concepts);

        //Set the bingo_game stuff
        const bingo_game = data.bingo_game;
        setBingoGameId(bingo_game.id);
        setGameTopic(bingo_game.topic || "");
        setGameDescriptionEditor(bingo_game.description || "");
        setGameSource(bingo_game.source || "");
        setGameActive(bingo_game.active || false);

        var receivedDate = new Date(Date.parse(bingo_game.start_date));
        setGameStartDate(receivedDate);
        receivedDate = new Date(Date.parse(bingo_game.end_date));
        setGameEndDate(receivedDate);

        setGameIndividualCount(bingo_game.individual_count || 0);
        setGameLeadTime(bingo_game.lead_time || 0);
        //Group options
        setGameGroupOption(bingo_game.group_option || false);
        setGameGroupDiscount(bingo_game.group_discount || 0);
        setGameGroupProjectId(bingo_game.project_id);
        setDirty(false);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
      });
  };

  const changeTab = (event, name) => {
    setCurTab(name);
  };

  const save_btn = dirty ? (
    <Suspense fallback={<Skeleton className="mb-2" />}>
      <Button
        color="primary"
        //className={classes["button"]}
        onClick={saveBingoGame}
        id="save_bingo_game"
        value="save_bingo_game"
      >
        {null == bingoGameId ? t("create_bingo_btn") : t("update_bingo_btn")}
      </Button>
    </Suspense>
  ) : null;

  const group_options = gameGroupOption ? (
    <Suspense fallback={<Skeleton className="mb-2" />}>
      <React.Fragment>
        <Col xs={6}>
          <span className="p-float-label">
            <InputNumber
              id="bingo-name"
              itemID="bingo-name"
              name="bingo-name"
              value={gameGroupDiscount}
              onChange={event => {
                setGameGroupDiscount(event.value);
              }}
            />
            <label htmlFor="bingo-name">{t("group_discount")}</label>
          </span>
        </Col>
        <Col xs={6}>
          <span className="p-float-label">
            <Dropdown
              id="bingo_game_project_id"
              inputId="bingo_game_project_id"
              itemID="bingo_game_project_id"
              value={gameGroupProjectId}
              options={gameProjects}
              optionValue="id"
              onChange={event => setGameGroupProjectId(event.value)}
              optionLabel="name"
              placeholder={t("group_source")}
            />
            <label htmlFor="bingo_game_project_id">{t("group_source")}</label>
          </span>
        </Col>
      </React.Fragment>
    </Suspense>
  ) : null;
  return (
    <Suspense fallback={<Skeleton className="mb-2" />}>
      <Panel style={{ height: "95%", width: "100%" }}>
        <TabView
          activeIndex={curTab}
          onTabChange={event => setCurTab(event.index)}
        >
          <TabPanel header={t("game_details_pnl")}>
            <Container>
              <Row>
                <Col xs={12}>
                  <span className="p-float-label">
                    <InputText
                      id='topic'
                      name="topic"
                      itemID="topic"
                      value={gameTopic}
                      onChange={event => setGameTopic(event.target.value)}
                    />
                    <label htmlFor="topic">{t("topic")}</label>
                  </span>

                </Col>
              </Row>
              <Row>
                <Col xs={12}>
                  <Editor
                    id="description"
                    aria-label={t("description")}
                    placeholder={t("description")}
                    value={gameDescriptionEditor}
                    headerTemplate={<EditorToolbar />}
                    onTextChange={event => {
                      setGameDescriptionEditor(event.htmlValue);
                    }}
                  />
                </Col>
              </Row>
              <Row>
                <Col xs={6}>
                  <span className="p-float-label">
                    <InputNumber
                      id='bingo-lead-time'
                      name="bingo-lead-time"
                      itemID="bingo-lead-time"
                      value={gameLeadTime}
                      onChange={event => setGameLeadTime(event.value)}
                    />
                    <label htmlFor="bingo-lead-time">{t("lead_time")}</label>
                  </span>

                </Col>
                <Col xs={6}>
                  <span className="p-float-label">
                    <InputNumber
                      id='bingo-individual_count'
                      name="bingo-individual_count"
                      itemID="bingo-individual_count"
                      value={gameIndividualCount}
                      onChange={event => setGameIndividualCount(event.value)}
                    />
                    <label htmlFor="bingo-individual_count">{t("ind_term_count")}</label>
                  </span>
                </Col>
              </Row>

              <Row>
                <Col xs={4}>
                  <span className="p-float-label">
                    <Calendar
                      id='bingo_game_dates'
                      value={[gameStartDate, gameEndDate]}
                      onChange={(event) => {
                        const changeTo = event.value;
                        if (null !== changeTo && changeTo.length > 1) {
                          setGameStartDate(changeTo[0]);
                          setGameEndDate(changeTo[1]);
                        }
                      }}
                      selectionMode="range"
                      showIcon={true}
                      inputId="bingo_game_dates"
                      name="bingo_game_dates"
                    />
                    <label htmlFor="bingo_game_dates">{t("game_dates")}</label>
                  </span>
                </Col>
                <Col xs={4}>
                  <InputSwitch
                    checked={gameActive}
                    onChange={event => setGameActive(!gameActive)}
                    id='active'
                    name='active'
                    itemID="active"
                  />
                  <label htmlFor="active">{t("active")}</label>
                </Col>
                <Col xs={12}>
                  <InputSwitch
                    checked={gameGroupOption}
                    id="group_option"
                    name="group_option"
                    itemID="group_option"
                    onChange={event => setGameGroupOption(!gameGroupOption)}
                    disabled={null == gameProjects || 2 > gameProjects.length}
                  />
                  <label htmlFor="group_option">{t("group_option")}</label>
                </Col>
                {group_options}

              </Row>
              <Row>
                <Col xs={12}>


                  {save_btn} {messages.status}
                  <span>{saveStatus}</span>
                </Col>

              </Row>

            </Container>
          </TabPanel>
          <TabPanel header={t("response_pnl")}>
            <Container>
              <Row>
                <Col xs={5}>
                  <ConceptChips concepts={concepts} />
                </Col>
                <Col xs={7}>
                  <BingoGameDataAdminTable results_raw={resultData} />
                </Col>

              </Row>

            </Container>
          </TabPanel>
        </TabView>
      </Panel>
    </Suspense>
  );
}
