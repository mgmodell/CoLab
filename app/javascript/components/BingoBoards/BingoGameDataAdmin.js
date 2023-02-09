import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import Paper from "@mui/material/Paper";
import Box from "@mui/material/Box";
import TextField from "@mui/material/TextField";
import Button from "@mui/material/Button";
import Grid from "@mui/material/Grid";
import FormControl from "@mui/material/FormControl";
import MenuItem from "@mui/material/MenuItem";
import Select from "@mui/material/Select";
import Tab from "@mui/material/Tab";
import Typography from "@mui/material/Typography";
import InputLabel from "@mui/material/InputLabel";
import FormControlLabel from "@mui/material/FormControlLabel";
import Switch from "@mui/material/Switch";

import Skeleton from "@mui/material/Skeleton";

import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";
import { TabContext, TabList, TabPanel } from "@mui/lab/";

import { DateTime } from "luxon";
import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";

import { EditorState, convertToRaw, ContentState } from "draft-js";
const Editor = React.lazy(() => import("./reactDraftWysiwygEditor"));

import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";

import { useTranslation } from "react-i18next";

import makeStyles from "@mui/styles/makeStyles";

import ConceptChips from "../ConceptChips";
const BingoGameDataAdminTable = React.lazy(() =>
  import("./BingoGameDataAdminTable")
);

import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";

const useStyles = makeStyles({
  container: {
    display: "flex",
    flexWrap: "wrap"
  },
  textField: {
    width: 200
  },
  dense: {
    marginTop: 19
  },
  menu: {
    width: 200
  }
});

