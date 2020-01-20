import React, { Suspense, useState, useEffect } from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import Paper from "@material-ui/core/Paper";
import TextField from "@material-ui/core/TextField";
import Button from "@material-ui/core/Button";
import Grid from "@material-ui/core/Grid";
import FormControl from "@material-ui/core/FormControl";
import MenuItem from "@material-ui/core/MenuItem";
import Select from "@material-ui/core/Select";
import Input from "@material-ui/core/Input";
import Tabs from "@material-ui/core/Tabs";
import Tab from "@material-ui/core/Tab";
import Typography from "@material-ui/core/Typography";
import InputLabel from "@material-ui/core/InputLabel";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Switch from "@material-ui/core/Switch";

import Skeleton from "@material-ui/lab/Skeleton";

import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from "@material-ui/pickers";

import { DateTime } from "luxon";
import LuxonUtils from "@date-io/luxon";
import { useUserStore } from "./UserStore";

import { EditorState, convertToRaw, ContentState } from "draft-js";
import { Editor } from "react-draft-wysiwyg";
import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";

import i18n from "./i18n";
import { useTranslation } from "react-i18next";

import { makeStyles } from "@material-ui/core/styles";

import ConceptChips from "./ConceptChips";
import BingoGameDataAdminTable from "./BingoGameDataAdminTable";

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
  //const { xl, i18n } = useTranslation( 'bingo_game' );

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
    getBingoGameData();
    initResultData();
  }, []);

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
    // Save
    setSaveStatus(t("save_status"));
    fetch(props.bingoGameUrl + ".json", {
      method: "PATCH",
      credentials: "include",
      body: JSON.stringify({
        bingo_game: {
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
      }),
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return {};
        }
      })
      .then(data => {
        //TODO: handle save errors
        setSaveStatus(data.notice);
        setDirty(false);
        setMessages(data.messages);

        getBingoGameData();
      });
  };

  const initResultData = () => {
    fetch(props.gameResultsUrl + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        setResultData(data);
      });
  };

  const getBingoGameData = () => {
    fetch(props.bingoGameUrl + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        const projects = new Array({ id: -1, name: "None Selected" }).concat(
          data.projects
        );

        setGameProjects(projects);
        setConcepts(data.concepts);
        setGameTopic(data.topic);
        setGameDescriptionEditor(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft(data.description).contentBlocks
            )
          )
        );
        setGameSource(data.source);
        setGameActive(data.active);
        setGameStartDate(DateTime.fromISO(data.start_date).toJSDate());
        setGameEndDate(DateTime.fromISO(data.end_date).toJSDate());
        setGameIndividualCount(data.individual_count);
        setGameLeadTime(data.lead_time);
        //Group options
        setGameGroupOption(data.group_option);
        setGameGroupDiscount(data.group_discount);
        setGameGroupProjectId(data.project_id);
        setDirty(false);
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
        className={classes.button}
        onClick={saveBingoGame}
        id="save_bingo_game"
        value="save_bingo_game"
      >
        {t("update_bingo_btn")}
      </Button>
    </Suspense>
  ) : null;

  const group_options = gameGroupOption ? (
    <Suspense fallback={<Skeleton variant="text" />}>
      <React.Fragment>
        <Grid item>
          <TextField
            id="bingo-name"
            label={t("group_discount")}
            type="number"
            className={classes.textField}
            value={gameGroupDiscount}
            onChange={event => setGameGroupDiscount(event.target.value)}
            margin="normal"
            error={null != messages.name}
            helper={messages.name}
          />
        </Grid>
        <Grid item>
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
        <Tabs value={curTab} onChange={changeTab} centered>
          <Tab value="details" label={t("game_details_pnl")} />
          <Tab value="results" label={t("response_pnl")} />
        </Tabs>
        {"details" == curTab && (
          <React.Fragment>
            <Grid container spacing={10}>
              <Grid item>
                <TextField
                  id="topic"
                  label={t("topic")}
                  className={classes.textField}
                  value={gameTopic}
                  onChange={event => setGameTopic(event.target.value)}
                  margin="normal"
                />
              </Grid>
              <Grid item>
                <Editor
                  toolbarClassName="demo-toolbar-absolute"
                  wrapperId="Description"
                  label={t("description")}
                  onEditorStateChange={setGameDescriptionEditor}
                  toolbarOnFocus
                  toolbar={{
                    options: ["inline", "list", "link"]
                  }}
                  editorState={gameDescriptionEditor}
                />
              </Grid>
              <Grid item>
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
              <Grid item>
                <TextField
                  id="bingo-individual_count"
                  label={t("ind_term_count")}
                  className={classes.textField}
                  value={gameIndividualCount}
                  type="number"
                  onChange={event => setGameIndividualCount(event.target.value)}
                  InputLabelProps={{
                    shrink: true
                  }}
                  margin="normal"
                />
              </Grid>
              <MuiPickersUtilsProvider utils={LuxonUtils}>
                <Grid item>
                  <KeyboardDatePicker
                    disableToolbar
                    variant="inline"
                    autoOk={true}
                    format="MM/dd/yyyy"
                    margin="normal"
                    id="bingo-start_date"
                    label={t("open_date")}
                    value={gameStartDate}
                    onChange={setGameStartDate}
                  />
                </Grid>
                <Grid item>
                  <KeyboardDatePicker
                    disableToolbar
                    variant="inline"
                    autoOk={true}
                    format="MM/dd/yyyy"
                    margin="normal"
                    id="bingo-end_date"
                    label={t("close_date")}
                    value={gameEndDate}
                    onChange={setGameEndDate}
                  />
                </Grid>
              </MuiPickersUtilsProvider>
              <Grid item>
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
              <Grid item>
                <Switch
                  checked={gameGroupOption}
                  id="group_option"
                  onChange={event => setGameGroupOption(!gameGroupOption)}
                  disabled={null == gameProjects || 1 > gameProjects.length}
                />
                <InputLabel htmlFor="group_option">
                  {t("group_option")}
                </InputLabel>
              </Grid>
              {group_options}
            </Grid>
            {save_btn}
            <Typography>{saveStatus}</Typography>
          </React.Fragment>
        )}
        {"results" == curTab && (
          <Grid container style={{ height: "100%" }}>
            <Grid item xs={5}>
              <ConceptChips concepts={concepts} />
            </Grid>
            <Grid item xs={7}>
              <BingoGameDataAdminTable results_raw={resultData} />
            </Grid>
          </Grid>
        )}
      </Paper>
    </Suspense>
  );
}

BingoGameDataAdmin.propTypes = {
  bingoGameUrl: PropTypes.string.isRequired,
  token: PropTypes.string.isRequired,
  conceptUrl: PropTypes.string.isRequired,
  gameResultsUrl: PropTypes.string.isRequired
};