export default function BingoGameDataAdmin(props) {
  const classes = useStyles();

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

  const { t, i18n } = useTranslation("bingo_games");

  const [dirty, setDirty] = useState(false);
  const [curTab, setCurTab] = useState("details");
  const [messages, setMessages] = useState({});
  const [gameProjects, setGameProjects] = useState([
    { id: -1, name: "None Selected" }
  ]);
  const [concepts, setConcepts] = useState([]);
  const [saveStatus, setSaveStatus] = useState("");
  const [resultData, setResultData] = useState(null);
  const [gameTopic, setGameTopic] = useState("");
  const [gameDescriptionEditor, setGameDescriptionEditor] = useState(
    EditorState.createWithContent(
      ContentState.createFromBlockArray(htmlToDraft("").contentBlocks)
    )
  );
  const [bingoGameId, setBingoGameId] = useState(
    "new" === bingoGameIdParam ? null : bingoGameIdParam
  );
  const [gameSource, setGameSource] = useState("");
  const [gameTimezone, setGameTimezone] = useState("UTC");
  const [gameActive, setGameActive] = useState(false);
  const [gameEndDate, setGameEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
      .toJSDate()
  );
  const [gameStartDate, setGameStartDate] = useState(
    DateTime.local().toJSDate()
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
          description: draftToHtml(
            convertToRaw(gameDescriptionEditor.getCurrentContent())
          ),
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
        dispatch(endTask("saving"));

        getBingoGameData();
      })
      .catch(error => {
        console.log("error", error);
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
        setGameDescriptionEditor(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft(bingo_game.description || "").contentBlocks
            )
          )
        );
        setGameSource(bingo_game.source || "");
        setGameActive(bingo_game.active || false);
        var receivedDate = DateTime.fromISO(bingo_game.start_date).setZone(
          bingo_game.course.timezone
        );
        setGameStartDate(receivedDate.toISO());
        setGameEndDate(
          DateTime.fromISO(bingo_game.end_date)
            .setZone(bingo_game.course.timezone)
            .toISO()
        );
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
    <Suspense fallback={<Skeleton variant="text" />}>
      <Button
        variant="contained"
        color="primary"
        className={classes["button"]}
        onClick={saveBingoGame}
        id="save_bingo_game"
        value="save_bingo_game"
      >
        {null == bingoGameId ? t("create_bingo_btn") : t("update_bingo_btn")}
      </Button>
    </Suspense>
  ) : null;

  const group_options = gameGroupOption ? (
    <Suspense fallback={<Skeleton variant="text" />}>
      <React.Fragment>
        <Grid item xs={6}>
          <TextField
            id="bingo-name"
            label={t("group_discount")}
            type="number"
            className={classes.textField}
            value={gameGroupDiscount}
            onChange={event =>
              setGameGroupDiscount(parseInt(event.target.value))
            }
            margin="normal"
            error={null != messages["name"]}
            helper={messages["name"]}
          />
        </Grid>
        <Grid item xs={6}>
          <FormControl className={classes.formControl}>
            <InputLabel shrink htmlFor="bingo_game_project_id">
              {t("group_source")}
            </InputLabel>
            <Select
              id="bingo_game_project_id"
              value={gameGroupProjectId}
              onChange={event => setGameGroupProjectId(event.target.value)}
              displayEmpty
              name="bingo_game_project"
              className={classes.selectEmpty}
            >
              {gameProjects.map(project => {
                return (
                  <MenuItem value={project.id} key={project.id}>
                    {project.name}
                  </MenuItem>
                );
              })}
            </Select>
          </FormControl>
        </Grid>
      </React.Fragment>
    </Suspense>
  ) : null;
  return (
    <Suspense fallback={<Skeleton variant="text" />}>
      <Paper style={{ height: "95%", width: "100%" }}>
        <TabContext value={curTab}>
          <Box>
            <TabList value={curTab} onChange={changeTab} centered>
              <Tab value="details" label={t("game_details_pnl")} />
              <Tab value="results" label={t("response_pnl")} />
            </TabList>
          </Box>
          <TabPanel value="details">
            <React.Fragment>
              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <TextField
                    id="topic"
                    label={t("topic")}
                    className={classes.textField}
                    value={gameTopic}
                    fullWidth
                    onChange={event => setGameTopic(event.target.value)}
                    margin="normal"
                  />
                </Grid>
                <Grid item xs={12}>
                  <Editor
                    wrapperId="Description"
                    label={t("description")}
                    placeholder={t("description")}
                    onEditorStateChange={setGameDescriptionEditor}
                    toolbarOnFocus
                    toolbar={{
                      options: [
                        "inline",
                        "list",
                        "link",
                        "blockType",
                        "fontSize",
                        "fontFamily"
                      ],
                      inline: {
                        options: [
                          "bold",
                          "italic",
                          "underline",
                          "strikethrough",
                          "monospace"
                        ],
                        bold: { className: "bordered-option-classname" },
                        italic: { className: "bordered-option-classname" },
                        underline: { className: "bordered-option-classname" },
                        strikethrough: {
                          className: "bordered-option-classname"
                        },
                        code: { className: "bordered-option-classname" }
                      },
                      blockType: {
                        className: "bordered-option-classname"
                      },
                      fontSize: {
                        className: "bordered-option-classname"
                      },
                      fontFamily: {
                        className: "bordered-option-classname"
                      }
                    }}
                    editorState={gameDescriptionEditor}
                  />
                </Grid>
                <Grid item xs={6}>
                  <TextField
                    id="bingo-lead-time"
                    label={t("lead_time")}
                    className={classes.lead_time}
                    value={gameLeadTime}
                    type="number"
                    onChange={event => setGameLeadTime(event.target.value)}
                    InputLabelProps={{
                      shrink: true
                    }}
                    margin="normal"
                  />
                </Grid>
                <Grid item xs={6}>
                  <TextField
                    id="bingo-individual_count"
                    label={t("ind_term_count")}
                    className={classes.textField}
                    value={gameIndividualCount}
                    type="number"
                    onChange={event =>
                      setGameIndividualCount(event.target.value)
                    }
                    InputLabelProps={{
                      shrink: true
                    }}
                    margin="normal"
                    error={null != messages.individual_count}
                    helperText={messages.individual_count}
                  />
                </Grid>
                <LocalizationProvider dateAdapter={AdapterLuxon}>
                  <Grid item xs={4}>
                    <DatePicker
                      variant="inline"
                      autoOk={true}
                      inputFormat="MM/dd/yyyy"
                      margin="normal"
                      label={t("open_date")}
                      value={gameStartDate}
                      onChange={setGameStartDate}
                      renderInput={props => (
                        <TextField id="bingo_game_start_date" {...props} />
                      )}
                    />
                    {null != messages.start_date ? (
                      <FormHelperText error={true}>
                        {messages.start_date}
                      </FormHelperText>
                    ) : null}
                  </Grid>
                  <Grid item xs={4}>
                    <DatePicker
                      variant="inline"
                      autoOk={true}
                      inputFormat="MM/dd/yyyy"
                      margin="normal"
                      label={t("close_date")}
                      value={gameEndDate}
                      onChange={setGameEndDate}
                      renderInput={props => (
                        <TextField id="bingo_game_end_date" {...props} />
                      )}
                    />
                    {null != messages.end_date ? (
                      <FormHelperText error={true}>
                        {messages.end_date}
                      </FormHelperText>
                    ) : null}
                  </Grid>
                </LocalizationProvider>
                <Grid item xs={4}>
                  <FormControlLabel
                    control={
                      <Switch
                        checked={gameActive}
                        onChange={event => setGameActive(!gameActive)}
                      />
                    }
                    label={t("active")}
                  />
                </Grid>
                <Grid item xs={12}>
                  <Switch
                    checked={gameGroupOption}
                    id="group_option"
                    onChange={event => setGameGroupOption(!gameGroupOption)}
                    disabled={null == gameProjects || 2 > gameProjects.length}
                  />
                  <InputLabel htmlFor="group_option">
                    {t("group_option")}
                  </InputLabel>
                </Grid>
                {group_options}
              </Grid>
              {save_btn} {messages.status}
              <Typography>{saveStatus}</Typography>
            </React.Fragment>
          </TabPanel>
          <TabPanel value="results">
            <Grid container style={{ height: "100%" }}>
              <Grid item xs={5}>
                <ConceptChips concepts={concepts} />
              </Grid>
              <Grid item xs={7}>
                <BingoGameDataAdminTable results_raw={resultData} />
              </Grid>
            </Grid>
          </TabPanel>
        </TabContext>
      </Paper>
    </Suspense>
  );
}

BingoGameDataAdmin.propTypes = {};
